import 'package:drift/drift.dart';

/// Drift table definition for countries.
///
/// Stores country information with ISO codes and cached statistics.
@DataClassName('CountryData')
class Countries extends Table {
  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// ISO 3166-1 alpha-2 country code (e.g., "PL", "UA").
  /// Must be exactly 2 characters and unique.
  TextColumn get countryCode => text().withLength(min: 2, max: 2).unique()();

  /// English name of the country.
  TextColumn get countryName => text()();

  /// Cached total days spent in this country.
  /// Recalculated when visits are modified.
  IntColumn get totalDays => integer().withDefault(const Constant(0))();

  /// Date of first recorded visit (null if no visits yet).
  DateTimeColumn get firstVisitDate => dateTime().nullable()();

  /// Date of most recent visit (null if no visits yet).
  DateTimeColumn get lastVisitDate => dateTime().nullable()();

  /// Record creation timestamp.
  DateTimeColumn get createdAt => dateTime()();

  /// Record last update timestamp.
  DateTimeColumn get updatedAt => dateTime()();
}
