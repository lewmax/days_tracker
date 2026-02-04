# DaysTracker MVP - Implementation Review

**Date:** February 3, 2026  
**Scope:** Phases 1–9 complete  
**Purpose:** Self-review of what was done well and what needs improvement.

---

## ✅ Completed Features

| Feature | Status | Notes |
|--------|--------|--------|
| Database (5 tables, 5 DAOs) | **DONE** | Drift schema, indexes, clearAllData(), forTesting constructor |
| Domain layer (11 entities, 4 repos, 20+ use cases) | **DONE** | Plain classes + copyWith + Equatable; freezed only for BLoC |
| Data layer (4 repo impls, 7 services) | **DONE** | Repos, DAOs, mappers, geocoding, location, background, export/import |
| Presentation (3 BLoCs, 6 screens, 15+ widgets) | **DONE** | Visits, Statistics, Settings; loading/error/empty states |
| Background tracking (iOS + Android) | **PARTIAL** | Service starts/stops; **Android WorkManager callback is placeholder** (see Known Issues) |
| Data export/import | **DONE** | JSON format, validate + restore, file picker + share |
| Tests (320+ passing) | **DONE** | Domain + BLoC + data (DAOs, repos, services) covered; **overall lib/ coverage ~61%** (below 80% target) |
| Documentation | **DONE** | README, CHANGELOG, TESTING.md, platform setup, known limitations |

---

## 📊 Test Coverage Report

| Layer | Coverage (approx.) | Notes |
|-------|--------------------|--------|
| **Domain** | **High** | Entities, enums, use cases (success/failure paths) well covered; GetDayDetails, GetDailyPresenceCalendar added |
| **Data** | **Medium** | DAOs (Countries, Cities, Visits, DailyPresence, LocationPings), VisitsRepositoryImpl, StatisticsRepositoryImpl, SettingsRepositoryImpl, GeocodingService, LocationProcessingService, ExportService, ImportService unit tested |
| **Presentation** | **Low** | BLoC tests only; no widget/screen tests |
| **Overall lib/** | **~61%** | Excluding `.g.dart`: ~2142 lines, ~1314 hit. Tables (schema-only) excluded would give ~63%. |

Coverage measured with `flutter test --coverage`; `lib/` line coverage excludes generated (`.g.dart`) files. New tests added: DAO tests (CitiesDao, DailyPresenceDao, LocationPingsDao), StatisticsRepositoryImpl, SettingsRepositoryImpl, GeocodingService, LocationProcessingService, GetDayDetails, GetDailyPresenceCalendar. To reach 80%+ would require more BLoC branch coverage, LocationRepositoryImpl/BackgroundService/LocationService tests (or excluding platform-heavy code), and/or widget tests.

---

## 🐛 Known Issues

### Critical

1. **Android background task does not run real logic**  
   - **Where:** `lib/data/services/background_service.dart` — `callbackDispatcher()` (WorkManager entry point).  
   - **What:** When WorkManager fires the periodic task on Android, the callback only logs and returns `true`. It does not initialize DI or call `LocationProcessingService` / `LocationService` to get location and process the ping.  
   - **Impact:** On Android, “hourly” background tracking is scheduled but does not actually record location when the app is in the background.  
   - **Fix:** Implement isolate-safe initialization (e.g. get database path + construct minimal stack in the isolate, or use a different approach that can access DI) and call the same location + processing flow that “Track now” uses in the foreground.

### High

2. **Manual testing checklist not executed**  
   - Add visit, overlap validation, statistics, calendar, export/import, background behavior, and “no crashes” have not been verified on a real device/simulator in this review.  
   - **Recommendation:** Run through the manual checklist in PROGRESS.md (Phase 8) on both iOS and Android before release.

3. **Test coverage below 80% target**  
   - Overall lib/ coverage is ~61% (excluding generated files). Data layer (DAOs, repos, GeocodingService, LocationProcessingService, export/import) now has substantial unit tests; presentation and platform services (BackgroundService, LocationService) remain largely untested.  
   - **Recommendation:** To reach 80%+: add more BLoC/use-case branch tests, LocationRepositoryImpl tests, or exclude platform-heavy and schema-only files from the coverage denominator.

4. **Performance not measured**  
   - Targets (calendar &lt;500ms, statistics &lt;1s, DB &lt;100ms) are not benchmarked.  
   - **Recommendation:** Run a quick profiling pass with 500+ visits and 365 days of data before release.

### Medium

5. **iOS background throttling**  
   - Documented limitation: iOS may not run background fetch every hour. Acceptable as known limitation but worth validating in the field.

6. **Lint suppressions in place**  
   - `unreachable_from_main`, `avoid_dynamic_calls`, and some test-style rules are ignored or relaxed. Maintainability is fine, but the codebase is not “zero suppressions.”

7. **TODOs in code**  
   - `location_processing_service.dart`: TODO about updating visits/presence when a ping wasn’t linked. Worth clarifying and either implementing or documenting as deferred.

---

## ⚡ Performance Benchmarks

| Scenario | Target | Status |
|----------|--------|--------|
| Calendar render (500 visits) | &lt;500ms | **Not measured** |
| Statistics calculation | &lt;1s | **Not measured** |
| Background ping processing | &lt;5s | **Not measured** |
| Database queries | &lt;100ms | **Not measured** |

Recommendation: Add a small benchmark or profile run (e.g. with 500 visits and 365 days) and record results here before release.

---

## 🔧 Technical Debt

1. **Android WorkManager callback is a stub**  
   - **Why:** DI and Drift are not set up in the WorkManager isolate; full implementation was deferred.  
   - **Impact:** Background location on Android does not run.  
   - **Priority:** **HIGH**

2. **Data layer has no direct unit tests**  
   - **Why:** Tests focus on domain and BLoCs with mocked repos.  
   - **Impact:** Repository/DAO/service regressions are only caught by integration or manual testing.  
   - **Priority:** **MEDIUM**

3. **Lint rule suppressions (avoid_dynamic_calls, unreachable_from_main)**  
   - **Why:** JSON/API parsing uses dynamic access; background and test code is “unreachable” from main.  
   - **Impact:** Slight increase in risk from dynamic misuse; no functional impact if discipline is kept.  
   - **Priority:** **LOW**

4. **No integration or widget tests**  
   - **Why:** MVP scope was domain + BLoC unit tests.  
   - **Impact:** End-to-end and UI flows are only validated manually.  
   - **Priority:** **MEDIUM** (for v1.1 or post-MVP)

---

## 🚀 Production Readiness

| Criterion | Status |
|-----------|--------|
| All features working | ⚠️ Background on Android is placeholder only |
| No critical bugs | ❌ One critical (Android background task) |
| Tests passing | ✅ 206 tests |
| Documentation complete | ✅ README, CHANGELOG, TESTING.md, setup, limitations |
| Performance acceptable | ⏳ Not measured |

### Recommendation

**NEEDS FIXES (list critical issues)**

- **Blocking:** Fix Android WorkManager `callbackDispatcher` so the periodic task actually gets location and processes it (same flow as “Track now”), or clearly ship with “background tracking on Android not functional” and document it.
- **Before release:** Run manual testing checklist (Phase 8) on both platforms.
- **Optional but recommended:** Run a quick performance check (calendar, statistics, DB) with large data; add benchmarks to this doc.

Once the Android background task is implemented (or explicitly scoped out and documented), and manual testing passes, the project can be treated as **ready for a controlled/beta release** with known limitations (coverage, performance unmeasured, iOS throttling).

---

## 📋 v1.1 Roadmap

1. Map visualization (e.g. Mapbox)  
2. Home / lock screen widget  
3. Overnight-only day counting rule  
4. Visit merge UI  
5. CSV export, PDF reports  
6. Ukrainian localization  
7. Advanced statistics (trends, charts)  
8. Raise test coverage (data layer, integration/widget tests) toward 75%+

---

## 💡 Suggested Improvements

| Improvement | Benefit | Effort | Priority |
|-------------|---------|--------|----------|
| Implement Android WorkManager callback with real location + processing | Background tracking works on Android | Medium (isolate/DI or alternate design) | **High** |
| Add repository/DAO unit tests (with in-memory or test DB) | Catch data-layer regressions, move toward 75% coverage | Medium | Medium |
| Add one integration test (e.g. “add visit → appears in list”) | Confidence in critical path | Low–Medium | Medium |
| Benchmark calendar + statistics with 500 visits | Validate performance targets | Low | Medium |
| Replace dynamic JSON access with typed parsing (e.g. json_serializable) | Fewer lint suppressions, safer parsing | Medium | Low |
| Add widget tests for main list/detail screens | UI regression safety | Medium | Low |

---

## 📝 Lessons Learned

### What Went Well

- **Clean Architecture** — Clear separation of core, domain, data, presentation made it easy to add features and test domain logic in isolation.
- **Domain test coverage** — Entities, enums, and use cases are well covered; overlap validation, day counting, and failure paths are tested.
- **BLoC + freezed** — Event/state handling is consistent and testable; freezed kept BLoC boilerplate manageable.
- **Documentation** — README, CHANGELOG, TESTING.md, and PROGRESS.md give a clear picture of setup, limitations, and how to run/add tests.
- **Platform setup** — Android manifest and iOS Info.plist are correctly configured for location and background; only the Android callback logic is missing.
- **Export/import** — JSON format, validation, and replace-on-import behave as specified; good base for backup/restore.
- **UI states** — Loading, error, and empty states are implemented on main screens; accessibility (semantics, labels) was added in Phase 8.

### What Could Be Improved

- **Background implementation** — The Android WorkManager entry point should have been implemented (or explicitly deferred with a ticket) earlier so “background tracking” is not partially stubbed at review time.
- **Coverage strategy** — Deciding up front to either (a) aim for 75% overall with data-layer + integration tests, or (b) explicitly accept “domain + BLoC + manual testing” for MVP would have set clearer expectations.
- **Performance** — Running at least one round of benchmarks (calendar, statistics) during Phase 8 would have provided concrete numbers for production readiness.
- **Manual testing** — Running the Phase 8 checklist before calling “all phases complete” would have caught the Android callback gap and any UI/flow issues.

### Challenges Faced

- **DI in background isolate** — WorkManager runs in a different isolate; injecting Drift and services there is non-trivial and was left as a placeholder.
- **Strict lint** — Rules like `unreachable_from_main` and `avoid_dynamic_calls` required either refactors (e.g. moving background code to a library, typing all JSON) or targeted suppressions; suppressions were chosen for speed.
- **Coverage vs. scope** — Achieving 75%+ over full lib/ would have required many more tests (repos, DAOs, services, widgets); scope stayed on domain + BLoC, so overall coverage stayed low.

---

*End of Implementation Review*
