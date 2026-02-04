import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/city_stats.dart';
import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:days_tracker/domain/repositories/statistics_repository.dart';
import 'package:injectable/injectable.dart';

/// Parameters for calculating city days.
class CalculateCityDaysParams {
  final DateTime startDate;
  final DateTime endDate;
  final DayCountingRule rule;
  final int? countryId; // Optional: filter by country

  const CalculateCityDaysParams({
    required this.startDate,
    required this.endDate,
    required this.rule,
    this.countryId,
  });
}

/// Use case for calculating days spent in each city.
///
/// Applies the specified counting rule and optionally filters by country.
/// Returns stats sorted by days descending.
@lazySingleton
class CalculateCityDays {
  final StatisticsRepository _repository;

  CalculateCityDays(this._repository);

  /// Executes the use case.
  ///
  /// [params] The parameters specifying date range, counting rule, and optional country filter.
  /// Returns [Either] with [Failure] on error or [List<CityStats>] on success.
  Future<Either<Failure, List<CityStats>>> call(CalculateCityDaysParams params) async {
    // Validate date range
    if (params.startDate.isAfter(params.endDate)) {
      return const Left(ValidationFailure(message: 'Start date must be before end date'));
    }

    // Get full statistics summary
    final result = await _repository.getStatisticsSummary(
      startDate: params.startDate,
      endDate: params.endDate,
      rule: params.rule,
    );

    return result.fold((failure) => Left(failure), (summary) {
      // Extract all city stats
      final allCityStats = <CityStats>[];

      for (final countryStats in summary.countries) {
        // Filter by country if specified
        if (params.countryId == null || countryStats.country.id == params.countryId) {
          allCityStats.addAll(countryStats.cities);
        }
      }

      // Sort by days descending
      allCityStats.sort((a, b) => b.days.compareTo(a.days));

      return Right(allCityStats);
    });
  }
}
