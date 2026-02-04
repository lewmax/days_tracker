/// Enum representing the view mode for visits list display.
enum VisitsViewMode {
  /// Chronological list sorted by date (newest first).
  chronological,

  /// Grouped by country with expandable sections.
  groupedByCountry,

  /// Active visits pinned at top, then chronological.
  activeFirst,

  /// Grouped by month (e.g., "February 2026", "January 2026").
  monthGrouping;

  /// Returns a human-readable label.
  String get label {
    switch (this) {
      case VisitsViewMode.chronological:
        return 'Timeline';
      case VisitsViewMode.groupedByCountry:
        return 'By Country';
      case VisitsViewMode.activeFirst:
        return 'Active First';
      case VisitsViewMode.monthGrouping:
        return 'By Month';
    }
  }
}
