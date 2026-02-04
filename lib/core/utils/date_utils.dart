import 'package:intl/intl.dart';

/// Utility class for date operations.
///
/// All date handling should use UTC internally and convert to local
/// only for display purposes.
class AppDateUtils {
  AppDateUtils._();

  /// Formats a date range as "Jan 15 - Jan 28" or "Active since Jan 15".
  ///
  /// [start] The start date (required).
  /// [end] The end date (null if visit is active).
  /// Returns formatted string representing the date range.
  static String formatDateRange(DateTime start, DateTime? end) {
    final DateFormat formatter = DateFormat('MMM d');

    if (end == null) {
      return 'Active since ${formatter.format(start.toLocal())}';
    }

    final startStr = formatter.format(start.toLocal());
    final endStr = formatter.format(end.toLocal());

    // If same year and different dates, show simple range
    if (start.year == end.year) {
      return '$startStr - $endStr';
    }

    // Different years, include year
    final DateFormat yearFormatter = DateFormat('MMM d, yyyy');
    return '${yearFormatter.format(start.toLocal())} - ${yearFormatter.format(end.toLocal())}';
  }

  /// Formats a date as "YYYY-MM-DD" for database storage.
  ///
  /// [date] The date to format.
  /// Returns ISO date string.
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date.toUtc());
  }

  /// Formats a date for display as "January 24, 2026".
  ///
  /// [date] The date to format.
  /// Returns human-readable date string.
  static String formatDateFull(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date.toLocal());
  }

  /// Formats a date for display as "Jan 24".
  ///
  /// [date] The date to format.
  /// Returns short date string.
  static String formatDateShort(DateTime date) {
    return DateFormat('MMM d').format(date.toLocal());
  }

  /// Calculates the number of calendar days between two dates (inclusive).
  ///
  /// [start] The start date.
  /// [end] The end date.
  /// Returns number of days including both start and end dates.
  static int calculateDays(DateTime start, DateTime end) {
    // Normalize to UTC midnight for accurate day counting
    final startDate = DateTime.utc(start.year, start.month, start.day);
    final endDate = DateTime.utc(end.year, end.month, end.day);

    return endDate.difference(startDate).inDays + 1;
  }

  /// Checks if a date falls within a date range (inclusive).
  ///
  /// [date] The date to check.
  /// [start] The start of the range.
  /// [end] The end of the range.
  /// Returns true if date is within the range.
  static bool isInDateRange(DateTime date, DateTime start, DateTime end) {
    final d = DateTime.utc(date.year, date.month, date.day);
    final s = DateTime.utc(start.year, start.month, start.day);
    final e = DateTime.utc(end.year, end.month, end.day);

    return !d.isBefore(s) && !d.isAfter(e);
  }

  /// Parses a date string in "YYYY-MM-DD" format to DateTime.
  ///
  /// [dateString] The date string to parse.
  /// Returns DateTime in UTC.
  static DateTime parseDate(String dateString) {
    return DateTime.parse(dateString).toUtc();
  }

  /// Gets the start of the day in UTC.
  ///
  /// [date] The date.
  /// Returns DateTime at midnight UTC.
  static DateTime startOfDay(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  /// Gets the end of the day in UTC (23:59:59.999).
  ///
  /// [date] The date.
  /// Returns DateTime at end of day UTC.
  static DateTime endOfDay(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Gets current date at midnight UTC.
  static DateTime today() {
    final now = DateTime.now().toUtc();
    return DateTime.utc(now.year, now.month, now.day);
  }

  /// Generates a list of dates between start and end (inclusive).
  ///
  /// [start] The start date.
  /// [end] The end date.
  /// Returns list of DateTime objects.
  static List<DateTime> getDateRange(DateTime start, DateTime end) {
    final List<DateTime> dates = [];
    var current = startOfDay(start);
    final endDate = startOfDay(end);

    while (!current.isAfter(endDate)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  /// Gets the first day of the month.
  static DateTime firstDayOfMonth(int year, int month) {
    return DateTime.utc(year, month);
  }

  /// Gets the last day of the month.
  static DateTime lastDayOfMonth(int year, int month) {
    return DateTime.utc(year, month + 1, 0);
  }

  /// Gets the number of days in a month.
  static int daysInMonth(int year, int month) {
    return DateTime.utc(year, month + 1, 0).day;
  }
}
