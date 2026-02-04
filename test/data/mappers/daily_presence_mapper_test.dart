import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/data/mappers/daily_presence_mapper.dart';
import 'package:days_tracker/domain/entities/city.dart';
import 'package:days_tracker/domain/entities/country.dart';
import 'package:days_tracker/domain/entities/daily_presence.dart' as domain;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2025, 1, 15);
  const dateStr = '2025-01-15';
  const country = Country(id: 1, countryCode: 'UA', countryName: 'Ukraine');
  const city = City(
    id: 1,
    countryId: 1,
    cityName: 'Kyiv',
    latitude: 50.45,
    longitude: 30.52,
    totalDays: 5,
  );

  group('DailyPresenceDataMapper', () {
    test('toEntity maps all fields', () {
      final data = DailyPresenceData(
        id: 1,
        visitId: 'v1',
        date: dateStr,
        cityId: 1,
        countryId: 1,
        pingCount: 2,
        meetsAnyPresenceRule: true,
        meetsTwoOrMorePingsRule: true,
        createdAt: now,
        updatedAt: now,
      );
      final entity = data.toEntity();
      expect(entity.id, 1);
      expect(entity.visitId, 'v1');
      expect(entity.date, dateStr);
      expect(entity.cityId, 1);
      expect(entity.countryId, 1);
      expect(entity.pingCount, 2);
      expect(entity.meetsAnyPresenceRule, true);
      expect(entity.meetsTwoOrMorePingsRule, true);
      expect(entity.city, isNull);
      expect(entity.country, isNull);
    });

    test('toEntity with city and country', () {
      final data = DailyPresenceData(
        id: 1,
        visitId: 'v1',
        date: dateStr,
        cityId: 1,
        countryId: 1,
        pingCount: 1,
        meetsAnyPresenceRule: true,
        meetsTwoOrMorePingsRule: false,
        createdAt: now,
        updatedAt: now,
      );
      final entity = data.toEntity(city: city, country: country);
      expect(entity.city, city);
      expect(entity.country, country);
    });
  });

  group('DailyPresenceEntityMapper', () {
    test('toData and toCompanion map entity', () {
      const presence = domain.DailyPresence(
        id: 1,
        visitId: 'v1',
        date: dateStr,
        cityId: 1,
        countryId: 1,
        pingCount: 3,
        meetsAnyPresenceRule: true,
        meetsTwoOrMorePingsRule: true,
      );
      final data = presence.toData();
      expect(data.id, 1);
      expect(data.pingCount, 3);
      final companion = presence.toCompanion();
      expect(companion.visitId.value, 'v1');
      expect(companion.pingCount.value, 3);
    });
  });
}
