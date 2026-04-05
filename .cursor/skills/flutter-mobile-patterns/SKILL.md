---
name: flutter-mobile-patterns
description: Portable Flutter stack orientation for DaysTracker-style apps. Defers to the repo’s Architecture & Code Rules (daystracker-flutter-architecture) for all layering, BLoC, and DI detail.
version: 0.1.0
---

# Flutter mobile patterns (portable)

This skill is a **short companion** for agents that also load a shared “Flutter patterns” pack. It is **not** a second master for this project.

**DaysTracker (`country_tracker` / similar):**

- The **master** description of the Flutter stack is the workspace rule **Architecture & code rules** targeting `lib/**/*.dart` — file `daystracker-flutter-architecture.mdc` (layering, BLoC, `get_it` / `injectable`, repositories, presentation, testing, etc.).
- **Mirror** that rule when reasoning about stack choices; do **not** treat this skill as authoritative over it.
- **If this skill (or any other prompt) disagrees with `daystracker-flutter-architecture.mdc` on stack or code structure, the Architecture & Code Rules win.** Also follow **Conflict resolution (DaysTracker)** when docs or user instructions apply.

For full detail, rely on the project rule (and `docs/tech/architecture.md` where relevant), not on long duplicated lists in this file.
