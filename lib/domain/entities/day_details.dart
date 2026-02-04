import 'package:days_tracker/domain/entities/country_presence.dart';
import 'package:equatable/equatable.dart';

/// Domain entity representing detailed presence information for a single day.
///
/// Used for the calendar day modal to show what countries/cities
/// the user was in on a specific date.
class DayDetails extends Equatable {
  /// The date this details is for.
  final DateTime date;

  /// List of countries with presence on this day.
  final List<CountryPresence> countries;

  const DayDetails({required this.date, required this.countries});

  /// Creates a copy of this day details with the given fields replaced.
  DayDetails copyWith({DateTime? date, List<CountryPresence>? countries}) {
    return DayDetails(date: date ?? this.date, countries: countries ?? this.countries);
  }

  /// Creates empty day details for a date with no presence.
  factory DayDetails.empty(DateTime date) {
    return DayDetails(date: date, countries: const []);
  }

  /// Whether there is any presence recorded for this day.
  bool get hasPresence => countries.isNotEmpty;

  /// Total number of pings across all cities for this day.
  int get totalPingCount {
    return countries.fold(0, (sum, country) {
      return sum + country.cities.fold(0, (citySum, city) => citySum + city.pingCount);
    });
  }

  @override
  List<Object?> get props => [date, countries];

  @override
  String toString() {
    return 'DayDetails(date: $date, countries: ${countries.length})';
  }
}
