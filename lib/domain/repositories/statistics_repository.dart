import 'package:dartz/dartz.dart';

import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/country.dart';
import 'package:days_tracker/domain/entities/country_stats.dart';
import 'package:days_tracker/domain/entities/day_details.dart';
import 'package:days_tracker/domain/entities/statistics_summary.dart';
import 'package:days_tracker/domain/enums/day_counting_rule.dart';

/// Abstract repository for statistics calculations.
///
/// Provides methods for calculating days spent in countries/cities
/// based on different counting rules.
abstract class StatisticsRepository {
  /// Gets a complete statistics summary for a date range.
  ///
  /// [startDate] The start of the period.
  /// [endDate] The end of the period.
  /// [rule] The day counting rule to apply.
  Future<Either<Failure, StatisticsSummary>> getStatisticsSummary({
    required DateTime startDate,
    required DateTime endDate,
    required DayCountingRule rule,
  });

  /// Gets calendar data for a specific month.
  ///
  /// [year] The year.
  /// [month] The month (1-12).
  /// [rule] The day counting rule to apply.
  /// Returns a map where keys are dates (YYYY-MM-DD) and values are
  /// lists of countries present on that day.
  Future<Either<Failure, Map<String, List<Country>>>> getDailyPresenceCalendar({
    required int year,
    required int month,
    required DayCountingRule rule,
  });

  /// Gets detailed presence information for a specific day.
  ///
  /// [date] The date to get details for.
  /// [rule] The day counting rule to apply.
  Future<Either<Failure, DayDetails>> getDayDetails({
    required DateTime date,
    required DayCountingRule rule,
  });

  /// Gets country statistics for a date range.
  ///
  /// [startDate] The start of the period.
  /// [endDate] The end of the period.
  /// [rule] The day counting rule to apply.
  /// Returns a list of country statistics sorted by days descending.
  Future<Either<Failure, List<CountryStats>>> getCountryStats({
    required DateTime startDate,
    required DateTime endDate,
    required DayCountingRule rule,
  });
}
