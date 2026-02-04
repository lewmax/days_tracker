import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/data/database/daos/cities_dao.dart';
import 'package:days_tracker/data/database/daos/countries_dao.dart';
import 'package:days_tracker/data/database/daos/daily_presence_dao.dart';
import 'package:days_tracker/data/database/daos/location_pings_dao.dart';
import 'package:days_tracker/data/database/daos/visits_dao.dart';
import 'package:days_tracker/data/services/export_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ExportService exportService;
  late CountriesDao countriesDao;
  late CitiesDao citiesDao;
  late VisitsDao visitsDao;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    countriesDao = CountriesDao(db);
    citiesDao = CitiesDao(db);
    visitsDao = VisitsDao(db);
    final pingsDao = LocationPingsDao(db);
    final presenceDao = DailyPresenceDao(db);
    exportService = ExportService(countriesDao, citiesDao, visitsDao, pingsDao, presenceDao);
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
  });

  tearDown(() async {
    await db.close();
  });

  group('ExportService', () {
    test('exportToJson returns Right with JSON string', () async {
      final result = await exportService.exportToJson();
      expect(result.isRight(), true);
      result.fold((f) => fail('expected Right'), (jsonStr) {
        expect(jsonStr, isNotEmpty);
        expect(jsonStr, contains('version'));
        expect(jsonStr, contains('exported_at'));
        expect(jsonStr, contains('app_version'));
        expect(jsonStr, contains('data'));
        expect(jsonStr, contains('countries'));
        expect(jsonStr, contains('cities'));
        expect(jsonStr, contains('visits'));
        expect(jsonStr, contains('location_pings'));
        expect(jsonStr, contains('daily_presence'));
      });
    });

    test('exportToJson includes inserted country and city', () async {
      final result = await exportService.exportToJson();
      result.fold((f) => fail('expected Right'), (jsonStr) {
        expect(jsonStr, contains('Ukraine'));
        expect(jsonStr, contains('UA'));
        expect(jsonStr, contains('Kyiv'));
      });
    });
  });
}
