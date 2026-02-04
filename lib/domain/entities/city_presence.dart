import 'package:days_tracker/domain/entities/city.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:equatable/equatable.dart';

/// Domain entity representing presence in a city for a specific day.
///
/// Part of the DayDetails structure for the calendar day modal.
class CityPresence extends Equatable {
  /// The city with presence.
  final City city;

  /// Number of pings in this city on the day.
  final int pingCount;

  /// Associated visit (if any).
  final Visit? visit;

  const CityPresence({required this.city, required this.pingCount, this.visit});

  /// Creates a copy of this city presence with the given fields replaced.
  CityPresence copyWith({City? city, int? pingCount, Visit? visit, bool clearVisit = false}) {
    return CityPresence(
      city: city ?? this.city,
      pingCount: pingCount ?? this.pingCount,
      visit: clearVisit ? null : (visit ?? this.visit),
    );
  }

  @override
  List<Object?> get props => [city, pingCount, visit];

  @override
  String toString() {
    return 'CityPresence(city: ${city.cityName}, pings: $pingCount)';
  }
}
