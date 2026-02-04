import 'package:days_tracker/core/constants/app_constants.dart';
import 'package:days_tracker/core/utils/location_utils.dart';
import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/data/database/tables/cities_table.dart';
import 'package:days_tracker/data/database/tables/countries_table.dart';
import 'package:drift/drift.dart';

part 'cities_dao.g.dart';

/// Data Access Object for cities table.
///
/// Provides CRUD operations and specific queries for cities.
@DriftAccessor(tables: [Cities, Countries])
class CitiesDao extends DatabaseAccessor<AppDatabase> with _$CitiesDaoMixin {
  CitiesDao(super.db);

  /// Gets all cities ordered by name.
  Future<List<CityData>> getAll() {
    return (select(cities)..orderBy([(c) => OrderingTerm.asc(c.cityName)])).get();
  }

  /// Gets a city by its ID.
  Future<CityData?> getById(int id) {
    return (select(cities)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  /// Inserts a new city and returns its ID.
  Future<int> insertCity(CitiesCompanion city) {
    return into(cities).insert(city);
  }

  /// Updates an existing city.
  Future<bool> updateCity(CityData city) {
    return update(cities).replace(city);
  }

  /// Deletes a city by ID.
  /// This will cascade delete all associated visits.
  Future<int> deleteById(int id) {
    return (delete(cities)..where((c) => c.id.equals(id))).go();
  }

  /// Finds a city by name within a country.
  Future<CityData?> findByName({required int countryId, required String cityName}) {
    return (select(cities)..where(
          (c) => c.countryId.equals(countryId) & c.cityName.lower().equals(cityName.toLowerCase()),
        ))
        .getSingleOrNull();
  }

  /// Finds the nearest city within a radius.
  ///
  /// [lat] Latitude to search from.
  /// [lon] Longitude to search from.
  /// [radiusKm] Search radius in kilometers (default: 50km).
  /// Returns the nearest city or null if none found.
  Future<CityData?> findNearestCity({
    required double lat,
    required double lon,
    double radiusKm = AppConstants.nearbyCityRadiusKm,
  }) async {
    // Get all cities - for MVP this is acceptable
    // In production, use spatial indexing or bounding box queries
    final allCities = await getAll();

    CityData? nearestCity;
    double nearestDistance = radiusKm;

    for (final city in allCities) {
      final distance = LocationUtils.calculateDistance(lat, lon, city.latitude, city.longitude);

      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestCity = city;
      }
    }

    return nearestCity;
  }

  /// Searches cities by name (case-insensitive).
  Future<List<CityData>> searchByName(String query, {int limit = 10}) {
    return (select(cities)
          ..where((c) => c.cityName.lower().like('%${query.toLowerCase()}%'))
          ..orderBy([(c) => OrderingTerm.asc(c.cityName)])
          ..limit(limit))
        .get();
  }

  /// Gets cities for a specific country.
  Future<List<CityData>> getCitiesByCountry(int countryId) {
    return (select(cities)
          ..where((c) => c.countryId.equals(countryId))
          ..orderBy([(c) => OrderingTerm.asc(c.cityName)]))
        .get();
  }

  /// Gets recently visited cities.
  Future<List<CityData>> getRecent({int limit = AppConstants.recentCitiesLimit}) {
    return (select(cities)
          ..where((c) => c.totalDays.isBiggerThanValue(0))
          ..orderBy([(c) => OrderingTerm.desc(c.updatedAt)])
          ..limit(limit))
        .get();
  }

  /// Updates the total days for a city.
  Future<void> updateTotalDays(int id, int totalDays) {
    return (update(cities)..where((c) => c.id.equals(id))).write(
      CitiesCompanion(totalDays: Value(totalDays), updatedAt: Value(DateTime.now().toUtc())),
    );
  }

  /// Watches all cities for changes.
  Stream<List<CityData>> watchAll() {
    return (select(cities)..orderBy([(c) => OrderingTerm.asc(c.cityName)])).watch();
  }

  /// Gets or creates a city by name and country.
  Future<CityData> getOrCreate({
    required int countryId,
    required String cityName,
    required double latitude,
    required double longitude,
  }) async {
    final existing = await findByName(countryId: countryId, cityName: cityName);
    if (existing != null) {
      return existing;
    }

    final now = DateTime.now().toUtc();
    final id = await insertCity(
      CitiesCompanion.insert(
        countryId: countryId,
        cityName: cityName,
        latitude: latitude,
        longitude: longitude,
        createdAt: now,
        updatedAt: now,
      ),
    );

    return (await getById(id))!;
  }
}
