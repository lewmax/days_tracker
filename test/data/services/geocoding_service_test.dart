import 'package:dartz/dartz.dart';
import 'package:days_tracker/core/error/failures.dart';
import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/data/database/daos/cities_dao.dart';
import 'package:days_tracker/data/database/daos/countries_dao.dart';
import 'package:days_tracker/data/datasources/google_maps_api_datasource.dart';
import 'package:days_tracker/data/services/geocoding_service.dart';
import 'package:days_tracker/domain/repositories/settings_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

/// Fake data source that returns configurable results without calling the real API.
/// Overrides reverseGeocode and searchPlaces so the real HTTP client is never used.
class FakeGoogleMapsDataSource extends GoogleMapsApiDataSource {
  FakeGoogleMapsDataSource() : super(_StubSettingsRepository(), http.Client());

  Either<Failure, GeocodingResult>? reverseGeocodeResult;
  Either<Failure, List<PlaceResult>>? searchPlacesResult;

  @override
  Future<Either<Failure, GeocodingResult>> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async => reverseGeocodeResult ?? const Left(GeocodingFailure(message: 'Not configured'));

  @override
  Future<Either<Failure, List<PlaceResult>>> searchPlaces({
    required String query,
    int limit = 10,
  }) async => searchPlacesResult ?? const Right([]);
}

class _StubSettingsRepository implements SettingsRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

void main() {
  late AppDatabase db;
  late CitiesDao citiesDao;
  late CountriesDao countriesDao;
  late FakeGoogleMapsDataSource fakeDataSource;
  late GeocodingService geocodingService;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    citiesDao = CitiesDao(db);
    countriesDao = CountriesDao(db);
    fakeDataSource = FakeGoogleMapsDataSource();
    geocodingService = GeocodingService(fakeDataSource, citiesDao, countriesDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('GeocodingService', () {
    test('reverseGeocode returns nearby city when one exists in database', () async {
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
      final result = await geocodingService.reverseGeocode(latitude: 52.23, longitude: 21.01);
      expect(result.isRight(), true);
      result.fold((l) => fail('expected Right'), (city) {
        expect(city.cityName, 'Warsaw');
        expect(city.country?.countryCode, 'PL');
      });
    });

    test('reverseGeocode uses API result when no nearby city and API succeeds', () async {
      fakeDataSource.reverseGeocodeResult = const Right(
        GeocodingResult(
          cityName: 'Berlin',
          countryCode: 'DE',
          countryName: 'Germany',
          latitude: 52.52,
          longitude: 13.40,
        ),
      );
      final result = await geocodingService.reverseGeocode(latitude: 52.52, longitude: 13.40);
      expect(result.isRight(), true);
      result.fold((l) => fail('expected Right'), (city) {
        expect(city.cityName, 'Berlin');
        expect(city.country?.countryCode, 'DE');
      });
      final allCities = await citiesDao.getAll();
      expect(allCities.length, 1);
      expect(allCities.first.cityName, 'Berlin');
    });

    test('reverseGeocode returns failure when no nearby city and API fails', () async {
      fakeDataSource.reverseGeocodeResult = const Left(GeocodingFailure(message: 'API error'));
      final result = await geocodingService.reverseGeocode(latitude: 0, longitude: 0);
      expect(result.isLeft(), true);
    });

    test('geocodeCityName returns local city when found in database', () async {
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
      // Service uses searchByName(countryCode) - pass substring of name to match
      final result = await geocodingService.geocodeCityName(
        cityName: 'Warsaw',
        countryCode: 'Poland',
      );
      expect(result.isRight(), true);
      result.fold((l) => fail('expected Right: $l'), (city) {
        expect(city.cityName, 'Warsaw');
        expect(city.country?.countryCode, 'PL');
      });
    });

    test('geocodeCityName uses API and creates city when not in database', () async {
      fakeDataSource.searchPlacesResult = const Right([
        PlaceResult(
          placeId: 'p1',
          description: 'Paris, France',
          cityName: 'Paris',
          countryCode: 'FR',
        ),
      ]);
      final result = await geocodingService.geocodeCityName(cityName: 'Paris', countryCode: 'FR');
      expect(result.isRight(), true);
      result.fold((l) => fail('expected Right'), (city) {
        expect(city.cityName, 'Paris');
      });
    });

    test('geocodeCityName returns failure when API returns empty', () async {
      fakeDataSource.searchPlacesResult = const Right([]);
      final result = await geocodingService.geocodeCityName(
        cityName: 'UnknownCity',
        countryCode: 'XX',
      );
      expect(result.isLeft(), true);
    });
  });
}
