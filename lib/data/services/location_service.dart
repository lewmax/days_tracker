import 'package:days_tracker/domain/entities/location_ping.dart';
import 'package:days_tracker/domain/repositories/location_repository.dart';
import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:days_tracker/domain/usecases/update_visit_from_location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

@lazySingleton
class LocationService {
  final LocationRepository _locationRepository;
  final VisitsRepository _visitsRepository;
  final UpdateVisitFromLocation _updateVisitFromLocation;
  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();

  LocationService(
    this._locationRepository,
    this._visitsRepository,
    this._updateVisitFromLocation,
  );

  /// Perform a single location check and update visits
  /// This is called by background tasks or manual refresh
  Future<void> performLocationCheck({String source = 'manual'}) async {
    try {
      _logger.i('Starting location check from source: $source');

      // Check if location services are enabled
      final serviceEnabled =
          await _locationRepository.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.w('Location services are disabled');
        return;
      }

      // Check permissions
      final permission = await _locationRepository.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _logger.w('Location permission not granted: $permission');
        return;
      }

      // Get current location
      final position = await _locationRepository.getCurrentLocation();
      _logger.i('Got location: ${position.latitude}, ${position.longitude}');

      // Reverse geocode to get city and country
      final geocode = await _locationRepository.reverseGeocode(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Create location ping
      final ping = LocationPing(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        city: geocode['city'],
        countryCode: geocode['countryCode'],
        source: source,
        geocodingPending: geocode['countryCode'] == null,
      );

      _logger.i(
        'Location ping: ${ping.city}, ${ping.countryCode} (pending: ${ping.geocodingPending})',
      );

      // Update visit based on location
      await _updateVisitFromLocation.execute(ping);

      _logger.i('Location check completed successfully');
    } catch (e, stackTrace) {
      _logger.e('Error performing location check: $e',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Retry geocoding for pending pings (when network becomes available)
  Future<void> retryPendingGeocoding() async {
    try {
      final pendingPings = await _visitsRepository.getPendingGeocodingPings();
      _logger.i('Retrying geocoding for ${pendingPings.length} pings');

      for (final ping in pendingPings) {
        try {
          final geocode = await _locationRepository.reverseGeocode(
            latitude: ping.latitude,
            longitude: ping.longitude,
          );

          if (geocode['countryCode'] != null) {
            final updatedPing = ping.copyWith(
              city: geocode['city'],
              countryCode: geocode['countryCode'],
              geocodingPending: false,
            );
            await _visitsRepository.updateLocationPing(updatedPing);

            // Also update visit if this affects the active visit
            await _updateVisitFromLocation.execute(updatedPing);
          }
        } catch (e) {
          _logger.w('Failed to geocode ping ${ping.id}: $e');
        }
      }
    } catch (e) {
      _logger.e('Error retrying pending geocoding: $e');
    }
  }

  /// Request location permissions
  Future<bool> requestLocationPermission() async {
    try {
      final permission = await _locationRepository.requestPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      _logger.e('Error requesting location permission: $e');
      return false;
    }
  }

  /// Check current permission status
  Future<LocationPermission> checkPermission() async {
    return await _locationRepository.checkPermission();
  }
}
