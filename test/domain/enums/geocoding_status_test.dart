import 'package:days_tracker/domain/enums/geocoding_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeocodingStatus', () {
    test('should have correct labels', () {
      expect(GeocodingStatus.success.label, 'Success');
      expect(GeocodingStatus.pending.label, 'Pending');
      expect(GeocodingStatus.failed.label, 'Failed');
    });

    test('fromString should parse success', () {
      expect(GeocodingStatus.fromString('success'), GeocodingStatus.success);
      expect(GeocodingStatus.fromString('SUCCESS'), GeocodingStatus.success);
    });

    test('fromString should parse pending', () {
      expect(GeocodingStatus.fromString('pending'), GeocodingStatus.pending);
      expect(GeocodingStatus.fromString('PENDING'), GeocodingStatus.pending);
    });

    test('fromString should parse failed', () {
      expect(GeocodingStatus.fromString('failed'), GeocodingStatus.failed);
      expect(GeocodingStatus.fromString('FAILED'), GeocodingStatus.failed);
    });

    test('fromString should return pending for unknown values', () {
      expect(GeocodingStatus.fromString('unknown'), GeocodingStatus.pending);
      expect(GeocodingStatus.fromString(''), GeocodingStatus.pending);
    });

    test('should have correct number of values', () {
      expect(GeocodingStatus.values.length, 3);
    });
  });
}
