class AppConstants {
  // App info
  static const String appName = 'DaysTracker';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String storageKeyVisits = 'visits_v1';
  static const String storageKeyPings = 'location_pings_v1';

  // Time periods for summary
  static const int days183 = 183;
  static const int days365 = 365;

  // Tracking
  static const int defaultTrackingFrequencyMinutes = 60;
  static const int minTrackingFrequencyMinutes = 15;
  static const int maxTrackingFrequencyMinutes = 360; // 6 hours

  // Location accuracy
  static const double cityRadiusKm = 50.0;

  // Privacy
  static const String privacyNotice = '''
DaysTracker is a privacy-first app. All your location data is stored locally on your device and encrypted using industry-standard encryption.

No data is ever sent to external servers. You can export your data, delete all data, or disable background tracking at any time.

Background location tracking is used only to automatically log your visits. You can disable this feature in settings.
''';

  // Mapbox
  static const String mapboxStyleUrl = 'mapbox://styles/mapbox/streets-v11';
}
