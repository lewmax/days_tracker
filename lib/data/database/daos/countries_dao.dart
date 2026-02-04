import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/data/database/tables/countries_table.dart';
import 'package:drift/drift.dart';

part 'countries_dao.g.dart';

/// Data Access Object for countries table.
///
/// Provides CRUD operations and specific queries for countries.
@DriftAccessor(tables: [Countries])
class CountriesDao extends DatabaseAccessor<AppDatabase> with _$CountriesDaoMixin {
  CountriesDao(super.db);

  /// Gets all countries ordered by name.
  Future<List<CountryData>> getAll() {
    return (select(countries)..orderBy([(c) => OrderingTerm.asc(c.countryName)])).get();
  }

  /// Gets a country by its ID.
  Future<CountryData?> getById(int id) {
    return (select(countries)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  /// Gets a country by its ISO code.
  Future<CountryData?> getByCode(String code) {
    return (select(
      countries,
    )..where((c) => c.countryCode.equals(code.toUpperCase()))).getSingleOrNull();
  }

  /// Inserts a new country and returns its ID.
  Future<int> insertCountry(CountriesCompanion country) {
    return into(countries).insert(country);
  }

  /// Updates an existing country.
  Future<bool> updateCountry(CountryData country) {
    return update(countries).replace(country);
  }

  /// Deletes a country by ID.
  /// This will cascade delete all associated cities and visits.
  Future<int> deleteById(int id) {
    return (delete(countries)..where((c) => c.id.equals(id))).go();
  }

  /// Searches countries by name (case-insensitive).
  Future<List<CountryData>> searchByName(String query) {
    return (select(countries)
          ..where((c) => c.countryName.lower().like('%${query.toLowerCase()}%'))
          ..orderBy([(c) => OrderingTerm.asc(c.countryName)])
          ..limit(20))
        .get();
  }

  /// Gets countries with visits in a date range.
  Future<List<CountryData>> getCountriesWithVisits() {
    return (select(countries)..where((c) => c.totalDays.isBiggerThanValue(0))).get();
  }

  /// Updates the total days for a country.
  Future<void> updateTotalDays(int id, int totalDays) {
    return (update(countries)..where((c) => c.id.equals(id))).write(
      CountriesCompanion(totalDays: Value(totalDays), updatedAt: Value(DateTime.now().toUtc())),
    );
  }

  /// Updates the visit dates for a country.
  Future<void> updateVisitDates(int id, {DateTime? firstVisitDate, DateTime? lastVisitDate}) {
    return (update(countries)..where((c) => c.id.equals(id))).write(
      CountriesCompanion(
        firstVisitDate: Value(firstVisitDate),
        lastVisitDate: Value(lastVisitDate),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Watches all countries for changes.
  Stream<List<CountryData>> watchAll() {
    return (select(countries)..orderBy([(c) => OrderingTerm.asc(c.countryName)])).watch();
  }

  /// Gets or creates a country by code.
  /// Returns the existing country or creates a new one.
  Future<CountryData> getOrCreate({
    required String countryCode,
    required String countryName,
  }) async {
    final existing = await getByCode(countryCode);
    if (existing != null) {
      return existing;
    }

    final now = DateTime.now().toUtc();
    final id = await insertCountry(
      CountriesCompanion.insert(
        countryCode: countryCode.toUpperCase(),
        countryName: countryName,
        createdAt: now,
        updatedAt: now,
      ),
    );

    return (await getById(id))!;
  }
}
