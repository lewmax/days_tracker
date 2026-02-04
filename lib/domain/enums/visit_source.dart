/// Enum representing the source of a visit record.
///
/// Helps distinguish between user-entered visits and automatically
/// tracked visits for different handling and display purposes.
enum VisitSource {
  /// User manually added this visit.
  manual,

  /// Visit was automatically created from background location tracking.
  auto;

  /// Returns a human-readable label.
  String get label {
    switch (this) {
      case VisitSource.manual:
        return 'Manual';
      case VisitSource.auto:
        return 'Auto';
    }
  }

  /// Converts string to enum value.
  static VisitSource fromString(String value) {
    switch (value.toLowerCase()) {
      case 'manual':
        return VisitSource.manual;
      case 'auto':
        return VisitSource.auto;
      default:
        return VisitSource.manual;
    }
  }
}
