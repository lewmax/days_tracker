import 'package:days_tracker/domain/entities/city.dart';
import 'package:days_tracker/domain/entities/city_presence.dart';
import 'package:days_tracker/domain/entities/country.dart';
import 'package:days_tracker/domain/entities/country_presence.dart';
import 'package:days_tracker/domain/entities/day_details.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DayDetails', () {
    final testDate = DateTime.utc(2026, 1, 15);

    const testCountry = Country(id: 1, countryCode: 'PL', countryName: 'Poland');

    const testCity = City(
      id: 1,
      countryId: 1,
      cityName: 'Warsaw',
      latitude: 52.2297,
      longitude: 21.0122,
    );

    const testCityPresence = CityPresence(city: testCity, pingCount: 5);

    const testCountryPresence = CountryPresence(country: testCountry, cities: [testCityPresence]);

    test('should create day details with required fields', () {
      final details = DayDetails(date: testDate, countries: [testCountryPresence]);

      expect(details.date, testDate);
      expect(details.countries.length, 1);
    });

    test('empty factory should create day details with no countries', () {
      final empty = DayDetails.empty(testDate);

      expect(empty.date, testDate);
      expect(empty.countries, isEmpty);
    });

    test('hasPresence should return true when countries exist', () {
      final details = DayDetails(date: testDate, countries: [testCountryPresence]);

      expect(details.hasPresence, isTrue);
    });

    test('hasPresence should return false when no countries', () {
      final details = DayDetails(date: testDate, countries: const []);

      expect(details.hasPresence, isFalse);
    });

    test('totalPingCount should calculate sum across all countries and cities', () {
      const city1 = City(
        id: 1,
        countryId: 1,
        cityName: 'Warsaw',
        latitude: 52.2297,
        longitude: 21.0122,
      );

      const city2 = City(
        id: 2,
        countryId: 2,
        cityName: 'Berlin',
        latitude: 52.5200,
        longitude: 13.4050,
      );

      const country1 = Country(id: 1, countryCode: 'PL', countryName: 'Poland');

      const country2 = Country(id: 2, countryCode: 'DE', countryName: 'Germany');

      final details = DayDetails(
        date: testDate,
        countries: [
          const CountryPresence(
            country: country1,
            cities: [CityPresence(city: city1, pingCount: 5)],
          ),
          const CountryPresence(
            country: country2,
            cities: [CityPresence(city: city2, pingCount: 3)],
          ),
        ],
      );

      expect(details.totalPingCount, 8);
    });

    test('totalPingCount should return 0 for empty day', () {
      final details = DayDetails(date: testDate, countries: const []);

      expect(details.totalPingCount, 0);
    });

    test('copyWith should return new instance with updated fields', () {
      final details = DayDetails(date: testDate, countries: [testCountryPresence]);

      final newDate = DateTime.utc(2026, 1, 20);
      final updated = details.copyWith(date: newDate);

      expect(updated.date, newDate);
      expect(updated.countries.length, 1);
    });

    test('two day details with same values should be equal', () {
      final details1 = DayDetails(date: testDate, countries: const []);

      final details2 = DayDetails(date: testDate, countries: const []);

      expect(details1, equals(details2));
    });

    test('toString should return readable format', () {
      final details = DayDetails(date: testDate, countries: [testCountryPresence]);

      final str = details.toString();
      expect(str, contains('2026'));
      expect(str, contains('1'));
    });
  });
}
