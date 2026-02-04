import 'package:days_tracker/domain/entities/city.dart';
import 'package:days_tracker/domain/entities/country.dart';
import 'package:days_tracker/domain/entities/daily_presence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DailyPresence', () {
    test('should create daily presence with all required fields', () {
      const presence = DailyPresence(
        id: 1,
        visitId: 'visit-123',
        date: '2026-01-15',
        cityId: 10,
        countryId: 5,
        pingCount: 3,
        meetsAnyPresenceRule: true,
        meetsTwoOrMorePingsRule: true,
      );

      expect(presence.id, 1);
      expect(presence.visitId, 'visit-123');
      expect(presence.date, '2026-01-15');
      expect(presence.cityId, 10);
      expect(presence.countryId, 5);
      expect(presence.pingCount, 3);
      expect(presence.meetsAnyPresenceRule, isTrue);
      expect(presence.meetsTwoOrMorePingsRule, isTrue);
    });

    test('should create daily presence with default values', () {
      const presence = DailyPresence(
        id: 1,
        visitId: 'visit-123',
        date: '2026-01-15',
        cityId: 10,
        countryId: 5,
      );

      expect(presence.pingCount, 1);
      expect(presence.meetsAnyPresenceRule, isTrue);
      expect(presence.meetsTwoOrMorePingsRule, isFalse);
      expect(presence.city, isNull);
      expect(presence.country, isNull);
    });

    test('should create daily presence with navigation properties', () {
      const country = Country(id: 5, countryCode: 'PL', countryName: 'Poland');

      const city = City(
        id: 10,
        countryId: 5,
        cityName: 'Warsaw',
        latitude: 52.2297,
        longitude: 21.0122,
      );

      const presence = DailyPresence(
        id: 1,
        visitId: 'visit-123',
        date: '2026-01-15',
        cityId: 10,
        countryId: 5,
        city: city,
        country: country,
      );

      expect(presence.city, isNotNull);
      expect(presence.country, isNotNull);
      expect(presence.city!.cityName, 'Warsaw');
      expect(presence.country!.countryCode, 'PL');
    });

    test('copyWith should return new instance with updated fields', () {
      const presence = DailyPresence(
        id: 1,
        visitId: 'visit-123',
        date: '2026-01-15',
        cityId: 10,
        countryId: 5,
        pingCount: 1,
      );

      final updated = presence.copyWith(pingCount: 5, meetsTwoOrMorePingsRule: true);

      expect(updated.id, 1);
      expect(updated.pingCount, 5);
      expect(updated.meetsTwoOrMorePingsRule, isTrue);
    });

    test('copyWith with clearCity should set city to null', () {
      const city = City(
        id: 10,
        countryId: 5,
        cityName: 'Warsaw',
        latitude: 52.2297,
        longitude: 21.0122,
      );

      const presence = DailyPresence(
        id: 1,
        visitId: 'visit-123',
        date: '2026-01-15',
        cityId: 10,
        countryId: 5,
        city: city,
      );

      final updated = presence.copyWith(clearCity: true);
      expect(updated.city, isNull);
    });

    test('copyWith with clearCountry should set country to null', () {
      const country = Country(id: 5, countryCode: 'PL', countryName: 'Poland');

      const presence = DailyPresence(
        id: 1,
        visitId: 'visit-123',
        date: '2026-01-15',
        cityId: 10,
        countryId: 5,
        country: country,
      );

      final updated = presence.copyWith(clearCountry: true);
      expect(updated.country, isNull);
    });

    test('two daily presences with same values should be equal', () {
      const presence1 = DailyPresence(
        id: 1,
        visitId: 'visit-123',
        date: '2026-01-15',
        cityId: 10,
        countryId: 5,
      );

      const presence2 = DailyPresence(
        id: 1,
        visitId: 'visit-123',
        date: '2026-01-15',
        cityId: 10,
        countryId: 5,
      );

      expect(presence1, equals(presence2));
    });

    test('toString should return readable format', () {
      const presence = DailyPresence(
        id: 1,
        visitId: 'visit-123',
        date: '2026-01-15',
        cityId: 10,
        countryId: 5,
        pingCount: 3,
      );

      final str = presence.toString();
      expect(str, contains('2026-01-15'));
      expect(str, contains('3'));
    });
  });
}
