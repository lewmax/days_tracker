import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/country.dart';
import 'package:days_tracker/domain/entities/country_stats.dart';
import 'package:days_tracker/domain/entities/day_details.dart';
import 'package:days_tracker/domain/entities/statistics_summary.dart';
import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:days_tracker/domain/repositories/statistics_repository.dart';
import 'package:days_tracker/domain/usecases/statistics/get_day_details.dart';
import 'package:flutter_test/flutter_test.dart';

class MockStatisticsRepository implements StatisticsRepository {
  DayDetails? _dayDetails;
  Failure? _failure;

  void setResult(DayDetails details) {
    _dayDetails = details;
    _failure = null;
  }

  void setFailure(Failure f) {
    _failure = f;
    _dayDetails = null;
  }

  @override
  Future<Either<Failure, DayDetails>> getDayDetails({
    required DateTime date,
    required DayCountingRule rule,
  }) async {
    if (_failure != null) return Left(_failure!);
    return Right(_dayDetails!);
  }

  @override
  Future<Either<Failure, StatisticsSummary>> getStatisticsSummary({
    required DateTime startDate,
    required DateTime endDate,
    required DayCountingRule rule,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, Map<String, List<Country>>>> getDailyPresenceCalendar({
    required int year,
    required int month,
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
  late GetDayDetails useCase;
  late MockStatisticsRepository mockRepo;

  setUp(() {
    mockRepo = MockStatisticsRepository();
    useCase = GetDayDetails(mockRepo);
  });

  group('GetDayDetails', () {
    test('returns day details when repository succeeds', () async {
      final date = DateTime.utc(2025, 6, 15);
      final details = DayDetails(date: date, countries: []);
      mockRepo.setResult(details);

      final result = await useCase.call(
        GetDayDetailsParams(date: date, rule: DayCountingRule.anyPresence),
      );

      expect(result.isRight(), true);
      result.fold((l) => fail('expected Right'), (r) {
        expect(r.date, date);
        expect(r.countries, isEmpty);
      });
    });

    test('returns failure when repository fails', () async {
      mockRepo.setFailure(const DatabaseFailure(message: 'DB error'));

      final result = await useCase.call(
        GetDayDetailsParams(date: DateTime.utc(2025, 6, 15), rule: DayCountingRule.twoOrMorePings),
      );

      expect(result.isLeft(), true);
    });
  });
}
