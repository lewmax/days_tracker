import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/data/database/tables/cities_table.dart';
import 'package:days_tracker/data/database/tables/visits_table.dart';
import 'package:drift/drift.dart';

part 'visits_dao.g.dart';

/// Data Access Object for visits table.
///
/// Provides CRUD operations and specific queries for visits.
@DriftAccessor(tables: [Visits, Cities])
class VisitsDao extends DatabaseAccessor<AppDatabase> with _$VisitsDaoMixin {
  VisitsDao(super.db);

  /// Gets all visits ordered by start date descending.
  Future<List<VisitData>> getAll() {
    return (select(visits)..orderBy([(v) => OrderingTerm.desc(v.startDate)])).get();
  }

  /// Gets a visit by its ID.
  Future<VisitData?> getById(String id) {
    return (select(visits)..where((v) => v.id.equals(id))).getSingleOrNull();
  }

  /// Gets the currently active visit (if any).
  Future<VisitData?> getActiveVisit() {
    return (select(visits)..where((v) => v.isActive.equals(true))).getSingleOrNull();
  }

  /// Inserts a new visit.
  Future<void> insertVisit(VisitsCompanion visit) {
    return into(visits).insert(visit);
  }

  /// Updates an existing visit.
  Future<bool> updateVisit(VisitData visit) {
    return update(visits).replace(visit);
  }

  /// Deletes a visit by ID.
  /// This will cascade delete associated daily_presence records.
  Future<int> deleteById(String id) {
    return (delete(visits)..where((v) => v.id.equals(id))).go();
  }

  /// Checks if a date range overlaps with existing visits.
  ///
  /// [start] Start of the range to check.
  /// [end] End of the range (null for active visits).
  /// [excludeId] Optional visit ID to exclude from the check (for updates).
  /// Returns true if there's an overlap.
  Future<bool> hasOverlap(DateTime start, DateTime? end, {String? excludeId}) async {
    // A visit overlaps if:
    // - Its start is before our end (or our end is null - active)
    // - AND its end is after our start (or its end is null - active)

    var query = select(visits);

    if (excludeId != null) {
      query = query..where((v) => v.id.equals(excludeId).not());
    }

    final allVisits = await query.get();

    for (final visit in allVisits) {
      final visitStart = visit.startDate;
      final visitEnd = visit.endDate;

      // Check overlap
      final ourEndCheck =
          end == null || visitStart.isBefore(end) || visitStart.isAtSameMomentAs(end);
      final theirEndCheck =
          visitEnd == null || visitEnd.isAfter(start) || visitEnd.isAtSameMomentAs(start);

      if (ourEndCheck && theirEndCheck) {
        return true;
      }
    }

    return false;
  }

  /// Gets visits in a date range.
  Future<List<VisitData>> getInDateRange({required DateTime startDate, required DateTime endDate}) {
    return (select(visits)
          ..where(
            (v) =>
                v.startDate.isSmallerOrEqualValue(endDate) &
                (v.endDate.isNull() | v.endDate.isBiggerOrEqualValue(startDate)),
          )
          ..orderBy([(v) => OrderingTerm.desc(v.startDate)]))
        .get();
  }

  /// Gets visits for a specific city.
  Future<List<VisitData>> getVisitsByCity(int cityId) {
    return (select(visits)
          ..where((v) => v.cityId.equals(cityId))
          ..orderBy([(v) => OrderingTerm.desc(v.startDate)]))
        .get();
  }

  /// Closes an active visit by setting its end date.
  Future<void> closeActiveVisit(String id, DateTime endDate) {
    return (update(visits)..where((v) => v.id.equals(id))).write(
      VisitsCompanion(
        isActive: const Value(false),
        endDate: Value(endDate),
        lastUpdated: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Updates the lastUpdated timestamp for a visit.
  Future<void> updateLastUpdated(String id, DateTime lastUpdated) {
    return (update(
      visits,
    )..where((v) => v.id.equals(id))).write(VisitsCompanion(lastUpdated: Value(lastUpdated)));
  }

  /// Watches all visits for changes.
  Stream<List<VisitData>> watchAll() {
    return (select(visits)..orderBy([(v) => OrderingTerm.desc(v.startDate)])).watch();
  }

  /// Gets the overlapping visit (if any) for error messages.
  Future<VisitData?> getOverlappingVisit(DateTime start, DateTime? end, {String? excludeId}) async {
    var query = select(visits);

    if (excludeId != null) {
      query = query..where((v) => v.id.equals(excludeId).not());
    }

    final allVisits = await query.get();

    for (final visit in allVisits) {
      final visitStart = visit.startDate;
      final visitEnd = visit.endDate;

      final ourEndCheck =
          end == null || visitStart.isBefore(end) || visitStart.isAtSameMomentAs(end);
      final theirEndCheck =
          visitEnd == null || visitEnd.isAfter(start) || visitEnd.isAtSameMomentAs(start);

      if (ourEndCheck && theirEndCheck) {
        return visit;
      }
    }

    return null;
  }
}
