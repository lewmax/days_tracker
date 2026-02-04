import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/country.dart';
import 'package:days_tracker/domain/entities/country_stats.dart';
import 'package:days_tracker/domain/entities/day_details.dart';
import 'package:days_tracker/domain/entities/statistics_summary.dart';
import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:days_tracker/domain/repositories/statistics_repository.dart';
import 'package:days_tracker/domain/usecases/statistics/get_daily_presence_calendar.dart';
import 'package:flutter_test/flutter_test.dart';

class MockStatisticsRepository implements StatisticsRepository {
  Map<String, List<Country>>? _calendar;
  Failure? _failure;

  void setResult(Map<String, List<Country>> calendar) {
    _calendar = calendar;
    _failure = null;
  }

  void setFailure(Failure f) {
    _failure = f;
    _calendar = null;
  }

  @override
  Future<Either<Failure, Map<String, List<Country>>>> getDailyPresenceCalendar({
    required int year,
    required int month,
    required DayCountingRule rule,
  }) async {
    if (_failure != null) return Left(_failure!);
    return Right(_calendar ?? {});
  }

  @override
  Future<Either<Failure, StatisticsSummary>> getStatisticsSummary({
    required DateTime startDate,
    required DateTime endDate,
    required DayCountingRule rule,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, DayDetails>> getDayDetails({
    required DateTime date,
    required DayCountingRule rule,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, List<CountryStats>>> getCountryStats({
    required DateTime startDate,
    required DateTime endDate,
    required DayCountingRule rule,
  }) async => throw UnimplementedError();
}

void main() {
  late GetDailyPresenceCalendar useCase;
  late MockStatisticsRepository mockRepo;

  setUp(() {
    mockRepo = MockStatisticsRepository();
    useCase = GetDailyPresenceCalendar(mockRepo);
  });

  group('GetDailyPresenceCalendar', () {
    test('returns calendar when repository succeeds', () async {
      mockRepo.setResult({'2025-06-15': []});

      final result = await useCase.call(
        const GetDailyPresenceCalendarParams(
          year: 2025,
          month: 6,
          rule: DayCountingRule.anyPresence,
        ),
      );

      expect(result.isRight(), true);
      result.fold((l) => fail('expected Right'), (r) {
        expect(r.containsKey('2025-06-15'), true);
        expect(r['2025-06-15'], isEmpty);
      });
    });

    test('returns ValidationFailure when month is invalid (too low)', () async {
      final result = await useCase.call(
        const GetDailyPresenceCalendarParams(
          year: 2025,
          month: 0,
          rule: DayCountingRule.anyPresence,
        ),
      );

      expect(result.isLeft(), true);
      result.fold((l) => expect(l, isA<ValidationFailure>()), (r) => fail('expected Left'));
    });

    test('returns ValidationFailure when month is invalid (too high)', () async {
      final result = await useCase.call(
        const GetDailyPresenceCalendarParams(
          year: 2025,
          month: 13,
          rule: DayCountingRule.anyPresence,
        ),
      );

      expect(result.isLeft(), true);
      result.fold((l) => expect(l, isA<ValidationFailure>()), (r) => fail('expected Left'));
    });

    test('returns ValidationFailure when year is out of range', () async {
      final result = await useCase.call(
        const GetDailyPresenceCalendarParams(
          year: 1999,
          month: 6,
          rule: DayCountingRule.anyPresence,
        ),
      );

      expect(result.isLeft(), true);
      result.fold((l) => expect(l, isA<ValidationFailure>()), (r) => fail('expected Left'));
    });

    test('returns failure when repository fails', () async {
      mockRepo.setFailure(const DatabaseFailure(message: 'DB error'));

      final result = await useCase.call(
        const GetDailyPresenceCalendarParams(
          year: 2025,
          month: 6,
          rule: DayCountingRule.twoOrMorePings,
        ),
      );

      expect(result.isLeft(), true);
    });
  });
}
