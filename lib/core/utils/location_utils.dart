import 'dart:math';

/// Utility class for geographic calculations.
///
/// All distance calculations use the Haversine formula for accuracy
/// on a spherical Earth model.
class LocationUtils {
  LocationUtils._();

  /// Earth's radius in kilometers.
  static const double _earthRadiusKm = 6371.0;

  /// Calculates the distance between two geographic coordinates using the Haversine formula.
  ///
  /// [lat1] Latitude of point 1 in degrees.
  /// [lon1] Longitude of point 1 in degrees.
  /// [lat2] Latitude of point 2 in degrees.
  /// [lon2] Longitude of point 2 in degrees.
  /// Returns distance in kilometers.
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * asin(sqrt(a));

    return _earthRadiusKm * c;
  }

  /// Checks if a point is within a certain radius of another point.
  ///
  /// [lat1] Latitude of point 1 in degrees.
  /// [lon1] Longitude of point 1 in degrees.
  /// [lat2] Latitude of point 2 in degrees.
  /// [lon2] Longitude of point 2 in degrees.
  /// [radiusKm] Radius in kilometers.
  /// Returns true if the distance between points is less than or equal to radius.
  static bool isWithinRadius(double lat1, double lon1, double lat2, double lon2, double radiusKm) {
    return calculateDistance(lat1, lon1, lat2, lon2) <= radiusKm;
  }

  /// Converts degrees to radians.
  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Validates latitude value.
  ///
  /// [latitude] The latitude to validate.
  /// Returns true if latitude is between -90 and 90.
  static bool isValidLatitude(double latitude) {
    return latitude >= -90 && latitude <= 90;
  }

  /// Validates longitude value.
  ///
  /// [longitude] The longitude to validate.
  /// Returns true if longitude is between -180 and 180.
  static bool isValidLongitude(double longitude) {
    return longitude >= -180 && longitude <= 180;
  }

  /// Validates both latitude and longitude.
  static bool isValidCoordinates(double latitude, double longitude) {
    return isValidLatitude(latitude) && isValidLongitude(longitude);
  }
}
