import 'package:days_tracker/core/utils/country_flag_utils.dart';
import 'package:flutter/material.dart';

/// Widget that displays a country flag emoji from a country code.
class CountryFlagWidget extends StatelessWidget {
  /// The ISO 3166-1 alpha-2 country code (e.g., "PL", "US").
  final String countryCode;

  /// The font size of the flag emoji.
  final double fontSize;

  const CountryFlagWidget({super.key, required this.countryCode, this.fontSize = 24});

  @override
  Widget build(BuildContext context) {
    return Text(CountryFlagUtils.getCountryFlag(countryCode), style: TextStyle(fontSize: fontSize));
  }
}
