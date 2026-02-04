import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/data/database/daos/cities_dao.dart';
import 'package:days_tracker/data/database/daos/countries_dao.dart';
import 'package:days_tracker/data/datasources/google_maps_api_datasource.dart';
import 'package:days_tracker/data/mappers/city_mapper.dart';
import 'package:days_tracker/data/mappers/country_mapper.dart';
import 'package:days_tracker/domain/entities/city.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

/// Service for geocoding coordinates to cities.
///
/// First checks the local database for nearby cities, then falls back
/// to the Google Maps API for new locations.
@lazySingleton
class GeocodingService {
  final GoogleMapsApiDataSource _apiDataSource;
  final CitiesDao _citiesDao;
  final CountriesDao _countriesDao;
  final Logger _logger = Logger();

  GeocodingService(this._apiDataSource, this._citiesDao, this._countriesDao);

  /// Reverse geocodes coordinates to a City entity.
  ///
  /// First checks if a city exists within 50km radius in the database.
  /// If not, calls Google Maps API and saves the result.
  ///
  /// [latitude] The GPS latitude.
  /// [longitude] The GPS longitude.
  /// Returns the City entity or a Failure.
  Future<Either<Failure, City>> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      _logger.d('[GeocodingService] reverseGeocode lat=$latitude lon=$longitude');
      // Step 1: Check for nearby city in database
      final nearestCity = await _citiesDao.findNearestCity(lat: latitude, lon: longitude);

      if (nearestCity != null) {
        _logger.d('[GeocodingService] Found nearby city in DB: ${nearestCity.cityName}');
        final countryData = await _countriesDao.getById(nearestCity.countryId);
        final country = countryData?.toEntity();
        return Right(nearestCity.toEntity(country: country));
      }

      _logger.d('[GeocodingService] No nearby city in DB, calling Google Maps API');
      // Step 2: Call Google Maps API
      final geocodeResult = await _apiDataSource.reverseGeocode(
        latitude: latitude,
        longitude: longitude,
      );

      return geocodeResult.fold(
        (failure) {
          _logger.w('[GeocodingService] API reverseGeocode failed: ${failure.message}');
          return Left(failure);
        },
        (result) async {
          _logger.i('[GeocodingService] API result: ${result.cityName}, ${result.countryName}');
          // Step 3: Get or create country
          final country = await _countriesDao.getOrCreate(
            countryCode: result.countryCode,
            countryName: result.countryName,
          );

          // Step 4: Get or create city
          final city = await _citiesDao.getOrCreate(
            countryId: country.id,
            cityName: result.cityName,
            latitude: result.latitude,
            longitude: result.longitude,
          );

          return Right(city.toEntity(country: country.toEntity()));
        },
      );
    } catch (e) {
      return Left(GeocodingFailure(message: 'Geocoding failed: $e'));
    }
  }

  /// Geocodes a city name to coordinates (for manual entry validation).
  ///
  /// This is a simplified version that just searches for the city
  /// in the API and returns its coordinates.
  Future<Either<Failure, City>> geocodeCityName({
    required String cityName,
    required String countryCode,
  }) async {
    try {
      // First check local database
      final countries = await _countriesDao.searchByName(countryCode);
      if (countries.isNotEmpty) {
        final localCity = await _citiesDao.findByName(
          countryId: countries.first.id,
          cityName: cityName,
        );
        if (localCity != null) {
          final country = await _countriesDao.getById(localCity.countryId);
          return Right(localCity.toEntity(country: country?.toEntity()));
        }
      }

      // Search Google Places for the city
      final searchResult = await _apiDataSource.searchPlaces(
        query: '$cityName, $countryCode',
        limit: 1,
      );

      return searchResult.fold((failure) => Left(failure), (results) async {
        if (results.isEmpty) {
          return Left(GeocodingFailure(message: 'City not found: $cityName'));
        }

        // For now, return a placeholder - full implementation would
        // call Place Details API to get coordinates
        // This is a simplified version for MVP
        final country = await _countriesDao.getOrCreate(
          countryCode: countryCode.toUpperCase(),
          countryName: countryCode,
        );

        final city = await _citiesDao.getOrCreate(
          countryId: country.id,
          cityName: cityName,
          latitude: 0, // Would need Place Details API
          longitude: 0,
        );

        return Right(city.toEntity(country: country.toEntity()));
      });
    } catch (e) {
      return Left(GeocodingFailure(message: 'Geocoding failed: $e'));
    }
  }
}
