/// Application-wide constants.
///
/// All magic numbers and configuration values should be defined here
/// to ensure consistency and easy modification.
class AppConstants {
  AppConstants._();

  /// App version string.
  static const String appVersion = '1.0.0';

  /// Radius in kilometers to consider a location as "same city".
  /// If a new ping is within this radius of an existing city, it's considered the same city.
  static const double nearbyCityRadiusKm = 50.0;

  /// Maximum number of retries for failed geocoding attempts.
  static const int maxGeocodingRetries = 3;

  /// Interval for background location fetch.
  static const Duration backgroundFetchInterval = Duration(hours: 1);

  /// Default number of days for statistics period.
  static const int defaultStatisticsDays = 183;

  /// Maximum number of flags to show in calendar cell.
  static const int maxFlagsInCalendarCell = 3;

  /// Number of results for city autocomplete.
  static const int cityAutocompleteLimit = 10;

  /// Number of recent cities to show.
  static const int recentCitiesLimit = 20;

  /// Database name.
  static const String databaseName = 'days_tracker.db';

  /// Export file version for compatibility checking.
  static const String exportVersion = '1.0.0';

  /// Minimum accuracy in meters for a location ping to be considered valid.
  static const double minLocationAccuracyMeters = 100.0;
}
