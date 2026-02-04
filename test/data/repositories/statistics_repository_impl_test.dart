import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/data/database/daos/cities_dao.dart';
import 'package:days_tracker/data/database/daos/countries_dao.dart';
import 'package:days_tracker/data/database/daos/daily_presence_dao.dart';
import 'package:days_tracker/data/database/daos/visits_dao.dart';
import 'package:days_tracker/domain/enums/day_counting_rule.dart';
import 'package:days_tracker/data/repositories/statistics_repository_impl.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late StatisticsRepositoryImpl repo;
  late CountriesDao countriesDao;
  late CitiesDao citiesDao;
  late VisitsDao visitsDao;
  late DailyPresenceDao dailyPresenceDao;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    countriesDao = CountriesDao(db);
    citiesDao = CitiesDao(db);
    visitsDao = VisitsDao(db);
    dailyPresenceDao = DailyPresenceDao(db);
    repo = StatisticsRepositoryImpl(dailyPresenceDao, countriesDao, citiesDao, visitsDao);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedData() async {
    final now = DateTime.utc(2025, 1, 1);
    final countryId = await countriesDao.insertCountry(
      CountriesCompanion.insert(
        countryCode: 'PL',
        countryName: 'Poland',
        createdAt: now,
        updatedAt: now,
      ),
    );
    final cityId = await citiesDao.insertCity(
      CitiesCompanion.insert(
        countryId: countryId,
        cityName: 'Warsaw',
        latitude: 52.23,
        longitude: 21.01,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await visitsDao.insertVisit(
      VisitsCompanion.insert(
        id: 'visit-1',
        cityId: cityId,
        startDate: DateTime.utc(2025, 6, 1),
        endDate: const Value.absent(),
        isActive: const Value(true),
        source: 'manual',
        lastUpdated: now,
        createdAt: now,
      ),
    );
    await dailyPresenceDao.insertPresence(
      DailyPresenceTableCompanion.insert(
        visitId: 'visit-1',
        date: '2025-06-15',
        cityId: cityId,
        countryId: countryId,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await dailyPresenceDao.insertPresence(
      DailyPresenceTableCompanion.insert(
        visitId: 'visit-1',
        date: '2025-06-16',
        cityId: cityId,
        countryId: countryId,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  group('StatisticsRepositoryImpl', () {
    test('getStatisticsSummary returns summary with seeded data', () async {
      await seedData();
      final result = await repo.getStatisticsSummary(
        startDate: DateTime.utc(2025, 6, 1),
        endDate: DateTime.utc(2025, 6, 30),
        rule: DayCountingRule.anyPresence,
      );
      expect(result.isRight(), true);
      result.fold((l) => fail('expected Right'), (summary) {
        expect(summary.totalDays, 2);
        expect(summary.totalCountries, 1);
        expect(summary.countries.length, 1);
        expect(summary.countries.first.country.countryCode, 'PL');
        expect(summary.countries.first.days, 2);
      });
    });

    test('getStatisticsSummary returns empty when no data', () async {
      final result = await repo.getStatisticsSummary(
        startDate: DateTime.utc(2025, 1, 1),
        endDate: DateTime.utc(2025, 1, 31),
        rule: DayCountingRule.anyPresence,
      );
      expect(result.isRight(), true);
      result.fold((l) => fail('expected Right'), (summary) {
        expect(summary.totalDays, 0);
        expect(summary.totalCountries, 0);
        expect(summary.countries, isEmpty);
      });
    });

    test('getDailyPresenceCalendar returns map of date to countries', () async {
      await seedData();
      final result = await repo.getDailyPresenceCalendar(
        year: 2025,
        month: 6,
        rule: DayCountingRule.anyPresence,
      );
      expect(result.isRight(), true);
      result.fold((l) => fail('expected Right'), (map) {
        expect(map.containsKey('2025-06-15'), true);
        expect(map.containsKey('2025-06-16'), true);
        expect(map['2025-06-15']!.length, 1);
        expect(map['2025-06-15']!.first.countryCode, 'PL');
      });
    });

    test('getDayDetails returns day details for date with presence', () async {
      await seedData();
      final result = await repo.getDayDetails(
        date: DateTime.utc(2025, 6, 15),
        rule: DayCountingRule.anyPresence,
      );
      expect(result.isRight(), true);
      result.fold((l) => fail('expected Right'), (details) {
        expect(details.date, DateTime.utc(2025, 6, 15));
        expect(details.countries.length, 1);
        expect(details.countries.first.country.countryCode, 'PL');
        expect(details.countries.first.cities.length, 1);
        expect(details.countries.first.cities.first.city.cityName, 'Warsaw');
      });
    });

    test('getDayDetails returns empty countries for date with no presence', () async {
      await seedData();
      final result = await repo.getDayDetails(
        date: DateTime.utc(2025, 7, 1),
        rule: DayCountingRule.anyPresence,
      );
      expect(result.isRight(), true);
      result.fold((l) => fail('expected Right'), (details) {
        expect(details.countries, isEmpty);
      });
    });

    test('getCountryStats returns list of country stats', () async {
      await seedData();
      final result = await repo.getCountryStats(
        startDate: DateTime.utc(2025, 6, 1),
        endDate: DateTime.utc(2025, 6, 30),
        rule: DayCountingRule.anyPresence,
      );
      expect(result.isRight(), true);
      result.fold((l) => fail('expected Right'), (list) {
        expect(list.length, 1);
        expect(list.first.country.countryCode, 'PL');
        expect(list.first.days, 2);
      });
    });

    test('getStatisticsSummary with twoOrMorePings filters correctly', () async {
      await seedData();
      final id = (await dailyPresenceDao.getByDate('2025-06-15')).first.id;
      await dailyPresenceDao.incrementPingCount(id);
      final result = await repo.getStatisticsSummary(
        startDate: DateTime.utc(2025, 6, 1),
        endDate: DateTime.utc(2025, 6, 30),
        rule: DayCountingRule.twoOrMorePings,
      );
      result.fold((l) => fail('expected Right'), (summary) {
        expect(summary.totalDays, 1);
        expect(summary.countries.first.days, 1);
      });
    });
  });
}
