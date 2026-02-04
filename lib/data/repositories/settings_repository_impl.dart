import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:days_tracker/domain/repositories/settings_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys for SharedPreferences storage.
class _SettingsKeys {
  static const String dayCountingRule = 'day_counting_rule';
  static const String backgroundTrackingEnabled = 'background_tracking_enabled';
}

/// Keys for secure storage.
class _SecureKeys {
  static const String googleMapsApiKey = 'google_maps_api_key';
}

/// Implementation of [SettingsRepository] using SharedPreferences and SecureStorage.
@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  SettingsRepositoryImpl(this._prefs, this._secureStorage);

  @override
  Future<Either<Failure, DayCountingRule>> getDayCountingRule() async {
    try {
      final value = _prefs.getString(_SettingsKeys.dayCountingRule);
      if (value == null) {
        return const Right(DayCountingRule.anyPresence);
      }

      final rule = DayCountingRule.values.firstWhere(
        (r) => r.name == value,
        orElse: () => DayCountingRule.anyPresence,
      );

      return Right(rule);
    } catch (e) {
      return Left(StorageFailure(message: 'Failed to get day counting rule: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setDayCountingRule(DayCountingRule rule) async {
    try {
      await _prefs.setString(_SettingsKeys.dayCountingRule, rule.name);
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(message: 'Failed to set day counting rule: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> getBackgroundTrackingEnabled() async {
    try {
      final value = _prefs.getBool(_SettingsKeys.backgroundTrackingEnabled);
      return Right(value ?? false);
    } catch (e) {
      return Left(StorageFailure(message: 'Failed to get background tracking: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setBackgroundTrackingEnabled(bool enabled) async {
    try {
      await _prefs.setBool(_SettingsKeys.backgroundTrackingEnabled, enabled);
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(message: 'Failed to set background tracking: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getGoogleMapsApiKey() async {
    try {
      final key = await _secureStorage.read(key: _SecureKeys.googleMapsApiKey);
      return Right(key);
    } catch (e) {
      return Left(StorageFailure(message: 'Failed to get Google Maps API key: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setGoogleMapsApiKey(String key) async {
    try {
      await _secureStorage.write(key: _SecureKeys.googleMapsApiKey, value: key);
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(message: 'Failed to set Google Maps API key: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearGoogleMapsApiKey() async {
    try {
      await _secureStorage.delete(key: _SecureKeys.googleMapsApiKey);
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(message: 'Failed to clear Google Maps API key: $e'));
    }
  }
}
