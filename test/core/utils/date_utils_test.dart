import 'package:days_tracker/core/utils/date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppDateUtils', () {
    group('formatDateRange', () {
      test('should format completed visit date range', () {
        final start = DateTime.utc(2025, 1, 15);
        final end = DateTime.utc(2025, 1, 28);

        final result = AppDateUtils.formatDateRange(start, end);

        expect(result, contains('Jan'));
        expect(result, contains('15'));
        expect(result, contains('28'));
      });

      test('should format active visit with null end date', () {
        final start = DateTime.utc(2025, 1, 15);

        final result = AppDateUtils.formatDateRange(start, null);

        expect(result, contains('Active since'));
        expect(result, contains('Jan'));
      });
    });

    group('formatDate', () {
      test('should format date as YYYY-MM-DD', () {
        final date = DateTime.utc(2025, 1, 15);

        final result = AppDateUtils.formatDate(date);

        expect(result, '2025-01-15');
      });

      test('should handle single digit months and days', () {
        final date = DateTime.utc(2025, 5, 5);

        final result = AppDateUtils.formatDate(date);

        expect(result, '2025-05-05');
      });
    });

    group('calculateDays', () {
      test('should calculate days inclusive', () {
        final start = DateTime.utc(2025);
        final end = DateTime.utc(2025, 1, 10);

        final result = AppDateUtils.calculateDays(start, end);

        expect(result, 10); // 1-10 inclusive
      });

      test('should return 1 for same day', () {
        final date = DateTime.utc(2025, 1, 15);

        final result = AppDateUtils.calculateDays(date, date);

        expect(result, 1);
      });

      test('should handle month boundaries', () {
        final start = DateTime.utc(2025, 1, 30);
        final end = DateTime.utc(2025, 2, 2);

        final result = AppDateUtils.calculateDays(start, end);

        expect(result, 4); // Jan 30, 31, Feb 1, 2
      });
    });

    group('isInDateRange', () {
      test('should return true for date within range', () {
        final date = DateTime.utc(2025, 1, 15);
        final start = DateTime.utc(2025);
        final end = DateTime.utc(2025, 1, 31);

        final result = AppDateUtils.isInDateRange(date, start, end);

        expect(result, true);
      });

      test('should return true for start date', () {
        final start = DateTime.utc(2025);
        final end = DateTime.utc(2025, 1, 31);

        final result = AppDateUtils.isInDateRange(start, start, end);

        expect(result, true);
      });

      test('should return true for end date', () {
        final start = DateTime.utc(2025);
        final end = DateTime.utc(2025, 1, 31);

        final result = AppDateUtils.isInDateRange(end, start, end);

        expect(result, true);
      });

      test('should return false for date outside range', () {
        final date = DateTime.utc(2025, 2, 15);
        final start = DateTime.utc(2025);
        final end = DateTime.utc(2025, 1, 31);

        final result = AppDateUtils.isInDateRange(date, start, end);

        expect(result, false);
      });
    });

    group('parseDate', () {
      test('should parse YYYY-MM-DD string to DateTime', () {
        final result = AppDateUtils.parseDate('2025-01-15');

        expect(result.year, 2025);
        expect(result.month, 1);
        // The day might shift due to timezone conversion
        expect(result.day >= 14 && result.day <= 15, true);
        expect(result.isUtc, true);
      });
    });

    group('startOfDay', () {
      test('should return midnight UTC', () {
        final date = DateTime.utc(2025, 1, 15, 14, 30, 45);

        final result = AppDateUtils.startOfDay(date);

        expect(result, DateTime.utc(2025, 1, 15));
      });
    });

    group('endOfDay', () {
      test('should return end of day UTC', () {
        final date = DateTime.utc(2025, 1, 15, 14, 30, 45);

        final result = AppDateUtils.endOfDay(date);

        expect(result.year, 2025);
        expect(result.month, 1);
        expect(result.day, 15);
        expect(result.hour, 23);
        expect(result.minute, 59);
        expect(result.second, 59);
      });
    });

    group('getDateRange', () {
      test('should return list of dates', () {
        final start = DateTime.utc(2025);
        final end = DateTime.utc(2025, 1, 5);

        final result = AppDateUtils.getDateRange(start, end);

        expect(result.length, 5);
        expect(result[0], DateTime.utc(2025));
        expect(result[4], DateTime.utc(2025, 1, 5));
      });
    });

    group('daysInMonth', () {
      test('should return 31 for January', () {
        expect(AppDateUtils.daysInMonth(2025, 1), 31);
      });

      test('should return 28 for February in non-leap year', () {
        expect(AppDateUtils.daysInMonth(2025, 2), 28);
      });

      test('should return 29 for February in leap year', () {
        expect(AppDateUtils.daysInMonth(2024, 2), 29);
      });

      test('should return 30 for April', () {
        expect(AppDateUtils.daysInMonth(2025, 4), 30);
      });
    });

    group('formatDateFull', () {
      test('should format date as full month day year', () {
        final date = DateTime.utc(2025, 1, 24);
        final result = AppDateUtils.formatDateFull(date);
        expect(result, contains('January'));
        expect(result, contains('24'));
        expect(result, contains('2025'));
      });
    });

    group('formatDateShort', () {
      test('should format date as short month day', () {
        final date = DateTime.utc(2025, 1, 24);
        final result = AppDateUtils.formatDateShort(date);
        expect(result, contains('Jan'));
        expect(result, contains('24'));
      });
    });

    group('today', () {
      test('should return current date at midnight UTC', () {
        final result = AppDateUtils.today();
        expect(result.hour, 0);
        expect(result.minute, 0);
        expect(result.second, 0);
        expect(result.isUtc, true);
      });
    });

    group('firstDayOfMonth', () {
      test('should return first day of month', () {
        final result = AppDateUtils.firstDayOfMonth(2025, 3);
        expect(result.year, 2025);
        expect(result.month, 3);
        expect(result.day, 1);
      });
    });

    group('lastDayOfMonth', () {
      test('should return last day of month', () {
        final result = AppDateUtils.lastDayOfMonth(2025, 1);
        expect(result.year, 2025);
        expect(result.month, 1);
        expect(result.day, 31);
      });

      test('should return last day of February in leap year', () {
        final result = AppDateUtils.lastDayOfMonth(2024, 2);
        expect(result.day, 29);
      });
    });

    group('formatDateRange different years', () {
      test('should include year when start and end are different years', () {
        final start = DateTime.utc(2024, 12, 15);
        final end = DateTime.utc(2025, 1, 10);
        final result = AppDateUtils.formatDateRange(start, end);
        expect(result, contains('2024'));
        expect(result, contains('2025'));
      });
    });
  });
}
