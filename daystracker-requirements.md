# DaysTracker MVP - Complete Requirements Document

**Version:** 1.0.0  
**Date:** February 3, 2026  
**Target:** AI Agent (Cursor/Windsurf) Implementation

---

## 📋 Project Overview

**Project Name:** DaysTracker

**Description:** Privacy-first offline Flutter app that tracks days spent in countries and cities. Automatic hourly background location tracking + manual entry. All data stored locally in SQLite.

**Core Value Proposition:** Помагає користувачам відстежувати дні перебування в країнах для податкових/візових цілей (183-day rule, 90/180 Schengen rule, etc.)

**Target Platforms:** iOS, Android (Web - low priority)

---

## 🎯 MVP Scope

### ✅ IN SCOPE (v1.0)
- Manual visit CRUD (country, city, date range)
- Automatic hourly background location tracking
- Reverse geocoding (coordinates → city & country)
- SQLite database (NO encryption for MVP)
- Statistics with 2 day counting rules:
  - **Any Presence** - будь-який ping в день = день counted
  - **Two Or More Pings** - ≥2 pings в день = день counted
- 4 view modes для Visits list
- 4 view modes для Statistics (including calendar)
- Time period filters (7d, 31d, 183d, 365d, all time)
- Settings (background toggle, day counting rule)
- Data export/import (JSON)
- English localization only

### ⏳ PHASE 2 (v1.1+)
- Map visualization (Mapbox)
- Home widget
- Overnight-only counting rule
- Visit merge UI
- CSV export
- PDF reports
- Ukrainian localization
- Advanced statistics (trends, charts)

### ❌ OUT OF SCOPE
- Cloud sync
- Social features
- Push notifications
- Multiple users/accounts
- Database encryption (v1.0)

---

## 🏗️ Tech Stack

```yaml
# Core
Flutter SDK: ">=3.19.0"
Dart: ">=3.3.0"

# Architecture
State Management: flutter_bloc (^8.1.4)
Dependency Injection: get_it (^7.6.7) + injectable (^2.3.2)
Navigation: auto_route (^7.8.4)

# Data Models
Domain Entities: Plain Dart classes + copyWith + equatable
BLoC Events/States: freezed (^2.4.7) + freezed_annotation (^2.4.1)

# Database
Database: drift (^2.14.1) - SQLite with type-safe queries
sqlite3_flutter_libs: ^0.5.20
path_provider: ^2.1.2
# NO encryption for MVP

# Location & Background
geolocator: ^11.0.0
geocoding: ^2.1.1 (fallback only)
workmanager: ^0.5.2 (Android background)
background_fetch: ^1.2.1 (iOS background)

# Geocoding API
Google Maps Geocoding API (reverse geocoding + places autocomplete)

# Utils
uuid: ^4.3.3
intl: ^0.18.1
http: ^1.2.0
logger: ^2.0.2
equatable: ^2.0.5
json_annotation: ^4.8.1

# Dev Dependencies
build_runner: ^2.4.8
drift_dev: ^2.14.1
injectable_generator: ^2.4.1
json_serializable: ^6.7.1
auto_route_generator: ^7.3.2
mockito: ^5.4.4
bloc_test: ^9.1.5
```

---

## 🗄️ Database Schema (SQLite via Drift)

### Table: `countries`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | Auto ID |
| country_code | TEXT(2) | NOT NULL, UNIQUE | ISO alpha-2 (PL, UA, DE) |
| country_name | TEXT | NOT NULL | English name (Poland, Ukraine) |
| total_days | INTEGER | DEFAULT 0 | Cached total days (recalculated) |
| first_visit_date | INTEGER | NULLABLE | Unix timestamp |
| last_visit_date | INTEGER | NULLABLE | Unix timestamp |
| created_at | INTEGER | NOT NULL | Unix timestamp |
| updated_at | INTEGER | NOT NULL | Unix timestamp |

**Indexes:**
- `idx_country_code` on `country_code`

---

### Table: `cities`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | Auto ID |
| country_id | INTEGER | NOT NULL, FK(countries.id) CASCADE | Parent country |
| city_name | TEXT | NOT NULL | English name (Warsaw, Kyiv) |
| latitude | REAL | NOT NULL | Canonical city center (from Google) |
| longitude | REAL | NOT NULL | Canonical city center |
| total_days | INTEGER | DEFAULT 0 | Cached total days |
| created_at | INTEGER | NOT NULL | Unix timestamp |
| updated_at | INTEGER | NOT NULL | Unix timestamp |

**Unique Constraint:** `(country_id, city_name)`

**Indexes:**
- `idx_city_country` on `country_id`
- `idx_city_location` on `(latitude, longitude)`

---

### Table: `visits`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | TEXT | PRIMARY KEY | UUID |
| city_id | INTEGER | NOT NULL, FK(cities.id) CASCADE | City visited |
| start_date | INTEGER | NOT NULL | Unix timestamp (UTC) |
| end_date | INTEGER | NULLABLE | Unix timestamp, NULL if active |
| is_active | INTEGER | NOT NULL, DEFAULT 0 | Boolean: 1=ongoing, 0=closed |
| source | TEXT | NOT NULL | 'manual' or 'auto' |
| user_latitude | REAL | NULLABLE | User's actual location (if available) |
| user_longitude | REAL | NULLABLE | User's actual location |
| last_updated | INTEGER | NOT NULL | Unix timestamp (last ping for auto) |
| created_at | INTEGER | NOT NULL | Unix timestamp |

**Indexes:**
- `idx_visit_city` on `city_id`
- `idx_visit_dates` on `(start_date, end_date)`
- `idx_visit_active` on `is_active`

---

### Table: `location_pings`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | TEXT | PRIMARY KEY | UUID |
| visit_id | TEXT | NULLABLE, FK(visits.id) SET NULL | Associated visit (NULL if pending) |
| timestamp | INTEGER | NOT NULL | Unix timestamp (UTC) |
| latitude | REAL | NOT NULL | Raw GPS coordinates |
| longitude | REAL | NOT NULL | Raw GPS coordinates |
| accuracy | REAL | NULLABLE | Meters |
| city_name | TEXT | NULLABLE | From geocoding (NULL if pending) |
| country_code | TEXT | NULLABLE | From geocoding |
| geocoding_status | TEXT | NOT NULL | 'success', 'pending', 'failed' |
| retry_count | INTEGER | DEFAULT 0 | Failed geocoding retry attempts |
| created_at | INTEGER | NOT NULL | Unix timestamp |

**Indexes:**
- `idx_ping_status` on `geocoding_status`
- `idx_ping_timestamp` on `timestamp`

---

### Table: `daily_presence`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | Auto ID |
| visit_id | TEXT | NOT NULL, FK(visits.id) CASCADE | Parent visit |
| date | TEXT | NOT NULL | YYYY-MM-DD format |
| city_id | INTEGER | NOT NULL, FK(cities.id) | City on that day |
| country_id | INTEGER | NOT NULL, FK(countries.id) | Country on that day |
| ping_count | INTEGER | DEFAULT 1 | Number of pings that day |
| meets_any_presence_rule | INTEGER | DEFAULT 1 | Boolean: always 1 |
| meets_two_or_more_pings_rule | INTEGER | DEFAULT 0 | Boolean: 1 if ping_count >= 2 |
| created_at | INTEGER | NOT NULL | Unix timestamp |
| updated_at | INTEGER | NOT NULL | Unix timestamp |

**Unique Constraint:** `(date, city_id)`

**Indexes:**
- `idx_daily_date` on `date`
- `idx_daily_country` on `country_id`
- `idx_daily_city` on `city_id`

**Purpose:** Денормалізована таблиця для швидкого підрахунку днів. Оновлюється при кожному ping.

---

## 📐 Domain Layer Architecture

### Domain Entities (Plain Classes)

**Location:** `lib/domain/entities/`

All entities use:
- Plain Dart classes (no annotations except Equatable)
- Immutable fields (`final`)
- `copyWith()` method
- `Equatable` for value equality
- NO JSON serialization (that's in data layer)

**Entities:**

1. **Country**
```
- int id
- String countryCode (ISO alpha-2)
- String countryName
- int totalDays
- DateTime? firstVisitDate
- DateTime? lastVisitDate
```

2. **City**
```
- int id
- int countryId
- String cityName
- double latitude (canonical)
- double longitude (canonical)
- int totalDays
- Country? country (navigation property, nullable)
```

3. **Visit**
```
- String id (UUID)
- int cityId
- DateTime startDate (UTC)
- DateTime? endDate (UTC, null if active)
- bool isActive
- VisitSource source (enum)
- double? userLatitude
- double? userLongitude
- DateTime lastUpdated (UTC)
- City? city (navigation property, nullable)
```

4. **LocationPing**
```
- String id (UUID)
- String? visitId
- DateTime timestamp (UTC)
- double latitude
- double longitude
- double? accuracy
- String? cityName
- String? countryCode
- GeocodingStatus geocodingStatus (enum)
- int retryCount
```

5. **DailyPresence**
```
- int id
- String visitId
- String date (YYYY-MM-DD)
- int cityId
- int countryId
- int pingCount
- bool meetsAnyPresenceRule
- bool meetsTwoOrMorePingsRule
- City? city (nullable)
- Country? country (nullable)
```

6. **StatisticsSummary**
```
- List<CountryStats> countries
- int totalDays
- int totalCountries
- int totalCities
- DateTime periodStart
- DateTime periodEnd
```

7. **CountryStats**
```
- Country country
- int days
- double percentage
- List<CityStats> cities
```

8. **CityStats**
```
- City city
- int days
- double percentage
```

9. **DayDetails** (для calendar day modal)
```
- DateTime date
- List<CountryPresence> countries
```

10. **CountryPresence**
```
- Country country
- List<CityPresence> cities
```

11. **CityPresence**
```
- City city
- int pingCount
- Visit? visit
```

---

### Domain Enums

**Location:** `lib/domain/enums/`

```dart
enum DayCountingRule {
  anyPresence,        // Будь-який ping = день рахується
  twoOrMorePings;     // ≥2 pings = день рахується
}

enum VisitSource {
  manual,   // User manually added
  auto;     // Auto-tracked from background
}

enum GeocodingStatus {
  success,   // Successfully geocoded
  pending,   // Waiting for geocoding
  failed;    // Failed after retries
}

enum StatisticsViewMode {
  calendar,           // Calendar grid with flags
  chronological,      // Sorted by date (newest first)
  groupedByCountry,   // Grouped by country with expandable cities
  periodSummary;      // Simple list with pie chart
}

enum TimePeriod {
  sevenDays,
  thirtyOneDays,
  oneHundredEightyThreeDays,
  threeHundredSixtyFiveDays,
  allTime;
  
  // Extension method: getDateRange() returns DateTimeRange
}

enum VisitsViewMode {
  chronological,      // Newest first
  groupedByCountry,   // Grouped by country
  activeFirst,        // Active visits on top
  monthGrouping;      // Grouped by month
}
```

---

### Domain Repositories (Abstract Interfaces)

**Location:** `lib/domain/repositories/`

**1. VisitsRepository**
```dart
abstract class VisitsRepository {
  Future<Either<Failure, List<Visit>>> getAllVisits();
  Future<Either<Failure, Visit>> getVisitById(String id);
  Future<Either<Failure, Visit?>> getActiveVisit();
  Future<Either<Failure, void>> createVisit(Visit visit);
  Future<Either<Failure, void>> updateVisit(Visit visit);
  Future<Either<Failure, void>> deleteVisit(String id);
  Future<Either<Failure, bool>> hasOverlap(Visit visit);
  Stream<List<Visit>> watchVisits();
}
```

**2. LocationRepository**
```dart
abstract class LocationRepository {
  Future<Either<Failure, Position>> getCurrentLocation();
  Future<Either<Failure, List<LocationPing>>> getPendingGeocoding();
  Future<Either<Failure, void>> savePing(LocationPing ping);
  Future<Either<Failure, void>> updatePingGeocodingStatus({
    required String pingId,
    required String cityName,
    required String countryCode,
    required GeocodingStatus status,
  });
}
```

**3. StatisticsRepository**
```dart
abstract class StatisticsRepository {
  Future<Either<Failure, StatisticsSummary>> getStatisticsSummary({
    required DateTime startDate,
    required DateTime endDate,
    required DayCountingRule rule,
  });
  
  Future<Either<Failure, Map<String, List<Country>>>> getDailyPresenceCalendar({
    required int year,
    required int month,
    required DayCountingRule rule,
  });
  
  Future<Either<Failure, DayDetails>> getDayDetails({
    required DateTime date,
    required DayCountingRule rule,
  });
  
  Future<Either<Failure, List<CountryStats>>> getCountryStats({
    required DateTime startDate,
    required DateTime endDate,
    required DayCountingRule rule,
  });
}
```

**4. SettingsRepository**
```dart
abstract class SettingsRepository {
  Future<Either<Failure, DayCountingRule>> getDayCountingRule();
  Future<Either<Failure, void>> setDayCountingRule(DayCountingRule rule);
  
  Future<Either<Failure, bool>> getBackgroundTrackingEnabled();
  Future<Either<Failure, void>> setBackgroundTrackingEnabled(bool enabled);
  
  Future<Either<Failure, String?>> getGoogleMapsApiKey();
  Future<Either<Failure, void>> setGoogleMapsApiKey(String key);
}
```

---

### Domain Use Cases

**Location:** `lib/domain/usecases/`

**Principle:** One use case = one action. Use case orchestrates repository calls.

**Pattern:**
```dart
class UseCaseName {
  final SomeRepository _repository;
  
  UseCaseName(this._repository);
  
  Future<Either<Failure, Result>> call(Params params) async {
    // Business logic here
    return await _repository.someMethod();
  }
}
```

**Use Cases to Implement:**

**Visits:**
- `GetAllVisits`
- `GetVisitById`
- `CreateVisit` (includes overlap validation)
- `UpdateVisit`
- `DeleteVisit`
- `ValidateVisitOverlap`

**Location:**
- `GetCurrentLocation`
- `ProcessLocationPing` (main background logic)
- `RetryFailedGeocoding`

**Geocoding:**
- `ReverseGeocodeLocation`
- `SearchCities` (for autocomplete)

**Statistics:**
- `CalculateCountryDays`
- `CalculateCityDays`
- `GetDailyPresenceCalendar`
- `GetStatisticsSummary`
- `GetDayDetails`

---

### Domain Failures

**Location:** `lib/core/error/failures.dart`

```dart
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({required String message}) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message);
}

class GeocodingFailure extends Failure {
  const GeocodingFailure({required String message}) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure({required String message}) : super(message);
}

class PermissionFailure extends Failure {
  const PermissionFailure({required String message}) : super(message);
}

class LocationFailure extends Failure {
  const LocationFailure({required String message}) : super(message);
}

class StorageFailure extends Failure {
  const StorageFailure({required String message}) : super(message);
}
```

---

## 💾 Data Layer Architecture

### Data Models (Drift Tables)

**Location:** `lib/data/database/tables/`

Each table is Drift-annotated class. Example:

```dart
@DataClassName('CountryData')
class Countries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get countryCode => text().withLength(min: 2, max: 2).unique()();
  TextColumn get countryName => text()();
  IntColumn get totalDays => integer().withDefault(const Constant(0))();
  DateTimeColumn get firstVisitDate => dateTime().nullable()();
  DateTimeColumn get lastVisitDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

**Tables to implement:**
- `countries_table.dart` → CountryData
- `cities_table.dart` → CityData
- `visits_table.dart` → VisitData
- `location_pings_table.dart` → LocationPingData
- `daily_presence_table.dart` → DailyPresenceData

---

### DAOs (Data Access Objects)

**Location:** `lib/data/database/daos/`

**Principle:** One DAO per table. Pure CRUD + specific queries.

**Example methods:**

**CountriesDao:**
- `Future<List<CountryData>> getAll()`
- `Future<CountryData?> getById(int id)`
- `Future<CountryData?> getByCode(String code)`
- `Future<int> insert(CountryData country)`
- `Future<void> update(CountryData country)`
- `Future<void> delete(int id)`
- `Future<List<CountryData>> searchByName(String query)`

**CitiesDao:**
- `Future<CityData?> findNearestCity({required double lat, required double lon, required double radiusKm})`
- `Future<CityData?> findByName({required int countryId, required String cityName})`
- `Future<List<CityData>> searchByName(String query, {int limit = 10})`
- `Future<List<CityData>> getRecent({int limit = 20})`

**VisitsDao:**
- `Future<VisitData?> getActiveVisit()`
- `Future<bool> hasOverlap(DateTime start, DateTime? end, {String? excludeId})`
- `Stream<List<VisitData>> watchAll()`

**LocationPingsDao:**
- `Future<List<LocationPingData>> getPendingGeocoding()`
- `Future<void> updateGeocodingSuccess({required String pingId, required String city, required String country})`
- `Future<void> linkToVisit(String pingId, String visitId)`

**DailyPresenceDao:**
- `Future<List<DailyPresenceData>> getInDateRange({required String startDate, required String endDate})`
- `Future<DailyPresenceData?> findByDateAndCity(String date, int cityId)`
- `Future<void> incrementPingCount(int id)`

---

### Mappers

**Location:** `lib/data/mappers/`

**Pattern:**
```dart
extension CountryMapper on CountryData {
  Country toEntity() {
    return Country(
      id: id,
      countryCode: countryCode,
      countryName: countryName,
      totalDays: totalDays,
      firstVisitDate: firstVisitDate,
      lastVisitDate: lastVisitDate,
    );
  }
}

extension CountryEntityMapper on Country {
  CountryData toData() {
    return CountryData(
      id: id,
      countryCode: countryCode,
      countryName: countryName,
      totalDays: totalDays,
      firstVisitDate: firstVisitDate,
      lastVisitDate: lastVisitDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
```

**Mappers to implement:**
- `country_mapper.dart`
- `city_mapper.dart`
- `visit_mapper.dart`
- `location_ping_mapper.dart`
- `daily_presence_mapper.dart`

---

### Repository Implementations

**Location:** `lib/data/repositories/`

**Pattern:**
```dart
@LazySingleton(as: VisitsRepository)
class VisitsRepositoryImpl implements VisitsRepository {
  final VisitsDao _visitsDao;
  final CitiesDao _citiesDao;
  
  VisitsRepositoryImpl(this._visitsDao, this._citiesDao);
  
  @override
  Future<Either<Failure, List<Visit>>> getAllVisits() async {
    try {
      final data = await _visitsDao.getAll();
      return Right(data.map((d) => d.toEntity()).toList());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
  
  // ... other methods
}
```

**Implementations:**
- `visits_repository_impl.dart`
- `location_repository_impl.dart`
- `statistics_repository_impl.dart`
- `settings_repository_impl.dart`

---

### Core Services

**Location:** `lib/data/services/`

**1. GeocodingService**

**Purpose:** Convert lat/lon → City entity

**Dependencies:**
- `GoogleMapsApiDataSource`
- `CitiesDao`
- `CountriesDao`

**Key Methods:**
```dart
Future<Either<Failure, City>> reverseGeocode({
  required double latitude,
  required double longitude,
});

Future<void> retryFailedGeocoding();
```

**Logic:**
1. Check if nearby city exists in DB (within 50km radius)
2. If found → return from DB
3. If not → call Google Maps Geocoding API
4. Parse response → extract city name, country code, canonical lat/lon
5. Get or create Country in DB
6. Get or create City in DB with canonical coordinates
7. Return City entity

---

**2. LocationProcessingService**

**Purpose:** Process hourly location pings (main business logic)

**Dependencies:**
- `LocationPingsDao`
- `VisitsDao`
- `DailyPresenceDao`
- `GeocodingService`

**Key Method:**
```dart
Future<Either<Failure, void>> processLocationPing({
  required double latitude,
  required double longitude,
  required double accuracy,
});
```

**Logic:**
1. Generate UUID for ping
2. Save raw ping to DB immediately (status=pending)
3. Attempt reverse geocoding
   - If success → update ping with city/country
   - If failed → keep pending (retry later)
4. Get current active visit
5. Compare cities:
   - **Same city** → extend visit (update lastUpdated, keep endDate=null)
   - **Different city** → close previous visit (set endDate=lastUpdated), create new visit
6. Update DailyPresence table:
   - Check if record exists for (date, cityId)
   - If exists → increment pingCount, update meetsTwoOrMorePingsRule if needed
   - If not exists → create new record

---

**3. LocationService**

**Purpose:** Wrapper around geolocator package

**Key Methods:**
```dart
Future<Either<Failure, Position>> getCurrentPosition();
Future<Either<Failure, PermissionStatus>> requestPermission();
Future<Either<Failure, PermissionStatus>> checkPermission();
```

---

**4. CitySearchService**

**Purpose:** Autocomplete for manual visit entry

**Dependencies:**
- `CitiesDao`
- `GoogleMapsApiDataSource` (Places Autocomplete)

**Key Method:**
```dart
Future<Either<Failure, List<City>>> searchCities({
  required String query,
  int limit = 10,
});
```

**Logic:**
1. Search in local DB first (cities user has visited)
2. If not enough results → call Google Places Autocomplete API
3. Combine results (local first)
4. Return list of City objects

---

**5. BackgroundService**

**Purpose:** Register and manage hourly background tasks

**Dependencies:**
- `WorkManager` (Android)
- `BackgroundFetch` (iOS)
- `LocationService`
- `LocationProcessingService`

**Key Methods:**
```dart
Future<void> startTracking();
Future<void> stopTracking();
```

**Android Implementation (WorkManager):**
- Register periodic task (1-hour interval)
- Task runs in background isolate
- Task callback:
  1. Get current location
  2. Call LocationProcessingService.processLocationPing()
  3. Return success/failure

**iOS Implementation (BackgroundFetch):**
- Register background fetch (1-hour minimum interval)
- iOS may throttle → document limitations
- Fallback: Significant Location Change (500m movement)
- Same callback logic as Android

---

### External Data Sources

**Location:** `lib/data/datasources/`

**GoogleMapsApiDataSource**

**Purpose:** HTTP calls to Google Maps APIs

**Methods:**
```dart
Future<Either<Failure, GeocodingResult>> reverseGeocode({
  required double latitude,
  required double longitude,
});

Future<Either<Failure, List<PlaceResult>>> searchPlaces({
  required String query,
  int limit = 10,
});
```

**API Endpoints:**
- Reverse Geocoding: `https://maps.googleapis.com/maps/api/geocode/json?latlng={lat},{lng}&key={API_KEY}`
- Places Autocomplete: `https://maps.googleapis.com/maps/api/place/autocomplete/json?input={query}&key={API_KEY}`

**Response Parsing:**
- Extract: city name (locality), country code (country short_name), canonical coordinates (geometry.location)
- Handle errors gracefully (return Failure)

---

## 🎨 Presentation Layer Architecture

### BLoC Pattern

**Location:** `lib/presentation/features/{feature}/bloc/`

**Structure for each feature:**
- `{feature}_bloc.dart` - BLoC logic
- `{feature}_event.dart` - Events (freezed)
- `{feature}_state.dart` - States (freezed)

**Example:**

```dart
// visits_event.dart
@freezed
class VisitsEvent with _$VisitsEvent {
  const factory VisitsEvent.started() = _Started;
  const factory VisitsEvent.loadVisits() = _LoadVisits;
  const factory VisitsEvent.createVisit(Visit visit) = _CreateVisit;
  const factory VisitsEvent.updateVisit(Visit visit) = _UpdateVisit;
  const factory VisitsEvent.deleteVisit(String id) = _DeleteVisit;
  const factory VisitsEvent.refreshVisits() = _RefreshVisits;
}

// visits_state.dart
@freezed
class VisitsState with _$VisitsState {
  const factory VisitsState.initial() = _Initial;
  const factory VisitsState.loading() = _Loading;
  const factory VisitsState.loaded(List<Visit> visits) = _Loaded;
  const factory VisitsState.error(String message) = _Error;
}
```

---

### Features & Screens

**Location:** `lib/presentation/features/`

**Feature 1: Visits**

**Screens:**
- `visits_screen.dart` (@RoutePage) - Main list screen
- `add_visit_screen.dart` (@RoutePage) - Full-screen form
- `edit_visit_screen.dart` (@RoutePage) - Edit form
- `visit_details_screen.dart` (@RoutePage) - View single visit

**Visits Screen Requirements:**

**View Modes (tabs/segmented control):**
1. **Chronological** - sorted by startDate descending (newest first)
2. **Grouped by Country** - expandable sections per country
3. **Active First** - active visits pinned at top, then chronological
4. **Month Grouping** - grouped by month (e.g., "February 2026", "January 2026")

**UI Elements:**
- Floating "+" button (bottom-right) → Add Visit Screen
- No search, no filters (per requirement)
- Pull-to-refresh
- Empty state: "No visits yet. Track your travels automatically or add manually."

**List Item Design:**
- Country flag emoji (🇵🇱)
- City name + Country name
- Date range ("Jan 15 - Jan 28" or "Active since Jan 15")
- Days count badge
- Source indicator (manual icon or auto icon)
- Tap → Visit Details Screen
- Swipe left → Delete (with confirmation)

---

**Add/Edit Visit Screen Requirements:**

**Form Fields:**
1. **Country Picker** (required)
   - Dropdown with search
   - Show flag + country name
   - Sorted alphabetically
   - Use all world countries (from predefined list or API)

2. **City Autocomplete** (required)
   - Text field with async search
   - Use CitySearchService
   - Show suggestions from DB first, then Google Places
   - Format: "City, Country"
   - Allow custom entry (save with warning if geocoding fails)

3. **Date Range Picker** (required)
   - Start Date (required)
   - End Date (optional - leave empty for active visit)
   - Use calendar picker
   - Validate: startDate <= endDate
   - Validate: no overlap with other visits

4. **"Use Current Location" Button**
   - Get current position
   - Auto-fill country & city via reverse geocoding
   - Show loading indicator

5. **Save Button**
   - Validate all fields
   - Check overlap (strict - block if overlaps)
   - Show error message if validation fails
   - On success → navigate back + show snackbar

**Overlap Validation:**
- Error message: "This visit overlaps with existing visit: [City, Country] from [Date] to [Date]"
- Do NOT allow save if overlap detected

---

**Feature 2: Statistics**

**Screen:**
- `statistics_screen.dart` (@RoutePage)

**Statistics Screen Requirements:**

**Top Section:**
- **Time Period Selector** (dropdown)
  - Options: "7 days", "31 days", "183 days", "365 days", "All time"
  - Default: "183 days"
  - On change → reload data

- **Day Counting Rule** (info icon + setting)
  - Show current rule in subtitle
  - Tap → bottom sheet or navigate to Settings
  - Options: "Any presence" or "2+ pings per day"

**View Modes (tabs/segmented control):**

1. **Calendar View** (PRIMARY - like screenshot)
   - Month/year selector (< January 2026 >)
   - 7-column grid (MON-SUN)
   - Each cell shows:
     - Day number (e.g., "24")
     - Country flags (up to 3 flags, if >3 show "...")
     - Current day highlighted (blue background)
   - Tap cell → DayDetailsModal (bottom sheet)
   
2. **Chronological List**
   - Simple list sorted by date (newest first)
   - Show: Date, Countries visited, Cities visited, Total days
   
3. **Grouped by Country**
   - Expandable list
   - Section header: Country flag + name + days count
   - Expanded: Cities within country + days per city
   
4. **Period Summary** (DEFAULT VIEW)
   - List of countries with days count + percentage
   - Simple pie chart (top 5 countries)
   - Total: "You spent X days in Y countries"
   - NO "Days Remaining" counter (per requirement)

**DayDetailsModal (bottom sheet):**
- Date header: "January 24, 2026"
- List countries present that day
- For each country, list cities
- For each city, show ping count
- Button: "Add/Edit Visit" (navigate to Add Visit Screen with date pre-filled)

---

**Feature 3: Settings**

**Screen:**
- `settings_screen.dart` (@RoutePage)

**Settings Screen Requirements:**

**Section 1: Location Tracking**
- Toggle: "Background Tracking" (on/off)
  - Subtitle: "Track location hourly in background"
  - When enabled → request "Always" permission
  - When disabled → stop background tasks
- Permission status indicator:
  - "Location Permission: Always" (green check)
  - "Location Permission: When In Use" (yellow warning + "Upgrade" button)
  - "Location Permission: Denied" (red error + "Open Settings" button)
- Button: "Test Location Now" (get current position + show on map or coordinates)

**Section 2: Preferences**
- Segmented Control: "Day Counting Rule"
  - Option 1: "Any Presence"
  - Option 2: "2+ Pings"
  - On change → reload statistics immediately

**Section 3: Data Management**
- Button: "Export Data" (JSON)
  - Show file picker
  - Save to Downloads folder
  - Show success snackbar with file path
- Button: "Import Data" (JSON)
  - Show file picker
  - Validate JSON structure
  - Confirmation: "This will replace all existing data. Continue?"
  - Import + show success message
- Button: "Clear All Data" (destructive)
  - Confirmation dialog: "This will delete all visits, pings, and statistics. This cannot be undone."
  - Require double confirmation
  - On confirm → truncate all tables + show success

**Section 4: API Configuration**
- Text field: "Google Maps API Key"
  - Secure input (obscured)
  - Save to flutter_secure_storage
  - Validate on save (test API call)

**Section 5: About**
- App version
- Privacy notice: "All data stored locally. No cloud sync."
- Link: "GitHub Repository" (open in browser)

---

### Common Widgets

**Location:** `lib/presentation/common/widgets/`

**Widgets to implement:**
- `country_flag_widget.dart` - Emoji flag from country code
- `loading_indicator.dart` - Centered CircularProgressIndicator
- `error_widget.dart` - Error message + retry button
- `empty_state_widget.dart` - Icon + message + CTA button
- `confirmation_dialog.dart` - Reusable confirmation dialog
- `date_range_picker_field.dart` - Text field + calendar picker
- `country_picker_dropdown.dart` - Searchable dropdown
- `city_autocomplete_field.dart` - Async search text field

---

### Navigation

**Location:** `lib/presentation/navigation/`

**app_router.dart** (AutoRoute config)

**Routes:**
- `/` → Bottom Navigation Shell
  - `/visits` → VisitsScreen
  - `/statistics` → StatisticsScreen
  - `/settings` → SettingsScreen
- `/visits/add` → AddVisitScreen
- `/visits/:id/edit` → EditVisitScreen
- `/visits/:id` → VisitDetailsScreen

**Bottom Navigation:**
- 3 tabs: Visits, Statistics, Settings
- Icons: location_on, bar_chart, settings
- Persistent bottom bar

---

## 🔧 Core Utilities

**Location:** `lib/core/utils/`

**date_utils.dart**
- `String formatDateRange(DateTime start, DateTime? end)` - "Jan 15 - Jan 28" or "Active since Jan 15"
- `String formatDate(DateTime date)` - "YYYY-MM-DD"
- `int calculateDays(DateTime start, DateTime end)` - Calendar days between dates
- `bool isInDateRange(DateTime date, DateTime start, DateTime end)`

**location_utils.dart**
- `double calculateDistance(double lat1, double lon1, double lat2, double lon2)` - Haversine formula (km)
- `bool isWithinRadius(double lat1, double lon1, double lat2, double lon2, double radiusKm)`

**country_flag_utils.dart**
- `String getCountryFlag(String countryCode)` - Convert "PL" → "🇵🇱" (Unicode)

**constants.dart**
- `const double NEARBY_CITY_RADIUS_KM = 50.0`
- `const int MAX_GEOCODING_RETRIES = 3`
- `const Duration BACKGROUND_FETCH_INTERVAL = Duration(hours: 1)`
- `const String APP_VERSION = "1.0.0"`

---

## 🧪 Testing Strategy

### Unit Tests (80%+ coverage required)

**Priority Areas:**

**1. Domain Layer (HIGHEST PRIORITY)**
- All use cases
- Day counting algorithms
- Overlap validation logic
- Date range calculations
- Statistics calculations

**2. Data Layer**
- Repository implementations (mock DAOs)
- GeocodingService (mock API)
- LocationProcessingService (integration test with real DB)
- Mappers (toEntity / toData)

**3. Presentation Layer (BLoCs)**
- State transitions
- Event handling
- Error handling
- Use `bloc_test` package

---

### Integration Tests

**Focus Areas:**
- Database operations (full CRUD cycles)
- Background ping processing (simulate ping → verify DB state)
- Statistics calculation (insert test data → verify calculations)

**Skip:** Widget tests for MVP (low priority)

---

### Manual Testing

**Critical Flows:**
1. Add manual visit → verify in list
2. Add overlapping visit → verify blocked
3. Enable background tracking → simulate location change → verify auto visit created
4. View statistics in all 4 modes → verify correct data
5. Change day counting rule → verify stats update
6. Export data → verify JSON valid → import → verify data restored
7. Delete visit → verify daily_presence cleaned up

**Background Testing:**
- **Android:** `adb shell cmd jobscheduler run -f com.yourpackage 999`
- **iOS:** Xcode → Debug → Simulate Background Fetch

---

## 📱 Platform Configuration

### Android

**File:** `android/app/src/main/AndroidManifest.xml`

**Required Permissions:**
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

**WorkManager Service:**
```xml
<service
    android:name="be.tramckrijte.workmanager.WorkmanagerBackgroundService"
    android:permission="android.permission.BIND_JOB_SERVICE"
    android:exported="true" />
```

---

### iOS

**File:** `ios/Runner/Info.plist`

**Required Keys:**
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to track which countries and cities you visit.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need background location access to automatically track your visits hourly.</string>

<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>fetch</string>
</array>
```

**Minimum iOS Version:** 13.0

---

## 📦 Data Export/Import Format

### Export JSON Structure

```json
{
  "version": "1.0.0",
  "exported_at": "2026-02-03T22:00:00.000Z",
  "app_version": "1.0.0",
  "data": {
    "countries": [
      {
        "id": 1,
        "country_code": "PL",
        "country_name": "Poland",
        "total_days": 156,
        "first_visit_date": "2025-08-01T00:00:00.000Z",
        "last_visit_date": "2026-02-03T00:00:00.000Z"
      }
    ],
    "cities": [
      {
        "id": 1,
        "country_id": 1,
        "city_name": "Warsaw",
        "latitude": 52.2297,
        "longitude": 21.0122,
        "total_days": 89
      }
    ],
    "visits": [
      {
        "id": "uuid-1",
        "city_id": 1,
        "start_date": "2026-01-15T00:00:00.000Z",
        "end_date": "2026-01-28T00:00:00.000Z",
        "is_active": false,
        "source": "manual",
        "user_latitude": null,
        "user_longitude": null,
        "last_updated": "2026-01-28T00:00:00.000Z"
      }
    ],
    "location_pings": [],
    "daily_presence": []
  }
}
```

---

## ✅ Success Criteria for MVP

**MVP is ready when:**

✅ **Core Functionality:**
- User can manually add visits (country + city + dates)
- App tracks location hourly in background
- Geocoding works (Google Maps API)
- Statistics show correct days per country/city
- Both day counting rules work correctly
- Overlap validation prevents conflicts

✅ **UI/UX:**
- Calendar view shows country flags (like screenshot)
- All 4 view modes work (Visits + Statistics)
- Time period selector works (7d/31d/183d/365d/all)
- Settings screen functional (toggles + API key + export/import)

✅ **Quality:**
- Tests passing (80%+ domain layer coverage)
- No critical bugs
- Background tracking works on iOS & Android
- Performance acceptable (500+ visits)

✅ **Documentation:**
- README with setup instructions
- Background setup documented
- Known limitations documented

---

## 🎯 Important Notes for AI Agent

### Architecture Rules
1. **Clean Architecture** - strict separation of layers
2. **Single Responsibility** - each class does ONE thing
3. **Dependency Rule** - domain never depends on data/presentation
4. **Repository Pattern** - abstract interfaces in domain, implementations in data
5. **Use Case Pattern** - one use case = one action

### Code Style
1. **No freezed for entities** - only plain classes + copyWith + equatable
2. **Freezed ONLY for BLoC events/states**
3. **NO encryption** for MVP (SQLite only)
4. **UTC everywhere** - all DateTime stored as UTC
5. **English only** - variable names, comments, UI text

### Critical Logic
1. **Overlap validation** - MUST block overlapping visits (strict)
2. **Active visit handling** - only ONE active visit at a time
3. **Daily presence updates** - increment ping count, update rules
4. **Geocoding retry** - max 3 attempts, then mark failed
5. **City matching** - 50km radius for "same city"

### Testing Priorities
1. **Highest:** Domain use cases (day counting, overlap validation)
2. **High:** Repository implementations, GeocodingService, LocationProcessingService
3. **Medium:** BLoCs (state transitions)
4. **Low:** UI widgets (skip for MVP)

### Performance Targets
- Calendar render: <500ms (500 visits)
- Statistics calculation: <1s (365 days)
- Background ping processing: <5s
- Database queries: <100ms

### Known Limitations (Document in README)
1. **iOS Background:** May not always run hourly (iOS throttling)
2. **Geocoding:** Requires internet; offline = pending pings
3. **Battery Impact:** Hourly location checks drain battery
4. **Accuracy:** GPS accuracy varies (15-50m typical)

---

**READY TO START IMPLEMENTATION!** 🚀