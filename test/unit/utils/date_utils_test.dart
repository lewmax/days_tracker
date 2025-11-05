import 'package:days_tracker/core/utils/date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppDateUtils', () {
    test('normalizeDate should return date at midnight', () {
      // Arrange
      final date = DateTime(2024, 1, 15, 14, 30, 45);

      // Act
      final normalized = AppDateUtils.normalizeDate(date);

      // Assert
      expect(normalized.year, 2024);
      expect(normalized.month, 1);
      expect(normalized.day, 15);
      expect(normalized.hour, 0);
      expect(normalized.minute, 0);
      expect(normalized.second, 0);
    });

    test('isSameDay should return true for same day different times', () {
      // Arrange
      final date1 = DateTime(2024, 1, 15, 8);
      final date2 = DateTime(2024, 1, 15, 20, 30);

      // Act
      final result = AppDateUtils.isSameDay(date1, date2);

      // Assert
      expect(result, true);
    });

    test('isSameDay should return false for different days', () {
      // Arrange
      final date1 = DateTime(2024, 1, 15, 23, 59);
      final date2 = DateTime(2024, 1, 16, 0, 1);

      // Act
      final result = AppDateUtils.isSameDay(date1, date2);

      // Assert
      expect(result, false);
    });

    test('getLastNDays should return correct date range', () {
      // Act
      final range = AppDateUtils.getLastNDays(30);

      // Assert
      expect(range.daysCount, 30);
      expect(AppDateUtils.isSameDay(range.end, DateTime.now()), true);
    });

    test('formatDaysCount should format correctly', () {
      expect(AppDateUtils.formatDaysCount(0), '0 days');
      expect(AppDateUtils.formatDaysCount(1), '1 day');
      expect(AppDateUtils.formatDaysCount(5), '5 days');
      expect(AppDateUtils.formatDaysCount(100), '100 days');
    });

    test('formatDateRange should format with end date', () {
      // Arrange
      final start = DateTime(2024);
      final end = DateTime(2024, 1, 15);

      // Act
      final result = AppDateUtils.formatDateRange(start, end);

      // Assert
      expect(result, contains('Jan 01, 2024'));
      expect(result, contains('Jan 15, 2024'));
    });

    test('formatDateRange should show Present when no end date', () {
      // Arrange
      final start = DateTime(2024);

      // Act
      final result = AppDateUtils.formatDateRange(start, null);

      // Assert
      expect(result, contains('Jan 01, 2024'));
      expect(result, contains('Present'));
    });
  });

  group('DateRange', () {
    test('daysCount should calculate correct number of days', () {
      // Arrange
      final start = DateTime(2024);
      final end = DateTime(2024, 1, 10);
      final range = DateRange(start: start, end: end);

      // Act
      final count = range.daysCount;

      // Assert
      expect(count, 10); // Inclusive of both start and end
    });

    test('daysCount should be 1 for same day', () {
      // Arrange
      final date = DateTime(2024);
      final range = DateRange(start: date, end: date);

      // Act
      final count = range.daysCount;

      // Assert
      expect(count, 1);
    });
  });
}
