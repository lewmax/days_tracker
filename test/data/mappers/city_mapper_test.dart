import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/data/mappers/city_mapper.dart';
import 'package:days_tracker/domain/entities/city.dart';
import 'package:days_tracker/domain/entities/country.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2025, 1, 1);

  group('CityDataMapper', () {
    test('toEntity maps all fields without country', () {
      final data = CityData(
        id: 1,
        countryId: 10,
        cityName: 'Kyiv',
        latitude: 50.45,
        longitude: 30.52,
        totalDays: 5,
        createdAt: now,
        updatedAt: now,
      );
      final entity = data.toEntity();
      expect(entity.id, 1);
      expect(entity.countryId, 10);
      expect(entity.cityName, 'Kyiv');
      expect(entity.latitude, 50.45);
      expect(entity.longitude, 30.52);
      expect(entity.totalDays, 5);
      expect(entity.country, isNull);
    });

    test('toEntity maps with country', () {
      final data = CityData(
        id: 1,
        countryId: 10,
        cityName: 'Warsaw',
        latitude: 52.23,
        longitude: 21.01,
        totalDays: 3,
        createdAt: now,
        updatedAt: now,
      );
      const country = Country(id: 10, countryCode: 'PL', countryName: 'Poland');
      final entity = data.toEntity(country: country);
      expect(entity.country, country);
      expect(entity.country?.countryCode, 'PL');
    });
  });

  group('CityEntityMapper', () {
    test('toData maps entity to CityData', () {
      const city = City(
        id: 1,
        countryId: 10,
        cityName: 'Lviv',
        latitude: 49.84,
        longitude: 24.03,
        totalDays: 2,
      );
      final data = city.toData();
      expect(data.id, 1);
      expect(data.countryId, 10);
      expect(data.cityName, 'Lviv');
      expect(data.latitude, 49.84);
      expect(data.longitude, 24.03);
      expect(data.totalDays, 2);
    });
  });
}
