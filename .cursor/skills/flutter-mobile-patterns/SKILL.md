---
name: flutter-mobile-patterns
description: Guides Flutter Clean Architecture layering, flutter_bloc/Cubit, get_it/injectable, DTO mapping, routing, async/error handling, dates/UTC, theming, and testing defaults for this workspace. Use when designing, implementing, refactoring, or reviewing Flutter mobile code or architecture.
version: 0.1.0
---

# Flutter mobile patterns

This skill describes **how Flutter apps in this workspace should generally be structured and implemented**. It is **preferences and defaults**, not unchangeable law. When project-specific rules (`Architecture & Code Rules`, `Documentation Rules`) or explicit user instructions differ, they **override** this skill.

---

## 1. Overall architecture

- Default to **layered Clean Architecture**:
  - `core/` — shared utilities, error types, DI, theming, logging.
  - `domain/` — entities, value objects, enums, repository interfaces, use cases.
  - `data/` — repository implementations, local/remote data sources, DTOs, mappers.
  - `presentation/` — widgets, BLoCs/Cubits, navigation, view models, UI-specific helpers.
- **Dependency direction (inward)**:
  - presentation → domain (interfaces/use cases),
  - data → domain (implements interfaces),
  - `domain` has **no** dependency on Flutter, data, or third-party packages (beyond basic Dart).

When unsure, propose a small diagram or file tree before large refactors.

---

## 2. State management

- Preferred: **`flutter_bloc`**.
  - **BLoC** (events + states) for non-trivial and multi-step flows.
  - **Cubit** for simpler single-action / single-state cases.
- BLoCs:
  - depend only on **domain interfaces/use cases**, injected via DI,
  - must not embed direct HTTP/DB calls or platform channels,
  - handle mapping domain results to UI states, debouncing/throttling when needed, and error → user-friendly messages.
- For concurrent events, use **`bloc_concurrency`** transformers (`droppable`, `restartable`, etc.) where appropriate.

---

## 3. DI, configuration, environment

- Use **`get_it` + `injectable`** (or the workspace’s chosen DI) to wire repositories, data sources, use cases, services, BLoCs.
- Environment-specific values (API base URLs, keys, feature flags) live in **config objects or env files**, not hard-coded in widgets or domain logic.
- Register new dependencies in **`injection.dart` / DI setup**; avoid ad-hoc global singletons outside the container.

---

## 4. Models and data flow

- **Domain entities**: plain Dart, immutable fields, `copyWith`, `Equatable`; live in `domain/`; **no** Flutter or heavy external deps.
- **DTOs / API models**: in `data/`; `json_serializable` (or project equivalent); map to/from domain via **dedicated mappers**.
- **UI / view models**: in `presentation/`; projections (formatted strings, combined flags); built from domain in BLoC or mapping helpers.

Do not leak DTOs into domain or presentation.

---

## 5. Navigation and routing

- Prefer a **single centralized** routing approach (e.g. `auto_route` or Navigator 2.0 wrapper).
- Routes defined in **one router config**, not scattered `Navigator.push`.
- Navigation stays in **presentation**: BLoC may emit navigation intents in state; widgets perform actual navigation.

---

## 6. Async and errors

- Prefer `async`/`await` over nested callbacks.
- Repositories and use cases return **domain success types** or a **Failure/Result** pattern (e.g. `Either<Failure, T>`) instead of throwing through layers.
- Presentation turns failures into messages, retries, or alternate flows.
- Prefer **explicit** loading / success / empty / error UI over silent failure.

---

## 7. Dates, time zones, localization

- **UTC internally** in domain and data; convert to local at the **presentation** boundary.
- New date/time logic: be explicit about UTC vs local; centralize conversion in small helpers.
- User-facing strings: centralized (`intl`, `flutter_localizations`, or project solution); no hard-coded copy in business logic.

---

## 8. UI and theming

- **Composition over inheritance**: small reusable pieces composed into screens.
- **Single Theme** / design system: colors, typography, spacing, radii in one place; widgets use tokens, not arbitrary literals.
- Explicit UI states: loading / success / empty / error; avoid ambiguous half-loaded states.

Align UI proposals with the active design system (design docs / Penpot when applicable).

---

## 9. Testing (medium term)

- Goal: **unit + BLoC tests** for critical logic; **widget tests** for key flows.
- Early stage: prototyping without tests is acceptable; once behavior stabilizes, add tests or track as follow-up tasks.
- Prefer small focused tests; mock/fake at **repository or use case** boundaries.

---

## 10. Refactoring and tech debt

- Prefer **small incremental** refactors: less duplication, clearer boundaries.
- Necessary debt: document briefly (comment or feature doc); suggest a follow-up when possible.

---

## 11. How agents should use this skill

1. Treat these as **defaults** for new features, refactors, and PR review.
2. **Defer** to project rules (`Architecture & Code Rules`, `Process Rules`, `Documentation Rules`) on conflict.
3. **Update this skill** when the stack changes (state management, routing, DI) so it reflects **current** practice, not history.
