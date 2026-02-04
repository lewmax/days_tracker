# 🎯 DaysTracker MVP - Implementation Prompt for Cursor AI Agent

**Target Model:** Claude Opus 4.5  
**Project Type:** Flutter Mobile App (iOS + Android)  
**Architecture:** Clean Architecture  
**Estimated Timeline:** 16 days (9 phases)

---

## 📋 Your Mission

You are an expert Flutter developer implementing **DaysTracker** - a privacy-first offline app that tracks days spent in countries and cities for tax/visa purposes (183-day rule, Schengen 90/180 rule).

**Your objectives:**
1. Implement complete MVP following Clean Architecture principles
2. Write comprehensive tests (80%+ coverage in domain layer)
3. Document all code (docstrings + inline comments for complex logic)
4. Complete all 9 implementation phases sequentially
5. Perform self-review and propose improvements after completion

---

## 📖 Requirements Document

**READ THIS FIRST:** `daystracker-requirements.md`

This document contains:
- Complete database schema (5 tables)
- All domain entities, repositories, and use cases
- Data layer implementations (DAOs, services, repositories)
- Presentation layer (BLoCs, screens, widgets)
- Background tracking setup (iOS + Android)
- Testing strategy and success criteria
- Complete technical specification

**DO NOT PROCEED** until you've read the entire requirements document.

---

## 🏗️ Architecture Principles (CRITICAL)

### Clean Architecture Layers

```
lib/
├── core/                 # DI, errors, utils
├── domain/              # Entities, repos (abstract), use cases
├── data/                # Repos (impl), DAOs, services, datasources
└── presentation/        # BLoCs, screens, widgets
```

**Dependency Rule:** `domain` ← `data` ← `presentation`
- Domain knows NOTHING about data/presentation
- Data implements domain interfaces
- Presentation depends on domain use cases

### Code Style Rules

**✅ DO:**
- Use plain Dart classes for entities (+ `copyWith` + `equatable`)
- Use `freezed` ONLY for BLoC events/states
- Store all DateTime as UTC
- Use `Either<Failure, Result>` for domain/data layer
- Write docstrings for all public methods
- Add inline comments for complex business logic
- Use `@injectable` for DI registration

**❌ DON'T:**
- Use freezed for domain entities
- Mix layers (e.g., BLoC calling DAO directly)
- Hardcode strings (use constants)
- Skip tests
- Leave TODO without explanation

---

## 🎯 Implementation Phases (Sequential - DO NOT SKIP)

### **PHASE 1: Project Setup & Database (Day 1-2)**

**Goal:** Working SQLite database with all tables and DAOs

**Tasks:**
1. Create Flutter project structure (Clean Architecture folders)
2. Add all dependencies to `pubspec.yaml`
3. Setup DI (get_it + injectable) - create injection.dart
4. Create 5 Drift table definitions
5. Create app_database.dart
6. Create 5 DAOs with CRUD + specific queries
7. Create 11 domain entities (plain classes)
8. Create 3 enums
9. Create failures.dart
10. Create 5 mappers (Data ↔ Entity)
11. Write unit tests for DAOs

**Success Criteria:**
- [ ] All tables created and migrations work
- [ ] All DAOs pass CRUD tests
- [ ] Entities have copyWith + equatable
- [ ] Mappers convert correctly
- [ ] `flutter analyze` shows 0 errors
- [ ] `flutter test` passes all DAO tests

---

### **PHASE 2: Core Services & Repositories (Day 3-4)**

**Goal:** Business logic layer operational

**Tasks:**
1. Create 4 abstract repository interfaces
2. Implement 4 repositories (visits, location, statistics, settings)
3. Create GoogleMapsApiDataSource
4. Implement 4 core services:
   - GeocodingService (Google Maps API + DB caching)
   - LocationService (geolocator wrapper)
   - LocationProcessingService (CRITICAL - main ping logic)
   - CitySearchService (autocomplete)
5. Register all in DI
6. Write unit tests (mock dependencies)

**Critical Implementation - LocationProcessingService:**
```dart
Future<Either<Failure, void>> processLocationPing(lat, lon, accuracy):
  1. Save raw ping (status=pending)
  2. Reverse geocode (update ping on success)
  3. Get active visit
  4. If same city → extend visit (update lastUpdated)
  5. If different city → close previous, create new
  6. Update daily_presence (increment pingCount)
```

**Success Criteria:**
- [ ] All repositories registered in DI
- [ ] GeocodingService caches cities
- [ ] LocationProcessingService handles same/different city
- [ ] Statistics calculates days correctly (both rules)
- [ ] All tests pass

---

### **PHASE 3: Use Cases (Day 5)**

**Goal:** Domain layer use cases isolate business logic

**Tasks:**
1. Create 15+ use cases in domain/usecases/
2. Each use case: single responsibility, inject repository
3. Register all in DI
4. Write unit tests (mock repositories)

**Critical Use Cases:**
- ValidateVisitOverlap (test multiple scenarios)
- CalculateCountryDays (test both counting rules)
- ProcessLocationPing (orchestrate services)

**Success Criteria:**
- [ ] All use cases implemented
- [ ] Overlap validation tested thoroughly
- [ ] Day counting tested for both rules
- [ ] All tests pass (80%+ coverage)

---

### **PHASE 4: BLoCs & States (Day 6-7)**

**Goal:** State management complete with freezed

**Tasks:**
1. Create 3 BLoCs (Visits, Statistics, Settings)
2. For each BLoC:
   - Create events.dart (freezed)
   - Create state.dart (freezed)
   - Create bloc.dart (inject use cases)
3. Run build_runner
4. Write BLoC tests (bloc_test package)

**BLoC Pattern:**
```dart
@freezed
class VisitsEvent with _$VisitsEvent {
  const factory VisitsEvent.loadVisits() = _LoadVisits;
  // ... other events
}

@freezed
class VisitsState with _$VisitsState {
  const factory VisitsState.initial() = _Initial;
  const factory VisitsState.loading() = _Loading;
  const factory VisitsState.loaded(List<Visit> visits) = _Loaded;
  const factory VisitsState.error(String message) = _Error;
}
```

**Success Criteria:**
- [ ] All BLoCs registered in DI
- [ ] State transitions tested
- [ ] Error handling tested
- [ ] No compilation errors

---

### **PHASE 5: UI Screens & Widgets (Day 8-10)**

**Goal:** Complete user interface

**Tasks:**
1. Setup AutoRoute navigation
2. Create bottom navigation shell (3 tabs)
3. Create 8+ common widgets
4. Implement Visits Feature (4 screens + 5 widgets)
5. Implement Statistics Feature (1 screen + 7 widgets)
6. Implement Settings Feature (1 screen)

**Critical UI Requirements:**

**Calendar View (like screenshot):**
```
- Month/year selector (< January 2026 >)
- 7-column grid (MON-SUN)
- Each cell: day number + up to 3 country flags
- Current day highlighted
- Tap → DayDetailsModal
```

**Add Visit Form:**
```
- Country picker (dropdown with flags)
- City autocomplete (CitySearchService)
- Date range picker
- "Use Current Location" button
- Strict overlap validation
```

**Success Criteria:**
- [ ] All 6 screens navigable
- [ ] Calendar matches screenshot
- [ ] All 4 view modes work
- [ ] Forms validate correctly
- [ ] No crashes

---

### **PHASE 6: Background Tracking (Day 11-12)**

**Goal:** Hourly location tracking on both platforms

**Tasks:**
1. Create BackgroundService interface
2. Implement for Android (WorkManager)
3. Implement for iOS (BackgroundFetch)
4. Update AndroidManifest.xml
5. Update Info.plist
6. Test on both platforms

**Android (WorkManager):**
```dart
Workmanager().registerPeriodicTask(
  "location-tracking",
  "locationTracking",
  frequency: Duration(hours: 1),
);

@pragma('vm:entry-point')
static void callbackDispatcher() {
  // Get location → process ping
}
```

**iOS (BackgroundFetch):**
```dart
BackgroundFetch.configure(
  minimumFetchInterval: 60,
  _onBackgroundFetch,
);
```

**Success Criteria:**
- [ ] Android task runs (test with adb)
- [ ] iOS fetch works (test with Xcode)
- [ ] Pings saved when app closed
- [ ] Visits created automatically

---

### **PHASE 7: Data Import/Export (Day 13)**

**Goal:** Backup and restore functionality

**Tasks:**
1. Create ExportService (dump all tables to JSON)
2. Create ImportService (parse + validate + restore)
3. Update SettingsBloc
4. Update SettingsScreen (buttons + file picker)

**JSON Format:**
```json
{
  "version": "1.0.0",
  "exported_at": "2026-02-03T22:00:00Z",
  "data": {
    "countries": [...],
    "cities": [...],
    "visits": [...],
    "location_pings": [...],
    "daily_presence": [...]
  }
}
```

**Success Criteria:**
- [ ] Export creates valid JSON
- [ ] Import validates structure
- [ ] Import replaces data correctly
- [ ] Error handling works

---

### **PHASE 8: Polish & Testing (Day 14-15)**

**Goal:** Production-ready quality

**Tasks:**
1. Run `flutter analyze` (fix all warnings)
2. Run `flutter test --coverage` (verify 75%+)
3. Manual testing (all critical flows)
4. Performance testing (500 visits)
5. UI polish (loading/error/empty states)
6. Accessibility (basic contrast, touch targets)

**Manual Testing Checklist:**
- [ ] Add visit → appears in list
- [ ] Overlapping visit blocked
- [ ] Statistics update correctly
- [ ] Calendar view functional
- [ ] Export/import works
- [ ] Background tracking works
- [ ] No crashes

**Performance Targets:**
- Calendar render: <500ms
- Statistics calc: <1s
- Database queries: <100ms

**Success Criteria:**
- [ ] 0 analyze warnings
- [ ] 75%+ test coverage
- [ ] All manual tests pass
- [ ] Performance acceptable
- [ ] UI polished

---

### **PHASE 9: Documentation (Day 16)**

**Goal:** Complete documentation

**Tasks:**
1. Create comprehensive README.md
2. Create CHANGELOG.md
3. Add docstrings to all public methods
4. Create TESTING.md
5. Document platform configurations

**README Structure:**
```markdown
# DaysTracker
- Features list
- Setup instructions
- Background tracking setup (iOS + Android)
- Architecture overview
- Known limitations
- Testing instructions
- Future roadmap
```

**Success Criteria:**
- [ ] README complete
- [ ] Background setup documented
- [ ] Known limitations listed
- [ ] All public methods have docstrings
- [ ] CHANGELOG created

---

## 📊 Self-Review (AFTER ALL PHASES)

**Create:** `IMPLEMENTATION_REVIEW.md`

**Template:**

```markdown
# DaysTracker MVP - Implementation Review

## ✅ Completed Features
- [ ] Database (5 tables, 5 DAOs) - Status: DONE/PARTIAL/ISSUE
- [ ] Domain layer (11 entities, 4 repos, 15 use cases)
- [ ] Data layer (4 repo impls, 5 services)
- [ ] Presentation (3 BLoCs, 6 screens, 15+ widgets)
- [ ] Background tracking (iOS + Android)
- [ ] Data export/import
- [ ] Tests (75%+ coverage)
- [ ] Documentation

## 📊 Test Coverage Report
Domain: XX%
Data: XX%
Presentation: XX%
Overall: XX%

## 🐛 Known Issues
### Critical
[List issues that block release]

### High
[Should fix before release]

### Medium
[Can fix in v1.1]

## ⚡ Performance Benchmarks
- Calendar render (500 visits): XXms
- Statistics calculation: XXms
- Background ping: XXms

## 🔧 Technical Debt
1. [Debt item]
   - Why: [reason]
   - Impact: [performance/maintainability]
   - Priority: HIGH/MEDIUM/LOW

## 🚀 Production Readiness
- [ ] All features working
- [ ] No critical bugs
- [ ] Tests passing
- [ ] Documentation complete
- [ ] Performance acceptable

### Recommendation
[ ] READY FOR RELEASE
[ ] NEEDS FIXES (list critical issues)
[ ] NOT READY (major problems)

## 📋 v1.1 Roadmap
1. Map visualization
2. Visit merge UI
3. CSV export
4. Ukrainian localization
5. Advanced statistics

## 💡 Suggested Improvements
1. [Improvement] - Benefit: [...] - Effort: [...] - Priority: [...]

## 📝 Lessons Learned
### What Went Well
- [List successes]

### What Could Be Improved
- [List improvements]

### Challenges Faced
- [List challenges]
```

---

## ⚠️ CRITICAL RULES

**DO NOT:**
- ❌ Skip phases (sequential required)
- ❌ Skip tests (80%+ domain coverage)
- ❌ Hardcode API keys
- ❌ Use freezed for entities
- ❌ Mix architecture layers
- ❌ Leave TODO without explanation
- ❌ Commit with analyze warnings
- ❌ Move to next phase with failing tests

**DO:**
- ✅ Complete phase checklist before next
- ✅ Write tests alongside code
- ✅ Run `flutter analyze` after each phase
- ✅ Run `flutter test` after each phase
- ✅ Document complex logic
- ✅ Use logger (not print)
- ✅ Handle all errors gracefully
- ✅ Test on both platforms

---

## 🎯 Success Criteria

**MVP is ready when:**

✅ User can manually add visits  
✅ App tracks location hourly in background  
✅ Geocoding works (Google Maps)  
✅ Statistics show correct days (both rules)  
✅ Calendar view matches screenshot  
✅ All 4 view modes work  
✅ Overlap validation works  
✅ Tests pass (75%+ coverage)  
✅ No critical bugs  
✅ Documentation complete  

---

## 🚀 Getting Started

**Your First Command:**
```bash
flutter create daystracker --org com.yourorg
cd daystracker
# Then begin Phase 1
```

**Remember:**
- Complete phases sequentially (1 → 9)
- Test everything as you build
- Document as you go
- Perform self-review at the end
- Ask if requirements unclear

**Good luck! Build something amazing! 💪**