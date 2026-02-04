import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/data/database/daos/cities_dao.dart';
import 'package:days_tracker/data/database/daos/countries_dao.dart';
import 'package:days_tracker/data/database/daos/daily_presence_dao.dart';
import 'package:days_tracker/data/database/daos/location_pings_dao.dart';
import 'package:days_tracker/data/database/daos/visits_dao.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late CountriesDao countriesDao;
  late CitiesDao citiesDao;
  late VisitsDao visitsDao;
  late DailyPresenceDao dailyPresenceDao;
  late LocationPingsDao locationPingsDao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    countriesDao = CountriesDao(db);
    citiesDao = CitiesDao(db);
    visitsDao = VisitsDao(db);
    dailyPresenceDao = DailyPresenceDao(db);
    locationPingsDao = LocationPingsDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase', () {
    test('clearAllData removes all records', () async {
      final now = DateTime.utc(2025, 1, 1);
      await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'US',
          countryName: 'United States',
          createdAt: now,
          updatedAt: now,
        ),
      );
      var list = await countriesDao.getAll();
      expect(list.length, 1);

      await db.clearAllData();

      list = await countriesDao.getAll();
      expect(list.length, 0);
    });
  });

  group('CountriesDao', () {
    test('insert and getById', () async {
      final now = DateTime.utc(2025, 1, 1);
      final id = await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'PL',
          countryName: 'Poland',
          createdAt: now,
          updatedAt: now,
        ),
      );
      expect(id, greaterThan(0));

      final country = await countriesDao.getById(id);
      expect(country != null, true);
      expect(country!.countryCode, 'PL');
      expect(country.countryName, 'Poland');
    });

    test('getByCode returns existing and uppercases code', () async {
      final now = DateTime.utc(2025, 1, 1);
      await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'UA',
          countryName: 'Ukraine',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final byCode = await countriesDao.getByCode('ua');
      expect(byCode?.countryCode, 'UA');
    });

    test('getOrCreate returns existing when code exists', () async {
      final now = DateTime.utc(2025, 1, 1);
      await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'DE',
          countryName: 'Germany',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final result = await countriesDao.getOrCreate(countryCode: 'DE', countryName: 'Germany');
      expect(result.countryCode, 'DE');
      final all = await countriesDao.getAll();
      expect(all.length, 1);
    });

    test('getOrCreate inserts when code does not exist', () async {
      final result = await countriesDao.getOrCreate(countryCode: 'FR', countryName: 'France');
      expect(result.countryCode, 'FR');
      expect(result.countryName, 'France');
      final all = await countriesDao.getAll();
      expect(all.length, 1);
    });

    test('searchByName finds by substring', () async {
      final now = DateTime.utc(2025, 1, 1);
      await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'PL',
          countryName: 'Poland',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'PT',
          countryName: 'Portugal',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final found = await countriesDao.searchByName('pol');
      expect(found.length, 1);
      expect(found.first.countryName, 'Poland');
    });

    test('deleteById removes country', () async {
      final now = DateTime.utc(2025, 1, 1);
      final id = await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'XX',
          countryName: 'Test',
          createdAt: now,
          updatedAt: now,
        ),
      );
      expect((await countriesDao.getById(id)) != null, true);

      await countriesDao.deleteById(id);
      expect(await countriesDao.getById(id), null);
    });
  });

  group('VisitsDao', () {
    test('getAll returns empty initially', () async {
      final list = await visitsDao.getAll();
      expect(list, isEmpty);
    });

    test('getActiveVisit returns null when no active visit', () async {
      final active = await visitsDao.getActiveVisit();
      expect(active, null);
    });

    test('hasOverlap returns false when no visits', () async {
      final overlap = await visitsDao.hasOverlap(
        DateTime.utc(2025, 1, 1),
        DateTime.utc(2025, 1, 10),
      );
      expect(overlap, false);
    });

    test('getOverlappingVisit returns null when no visits', () async {
      final overlapping = await visitsDao.getOverlappingVisit(
        DateTime.utc(2025, 1, 1),
        DateTime.utc(2025, 1, 10),
      );
      expect(overlapping, null);
    });

    test('hasOverlap returns true when new range overlaps existing', () async {
      final now = DateTime.utc(2025, 1, 1);
      final countryId = await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'DE',
          countryName: 'Germany',
          createdAt: now,
          updatedAt: now,
        ),
      );
      final cityId = await citiesDao.insertCity(
        CitiesCompanion.insert(
          countryId: countryId,
          cityName: 'Berlin',
          latitude: 52.52,
          longitude: 13.40,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await visitsDao.insertVisit(
        VisitsCompanion.insert(
          id: 'v1',
          cityId: cityId,
          startDate: DateTime.utc(2025, 1, 5),
          endDate: Value(DateTime.utc(2025, 1, 15)),
          isActive: const Value(false),
          source: 'manual',
          lastUpdated: now,
          createdAt: now,
        ),
      );
      final overlap = await visitsDao.hasOverlap(
        DateTime.utc(2025, 1, 10),
        DateTime.utc(2025, 1, 20),
      );
      expect(overlap, true);
    });

    test('getInDateRange returns visits in range', () async {
      final now = DateTime.utc(2025, 1, 1);
      final countryId = await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'FR',
          countryName: 'France',
          createdAt: now,
          updatedAt: now,
        ),
      );
      final cityId = await citiesDao.insertCity(
        CitiesCompanion.insert(
          countryId: countryId,
          cityName: 'Paris',
          latitude: 48.85,
          longitude: 2.35,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await visitsDao.insertVisit(
        VisitsCompanion.insert(
          id: 'v2',
          cityId: cityId,
          startDate: DateTime.utc(2025, 1, 10),
          endDate: Value(DateTime.utc(2025, 1, 12)),
          isActive: const Value(false),
          source: 'manual',
          lastUpdated: now,
          createdAt: now,
        ),
      );
      final list = await visitsDao.getInDateRange(
        startDate: DateTime.utc(2025, 1, 1),
        endDate: DateTime.utc(2025, 1, 31),
      );
      expect(list.length, 1);
      expect(list.first.id, 'v2');
    });
  });

  group('CitiesDao', () {
    test('insert and getById', () async {
      final now = DateTime.utc(2025, 1, 1);
      final countryId = await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'DE',
          countryName: 'Germany',
          createdAt: now,
          updatedAt: now,
        ),
      );
      final id = await citiesDao.insertCity(
        CitiesCompanion.insert(
          countryId: countryId,
          cityName: 'Berlin',
          latitude: 52.52,
          longitude: 13.40,
          createdAt: now,
          updatedAt: now,
        ),
      );
      expect(id, greaterThan(0));
      final city = await citiesDao.getById(id);
      expect(city != null, true);
      expect(city!.cityName, 'Berlin');
      expect(city.latitude, 52.52);
    });

    test('findByName returns city when match', () async {
      final now = DateTime.utc(2025, 1, 1);
      final countryId = await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'PL',
          countryName: 'Poland',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await citiesDao.insertCity(
        CitiesCompanion.insert(
          countryId: countryId,
          cityName: 'Warsaw',
          latitude: 52.23,
          longitude: 21.01,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final found = await citiesDao.findByName(countryId: countryId, cityName: 'warsaw');
      expect(found != null, true);
      expect(found!.cityName, 'Warsaw');
    });

    test('getOrCreate returns existing when name matches', () async {
      final now = DateTime.utc(2025, 1, 1);
      final countryId = await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'UA',
          countryName: 'Ukraine',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await citiesDao.insertCity(
        CitiesCompanion.insert(
          countryId: countryId,
          cityName: 'Kyiv',
          latitude: 50.45,
          longitude: 30.52,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final result = await citiesDao.getOrCreate(
        countryId: countryId,
        cityName: 'Kyiv',
        latitude: 50.45,
        longitude: 30.52,
      );
      expect(result.cityName, 'Kyiv');
      final all = await citiesDao.getAll();
      expect(all.length, 1);
    });

    test('getOrCreate inserts when no match', () async {
      final now = DateTime.utc(2025, 1, 1);
      final countryId = await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'IT',
          countryName: 'Italy',
          createdAt: now,
          updatedAt: now,
        ),
      );
      final result = await citiesDao.getOrCreate(
        countryId: countryId,
        cityName: 'Rome',
        latitude: 41.90,
        longitude: 12.50,
      );
      expect(result.cityName, 'Rome');
      final all = await citiesDao.getAll();
      expect(all.length, 1);
    });

    test('searchByName finds by substring', () async {
      final now = DateTime.utc(2025, 1, 1);
      final countryId = await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'ES',
          countryName: 'Spain',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await citiesDao.insertCity(
        CitiesCompanion.insert(
          countryId: countryId,
          cityName: 'Barcelona',
          latitude: 41.38,
          longitude: 2.18,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await citiesDao.insertCity(
        CitiesCompanion.insert(
          countryId: countryId,
          cityName: 'Madrid',
          latitude: 40.42,
          longitude: -3.70,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final found = await citiesDao.searchByName('bar');
      expect(found.length, 1);
      expect(found.first.cityName, 'Barcelona');
    });

    test('getCitiesByCountry returns only that country cities', () async {
      final now = DateTime.utc(2025, 1, 1);
      final c1 = await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'AA',
          countryName: 'Country A',
          createdAt: now,
          updatedAt: now,
        ),
      );
      final c2 = await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'BB',
          countryName: 'Country B',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await citiesDao.insertCity(
        CitiesCompanion.insert(
          countryId: c1,
          cityName: 'City A1',
          latitude: 0,
          longitude: 0,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await citiesDao.insertCity(
        CitiesCompanion.insert(
          countryId: c2,
          cityName: 'City B1',
          latitude: 0,
          longitude: 0,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final list = await citiesDao.getCitiesByCountry(c1);
      expect(list.length, 1);
      expect(list.first.cityName, 'City A1');
    });

    test('updateTotalDays updates city', () async {
      final now = DateTime.utc(2025, 1, 1);
      final countryId = await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'XX',
          countryName: 'Test',
          createdAt: now,
          updatedAt: now,
        ),
      );
      final cityId = await citiesDao.insertCity(
        CitiesCompanion.insert(
          countryId: countryId,
          cityName: 'TestCity',
          latitude: 0,
          longitude: 0,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await citiesDao.updateTotalDays(cityId, 5);
      final city = await citiesDao.getById(cityId);
      expect(city!.totalDays, 5);
    });

    test('deleteById removes city', () async {
      final now = DateTime.utc(2025, 1, 1);
      final countryId = await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'YY',
          countryName: 'Test2',
          createdAt: now,
          updatedAt: now,
        ),
      );
      final cityId = await citiesDao.insertCity(
        CitiesCompanion.insert(
          countryId: countryId,
          cityName: 'ToDelete',
          latitude: 0,
          longitude: 0,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await citiesDao.deleteById(cityId);
      expect(await citiesDao.getById(cityId), null);
    });

    test('findNearestCity returns city within radius', () async {
      final now = DateTime.utc(2025, 1, 1);
      final countryId = await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'DE',
          countryName: 'Germany',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await citiesDao.insertCity(
        CitiesCompanion.insert(
          countryId: countryId,
          cityName: 'Munich',
          latitude: 48.14,
          longitude: 11.58,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final nearest = await citiesDao.findNearestCity(lat: 48.14, lon: 11.58, radiusKm: 50);
      expect(nearest != null, true);
      expect(nearest!.cityName, 'Munich');
    });
  });

  group('DailyPresenceDao', () {
    test('insert and getById', () async {
      final now = DateTime.utc(2025, 1, 1);
      final countryId = await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'DE',
          countryName: 'Germany',
          createdAt: now,
          updatedAt: now,
        ),
      );
      final cityId = await citiesDao.insertCity(
        CitiesCompanion.insert(
          countryId: countryId,
          cityName: 'Berlin',
          latitude: 52.52,
          longitude: 13.40,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await visitsDao.insertVisit(
        VisitsCompanion.insert(
          id: 'visit-dp-1',
          cityId: cityId,
          startDate: DateTime.utc(2025, 1, 1),
          endDate: const Value.absent(),
          isActive: const Value(true),
          source: 'manual',
          lastUpdated: now,
          createdAt: now,
        ),
      );
      final id = await dailyPresenceDao.insertPresence(
        DailyPresenceTableCompanion.insert(
          visitId: 'visit-dp-1',
          date: '2025-01-15',
          cityId: cityId,
          countryId: countryId,
          createdAt: now,
          updatedAt: now,
        ),
      );
      expect(id, greaterThan(0));
      final presence = await dailyPresenceDao.getById(id);
      expect(presence != null, true);
      expect(presence!.date, '2025-01-15');
      expect(presence.cityId, cityId);
    });

    test('findByDateAndCity returns record when match', () async {
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
          id: 'visit-dp-2',
          cityId: cityId,
          startDate: now,
          endDate: const Value.absent(),
          isActive: const Value(true),
          source: 'manual',
          lastUpdated: now,
          createdAt: now,
        ),
      );
      await dailyPresenceDao.insertPresence(
        DailyPresenceTableCompanion.insert(
          visitId: 'visit-dp-2',
          date: '2025-02-01',
          cityId: cityId,
          countryId: countryId,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final found = await dailyPresenceDao.findByDateAndCity('2025-02-01', cityId);
      expect(found != null, true);
      expect(found!.visitId, 'visit-dp-2');
    });

    test('getInDateRange returns records in range', () async {
      final now = DateTime.utc(2025, 1, 1);
      final countryId = await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'FR',
          countryName: 'France',
          createdAt: now,
          updatedAt: now,
        ),
      );
      final cityId = await citiesDao.insertCity(
        CitiesCompanion.insert(
          countryId: countryId,
          cityName: 'Paris',
          latitude: 48.85,
          longitude: 2.35,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await visitsDao.insertVisit(
        VisitsCompanion.insert(
          id: 'visit-dp-3',
          cityId: cityId,
          startDate: now,
          endDate: const Value.absent(),
          isActive: const Value(true),
          source: 'manual',
          lastUpdated: now,
          createdAt: now,
        ),
      );
      await dailyPresenceDao.insertPresence(
        DailyPresenceTableCompanion.insert(
          visitId: 'visit-dp-3',
          date: '2025-03-10',
          cityId: cityId,
          countryId: countryId,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final list = await dailyPresenceDao.getInDateRange(
        startDate: '2025-03-01',
        endDate: '2025-03-31',
      );
      expect(list.length, 1);
      expect(list.first.date, '2025-03-10');
    });

    test('getOrCreate returns existing when date and city match', () async {
      final now = DateTime.utc(2025, 1, 1);
      final countryId = await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'ES',
          countryName: 'Spain',
          createdAt: now,
          updatedAt: now,
        ),
      );
      final cityId = await citiesDao.insertCity(
        CitiesCompanion.insert(
          countryId: countryId,
          cityName: 'Barcelona',
          latitude: 41.38,
          longitude: 2.18,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await visitsDao.insertVisit(
        VisitsCompanion.insert(
          id: 'visit-dp-4',
          cityId: cityId,
          startDate: now,
          endDate: const Value.absent(),
          isActive: const Value(true),
          source: 'manual',
          lastUpdated: now,
          createdAt: now,
        ),
      );
      await dailyPresenceDao.insertPresence(
        DailyPresenceTableCompanion.insert(
          visitId: 'visit-dp-4',
          date: '2025-04-20',
          cityId: cityId,
          countryId: countryId,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final result = await dailyPresenceDao.getOrCreate(
        visitId: 'visit-dp-4',
        date: '2025-04-20',
        cityId: cityId,
        countryId: countryId,
      );
      expect(result.date, '2025-04-20');
      final all = await dailyPresenceDao.getAll();
      expect(all.length, 1);
    });

    test('incrementPingCount updates pingCount and rule', () async {
      final now = DateTime.utc(2025, 1, 1);
      final countryId = await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'IT',
          countryName: 'Italy',
          createdAt: now,
          updatedAt: now,
        ),
      );
      final cityId = await citiesDao.insertCity(
        CitiesCompanion.insert(
          countryId: countryId,
          cityName: 'Rome',
          latitude: 41.90,
          longitude: 12.50,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await visitsDao.insertVisit(
        VisitsCompanion.insert(
          id: 'visit-dp-5',
          cityId: cityId,
          startDate: now,
          endDate: const Value.absent(),
          isActive: const Value(true),
          source: 'manual',
          lastUpdated: now,
          createdAt: now,
        ),
      );
      final id = await dailyPresenceDao.insertPresence(
        DailyPresenceTableCompanion.insert(
          visitId: 'visit-dp-5',
          date: '2025-05-01',
          cityId: cityId,
          countryId: countryId,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await dailyPresenceDao.incrementPingCount(id);
      final presence = await dailyPresenceDao.getById(id);
      expect(presence!.pingCount, 2);
      expect(presence.meetsTwoOrMorePingsRule, true);
    });

    test('countDaysByCountry returns unique days per country', () async {
      final now = DateTime.utc(2025, 1, 1);
      final c1 = await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'C1',
          countryName: 'C1',
          createdAt: now,
          updatedAt: now,
        ),
      );
      final city1 = await citiesDao.insertCity(
        CitiesCompanion.insert(
          countryId: c1,
          cityName: 'City1',
          latitude: 0,
          longitude: 0,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await visitsDao.insertVisit(
        VisitsCompanion.insert(
          id: 'v-c1',
          cityId: city1,
          startDate: now,
          endDate: const Value.absent(),
          isActive: const Value(true),
          source: 'manual',
          lastUpdated: now,
          createdAt: now,
        ),
      );
      await dailyPresenceDao.insertPresence(
        DailyPresenceTableCompanion.insert(
          visitId: 'v-c1',
          date: '2025-06-01',
          cityId: city1,
          countryId: c1,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await dailyPresenceDao.insertPresence(
        DailyPresenceTableCompanion.insert(
          visitId: 'v-c1',
          date: '2025-06-02',
          cityId: city1,
          countryId: c1,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final counts = await dailyPresenceDao.countDaysByCountry(
        startDate: '2025-06-01',
        endDate: '2025-06-30',
        requireTwoOrMorePings: false,
      );
      expect(counts[c1], 2);
    });

    test('deleteByVisitId removes presence records', () async {
      final now = DateTime.utc(2025, 1, 1);
      final countryId = await countriesDao.insertCountry(
        CountriesCompanion.insert(
          countryCode: 'XX',
          countryName: 'X',
          createdAt: now,
          updatedAt: now,
        ),
      );
      final cityId = await citiesDao.insertCity(
        CitiesCompanion.insert(
          countryId: countryId,
          cityName: 'XCity',
          latitude: 0,
          longitude: 0,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await visitsDao.insertVisit(
        VisitsCompanion.insert(
          id: 'visit-del',
          cityId: cityId,
          startDate: now,
          endDate: const Value.absent(),
          isActive: const Value(true),
          source: 'manual',
          lastUpdated: now,
          createdAt: now,
        ),
      );
      await dailyPresenceDao.insertPresence(
        DailyPresenceTableCompanion.insert(
          visitId: 'visit-del',
          date: '2025-07-01',
          cityId: cityId,
          countryId: countryId,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final deleted = await dailyPresenceDao.deleteByVisitId('visit-del');
      expect(deleted, 1);
      final list = await dailyPresenceDao.getByDate('2025-07-01');
      expect(list.where((p) => p.visitId == 'visit-del').length, 0);
    });
  });

  group('LocationPingsDao', () {
    test('insert and getById', () async {
      final now = DateTime.utc(2025, 1, 1);
      await locationPingsDao.insertPing(
        LocationPingsCompanion.insert(
          id: 'ping-1',
          timestamp: now,
          latitude: 52.52,
          longitude: 13.40,
          geocodingStatus: 'pending',
          createdAt: now,
        ),
      );
      final ping = await locationPingsDao.getById('ping-1');
      expect(ping != null, true);
      expect(ping!.latitude, 52.52);
      expect(ping.geocodingStatus, 'pending');
    });

    test('getPendingGeocoding returns pending and retryable failed', () async {
      final now = DateTime.utc(2025, 1, 1);
      await locationPingsDao.insertPing(
        LocationPingsCompanion.insert(
          id: 'ping-pending',
          timestamp: now,
          latitude: 50.0,
          longitude: 10.0,
          geocodingStatus: 'pending',
          createdAt: now,
        ),
      );
      final list = await locationPingsDao.getPendingGeocoding();
      expect(list.length, 1);
      expect(list.first.id, 'ping-pending');
    });

    test('updateGeocodingSuccess updates city and country', () async {
      final now = DateTime.utc(2025, 1, 1);
      await locationPingsDao.insertPing(
        LocationPingsCompanion.insert(
          id: 'ping-success',
          timestamp: now,
          latitude: 48.85,
          longitude: 2.35,
          geocodingStatus: 'pending',
          createdAt: now,
        ),
      );
      await locationPingsDao.updateGeocodingSuccess(
        pingId: 'ping-success',
        cityName: 'Paris',
        countryCode: 'FR',
      );
      final ping = await locationPingsDao.getById('ping-success');
      expect(ping!.cityName, 'Paris');
      expect(ping.countryCode, 'FR');
      expect(ping.geocodingStatus, 'success');
    });

    test('updateGeocodingFailed increments retry and keeps pending when under max', () async {
      final now = DateTime.utc(2025, 1, 1);
      await locationPingsDao.insertPing(
        LocationPingsCompanion.insert(
          id: 'ping-fail',
          timestamp: now,
          latitude: 0,
          longitude: 0,
          geocodingStatus: 'pending',
          retryCount: const Value(0),
          createdAt: now,
        ),
      );
      await locationPingsDao.updateGeocodingFailed('ping-fail');
      final ping = await locationPingsDao.getById('ping-fail');
      expect(ping!.retryCount, 1);
      expect(ping.geocodingStatus, 'pending');
    });

    test('linkToVisit sets visitId', () async {
      final now = DateTime.utc(2025, 1, 1);
      await locationPingsDao.insertPing(
        LocationPingsCompanion.insert(
          id: 'ping-link',
          timestamp: now,
          latitude: 0,
          longitude: 0,
          geocodingStatus: 'success',
          cityName: const Value('Berlin'),
          countryCode: const Value('DE'),
          createdAt: now,
        ),
      );
      await locationPingsDao.linkToVisit('ping-link', 'visit-123');
      final ping = await locationPingsDao.getById('ping-link');
      expect(ping!.visitId, 'visit-123');
    });

    test('getPingsForVisit returns only that visit pings', () async {
      final now = DateTime.utc(2025, 1, 1);
      await locationPingsDao.insertPing(
        LocationPingsCompanion.insert(
          id: 'p1',
          timestamp: now,
          latitude: 0,
          longitude: 0,
          geocodingStatus: 'success',
          visitId: const Value('v-a'),
          createdAt: now,
        ),
      );
      await locationPingsDao.insertPing(
        LocationPingsCompanion.insert(
          id: 'p2',
          timestamp: now.add(const Duration(hours: 1)),
          latitude: 0,
          longitude: 0,
          geocodingStatus: 'success',
          visitId: const Value('v-a'),
          createdAt: now,
        ),
      );
      await locationPingsDao.insertPing(
        LocationPingsCompanion.insert(
          id: 'p3',
          timestamp: now,
          latitude: 0,
          longitude: 0,
          geocodingStatus: 'success',
          visitId: const Value('v-b'),
          createdAt: now,
        ),
      );
      final list = await locationPingsDao.getPingsForVisit('v-a');
      expect(list.length, 2);
      expect(list.map((p) => p.id).toList(), containsAll(['p1', 'p2']));
    });

    test('getInDateRange filters by timestamp', () async {
      final base = DateTime.utc(2025, 8, 15);
      await locationPingsDao.insertPing(
        LocationPingsCompanion.insert(
          id: 'range-1',
          timestamp: base,
          latitude: 0,
          longitude: 0,
          geocodingStatus: 'pending',
          createdAt: base,
        ),
      );
      await locationPingsDao.insertPing(
        LocationPingsCompanion.insert(
          id: 'range-2',
          timestamp: DateTime.utc(2025, 9, 1),
          latitude: 0,
          longitude: 0,
          geocodingStatus: 'pending',
          createdAt: DateTime.utc(2025, 9, 1),
        ),
      );
      final list = await locationPingsDao.getInDateRange(
        startDate: DateTime.utc(2025, 8, 1),
        endDate: DateTime.utc(2025, 8, 31),
      );
      expect(list.length, 1);
      expect(list.first.id, 'range-1');
    });

    test('getMostRecent returns latest ping', () async {
      final t1 = DateTime.utc(2025, 10, 1);
      final t2 = DateTime.utc(2025, 10, 2);
      await locationPingsDao.insertPing(
        LocationPingsCompanion.insert(
          id: 'recent-1',
          timestamp: t1,
          latitude: 0,
          longitude: 0,
          geocodingStatus: 'pending',
          createdAt: t1,
        ),
      );
      await locationPingsDao.insertPing(
        LocationPingsCompanion.insert(
          id: 'recent-2',
          timestamp: t2,
          latitude: 0,
          longitude: 0,
          geocodingStatus: 'pending',
          createdAt: t2,
        ),
      );
      final recent = await locationPingsDao.getMostRecent();
      expect(recent != null, true);
      expect(recent!.id, 'recent-2');
    });

    test('deleteById removes ping', () async {
      final now = DateTime.utc(2025, 1, 1);
      await locationPingsDao.insertPing(
        LocationPingsCompanion.insert(
          id: 'ping-del',
          timestamp: now,
          latitude: 0,
          longitude: 0,
          geocodingStatus: 'pending',
          createdAt: now,
        ),
      );
      await locationPingsDao.deleteById('ping-del');
      expect(await locationPingsDao.getById('ping-del'), null);
    });
  });
}
