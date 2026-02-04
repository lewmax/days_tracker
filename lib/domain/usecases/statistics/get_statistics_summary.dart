import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/statistics_summary.dart';
import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:days_tracker/domain/repositories/statistics_repository.dart';
import 'package:injectable/injectable.dart';

/// Parameters for getting statistics summary.
class GetStatisticsSummaryParams {
  final DateTime startDate;
  final DateTime endDate;
  final DayCountingRule rule;

  const GetStatisticsSummaryParams({
    required this.startDate,
    required this.endDate,
    required this.rule,
  });
}

/// Use case for getting a complete statistics summary.
///
/// Returns aggregated statistics including:
/// - Total days tracked
/// - Countries with their day counts
/// - Cities with their day counts
/// - Percentages of time spent in each location
@lazySingleton
class GetStatisticsSummary {
  final StatisticsRepository _repository;

  GetStatisticsSummary(this._repository);

  /// Executes the use case.
  ///
  /// [params] The parameters specifying date range and counting rule.
  /// Returns [Either] with [Failure] on error or [StatisticsSummary] on success.
  Future<Either<Failure, StatisticsSummary>> call(GetStatisticsSummaryParams params) async {
    // Validate date range
    if (params.startDate.isAfter(params.endDate)) {
      return const Left(ValidationFailure(message: 'Start date must be before end date'));
    }

    return _repository.getStatisticsSummary(
      startDate: params.startDate,
      endDate: params.endDate,
      rule: params.rule,
    );
  }
}
