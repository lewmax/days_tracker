/// Enum representing predefined time periods for filtering statistics.
enum TimePeriod {
  /// Last 7 days.
  sevenDays,

  /// Last 31 days.
  thirtyOneDays,

  /// Last 183 days (half year, common for tax residency rules).
  oneHundredEightyThreeDays,

  /// Last 365 days (full year).
  threeHundredSixtyFiveDays,

  /// All available data.
  allTime;

  /// Returns a human-readable label.
  String get label {
    switch (this) {
      case TimePeriod.sevenDays:
        return '7 days';
      case TimePeriod.thirtyOneDays:
        return '31 days';
      case TimePeriod.oneHundredEightyThreeDays:
        return '183 days';
      case TimePeriod.threeHundredSixtyFiveDays:
        return '365 days';
      case TimePeriod.allTime:
        return 'All time';
    }
  }

  /// Returns the number of days for this period, or null for allTime.
  int? get days {
    switch (this) {
      case TimePeriod.sevenDays:
        return 7;
      case TimePeriod.thirtyOneDays:
        return 31;
      case TimePeriod.oneHundredEightyThreeDays:
        return 183;
      case TimePeriod.threeHundredSixtyFiveDays:
        return 365;
      case TimePeriod.allTime:
        return null;
    }
  }

  /// Returns the date range for this period.
  ///
  /// [referenceDate] The end date (defaults to today).
  /// Returns a record with start and end dates.
  ({DateTime start, DateTime end}) getDateRange({DateTime? referenceDate}) {
    final end = referenceDate ?? DateTime.now().toUtc();
    final endOfDay = DateTime.utc(end.year, end.month, end.day, 23, 59, 59);

    final int? periodDays = days;
    if (periodDays == null) {
      // All time: use a very early start date
      return (start: DateTime.utc(2000), end: endOfDay);
    }

    final startOfPeriod = DateTime.utc(end.year, end.month, end.day - periodDays + 1);

    return (start: startOfPeriod, end: endOfDay);
  }
}
