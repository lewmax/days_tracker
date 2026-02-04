import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/constants/app_constants.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/data/services/city_search_service.dart';
import 'package:days_tracker/domain/entities/city.dart';
import 'package:injectable/injectable.dart';

/// Parameters for city search.
class SearchCitiesParams {
  final String query;
  final int limit;

  const SearchCitiesParams({required this.query, this.limit = AppConstants.cityAutocompleteLimit});
}

/// Use case for searching cities (autocomplete).
///
/// Searches local database first (cities user has visited),
/// then falls back to Google Places API for new cities.
@lazySingleton
class SearchCities {
  final CitySearchService _searchService;

  SearchCities(this._searchService);

  /// Executes the use case.
  ///
  /// [params] The search parameters.
  /// Returns [Either] with [Failure] on error or [List<City>] on success.
  Future<Either<Failure, List<City>>> call(SearchCitiesParams params) async {
    if (params.query.trim().isEmpty) {
      return const Right([]);
    }

    return _searchService.searchCities(query: params.query, limit: params.limit);
  }
}
