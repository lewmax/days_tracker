import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/repositories/location_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for getting the current GPS location.
///
/// Handles permission requests and location service checks.
@lazySingleton
class GetCurrentLocation {
  final LocationRepository _repository;

  GetCurrentLocation(this._repository);

  /// Executes the use case.
  ///
  /// Returns [Either] with [Failure] on error or [Position] on success.
  /// May return [PermissionFailure] if location permission is denied.
  /// May return [LocationFailure] if location services are disabled.
  Future<Either<Failure, Position>> call() async {
    return _repository.getCurrentLocation();
  }
}
