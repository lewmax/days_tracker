import 'package:days_tracker/domain/entities/country.dart';
import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:days_tracker/domain/enums/statistics_view_mode.dart';
import 'package:days_tracker/domain/enums/time_period.dart';
import 'package:days_tracker/domain/usecases/settings/get_day_counting_rule.dart';
import 'package:days_tracker/domain/usecases/statistics/get_daily_presence_calendar.dart';
import 'package:days_tracker/domain/usecases/statistics/get_day_details.dart';
import 'package:days_tracker/domain/usecases/statistics/get_statistics_summary.dart';
import 'package:days_tracker/presentation/blocs/statistics/statistics_event.dart';
import 'package:days_tracker/presentation/blocs/statistics/statistics_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

/// BLoC for managing statistics state.
///
/// Handles loading statistics, changing view modes, time periods,
/// and day counting rules, as well as calendar navigation.
@injectable
class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final Logger _logger = Logger();
  final GetStatisticsSummary _getStatisticsSummary;
  final GetDailyPresenceCalendar _getDailyPresenceCalendar;
  final GetDayDetails _getDayDetails;
  final GetDayCountingRule _getDayCountingRule;

  TimePeriod _currentPeriod = TimePeriod.thirtyOneDays;
  DayCountingRule _currentRule = DayCountingRule.anyPresence;
  StatisticsViewMode _currentViewMode = StatisticsViewMode.calendar;
  int _calendarYear = DateTime.now().year;
  int _calendarMonth = DateTime.now().month;

  StatisticsBloc(
    this._getStatisticsSummary,
    this._getDailyPresenceCalendar,
    this._getDayDetails,
    this._getDayCountingRule,
  ) : super(const StatisticsState.initial()) {
    on<StatisticsEvent>(_onEvent);
  }

  Future<void> _onEvent(StatisticsEvent event, Emitter<StatisticsState> emit) async {
    _logger.d('[StatisticsBloc] Event: $event');
    await event.when(
      loadStatistics: () => _onLoadStatistics(emit),
      refreshStatistics: () => _onRefreshStatistics(emit),
      changeTimePeriod: (period) => _onChangeTimePeriod(period, emit),
      changeDayCountingRule: (rule) => _onChangeDayCountingRule(rule, emit),
      changeViewMode: (mode) => _onChangeViewMode(mode, emit),
      previousMonth: () => _onPreviousMonth(emit),
      nextMonth: () => _onNextMonth(emit),
      selectDate: (date) => _onSelectDate(date, emit),
      clearSelectedDate: () => _onClearSelectedDate(emit),
    );
  }

  Future<void> _onLoadStatistics(Emitter<StatisticsState> emit) async {
    _logger.i('[StatisticsBloc] Loading statistics');
    emit(const StatisticsState.loading());

    // Get current day counting rule from settings
    final ruleResult = await _getDayCountingRule();
    ruleResult.fold(
      (failure) {}, // Use default rule
      (rule) => _currentRule = rule,
    );

    await _loadData(emit);
  }

  Future<void> _onRefreshStatistics(Emitter<StatisticsState> emit) async {
    _logger.d('[StatisticsBloc] Refreshing statistics');
    await _loadData(emit);
  }

  Future<void> _onChangeTimePeriod(TimePeriod period, Emitter<StatisticsState> emit) async {
    _logger.d('[StatisticsBloc] Time period changed: $period');
    _currentPeriod = period;
    await _loadData(emit);
  }

  Future<void> _onChangeDayCountingRule(DayCountingRule rule, Emitter<StatisticsState> emit) async {
    _logger.d('[StatisticsBloc] Day counting rule changed: $rule');
    _currentRule = rule;
    await _loadData(emit);
  }

  Future<void> _onChangeViewMode(StatisticsViewMode mode, Emitter<StatisticsState> emit) async {
    _logger.d('[StatisticsBloc] View mode changed: $mode');
    _currentViewMode = mode;

    state.mapOrNull(
      loaded: (loadedState) {
        emit(loadedState.copyWith(viewMode: mode));
      },
    );
  }

  Future<void> _onPreviousMonth(Emitter<StatisticsState> emit) async {
    if (_calendarMonth == 1) {
      _calendarMonth = 12;
      _calendarYear--;
    } else {
      _calendarMonth--;
    }
    await _loadCalendarData(emit);
  }

  Future<void> _onNextMonth(Emitter<StatisticsState> emit) async {
    if (_calendarMonth == 12) {
      _calendarMonth = 1;
      _calendarYear++;
    } else {
      _calendarMonth++;
    }
    await _loadCalendarData(emit);
  }

  Future<void> _onSelectDate(DateTime date, Emitter<StatisticsState> emit) async {
    final result = await _getDayDetails(GetDayDetailsParams(date: date, rule: _currentRule));

    result.fold(
      (failure) {}, // Ignore error for day details
      (details) {
        state.mapOrNull(
          loaded: (loadedState) {
            emit(loadedState.copyWith(selectedDate: date, selectedDayDetails: details));
          },
        );
      },
    );
  }

  Future<void> _onClearSelectedDate(Emitter<StatisticsState> emit) async {
    state.mapOrNull(
      loaded: (loadedState) {
        emit(loadedState.copyWith(selectedDate: null, selectedDayDetails: null));
      },
    );
  }

  /// Loads all statistics data.
  Future<void> _loadData(Emitter<StatisticsState> emit) async {
    final dateRange = _currentPeriod.getDateRange();

    // Load summary
    final summaryResult = await _getStatisticsSummary(
      GetStatisticsSummaryParams(
        startDate: dateRange.start,
        endDate: dateRange.end,
        rule: _currentRule,
      ),
    );

    // Load calendar data
    final calendarResult = await _getDailyPresenceCalendar(
      GetDailyPresenceCalendarParams(
        year: _calendarYear,
        month: _calendarMonth,
        rule: _currentRule,
      ),
    );

    summaryResult.fold(
      (failure) {
        _logger.e('[StatisticsBloc] Load failed: ${failure.message}');
        emit(StatisticsState.error(failure.message));
      },
      (summary) {
        final calendarData = calendarResult.fold(
          (failure) => <String, List<Country>>{},
          (data) => data,
        );
        _logger.i(
          '[StatisticsBloc] Loaded: ${summary.countries.length} countries, calendar months: ${calendarData.length}',
        );

        emit(
          StatisticsState.loaded(
            summary: summary,
            calendarData: calendarData,
            timePeriod: _currentPeriod,
            countingRule: _currentRule,
            viewMode: _currentViewMode,
            calendarYear: _calendarYear,
            calendarMonth: _calendarMonth,
          ),
        );
      },
    );
  }

  /// Loads only calendar data (for month navigation).
  Future<void> _loadCalendarData(Emitter<StatisticsState> emit) async {
    final calendarResult = await _getDailyPresenceCalendar(
      GetDailyPresenceCalendarParams(
        year: _calendarYear,
        month: _calendarMonth,
        rule: _currentRule,
      ),
    );

    state.mapOrNull(
      loaded: (loadedState) {
        calendarResult.fold(
          (failure) {}, // Keep existing data on error
          (data) {
            emit(
              loadedState.copyWith(
                calendarData: data,
                calendarYear: _calendarYear,
                calendarMonth: _calendarMonth,
              ),
            );
          },
        );
      },
    );
  }
}
