import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/repositories/settings_repository.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

/// Result from reverse geocoding.
class GeocodingResult {
  final String cityName;
  final String countryCode;
  final String countryName;
  final double latitude;
  final double longitude;

  const GeocodingResult({
    required this.cityName,
    required this.countryCode,
    required this.countryName,
    required this.latitude,
    required this.longitude,
  });
}

/// Result from places autocomplete.
class PlaceResult {
  final String placeId;
  final String description;
  final String? cityName;
  final String? countryCode;

  const PlaceResult({
    required this.placeId,
    required this.description,
    this.cityName,
    this.countryCode,
  });
}

/// Data source for Google Maps API calls.
@lazySingleton
class GoogleMapsApiDataSource {
  final SettingsRepository _settingsRepository;
  final http.Client _httpClient;
  final Logger _logger = Logger();

  static const String _geocodeBaseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';
  static const String _placesBaseUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';

  GoogleMapsApiDataSource(this._settingsRepository, this._httpClient);

  /// Gets the API key from secure storage.
  Future<String?> _getApiKey() async {
    final result = await _settingsRepository.getGoogleMapsApiKey();
    return result.fold((failure) => null, (key) => key);
  }

  /// Reverse geocodes coordinates to city and country.
  ///
  /// [latitude] The latitude.
  /// [longitude] The longitude.
  /// Returns GeocodingResult or Failure.
  Future<Either<Failure, GeocodingResult>> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      _logger.d('[GoogleMapsApi] reverseGeocode lat=$latitude lon=$longitude');
      final apiKey = await _getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        _logger.w('[GoogleMapsApi] No API key configured');
        return const Left(GeocodingFailure(message: 'Google Maps API key not configured'));
      }

      final uri = Uri.parse(_geocodeBaseUrl).replace(
        queryParameters: {
          'latlng': '$latitude,$longitude',
          'key': apiKey,
          'result_type': 'locality|administrative_area_level_3',
          'language': 'en',
        },
      );

      final response = await _httpClient.get(uri);

      if (response.statusCode != 200) {
        return Left(NetworkFailure(message: 'Geocoding failed with status ${response.statusCode}'));
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String;

      if (status != 'OK') {
        _logger.w('[GoogleMapsApi] Geocode status: $status');
        if (status == 'ZERO_RESULTS') {
          return const Left(GeocodingFailure(message: 'No results found for coordinates'));
        } else if (status == 'REQUEST_DENIED') {
          return Left(
            GeocodingFailure(
              message: 'Request denied by Google Maps API: ${data['error_message']}',
            ),
          );
        }
        return Left(GeocodingFailure(message: 'Geocoding failed: $status'));
      }

      final results = data['results'] as List<dynamic>;
      if (results.isEmpty) {
        return const Left(GeocodingFailure(message: 'No results in response'));
      }

      // Parse the first result
      final result = results.first as Map<String, dynamic>;
      return _parseGeocodingResult(result, latitude, longitude);
    } on http.ClientException catch (e) {
      return Left(NetworkFailure(message: 'Network error: $e'));
    } catch (e) {
      return Left(GeocodingFailure(message: 'Geocoding error: $e'));
    }
  }

  /// Parses a geocoding result from the API response.
  Either<Failure, GeocodingResult> _parseGeocodingResult(
    Map<String, dynamic> result,
    double originalLat,
    double originalLon,
  ) {
    try {
      final addressComponents = result['address_components'] as List<dynamic>? ?? [];
      final geometry = result['geometry'] as Map<String, dynamic>?;
      final location = geometry?['location'] as Map<String, dynamic>?;

      String? cityName;
      String? countryCode;
      String? countryName;

      for (final component in addressComponents) {
        final types = (component['types'] as List<dynamic>).cast<String>();

        if (types.contains('locality')) {
          cityName = component['long_name'] as String?;
        } else if (types.contains('administrative_area_level_3') && cityName == null) {
          cityName = component['long_name'] as String?;
        } else if (types.contains('country')) {
          countryCode = component['short_name'] as String?;
          countryName = component['long_name'] as String?;
        }
      }

      if (cityName == null) {
        return const Left(GeocodingFailure(message: 'City name not found in result'));
      }

      if (countryCode == null) {
        return const Left(GeocodingFailure(message: 'Country code not found in result'));
      }

      // Use canonical coordinates from Google if available
      final canonicalLat = (location?['lat'] as num?)?.toDouble() ?? originalLat;
      final canonicalLon = (location?['lng'] as num?)?.toDouble() ?? originalLon;

      return Right(
        GeocodingResult(
          cityName: cityName,
          countryCode: countryCode,
          countryName: countryName ?? countryCode,
          latitude: canonicalLat,
          longitude: canonicalLon,
        ),
      );
    } catch (e) {
      return Left(GeocodingFailure(message: 'Failed to parse result: $e'));
    }
  }

  /// Searches for places using autocomplete.
  ///
  /// [query] The search query.
  /// [limit] Maximum number of results.
  /// Returns list of PlaceResult or Failure.
  Future<Either<Failure, List<PlaceResult>>> searchPlaces({
    required String query,
    int limit = 10,
  }) async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        return const Left(GeocodingFailure(message: 'Google Maps API key not configured'));
      }

      final uri = Uri.parse(_placesBaseUrl).replace(
        queryParameters: {'input': query, 'key': apiKey, 'types': '(cities)', 'language': 'en'},
      );

      final response = await _httpClient.get(uri);

      if (response.statusCode != 200) {
        return Left(
          NetworkFailure(message: 'Places search failed with status ${response.statusCode}'),
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String;

      if (status != 'OK' && status != 'ZERO_RESULTS') {
        return Left(GeocodingFailure(message: 'Places search failed: $status'));
      }

      final predictions = data['predictions'] as List<dynamic>? ?? [];
      final results = predictions.take(limit).map((p) {
        final prediction = p as Map<String, dynamic>;
        return PlaceResult(
          placeId: prediction['place_id'] as String,
          description: prediction['description'] as String,
        );
      }).toList();

      return Right(results);
    } on http.ClientException catch (e) {
      return Left(NetworkFailure(message: 'Network error: $e'));
    } catch (e) {
      return Left(GeocodingFailure(message: 'Places search error: $e'));
    }
  }
}
