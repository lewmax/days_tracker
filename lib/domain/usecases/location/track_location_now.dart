import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/data/services/background_service.dart';
import 'package:injectable/injectable.dart';

/// Use case for triggering an immediate location tracking operation.
///
/// This is useful for testing the location tracking functionality
/// or for getting an immediate location update without waiting
/// for the scheduled background task.
@lazySingleton
class TrackLocationNow {
  final BackgroundService _backgroundService;

  TrackLocationNow(this._backgroundService);

  /// Executes the use case.
  ///
  /// Returns [Either] with [Failure] on error or void on success.
  /// This will get the current location and process it as a ping.
  Future<Either<Failure, void>> call() async {
    return _backgroundService.trackNow();
  }
}
