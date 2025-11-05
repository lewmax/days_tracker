import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat standardDateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat shortDateFormat = DateFormat('MMM dd');
  static final DateFormat timeFormat = DateFormat('HH:mm');
  static final DateFormat dateTimeFormat = DateFormat('MMM dd, yyyy HH:mm');

  /// Get normalized date (midnight)
  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get date range for last N days
  static DateRange getLastNDays(int days) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days - 1));
    return DateRange(
      start: normalizeDate(startDate),
      end: normalizeDate(endDate),
    );
  }

  /// Format duration in days
  static String formatDaysCount(int days) {
    if (days == 0) return '0 days';
    if (days == 1) return '1 day';
    return '$days days';
  }

  /// Format date range
  static String formatDateRange(DateTime start, DateTime? end) {
    if (end == null) {
      return '${standardDateFormat.format(start)} - Present';
    }
    return '${standardDateFormat.format(start)} - ${standardDateFormat.format(end)}';
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});

  int get daysCount {
    return end.difference(start).inDays + 1;
  }
}
