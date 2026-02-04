import 'package:days_tracker/domain/entities/city.dart';
import 'package:days_tracker/domain/entities/city_presence.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/enums/visit_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CityPresence', () {
    const testCity = City(
      id: 1,
      countryId: 10,
      cityName: 'Warsaw',
      latitude: 52.2297,
      longitude: 21.0122,
    );

    final testVisit = Visit(
      id: 'visit-123',
      cityId: 1,
      startDate: DateTime.utc(2026, 1, 1),
      endDate: DateTime.utc(2026, 1, 15),
      isActive: false,
      source: VisitSource.manual,
      lastUpdated: DateTime.utc(2026, 1, 15),
    );

    test('should create city presence with required fields', () {
      const presence = CityPresence(city: testCity, pingCount: 5);

      expect(presence.city, testCity);
      expect(presence.pingCount, 5);
      expect(presence.visit, isNull);
    });

    test('should create city presence with visit', () {
      final presence = CityPresence(city: testCity, pingCount: 5, visit: testVisit);

      expect(presence.visit, isNotNull);
      expect(presence.visit!.id, 'visit-123');
    });

    test('copyWith should return new instance with updated fields', () {
      const presence = CityPresence(city: testCity, pingCount: 5);

      final updated = presence.copyWith(pingCount: 10);

      expect(updated.city, testCity);
      expect(updated.pingCount, 10);
    });

    test('copyWith with clearVisit should set visit to null', () {
      final presence = CityPresence(city: testCity, pingCount: 5, visit: testVisit);

      final updated = presence.copyWith(clearVisit: true);

      expect(updated.visit, isNull);
    });

    test('two city presences with same values should be equal', () {
      const presence1 = CityPresence(city: testCity, pingCount: 5);

      const presence2 = CityPresence(city: testCity, pingCount: 5);

      expect(presence1, equals(presence2));
    });

    test('toString should return readable format', () {
      const presence = CityPresence(city: testCity, pingCount: 5);

      final str = presence.toString();
      expect(str, contains('Warsaw'));
      expect(str, contains('5'));
    });
  });
}
