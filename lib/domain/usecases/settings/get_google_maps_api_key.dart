import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for getting the Google Maps API key.
///
/// The API key is stored securely and used for reverse geocoding
/// and places autocomplete.
@lazySingleton
class GetGoogleMapsApiKey {
  final SettingsRepository _repository;

  GetGoogleMapsApiKey(this._repository);

  /// Executes the use case.
  ///
  /// Returns [Either] with [Failure] on error or [String?] on success.
  /// Returns null if no API key has been configured.
  Future<Either<Failure, String?>> call() async {
    return _repository.getGoogleMapsApiKey();
  }
}
