import 'package:days_tracker/data/database/tables/cities_table.dart';
import 'package:drift/drift.dart';

/// Drift table definition for visits.
///
/// A visit represents a continuous stay in a single city.
@DataClassName('VisitData')
class Visits extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// Foreign key to the city.
  /// Cascade delete: when city is deleted, visits are deleted.
  IntColumn get cityId => integer().references(Cities, #id)();

  /// Start date of the visit (UTC).
  DateTimeColumn get startDate => dateTime()();

  /// End date of the visit (UTC), null if visit is ongoing.
  DateTimeColumn get endDate => dateTime().nullable()();

  /// Whether this visit is currently active.
  /// Only one visit should be active at a time.
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();

  /// Source of the visit: 'manual' or 'auto'.
  TextColumn get source => text()();

  /// User's actual latitude when visit was created (for auto visits).
  RealColumn get userLatitude => real().nullable()();

  /// User's actual longitude when visit was created (for auto visits).
  RealColumn get userLongitude => real().nullable()();

  /// Last time this visit was updated (last ping for auto visits).
  DateTimeColumn get lastUpdated => dateTime()();

  /// Record creation timestamp.
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
