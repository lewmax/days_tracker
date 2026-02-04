import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/country.dart';
import 'package:days_tracker/domain/entities/day_details.dart';
import 'package:days_tracker/domain/entities/statistics_summary.dart';
import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:days_tracker/domain/enums/statistics_view_mode.dart';
import 'package:days_tracker/domain/enums/time_period.dart';
import 'package:days_tracker/domain/usecases/settings/get_day_counting_rule.dart';
import 'package:days_tracker/domain/usecases/statistics/get_daily_presence_calendar.dart';
import 'package:days_tracker/domain/usecases/statistics/get_day_details.dart';
import 'package:days_tracker/domain/usecases/statistics/get_statistics_summary.dart';
import 'package:days_tracker/presentation/blocs/statistics/statistics_bloc.dart';
import 'package:days_tracker/presentation/blocs/statistics/statistics_event.dart';
import 'package:days_tracker/presentation/blocs/statistics/statistics_state.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock implementations
class MockGetStatisticsSummary implements GetStatisticsSummary {
  Either<Failure, StatisticsSummary>? resultToReturn;

  void setResult(StatisticsSummary summary) {
    resultToReturn = Right(summary);
  }

  void setFailure(Failure failure) {
    resultToReturn = Left(failure);
  }

  @override
  Future<Either<Failure, StatisticsSummary>> call(GetStatisticsSummaryParams params) async {
    return resultToReturn!;
  }
}

class MockGetDailyPresenceCalendar implements GetDailyPresenceCalendar {
  Either<Failure, Map<String, List<Country>>>? resultToReturn;

  void setResult(Map<String, List<Country>> calendar) {
    resultToReturn = Right(calendar);
  }

  void setFailure(Failure failure) {
    resultToReturn = Left(failure);
  }

  @override
  Future<Either<Failure, Map<String, List<Country>>>> call(
    GetDailyPresenceCalendarParams params,
  ) async {
    return resultToReturn!;
  }
}

class MockGetDayDetails implements GetDayDetails {
  Either<Failure, DayDetails>? resultToReturn;

  void setResult(DayDetails details) {
    resultToReturn = Right(details);
  }

  void setFailure(Failure failure) {
    resultToReturn = Left(failure);
  }

  @override
  Future<Either<Failure, DayDetails>> call(GetDayDetailsParams params) async {
    return resultToReturn!;
  }
}

class MockGetDayCountingRule implements GetDayCountingRule {
  Either<Failure, DayCountingRule>? resultToReturn;

  void setResult(DayCountingRule rule) {
    resultToReturn = Right(rule);
  }

  void setFailure(Failure failure) {
    resultToReturn = Left(failure);
  }

  @override
  Future<Either<Failure, DayCountingRule>> call() async {
    return resultToReturn!;
  }
}

void main() {
  group('StatisticsBloc', () {
    late MockGetStatisticsSummary mockGetStatisticsSummary;
    late MockGetDailyPresenceCalendar mockGetDailyPresenceCalendar;
    late MockGetDayDetails mockGetDayDetails;
    late MockGetDayCountingRule mockGetDayCountingRule;

    final periodStart = DateTime.utc(2026, 1, 1);
    final periodEnd = DateTime.utc(2026, 1, 31);

    final testSummary = StatisticsSummary(
      countries: const [],
      totalDays: 15,
      totalCountries: 2,
      totalCities: 3,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );

    setUp(() {
      mockGetStatisticsSummary = MockGetStatisticsSummary();
      mockGetDailyPresenceCalendar = MockGetDailyPresenceCalendar();
      mockGetDayDetails = MockGetDayDetails();
      mockGetDayCountingRule = MockGetDayCountingRule();
    });

    StatisticsBloc createBloc() {
      return StatisticsBloc(
        mockGetStatisticsSummary,
        mockGetDailyPresenceCalendar,
        mockGetDayDetails,
        mockGetDayCountingRule,
      );
    }

    test('initial state should be StatisticsState.initial()', () {
      mockGetStatisticsSummary.setResult(testSummary);
      mockGetDailyPresenceCalendar.setResult({});
      mockGetDayCountingRule.setResult(DayCountingRule.anyPresence);

      final bloc = createBloc();
      expect(bloc.state, const StatisticsState.initial());
      bloc.close();
    });

    blocTest<StatisticsBloc, StatisticsState>(
      'emits [loading, loaded] when loadStatistics is added',
      setUp: () {
        mockGetStatisticsSummary.setResult(testSummary);
        mockGetDailyPresenceCalendar.setResult({});
        mockGetDayCountingRule.setResult(DayCountingRule.anyPresence);
      },
      build: createBloc,
      act: (bloc) => bloc.add(const StatisticsEvent.loadStatistics()),
      expect: () => [
        const StatisticsState.loading(),
        isA<StatisticsState>().having(
          (s) => s.maybeMap(loaded: (l) => l.summary.totalDays, orElse: () => -1),
          'total days',
          15,
        ),
      ],
    );

    blocTest<StatisticsBloc, StatisticsState>(
      'emits error state when loadStatistics fails',
      setUp: () {
        mockGetStatisticsSummary.setFailure(const DatabaseFailure(message: 'DB error'));
        mockGetDailyPresenceCalendar.setResult({});
        mockGetDayCountingRule.setResult(DayCountingRule.anyPresence);
      },
      build: createBloc,
      act: (bloc) => bloc.add(const StatisticsEvent.loadStatistics()),
      expect: () => [const StatisticsState.loading(), const StatisticsState.error('DB error')],
    );

    blocTest<StatisticsBloc, StatisticsState>(
      'changes time period correctly',
      setUp: () {
        mockGetStatisticsSummary.setResult(testSummary);
        mockGetDailyPresenceCalendar.setResult({});
        mockGetDayCountingRule.setResult(DayCountingRule.anyPresence);
      },
      build: createBloc,
      seed: () => StatisticsState.loaded(
        summary: testSummary,
        calendarData: const {},
        viewMode: StatisticsViewMode.calendar,
        timePeriod: TimePeriod.thirtyOneDays,
        countingRule: DayCountingRule.anyPresence,
        calendarYear: 2026,
        calendarMonth: 1,
      ),
      act: (bloc) =>
          bloc.add(const StatisticsEvent.changeTimePeriod(TimePeriod.threeHundredSixtyFiveDays)),
      expect: () => [
        isA<StatisticsState>().having(
          (s) => s.maybeMap(loaded: (l) => l.timePeriod, orElse: () => null),
          'time period',
          TimePeriod.threeHundredSixtyFiveDays,
        ),
      ],
    );

    blocTest<StatisticsBloc, StatisticsState>(
      'changes view mode correctly',
      setUp: () {
        mockGetStatisticsSummary.setResult(testSummary);
        mockGetDailyPresenceCalendar.setResult({});
        mockGetDayCountingRule.setResult(DayCountingRule.anyPresence);
      },
      build: createBloc,
      seed: () => StatisticsState.loaded(
        summary: testSummary,
        calendarData: const {},
        viewMode: StatisticsViewMode.calendar,
        timePeriod: TimePeriod.thirtyOneDays,
        countingRule: DayCountingRule.anyPresence,
        calendarYear: 2026,
        calendarMonth: 1,
      ),
      act: (bloc) =>
          bloc.add(const StatisticsEvent.changeViewMode(StatisticsViewMode.groupedByCountry)),
      expect: () => [
        isA<StatisticsState>().having(
          (s) => s.maybeMap(loaded: (l) => l.viewMode, orElse: () => null),
          'view mode',
          StatisticsViewMode.groupedByCountry,
        ),
      ],
    );

    blocTest<StatisticsBloc, StatisticsState>(
      'changes day counting rule correctly',
      setUp: () {
        mockGetStatisticsSummary.setResult(testSummary);
        mockGetDailyPresenceCalendar.setResult({});
        mockGetDayCountingRule.setResult(DayCountingRule.twoOrMorePings);
      },
      build: createBloc,
      seed: () => StatisticsState.loaded(
        summary: testSummary,
        calendarData: const {},
        viewMode: StatisticsViewMode.calendar,
        timePeriod: TimePeriod.thirtyOneDays,
        countingRule: DayCountingRule.anyPresence,
        calendarYear: 2026,
        calendarMonth: 1,
      ),
      act: (bloc) =>
          bloc.add(const StatisticsEvent.changeDayCountingRule(DayCountingRule.twoOrMorePings)),
      expect: () => [
        isA<StatisticsState>().having(
          (s) => s.maybeMap(loaded: (l) => l.countingRule, orElse: () => null),
          'day counting rule',
          DayCountingRule.twoOrMorePings,
        ),
      ],
    );

    blocTest<StatisticsBloc, StatisticsState>(
      'navigates to previous month',
      setUp: () {
        mockGetStatisticsSummary.setResult(testSummary);
        mockGetDailyPresenceCalendar.setResult({});
        mockGetDayCountingRule.setResult(DayCountingRule.anyPresence);
      },
      build: createBloc,
      seed: () => StatisticsState.loaded(
        summary: testSummary,
        calendarData: const {},
        viewMode: StatisticsViewMode.calendar,
        timePeriod: TimePeriod.thirtyOneDays,
        countingRule: DayCountingRule.anyPresence,
        calendarYear: 2026,
        calendarMonth: 2,
      ),
      act: (bloc) => bloc.add(const StatisticsEvent.previousMonth()),
      expect: () => [
        isA<StatisticsState>().having(
          (s) => s.maybeMap(loaded: (l) => l.calendarMonth, orElse: () => -1),
          'selected month',
          1,
        ),
      ],
    );

    blocTest<StatisticsBloc, StatisticsState>(
      'navigates to next month',
      setUp: () {
        mockGetStatisticsSummary.setResult(testSummary);
        mockGetDailyPresenceCalendar.setResult({});
        mockGetDayCountingRule.setResult(DayCountingRule.anyPresence);
      },
      build: createBloc,
      seed: () => StatisticsState.loaded(
        summary: testSummary,
        calendarData: const {},
        viewMode: StatisticsViewMode.calendar,
        timePeriod: TimePeriod.thirtyOneDays,
        countingRule: DayCountingRule.anyPresence,
        calendarYear: 2026,
        calendarMonth: 2,
      ),
      act: (bloc) => bloc.add(const StatisticsEvent.nextMonth()),
      expect: () => [
        isA<StatisticsState>().having(
          (s) => s.maybeMap(loaded: (l) => l.calendarMonth, orElse: () => -1),
          'selected month',
          3,
        ),
      ],
    );
  });
}
