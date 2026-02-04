import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/data/services/geocoding_service.dart';
import 'package:days_tracker/domain/entities/city.dart';
import 'package:injectable/injectable.dart';

/// Parameters for reverse geocoding.
class ReverseGeocodeParams {
  final double latitude;
  final double longitude;

  const ReverseGeocodeParams({required this.latitude, required this.longitude});
}

/// Use case for reverse geocoding coordinates to a city.
///
/// First checks the local database for nearby cached cities,
/// then falls back to Google Maps API if no match is found.
@lazySingleton
class ReverseGeocodeLocation {
  final GeocodingService _geocodingService;

  ReverseGeocodeLocation(this._geocodingService);

  /// Executes the use case.
  ///
  /// [params] The coordinates to reverse geocode.
  /// Returns [Either] with [Failure] on error or [City] on success.
  Future<Either<Failure, City>> call(ReverseGeocodeParams params) async {
    // Validate coordinates
    if (params.latitude < -90 || params.latitude > 90) {
      return Left(ValidationFailure(message: 'Invalid latitude: ${params.latitude}'));
    }
    if (params.longitude < -180 || params.longitude > 180) {
      return Left(ValidationFailure(message: 'Invalid longitude: ${params.longitude}'));
    }

    return _geocodingService.reverseGeocode(latitude: params.latitude, longitude: params.longitude);
  }
}
