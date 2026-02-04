import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/country_stats.dart';
import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:days_tracker/domain/repositories/statistics_repository.dart';
import 'package:injectable/injectable.dart';

/// Parameters for calculating country days.
class CalculateCountryDaysParams {
  final DateTime startDate;
  final DateTime endDate;
  final DayCountingRule rule;

  const CalculateCountryDaysParams({
    required this.startDate,
    required this.endDate,
    required this.rule,
  });
}

/// Use case for calculating days spent in each country.
///
/// Applies the specified counting rule:
/// - [DayCountingRule.anyPresence]: Any ping counts as a day
/// - [DayCountingRule.twoOrMorePings]: At least 2 pings required
///
/// Returns stats sorted by days descending.
@lazySingleton
class CalculateCountryDays {
  final StatisticsRepository _repository;

  CalculateCountryDays(this._repository);

  /// Executes the use case.
  ///
  /// [params] The parameters specifying date range and counting rule.
  /// Returns [Either] with [Failure] on error or [List<CountryStats>] on success.
  Future<Either<Failure, List<CountryStats>>> call(CalculateCountryDaysParams params) async {
    // Validate date range
    if (params.startDate.isAfter(params.endDate)) {
      return const Left(ValidationFailure(message: 'Start date must be before end date'));
    }

    return _repository.getCountryStats(
      startDate: params.startDate,
      endDate: params.endDate,
      rule: params.rule,
    );
  }
}
