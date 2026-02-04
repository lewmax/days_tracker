import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for setting the Google Maps API key.
///
/// The API key is stored securely in encrypted storage
/// and used for geocoding operations.
@lazySingleton
class SetGoogleMapsApiKey {
  final SettingsRepository _repository;

  SetGoogleMapsApiKey(this._repository);

  /// Executes the use case.
  ///
  /// [apiKey] The Google Maps API key to store.
  /// Returns [Either] with [Failure] on error or void on success.
  Future<Either<Failure, void>> call(String apiKey) async {
    if (apiKey.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'API key cannot be empty'));
    }
    return _repository.setGoogleMapsApiKey(apiKey);
  }
}
