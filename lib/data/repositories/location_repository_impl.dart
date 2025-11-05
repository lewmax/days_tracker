import 'dart:convert';

import 'package:days_tracker/domain/repositories/location_repository.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

@LazySingleton(as: LocationRepository)
class LocationRepositoryImpl implements LocationRepository {
  final Logger _logger = Logger();
  String? _mapboxToken;

  LocationRepositoryImpl();

  void setMapboxToken(String token) {
    _mapboxToken = token;
  }

  @override
  Future<Position> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 30),
      );
      return position;
    } catch (e) {
      _logger.e('Error getting current location: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  @override
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  @override
  Future<Map<String, String?>> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    // Try Mapbox first if token is available
    if (_mapboxToken != null && _mapboxToken!.isNotEmpty) {
      try {
        final result = await _reverseGeocodeMapbox(latitude, longitude);
        if (result != null) return result;
      } catch (e) {
        _logger.w('Mapbox geocoding failed, falling back to device: $e');
      }
    }

    // Fall back to device geocoding
    return await _reverseGeocodeDevice(latitude, longitude);
  }

  Future<Map<String, String?>?> _reverseGeocodeMapbox(
    double latitude,
    double longitude,
  ) async {
    final url =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$longitude,$latitude.json?access_token=$_mapboxToken&types=place,country';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>?;

      if (features != null && features.isNotEmpty) {
        String? city;
        String? countryCode;

        for (final feature in features) {
          final placeType = feature['place_type'] as List<dynamic>?;
          if (placeType != null) {
            if (placeType.contains('place')) {
              city = feature['text'] as String?;
            }
            if (placeType.contains('country')) {
              final properties = feature['properties'] as Map<String, dynamic>?;
              countryCode = properties?['short_code'] as String?;
              countryCode = countryCode?.toUpperCase();
            }
          }
        }

        return {
          'city': city,
          'countryCode': countryCode,
        };
      }
    }

    return null;
  }

  Future<Map<String, String?>> _reverseGeocodeDevice(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return {
          'city': place.locality ?? place.subAdministrativeArea,
          'countryCode': place.isoCountryCode,
        };
      }
    } catch (e) {
      _logger.e('Device geocoding failed: $e');
    }

    return {
      'city': null,
      'countryCode': null,
    };
  }
}
