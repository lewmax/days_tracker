import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/constants/app_constants.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/data/database/daos/cities_dao.dart';
import 'package:days_tracker/data/database/daos/countries_dao.dart';
import 'package:days_tracker/data/datasources/google_maps_api_datasource.dart';
import 'package:days_tracker/data/mappers/city_mapper.dart';
import 'package:days_tracker/data/mappers/country_mapper.dart';
import 'package:days_tracker/domain/entities/city.dart';
import 'package:injectable/injectable.dart';

/// Service for searching cities (for autocomplete).
///
/// Combines local database search with Google Places API
/// to provide comprehensive city search functionality.
@lazySingleton
class CitySearchService {
  final CitiesDao _citiesDao;
  final CountriesDao _countriesDao;
  final GoogleMapsApiDataSource _apiDataSource;

  CitySearchService(this._citiesDao, this._countriesDao, this._apiDataSource);

  /// Searches for cities matching the query.
  ///
  /// First searches local database (cities user has visited),
  /// then falls back to Google Places API for new cities.
  ///
  /// [query] The search query (city name).
  /// [limit] Maximum number of results.
  /// Returns list of City entities or Failure.
  Future<Either<Failure, List<City>>> searchCities({
    required String query,
    int limit = AppConstants.cityAutocompleteLimit,
  }) async {
    try {
      if (query.trim().isEmpty) {
        return const Right([]);
      }

      final results = <City>[];

      // Step 1: Search local database first
      final localResults = await _citiesDao.searchByName(query, limit: limit);

      for (final cityData in localResults) {
        final countryData = await _countriesDao.getById(cityData.countryId);
        final country = countryData?.toEntity();
        results.add(cityData.toEntity(country: country));
      }

      // If we have enough local results, return them
      if (results.length >= limit) {
        return Right(results.take(limit).toList());
      }

      // Step 2: Search Google Places API for additional results
      final remainingSlots = limit - results.length;
      final apiResult = await _apiDataSource.searchPlaces(query: query, limit: remainingSlots);

      apiResult.fold(
        (failure) {
          // API failed - just return local results
          // Don't propagate the error since we have some results
        },
        (places) {
          // Add API results that aren't already in local results
          for (final place in places) {
            // Skip if this place is already in local results
            // (simple check based on description containing city name)
            final alreadyExists = results.any(
              (c) => place.description.toLowerCase().contains(c.cityName.toLowerCase()),
            );

            if (!alreadyExists) {
              // Create a placeholder City for API results
              // These will be properly geocoded when selected
              results.add(
                City(
                  id: -1, // Placeholder ID
                  countryId: -1,
                  cityName: _extractCityName(place.description),
                  latitude: 0,
                  longitude: 0,
                ),
              );
            }
          }
        },
      );

      return Right(results.take(limit).toList());
    } catch (e) {
      return Left(DatabaseFailure(message: 'City search failed: $e'));
    }
  }

  /// Gets recently visited cities.
  ///
  /// [limit] Maximum number of results.
  Future<Either<Failure, List<City>>> getRecentCities({
    int limit = AppConstants.recentCitiesLimit,
  }) async {
    try {
      final cityDataList = await _citiesDao.getRecent(limit: limit);
      final cities = <City>[];

      for (final cityData in cityDataList) {
        final countryData = await _countriesDao.getById(cityData.countryId);
        final country = countryData?.toEntity();
        cities.add(cityData.toEntity(country: country));
      }

      return Right(cities);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get recent cities: $e'));
    }
  }

  /// Gets cities for a specific country.
  ///
  /// [countryId] The country ID.
  Future<Either<Failure, List<City>>> getCitiesByCountry(int countryId) async {
    try {
      final cityDataList = await _citiesDao.getCitiesByCountry(countryId);
      final countryData = await _countriesDao.getById(countryId);
      final country = countryData?.toEntity();

      final cities = cityDataList.map((cityData) => cityData.toEntity(country: country)).toList();

      return Right(cities);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get cities by country: $e'));
    }
  }

  /// Extracts city name from Google Places description.
  ///
  /// Description format is usually "City, Country" or "City, State, Country".
  String _extractCityName(String description) {
    final parts = description.split(',');
    return parts.isNotEmpty ? parts.first.trim() : description;
  }
}
