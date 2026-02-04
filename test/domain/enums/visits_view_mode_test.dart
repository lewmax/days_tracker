import 'package:days_tracker/domain/enums/visits_view_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VisitsViewMode', () {
    test('should have correct labels', () {
      expect(VisitsViewMode.chronological.label, 'Timeline');
      expect(VisitsViewMode.groupedByCountry.label, 'By Country');
      expect(VisitsViewMode.activeFirst.label, 'Active First');
      expect(VisitsViewMode.monthGrouping.label, 'By Month');
    });

    test('should have correct number of values', () {
      expect(VisitsViewMode.values.length, 4);
    });

    test('chronological should be a valid view mode', () {
      expect(VisitsViewMode.values.contains(VisitsViewMode.chronological), isTrue);
    });

    test('groupedByCountry should be a valid view mode', () {
      expect(VisitsViewMode.values.contains(VisitsViewMode.groupedByCountry), isTrue);
    });

    test('activeFirst should be a valid view mode', () {
      expect(VisitsViewMode.values.contains(VisitsViewMode.activeFirst), isTrue);
    });

    test('monthGrouping should be a valid view mode', () {
      expect(VisitsViewMode.values.contains(VisitsViewMode.monthGrouping), isTrue);
    });
  });
}
