import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/day_details.dart';
import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:days_tracker/domain/repositories/statistics_repository.dart';
import 'package:injectable/injectable.dart';

/// Parameters for getting day details.
class GetDayDetailsParams {
  final DateTime date;
  final DayCountingRule rule;

  const GetDayDetailsParams({required this.date, required this.rule});
}

/// Use case for getting detailed information about a specific day.
///
/// Returns details including:
/// - Countries visited on that day
/// - Cities visited in each country
/// - Ping counts per city
/// - Associated visits
///
/// Used for the calendar day detail modal.
@lazySingleton
class GetDayDetails {
  final StatisticsRepository _repository;

  GetDayDetails(this._repository);

  /// Executes the use case.
  ///
  /// [params] The parameters specifying the date and counting rule.
  /// Returns [Either] with [Failure] on error or [DayDetails] on success.
  Future<Either<Failure, DayDetails>> call(GetDayDetailsParams params) async {
    return _repository.getDayDetails(date: params.date, rule: params.rule);
  }
}
