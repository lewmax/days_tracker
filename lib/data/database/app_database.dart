import 'dart:io';

import 'package:days_tracker/core/constants/app_constants.dart';
import 'package:days_tracker/data/database/tables/tables.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Main database class for the application.
///
/// Uses Drift for type-safe SQLite access. All tables are defined
/// in the tables/ directory and included here.
@DriftDatabase(tables: [Countries, Cities, Visits, LocationPings, DailyPresenceTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructor for testing with a custom executor.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Create indexes for better query performance
        await _createIndexes(m);
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future migrations here
      },
    );
  }

  /// Creates custom indexes for better query performance.
  Future<void> _createIndexes(Migrator m) async {
    // Countries indexes
    await customStatement('CREATE INDEX IF NOT EXISTS idx_country_code ON countries(country_code)');

    // Cities indexes
    await customStatement('CREATE INDEX IF NOT EXISTS idx_city_country ON cities(country_id)');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_city_location ON cities(latitude, longitude)',
    );

    // Visits indexes
    await customStatement('CREATE INDEX IF NOT EXISTS idx_visit_city ON visits(city_id)');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_visit_dates ON visits(start_date, end_date)',
    );
    await customStatement('CREATE INDEX IF NOT EXISTS idx_visit_active ON visits(is_active)');

    // Location pings indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_ping_status ON location_pings(geocoding_status)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_ping_timestamp ON location_pings(timestamp)',
    );

    // Daily presence indexes
    await customStatement('CREATE INDEX IF NOT EXISTS idx_daily_date ON daily_presence(date)');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_daily_country ON daily_presence(country_id)',
    );
    await customStatement('CREATE INDEX IF NOT EXISTS idx_daily_city ON daily_presence(city_id)');
  }

  /// Clears all data from all tables.
  ///
  /// Use with caution - this is destructive and cannot be undone.
  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(dailyPresenceTable).go();
      await delete(locationPings).go();
      await delete(visits).go();
      await delete(cities).go();
      await delete(countries).go();
    });
  }
}

/// Opens a connection to the database.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.databaseName));
    return NativeDatabase.createInBackground(file);
  });
}
