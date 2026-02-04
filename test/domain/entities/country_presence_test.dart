import 'package:days_tracker/domain/entities/city.dart';
import 'package:days_tracker/domain/entities/city_presence.dart';
import 'package:days_tracker/domain/entities/country.dart';
import 'package:days_tracker/domain/entities/country_presence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CountryPresence', () {
    const testCountry = Country(id: 1, countryCode: 'PL', countryName: 'Poland');

    const testCity = City(
      id: 1,
      countryId: 1,
      cityName: 'Warsaw',
      latitude: 52.2297,
      longitude: 21.0122,
    );

    const testCityPresence = CityPresence(city: testCity, pingCount: 5);

    test('should create country presence with required fields', () {
      const presence = CountryPresence(country: testCountry, cities: [testCityPresence]);

      expect(presence.country, testCountry);
      expect(presence.cities.length, 1);
    });

    test('totalPingCount should calculate sum of all city pings', () {
      const city1 = City(
        id: 1,
        countryId: 1,
        cityName: 'Warsaw',
        latitude: 52.2297,
        longitude: 21.0122,
      );

      const city2 = City(
        id: 2,
        countryId: 1,
        cityName: 'Kraków',
        latitude: 50.0647,
        longitude: 19.9450,
      );

      const presence = CountryPresence(
        country: testCountry,
        cities: [
          CityPresence(city: city1, pingCount: 5),
          CityPresence(city: city2, pingCount: 3),
        ],
      );

      expect(presence.totalPingCount, 8);
    });

    test('totalPingCount should return 0 for empty cities', () {
      const presence = CountryPresence(country: testCountry, cities: []);

      expect(presence.totalPingCount, 0);
    });

    test('copyWith should return new instance with updated fields', () {
      const presence = CountryPresence(country: testCountry, cities: [testCityPresence]);

      const newCountry = Country(id: 2, countryCode: 'DE', countryName: 'Germany');

      final updated = presence.copyWith(country: newCountry);

      expect(updated.country.countryCode, 'DE');
      expect(updated.cities.length, 1);
    });

    test('two country presences with same values should be equal', () {
      const presence1 = CountryPresence(country: testCountry, cities: [testCityPresence]);

      const presence2 = CountryPresence(country: testCountry, cities: [testCityPresence]);

      expect(presence1, equals(presence2));
    });

    test('toString should return readable format', () {
      const presence = CountryPresence(country: testCountry, cities: [testCityPresence]);

      final str = presence.toString();
      expect(str, contains('Poland'));
      expect(str, contains('1'));
    });
  });
}
