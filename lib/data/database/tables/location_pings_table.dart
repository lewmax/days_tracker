import 'package:days_tracker/data/database/tables/visits_table.dart';
import 'package:drift/drift.dart';

/// Drift table definition for location pings.
///
/// Raw GPS readings from background tracking. Each ping is geocoded
/// to determine the city and country.
@DataClassName('LocationPingData')
class LocationPings extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// Associated visit ID (null if not yet linked).
  /// Set null on visit delete to preserve ping history.
  TextColumn get visitId => text().nullable().references(Visits, #id)();

  /// Timestamp when the ping was recorded (UTC).
  DateTimeColumn get timestamp => dateTime()();

  /// Raw GPS latitude.
  RealColumn get latitude => real()();

  /// Raw GPS longitude.
  RealColumn get longitude => real()();

  /// GPS accuracy in meters (if available).
  RealColumn get accuracy => real().nullable()();

  /// City name from geocoding (null if pending).
  TextColumn get cityName => text().nullable()();

  /// Country code from geocoding (null if pending).
  TextColumn get countryCode => text().nullable()();

  /// Status of geocoding: 'success', 'pending', or 'failed'.
  TextColumn get geocodingStatus => text()();

  /// Number of failed geocoding retry attempts.
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  /// Record creation timestamp.
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
