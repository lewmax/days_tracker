import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/data/database/daos/cities_dao.dart';
import 'package:days_tracker/data/database/daos/countries_dao.dart';
import 'package:days_tracker/data/database/daos/daily_presence_dao.dart';
import 'package:days_tracker/data/database/daos/visits_dao.dart';
import 'package:days_tracker/data/repositories/visits_repository_impl.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:days_tracker/domain/enums/visit_source.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late VisitsRepositoryImpl repo;
  late CountriesDao countriesDao;
  late CitiesDao citiesDao;
  late int countryId;
  late int cityId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    countriesDao = CountriesDao(db);
    citiesDao = CitiesDao(db);
    final visitsDao = VisitsDao(db);
    final dailyPresenceDao = DailyPresenceDao(db);
    repo = VisitsRepositoryImpl(visitsDao, citiesDao, countriesDao, dailyPresenceDao);
    final now = DateTime.utc(2025, 1, 1);
    countryId = await countriesDao.insertCountry(
      CountriesCompanion.insert(
        countryCode: 'PL',
        countryName: 'Poland',
        createdAt: now,
        updatedAt: now,
      ),
    );
    cityId = await citiesDao.insertCity(
      CitiesCompanion.insert(
        countryId: countryId,
        cityName: 'Warsaw',
        latitude: 52.23,
        longitude: 21.01,
        createdAt: now,
        updatedAt: now,
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('VisitsRepositoryImpl', () {
    test('getAllVisits returns empty list when no visits', () async {
      final result = await repo.getAllVisits();
      expect(result.isRight(), true);
      result.fold((l) => fail('expected Right'), (list) {
        expect(list, isEmpty);
      });
    });

    test('getActiveVisit returns null when no visits', () async {
      final result = await repo.getActiveVisit();
      expect(result.isRight(), true);
      result.fold((l) => fail('expected Right'), (v) => expect(v, null));
    });

    test('createVisit then getAllVisits returns the visit', () async {
      final visit = Visit(
        id: 'v1',
        cityId: cityId,
        startDate: DateTime.utc(2025, 1, 1),
        endDate: DateTime.utc(2025, 1, 10),
        isActive: false,
        source: VisitSource.manual,
        userLatitude: null,
        userLongitude: null,
        lastUpdated: DateTime.utc(2025, 1, 1),
      );
      final createResult = await repo.createVisit(visit);
      expect(createResult.isRight(), true);

      final getAllResult = await repo.getAllVisits();
      getAllResult.fold((l) => fail('expected Right'), (list) {
        expect(list.length, 1);
        expect(list.first.id, 'v1');
        expect(list.first.cityId, cityId);
        expect(list.first.source, VisitSource.manual);
      });
    });

    test('getVisitById returns visit after create', () async {
      final visit = Visit(
        id: 'v2',
        cityId: cityId,
        startDate: DateTime.utc(2025, 1, 5),
        endDate: DateTime.utc(2025, 1, 15),
        isActive: false,
        source: VisitSource.manual,
        userLatitude: null,
        userLongitude: null,
        lastUpdated: DateTime.utc(2025, 1, 5),
      );
      await repo.createVisit(visit);

      final result = await repo.getVisitById('v2');
      result.fold((l) => fail('expected Right'), (v) {
        expect(v.id, 'v2');
        expect(v.city?.cityName, 'Warsaw');
        expect(v.city?.country?.countryName, 'Poland');
      });
    });

    test('createVisit with overlap returns ValidationFailure', () async {
      final visit1 = Visit(
        id: 'v-a',
        cityId: cityId,
        startDate: DateTime.utc(2025, 1, 1),
        endDate: DateTime.utc(2025, 1, 10),
        isActive: false,
        source: VisitSource.manual,
        userLatitude: null,
        userLongitude: null,
        lastUpdated: DateTime.utc(2025, 1, 1),
      );
      await repo.createVisit(visit1);

      final visit2 = Visit(
        id: 'v-b',
        cityId: cityId,
        startDate: DateTime.utc(2025, 1, 5),
        endDate: DateTime.utc(2025, 1, 15),
        isActive: false,
        source: VisitSource.manual,
        userLatitude: null,
        userLongitude: null,
        lastUpdated: DateTime.utc(2025, 1, 5),
      );
      final result = await repo.createVisit(visit2);
      expect(result.isLeft(), true);
      result.fold((f) => expect(f.message, contains('overlap')), (r) => fail('expected Left'));
    });

    test('deleteVisit removes visit', () async {
      final visit = Visit(
        id: 'v-del',
        cityId: cityId,
        startDate: DateTime.utc(2025, 1, 1),
        endDate: DateTime.utc(2025, 1, 5),
        isActive: false,
        source: VisitSource.manual,
        userLatitude: null,
        userLongitude: null,
        lastUpdated: DateTime.utc(2025, 1, 1),
      );
      await repo.createVisit(visit);

      final deleteResult = await repo.deleteVisit('v-del');
      expect(deleteResult.isRight(), true);

      final getResult = await repo.getVisitById('v-del');
      getResult.fold(
        (f) => expect(f.message, contains('not found')),
        (v) => fail('expected Left NotFoundFailure'),
      );
    });
  });
}
