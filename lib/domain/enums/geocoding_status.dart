/// Enum representing the status of a geocoding operation for a location ping.
///
/// Used to track whether a raw GPS coordinate has been successfully
/// converted to a city/country name.
enum GeocodingStatus {
  /// Geocoding completed successfully.
  success,

  /// Geocoding is pending (waiting to be processed).
  pending,

  /// Geocoding failed after all retry attempts.
  failed;

  /// Returns a human-readable label.
  String get label {
    switch (this) {
      case GeocodingStatus.success:
        return 'Success';
      case GeocodingStatus.pending:
        return 'Pending';
      case GeocodingStatus.failed:
        return 'Failed';
    }
  }

  /// Converts string to enum value.
  static GeocodingStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'success':
        return GeocodingStatus.success;
      case 'pending':
        return GeocodingStatus.pending;
      case 'failed':
        return GeocodingStatus.failed;
      default:
        return GeocodingStatus.pending;
    }
  }
}
