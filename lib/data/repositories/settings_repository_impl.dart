import 'package:days_tracker/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences _prefs;

  static const String _backgroundTrackingKey = 'background_tracking_enabled';
  static const String _overnightOnlyKey = 'overnight_only_enabled';
  static const String _mapboxTokenKey = 'mapbox_token';
  static const String _dayCountingRuleKey = 'day_counting_rule';
  static const String _trackingFrequencyKey = 'tracking_frequency_minutes';
  static const String _languageCodeKey = 'language_code';

  SettingsRepositoryImpl(this._prefs);

  @override
  Future<bool> isBackgroundTrackingEnabled() async {
    return _prefs.getBool(_backgroundTrackingKey) ?? false;
  }

  @override
  Future<void> setBackgroundTrackingEnabled(bool enabled) async {
    await _prefs.setBool(_backgroundTrackingKey, enabled);
  }

  @override
  Future<bool> isOvernightOnlyEnabled() async {
    return _prefs.getBool(_overnightOnlyKey) ?? false;
  }

  @override
  Future<void> setOvernightOnlyEnabled(bool enabled) async {
    await _prefs.setBool(_overnightOnlyKey, enabled);
  }

  @override
  Future<String?> getMapboxToken() async {
    return _prefs.getString(_mapboxTokenKey);
  }

  @override
  Future<void> setMapboxToken(String token) async {
    await _prefs.setString(_mapboxTokenKey, token);
  }

  @override
  Future<String> getDayCountingRule() async {
    return _prefs.getString(_dayCountingRuleKey) ?? 'anyPresence';
  }

  @override
  Future<void> setDayCountingRule(String rule) async {
    await _prefs.setString(_dayCountingRuleKey, rule);
  }

  @override
  Future<int> getTrackingFrequency() async {
    return _prefs.getInt(_trackingFrequencyKey) ?? 60; // Default: 60 minutes
  }

  @override
  Future<void> setTrackingFrequency(int minutes) async {
    await _prefs.setInt(_trackingFrequencyKey, minutes);
  }

  @override
  Future<String> getLanguageCode() async {
    return _prefs.getString(_languageCodeKey) ?? 'en';
  }

  @override
  Future<void> setLanguageCode(String code) async {
    await _prefs.setString(_languageCodeKey, code);
  }
}
