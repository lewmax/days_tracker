# DaysTracker

A **privacy-first, offline** Flutter app that tracks how many days you spend in each country and city. Built for tax and visa rules (e.g. 183-day rule, Schengen 90/180 days).

- **Manual visits:** Add country, city, and date range.
- **Automatic tracking:** Optional hourly background location with reverse geocoding.
- **Statistics:** Calendar and list views, time filters (7d–all time), two day-counting rules.
- **Export/Import:** JSON backup and restore.
- **English only** in v1.0.

---

## Features

- **Visits**
  - Add, edit, delete visits (country, city, start/end date).
  - Overlap validation (no overlapping visits).
  - One active (ongoing) visit at a time.
  - Four list modes: Chronological, Grouped by country, Active first, Month grouping.

- **Statistics**
  - Days per country and city.
  - Four views: Calendar, Chronological, Grouped by country, Period summary.
  - Time periods: 7d, 31d, 183d, 365d, All time.
  - Day counting rules: **Any presence** (1+ ping/day) or **Two or more pings** per day.

- **Background tracking (optional)**
  - Hourly location pings when enabled in Settings.
  - Reverse geocoding (Google Maps API) to resolve country/city.
  - Pending pings retried when online.

- **Settings**
  - Toggle background tracking.
  - Day counting rule.
  - Google Maps API key (required for geocoding).
  - Export data (JSON) / Import from file / Clear all data.

- **Data**
  - Stored locally in SQLite (Drift). No cloud sync. No encryption in MVP.

---

## Setup

### Prerequisites

- Flutter SDK **>=3.19.0** (Dart >=3.3.0)
- Optional: [FVM](https://fvm.app/) for Flutter version management

### Run the app

```bash
# Clone (or open) the project
cd country_tracker

# Install dependencies
flutter pub get
# or with FVM:
fvm flutter pub get

# Generate code (Drift, Injectable, Freezed, AutoRoute)
dart run build_runner build --delete-conflicting-outputs

# Run
flutter run
# or
fvm flutter run
```

### Google Maps API key (for geocoding)

1. Create a project in [Google Cloud Console](https://console.cloud.google.com/).
2. Enable **Geocoding API** and **Maps SDK for Android** / **Maps SDK for iOS** if needed.
3. Create an API key and restrict it (e.g. by app package/bundle ID).
4. In the app: **Settings → Google Maps API Key** and paste the key.

Without a key, automatic location pings will stay in “pending” until you add a key and retry.

---

## Background tracking setup

### Android

- **Permissions:** The app requests:
  - `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION`
  - `ACCESS_BACKGROUND_LOCATION` (for background tracking)
  - `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_LOCATION`, `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED`
- **Manifest:** Already configured in `android/app/src/main/AndroidManifest.xml` (permissions + foreground service + boot receiver).
- **WorkManager:** Used for the periodic location task. No extra setup.

### iOS

- **Info.plist:** Location usage descriptions and background modes are set in `ios/Runner/Info.plist`:
  - `NSLocationWhenInUseUsageDescription`
  - `NSLocationAlwaysAndWhenInUseUsageDescription`
  - `NSLocationAlwaysUsageDescription`
  - `UIBackgroundModes`: `location`, `fetch`, `processing`
  - `BGTaskSchedulerPermittedIdentifiers`: `com.daystracker.locationTracking`
- **Background execution:** iOS may throttle background fetch; hourly pings are not guaranteed.

---

## Architecture overview

Clean Architecture with three main layers:

```
lib/
├── core/         # DI, errors, constants, utils (no app/UI deps)
├── domain/       # Entities, repository interfaces, use cases
├── data/         # Repos impl, DAOs, services, datasources
└── presentation/ # BLoCs, screens, widgets, navigation
```

- **Domain:** Plain Dart entities (copyWith, Equatable), abstract repositories, use cases. No Flutter/Drift.
- **Data:** Drift (SQLite), DAOs, repository implementations, geocoding/location/background services.
- **Presentation:** flutter_bloc (freezed events/states), auto_route, shared widgets.

**Dependency rule:** `domain` ← `data` ← `presentation`.

---

## Known limitations

1. **iOS background:** System may throttle background execution; hourly pings are not guaranteed.
2. **Geocoding:** Requires internet. Offline pings stay “pending” until online and retried.
3. **Battery:** Hourly location checks can increase battery usage.
4. **Accuracy:** GPS accuracy varies (typically 15–50 m); city/country resolution depends on Google’s geocoding.
5. **No encryption:** SQLite database is not encrypted in v1.0.
6. **English only:** No localization in v1.0.

---

## Testing

- Unit tests: `flutter test`
- With coverage: `flutter test --coverage` (report in `coverage/lcov.info`)

See [TESTING.md](TESTING.md) for details.

---

## Future roadmap (v1.1+)

- Map view (e.g. Mapbox)
- Home / lock screen widget
- Overnight-only day counting rule
- Visit merge UI
- CSV export, PDF reports
- Ukrainian localization
- Richer statistics (trends, charts)

---

## License

Proprietary / none (see `publish_to: 'none'` in `pubspec.yaml`).
