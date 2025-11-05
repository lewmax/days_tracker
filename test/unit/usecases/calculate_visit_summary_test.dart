import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:days_tracker/domain/usecases/calculate_visit_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'calculate_visit_summary_test.mocks.dart';

@GenerateMocks([VisitsRepository])
void main() {
  late CalculateVisitSummary useCase;
  late MockVisitsRepository mockRepository;

  setUp(() {
    mockRepository = MockVisitsRepository();
    useCase = CalculateVisitSummary(mockRepository);
  });

  group('CalculateVisitSummary', () {
    test('should calculate correct day count for single visit', () async {
      // Arrange
      final startDate = DateTime(2024);
      final endDate = DateTime(2024, 1, 10);

      final visit = Visit(
        id: '1',
        countryCode: 'US',
        countryName: 'United States',
        city: 'New York',
        startDate: DateTime(2024, 1, 5),
        endDate: DateTime(2024, 1, 7),
        latitude: 40.7128,
        longitude: -74.0060,
        overnightOnly: false,
        isActive: false,
        lastUpdated: DateTime.now(),
      );

      when(mockRepository.getVisitsInRange(any, any))
          .thenAnswer((_) async => [visit]);

      // Act
      final result = await useCase.execute(
        startDate: startDate,
        endDate: endDate,
        rule: DayCountingRule.anyPresence,
      );

      // Assert
      expect(result.length, 1);
      expect(result[0].countryCode, 'US');
      expect(result[0].totalDays, 3); // Jan 5, 6, 7
    });

    test('should group visits by country and city', () async {
      // Arrange
      final startDate = DateTime(2024);
      final endDate = DateTime(2024, 1, 31);

      final visits = [
        Visit(
          id: '1',
          countryCode: 'US',
          city: 'New York',
          startDate: DateTime(2024, 1, 5),
          endDate: DateTime(2024, 1, 7),
          latitude: 40.7128,
          longitude: -74.0060,
          overnightOnly: false,
          isActive: false,
          lastUpdated: DateTime.now(),
        ),
        Visit(
          id: '2',
          countryCode: 'US',
          city: 'Los Angeles',
          startDate: DateTime(2024, 1, 10),
          endDate: DateTime(2024, 1, 12),
          latitude: 34.0522,
          longitude: -118.2437,
          overnightOnly: false,
          isActive: false,
          lastUpdated: DateTime.now(),
        ),
        Visit(
          id: '3',
          countryCode: 'CA',
          city: 'Toronto',
          startDate: DateTime(2024, 1, 15),
          endDate: DateTime(2024, 1, 20),
          latitude: 43.6532,
          longitude: -79.3832,
          overnightOnly: false,
          isActive: false,
          lastUpdated: DateTime.now(),
        ),
      ];

      when(mockRepository.getVisitsInRange(any, any))
          .thenAnswer((_) async => visits);

      // Act
      final result = await useCase.execute(
        startDate: startDate,
        endDate: endDate,
        rule: DayCountingRule.anyPresence,
      );

      // Assert
      expect(result.length, 3); // 2 US cities + 1 CA city
    });

    test('should sort summaries by total days descending', () async {
      // Arrange
      final startDate = DateTime(2024);
      final endDate = DateTime(2024, 1, 31);

      final visits = [
        Visit(
          id: '1',
          countryCode: 'US',
          city: 'New York',
          startDate: DateTime(2024, 1, 5),
          endDate: DateTime(2024, 1, 7), // 3 days
          latitude: 40.7128,
          longitude: -74.0060,
          overnightOnly: false,
          isActive: false,
          lastUpdated: DateTime.now(),
        ),
        Visit(
          id: '2',
          countryCode: 'CA',
          city: 'Toronto',
          startDate: DateTime(2024, 1, 10),
          endDate: DateTime(2024, 1, 20), // 11 days
          latitude: 43.6532,
          longitude: -79.3832,
          overnightOnly: false,
          isActive: false,
          lastUpdated: DateTime.now(),
        ),
      ];

      when(mockRepository.getVisitsInRange(any, any))
          .thenAnswer((_) async => visits);

      // Act
      final result = await useCase.execute(
        startDate: startDate,
        endDate: endDate,
        rule: DayCountingRule.anyPresence,
      );

      // Assert
      expect(result[0].countryCode, 'CA'); // 11 days (most)
      expect(result[1].countryCode, 'US'); // 3 days
    });

    test('should filter overnight only visits', () async {
      // Arrange
      final startDate = DateTime(2024);
      final endDate = DateTime(2024, 1, 31);

      final visits = [
        Visit(
          id: '1',
          countryCode: 'US',
          city: 'New York',
          startDate: DateTime(2024, 1, 5),
          endDate: DateTime(2024, 1, 7),
          latitude: 40.7128,
          longitude: -74.0060,
          overnightOnly: true,
          isActive: false,
          lastUpdated: DateTime.now(),
        ),
        Visit(
          id: '2',
          countryCode: 'CA',
          city: 'Toronto',
          startDate: DateTime(2024, 1, 10),
          endDate: DateTime(2024, 1, 12),
          latitude: 43.6532,
          longitude: -79.3832,
          overnightOnly: false,
          isActive: false,
          lastUpdated: DateTime.now(),
        ),
      ];

      when(mockRepository.getVisitsInRange(any, any))
          .thenAnswer((_) async => visits);

      // Act
      final result = await useCase.execute(
        startDate: startDate,
        endDate: endDate,
        rule: DayCountingRule.anyPresence,
        overnightOnly: true,
      );

      // Assert
      expect(result.length, 1);
      expect(result[0].countryCode, 'US');
    });

    test('should handle active visit (no end date)', () async {
      // Arrange
      final startDate = DateTime(2024);
      final endDate = DateTime(2024, 1, 31);

      final visit = Visit(
        id: '1',
        countryCode: 'US',
        city: 'New York',
        startDate: DateTime(2024, 1, 25),
        latitude: 40.7128,
        longitude: -74.0060,
        overnightOnly: false,
        isActive: true,
        lastUpdated: DateTime.now(),
      );

      when(mockRepository.getVisitsInRange(any, any))
          .thenAnswer((_) async => [visit]);

      // Act
      final result = await useCase.execute(
        startDate: startDate,
        endDate: endDate,
        rule: DayCountingRule.anyPresence,
      );

      // Assert
      expect(result.length, 1);
      expect(result[0].totalDays, greaterThan(0));
    });

    test('should return empty list when no visits in range', () async {
      // Arrange
      final startDate = DateTime(2024);
      final endDate = DateTime(2024, 1, 31);

      when(mockRepository.getVisitsInRange(any, any))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase.execute(
        startDate: startDate,
        endDate: endDate,
        rule: DayCountingRule.anyPresence,
      );

      // Assert
      expect(result, isEmpty);
    });
  });
}
