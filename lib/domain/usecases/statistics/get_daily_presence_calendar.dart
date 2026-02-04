import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/country.dart';
import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:days_tracker/domain/repositories/statistics_repository.dart';
import 'package:injectable/injectable.dart';

/// Parameters for getting daily presence calendar.
class GetDailyPresenceCalendarParams {
  final int year;
  final int month;
  final DayCountingRule rule;

  const GetDailyPresenceCalendarParams({
    required this.year,
    required this.month,
    required this.rule,
  });
}

/// Use case for getting daily presence data for calendar display.
///
/// Returns a map where:
/// - Key: date string in YYYY-MM-DD format
/// - Value: list of countries the user was in on that day
///
/// Used to populate the calendar view with country flags.
@lazySingleton
class GetDailyPresenceCalendar {
  final StatisticsRepository _repository;

  GetDailyPresenceCalendar(this._repository);

  /// Executes the use case.
  ///
  /// [params] The parameters specifying year, month, and counting rule.
  /// Returns [Either] with [Failure] on error or calendar data on success.
  Future<Either<Failure, Map<String, List<Country>>>> call(
    GetDailyPresenceCalendarParams params,
  ) async {
    // Validate month
    if (params.month < 1 || params.month > 12) {
      return Left(ValidationFailure(message: 'Invalid month: ${params.month}'));
    }

    // Validate year (reasonable range)
    if (params.year < 2000 || params.year > 2100) {
      return Left(ValidationFailure(message: 'Invalid year: ${params.year}'));
    }

    return _repository.getDailyPresenceCalendar(
      year: params.year,
      month: params.month,
      rule: params.rule,
    );
  }
}
