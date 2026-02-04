import 'package:days_tracker/domain/entities/country.dart';
import 'package:days_tracker/domain/entities/day_details.dart';
import 'package:days_tracker/domain/entities/statistics_summary.dart';
import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:days_tracker/domain/enums/statistics_view_mode.dart';
import 'package:days_tracker/domain/enums/time_period.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'statistics_state.freezed.dart';

/// State for the StatisticsBLoC.
@freezed
class StatisticsState with _$StatisticsState {
  const StatisticsState._();

  /// Initial state before any data is loaded.
  const factory StatisticsState.initial() = _Initial;

  /// Loading state while fetching statistics.
  const factory StatisticsState.loading() = _Loading;

  /// Loaded state with statistics data.
  const factory StatisticsState.loaded({
    required StatisticsSummary summary,
    required Map<String, List<Country>> calendarData,
    required TimePeriod timePeriod,
    required DayCountingRule countingRule,
    required StatisticsViewMode viewMode,
    required int calendarYear,
    required int calendarMonth,
    DayDetails? selectedDayDetails,
    DateTime? selectedDate,
  }) = _Loaded;

  /// Error state when something goes wrong.
  const factory StatisticsState.error(String message) = _Error;

  /// Helper to check if we're in loaded state.
  bool get isLoaded => this is _Loaded;

  /// Get summary if loaded.
  StatisticsSummary? get summaryOrNull =>
      maybeMap(loaded: (state) => state.summary, orElse: () => null);

  /// Get current view mode.
  StatisticsViewMode get viewModeOrDefault =>
      maybeMap(loaded: (state) => state.viewMode, orElse: () => StatisticsViewMode.calendar);

  /// Get current time period.
  TimePeriod get timePeriodOrDefault =>
      maybeMap(loaded: (state) => state.timePeriod, orElse: () => TimePeriod.thirtyOneDays);

  /// Get current counting rule.
  DayCountingRule get countingRuleOrDefault =>
      maybeMap(loaded: (state) => state.countingRule, orElse: () => DayCountingRule.anyPresence);
}
