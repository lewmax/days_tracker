import 'package:days_tracker/domain/entities/city.dart';
import 'package:days_tracker/domain/entities/city_stats.dart';
import 'package:days_tracker/domain/entities/country.dart';
import 'package:days_tracker/domain/entities/country_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CountryStats', () {
    const testCountry = Country(id: 1, countryCode: 'PL', countryName: 'Poland', totalDays: 30);

    const testCity = City(
      id: 1,
      countryId: 1,
      cityName: 'Warsaw',
      latitude: 52.2297,
      longitude: 21.0122,
    );

    const testCityStats = CityStats(city: testCity, days: 20, percentage: 66.7);

    test('should create country stats with all required fields', () {
      const stats = CountryStats(
        country: testCountry,
        days: 30,
        percentage: 50.0,
        cities: [testCityStats],
      );

      expect(stats.country, testCountry);
      expect(stats.days, 30);
      expect(stats.percentage, 50.0);
      expect(stats.cities.length, 1);
    });

    test('should create country stats with default empty cities', () {
      const stats = CountryStats(country: testCountry, days: 30, percentage: 50.0);

      expect(stats.cities, isEmpty);
    });

    test('copyWith should return new instance with updated fields', () {
      const stats = CountryStats(country: testCountry, days: 30, percentage: 50.0);

      final updated = stats.copyWith(days: 45, percentage: 60.0, cities: [testCityStats]);

      expect(updated.days, 45);
      expect(updated.percentage, 60.0);
      expect(updated.cities.length, 1);
    });

    test('two country stats with same values should be equal', () {
      const stats1 = CountryStats(country: testCountry, days: 30, percentage: 50.0);

      const stats2 = CountryStats(country: testCountry, days: 30, percentage: 50.0);

      expect(stats1, equals(stats2));
    });

    test('toString should return readable format', () {
      const stats = CountryStats(country: testCountry, days: 30, percentage: 50.5);

      final str = stats.toString();
      expect(str, contains('Poland'));
      expect(str, contains('30'));
      expect(str, contains('50.5'));
    });
  });
}
