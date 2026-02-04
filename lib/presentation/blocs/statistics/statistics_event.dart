import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:days_tracker/domain/enums/statistics_view_mode.dart';
import 'package:days_tracker/domain/enums/time_period.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'statistics_event.freezed.dart';

/// Events for the StatisticsBLoC.
@freezed
class StatisticsEvent with _$StatisticsEvent {
  /// Load statistics for the current period and rule.
  const factory StatisticsEvent.loadStatistics() = _LoadStatistics;

  /// Refresh statistics (pull-to-refresh).
  const factory StatisticsEvent.refreshStatistics() = _RefreshStatistics;

  /// Change the time period filter.
  const factory StatisticsEvent.changeTimePeriod(TimePeriod period) = _ChangeTimePeriod;

  /// Change the day counting rule.
  const factory StatisticsEvent.changeDayCountingRule(DayCountingRule rule) =
      _ChangeDayCountingRule;

  /// Change the statistics view mode.
  const factory StatisticsEvent.changeViewMode(StatisticsViewMode mode) = _ChangeViewMode;

  /// Navigate to previous month in calendar view.
  const factory StatisticsEvent.previousMonth() = _PreviousMonth;

  /// Navigate to next month in calendar view.
  const factory StatisticsEvent.nextMonth() = _NextMonth;

  /// Select a specific date to show details.
  const factory StatisticsEvent.selectDate(DateTime date) = _SelectDate;

  /// Clear selected date.
  const factory StatisticsEvent.clearSelectedDate() = _ClearSelectedDate;
}
