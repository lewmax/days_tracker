/// Utility class for country flag operations.
///
/// Converts ISO 3166-1 alpha-2 country codes to emoji flags.
class CountryFlagUtils {
  CountryFlagUtils._();

  /// Converts a two-letter country code to its flag emoji.
  ///
  /// Uses Unicode Regional Indicator Symbols to create flag emojis.
  /// For example, "US" becomes 🇺🇸, "PL" becomes 🇵🇱.
  ///
  /// [countryCode] ISO 3166-1 alpha-2 country code (e.g., "US", "PL", "UA").
  /// Returns the corresponding flag emoji or empty string if invalid.
  static String getCountryFlag(String countryCode) {
    if (countryCode.length != 2) {
      return '';
    }

    final code = countryCode.toUpperCase();

    // Unicode offset for Regional Indicator Symbol Letters
    // 'A' = 65, Regional Indicator A = 0x1F1E6
    const int offset = 0x1F1E6 - 65; // = 127397

    final int firstLetter = code.codeUnitAt(0) + offset;
    final int secondLetter = code.codeUnitAt(1) + offset;

    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  /// Validates a country code format.
  ///
  /// [countryCode] The country code to validate.
  /// Returns true if it's a valid 2-letter uppercase code.
  static bool isValidCountryCode(String countryCode) {
    if (countryCode.length != 2) return false;

    final code = countryCode.toUpperCase();
    return code.codeUnits.every((unit) => unit >= 65 && unit <= 90);
  }
}
