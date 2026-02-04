import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/domain/entities/country.dart';
import 'package:days_tracker/domain/entities/country_stats.dart';
import 'package:days_tracker/domain/entities/day_details.dart';
import 'package:days_tracker/domain/entities/statistics_summary.dart';
import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:days_tracker/domain/repositories/statistics_repository.dart';
import 'package:days_tracker/domain/usecases/statistics/get_statistics_summary.dart';
import 'package:flutter_test/flutter_test.dart';

/// Simple mock implementation of StatisticsRepository for testing.
class MockStatisticsRepository implements StatisticsRepository {
  StatisticsSummary? _summary;
  Failure? _failure;

  void setSummary(StatisticsSummary summary) => _summary = summary;
  void setFailure(Failure? failure) => _failure = failure;

  @override
  Future<Either<Failure, StatisticsSummary>> getStatisticsSummary({
    required DateTime startDate,
    required DateTime endDate,
    required DayCountingRule rule,
  }) async {
    if (_failure != null) return Left(_failure!);
    return Right(_summary!);
  }

  @override
  Future<Either<Failure, Map<String, List<Country>>>> getDailyPresenceCalendar({
    required int year,
    required int month,
    required DayCountingRule rule,
  }) async => const Right({});

  @override
  Future<Either<Failure, DayDetails>> getDayDetails({
    required DateTime date,
    required DayCountingRule rule,
  }) async => Right(DayDetails(date: date, countries: const []));

  @override
  Future<Either<Failure, List<CountryStats>>> getCountryStats({
    required DateTime startDate,
    required DateTime endDate,
    required DayCountingRule rule,
  }) async => const Right([]);
}

void main() {
  late GetStatisticsSummary useCase;
  late MockStatisticsRepository mockRepository;

  setUp(() {
    mockRepository = MockStatisticsRepository();
    useCase = GetStatisticsSummary(mockRepository);
  });

  final startDate = DateTime.utc(2026);
  final endDate = DateTime.utc(2026, 1, 31);
  const rule = DayCountingRule.anyPresence;

  const testCountry = Country(id: 1, countryCode: 'PL', countryName: 'Poland', totalDays: 15);

  final testSummary = StatisticsSummary(
    countries: const [CountryStats(country: testCountry, days: 15, percentage: 50.0)],
    totalDays: 30,
    totalCountries: 1,
    totalCities: 1,
    periodStart: startDate,
    periodEnd: endDate,
  );

  group('GetStatisticsSummary', () {
    test('should return statistics summary when successful', () async {
      // Arrange
      mockRepository.setSummary(testSummary);

      // Act
      final result = await useCase(
        GetStatisticsSummaryParams(startDate: startDate, endDate: endDate, rule: rule),
      );

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Expected right but got left'), (summary) {
        expect(summary.totalDays, 30);
        expect(summary.totalCountries, 1);
        expect(summary.countries.first.country.countryCode, 'PL');
      });
    });

    test('should fail when start date is after end date', () async {
      // Arrange
      mockRepository.setSummary(testSummary);
      final invalidParams = GetStatisticsSummaryParams(
        startDate: endDate,
        endDate: startDate,
        rule: rule,
      );

      // Act
      final result = await useCase(invalidParams);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, contains('before end date'));
      }, (summary) => fail('Expected left but got right'));
    });

    test('should propagate failure from repository', () async {
      // Arrange
      mockRepository.setFailure(const DatabaseFailure(message: 'Database error'));

      // Act
      final result = await useCase(
        GetStatisticsSummaryParams(startDate: startDate, endDate: endDate, rule: rule),
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<DatabaseFailure>()),
        (summary) => fail('Expected left but got right'),
      );
    });

    test('should work with both day counting rules', () async {
      // Arrange
      mockRepository.setSummary(testSummary);
      const twoOrMoreRule = DayCountingRule.twoOrMorePings;

      // Act
      final result = await useCase(
        GetStatisticsSummaryParams(startDate: startDate, endDate: endDate, rule: twoOrMoreRule),
      );

      // Assert
      expect(result.isRight(), true);
    });
  });
}
