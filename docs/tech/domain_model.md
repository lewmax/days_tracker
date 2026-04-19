# DaysTracker — Domain Model

> Pure-domain entities, value objects, enums, repository contracts, and business rules. Lives in `lib/domain/`. No Flutter, no IO, no DTOs.

## 1. Entities (overview)

| Entity | Identity | Purpose |
|---|---|---|
| `Country` | `code` (ISO-3166 alpha-2) | Reference data; flag, name, continent. |
| `Continent` | `code` (e.g. `EU`, `AS`) | Reference data for `Top continents` aggregation. |
| `City` | `id` (local UUID) | Locality within a country; `(name, countryCode, lat, lon)`. |
| `Visit` | `id` (local UUID) | Continuous stay in **one city**, with start/end dates. |
| `LocationPing` | `id` (local UUID) | Raw background sample; ephemeral. |
| `ConfirmationRequest` | `id` (local UUID) | Pending one-ping suggestion the user must accept/dismiss. |
| `ImportSession` | `id` (local UUID) | A photo-import run; carries suggestions and outcome. |
| `ImportSuggestion` | `id` (local UUID) | One proposed visit derived from photo metadata. |
| `RewindSession` | `year` | Snapshot for a completed calendar year (route + chronological list). |
| `SchengenStatus` | (computed) | Days used, remaining, window dates, earliest re-entry. |
| `TrackingSettings` | singleton | Background tracking enabled + frequency. |

All entities are **immutable plain Dart classes** with `Equatable`, `copyWith`, no `freezed`, no Flutter imports.

## 2. Reference data

### `Country`

| Field | Type | Notes |
|---|---|---|
| `code` | `String` | ISO-3166 alpha-2, uppercase. |
| `name` | `String` | English display name. |
| `flagEmoji` | `String` | Regional indicator pair; rendered with emoji-capable font. |
| `continentCode` | `String` | FK → `Continent.code`. |

### `Continent`

| Field | Type | Notes |
|---|---|---|
| `code` | `String` | e.g. `EU`, `AS`, `AF`, `NA`, `SA`, `OC`, `AN`. |
| `name` | `String` | English display name. |

> **Source:** fetched on **every app launch** from a remote JSON endpoint (URL TBD — see `architecture.md` §16). Cached in `reference_data_cache` for offline fallback within the session. The bundled fallback is used only if the cache is empty and the network call fails.

## 3. Local entities

### `City`

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | Local UUID. |
| `name` | `String` | Display name as returned by reverse geocoder; user can edit on a per-visit basis (visit copies the resolved name; future renames don't rewrite history). |
| `countryCode` | `String` | ISO-3166 alpha-2. |
| `lat` | `double` | Centroid for map pin / clustering. |
| `lon` | `double` | Same. |

**Invariants:**

- `(name, countryCode, lat≈lon)` is unique within rounding tolerance (avoid creating near-duplicate cities for slightly different geocoder results).
- Cities are never deleted automatically; they may become orphaned if all visits referencing them are deleted (acceptable; pruning is a future cleanup task).

### `Visit`

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | Local UUID. |
| `cityId` | `String` | FK → `City.id`. **Required** — there are no country-only visits. |
| `countryCode` | `String` | Denormalised from `City.countryCode` for fast filtering. |
| `startUtc` | `DateTime` | UTC, inclusive. |
| `endUtc` | `DateTime` | UTC, inclusive. |
| `confidence` | `VisitConfidence` | `confirmed` or `possible`. |
| `origin` | `VisitOrigin` | `manual`, `photoImport`, `backgroundTracking`. |
| `notes` | `String?` | Optional free text (not exposed in MVP UI). |
| `createdAtUtc` | `DateTime` | Audit. |
| `updatedAtUtc` | `DateTime` | Audit. |

**Invariants:**

- `startUtc <= endUtc`.
- A visit always has a city (and therefore a country). Country-only visits are not a supported shape.
- **No two `confirmed` visits overlap in time** for the same logical "user" (single-user app). Overlap is defined inclusively: visits `[a,b]` and `[c,d]` overlap iff `a <= d && c <= b`.
- `possible` visits **may** overlap with confirmed ones — they represent a yet-unresolved suggestion; resolving (accept/dismiss) reconciles to the non-overlap rule.
- Editing a visit **never** changes `cityId`. The brief's "city greyed and non-editable" rule is enforced at the domain layer: `VisitRepository.update(visitId, {newStartUtc, newEndUtc})` accepts dates only.
- `confidence` may be promoted from `possible` → `confirmed` (e.g. user confirms a tracking suggestion). The reverse is not allowed.

### `LocationPing`

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | Local UUID. |
| `timestampUtc` | `DateTime` | When the OS reported the fix. |
| `lat` | `double` | |
| `lon` | `double` | |
| `accuracyMeters` | `double` | OS-reported. |
| `resolvedCityId` | `String?` | Null while geocoding is pending. |
| `resolvedCountryCode` | `String?` | Same. |
| `processed` | `bool` | True after the derivation pass has consumed it. |

**Invariants:**

- A ping with `resolvedCityId == null && processed == false` is eligible for retry on the next online window.
- Pings older than the configured retention horizon (default: 30 days, post-MVP knob) may be pruned by a maintenance task.

### `ConfirmationRequest`

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | Local UUID. |
| `pingId` | `String` | FK → `LocationPing.id`. |
| `suggestedCityId` | `String` | Resolved city. |
| `suggestedCountryCode` | `String` | Same. |
| `suggestedDateUtc` | `DateTime` | The calendar day the ping fell on (UTC). |
| `createdAtUtc` | `DateTime` | |
| `status` | `ConfirmationStatus` | `pending`, `accepted`, `dismissed`. |

**Invariants:**

- One `pending` request per `pingId`.
- Accepting a request creates a `Visit` with `confidence = confirmed`, `origin = backgroundTracking`, dates = the suggested calendar day (UTC start/end).
- Dismissing a request marks the ping as `processed = true`.

### `ImportSession`

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | Local UUID. |
| `source` | `ImportSource` | `json` or `photos`. |
| `startedAtUtc` | `DateTime` | |
| `finishedAtUtc` | `DateTime?` | Null while in progress. |
| `status` | `ImportSessionStatus` | `scanning`, `awaitingReview`, `applied`, `cancelled`, `failed`. |

### `ImportSuggestion`

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | Local UUID. |
| `sessionId` | `String` | FK → `ImportSession.id`. |
| `cityId` | `String` | Resolved city. |
| `countryCode` | `String` | |
| `startUtc` | `DateTime` | Inclusive. |
| `endUtc` | `DateTime` | Inclusive. |
| `confidence` | `VisitConfidence` | Always `possible` in MVP photo flow; the user promotes via review. |
| `photoCount` | `int` | Number of source photos contributing to this suggestion. |
| `decision` | `SuggestionDecision` | `pending`, `accepted`, `edited`, `dismissed`. |

**Invariants:**

- Accepting a suggestion creates a `Visit` (`confidence = confirmed`, `origin = photoImport`).
- Editing dates before acceptance updates the suggestion in place; the resulting `Visit` reflects the edit.
- Dismissing a suggestion never creates a visit.

### `RewindSession`

| Field | Type | Notes |
|---|---|---|
| `year` | `int` | Calendar year, identity. |
| `visits` | `List<Visit>` | Confirmed visits with any day inside `year`, ordered by `startUtc`. |
| `cityCount` | `int` | Distinct cities in those visits. |
| `countryCount` | `int` | Distinct countries. |

**Eligibility (pure rule):** `RewindSession` for year `Y` is **eligible** iff `today (local) >= 1 January Y+1`. The `Map`-button gate additionally requires **≥3 distinct cities visited all-time** (not just within `Y`).

### `SchengenStatus` (value object, computed)

| Field | Type | Notes |
|---|---|---|
| `referenceDateUtc` | `DateTime` | "As of" — usually today UTC. |
| `daysUsed` | `int` | Count of calendar days (UTC) inside the rolling 180-day window that the user spent inside Schengen. |
| `daysRemaining` | `int` | `max(0, 90 - daysUsed)`. |
| `windowStartUtc` | `DateTime` | `referenceDateUtc - 179 days` (inclusive). |
| `windowEndUtc` | `DateTime` | `referenceDateUtc`. |
| `earliestReentryUtc` | `DateTime?` | Null when not over the limit; otherwise the first UTC date on which the rolling count would drop below 90. |
| `isOverLimit` | `bool` | `daysUsed > 90`. |

### `TrackingSettings`

| Field | Type |
|---|---|
| `enabled` | `bool` |
| `frequency` | `TrackingFrequency` |

## 4. Enums

```dart
enum VisitConfidence { confirmed, possible }
enum VisitOrigin { manual, photoImport, backgroundTracking }
enum TrackingFrequency { off, h1, h2, h4, h8, h12, h24 }
enum ConfirmationStatus { pending, accepted, dismissed }
enum ImportSource { json, photos }
enum ImportSessionStatus { scanning, awaitingReview, applied, cancelled, failed }
enum SuggestionDecision { pending, accepted, edited, dismissed }
enum StatisticsPeriod { all, thisYear, prevYear, last183 }
enum StatisticsCategory { countries, cities, continents, week }
enum TimelineMode { calendar, chronological }
```

## 5. Aggregates and derived value objects

These are pure structs returned by `StatisticsRepository` / `RewindRepository`. They are **not** stored — recomputed from `visits` on demand.

### `DayPresence`

`(dateUtc, cityId, countryCode)` — one record per (day, city) the user was present. A day with multiple cities yields multiple records (open question §16.8 in `architecture.md`).

### `CountryStat`

| Field | Type |
|---|---|
| `countryCode` | `String` |
| `days` | `int` |
| `cityCount` | `int` |
| `pctOfPeriod` | `double` (0..1) |

### `CityStat`

| Field | Type |
|---|---|
| `cityId` | `String` |
| `countryCode` | `String` |
| `days` | `int` |
| `pctOfPeriod` | `double` |

### `ContinentStat`

| Field | Type |
|---|---|
| `continentCode` | `String` |
| `days` | `int` |
| `countryCount` | `int` |
| `cityCount` | `int` |
| `pctOfPeriod` | `double` |

### `TopWeekResult`

| Field | Type |
|---|---|
| `windowStartUtc` | `DateTime` |
| `windowEndUtc` | `DateTime` (= start + 6 days, inclusive) |
| `uniqueCityCount` | `int` |
| `cities` | `List<CityStat>` (cities touched in the window) |
| `groupedByCountry` | `Map<String, List<CityStat>>` |

## 6. Day-counting semantics

Pure functions in `domain/visits/day_counting.dart`. **No IO**.

- **Inclusive calendar days.** A visit `[Mar 5, Mar 5]` = **1 day**. A visit `[Mar 5, Mar 7]` = **3 days**.
- **Calendar boundary**: UTC midnight for statistics math. Presentation may render in local time.
- **Period definitions:**
  - `all` — entire history.
  - `thisYear` — `[Jan 1 (local) of current year, today (local)]`, converted to UTC bounds.
  - `prevYear` — `[Jan 1, Dec 31]` of the previous calendar year (local).
  - `last183` — `[today - 182 days, today]` inclusive (UTC bounds).
- **Period clipping:** a visit that straddles a period boundary contributes only the days that fall inside the period.
- **Confirmed-only:** all statistics use **`confirmed`** visits exclusively. `possible` visits are never silently mixed into headline numbers.
- **Top week:** scan all rolling 7-day windows (`[d, d+6]`) over the selected period; pick the one with the most **distinct confirmed cities**. Ties — open question (architecture §16.7).

## 7. Schengen rules

Pure functions in `domain/schengen/`. Inputs: list of `confirmed` visits, reference date, Schengen country list.

- **Window:** trailing 180 days (`[ref - 179, ref]` inclusive UTC).
- **Day counted as inside Schengen:** any calendar day during which the user had a confirmed visit whose city's country is in the Schengen list.
- **`daysUsed`** = count of distinct UTC calendar days inside the window that match the above.
- **`earliestReentryUtc`** = first future date `D` such that the rolling window `[D - 179, D]` contains `< 90` Schengen days, considering only days already known. If the user is **not** currently over the limit, this is `null`.
- The helper is **explicitly framed as informational** in the UI; no legal phrasing.

## 8. Year Rewind eligibility (pure rule)

```dart
bool isRewindEligible(int year, DateTime nowLocal) =>
    nowLocal.isAfter(DateTime(year + 1, 1, 1).subtract(const Duration(microseconds: 1)));
```

Map-button visibility additionally requires `confirmedDistinctCityCountAllTime >= 3`. Settings → Rewinds history shows **all** eligible years regardless of city count, with an empty state when none exist.

## 9. Visit overlap rule (pure)

```dart
bool overlaps(Visit a, Visit b) =>
    !a.endUtc.isBefore(b.startUtc) && !b.endUtc.isBefore(a.startUtc);
```

`VisitRepository.create` and `VisitRepository.update` MUST reject any change that produces overlap among **confirmed** visits, returning `Left(ConflictFailure.visitOverlap(otherVisitId))`.

## 10. Repository contracts (signatures)

> Authoritative file: `lib/domain/repositories/`. Listed here for cross-referencing feature docs.

```dart
abstract interface class VisitRepository {
  Future<Either<Failure, List<Visit>>> list({DateTime? fromUtc, DateTime? toUtc, String? countryCode, String? cityId});
  Future<Either<Failure, Visit>> getById(String id);
  Future<Either<Failure, Visit>> create({required String cityId, required DateTime startUtc, required DateTime endUtc, required VisitOrigin origin, VisitConfidence confidence});
  Future<Either<Failure, Visit>> updateDates(String id, {required DateTime startUtc, required DateTime endUtc});
  Future<Either<Failure, Unit>> delete(String id);
  Future<Either<Failure, Visit>> promoteToConfirmed(String id);
  Stream<List<Visit>> watch({DateTime? fromUtc, DateTime? toUtc});
}

abstract interface class StatisticsRepository {
  Future<Either<Failure, List<CountryStat>>> topCountries(StatisticsPeriod period);
  Future<Either<Failure, List<CityStat>>> topCities(StatisticsPeriod period);
  Future<Either<Failure, List<ContinentStat>>> topContinents(StatisticsPeriod period);
  Future<Either<Failure, TopWeekResult?>> topWeek(StatisticsPeriod period);
  Future<Either<Failure, List<CityStat>>> citiesInCountry(String countryCode, StatisticsPeriod period);
  Future<Either<Failure, List<CountryStat>>> countriesInContinent(String continentCode, StatisticsPeriod period);
  Future<Either<Failure, bool>> hasEnoughDataForPrevYear();
}

abstract interface class BackgroundTrackingRepository {
  Future<Either<Failure, TrackingSettings>> readSettings();
  Future<Either<Failure, Unit>> updateSettings({required bool enabled, required TrackingFrequency frequency});
  Stream<List<ConfirmationRequest>> watchPendingConfirmations();
  Future<Either<Failure, Unit>> acceptConfirmation(String id);
  Future<Either<Failure, Unit>> dismissConfirmation(String id);
}

abstract interface class GeocodingRepository {
  Future<Either<Failure, City>> reverseGeocode(double lat, double lon);
  Future<Either<Failure, List<City>>> searchByName(String query);
}

abstract interface class PhotoImportRepository {
  Future<Either<Failure, Unit>> ensurePermission();
  Future<Either<Failure, ImportSession>> startScan();
  Stream<ImportSession> watchSession(String sessionId);
  Future<Either<Failure, List<ImportSuggestion>>> listSuggestions(String sessionId);
  Future<Either<Failure, Unit>> updateSuggestion(String id, {DateTime? startUtc, DateTime? endUtc, SuggestionDecision? decision});
  Future<Either<Failure, int>> applyAccepted(String sessionId); // returns count of created visits
  Future<Either<Failure, Unit>> cancel(String sessionId);
}

abstract interface class JsonImportExportRepository {
  Future<Either<Failure, String>> exportToFile(); // returns absolute path
  Future<Either<Failure, ImportSession>> importFromFile(String path, {required ImportMergeStrategy strategy});
}

abstract interface class RewindRepository {
  Future<Either<Failure, List<int>>> eligibleYears();
  Future<Either<Failure, RewindSession>> load(int year);
}

abstract interface class SchengenRepository {
  Future<Either<Failure, SchengenStatus>> currentStatus({DateTime? referenceUtc});
}

abstract interface class SettingsRepository {
  Future<Either<Failure, bool>> isOnboardingDone();
  Future<Either<Failure, Unit>> markOnboardingDone();
  Future<Either<Failure, int?>> readLastSeenRewindYear();
  Future<Either<Failure, Unit>> writeLastSeenRewindYear(int year);
}

abstract interface class ReferenceDataRepository {
  Future<Either<Failure, List<Country>>> loadCountries(); // refreshes on every app launch
  Future<Either<Failure, List<Continent>>> loadContinents();
}

enum ImportMergeStrategy { replaceAll, mergeNonConflicting }
```

## 11. Validation rules summary

| Rule | Where enforced |
|---|---|
| `startUtc <= endUtc` | Domain (entity construction + repo) |
| Confirmed visits non-overlap | Domain pure check + repo on write |
| Visit must reference a city | Domain construction |
| Tracking frequency `off` ⇔ `enabled = false` | Domain + repo |
| Suggestion edits stay within a sane bound (≤ 6 months span) | Domain pure check |
| Schengen window arithmetic | Domain pure functions only |
| Day-counting period clipping | Domain pure functions only |

## 12. Cross-references

- Architecture: `docs/tech/architecture.md`.
- Per-feature behaviour: `docs/features/*.md`.
- Code rules: `.cursor/rules/daystracker-flutter-architecture.mdc`.
- Visual truth: Penpot file `days_tracker`.
