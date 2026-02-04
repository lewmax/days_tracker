import 'package:dartz/dartz.dart';

import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/location_ping.dart';
import 'package:days_tracker/domain/enums/geocoding_status.dart';

/// Position data from GPS.
class Position {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime timestamp;

  const Position({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.timestamp,
  });
}

/// Abstract repository for location-related operations.
///
/// Handles GPS location retrieval and location ping management.
abstract class LocationRepository {
  /// Gets the current GPS position.
  ///
  /// Returns PermissionFailure if location permission is denied.
  /// Returns LocationFailure if location services are disabled.
  Future<Either<Failure, Position>> getCurrentLocation();

  /// Retrieves all location pings that need geocoding.
  ///
  /// Returns pings with status 'pending' or 'failed' (with retry count < max).
  Future<Either<Failure, List<LocationPing>>> getPendingGeocoding();

  /// Saves a new location ping.
  ///
  /// [ping] The location ping to save.
  Future<Either<Failure, void>> savePing(LocationPing ping);

  /// Updates a ping's geocoding status and results.
  ///
  /// [pingId] The ID of the ping to update.
  /// [cityName] The resolved city name (null if failed).
  /// [countryCode] The resolved country code (null if failed).
  /// [status] The new geocoding status.
  Future<Either<Failure, void>> updatePingGeocodingStatus({
    required String pingId,
    required String? cityName,
    required String? countryCode,
    required GeocodingStatus status,
  });

  /// Links a location ping to a visit.
  ///
  /// [pingId] The ID of the ping.
  /// [visitId] The ID of the visit to link to.
  Future<Either<Failure, void>> linkPingToVisit({required String pingId, required String visitId});

  /// Gets all pings for a specific visit.
  ///
  /// [visitId] The ID of the visit.
  Future<Either<Failure, List<LocationPing>>> getPingsForVisit(String visitId);
}
