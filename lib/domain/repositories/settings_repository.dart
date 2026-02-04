import 'package:dartz/dartz.dart';

import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/enums/day_counting_rule.dart';

/// Abstract repository for application settings.
///
/// Settings are stored locally using SharedPreferences and SecureStorage.
abstract class SettingsRepository {
  /// Gets the current day counting rule.
  ///
  /// Returns the default rule (anyPresence) if not set.
  Future<Either<Failure, DayCountingRule>> getDayCountingRule();

  /// Sets the day counting rule.
  ///
  /// [rule] The rule to set.
  Future<Either<Failure, void>> setDayCountingRule(DayCountingRule rule);

  /// Gets whether background tracking is enabled.
  ///
  /// Returns false if not set.
  Future<Either<Failure, bool>> getBackgroundTrackingEnabled();

  /// Sets whether background tracking is enabled.
  ///
  /// [enabled] Whether to enable background tracking.
  Future<Either<Failure, void>> setBackgroundTrackingEnabled(bool enabled);

  /// Gets the Google Maps API key.
  ///
  /// Returns null if not set. Key is stored securely.
  Future<Either<Failure, String?>> getGoogleMapsApiKey();

  /// Sets the Google Maps API key.
  ///
  /// [key] The API key to store securely.
  Future<Either<Failure, void>> setGoogleMapsApiKey(String key);

  /// Clears the Google Maps API key.
  Future<Either<Failure, void>> clearGoogleMapsApiKey();
}
