import 'package:days_tracker/domain/enums/statistics_view_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatisticsViewMode', () {
    test('should have correct labels', () {
      expect(StatisticsViewMode.calendar.label, 'Calendar');
      expect(StatisticsViewMode.chronological.label, 'Timeline');
      expect(StatisticsViewMode.groupedByCountry.label, 'By Country');
      expect(StatisticsViewMode.periodSummary.label, 'Summary');
    });

    test('should have correct number of values', () {
      expect(StatisticsViewMode.values.length, 4);
    });

    test('calendar should be a valid view mode', () {
      expect(StatisticsViewMode.values.contains(StatisticsViewMode.calendar), isTrue);
    });

    test('chronological should be a valid view mode', () {
      expect(StatisticsViewMode.values.contains(StatisticsViewMode.chronological), isTrue);
    });

    test('groupedByCountry should be a valid view mode', () {
      expect(StatisticsViewMode.values.contains(StatisticsViewMode.groupedByCountry), isTrue);
    });

    test('periodSummary should be a valid view mode', () {
      expect(StatisticsViewMode.values.contains(StatisticsViewMode.periodSummary), isTrue);
    });
  });
}
