import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/core/utils/date_utils.dart';
import 'package:days_tracker/data/database/daos/cities_dao.dart';
import 'package:days_tracker/data/database/daos/countries_dao.dart';
import 'package:days_tracker/data/database/daos/daily_presence_dao.dart';
import 'package:days_tracker/data/database/daos/visits_dao.dart';
import 'package:days_tracker/data/mappers/city_mapper.dart';
import 'package:days_tracker/data/mappers/country_mapper.dart';
import 'package:days_tracker/data/mappers/visit_mapper.dart';
import 'package:days_tracker/domain/entities/city_presence.dart';
import 'package:days_tracker/domain/entities/city_stats.dart';
import 'package:days_tracker/domain/entities/country.dart';
import 'package:days_tracker/domain/entities/country_presence.dart';
import 'package:days_tracker/domain/entities/country_stats.dart';
import 'package:days_tracker/domain/entities/day_details.dart';
import 'package:days_tracker/domain/entities/statistics_summary.dart';
import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:days_tracker/domain/repositories/statistics_repository.dart';
import 'package:injectable/injectable.dart';

/// Implementation of [StatisticsRepository] using local SQLite database.
@LazySingleton(as: StatisticsRepository)
class StatisticsRepositoryImpl implements StatisticsRepository {
  final DailyPresenceDao _dailyPresenceDao;
  final CountriesDao _countriesDao;
  final CitiesDao _citiesDao;
  final VisitsDao _visitsDao;

  StatisticsRepositoryImpl(
    this._dailyPresenceDao,
    this._countriesDao,
    this._citiesDao,
    this._visitsDao,
  );

  @override
  Future<Either<Failure, StatisticsSummary>> getStatisticsSummary({
    required DateTime startDate,
    required DateTime endDate,
    required DayCountingRule rule,
  }) async {
    try {
      final startDateStr = AppDateUtils.formatDate(startDate);
      final endDateStr = AppDateUtils.formatDate(endDate);
      final requireTwoOrMore = rule == DayCountingRule.twoOrMorePings;

      // Get days per country
      final daysByCountry = await _dailyPresenceDao.countDaysByCountry(
        startDate: startDateStr,
        endDate: endDateStr,
        requireTwoOrMorePings: requireTwoOrMore,
      );

      // Get days per city
      final daysByCity = await _dailyPresenceDao.countDaysByCity(
        startDate: startDateStr,
        endDate: endDateStr,
        requireTwoOrMorePings: requireTwoOrMore,
      );

      // Calculate total unique days
      final presenceRecords = await _dailyPresenceDao.getInDateRange(
        startDate: startDateStr,
        endDate: endDateStr,
      );

      final Set<String> uniqueDates = {};
      for (final record in presenceRecords) {
        if (!requireTwoOrMore || record.meetsTwoOrMorePingsRule) {
          uniqueDates.add(record.date);
        }
      }

      final totalDays = uniqueDates.length;

      // Build country stats
      final countryStats = <CountryStats>[];
      for (final entry in daysByCountry.entries) {
        final countryData = await _countriesDao.getById(entry.key);
        if (countryData == null) continue;

        final country = countryData.toEntity();
        final days = entry.value;
        final percentage = totalDays > 0 ? (days / totalDays) * 100 : 0.0;

        // Get city stats for this country
        final citiesInCountry = await _citiesDao.getCitiesByCountry(entry.key);
        final cityStatsList = <CityStats>[];

        for (final cityData in citiesInCountry) {
          final cityDays = daysByCity[cityData.id] ?? 0;
          if (cityDays > 0) {
            final city = cityData.toEntity(country: country);
            final cityPercentage = days > 0 ? (cityDays / days) * 100 : 0.0;
            cityStatsList.add(CityStats(city: city, days: cityDays, percentage: cityPercentage));
          }
        }

        // Sort cities by days descending
        cityStatsList.sort((a, b) => b.days.compareTo(a.days));

        countryStats.add(
          CountryStats(country: country, days: days, percentage: percentage, cities: cityStatsList),
        );
      }

      // Sort countries by days descending
      countryStats.sort((a, b) => b.days.compareTo(a.days));

      return Right(
        StatisticsSummary(
          countries: countryStats,
          totalDays: totalDays,
          totalCountries: countryStats.length,
          totalCities: daysByCity.length,
          periodStart: startDate,
          periodEnd: endDate,
        ),
      );
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get statistics summary: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, List<Country>>>> getDailyPresenceCalendar({
    required int year,
    required int month,
    required DayCountingRule rule,
  }) async {
    try {
      final startDate = AppDateUtils.firstDayOfMonth(year, month);
      final endDate = AppDateUtils.lastDayOfMonth(year, month);
      final startDateStr = AppDateUtils.formatDate(startDate);
      final endDateStr = AppDateUtils.formatDate(endDate);
      final requireTwoOrMore = rule == DayCountingRule.twoOrMorePings;

      final presenceRecords = await _dailyPresenceDao.getInDateRange(
        startDate: startDateStr,
        endDate: endDateStr,
      );

      final Map<String, Set<int>> dateCountryIds = {};

      for (final record in presenceRecords) {
        if (!requireTwoOrMore || record.meetsTwoOrMorePingsRule) {
          dateCountryIds.putIfAbsent(record.date, () => {});
          dateCountryIds[record.date]!.add(record.countryId);
        }
      }

      // Convert country IDs to Country entities
      final Map<String, List<Country>> result = {};
      for (final entry in dateCountryIds.entries) {
        final countries = <Country>[];
        for (final countryId in entry.value) {
          final countryData = await _countriesDao.getById(countryId);
          if (countryData != null) {
            countries.add(countryData.toEntity());
          }
        }
        result[entry.key] = countries;
      }

      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get calendar data: $e'));
    }
  }

  @override
  Future<Either<Failure, DayDetails>> getDayDetails({
    required DateTime date,
    required DayCountingRule rule,
  }) async {
    try {
      final dateStr = AppDateUtils.formatDate(date);
      final requireTwoOrMore = rule == DayCountingRule.twoOrMorePings;

      final presenceRecords = await _dailyPresenceDao.getByDate(dateStr);

      // Filter by rule
      final filteredRecords = presenceRecords.where((r) {
        return !requireTwoOrMore || r.meetsTwoOrMorePingsRule;
      }).toList();

      // Group by country
      final Map<int, List<({int cityId, int pingCount, String visitId})>> countryData = {};

      for (final record in filteredRecords) {
        countryData.putIfAbsent(record.countryId, () => []);
        countryData[record.countryId]!.add((
          cityId: record.cityId,
          pingCount: record.pingCount,
          visitId: record.visitId,
        ));
      }

      // Build country presence list
      final countryPresences = <CountryPresence>[];

      for (final entry in countryData.entries) {
        final countryDataObj = await _countriesDao.getById(entry.key);
        if (countryDataObj == null) continue;

        final country = countryDataObj.toEntity();
        final cityPresences = <CityPresence>[];

        for (final cityInfo in entry.value) {
          final cityDataObj = await _citiesDao.getById(cityInfo.cityId);
          if (cityDataObj == null) continue;

          final city = cityDataObj.toEntity(country: country);

          // Get visit if available
          final visitData = await _visitsDao.getById(cityInfo.visitId);
          final visit = visitData?.toEntity(city: city);

          cityPresences.add(CityPresence(city: city, pingCount: cityInfo.pingCount, visit: visit));
        }

        countryPresences.add(CountryPresence(country: country, cities: cityPresences));
      }

      return Right(DayDetails(date: date, countries: countryPresences));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get day details: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CountryStats>>> getCountryStats({
    required DateTime startDate,
    required DateTime endDate,
    required DayCountingRule rule,
  }) async {
    final result = await getStatisticsSummary(startDate: startDate, endDate: endDate, rule: rule);

    return result.map((summary) => summary.countries);
  }
}
