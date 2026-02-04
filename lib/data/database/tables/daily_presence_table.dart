import 'package:days_tracker/data/database/tables/cities_table.dart';
import 'package:days_tracker/data/database/tables/countries_table.dart';
import 'package:days_tracker/data/database/tables/visits_table.dart';
import 'package:drift/drift.dart';

/// Drift table definition for daily presence.
///
/// Denormalized table for fast day counting. One record per (date, city) pair.
/// Updated whenever a location ping is processed.
@DataClassName('DailyPresenceData')
class DailyPresenceTable extends Table {
  @override
  String get tableName => 'daily_presence';

  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Associated visit ID.
  /// Cascade delete: when visit is deleted, presence records are deleted.
  TextColumn get visitId => text().references(Visits, #id)();

  /// Date in YYYY-MM-DD format.
  TextColumn get date => text()();

  /// City where user was present.
  IntColumn get cityId => integer().references(Cities, #id)();

  /// Country where user was present (denormalized for fast queries).
  IntColumn get countryId => integer().references(Countries, #id)();

  /// Number of pings recorded on this day.
  IntColumn get pingCount => integer().withDefault(const Constant(1))();

  /// Whether this meets the "any presence" rule (always true).
  BoolColumn get meetsAnyPresenceRule => boolean().withDefault(const Constant(true))();

  /// Whether this meets the "two or more pings" rule.
  BoolColumn get meetsTwoOrMorePingsRule => boolean().withDefault(const Constant(false))();

  /// Record creation timestamp.
  DateTimeColumn get createdAt => dateTime()();

  /// Record last update timestamp.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {date, cityId},
  ];
}
