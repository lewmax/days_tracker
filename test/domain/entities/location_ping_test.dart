import 'package:days_tracker/domain/entities/location_ping.dart';
import 'package:days_tracker/domain/enums/geocoding_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocationPing', () {
    final testTimestamp = DateTime.utc(2026, 1, 15, 10, 30);

    test('should create location ping with all required fields', () {
      final ping = LocationPing(
        id: 'ping-123',
        timestamp: testTimestamp,
        latitude: 52.2297,
        longitude: 21.0122,
        geocodingStatus: GeocodingStatus.pending,
      );

      expect(ping.id, 'ping-123');
      expect(ping.timestamp, testTimestamp);
      expect(ping.latitude, 52.2297);
      expect(ping.longitude, 21.0122);
      expect(ping.geocodingStatus, GeocodingStatus.pending);
      expect(ping.visitId, isNull);
      expect(ping.accuracy, isNull);
      expect(ping.cityName, isNull);
      expect(ping.countryCode, isNull);
      expect(ping.retryCount, 0);
    });

    test('should create location ping with all optional fields', () {
      final ping = LocationPing(
        id: 'ping-123',
        visitId: 'visit-456',
        timestamp: testTimestamp,
        latitude: 52.2297,
        longitude: 21.0122,
        accuracy: 15.5,
        cityName: 'Warsaw',
        countryCode: 'PL',
        geocodingStatus: GeocodingStatus.success,
        retryCount: 2,
      );

      expect(ping.visitId, 'visit-456');
      expect(ping.accuracy, 15.5);
      expect(ping.cityName, 'Warsaw');
      expect(ping.countryCode, 'PL');
      expect(ping.retryCount, 2);
    });

    test('isGeocoded should return true when status is success', () {
      final ping = LocationPing(
        id: 'ping-123',
        timestamp: testTimestamp,
        latitude: 52.2297,
        longitude: 21.0122,
        geocodingStatus: GeocodingStatus.success,
      );

      expect(ping.isGeocoded, isTrue);
      expect(ping.isPending, isFalse);
      expect(ping.isFailed, isFalse);
    });

    test('isPending should return true when status is pending', () {
      final ping = LocationPing(
        id: 'ping-123',
        timestamp: testTimestamp,
        latitude: 52.2297,
        longitude: 21.0122,
        geocodingStatus: GeocodingStatus.pending,
      );

      expect(ping.isGeocoded, isFalse);
      expect(ping.isPending, isTrue);
      expect(ping.isFailed, isFalse);
    });

    test('isFailed should return true when status is failed', () {
      final ping = LocationPing(
        id: 'ping-123',
        timestamp: testTimestamp,
        latitude: 52.2297,
        longitude: 21.0122,
        geocodingStatus: GeocodingStatus.failed,
      );

      expect(ping.isGeocoded, isFalse);
      expect(ping.isPending, isFalse);
      expect(ping.isFailed, isTrue);
    });

    test('copyWith should return new instance with updated fields', () {
      final ping = LocationPing(
        id: 'ping-123',
        timestamp: testTimestamp,
        latitude: 52.2297,
        longitude: 21.0122,
        geocodingStatus: GeocodingStatus.pending,
      );

      final updated = ping.copyWith(
        cityName: 'Warsaw',
        countryCode: 'PL',
        geocodingStatus: GeocodingStatus.success,
      );

      expect(updated.id, 'ping-123');
      expect(updated.cityName, 'Warsaw');
      expect(updated.countryCode, 'PL');
      expect(updated.geocodingStatus, GeocodingStatus.success);
    });

    test('copyWith with clear flags should set fields to null', () {
      final ping = LocationPing(
        id: 'ping-123',
        visitId: 'visit-456',
        timestamp: testTimestamp,
        latitude: 52.2297,
        longitude: 21.0122,
        accuracy: 15.5,
        cityName: 'Warsaw',
        countryCode: 'PL',
        geocodingStatus: GeocodingStatus.success,
      );

      final updated = ping.copyWith(
        clearVisitId: true,
        clearAccuracy: true,
        clearCityName: true,
        clearCountryCode: true,
      );

      expect(updated.visitId, isNull);
      expect(updated.accuracy, isNull);
      expect(updated.cityName, isNull);
      expect(updated.countryCode, isNull);
    });

    test('two pings with same values should be equal', () {
      final ping1 = LocationPing(
        id: 'ping-123',
        timestamp: testTimestamp,
        latitude: 52.2297,
        longitude: 21.0122,
        geocodingStatus: GeocodingStatus.pending,
      );

      final ping2 = LocationPing(
        id: 'ping-123',
        timestamp: testTimestamp,
        latitude: 52.2297,
        longitude: 21.0122,
        geocodingStatus: GeocodingStatus.pending,
      );

      expect(ping1, equals(ping2));
    });

    test('toString should return readable format', () {
      final ping = LocationPing(
        id: 'ping-123',
        timestamp: testTimestamp,
        latitude: 52.2297,
        longitude: 21.0122,
        geocodingStatus: GeocodingStatus.pending,
      );

      final str = ping.toString();
      expect(str, contains('ping-123'));
      expect(str, contains('52.2297'));
      expect(str, contains('pending'));
    });
  });
}
