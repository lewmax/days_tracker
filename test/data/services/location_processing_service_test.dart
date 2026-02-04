import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/data/database/daos/cities_dao.dart';
import 'package:days_tracker/data/database/daos/countries_dao.dart';
import 'package:days_tracker/data/database/daos/daily_presence_dao.dart';
import 'package:days_tracker/data/database/daos/location_pings_dao.dart';
import 'package:days_tracker/data/database/daos/visits_dao.dart';
import 'package:days_tracker/data/services/geocoding_service.dart';
import 'package:days_tracker/data/services/location_processing_service.dart';
import 'package:days_tracker/domain/entities/city.dart';
import 'package:days_tracker/domain/entities/country.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

/// Mock geocoding service that returns configurable City or Failure.
class MockGeocodingService implements GeocodingService {
  MockGeocodingService();

  Either<Failure, City>? reverseGeocodeResult;

  @override
  Future<Either<Failure, City>> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async => reverseGeocodeResult ?? const Left(GeocodingFailure(message: 'Not configured'));

  @override
  Future<Either<Failure, City>> geocodeCityName({
    required String cityName,
    required String countryCode,
  }) async => throw UnimplementedError();
}

void main() {
  late AppDatabase db;
  late LocationPingsDao pingsDao;
  late VisitsDao visitsDao;
  late DailyPresenceDao presenceDao;
  late MockGeocodingService mockGeocoding;
  late LocationProcessingService service;
  late CountriesDao countriesDao;
  late CitiesDao citiesDao;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    countriesDao = CountriesDao(db);
    citiesDao = CitiesDao(db);
    pingsDao = LocationPingsDao(db);
    visitsDao = VisitsDao(db);
    presenceDao = DailyPresenceDao(db);
    mockGeocoding = MockGeocodingService();
    service = LocationProcessingService(
      pingsDao,
      visitsDao,
      presenceDao,
      mockGeocoding,
      const Uuid(),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('LocationProcessingService', () {
    test('processLocationPing returns Right when geocoding fails (ping stays pending)', () async {
      mockGeocoding.reverseGeocodeResult = const Left(GeocodingFailure(message: 'No network'));
      final result = await service.processLocationPing(
        latitude: 52.52,
        longitude: 13.40,
        accuracy: null,
      );
      expect(result.isRight(), true);
      final pings = await pingsDao.getAll();
      expect(pings.length, 1);
      expect(pings.first.geocodingStatus, 'pending');
    });

    test(
      'processLocationPing creates visit and daily presence when geocoding succeeds and no active visit',
      () async {
        final now = DateTime.utc(2025, 6, 15, 12, 0, 0);
        final countryId = await countriesDao.insertCountry(
          CountriesCompanion.insert(
            countryCode: 'DE',
            countryName: 'Germany',
            createdAt: now,
            updatedAt: now,
          ),
        );
        expect(countryId, 1);
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
        final country = Country(
          id: countryId,
          countryCode: 'DE',
          countryName: 'Germany',
          totalDays: 0,
        );
        final city = City(
          id: cityId,
          countryId: countryId,
          cityName: 'Berlin',
          latitude: 52.52,
          longitude: 13.40,
          totalDays: 0,
          country: country,
        );
        mockGeocoding.reverseGeocodeResult = Right(city);

        final result = await service.processLocationPing(
          latitude: 52.52,
          longitude: 13.40,
          accuracy: 10.0,
        );
        expect(result.isRight(), true);

        final pings = await pingsDao.getAll();
        expect(pings.length, 1);
        expect(pings.first.geocodingStatus, 'success');
        expect(pings.first.cityName, 'Berlin');
        expect(pings.first.visitId != null, true);

        final visits = await visitsDao.getAll();
        expect(visits.length, 1);
        expect(visits.first.isActive, true);
        expect(visits.first.cityId, cityId);

        final presenceList = await presenceDao.getAll();
        expect(presenceList.length, 1);
        expect(presenceList.first.cityId, cityId);
        expect(presenceList.first.countryId, countryId);
      },
    );

    test('retryFailedGeocoding updates pending ping when geocoding succeeds', () async {
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
      await pingsDao.insertPing(
        LocationPingsCompanion.insert(
          id: 'ping-retry-1',
          timestamp: now,
          latitude: 52.23,
          longitude: 21.01,
          geocodingStatus: 'pending',
          createdAt: now,
        ),
      );
      final country = Country(
        id: countryId,
        countryCode: 'PL',
        countryName: 'Poland',
        totalDays: 0,
      );
      mockGeocoding.reverseGeocodeResult = Right(
        City(
          id: cityId,
          countryId: countryId,
          cityName: 'Warsaw',
          latitude: 52.23,
          longitude: 21.01,
          totalDays: 0,
          country: country,
        ),
      );

      final result = await service.retryFailedGeocoding();
      expect(result.isRight(), true);
      result.fold((l) => fail('expected Right'), (count) => expect(count, 1));
      final ping = await pingsDao.getById('ping-retry-1');
      expect(ping!.geocodingStatus, 'success');
      expect(ping.cityName, 'Warsaw');
    });

    test('retryFailedGeocoding updates retry count when geocoding fails', () async {
      final now = DateTime.utc(2025, 1, 1);
      await pingsDao.insertPing(
        LocationPingsCompanion.insert(
          id: 'ping-fail-1',
          timestamp: now,
          latitude: 0,
          longitude: 0,
          geocodingStatus: 'pending',
          retryCount: const Value(0),
          createdAt: now,
        ),
      );
      mockGeocoding.reverseGeocodeResult = const Left(GeocodingFailure(message: 'API error'));

      final result = await service.retryFailedGeocoding();
      expect(result.isRight(), true);
      result.fold((l) => fail('expected Right'), (count) => expect(count, 0));
      final ping = await pingsDao.getById('ping-fail-1');
      expect(ping!.retryCount, 1);
      expect(ping.geocodingStatus, 'pending');
    });
  });
}
