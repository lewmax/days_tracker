import 'package:days_tracker/domain/entities/city_stats.dart';
import 'package:days_tracker/domain/entities/country.dart';
import 'package:equatable/equatable.dart';

/// Domain entity representing statistics for a specific country.
class CountryStats extends Equatable {
  /// The country this statistics is for.
  final Country country;

  /// Number of days spent in this country.
  final int days;

  /// Percentage of total days spent in this country.
  final double percentage;

  /// Statistics for cities within this country.
  final List<CityStats> cities;

  const CountryStats({
    required this.country,
    required this.days,
    required this.percentage,
    this.cities = const [],
  });

  /// Creates a copy of this country stats with the given fields replaced.
  CountryStats copyWith({
    Country? country,
    int? days,
    double? percentage,
    List<CityStats>? cities,
  }) {
    return CountryStats(
      country: country ?? this.country,
      days: days ?? this.days,
      percentage: percentage ?? this.percentage,
      cities: cities ?? this.cities,
    );
  }

  @override
  List<Object?> get props => [country, days, percentage, cities];

  @override
  String toString() {
    return 'CountryStats(country: ${country.countryName}, days: $days, %: ${percentage.toStringAsFixed(1)})';
  }
}
