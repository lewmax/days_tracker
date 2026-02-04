import 'package:days_tracker/domain/entities/city.dart';
import 'package:days_tracker/domain/entities/city_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CityStats', () {
    const testCity = City(
      id: 1,
      countryId: 10,
      cityName: 'Warsaw',
      latitude: 52.2297,
      longitude: 21.0122,
      totalDays: 15,
    );

    test('should create city stats with all required fields', () {
      const stats = CityStats(city: testCity, days: 15, percentage: 75.0);

      expect(stats.city, testCity);
      expect(stats.days, 15);
      expect(stats.percentage, 75.0);
    });

    test('copyWith should return new instance with updated fields', () {
      const stats = CityStats(city: testCity, days: 15, percentage: 75.0);

      final updated = stats.copyWith(days: 20, percentage: 80.0);

      expect(updated.city, testCity);
      expect(updated.days, 20);
      expect(updated.percentage, 80.0);
    });

    test('two city stats with same values should be equal', () {
      const stats1 = CityStats(city: testCity, days: 15, percentage: 75.0);

      const stats2 = CityStats(city: testCity, days: 15, percentage: 75.0);

      expect(stats1, equals(stats2));
    });

    test('toString should return readable format', () {
      const stats = CityStats(city: testCity, days: 15, percentage: 75.5);

      final str = stats.toString();
      expect(str, contains('Warsaw'));
      expect(str, contains('15'));
      expect(str, contains('75.5'));
    });
  });
}
