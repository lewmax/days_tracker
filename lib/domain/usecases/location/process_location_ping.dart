import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/data/services/location_processing_service.dart';
import 'package:injectable/injectable.dart';

/// Parameters for processing a location ping.
class ProcessLocationPingParams {
  final double latitude;
  final double longitude;
  final double? accuracy;

  const ProcessLocationPingParams({required this.latitude, required this.longitude, this.accuracy});
}

/// Use case for processing a background location ping.
///
/// This is the main entry point for background location tracking.
/// It orchestrates:
/// 1. Saving the raw ping
/// 2. Reverse geocoding to get city/country
/// 3. Creating or extending visits
/// 4. Updating daily presence records
@lazySingleton
class ProcessLocationPing {
  final LocationProcessingService _processingService;

  ProcessLocationPing(this._processingService);

  /// Executes the use case.
  ///
  /// [params] The location ping parameters.
  /// Returns [Either] with [Failure] on error or void on success.
  Future<Either<Failure, void>> call(ProcessLocationPingParams params) async {
    // Validate coordinates
    if (params.latitude < -90 || params.latitude > 90) {
      return Left(ValidationFailure(message: 'Invalid latitude: ${params.latitude}'));
    }
    if (params.longitude < -180 || params.longitude > 180) {
      return Left(ValidationFailure(message: 'Invalid longitude: ${params.longitude}'));
    }

    return _processingService.processLocationPing(
      latitude: params.latitude,
      longitude: params.longitude,
      accuracy: params.accuracy,
    );
  }
}
