import 'package:geolocator/geolocator.dart';

abstract class LocationRepository {
  /// Get current location
  Future<Position> getCurrentLocation();

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled();

  /// Check location permission status
  Future<LocationPermission> checkPermission();

  /// Request location permission
  Future<LocationPermission> requestPermission();

  /// Reverse geocode coordinates to city and country
  Future<Map<String, String?>> reverseGeocode({
    required double latitude,
    required double longitude,
  });
}
