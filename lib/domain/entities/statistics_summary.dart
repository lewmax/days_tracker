import 'package:days_tracker/domain/entities/country_stats.dart';
import 'package:equatable/equatable.dart';

/// Domain entity representing a summary of statistics for a time period.
///
/// Contains aggregated data about countries visited, total days, etc.
class StatisticsSummary extends Equatable {
  /// Statistics for each country visited.
  final List<CountryStats> countries;

  /// Total unique days with presence recorded.
  final int totalDays;

  /// Total number of unique countries visited.
  final int totalCountries;

  /// Total number of unique cities visited.
  final int totalCities;

  /// Start of the statistics period.
  final DateTime periodStart;

  /// End of the statistics period.
  final DateTime periodEnd;

  const StatisticsSummary({
    required this.countries,
    required this.totalDays,
    required this.totalCountries,
    required this.totalCities,
    required this.periodStart,
    required this.periodEnd,
  });

  /// Creates a copy of this summary with the given fields replaced.
  StatisticsSummary copyWith({
    List<CountryStats>? countries,
    int? totalDays,
    int? totalCountries,
    int? totalCities,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) {
    return StatisticsSummary(
      countries: countries ?? this.countries,
      totalDays: totalDays ?? this.totalDays,
      totalCountries: totalCountries ?? this.totalCountries,
      totalCities: totalCities ?? this.totalCities,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
    );
  }

  /// Creates an empty summary for a period with no data.
  factory StatisticsSummary.empty({required DateTime periodStart, required DateTime periodEnd}) {
    return StatisticsSummary(
      countries: const [],
      totalDays: 0,
      totalCountries: 0,
      totalCities: 0,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
  }

  @override
  List<Object?> get props => [
    countries,
    totalDays,
    totalCountries,
    totalCities,
    periodStart,
    periodEnd,
  ];

  @override
  String toString() {
    return 'StatisticsSummary(days: $totalDays, countries: $totalCountries, cities: $totalCities)';
  }
}
