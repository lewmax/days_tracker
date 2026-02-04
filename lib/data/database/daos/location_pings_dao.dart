import 'package:days_tracker/core/constants/app_constants.dart';
import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/data/database/tables/location_pings_table.dart';
import 'package:drift/drift.dart';

part 'location_pings_dao.g.dart';

/// Data Access Object for location_pings table.
///
/// Provides CRUD operations and specific queries for location pings.
@DriftAccessor(tables: [LocationPings])
class LocationPingsDao extends DatabaseAccessor<AppDatabase> with _$LocationPingsDaoMixin {
  LocationPingsDao(super.db);

  /// Gets all location pings ordered by timestamp descending.
  Future<List<LocationPingData>> getAll() {
    return (select(locationPings)..orderBy([(p) => OrderingTerm.desc(p.timestamp)])).get();
  }

  /// Gets a ping by its ID.
  Future<LocationPingData?> getById(String id) {
    return (select(locationPings)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  /// Inserts a new location ping.
  Future<void> insertPing(LocationPingsCompanion ping) {
    return into(locationPings).insert(ping);
  }

  /// Updates an existing ping.
  Future<bool> updatePing(LocationPingData ping) {
    return update(locationPings).replace(ping);
  }

  /// Deletes a ping by ID.
  Future<int> deleteById(String id) {
    return (delete(locationPings)..where((p) => p.id.equals(id))).go();
  }

  /// Gets pings that need geocoding (pending or failed with retries left).
  Future<List<LocationPingData>> getPendingGeocoding() {
    return (select(locationPings)
          ..where(
            (p) =>
                p.geocodingStatus.equals('pending') |
                (p.geocodingStatus.equals('failed') &
                    p.retryCount.isSmallerThanValue(AppConstants.maxGeocodingRetries)),
          )
          ..orderBy([(p) => OrderingTerm.asc(p.timestamp)]))
        .get();
  }

  /// Updates geocoding status after successful geocoding.
  Future<void> updateGeocodingSuccess({
    required String pingId,
    required String cityName,
    required String countryCode,
  }) {
    return (update(locationPings)..where((p) => p.id.equals(pingId))).write(
      LocationPingsCompanion(
        cityName: Value(cityName),
        countryCode: Value(countryCode),
        geocodingStatus: const Value('success'),
      ),
    );
  }

  /// Updates geocoding status after failed geocoding.
  Future<void> updateGeocodingFailed(String pingId) async {
    final ping = await getById(pingId);
    if (ping == null) return;

    final newRetryCount = ping.retryCount + 1;
    final newStatus = newRetryCount >= AppConstants.maxGeocodingRetries ? 'failed' : 'pending';

    await (update(locationPings)..where((p) => p.id.equals(pingId))).write(
      LocationPingsCompanion(retryCount: Value(newRetryCount), geocodingStatus: Value(newStatus)),
    );
  }

  /// Links a ping to a visit.
  Future<void> linkToVisit(String pingId, String visitId) {
    return (update(
      locationPings,
    )..where((p) => p.id.equals(pingId))).write(LocationPingsCompanion(visitId: Value(visitId)));
  }

  /// Gets all pings for a specific visit.
  Future<List<LocationPingData>> getPingsForVisit(String visitId) {
    return (select(locationPings)
          ..where((p) => p.visitId.equals(visitId))
          ..orderBy([(p) => OrderingTerm.asc(p.timestamp)]))
        .get();
  }

  /// Gets pings in a date range.
  Future<List<LocationPingData>> getInDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return (select(locationPings)
          ..where(
            (p) =>
                p.timestamp.isBiggerOrEqualValue(startDate) &
                p.timestamp.isSmallerOrEqualValue(endDate),
          )
          ..orderBy([(p) => OrderingTerm.desc(p.timestamp)]))
        .get();
  }

  /// Gets the most recent ping.
  Future<LocationPingData?> getMostRecent() {
    return (select(locationPings)
          ..orderBy([(p) => OrderingTerm.desc(p.timestamp)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Watches pings that need geocoding.
  Stream<List<LocationPingData>> watchPendingGeocoding() {
    return (select(locationPings)
          ..where(
            (p) =>
                p.geocodingStatus.equals('pending') |
                (p.geocodingStatus.equals('failed') &
                    p.retryCount.isSmallerThanValue(AppConstants.maxGeocodingRetries)),
          )
          ..orderBy([(p) => OrderingTerm.asc(p.timestamp)]))
        .watch();
  }
}
