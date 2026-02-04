import 'package:days_tracker/domain/enums/geocoding_status.dart';
import 'package:equatable/equatable.dart';

/// Domain entity representing a single location ping.
///
/// Location pings are raw GPS readings captured from background tracking.
/// They are later geocoded to determine the city and country.
class LocationPing extends Equatable {
  /// Unique identifier (UUID).
  final String id;

  /// Associated visit ID (null if not yet linked to a visit).
  final String? visitId;

  /// Timestamp when the ping was recorded (UTC).
  final DateTime timestamp;

  /// Raw GPS latitude.
  final double latitude;

  /// Raw GPS longitude.
  final double longitude;

  /// GPS accuracy in meters (if available).
  final double? accuracy;

  /// City name from geocoding (null if pending).
  final String? cityName;

  /// Country code from geocoding (null if pending).
  final String? countryCode;

  /// Status of the geocoding operation.
  final GeocodingStatus geocodingStatus;

  /// Number of failed geocoding retry attempts.
  final int retryCount;

  const LocationPing({
    required this.id,
    this.visitId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.cityName,
    this.countryCode,
    required this.geocodingStatus,
    this.retryCount = 0,
  });

  /// Creates a copy of this ping with the given fields replaced.
  LocationPing copyWith({
    String? id,
    String? visitId,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    double? accuracy,
    String? cityName,
    String? countryCode,
    GeocodingStatus? geocodingStatus,
    int? retryCount,
    bool clearVisitId = false,
    bool clearAccuracy = false,
    bool clearCityName = false,
    bool clearCountryCode = false,
  }) {
    return LocationPing(
      id: id ?? this.id,
      visitId: clearVisitId ? null : (visitId ?? this.visitId),
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: clearAccuracy ? null : (accuracy ?? this.accuracy),
      cityName: clearCityName ? null : (cityName ?? this.cityName),
      countryCode: clearCountryCode ? null : (countryCode ?? this.countryCode),
      geocodingStatus: geocodingStatus ?? this.geocodingStatus,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  /// Whether geocoding was successful.
  bool get isGeocoded => geocodingStatus == GeocodingStatus.success;

  /// Whether this ping is pending geocoding.
  bool get isPending => geocodingStatus == GeocodingStatus.pending;

  /// Whether geocoding has failed.
  bool get isFailed => geocodingStatus == GeocodingStatus.failed;

  @override
  List<Object?> get props => [
    id,
    visitId,
    timestamp,
    latitude,
    longitude,
    accuracy,
    cityName,
    countryCode,
    geocodingStatus,
    retryCount,
  ];

  @override
  String toString() {
    return 'LocationPing(id: $id, lat: $latitude, lon: $longitude, status: $geocodingStatus)';
  }
}
