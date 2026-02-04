import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/constants/app_constants.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/data/database/daos/cities_dao.dart';
import 'package:days_tracker/data/database/daos/countries_dao.dart';
import 'package:days_tracker/data/database/daos/daily_presence_dao.dart';
import 'package:days_tracker/data/database/daos/location_pings_dao.dart';
import 'package:days_tracker/data/database/daos/visits_dao.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

/// Model for export data format.
class ExportDataModel {
  final String version;
  final DateTime exportedAt;
  final String appVersion;
  final ExportDataContent data;

  ExportDataModel({
    required this.version,
    required this.exportedAt,
    required this.appVersion,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
    'version': version,
    'exported_at': exportedAt.toIso8601String(),
    'app_version': appVersion,
    'data': data.toJson(),
  };

  factory ExportDataModel.fromJson(Map<String, dynamic> json) {
    return ExportDataModel(
      version: json['version'] as String,
      exportedAt: DateTime.parse(json['exported_at'] as String),
      appVersion: json['app_version'] as String,
      data: ExportDataContent.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

/// Content of the export data.
class ExportDataContent {
  final List<Map<String, dynamic>> countries;
  final List<Map<String, dynamic>> cities;
  final List<Map<String, dynamic>> visits;
  final List<Map<String, dynamic>> locationPings;
  final List<Map<String, dynamic>> dailyPresence;

  ExportDataContent({
    required this.countries,
    required this.cities,
    required this.visits,
    required this.locationPings,
    required this.dailyPresence,
  });

  Map<String, dynamic> toJson() => {
    'countries': countries,
    'cities': cities,
    'visits': visits,
    'location_pings': locationPings,
    'daily_presence': dailyPresence,
  };

  factory ExportDataContent.fromJson(Map<String, dynamic> json) {
    return ExportDataContent(
      countries: List<Map<String, dynamic>>.from(
        (json['countries'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      ),
      cities: List<Map<String, dynamic>>.from(
        (json['cities'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      ),
      visits: List<Map<String, dynamic>>.from(
        (json['visits'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      ),
      locationPings: List<Map<String, dynamic>>.from(
        (json['location_pings'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      ),
      dailyPresence: List<Map<String, dynamic>>.from(
        (json['daily_presence'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      ),
    );
  }
}

/// Service for exporting all app data to JSON format.
///
/// Exports all tables (countries, cities, visits, location_pings, daily_presence)
/// in a structured JSON format that can be imported later.
@lazySingleton
class ExportService {
  final CountriesDao _countriesDao;
  final CitiesDao _citiesDao;
  final VisitsDao _visitsDao;
  final LocationPingsDao _pingsDao;
  final DailyPresenceDao _presenceDao;
  final Logger _logger = Logger();

  ExportService(
    this._countriesDao,
    this._citiesDao,
    this._visitsDao,
    this._pingsDao,
    this._presenceDao,
  );

  /// Exports all data to a JSON string.
  ///
  /// Returns the JSON string on success or a [Failure] on error.
  Future<Either<Failure, String>> exportToJson() async {
    try {
      _logger.i('Starting data export...');

      // Get all data from each table
      final countries = await _countriesDao.getAll();
      final cities = await _citiesDao.getAll();
      final visits = await _visitsDao.getAll();
      final pings = await _pingsDao.getAll();
      final presence = await _presenceDao.getAll();

      _logger.i(
        'Exporting: ${countries.length} countries, ${cities.length} cities, '
        '${visits.length} visits, ${pings.length} pings, ${presence.length} daily presence',
      );

      // Convert to export format
      final exportData = ExportDataModel(
        version: '1.0.0',
        exportedAt: DateTime.now().toUtc(),
        appVersion: AppConstants.appVersion,
        data: ExportDataContent(
          countries: countries.map(_countryToJson).toList(),
          cities: cities.map(_cityToJson).toList(),
          visits: visits.map(_visitToJson).toList(),
          locationPings: pings.map(_pingToJson).toList(),
          dailyPresence: presence.map(_presenceToJson).toList(),
        ),
      );

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData.toJson());
      _logger.i('Export completed successfully');

      return Right(jsonString);
    } catch (e) {
      _logger.e('Export failed: $e');
      return Left(StorageFailure(message: 'Failed to export data: $e'));
    }
  }

  /// Converts CountryData to JSON map.
  Map<String, dynamic> _countryToJson(dynamic country) {
    return {
      'id': country.id,
      'country_code': country.countryCode,
      'country_name': country.countryName,
      'total_days': country.totalDays,
      'first_visit_date': country.firstVisitDate?.toIso8601String(),
      'last_visit_date': country.lastVisitDate?.toIso8601String(),
      'created_at': country.createdAt.toIso8601String(),
      'updated_at': country.updatedAt.toIso8601String(),
    };
  }

  /// Converts CityData to JSON map.
  Map<String, dynamic> _cityToJson(dynamic city) {
    return {
      'id': city.id,
      'country_id': city.countryId,
      'city_name': city.cityName,
      'latitude': city.latitude,
      'longitude': city.longitude,
      'total_days': city.totalDays,
      'created_at': city.createdAt.toIso8601String(),
      'updated_at': city.updatedAt.toIso8601String(),
    };
  }

  /// Converts VisitData to JSON map.
  Map<String, dynamic> _visitToJson(dynamic visit) {
    return {
      'id': visit.id,
      'city_id': visit.cityId,
      'start_date': visit.startDate.toIso8601String(),
      'end_date': visit.endDate?.toIso8601String(),
      'is_active': visit.isActive,
      'source': visit.source,
      'user_latitude': visit.userLatitude,
      'user_longitude': visit.userLongitude,
      'last_updated': visit.lastUpdated.toIso8601String(),
      'created_at': visit.createdAt.toIso8601String(),
    };
  }

  /// Converts LocationPingData to JSON map.
  Map<String, dynamic> _pingToJson(dynamic ping) {
    return {
      'id': ping.id,
      'visit_id': ping.visitId,
      'timestamp': ping.timestamp.toIso8601String(),
      'latitude': ping.latitude,
      'longitude': ping.longitude,
      'accuracy': ping.accuracy,
      'city_name': ping.cityName,
      'country_code': ping.countryCode,
      'geocoding_status': ping.geocodingStatus,
      'retry_count': ping.retryCount,
      'created_at': ping.createdAt.toIso8601String(),
    };
  }

  /// Converts DailyPresenceData to JSON map.
  Map<String, dynamic> _presenceToJson(dynamic presence) {
    return {
      'id': presence.id,
      'visit_id': presence.visitId,
      'date': presence.date,
      'city_id': presence.cityId,
      'country_id': presence.countryId,
      'ping_count': presence.pingCount,
      'meets_any_presence_rule': presence.meetsAnyPresenceRule,
      'meets_two_or_more_pings_rule': presence.meetsTwoOrMorePingsRule,
      'created_at': presence.createdAt.toIso8601String(),
      'updated_at': presence.updatedAt.toIso8601String(),
    };
  }
}
