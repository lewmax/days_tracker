import 'package:days_tracker/domain/enums/time_period.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimePeriod', () {
    test('should have correct labels', () {
      expect(TimePeriod.sevenDays.label, '7 days');
      expect(TimePeriod.thirtyOneDays.label, '31 days');
      expect(TimePeriod.oneHundredEightyThreeDays.label, '183 days');
      expect(TimePeriod.threeHundredSixtyFiveDays.label, '365 days');
      expect(TimePeriod.allTime.label, 'All time');
    });

    test('should have correct days values', () {
      expect(TimePeriod.sevenDays.days, 7);
      expect(TimePeriod.thirtyOneDays.days, 31);
      expect(TimePeriod.oneHundredEightyThreeDays.days, 183);
      expect(TimePeriod.threeHundredSixtyFiveDays.days, 365);
      expect(TimePeriod.allTime.days, isNull);
    });

    group('getDateRange', () {
      test('should return correct range for sevenDays', () {
        final referenceDate = DateTime.utc(2025, 1, 31);
        final range = TimePeriod.sevenDays.getDateRange(referenceDate: referenceDate);

        expect(range.start, DateTime.utc(2025, 1, 25));
        expect(range.end.year, 2025);
        expect(range.end.month, 1);
        expect(range.end.day, 31);
      });

      test('should return correct range for allTime', () {
        final referenceDate = DateTime.utc(2025, 1, 31);
        final range = TimePeriod.allTime.getDateRange(referenceDate: referenceDate);

        expect(range.start.year, 2000);
        expect(range.end.year, 2025);
      });
    });
  });
}
