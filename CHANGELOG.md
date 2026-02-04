# Changelog

All notable changes to DaysTracker are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.0.0] - 2026-02-03

### Added

- **Visits**
  - Manual add, edit, delete visits (country, city, date range).
  - Overlap validation and single active visit.
  - List view modes: Chronological, Grouped by country, Active first, Month grouping.
  - Visit details and edit screens.

- **Statistics**
  - Days per country and city.
  - Views: Calendar, Chronological, Grouped by country, Period summary.
  - Time periods: 7d, 31d, 183d, 365d, All time.
  - Day counting rules: Any presence, Two or more pings per day.

- **Background tracking**
  - Optional hourly location tracking (WorkManager on Android, Background Fetch on iOS).
  - Reverse geocoding via Google Maps Geocoding API.
  - Manual “Track now” from Settings.
  - Pending pings retried when online.

- **Settings**
  - Toggle background tracking.
  - Day counting rule selection.
  - Google Maps API key (stored securely).
  - Export data to JSON, import from file, clear all data.

- **Data**
  - SQLite database (Drift) with 5 tables: countries, cities, visits, location_pings, daily_presence.
  - JSON export/import for backup and restore.

- **Quality**
  - Clean Architecture (core, domain, data, presentation).
  - Unit tests for domain, core utils, and BLoCs (206 tests).
  - Accessibility: semantics and labels on main widgets.
  - Loading, error, and empty states on main screens.

### Known limitations

- iOS may throttle background execution.
- Geocoding requires internet.
- Database not encrypted in v1.0.
- English only.

---

## [Unreleased]

- Map visualization (Mapbox).
- Home widget.
- Overnight-only counting rule.
- Visit merge UI.
- CSV export, PDF reports.
- Ukrainian localization.
