import 'package:days_tracker/data/database/tables/countries_table.dart';
import 'package:drift/drift.dart';

/// Drift table definition for cities.
///
/// Cities belong to countries and store canonical GPS coordinates.
@DataClassName('CityData')
class Cities extends Table {
  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Foreign key to parent country.
  /// Cascade delete: when country is deleted, cities are deleted.
  IntColumn get countryId => integer().references(Countries, #id)();

  /// English name of the city.
  TextColumn get cityName => text()();

  /// Canonical latitude (city center from geocoding).
  RealColumn get latitude => real()();

  /// Canonical longitude (city center from geocoding).
  RealColumn get longitude => real()();

  /// Cached total days spent in this city.
  IntColumn get totalDays => integer().withDefault(const Constant(0))();

  /// Record creation timestamp.
  DateTimeColumn get createdAt => dateTime()();

  /// Record last update timestamp.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {countryId, cityName},
  ];
}
