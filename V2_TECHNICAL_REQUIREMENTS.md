# DaysTracker v2.0 – Technical Requirements

**Version:** 2.0.0  
**Prerequisite:** v1.0 MVP complete (Phases 1–9)  
**Target:** Post-MVP feature set, quality improvements, and known v1.0 fixes.

---

## 1. Scope summary

v2.0 extends v1.0 with new features from the roadmap, addresses critical/minor v1.0 issues, and improves test and production readiness where specified below. All v1.0 architecture, tech stack, and constraints (Clean Architecture, Bloc, Drift, no cloud sync) remain unless explicitly changed here.

---

## 2. Must-fix (v1.0 carry-over)

- **Android background tracking**
  - Implement real logic in WorkManager `callbackDispatcher` (see `lib/data/services/background_service.dart`).
  - Requirement: when the periodic task runs, obtain location (same capability as “Track now”), run reverse geocoding, and persist via the same flow as foreground (e.g. LocationProcessingService + DB). Isolate-safe initialization (DB path + minimal stack in WorkManager isolate) or an equivalent approach is acceptable.
  - Success: background hourly task on Android actually records location and updates visits/presence.

- **Optional but recommended before calling v2.0 done**
  - Execute manual testing checklist (e.g. PROGRESS.md Phase 8) on iOS and Android.
  - One-off performance check: calendar, statistics, DB with large data (e.g. 500+ visits, 365 days) and document results (or “not measured” and rationale).

---

## 3. New features (v2.0)

### 3.1 Map visualization
- Integrate a map SDK (e.g. Mapbox) to show:
  - Countries/cities with presence (e.g. pins or regions).
  - Optional: current location and/or visit locations.
- Requirements: offline-capable where possible; no new backend; reuse existing country/city/visit data and day-counting rules.
- Tech: Add Mapbox (or chosen provider) per platform; new screen or tab; keep existing navigation (e.g. auto_route) and state (Bloc) patterns.

### 3.2 Home / lock screen widget
- Widget(s) on device home screen (and lock screen if supported) showing:
  - At least: total days in current country and/or “top” country/city (configurable or simple rule).
- Requirements: read-only; refresh within platform limits; no new backend; data from existing SQLite/Drift.
- Tech: Use platform widget APIs (e.g. Flutter home_widget or platform-specific); respect existing architecture (widget as view over same data layer).

### 3.3 Overnight-only day counting rule
- New day-counting rule: **Overnight** – a day counts only if the user has presence spanning a configured “night” window (e.g. local midnight or a time range).
- Requirements: configurable in Settings; applied consistently in statistics, calendar, and any map/export that uses day counts; stored in DB/computed from existing presence/ping data where possible.
- Tech: New enum value (e.g. `DayCountingRule.overnight`); updates in StatisticsRepositoryImpl / DAOs / BLoCs and any export that uses day counts.

### 3.4 Visit merge UI
- Allow user to select two (or more) visits and merge them into one (e.g. combine date ranges, keep one city/country, sum or reconcile days).
- Requirements: validation (e.g. no overlapping other visits after merge); update visits and any dependent presence/aggregations; undo not required for v2.0.
- Tech: New use case(s) (e.g. MergeVisits), repository method(s), BLoC events; UI in visits list/detail (selection + “Merge” action).

### 3.5 CSV export
- Export data (visits and/or statistics) to CSV in addition to existing JSON.
- Requirements: same data scope as JSON export or a defined subset; file picker/share as today; no cloud upload.
- Tech: New export path or parameter in existing export service; CSV formatter; reuse existing file/share flow.

### 3.6 PDF reports
- Generate PDF report(s) (e.g. summary by country, date range, or “for authority”).
- Requirements: content based on existing stats/visits; local generation only; optional print/share.
- Tech: Add PDF package (e.g. pdf, printing); one or more report templates; trigger from Statistics or Settings.

### 3.7 Ukrainian localization
- Full UI (and in-app strings) in Ukrainian; English remains supported.
- Requirements: all user-facing text in `lib` covered (l10n); locale switch in Settings or system; no new backend.
- Tech: Extend l10n (e.g. ARB + flutter_localizations); add `uk`; ensure date/number formatting for Ukrainian locale.

### 3.8 Advanced statistics (trends, charts)
- Trends over time and simple charts (e.g. days per month, per country over time).
- Requirements: data from existing DB; time ranges consistent with current filters (7d, 31d, 183d, 365d, all); no new backend.
- Tech: New or extended statistics use case(s)/repository; chart library (e.g. fl_chart); new/updated Statistics UI and Bloc.

---

## 4. Quality and technical debt (v2.0)

- **Test coverage**
  - Target: raise overall `lib/` line coverage (excluding `.g.dart`) toward **80%** (or document why a lower target is accepted).
  - Add tests as needed for: new use cases, repository/DAO changes, and critical BLoC branches; optional: integration or widget tests for new screens (map, widget config, merge UI).

- **Android WorkManager**
  - Must-fix above counts as resolving the main related technical debt for v2.0.

- **Lint and TODOs**
  - No new broad lint suppressions for v2.0 features; address or document existing TODOs (e.g. in `location_processing_service.dart`) where they touch changed code.

---

## 5. Out of scope for v2.0

- Cloud sync, push notifications, multiple users/accounts.
- Database encryption (still out of scope unless explicitly added in a later spec).
- Web as a primary platform (can remain low priority).
- Breaking changes to v1.0 public export/import format without a separate migration path.

---

## 6. Success criteria for v2.0 release

- All v2.0 features implemented and tested (manual minimum; automated where specified).
- Android background tracking implemented and verified (periodic task records location).
- No new critical or blocking bugs from v2.0 changes.
- CHANGELOG and README updated for v2.0; known limitations documented.
- Optional: Performance and/or coverage documented (targets or “not measured” with rationale).