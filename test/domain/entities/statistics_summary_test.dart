import 'package:days_tracker/domain/entities/country.dart';
import 'package:days_tracker/domain/entities/country_stats.dart';
import 'package:days_tracker/domain/entities/statistics_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatisticsSummary', () {
    final testPeriodStart = DateTime.utc(2026, 1, 1);
    final testPeriodEnd = DateTime.utc(2026, 1, 31);

    const testCountry = Country(id: 1, countryCode: 'PL', countryName: 'Poland');

    const testCountryStats = CountryStats(country: testCountry, days: 15, percentage: 50.0);

    test('should create statistics summary with all fields', () {
      final summary = StatisticsSummary(
        countries: [testCountryStats],
        totalDays: 30,
        totalCountries: 2,
        totalCities: 5,
        periodStart: testPeriodStart,
        periodEnd: testPeriodEnd,
      );

      expect(summary.countries.length, 1);
      expect(summary.totalDays, 30);
      expect(summary.totalCountries, 2);
      expect(summary.totalCities, 5);
      expect(summary.periodStart, testPeriodStart);
      expect(summary.periodEnd, testPeriodEnd);
    });

    test('copyWith should return new instance with updated fields', () {
      final summary = StatisticsSummary(
        countries: [testCountryStats],
        totalDays: 30,
        totalCountries: 2,
        totalCities: 5,
        periodStart: testPeriodStart,
        periodEnd: testPeriodEnd,
      );

      final updated = summary.copyWith(totalDays: 45, totalCountries: 3);

      expect(updated.totalDays, 45);
      expect(updated.totalCountries, 3);
      expect(updated.totalCities, 5);
    });

    test('empty factory should create empty summary', () {
      final empty = StatisticsSummary.empty(periodStart: testPeriodStart, periodEnd: testPeriodEnd);

      expect(empty.countries, isEmpty);
      expect(empty.totalDays, 0);
      expect(empty.totalCountries, 0);
      expect(empty.totalCities, 0);
      expect(empty.periodStart, testPeriodStart);
      expect(empty.periodEnd, testPeriodEnd);
    });

    test('two summaries with same values should be equal', () {
      final summary1 = StatisticsSummary(
        countries: const [],
        totalDays: 30,
        totalCountries: 2,
        totalCities: 5,
        periodStart: testPeriodStart,
        periodEnd: testPeriodEnd,
      );

      final summary2 = StatisticsSummary(
        countries: const [],
        totalDays: 30,
        totalCountries: 2,
        totalCities: 5,
        periodStart: testPeriodStart,
        periodEnd: testPeriodEnd,
      );

      expect(summary1, equals(summary2));
    });

    test('toString should return readable format', () {
      final summary = StatisticsSummary(
        countries: const [],
        totalDays: 30,
        totalCountries: 2,
        totalCities: 5,
        periodStart: testPeriodStart,
        periodEnd: testPeriodEnd,
      );

      final str = summary.toString();
      expect(str, contains('30'));
      expect(str, contains('2'));
      expect(str, contains('5'));
    });
  });
}
