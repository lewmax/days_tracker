import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/data/database/daos/location_pings_dao.dart';
import 'package:days_tracker/data/mappers/location_ping_mapper.dart';
import 'package:days_tracker/domain/entities/location_ping.dart';
import 'package:days_tracker/domain/enums/geocoding_status.dart';
import 'package:days_tracker/domain/repositories/location_repository.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:injectable/injectable.dart';

/// Implementation of [LocationRepository] using geolocator and local database.
@LazySingleton(as: LocationRepository)
class LocationRepositoryImpl implements LocationRepository {
  final LocationPingsDao _locationPingsDao;

  LocationRepositoryImpl(this._locationPingsDao);

  @override
  Future<Either<Failure, Position>> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Left(LocationFailure(message: 'Location services are disabled'));
      }

      // Check permission
      var permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          return const Left(PermissionFailure(message: 'Location permission denied'));
        }
      }

      if (permission == geo.LocationPermission.deniedForever) {
        return const Left(PermissionFailure(message: 'Location permission permanently denied'));
      }

      // Get current position
      final geoPosition = await geo.Geolocator.getLastKnownPosition();

      if (geoPosition == null) {
        return const Left(LocationFailure(message: 'No location data available'));
      }

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

  @override
  Future<Either<Failure, List<LocationPing>>> getPendingGeocoding() async {
    try {
      final pingDataList = await _locationPingsDao.getPendingGeocoding();
      final pings = pingDataList.map((p) => p.toEntity()).toList();
      return Right(pings);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get pending geocoding: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> savePing(LocationPing ping) async {
    try {
      await _locationPingsDao.insertPing(ping.toCompanion());
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to save ping: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePingGeocodingStatus({
    required String pingId,
    required String? cityName,
    required String? countryCode,
    required GeocodingStatus status,
  }) async {
    try {
      if (status == GeocodingStatus.success && cityName != null && countryCode != null) {
        await _locationPingsDao.updateGeocodingSuccess(
          pingId: pingId,
          cityName: cityName,
          countryCode: countryCode,
        );
      } else if (status == GeocodingStatus.failed || status == GeocodingStatus.pending) {
        await _locationPingsDao.updateGeocodingFailed(pingId);
      }
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to update geocoding status: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> linkPingToVisit({
    required String pingId,
    required String visitId,
  }) async {
    try {
      await _locationPingsDao.linkToVisit(pingId, visitId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to link ping to visit: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LocationPing>>> getPingsForVisit(String visitId) async {
    try {
      final pingDataList = await _locationPingsDao.getPingsForVisit(visitId);
      final pings = pingDataList.map((p) => p.toEntity()).toList();
      return Right(pings);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get pings for visit: $e'));
    }
  }
}
