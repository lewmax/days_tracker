/// Enum representing the view mode for statistics display.
enum StatisticsViewMode {
  /// Calendar grid view with flags showing daily presence.
  calendar,

  /// Chronological list sorted by date (newest first).
  chronological,

  /// Grouped by country with expandable city details.
  groupedByCountry,

  /// Period summary with totals and percentages.
  periodSummary;

  /// Returns a human-readable label.
  String get label {
    switch (this) {
      case StatisticsViewMode.calendar:
        return 'Calendar';
      case StatisticsViewMode.chronological:
        return 'Timeline';
      case StatisticsViewMode.groupedByCountry:
        return 'By Country';
      case StatisticsViewMode.periodSummary:
        return 'Summary';
    }
  }
}
