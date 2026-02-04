import 'package:days_tracker/domain/entities/city.dart';
import 'package:days_tracker/domain/entities/country.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('City', () {
    test('should create a city with all required fields', () {
      const city = City(
        id: 1,
        countryId: 10,
        cityName: 'Warsaw',
        latitude: 52.2297,
        longitude: 21.0122,
        totalDays: 5,
      );

      expect(city.id, 1);
      expect(city.countryId, 10);
      expect(city.cityName, 'Warsaw');
      expect(city.latitude, 52.2297);
      expect(city.longitude, 21.0122);
      expect(city.totalDays, 5);
      expect(city.country, isNull);
    });

    test('should create a city with default totalDays', () {
      const city = City(
        id: 1,
        countryId: 10,
        cityName: 'Kyiv',
        latitude: 50.4501,
        longitude: 30.5234,
      );

      expect(city.totalDays, 0);
    });

    test('should create a city with country navigation property', () {
      const country = Country(id: 10, countryCode: 'PL', countryName: 'Poland');

      const city = City(
        id: 1,
        countryId: 10,
        cityName: 'Warsaw',
        latitude: 52.2297,
        longitude: 21.0122,
        country: country,
      );

      expect(city.country, isNotNull);
      expect(city.country!.countryCode, 'PL');
    });

    test('copyWith should return new instance with updated fields', () {
      const city = City(
        id: 1,
        countryId: 10,
        cityName: 'Warsaw',
        latitude: 52.2297,
        longitude: 21.0122,
        totalDays: 5,
      );

      final updated = city.copyWith(cityName: 'Kraków', totalDays: 10);

      expect(updated.id, 1);
      expect(updated.cityName, 'Kraków');
      expect(updated.totalDays, 10);
      expect(updated.latitude, 52.2297);
    });

    test('copyWith with clearCountry should set country to null', () {
      const country = Country(id: 10, countryCode: 'PL', countryName: 'Poland');

      const city = City(
        id: 1,
        countryId: 10,
        cityName: 'Warsaw',
        latitude: 52.2297,
        longitude: 21.0122,
        country: country,
      );

      final updated = city.copyWith(clearCountry: true);

      expect(updated.country, isNull);
    });

    test('two cities with same values should be equal', () {
      const city1 = City(
        id: 1,
        countryId: 10,
        cityName: 'Warsaw',
        latitude: 52.2297,
        longitude: 21.0122,
      );

      const city2 = City(
        id: 1,
        countryId: 10,
        cityName: 'Warsaw',
        latitude: 52.2297,
        longitude: 21.0122,
      );

      expect(city1, equals(city2));
      expect(city1.hashCode, equals(city2.hashCode));
    });

    test('two cities with different values should not be equal', () {
      const city1 = City(
        id: 1,
        countryId: 10,
        cityName: 'Warsaw',
        latitude: 52.2297,
        longitude: 21.0122,
      );

      const city2 = City(
        id: 2,
        countryId: 10,
        cityName: 'Kraków',
        latitude: 50.0647,
        longitude: 19.9450,
      );

      expect(city1, isNot(equals(city2)));
    });

    test('toString should return readable format', () {
      const city = City(
        id: 1,
        countryId: 10,
        cityName: 'Warsaw',
        latitude: 52.2297,
        longitude: 21.0122,
        totalDays: 5,
      );

      expect(city.toString(), contains('Warsaw'));
      expect(city.toString(), contains('id: 1'));
    });
  });
}
