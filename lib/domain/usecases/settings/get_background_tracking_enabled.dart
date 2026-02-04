import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for checking if background tracking is enabled.
///
/// Background tracking captures hourly location pings even when
/// the app is not in the foreground.
@lazySingleton
class GetBackgroundTrackingEnabled {
  final SettingsRepository _repository;

  GetBackgroundTrackingEnabled(this._repository);

  /// Executes the use case.
  ///
  /// Returns [Either] with [Failure] on error or [bool] on success.
  /// Returns false as default if not set.
  Future<Either<Failure, bool>> call() async {
    return _repository.getBackgroundTrackingEnabled();
  }
}
