import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/domain/entities/location_ping.dart';
import 'package:days_tracker/domain/enums/geocoding_status.dart';
import 'package:drift/drift.dart';

/// Extension to convert LocationPingData (database) to LocationPing (domain entity).
extension LocationPingDataMapper on LocationPingData {
  /// Converts this database model to a domain entity.
  LocationPing toEntity() {
    return LocationPing(
      id: id,
      visitId: visitId,
      timestamp: timestamp,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      cityName: cityName,
      countryCode: countryCode,
      geocodingStatus: GeocodingStatus.fromString(geocodingStatus),
      retryCount: retryCount,
    );
  }
}

/// Extension to convert LocationPing (domain entity) to LocationPingData (database).
extension LocationPingEntityMapper on LocationPing {
  /// Converts this domain entity to a database model.
  LocationPingData toData() {
    final now = DateTime.now().toUtc();
    return LocationPingData(
      id: id,
      visitId: visitId,
      timestamp: timestamp,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      cityName: cityName,
      countryCode: countryCode,
      geocodingStatus: geocodingStatus.name,
      retryCount: retryCount,
      createdAt: now,
    );
  }

  /// Converts this domain entity to a Drift companion for insertion.
  LocationPingsCompanion toCompanion() {
    final now = DateTime.now().toUtc();
    return LocationPingsCompanion(
      id: Value(id),
      visitId: Value(visitId),
      timestamp: Value(timestamp),
      latitude: Value(latitude),
      longitude: Value(longitude),
      accuracy: Value(accuracy),
      cityName: Value(cityName),
      countryCode: Value(countryCode),
      geocodingStatus: Value(geocodingStatus.name),
      retryCount: Value(retryCount),
      createdAt: Value(now),
    );
  }
}
