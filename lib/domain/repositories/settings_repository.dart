abstract class SettingsRepository {
  /// Background tracking enabled
  Future<bool> isBackgroundTrackingEnabled();
  Future<void> setBackgroundTrackingEnabled(bool enabled);

  /// Overnight only filter
  Future<bool> isOvernightOnlyEnabled();
  Future<void> setOvernightOnlyEnabled(bool enabled);

  /// Mapbox access token
  Future<String?> getMapboxToken();
  Future<void> setMapboxToken(String token);

  /// Day counting rule
  Future<String> getDayCountingRule();
  Future<void> setDayCountingRule(String rule);

  /// Tracking frequency (in minutes)
  Future<int> getTrackingFrequency();
  Future<void> setTrackingFrequency(int minutes);

  /// Language preference
  Future<String> getLanguageCode();
  Future<void> setLanguageCode(String code);
}
