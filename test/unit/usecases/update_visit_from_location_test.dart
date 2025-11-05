import 'package:days_tracker/domain/entities/location_ping.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/repositories/visits_repository.dart';
import 'package:days_tracker/domain/usecases/update_visit_from_location.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'update_visit_from_location_test.mocks.dart';

@GenerateMocks([VisitsRepository])
void main() {
  late UpdateVisitFromLocation useCase;
  late MockVisitsRepository mockRepository;

  setUp(() {
    mockRepository = MockVisitsRepository();
    useCase = UpdateVisitFromLocation(mockRepository);
  });

  group('UpdateVisitFromLocation', () {
    test('should create new visit when no active visit exists', () async {
      // Arrange
      final ping = LocationPing(
        id: 'ping1',
        timestamp: DateTime.now(),
        latitude: 40.7128,
        longitude: -74.0060,
        accuracy: 10.0,
        city: 'New York',
        countryCode: 'US',
        source: 'background',
      );

      when(mockRepository.getActiveVisit()).thenAnswer((_) async => null);
      when(mockRepository.addLocationPing(any)).thenAnswer((_) async {});
      when(mockRepository.createVisit(any)).thenAnswer((_) async {});

      // Act
      final result = await useCase.execute(ping);

      // Assert
      expect(result, true); // New visit created
      verify(mockRepository.addLocationPing(ping)).called(1);
      verify(mockRepository.createVisit(any)).called(1);
    });

    test('should update existing visit when location matches', () async {
      // Arrange
      final activeVisit = Visit(
        id: 'visit1',
        countryCode: 'US',
        city: 'New York',
        startDate: DateTime.now().subtract(const Duration(hours: 2)),
        latitude: 40.7128,
        longitude: -74.0060,
        overnightOnly: false,
        isActive: true,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
      );

      final ping = LocationPing(
        id: 'ping1',
        timestamp: DateTime.now(),
        latitude: 40.7130, // Slightly different but same city
        longitude: -74.0062,
        accuracy: 10.0,
        city: 'New York',
        countryCode: 'US',
        source: 'background',
      );

      when(mockRepository.getActiveVisit())
          .thenAnswer((_) async => activeVisit);
      when(mockRepository.addLocationPing(any)).thenAnswer((_) async {});
      when(mockRepository.updateVisit(any)).thenAnswer((_) async {});

      // Act
      final result = await useCase.execute(ping);

      // Assert
      expect(result, false); // Visit updated, not created
      verify(mockRepository.addLocationPing(ping)).called(1);
      verify(mockRepository.updateVisit(any)).called(1);
      verifyNever(mockRepository.createVisit(any));
    });

    test('should close old and create new visit when country changes',
        () async {
      // Arrange
      final activeVisit = Visit(
        id: 'visit1',
        countryCode: 'US',
        city: 'New York',
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        latitude: 40.7128,
        longitude: -74.0060,
        overnightOnly: false,
        isActive: true,
        lastUpdated: DateTime.now(),
      );

      final ping = LocationPing(
        id: 'ping1',
        timestamp: DateTime.now(),
        latitude: 43.6532,
        longitude: -79.3832,
        accuracy: 10.0,
        city: 'Toronto',
        countryCode: 'CA', // Different country
        source: 'background',
      );

      when(mockRepository.getActiveVisit())
          .thenAnswer((_) async => activeVisit);
      when(mockRepository.addLocationPing(any)).thenAnswer((_) async {});
      when(mockRepository.closeActiveVisit(any)).thenAnswer((_) async {});
      when(mockRepository.createVisit(any)).thenAnswer((_) async {});

      // Act
      final result = await useCase.execute(ping);

      // Assert
      expect(result, true); // New visit created
      verify(mockRepository.addLocationPing(ping)).called(1);
      verify(mockRepository.closeActiveVisit(any)).called(1);
      verify(mockRepository.createVisit(any)).called(1);
    });

    test('should close old and create new visit when city changes', () async {
      // Arrange
      final activeVisit = Visit(
        id: 'visit1',
        countryCode: 'US',
        city: 'New York',
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        latitude: 40.7128,
        longitude: -74.0060,
        overnightOnly: false,
        isActive: true,
        lastUpdated: DateTime.now(),
      );

      final ping = LocationPing(
        id: 'ping1',
        timestamp: DateTime.now(),
        latitude: 34.0522,
        longitude: -118.2437,
        accuracy: 10.0,
        city: 'Los Angeles', // Different city, same country
        countryCode: 'US',
        source: 'background',
      );

      when(mockRepository.getActiveVisit())
          .thenAnswer((_) async => activeVisit);
      when(mockRepository.addLocationPing(any)).thenAnswer((_) async {});
      when(mockRepository.closeActiveVisit(any)).thenAnswer((_) async {});
      when(mockRepository.createVisit(any)).thenAnswer((_) async {});

      // Act
      final result = await useCase.execute(ping);

      // Assert
      expect(result, true); // New visit created
      verify(mockRepository.closeActiveVisit(any)).called(1);
      verify(mockRepository.createVisit(any)).called(1);
    });

    test('should not create visit when country code is null', () async {
      // Arrange
      final ping = LocationPing(
        id: 'ping1',
        timestamp: DateTime.now(),
        latitude: 40.7128,
        longitude: -74.0060,
        accuracy: 10.0,
        source: 'background',
        geocodingPending: true,
      );

      when(mockRepository.getActiveVisit()).thenAnswer((_) async => null);
      when(mockRepository.addLocationPing(any)).thenAnswer((_) async {});

      // Act
      final result = await useCase.execute(ping);

      // Assert
      expect(result, false); // No visit created
      verify(mockRepository.addLocationPing(ping)).called(1);
      verifyNever(mockRepository.createVisit(any));
    });

    test('should add ping even when repository operations fail', () async {
      // Arrange
      final ping = LocationPing(
        id: 'ping1',
        timestamp: DateTime.now(),
        latitude: 40.7128,
        longitude: -74.0060,
        accuracy: 10.0,
        city: 'New York',
        countryCode: 'US',
        source: 'background',
      );

      when(mockRepository.getActiveVisit()).thenAnswer((_) async => null);
      when(mockRepository.addLocationPing(any)).thenAnswer((_) async {});
      when(mockRepository.createVisit(any))
          .thenThrow(Exception('Storage error'));

      // Act & Assert
      expect(() => useCase.execute(ping), throwsException);
      verify(mockRepository.addLocationPing(ping)).called(1);
    });
  });
}
