import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/data/database/tables/cities_table.dart';
import 'package:days_tracker/data/database/tables/countries_table.dart';
import 'package:days_tracker/data/database/tables/daily_presence_table.dart';
import 'package:drift/drift.dart';

part 'daily_presence_dao.g.dart';

/// Data Access Object for daily_presence table.
///
/// Provides CRUD operations and specific queries for daily presence records.
@DriftAccessor(tables: [DailyPresenceTable, Cities, Countries])
class DailyPresenceDao extends DatabaseAccessor<AppDatabase> with _$DailyPresenceDaoMixin {
  DailyPresenceDao(super.db);

  /// Gets all daily presence records.
  Future<List<DailyPresenceData>> getAll() {
    return (select(dailyPresenceTable)..orderBy([(d) => OrderingTerm.desc(d.date)])).get();
  }

  /// Gets a presence record by ID.
  Future<DailyPresenceData?> getById(int id) {
    return (select(dailyPresenceTable)..where((d) => d.id.equals(id))).getSingleOrNull();
  }

  /// Inserts a new daily presence record.
  Future<int> insertPresence(DailyPresenceTableCompanion presence) {
    return into(dailyPresenceTable).insert(presence);
  }

  /// Updates an existing presence record.
  Future<bool> updatePresence(DailyPresenceData presence) {
    return update(dailyPresenceTable).replace(presence);
  }

  /// Deletes a presence record by ID.
  Future<int> deleteById(int id) {
    return (delete(dailyPresenceTable)..where((d) => d.id.equals(id))).go();
  }

  /// Deletes all presence records for a visit.
  Future<int> deleteByVisitId(String visitId) {
    return (delete(dailyPresenceTable)..where((d) => d.visitId.equals(visitId))).go();
  }

  /// Finds a presence record by date and city.
  Future<DailyPresenceData?> findByDateAndCity(String date, int cityId) {
    return (select(
      dailyPresenceTable,
    )..where((d) => d.date.equals(date) & d.cityId.equals(cityId))).getSingleOrNull();
  }

  /// Increments the ping count for a presence record.
  Future<void> incrementPingCount(int id) async {
    final presence = await getById(id);
    if (presence == null) return;

    final newPingCount = presence.pingCount + 1;
    final meetsTwoOrMore = newPingCount >= 2;

    await (update(dailyPresenceTable)..where((d) => d.id.equals(id))).write(
      DailyPresenceTableCompanion(
        pingCount: Value(newPingCount),
        meetsTwoOrMorePingsRule: Value(meetsTwoOrMore),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Gets presence records in a date range.
  Future<List<DailyPresenceData>> getInDateRange({
    required String startDate,
    required String endDate,
  }) {
    return (select(dailyPresenceTable)
          ..where(
            (d) => d.date.isBiggerOrEqualValue(startDate) & d.date.isSmallerOrEqualValue(endDate),
          )
          ..orderBy([(d) => OrderingTerm.asc(d.date)]))
        .get();
  }

  /// Gets presence records for a specific country in a date range.
  Future<List<DailyPresenceData>> getByCountryInRange({
    required int countryId,
    required String startDate,
    required String endDate,
  }) {
    return (select(dailyPresenceTable)
          ..where(
            (d) =>
                d.countryId.equals(countryId) &
                d.date.isBiggerOrEqualValue(startDate) &
                d.date.isSmallerOrEqualValue(endDate),
          )
          ..orderBy([(d) => OrderingTerm.asc(d.date)]))
        .get();
  }

  /// Gets presence records for a specific city in a date range.
  Future<List<DailyPresenceData>> getByCityInRange({
    required int cityId,
    required String startDate,
    required String endDate,
  }) {
    return (select(dailyPresenceTable)
          ..where(
            (d) =>
                d.cityId.equals(cityId) &
                d.date.isBiggerOrEqualValue(startDate) &
                d.date.isSmallerOrEqualValue(endDate),
          )
          ..orderBy([(d) => OrderingTerm.asc(d.date)]))
        .get();
  }

  /// Gets all presence records for a specific date.
  Future<List<DailyPresenceData>> getByDate(String date) {
    return (select(dailyPresenceTable)..where((d) => d.date.equals(date))).get();
  }

  /// Counts unique days per country in a date range.
  ///
  /// [rule] If 'anyPresence', counts all records. If 'twoOrMorePings',
  /// counts only records with meetsTwoOrMorePingsRule = true.
  Future<Map<int, int>> countDaysByCountry({
    required String startDate,
    required String endDate,
    required bool requireTwoOrMorePings,
  }) async {
    var query = select(
      dailyPresenceTable,
    )..where((d) => d.date.isBiggerOrEqualValue(startDate) & d.date.isSmallerOrEqualValue(endDate));

    if (requireTwoOrMorePings) {
      query = query..where((d) => d.meetsTwoOrMorePingsRule.equals(true));
    }

    final records = await query.get();

    // Group by country and count unique dates
    final Map<int, Set<String>> countryDates = {};
    for (final record in records) {
      countryDates.putIfAbsent(record.countryId, () => {});
      countryDates[record.countryId]!.add(record.date);
    }

    return countryDates.map((key, value) => MapEntry(key, value.length));
  }

  /// Counts unique days per city in a date range.
  Future<Map<int, int>> countDaysByCity({
    required String startDate,
    required String endDate,
    required bool requireTwoOrMorePings,
  }) async {
    var query = select(
      dailyPresenceTable,
    )..where((d) => d.date.isBiggerOrEqualValue(startDate) & d.date.isSmallerOrEqualValue(endDate));

    if (requireTwoOrMorePings) {
      query = query..where((d) => d.meetsTwoOrMorePingsRule.equals(true));
    }

    final records = await query.get();

    // Group by city and count unique dates
    final Map<int, Set<String>> cityDates = {};
    for (final record in records) {
      cityDates.putIfAbsent(record.cityId, () => {});
      cityDates[record.cityId]!.add(record.date);
    }

    return cityDates.map((key, value) => MapEntry(key, value.length));
  }

  /// Gets or creates a daily presence record.
  Future<DailyPresenceData> getOrCreate({
    required String visitId,
    required String date,
    required int cityId,
    required int countryId,
  }) async {
    final existing = await findByDateAndCity(date, cityId);
    if (existing != null) {
      return existing;
    }

    final now = DateTime.now().toUtc();
    final id = await insertPresence(
      DailyPresenceTableCompanion.insert(
        visitId: visitId,
        date: date,
        cityId: cityId,
        countryId: countryId,
        createdAt: now,
        updatedAt: now,
      ),
    );

    return (await getById(id))!;
  }
}
