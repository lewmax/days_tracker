import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/data/services/location_processing_service.dart';
import 'package:injectable/injectable.dart';

/// Use case for retrying geocoding on failed location pings.
///
/// This should be called periodically (e.g., when network becomes available)
/// to retry geocoding pings that previously failed.
@lazySingleton
class RetryFailedGeocoding {
  final LocationProcessingService _processingService;

  RetryFailedGeocoding(this._processingService);

  /// Executes the use case.
  ///
  /// Returns [Either] with [Failure] on error or the count of
  /// successfully processed pings on success.
  Future<Either<Failure, int>> call() async {
    return _processingService.retryFailedGeocoding();
  }
}
