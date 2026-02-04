import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/core/utils/date_utils.dart';
import 'package:days_tracker/data/database/daos/daily_presence_dao.dart';
import 'package:days_tracker/data/database/daos/location_pings_dao.dart';
import 'package:days_tracker/data/database/daos/visits_dao.dart';
import 'package:days_tracker/data/mappers/location_ping_mapper.dart';
import 'package:days_tracker/data/mappers/visit_mapper.dart';
import 'package:days_tracker/data/services/geocoding_service.dart';
import 'package:days_tracker/domain/entities/location_ping.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/enums/geocoding_status.dart';
import 'package:days_tracker/domain/enums/visit_source.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

/// Service for processing location pings.
///
/// This is the core business logic for background location tracking.
/// It handles:
/// 1. Saving raw pings
/// 2. Geocoding coordinates to cities
/// 3. Creating/extending visits
/// 4. Updating daily presence
@lazySingleton
class LocationProcessingService {
  final LocationPingsDao _pingsDao;
  final VisitsDao _visitsDao;
  final DailyPresenceDao _presenceDao;
  final GeocodingService _geocodingService;
  final Uuid _uuid;

  LocationProcessingService(
    this._pingsDao,
    this._visitsDao,
    this._presenceDao,
    this._geocodingService,
    this._uuid,
  );

  /// Processes a new location ping.
  ///
  /// This is the main entry point for background location updates.
  ///
  /// [latitude] GPS latitude.
  /// [longitude] GPS longitude.
  /// [accuracy] GPS accuracy in meters.
  /// Returns void on success or Failure.
  Future<Either<Failure, void>> processLocationPing({
    required double latitude,
    required double longitude,
    required double? accuracy,
  }) async {
    try {
      final now = DateTime.now().toUtc();
      final pingId = _uuid.v4();

      // Step 1: Save raw ping immediately (status=pending)
      final ping = LocationPing(
        id: pingId,
        timestamp: now,
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
        geocodingStatus: GeocodingStatus.pending,
      );

      await _pingsDao.insertPing(ping.toCompanion());

      // Step 2: Attempt reverse geocoding
      final geocodeResult = await _geocodingService.reverseGeocode(
        latitude: latitude,
        longitude: longitude,
      );

      return geocodeResult.fold(
        (failure) async {
          // Geocoding failed - leave ping as pending for retry
          return const Right(null);
        },
        (city) async {
          // Step 3: Update ping with geocoding success
          await _pingsDao.updateGeocodingSuccess(
            pingId: pingId,
            cityName: city.cityName,
            countryCode: city.country?.countryCode ?? '',
          );

          // Step 4: Get current active visit
          final activeVisitData = await _visitsDao.getActiveVisit();

          if (activeVisitData == null) {
            // No active visit - create new one
            await _createNewVisit(
              cityId: city.id,
              pingId: pingId,
              timestamp: now,
              latitude: latitude,
              longitude: longitude,
            );
          } else if (activeVisitData.cityId == city.id) {
            // Same city - extend existing visit
            await _extendVisit(
              visitId: activeVisitData.id,
              pingId: pingId,
              timestamp: now,
              cityId: city.id,
              countryId: city.countryId,
            );
          } else {
            // Different city - close old visit, create new one
            await _visitsDao.closeActiveVisit(activeVisitData.id, now);
            await _createNewVisit(
              cityId: city.id,
              pingId: pingId,
              timestamp: now,
              latitude: latitude,
              longitude: longitude,
            );
          }

          return const Right(null);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to process location ping: $e'));
    }
  }

  /// Creates a new auto visit.
  Future<void> _createNewVisit({
    required int cityId,
    required String pingId,
    required DateTime timestamp,
    required double latitude,
    required double longitude,
  }) async {
    final visitId = _uuid.v4();

    final visit = Visit(
      id: visitId,
      cityId: cityId,
      startDate: timestamp,
      isActive: true,
      source: VisitSource.auto,
      userLatitude: latitude,
      userLongitude: longitude,
      lastUpdated: timestamp,
    );

    await _visitsDao.insertVisit(visit.toCompanion());

    // Link ping to visit
    await _pingsDao.linkToVisit(pingId, visitId);

    // Update daily presence
    await _updateDailyPresence(
      visitId: visitId,
      date: timestamp,
      cityId: cityId,
      countryId: await _getCountryIdForCity(cityId),
    );
  }

  /// Extends an existing visit with a new ping.
  Future<void> _extendVisit({
    required String visitId,
    required String pingId,
    required DateTime timestamp,
    required int cityId,
    required int countryId,
  }) async {
    // Update visit's lastUpdated
    await _visitsDao.updateLastUpdated(visitId, timestamp);

    // Link ping to visit
    await _pingsDao.linkToVisit(pingId, visitId);

    // Update daily presence
    await _updateDailyPresence(
      visitId: visitId,
      date: timestamp,
      cityId: cityId,
      countryId: countryId,
    );
  }

  /// Updates or creates a daily presence record.
  Future<void> _updateDailyPresence({
    required String visitId,
    required DateTime date,
    required int cityId,
    required int countryId,
  }) async {
    final dateStr = AppDateUtils.formatDate(date);

    // Check if record exists
    final existing = await _presenceDao.findByDateAndCity(dateStr, cityId);

    if (existing != null) {
      // Increment ping count
      await _presenceDao.incrementPingCount(existing.id);
    } else {
      // Create new record
      await _presenceDao.getOrCreate(
        visitId: visitId,
        date: dateStr,
        cityId: cityId,
        countryId: countryId,
      );
    }
  }

  /// Gets the country ID for a city (helper method).
  Future<int> _getCountryIdForCity(int cityId) async {
    // In a real implementation, this would query the city to get countryId
    // For now, we'll assume it's available from the geocoding service
    return 1; // Placeholder - actual implementation would query database
  }

  /// Retries geocoding for pending pings.
  ///
  /// Call this periodically to process pings that failed geocoding.
  Future<Either<Failure, int>> retryFailedGeocoding() async {
    try {
      final pendingPings = await _pingsDao.getPendingGeocoding();
      var processedCount = 0;

      for (final pingData in pendingPings) {
        final result = await _geocodingService.reverseGeocode(
          latitude: pingData.latitude,
          longitude: pingData.longitude,
        );

        await result.fold(
          (failure) async {
            // Still failed - update retry count
            await _pingsDao.updateGeocodingFailed(pingData.id);
          },
          (city) async {
            // Success - update ping
            await _pingsDao.updateGeocodingSuccess(
              pingId: pingData.id,
              cityName: city.cityName,
              countryCode: city.country?.countryCode ?? '',
            );
            processedCount++;

            // TODO: Also need to update visits/presence if ping wasn't
            // linked to a visit during initial processing
          },
        );
      }

      return Right(processedCount);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to retry geocoding: $e'));
    }
  }
}
