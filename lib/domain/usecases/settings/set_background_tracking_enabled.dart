import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/data/services/background_service.dart';
import 'package:days_tracker/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for enabling or disabling background tracking.
///
/// When enabled, the app will capture hourly location pings
/// even when running in the background. This use case handles
/// both persisting the setting and starting/stopping the
/// background service.
@lazySingleton
class SetBackgroundTrackingEnabled {
  final SettingsRepository _repository;
  final BackgroundService _backgroundService;

  SetBackgroundTrackingEnabled(this._repository, this._backgroundService);

  /// Executes the use case.
  ///
  /// [enabled] Whether background tracking should be enabled.
  /// Returns [Either] with [Failure] on error or void on success.
  Future<Either<Failure, void>> call(bool enabled) async {
    // First, start or stop the background service
    final serviceResult = enabled
        ? await _backgroundService.startTracking()
        : await _backgroundService.stopTracking();

    // If service operation failed, return the failure
    if (serviceResult.isLeft()) {
      return serviceResult;
    }

    // Then persist the setting
    return _repository.setBackgroundTrackingEnabled(enabled);
  }
}
