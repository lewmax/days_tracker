import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/enums/visit_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Visit', () {
    test('should create a visit with all required fields', () {
      final visit = Visit(
        id: 'test-uuid',
        cityId: 1,
        startDate: DateTime.utc(2025),
        endDate: DateTime.utc(2025, 1, 10),
        isActive: false,
        source: VisitSource.manual,
        lastUpdated: DateTime.utc(2025, 1, 10),
      );

      expect(visit.id, 'test-uuid');
      expect(visit.cityId, 1);
      expect(visit.startDate, DateTime.utc(2025));
      expect(visit.endDate, DateTime.utc(2025, 1, 10));
      expect(visit.isActive, false);
      expect(visit.source, VisitSource.manual);
    });

    test('should create an active visit with null endDate', () {
      final visit = Visit(
        id: 'test-uuid',
        cityId: 1,
        startDate: DateTime.utc(2025),
        isActive: true,
        source: VisitSource.auto,
        lastUpdated: DateTime.utc(2025, 1, 5),
      );

      expect(visit.endDate, isNull);
      expect(visit.isActive, true);
    });

    test('daysCount should calculate correct days for completed visit', () {
      final visit = Visit(
        id: 'test-uuid',
        cityId: 1,
        startDate: DateTime.utc(2025),
        endDate: DateTime.utc(2025, 1, 10),
        isActive: false,
        source: VisitSource.manual,
        lastUpdated: DateTime.utc(2025, 1, 10),
      );

      expect(visit.daysCount, 10); // Jan 1-10 inclusive
    });

    test('daysCount should calculate days from start to today for active visit', () {
      final today = DateTime.now().toUtc();
      final startDate = DateTime.utc(today.year, today.month, today.day - 5);

      final visit = Visit(
        id: 'test-uuid',
        cityId: 1,
        startDate: startDate,
        isActive: true,
        source: VisitSource.auto,
        lastUpdated: today,
      );

      expect(visit.daysCount, 6); // 5 days ago to today = 6 days
    });

    test('copyWith should return new instance with updated fields', () {
      final original = Visit(
        id: 'test-uuid',
        cityId: 1,
        startDate: DateTime.utc(2025),
        isActive: true,
        source: VisitSource.auto,
        lastUpdated: DateTime.utc(2025, 1, 5),
      );

      final updated = original.copyWith(endDate: DateTime.utc(2025, 1, 10), isActive: false);

      expect(updated.id, 'test-uuid');
      expect(updated.endDate, DateTime.utc(2025, 1, 10));
      expect(updated.isActive, false);
      expect(original.isActive, true); // Original unchanged
    });

    test('copyWith with clearEndDate should set endDate to null', () {
      final original = Visit(
        id: 'test-uuid',
        cityId: 1,
        startDate: DateTime.utc(2025),
        endDate: DateTime.utc(2025, 1, 10),
        isActive: false,
        source: VisitSource.manual,
        lastUpdated: DateTime.utc(2025, 1, 10),
      );

      final updated = original.copyWith(clearEndDate: true, isActive: true);

      expect(updated.endDate, isNull);
      expect(updated.isActive, true);
    });

    test('two visits with same values should be equal', () {
      final date = DateTime.utc(2025);

      final visit1 = Visit(
        id: 'test-uuid',
        cityId: 1,
        startDate: date,
        isActive: true,
        source: VisitSource.manual,
        lastUpdated: date,
      );

      final visit2 = Visit(
        id: 'test-uuid',
        cityId: 1,
        startDate: date,
        isActive: true,
        source: VisitSource.manual,
        lastUpdated: date,
      );

      expect(visit1, equals(visit2));
    });
  });
}
