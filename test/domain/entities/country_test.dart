import 'package:days_tracker/domain/entities/country.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Country', () {
    test('should create a country with all required fields', () {
      final country = Country(
        id: 1,
        countryCode: 'PL',
        countryName: 'Poland',
        totalDays: 10,
        firstVisitDate: DateTime.utc(2025),
        lastVisitDate: DateTime.utc(2025, 12, 31),
      );

      expect(country.id, 1);
      expect(country.countryCode, 'PL');
      expect(country.countryName, 'Poland');
      expect(country.totalDays, 10);
      expect(country.firstVisitDate, DateTime.utc(2025));
      expect(country.lastVisitDate, DateTime.utc(2025, 12, 31));
    });

    test('should create a country with default values', () {
      const country = Country(id: 1, countryCode: 'UA', countryName: 'Ukraine');

      expect(country.totalDays, 0);
      expect(country.firstVisitDate, isNull);
      expect(country.lastVisitDate, isNull);
    });

    test('copyWith should return new instance with updated fields', () {
      const original = Country(id: 1, countryCode: 'PL', countryName: 'Poland', totalDays: 10);

      final updated = original.copyWith(totalDays: 20);

      expect(updated.id, 1);
      expect(updated.countryCode, 'PL');
      expect(updated.countryName, 'Poland');
      expect(updated.totalDays, 20);
      expect(original.totalDays, 10); // Original unchanged
    });

    test('copyWith with clearFirstVisitDate should set to null', () {
      final original = Country(
        id: 1,
        countryCode: 'PL',
        countryName: 'Poland',
        firstVisitDate: DateTime.utc(2025),
      );

      final updated = original.copyWith(clearFirstVisitDate: true);

      expect(updated.firstVisitDate, isNull);
    });

    test('two countries with same values should be equal', () {
      const country1 = Country(id: 1, countryCode: 'PL', countryName: 'Poland', totalDays: 10);

      const country2 = Country(id: 1, countryCode: 'PL', countryName: 'Poland', totalDays: 10);

      expect(country1, equals(country2));
      expect(country1.hashCode, equals(country2.hashCode));
    });

    test('two countries with different values should not be equal', () {
      const country1 = Country(id: 1, countryCode: 'PL', countryName: 'Poland');

      const country2 = Country(id: 2, countryCode: 'UA', countryName: 'Ukraine');

      expect(country1, isNot(equals(country2)));
    });

    test('toString should return readable format', () {
      const country = Country(id: 1, countryCode: 'PL', countryName: 'Poland', totalDays: 10);

      expect(country.toString(), 'Country(id: 1, code: PL, name: Poland, days: 10)');
    });
  });
}
