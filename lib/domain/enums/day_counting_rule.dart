/// Enum representing the rule for counting days in a country/city.
///
/// Different tax and visa regulations have different definitions of
/// what counts as a "day" present in a location.
enum DayCountingRule {
  /// Any presence during a day counts as a full day.
  ///
  /// If there's at least one location ping in a country on a given day,
  /// that entire day is counted as spent in that country.
  anyPresence,

  /// Two or more pings during a day are required to count.
  ///
  /// This provides higher confidence that the user actually spent
  /// significant time in the location, not just passing through.
  twoOrMorePings;

  /// Returns a human-readable description of the rule.
  String get description {
    switch (this) {
      case DayCountingRule.anyPresence:
        return 'Any Presence';
      case DayCountingRule.twoOrMorePings:
        return '2+ Pings';
    }
  }

  /// Returns a detailed explanation of the rule.
  String get explanation {
    switch (this) {
      case DayCountingRule.anyPresence:
        return 'Any location ping in a day counts as a full day';
      case DayCountingRule.twoOrMorePings:
        return 'At least 2 pings required to count as a day';
    }
  }
}
