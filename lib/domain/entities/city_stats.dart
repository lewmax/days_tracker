import 'package:days_tracker/domain/entities/city.dart';
import 'package:equatable/equatable.dart';

/// Domain entity representing statistics for a specific city.
class CityStats extends Equatable {
  /// The city this statistics is for.
  final City city;

  /// Number of days spent in this city.
  final int days;

  /// Percentage of total days (or country days) spent in this city.
  final double percentage;

  const CityStats({required this.city, required this.days, required this.percentage});

  /// Creates a copy of this city stats with the given fields replaced.
  CityStats copyWith({City? city, int? days, double? percentage}) {
    return CityStats(
      city: city ?? this.city,
      days: days ?? this.days,
      percentage: percentage ?? this.percentage,
    );
  }

  @override
  List<Object?> get props => [city, days, percentage];

  @override
  String toString() {
    return 'CityStats(city: ${city.cityName}, days: $days, %: ${percentage.toStringAsFixed(1)})';
  }
}
