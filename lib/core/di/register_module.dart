import 'package:days_tracker/data/database/app_database.dart';
import 'package:days_tracker/data/database/daos/cities_dao.dart';
import 'package:days_tracker/data/database/daos/countries_dao.dart';
import 'package:days_tracker/data/database/daos/daily_presence_dao.dart';
import 'package:days_tracker/data/database/daos/location_pings_dao.dart';
import 'package:days_tracker/data/database/daos/visits_dao.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Module for registering third-party dependencies and singletons.
@module
abstract class RegisterModule {
  /// Provides SharedPreferences instance.
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  /// Provides FlutterSecureStorage instance.
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  /// Provides HTTP client.
  @lazySingleton
  http.Client get httpClient => http.Client();

  /// Provides UUID generator.
  @lazySingleton
  Uuid get uuid => const Uuid();

  /// Provides the database instance.
  @lazySingleton
  AppDatabase get database => AppDatabase();

  /// Provides CountriesDao.
  @lazySingleton
  CountriesDao countriesDao(AppDatabase db) => CountriesDao(db);

  /// Provides CitiesDao.
  @lazySingleton
  CitiesDao citiesDao(AppDatabase db) => CitiesDao(db);

  /// Provides VisitsDao.
  @lazySingleton
  VisitsDao visitsDao(AppDatabase db) => VisitsDao(db);

  /// Provides LocationPingsDao.
  @lazySingleton
  LocationPingsDao locationPingsDao(AppDatabase db) => LocationPingsDao(db);

  /// Provides DailyPresenceDao.
  @lazySingleton
  DailyPresenceDao dailyPresenceDao(AppDatabase db) => DailyPresenceDao(db);
}
