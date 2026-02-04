import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/data/services/export_service.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

/// Service for importing data from JSON format.
///
/// Parses and validates the JSON structure, then replaces all existing
/// data with the imported data.
@lazySingleton
class ImportService {
  final AppDatabase _database;
  final Logger _logger = Logger();

  ImportService(this._database);

  /// Validates the JSON structure without importing.
  ///
  /// Returns the parsed [ExportDataModel] on success or a [Failure] on error.
  Either<Failure, ExportDataModel> validateJson(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      // Check required fields
      if (!json.containsKey('version')) {
        return const Left(ValidationFailure(message: 'Missing version field'));
      }
      if (!json.containsKey('exported_at')) {
        return const Left(ValidationFailure(message: 'Missing exported_at field'));
      }
      if (!json.containsKey('data')) {
        return const Left(ValidationFailure(message: 'Missing data field'));
      }

      final data = json['data'] as Map<String, dynamic>;

      // Check data sections
      if (!data.containsKey('countries')) {
        return const Left(ValidationFailure(message: 'Missing countries data'));
      }
      if (!data.containsKey('cities')) {
        return const Left(ValidationFailure(message: 'Missing cities data'));
      }
      if (!data.containsKey('visits')) {
        return const Left(ValidationFailure(message: 'Missing visits data'));
      }
      if (!data.containsKey('location_pings')) {
        return const Left(ValidationFailure(message: 'Missing location_pings data'));
      }
      if (!data.containsKey('daily_presence')) {
        return const Left(ValidationFailure(message: 'Missing daily_presence data'));
      }

      // Parse and validate structure
      final exportData = ExportDataModel.fromJson(json);

      _logger.i(
        'Validated import data: ${exportData.data.countries.length} countries, '
        '${exportData.data.cities.length} cities, ${exportData.data.visits.length} visits',
      );

      return Right(exportData);
    } on FormatException catch (e) {
      return Left(ValidationFailure(message: 'Invalid JSON format: ${e.message}'));
    } catch (e) {
      return Left(ValidationFailure(message: 'Failed to parse import data: $e'));
    }
  }

  /// Imports data from a JSON string, replacing all existing data.
  ///
  /// This operation is destructive - all existing data will be deleted.
  /// Returns the number of records imported on success or a [Failure] on error.
  Future<Either<Failure, ImportResult>> importFromJson(String jsonString) async {
    // First validate
    final validationResult = validateJson(jsonString);

    return validationResult.fold((failure) => Left(failure), (exportData) async {
      try {
        _logger.i('Starting data import...');

        return await _database.transaction(() async {
          // Clear all existing data
          await _database.clearAllData();
          _logger.i('Cleared existing data');

          // Import countries (maintaining IDs for foreign key references)
          var countriesImported = 0;
          for (final countryJson in exportData.data.countries) {
            await _database
                .into(_database.countries)
                .insert(
                  CountriesCompanion.insert(
                    countryCode: countryJson['country_code'] as String,
                    countryName: countryJson['country_name'] as String,
                    totalDays: Value(countryJson['total_days'] as int? ?? 0),
                    firstVisitDate: Value(_parseDateTime(countryJson['first_visit_date'])),
                    lastVisitDate: Value(_parseDateTime(countryJson['last_visit_date'])),
                    createdAt: _parseDateTime(countryJson['created_at']) ?? DateTime.now().toUtc(),
                    updatedAt: _parseDateTime(countryJson['updated_at']) ?? DateTime.now().toUtc(),
                  ),
                  mode: InsertMode.insertOrReplace,
                );
            countriesImported++;
          }
          _logger.i('Imported $countriesImported countries');

          // Import cities
          var citiesImported = 0;
          for (final cityJson in exportData.data.cities) {
            await _database
                .into(_database.cities)
                .insert(
                  CitiesCompanion.insert(
                    countryId: cityJson['country_id'] as int,
                    cityName: cityJson['city_name'] as String,
                    latitude: (cityJson['latitude'] as num).toDouble(),
                    longitude: (cityJson['longitude'] as num).toDouble(),
                    totalDays: Value(cityJson['total_days'] as int? ?? 0),
                    createdAt: _parseDateTime(cityJson['created_at']) ?? DateTime.now().toUtc(),
                    updatedAt: _parseDateTime(cityJson['updated_at']) ?? DateTime.now().toUtc(),
                  ),
                  mode: InsertMode.insertOrReplace,
                );
            citiesImported++;
          }
          _logger.i('Imported $citiesImported cities');

          // Import visits
          var visitsImported = 0;
          for (final visitJson in exportData.data.visits) {
            await _database
                .into(_database.visits)
                .insert(
                  VisitsCompanion.insert(
                    id: visitJson['id'] as String,
                    cityId: visitJson['city_id'] as int,
                    startDate: _parseDateTime(visitJson['start_date'])!,
                    endDate: Value(_parseDateTime(visitJson['end_date'])),
                    isActive: Value(visitJson['is_active'] as bool? ?? false),
                    source: visitJson['source'] as String,
                    userLatitude: Value((visitJson['user_latitude'] as num?)?.toDouble()),
                    userLongitude: Value((visitJson['user_longitude'] as num?)?.toDouble()),
                    lastUpdated:
                        _parseDateTime(visitJson['last_updated']) ?? DateTime.now().toUtc(),
                    createdAt: _parseDateTime(visitJson['created_at']) ?? DateTime.now().toUtc(),
                  ),
                  mode: InsertMode.insertOrReplace,
                );
            visitsImported++;
          }
          _logger.i('Imported $visitsImported visits');

          // Import location pings
          var pingsImported = 0;
          for (final pingJson in exportData.data.locationPings) {
            await _database
                .into(_database.locationPings)
                .insert(
                  LocationPingsCompanion.insert(
                    id: pingJson['id'] as String,
                    visitId: Value(pingJson['visit_id'] as String?),
                    timestamp: _parseDateTime(pingJson['timestamp'])!,
                    latitude: (pingJson['latitude'] as num).toDouble(),
                    longitude: (pingJson['longitude'] as num).toDouble(),
                    accuracy: Value((pingJson['accuracy'] as num?)?.toDouble()),
                    cityName: Value(pingJson['city_name'] as String?),
                    countryCode: Value(pingJson['country_code'] as String?),
                    geocodingStatus: pingJson['geocoding_status'] as String,
                    retryCount: Value(pingJson['retry_count'] as int? ?? 0),
                    createdAt: _parseDateTime(pingJson['created_at']) ?? DateTime.now().toUtc(),
                  ),
                  mode: InsertMode.insertOrReplace,
                );
            pingsImported++;
          }
          _logger.i('Imported $pingsImported location pings');

          // Import daily presence
          var presenceImported = 0;
          for (final presenceJson in exportData.data.dailyPresence) {
            await _database
                .into(_database.dailyPresenceTable)
                .insert(
                  DailyPresenceTableCompanion.insert(
                    visitId: presenceJson['visit_id'] as String,
                    date: presenceJson['date'] as String,
                    cityId: presenceJson['city_id'] as int,
                    countryId: presenceJson['country_id'] as int,
                    pingCount: Value(presenceJson['ping_count'] as int? ?? 1),
                    meetsAnyPresenceRule: Value(
                      presenceJson['meets_any_presence_rule'] as bool? ?? true,
                    ),
                    meetsTwoOrMorePingsRule: Value(
                      presenceJson['meets_two_or_more_pings_rule'] as bool? ?? false,
                    ),
                    createdAt: _parseDateTime(presenceJson['created_at']) ?? DateTime.now().toUtc(),
                    updatedAt: _parseDateTime(presenceJson['updated_at']) ?? DateTime.now().toUtc(),
                  ),
                  mode: InsertMode.insertOrReplace,
                );
            presenceImported++;
          }
          _logger.i('Imported $presenceImported daily presence records');

          final result = ImportResult(
            countriesImported: countriesImported,
            citiesImported: citiesImported,
            visitsImported: visitsImported,
            pingsImported: pingsImported,
            presenceImported: presenceImported,
          );

          _logger.i('Import completed successfully: $result');
          return Right(result);
        });
      } catch (e) {
        _logger.e('Import failed: $e');
        return Left(DatabaseFailure(message: 'Failed to import data: $e'));
      }
    });
  }

  /// Parses a DateTime from a string, returning null if invalid.
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}

/// Result of an import operation.
class ImportResult {
  final int countriesImported;
  final int citiesImported;
  final int visitsImported;
  final int pingsImported;
  final int presenceImported;

  ImportResult({
    required this.countriesImported,
    required this.citiesImported,
    required this.visitsImported,
    required this.pingsImported,
    required this.presenceImported,
  });

  int get totalRecords =>
      countriesImported + citiesImported + visitsImported + pingsImported + presenceImported;

  @override
  String toString() =>
      'ImportResult(countries: $countriesImported, cities: $citiesImported, '
      'visits: $visitsImported, pings: $pingsImported, presence: $presenceImported)';
}
