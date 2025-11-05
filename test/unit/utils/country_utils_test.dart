import 'package:days_tracker/core/utils/country_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CountryUtils', () {
    test('getCountryName should return correct name for valid code', () {
      expect(CountryUtils.getCountryName('US'), 'United States');
      expect(CountryUtils.getCountryName('CA'), 'Canada');
      expect(CountryUtils.getCountryName('GB'), 'United Kingdom');
      expect(CountryUtils.getCountryName('DE'), 'Germany');
    });

    test('getCountryName should handle lowercase codes', () {
      expect(CountryUtils.getCountryName('us'), 'United States');
      expect(CountryUtils.getCountryName('ca'), 'Canada');
    });

    test('getCountryName should return code for unknown country', () {
      expect(CountryUtils.getCountryName('XX'), 'XX');
      expect(CountryUtils.getCountryName('ZZZ'), 'ZZZ');
    });

    test('getAllCountryCodes should return list of codes', () {
      final codes = CountryUtils.getAllCountryCodes();

      expect(codes, isNotEmpty);
      expect(codes, contains('US'));
      expect(codes, contains('CA'));
      expect(codes, contains('GB'));
    });

    test('getAllCountryCodes should return sorted list', () {
      final codes = CountryUtils.getAllCountryCodes();
      final sortedCodes = List<String>.from(codes)..sort();

      expect(codes, equals(sortedCodes));
    });

    test('getAllCountries should return list of entries', () {
      final countries = CountryUtils.getAllCountries();

      expect(countries, isNotEmpty);
      expect(countries.first.key, isA<String>());
      expect(countries.first.value, isA<String>());
    });

    test('getAllCountries should be sorted by name', () {
      final countries = CountryUtils.getAllCountries();

      for (int i = 0; i < countries.length - 1; i++) {
        expect(
          countries[i].value.compareTo(countries[i + 1].value),
          lessThanOrEqualTo(0),
        );
      }
    });
  });
}
