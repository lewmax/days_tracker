# Testing

This document describes how to run and extend tests for DaysTracker.

---

## Running tests

```bash
# All tests
flutter test
# or with FVM
fvm flutter test

# With coverage
flutter test --coverage
```

Coverage is written to `coverage/lcov.info`. You can generate an HTML report with [lcov](https://github.com/linux-test-project/lcov) if installed:

```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Test structure

Tests mirror the `lib/` layout:

```
test/
├── core/
│   └── utils/          # date_utils, location_utils, country_flag_utils
├── domain/
│   ├── entities/       # Country, City, Visit, DailyPresence, etc.
│   ├── enums/          # TimePeriod, DayCountingRule, VisitSource, etc.
│   └── usecases/       # CreateVisit, UpdateVisit, GetStatisticsSummary, etc.
└── presentation/
    └── blocs/          # VisitsBloc, StatisticsBloc, SettingsBloc
```

- **Domain:** Entities (equality, copyWith, factories), enums (values, labels), use cases (success/failure paths with mocked repositories).
- **Presentation:** BLoC tests with `bloc_test`; mocks for use cases.

No integration or widget tests in the current suite; focus is on domain logic and BLoC behavior.

---

## What is covered

- **Core utils:** Date range, parsing, day counting; coordinate validation; country flag mapping.
- **Domain entities:** Construction, copyWith, equality, toString.
- **Domain use cases:** Validation (empty ID, date order, overlap), repository success/failure, delegation to repos.
- **BLoCs:** Initial state, load → loading → loaded/error, events (view mode, period, day counting rule, export/import, etc.).

---

## Writing new tests

1. **Use case tests:** Mock the repository (or dependencies), call the use case, assert on `Either` (Left = failure, Right = success).
2. **BLoC tests:** Use `blocTest<Bloc, Event, State>` from `bloc_test`; provide mocked use cases in the BLoC constructor; assert emitted states with `expect`/`emitsInOrder`.
3. **Mocks:** Manual mock classes that implement the interface and expose setters or stored results for tests (no mockito in current setup).

---

## Coverage goals

- **Domain layer:** Target 80%+ line coverage (entities, use cases, enums).
- **Overall lib/:** Lower due to untested data layer and UI; increase with integration or widget tests if needed.

Run `flutter test --coverage` and inspect `coverage/lcov.info` (or the HTML report) to see per-file coverage.
