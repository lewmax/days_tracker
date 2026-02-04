import 'package:days_tracker/core/utils/country_flag_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CountryFlagUtils', () {
    group('getCountryFlag', () {
      test('should convert PL to Polish flag emoji', () {
        final result = CountryFlagUtils.getCountryFlag('PL');
        expect(result, '🇵🇱');
      });

      test('should convert UA to Ukrainian flag emoji', () {
        final result = CountryFlagUtils.getCountryFlag('UA');
        expect(result, '🇺🇦');
      });

      test('should convert US to US flag emoji', () {
        final result = CountryFlagUtils.getCountryFlag('US');
        expect(result, '🇺🇸');
      });

      test('should convert DE to German flag emoji', () {
        final result = CountryFlagUtils.getCountryFlag('DE');
        expect(result, '🇩🇪');
      });

      test('should handle lowercase input', () {
        final result = CountryFlagUtils.getCountryFlag('gb');
        expect(result, '🇬🇧');
      });

      test('should return empty string for invalid input', () {
        expect(CountryFlagUtils.getCountryFlag(''), '');
        expect(CountryFlagUtils.getCountryFlag('P'), '');
        expect(CountryFlagUtils.getCountryFlag('POL'), '');
      });
    });

    group('isValidCountryCode', () {
      test('should return true for valid country codes', () {
        expect(CountryFlagUtils.isValidCountryCode('PL'), true);
        expect(CountryFlagUtils.isValidCountryCode('UA'), true);
        expect(CountryFlagUtils.isValidCountryCode('US'), true);
        expect(CountryFlagUtils.isValidCountryCode('pl'), true); // lowercase ok
      });

      test('should return false for invalid country codes', () {
        expect(CountryFlagUtils.isValidCountryCode(''), false);
        expect(CountryFlagUtils.isValidCountryCode('P'), false);
        expect(CountryFlagUtils.isValidCountryCode('POL'), false);
        expect(CountryFlagUtils.isValidCountryCode('12'), false);
        expect(CountryFlagUtils.isValidCountryCode('P1'), false);
      });
    });
  });
}
