import 'package:days_tracker/domain/entities/city.dart';
import 'package:days_tracker/domain/enums/visit_source.dart';
import 'package:equatable/equatable.dart';

/// Domain entity representing a visit to a city.
///
/// A visit represents a continuous stay in a single city. When the user
/// moves to a different city, the current visit is closed and a new one begins.
class Visit extends Equatable {
  /// Unique identifier (UUID).
  final String id;

  /// Foreign key to the city.
  final int cityId;

  /// Start date of the visit (UTC).
  final DateTime startDate;

  /// End date of the visit (UTC), null if visit is ongoing.
  final DateTime? endDate;

  /// Whether this visit is currently active (no end date).
  final bool isActive;

  /// Source of this visit (manual entry or auto-tracked).
  final VisitSource source;

  /// User's actual latitude when the visit was recorded (for auto visits).
  final double? userLatitude;

  /// User's actual longitude when the visit was recorded (for auto visits).
  final double? userLongitude;

  /// Last time this visit was updated (last ping for auto visits).
  final DateTime lastUpdated;

  /// Navigation property to the city (optional).
  final City? city;

  const Visit({
    required this.id,
    required this.cityId,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.source,
    this.userLatitude,
    this.userLongitude,
    required this.lastUpdated,
    this.city,
  });

  /// Creates a copy of this visit with the given fields replaced.
  Visit copyWith({
    String? id,
    int? cityId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    VisitSource? source,
    double? userLatitude,
    double? userLongitude,
    DateTime? lastUpdated,
    City? city,
    bool clearEndDate = false,
    bool clearUserLatitude = false,
    bool clearUserLongitude = false,
    bool clearCity = false,
  }) {
    return Visit(
      id: id ?? this.id,
      cityId: cityId ?? this.cityId,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      isActive: isActive ?? this.isActive,
      source: source ?? this.source,
      userLatitude: clearUserLatitude ? null : (userLatitude ?? this.userLatitude),
      userLongitude: clearUserLongitude ? null : (userLongitude ?? this.userLongitude),
      lastUpdated: lastUpdated ?? this.lastUpdated,
      city: clearCity ? null : (city ?? this.city),
    );
  }

  /// Calculates the number of days for this visit.
  ///
  /// For active visits, calculates days until today.
  int get daysCount {
    final end = endDate ?? DateTime.now().toUtc();
    final startDay = DateTime.utc(startDate.year, startDate.month, startDate.day);
    final endDay = DateTime.utc(end.year, end.month, end.day);
    return endDay.difference(startDay).inDays + 1;
  }

  @override
  List<Object?> get props => [
    id,
    cityId,
    startDate,
    endDate,
    isActive,
    source,
    userLatitude,
    userLongitude,
    lastUpdated,
    city,
  ];

  @override
  String toString() {
    return 'Visit(id: $id, cityId: $cityId, start: $startDate, end: $endDate, active: $isActive)';
  }
}
