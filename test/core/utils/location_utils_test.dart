import 'package:days_tracker/core/utils/location_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocationUtils', () {
    group('calculateDistance', () {
      test('should return 0 for same coordinates', () {
        const lat = 52.2297;
        const lon = 21.0122;

        final result = LocationUtils.calculateDistance(lat, lon, lat, lon);

        expect(result, closeTo(0, 0.001));
      });

      test('should calculate distance between Warsaw and Kraków (~250km)', () {
        // Warsaw coordinates
        const warsawLat = 52.2297;
        const warsawLon = 21.0122;
        // Kraków coordinates
        const krakowLat = 50.0647;
        const krakowLon = 19.9450;

        final result = LocationUtils.calculateDistance(warsawLat, warsawLon, krakowLat, krakowLon);

        // Distance should be approximately 250-260km
        expect(result, closeTo(250, 20));
      });

      test('should calculate distance between London and Paris (~340km)', () {
        // London coordinates
        const londonLat = 51.5074;
        const londonLon = -0.1278;
        // Paris coordinates
        const parisLat = 48.8566;
        const parisLon = 2.3522;

        final result = LocationUtils.calculateDistance(londonLat, londonLon, parisLat, parisLon);

        // Distance should be approximately 340km (allow larger tolerance)
        expect(result, closeTo(343, 50));
      });
    });

    group('isWithinRadius', () {
      test('should return true for same location', () {
        const lat = 52.2297;
        const lon = 21.0122;

        final result = LocationUtils.isWithinRadius(lat, lon, lat, lon, 50);

        expect(result, true);
      });

      test('should return true for location within radius', () {
        // Warsaw center
        const lat1 = 52.2297;
        const lon1 = 21.0122;
        // Warsaw suburb (about 10km away)
        const lat2 = 52.2897;
        const lon2 = 21.0622;

        final result = LocationUtils.isWithinRadius(lat1, lon1, lat2, lon2, 50);

        expect(result, true);
      });

      test('should return false for location outside radius', () {
        // Warsaw
        const warsawLat = 52.2297;
        const warsawLon = 21.0122;
        // Kraków (about 250km away)
        const krakowLat = 50.0647;
        const krakowLon = 19.9450;

        final result = LocationUtils.isWithinRadius(
          warsawLat,
          warsawLon,
          krakowLat,
          krakowLon,
          50, // 50km radius
        );

        expect(result, false);
      });
    });

    group('isValidLatitude', () {
      test('should return true for valid latitude', () {
        expect(LocationUtils.isValidLatitude(0), true);
        expect(LocationUtils.isValidLatitude(45.5), true);
        expect(LocationUtils.isValidLatitude(-45.5), true);
        expect(LocationUtils.isValidLatitude(90), true);
        expect(LocationUtils.isValidLatitude(-90), true);
      });

      test('should return false for invalid latitude', () {
        expect(LocationUtils.isValidLatitude(91), false);
        expect(LocationUtils.isValidLatitude(-91), false);
        expect(LocationUtils.isValidLatitude(180), false);
      });
    });

    group('isValidLongitude', () {
      test('should return true for valid longitude', () {
        expect(LocationUtils.isValidLongitude(0), true);
        expect(LocationUtils.isValidLongitude(90), true);
        expect(LocationUtils.isValidLongitude(-90), true);
        expect(LocationUtils.isValidLongitude(180), true);
        expect(LocationUtils.isValidLongitude(-180), true);
      });

      test('should return false for invalid longitude', () {
        expect(LocationUtils.isValidLongitude(181), false);
        expect(LocationUtils.isValidLongitude(-181), false);
        expect(LocationUtils.isValidLongitude(200), false);
      });
    });

    group('isValidCoordinates', () {
      test('should return true for valid coordinates', () {
        expect(LocationUtils.isValidCoordinates(52.2297, 21.0122), true);
        expect(LocationUtils.isValidCoordinates(0, 0), true);
        expect(LocationUtils.isValidCoordinates(-90, -180), true);
        expect(LocationUtils.isValidCoordinates(90, 180), true);
      });

      test('should return false for invalid coordinates', () {
        expect(LocationUtils.isValidCoordinates(91, 21.0122), false);
        expect(LocationUtils.isValidCoordinates(52.2297, 181), false);
        expect(LocationUtils.isValidCoordinates(91, 181), false);
      });
    });
  });
}
