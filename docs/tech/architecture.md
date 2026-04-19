# DaysTracker — Technical Architecture

> Authoritative technical reference for `lib/`. Layering and code rules in `.cursor/rules/daystracker-flutter-architecture.mdc` are binding; this file describes the **shape** of the app at a higher level (modules, navigation, repositories, background work, theming, testing).

## 1. Purpose & scope

- **Platforms:** iOS and Android, single Flutter codebase (`lib/`).
- **Posture:** offline-first, privacy-first, local-only storage. No mandatory account, no cloud sync, no analytics in MVP.
- **Hero job:** answer "where have I been and for how long?" fast and calmly.
- **Out of scope (architectural):** server backend, multi-device sync, push notifications, in-app purchases, telemetry pipelines.

## 2. Stack summary

| Concern | Choice | Notes |
|---|---|---|
| State management | `flutter_bloc` 9.x (BLoC + Cubit) | One BLoC per feature slice; `bloc_concurrency` for overlapping events. |
| DI | `get_it` 9.x + `injectable` 2.x | Repos as `@Injectable(as: Interface)`; BLoCs as `@injectable`. |
| Navigation | `auto_route` 11.x | Declarative routes; deep links not required in MVP. |
| Codegen unions | `freezed` 3.x | **Only** BLoC events/states/DTOs (per architecture rule). |
| JSON | `json_serializable` 6.x | Data layer only. |
| Functional errors | `dartz` (planned) | Repos return `Either<Failure, T>`. |
| Persistence | Drift (SQLite) (planned) | Behind repository interfaces. |
| Map renderer | **`mapbox_gl`** | Live tiles + country fills + city pins + clustering. |
| Geolocation | `geolocator`, `permission_handler` (planned) | In data adapters only. |
| Photo metadata | **TBD — open question** | See §16. |
| Background work | **TBD — open question** | See §16. |
| Localization | `flutter_localizations` + ARB | English-only MVP. |
| HTTP | `http` | Used for reference data fetch and reverse geocoding. |
| Logging | `logger` | Debug only; never logs PII. |

> Packages marked **planned** are not yet in `pubspec.yaml`. They are added by the Bootstrap Architect step (`/5-bootstrap-project`) per this spec.

## 3. Layering (Clean Architecture)

Defers to workspace rule `daystracker-flutter-architecture` (binding for `lib/**`).

```
presentation  →  domain  ←  data
   (BLoC, widgets,   (entities,    (repository impls,
    routing, theme)   interfaces,   Drift, HTTP, plugins,
                      pure rules)   DTOs, mappers)
```

- **Presentation** never imports concrete data types or DAOs.
- **Domain** has zero Flutter / IO imports.
- **Data** owns Drift, DTOs, plugins, and maps low-level errors → `Failure`.

## 4. Module map (`lib/` structure)

```
lib/
├── main.dart
├── app.dart                  # Root MaterialApp + auto_route + theme + DI bootstrap
├── core/
│   ├── di/                   # injectable config, GetIt setup
│   ├── error/                # Failure types, exception → failure mappers
│   ├── time/                 # UTC helpers, calendar-day arithmetic
│   ├── result/               # Either / Unit aliases
│   ├── logging/              # logger config
│   └── theme/                # ThemeData, ThemeExtension, design tokens
├── domain/
│   ├── countries/            # Country, Continent entities
│   ├── visits/               # Visit, VisitConfidence, VisitOrigin
│   ├── tracking/             # LocationPing, ConfirmationRequest, TrackingFrequency
│   ├── statistics/           # CountryStat, CityStat, ContinentStat, TopWeekResult, periods
│   ├── schengen/             # SchengenWindow, SchengenStatus, pure rules
│   ├── rewind/               # RewindSession, RewindEligibility rule
│   ├── import_export/        # ImportSession, ImportSuggestion, ImportSource
│   └── repositories/         # All abstract repository interfaces
├── data/
│   ├── db/                   # Drift database, DAOs, schema, migrations
│   ├── countries/            # ReferenceDataApi (HTTP) + cache + impl
│   ├── visits/               # VisitRepositoryImpl + DTOs + mappers
│   ├── tracking/             # Geolocator adapter, BackgroundTrackingRepositoryImpl
│   ├── geocoding/            # Reverse geocoding adapter (online)
│   ├── statistics/           # StatisticsRepositoryImpl (Drift queries)
│   ├── schengen/             # SchengenRepositoryImpl
│   ├── rewind/               # RewindRepositoryImpl
│   ├── import/               # JSON + photo metadata adapters
│   └── settings/             # SettingsRepositoryImpl (shared_preferences-equivalent)
└── presentation/
    ├── router/               # auto_route configuration + guards
    ├── shell/                # Bottom tab scaffold
    ├── onboarding/
    ├── timeline/
    ├── statistics/
    ├── map/
    ├── settings/
    ├── visits/               # Add/Edit Visit, Choose City
    ├── import/                # Import hub + photo flow
    ├── rewind/               # Year rewind + Rewinds history list
    ├── schengen/             # Schengen Detail screen
    └── shared/               # Reusable widgets (chips, country header, city row, FAB)
```

Each presentation feature folder owns its **BLoC**, **state**, **events**, **screens**, and **widgets**. Cross-feature shared widgets live in `presentation/shared/`.

## 5. Navigation (`auto_route`)

**Root shell** = bottom tab bar with four tabs (no Year Rewind tab):

- `TimelineRoute` → tab 1 (Calendar | Chronological mode toggle inside)
- `StatisticsRoute` → tab 2
- `MapRoute` → tab 3
- `SettingsRoute` → tab 4

**Secondary routes** (push on top of the active tab):

| Route | Entered from | Notes |
|---|---|---|
| `OnboardingRoute` | App launch when no completed onboarding | Modal-style, replaces shell until done. |
| `DayDetailRoute(date)` | `TimelineRoute` calendar day tap | Read-only day view with `+` to add visit pre-set to that day. |
| `VisitDetailRoute(visitId)` | `TimelineRoute` chronological city row tap | Edit dates only; city greyed. |
| `AddVisitRoute({date?})` | FAB on Timeline / `+` on Day Detail | Create flow; date pre-fixed when entered from Day Detail. |
| `ChooseCityRoute` | Add visit city field tap | Map + inline search; returns selected city. |
| `RewindRoute(year)` | `MapRoute` `Rewind {year}` button; `RewindsHistoryRoute` row | Playback + snap sheet. |
| `RewindsHistoryRoute` | `SettingsRoute` → Rewinds history row | Lists eligible completed years. |
| `CountryCitiesRoute(countryCode, period)` | `Statistics / Top countries` card tap | List of cities for that country in active period. |
| `ContinentDetailRoute(continentCode, period)` | `Statistics / Top continents` card tap | Country cards + nested city rows. |
| `SchengenDetailRoute` | `MapRoute` Schengen entry | Helper view; not on `Statistics`. |
| `ImportHubRoute` | `SettingsRoute` → Import data | JSON / photos branches. |
| `ImportPhotosRoute` | `ImportHubRoute` photos branch; Onboarding | Permission → Scanning → Results. |

**Rules:**
- Routing is owned by `presentation/router/`. `domain` and `data` never import `auto_route`.
- Tab switches preserve scroll/state per tab using `AutoTabsScaffold` semantics.
- `FAB / AddVisit` is a presentation overlay — not a router concern.

## 6. State management

- **One BLoC (or Cubit) per screen-level feature**. Examples: `TimelineBloc`, `StatisticsBloc`, `MapBloc`, `AddVisitBloc`, `ChooseCityBloc`, `ImportPhotosBloc`, `RewindBloc`, `BackgroundTrackingBloc`, `SchengenBloc`.
- Events and states are `freezed` unions. Loading / Success / Empty / Error are explicit states; no boolean flags muddled into a single state class.
- Long-running flows (photo import scan, background ping ingestion) use `bloc_concurrency`'s `restartable` or `droppable` to prevent overlap.
- BLoCs only depend on **domain repository interfaces** and pure helpers, injected via constructor by `injectable`.
- BLoCs `fold` `Either<Failure, T>` returned by repositories; user-visible messages are produced through l10n at the BLoC → UI boundary.

## 7. Repository contracts (interfaces in `domain/repositories/`)

| Interface | Responsibility |
|---|---|
| `VisitRepository` | CRUD visits; non-overlap enforcement; query by date range / city / country. |
| `LocationPingRepository` | Persist raw pings; query last N pings; purge after derivation. |
| `BackgroundTrackingRepository` | Toggle, frequency, current settings, schedule next ping; expose ping stream / poll. |
| `GeocodingRepository` | Reverse-geocode `(lat, lon)` → city + country (online); fail gracefully offline. |
| `ConfirmationRequestRepository` | Pending one-ping confirmations the user has to accept/dismiss. |
| `PhotoImportRepository` | Permission, scan, group photo locations into `ImportSuggestion`s. |
| `JsonImportExportRepository` | Read/write portable JSON; validate schema; merge / replace strategies. |
| `SettingsRepository` | Background tracking config, onboarding completion, last-seen rewind year. |
| `StatisticsRepository` | Aggregations: country/city/continent rankings, top week, period filters. |
| `RewindRepository` | List eligible completed years; load year route + chronological visits. |
| `SchengenRepository` | Compute days used / remaining / earliest re-entry over rolling 180-day window. |
| `ReferenceDataRepository` | Countries → continents map (fetched on app launch; cached for offline session). |

**All fallible methods return `Either<Failure, T>`**. Streams (`Stream<T>` for ping events, etc.) emit raw values; failures translate to BLoC error states via try/catch in the repo impl.

## 8. Background work

> **Open question.** The exact mechanism (`flutter_background_service`, `workmanager`, native isolate) is **not yet decided**. See §16. Whatever choice the Bootstrap Architect makes must satisfy the rules below.

- **Frequencies** allowed: `Off`, `1h`, `2h`, `4h`, `8h`, `12h`, `24h` (per brief).
- A **ping** = `(timestampUtc, lat, lon, accuracy, source)`.
- The background pipeline is owned by **data**: a tracking adapter wakes on schedule, writes a `LocationPing`, and triggers a derivation pass.
- **Visit derivation** rule (per brief): if a city appears in **≥2 pings**, the derivation creates a `Visit` (`origin = backgroundTracking`, `confidence = confirmed`). A **single** ping creates a `ConfirmationRequest` (`confidence = possible`) the user must accept or dismiss.
- Reverse geocoding runs **best-effort online**; if offline, the ping is stored without resolved city and the derivation retries on next online window. No silent loss.
- Background code never imports `presentation`. UI surfaces unresolved pings only when the foreground BLoC observes the repository.
- Battery & privacy: no continuous foreground location, no Bluetooth scanning, no advertising IDs. The user can disable tracking at any time without orphan state.

## 9. Persistence (Drift / SQLite)

Single local DB. Tables (initial sketch — owned by `domain_model.md`):

- `visits` — `id`, `cityId`, `countryCode`, `startUtc`, `endUtc`, `confidence`, `origin`, `notes?`, `createdAtUtc`, `updatedAtUtc`.
- `location_pings` — `id`, `timestampUtc`, `lat`, `lon`, `accuracy`, `resolvedCityId?`, `resolvedCountryCode?`, `processed`.
- `confirmation_requests` — `id`, `pingId`, `suggestedCityId`, `suggestedCountryCode`, `createdAtUtc`, `status`.
- `cities` — `id`, `name`, `countryCode`, `lat`, `lon` (populated on demand from geocoder).
- `settings` — single-row key-value (`tracking_enabled`, `tracking_frequency`, `onboarding_done`, `last_seen_rewind_year`).
- `reference_data_cache` — last-fetched countries → continents JSON + `fetchedAtUtc`.

Migrations run at app start before the first repository read. **No** schema changes inside repositories at runtime.

## 10. Errors and `Failure`

Sealed `Failure` hierarchy (in `core/error/`):

- `NetworkFailure` (offline, timeout, HTTP error)
- `GeocodingFailure` (no result, rate limit, network)
- `PermissionFailure` (location, photos)
- `StorageFailure` (DB read/write, migration)
- `ValidationFailure` (overlap, bad date range, missing city)
- `NotFoundFailure` (entity by id)
- `ConflictFailure` (visit overlap, JSON import collision)
- `UnexpectedFailure` (catch-all with cause for diagnostics)

Repositories **map** caught exceptions to a `Failure` and **never throw across the layer boundary**. BLoCs translate `Failure` codes to localized messages.

## 11. Time and timezone

- `DateTime` in **domain** and **data** is **UTC**. Field names use the `Utc` suffix when ambiguity is possible (`startUtc`, `endUtc`, `timestampUtc`).
- Conversion to local time happens **only** in presentation, near formatters and pickers.
- **Calendar-day semantics** are **inclusive** on both ends. A visit `{startUtc: 2025-03-05T00:00Z, endUtc: 2025-03-05T00:00Z}` counts as **1 day**.
- Calendar-day boundaries for statistics use the **device local calendar** (per brief: Year Rewind `Y` unlocks on `1 January Y+1` **local**).
- Schengen rolling windows and "Last 183 days" use **UTC midnight** boundaries to keep math reproducible regardless of travel.

## 12. Internationalization

- ARB files under `lib/l10n/` with generated `S` class (Flutter's built-in l10n).
- **English-only** in MVP. Adding a locale is mechanical (add ARB, regenerate).
- No hardcoded user-visible strings in widgets. Debug strings in `logger` calls may stay English regardless of locale.
- Number / date formatting goes through `intl` and respects device locale even when copy is English-only.

## 13. Theming and design tokens

- Single `ThemeData` + a `DaysTrackerTokens extends ThemeExtension` carrying colours, spacing, radii, typography sizes.
- Token names mirror Penpot `01 – Tokens`: `surface.base`, `surface.card`, `surface.elevated`, `onSurface.{primary,secondary,disabled}`, `primary`, `primary.muted`, `onPrimary`, `secondary`, `secondary.muted`, `success`, `warning`, `error`, `safe`, `caution`, `over`.
- Spacing / radii / typography tokens are **not yet present** in Penpot — added during Bootstrap with sensible defaults; revisit when Penpot tokens grow.
- Per design rule: dark text on light surfaces; light text only on dark / strong-accent surfaces. No raw hex in widgets — always tokens.
- All chips, buttons, list rows pull from a single component file (`shared/`); no per-screen radii drift.

## 14. Map and geocoding

- **Renderer:** `mapbox_gl`. Style URL is configurable; OSM-style fallback acceptable for early development. Mapbox API key kept out of the repo (read from `--dart-define`).
- **Country fills** come from a bundled GeoJSON country boundary set (small, public domain). Selection paints by ISO-3166 code derived from visits.
- **City pins** render with Mapbox's clustering at lower zoom levels; individual pins appear at higher zoom.
- **Reverse geocoding:** online-only via a thin `GeocodingApi` (Mapbox Geocoding API or alternative). Offline, requests are queued to `LocationPing.processed = false`.
- **Year Rewind** uses the same renderer with a connected route layer between visits — not a continuous GPS track in MVP.

## 15. Testing strategy

- **Unit tests:** pure domain rules (day-counting, Schengen window, rewind eligibility, visit overlap, top-week selection).
- **BLoC tests:** non-trivial state transitions (`AddVisitBloc`, `StatisticsBloc`, `ImportPhotosBloc`, `RewindBloc`, `BackgroundTrackingBloc`).
- **Widget tests:** critical flows — Add Visit, Choose City, Photo Import review, Day Detail.
- **Boundaries:** mock at **repository interfaces**; do not mock Drift internals or `geolocator` directly.
- **Integration:** deferred to post-MVP unless a flow proves regression-prone.
- **Coverage target:** none in MVP; Process Rules permit skipping tests on first iteration of a feature, with a follow-up task.

## 16. Open questions / decisions to make

1. **Background tracking mechanism.** `flutter_background_service` vs `workmanager` vs native isolate. Pick during Bootstrap. Constraints: must support 1h–24h periodic schedules on iOS+Android; must handle reverse-geocoding retry; must not require a foreground service banner where avoidable.
2. **Photo metadata reader.** No package selected. Candidates: `photo_manager`, `native_exif`, `image_picker` + EXIF lib. Decide before `import_data.md` implementation.
3. **Reference data endpoint.** Where to fetch the countries → continents JSON on every app launch? Self-hosted static JSON vs a public dataset (e.g. Restcountries). Need a stable URL with low SLA risk; cache the last successful payload for offline fallback within the same session.
4. **Mapbox styling and offline tiles.** Acceptable to require connectivity for the Map screen in MVP, or do we need offline tile packs? Brief says core flows must work offline; map view may degrade gracefully (show country fills from bundled GeoJSON without tiles).
5. **Country boundary data source.** Which GeoJSON dataset to bundle for country fills? Trade-off: file size vs accuracy of small territories.
6. **Schengen reference list.** Hardcoded constant of Schengen-area country codes in `domain/schengen/` — needs a maintenance plan when membership changes (rare but real).
7. **Day-counting tie-breakers.** "Top week" — when multiple rolling 7-day windows tie on unique cities, prefer most recent or earliest? Brief flags this as an open question.
8. **Multi-city days.** A single calendar day spent in two cities — does each contribute a full day to its country count? Need product call before `domain_model.md` finalises day-presence rules.

## 17. Cross-references

- Code rules: `.cursor/rules/daystracker-flutter-architecture.mdc` (binding for `lib/**`).
- Domain detail: `docs/tech/domain_model.md`.
- Per-feature behaviour: `docs/features/*.md`.
- Visual truth: Penpot file `days_tracker` (linked from `docs/02_design_brief.md`).
