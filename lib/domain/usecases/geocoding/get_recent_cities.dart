import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/constants/app_constants.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/data/services/city_search_service.dart';
import 'package:days_tracker/domain/entities/city.dart';
import 'package:injectable/injectable.dart';

/// Use case for getting recently visited cities.
///
/// Returns cities the user has visited recently, useful for
/// quick selection in the add visit form.
@lazySingleton
class GetRecentCities {
  final CitySearchService _searchService;

  GetRecentCities(this._searchService);

  /// Executes the use case.
  ///
  /// [limit] Maximum number of recent cities to return.
  /// Returns [Either] with [Failure] on error or [List<City>] on success.
  Future<Either<Failure, List<City>>> call({int limit = AppConstants.recentCitiesLimit}) async {
    return _searchService.getRecentCities(limit: limit);
  }
}
