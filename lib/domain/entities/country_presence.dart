import 'package:days_tracker/domain/entities/city_presence.dart';
import 'package:days_tracker/domain/entities/country.dart';
import 'package:equatable/equatable.dart';

/// Domain entity representing presence in a country for a specific day.
///
/// Part of the DayDetails structure for the calendar day modal.
class CountryPresence extends Equatable {
  /// The country with presence.
  final Country country;

  /// Cities visited within this country on the day.
  final List<CityPresence> cities;

  const CountryPresence({required this.country, required this.cities});

  /// Creates a copy of this country presence with the given fields replaced.
  CountryPresence copyWith({Country? country, List<CityPresence>? cities}) {
    return CountryPresence(country: country ?? this.country, cities: cities ?? this.cities);
  }

  /// Total pings in this country for the day.
  int get totalPingCount {
    return cities.fold(0, (sum, city) => sum + city.pingCount);
  }

  @override
  List<Object?> get props => [country, cities];

  @override
  String toString() {
    return 'CountryPresence(country: ${country.countryName}, cities: ${cities.length})';
  }
}
