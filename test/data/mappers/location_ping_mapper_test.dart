import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/data/mappers/location_ping_mapper.dart';
import 'package:days_tracker/domain/entities/location_ping.dart';
import 'package:days_tracker/domain/enums/geocoding_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2025, 1, 1);

  group('LocationPingDataMapper', () {
    test('toEntity maps all fields', () {
      final data = LocationPingData(
        id: 'ping1',
        visitId: 'v1',
        timestamp: now,
        latitude: 50.45,
        longitude: 30.52,
        accuracy: 10.0,
        cityName: 'Kyiv',
        countryCode: 'UA',
        geocodingStatus: 'success',
        retryCount: 0,
        createdAt: now,
      );
      final entity = data.toEntity();
      expect(entity.id, 'ping1');
      expect(entity.visitId, 'v1');
      expect(entity.latitude, 50.45);
      expect(entity.longitude, 30.52);
      expect(entity.cityName, 'Kyiv');
      expect(entity.countryCode, 'UA');
      expect(entity.geocodingStatus, GeocodingStatus.success);
      expect(entity.retryCount, 0);
    });

    test('toEntity maps optional nulls', () {
      final data = LocationPingData(
        id: 'ping2',
        visitId: null,
        timestamp: now,
        latitude: 0,
        longitude: 0,
        accuracy: null,
        cityName: null,
        countryCode: null,
        geocodingStatus: 'pending',
        retryCount: 1,
        createdAt: now,
      );
      final entity = data.toEntity();
      expect(entity.visitId, isNull);
      expect(entity.geocodingStatus, GeocodingStatus.pending);
    });
  });

  group('LocationPingEntityMapper', () {
    test('toData and toCompanion map entity', () {
      final ping = LocationPing(
        id: 'p1',
        visitId: 'v1',
        timestamp: now,
        latitude: 50.0,
        longitude: 30.0,
        accuracy: null,
        cityName: null,
        countryCode: null,
        geocodingStatus: GeocodingStatus.failed,
        retryCount: 3,
      );
      final data = ping.toData();
      expect(data.id, 'p1');
      expect(data.geocodingStatus, 'failed');
      final companion = ping.toCompanion();
      expect(companion.id.value, 'p1');
    });
  });
}
