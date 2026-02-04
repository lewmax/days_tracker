import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for clearing the Google Maps API key.
///
/// Removes the stored API key from secure storage.
@lazySingleton
class ClearGoogleMapsApiKey {
  final SettingsRepository _repository;

  ClearGoogleMapsApiKey(this._repository);

  /// Executes the use case.
  ///
  /// Returns [Either] with [Failure] on error or void on success.
  Future<Either<Failure, void>> call() async {
    return _repository.clearGoogleMapsApiKey();
  }
}
