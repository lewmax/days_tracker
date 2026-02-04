import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/repositories/location_repository.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

/// Permission status for location access.
enum LocationPermissionStatus {
  /// Permission has not been requested yet.
  notDetermined,

  /// Permission was denied.
  denied,

  /// Permission was permanently denied (user needs to enable in settings).
  deniedForever,

  /// Permission granted while app is in use.
  whileInUse,

  /// Permission granted always (including background).
  always,
}

/// Service wrapper around geolocator package.
///
/// Provides a clean interface for location-related operations
/// with proper error handling.
@lazySingleton
class LocationService {
  final Logger _logger = Logger();

  /// Checks if location services are enabled.
  Future<bool> isLocationServiceEnabled() async {
    return geo.Geolocator.isLocationServiceEnabled();
  }

  /// Opens device location settings.
  Future<bool> openLocationSettings() async {
    return geo.Geolocator.openLocationSettings();
  }

  /// Opens app settings (for permission changes).
  Future<bool> openAppSettings() async {
    return geo.Geolocator.openAppSettings();
  }

  /// Checks current location permission status.
  Future<Either<Failure, LocationPermissionStatus>> checkPermission() async {
    try {
      final permission = await geo.Geolocator.checkPermission();
      return Right(_mapPermission(permission));
    } catch (e) {
      return Left(PermissionFailure(message: 'Failed to check permission: $e'));
    }
  }

  /// Requests location permission.
  Future<Either<Failure, LocationPermissionStatus>> requestPermission() async {
    try {
      final permission = await geo.Geolocator.requestPermission();
      return Right(_mapPermission(permission));
    } catch (e) {
      return Left(PermissionFailure(message: 'Failed to request permission: $e'));
    }
  }

  /// Gets the current position.
  ///
  /// Returns Position or appropriate Failure.
  Future<Either<Failure, Position>> getCurrentPosition() async {
    try {
      _logger.d('[LocationService] getCurrentPosition');
      final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.w('[LocationService] Location services disabled');
        return const Left(LocationFailure(message: 'Location services are disabled'));
      }

      var permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          return const Left(PermissionFailure(message: 'Location permission denied'));
        }
      }

      if (permission == geo.LocationPermission.deniedForever) {
        return const Left(
          PermissionFailure(
            message:
                'Location permission permanently denied. '
                'Please enable in app settings.',
          ),
        );
      }

      final geoPosition = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(accuracy: geo.LocationAccuracy.high),
      );
      _logger.i('[LocationService] Position: ${geoPosition.latitude}, ${geoPosition.longitude}');

      return Right(
        Position(
          latitude: geoPosition.latitude,
          longitude: geoPosition.longitude,
          accuracy: geoPosition.accuracy,
          timestamp: geoPosition.timestamp,
        ),
      );
    } on geo.LocationServiceDisabledException {
      return const Left(LocationFailure(message: 'Location services are disabled'));
    } on geo.PermissionDeniedException {
      return const Left(PermissionFailure(message: 'Location permission denied'));
    } catch (e) {
      return Left(LocationFailure(message: 'Failed to get location: $e'));
    }
  }

  /// Gets the last known position (faster but may be stale).
  Future<Either<Failure, Position?>> getLastKnownPosition() async {
    try {
      final geoPosition = await geo.Geolocator.getLastKnownPosition();
      if (geoPosition == null) {
        return const Right(null);
      }

      return Right(
        Position(
          latitude: geoPosition.latitude,
          longitude: geoPosition.longitude,
          accuracy: geoPosition.accuracy,
          timestamp: geoPosition.timestamp,
        ),
      );
    } catch (e) {
      return Left(LocationFailure(message: 'Failed to get last position: $e'));
    }
  }

  /// Maps geolocator permission to our enum.
  LocationPermissionStatus _mapPermission(geo.LocationPermission permission) {
    switch (permission) {
      case geo.LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case geo.LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case geo.LocationPermission.whileInUse:
        return LocationPermissionStatus.whileInUse;
      case geo.LocationPermission.always:
        return LocationPermissionStatus.always;
      default:
        return LocationPermissionStatus.notDetermined;
    }
  }
}
