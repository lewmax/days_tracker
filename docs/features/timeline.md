# Feature — Timeline (Calendar + Chronological)

> Penpot: `03 – Timeline` (`Calendar / *`, `Chronological / *`, `Day Detail / *`, `Help / PossiblePlaces`, `Empty`, `Loading`, `Error`).

## Overview

`Timeline` is the default landing surface and answers "what visits are logged and when?". It has **two modes only**:

- **Calendar** — month grid; days show country flags; tapping a day opens `Day Detail`.
- **Chronological** — list of country groups (newest first by end date) with nested city rows.

The mode toggle lives at the top of the screen. State is preserved per tab so the user can return to the same scroll position.

The FAB (`+`) sits **above** the bottom tab bar in z-order, fixed to the bottom of the viewport, in both modes.

## User stories

- As a user, I want to scan recent travel by month visually.
- As a user, I want to scroll through a chronological list of countries and stays.
- As a user, I want to tap a calendar day to see what places I was in that day.
- As a user, I want to tap a city row to inspect / edit a specific stay.
- As a user, I want a one-tap action to add a new visit from anywhere in Timeline.

## Modes & states

### Calendar mode

| State | Frame | Notes |
|---|---|---|
| Normal | `Calendar / Month` | Month nav header; weekday strip; 6×7 day grid; days with confirmed visits show **country flag**; today is highlighted. |
| Sparse | `Calendar / MonthSparse` | Few days have flags; rest are blank. |
| Dense | `Calendar / MonthDense` | Every day has at least one flag. |
| Today highlighted | `Calendar / MonthToday` | Today's cell visually emphasised. |
| Multiple flags per day | `Calendar / MonthMultiFlag` | Day cell shows up to N flags (design caps overflow). |
| Empty month | `Calendar / MonthEmpty` | No flags; empty hint copy. |
| Loading | `Calendar / Loading` | Skeleton grid. |

Tapping a day → `Day Detail`.

### Day Detail (Calendar-only entry)

| State | Frame | Notes |
|---|---|---|
| Normal | `Calendar / Day Detail` | Header carries the calendar day. Place rows for that day, using the **same chip vocabulary** as Chronological. |
| Multi-country, multi-city | `Calendar / Day Detail / MultiCountryMultiCity` | Multiple grouped rows. |
| Possible mixed | `Calendar / Day Detail / PossibleMixed` | Possible (`Unconfirmed`) rows show a **full-height amber stripe** on the left. |
| Heavy stack | `Calendar / Day Detail / HeavyStack` | Stress test for stacked rows; vertical spacing must equal row height + gap so cards never overlap. |
| Delete dialog | `Calendar / Day Detail / DialogRemoveVisit` | `Delete visit?` confirm. |

`+` on Day Detail → `AddVisitRoute(date: thisDay)` (date is fixed; only city editable). See `visits.md`.

### Chronological mode

| State | Frame | Notes |
|---|---|---|
| Normal | `Chronological / Normal` | Country groups (flag + name as primary title) + **wrapping chip strip** + nested city rows. |
| Possible mixed | `Chronological / PossibleMixed` | Possible city rows render with **left amber stripe** + `Unconfirmed` amber chip. |
| Multi-country / multi-city | `Chronological / MultiCountryMultiCity` | Stress test for nested complexity. |
| Two countries with repeats | `Chronological / TwoCountriesRepeatVisits` | Five cities per country with repeat visits; FAB scroll-overlap check. |
| Delete dialog | `Chronological / DialogRemoveVisit` | `Delete visit?` confirm. |

Tapping a **city row** → `VisitDetailRoute(visitId)` (edit dates only; see `visits.md`). Tapping the **country header** does **nothing** in Chronological — no navigation.

### Country group header (chip rules — Chronological)

Chips use the same pill pattern as Statistics period filters: muted fill, secondary label inside; selected variant adds teal label + thin teal outline (only when an actual filter is selected). On Chronological, treat all stat chips as **informational (default)**.

Conditional chip rules:

- `{n} cities` — show only when `n > 1`.
- `{m} visits` — show only when `m > 1` (never show `1 visit`).
- `{d} days` — show only when `d > 1` (never show `1 day`).
- Date chip when `d == 1` → `{day} {Mon}` (e.g. `4 Jan`).
- Date chip when `d > 1`:
  - same month → `{d1}-{d2} {Mon}` (e.g. `2-12 Feb`).
  - cross month → `{d1} {Mon1} - {d2} {Mon2}` (e.g. `31 Jan - 4 Feb`).

### City / stay row (Chronological)

- City name = primary label.
- Same chip vocabulary, applied to a single stay:
  - single calendar day → `{day} {Mon}` only (no `1 day`).
  - multi-day → `{N} days` + range chip with same-month / cross-month rules.
- Sort: visit rows under a country are ordered **newest to oldest by end date**.

### Top-level states (both modes)

| State | Frame |
|---|---|
| Empty (no visits ever) | `Timeline / Empty` |
| Loading | `Timeline / Loading` |
| Error | `Timeline / Error` |

## Help · Possible places

`Timeline / Help / PossiblePlaces` — opens from a help affordance (e.g. info icon next to a possible row); explains the `Unconfirmed` flow and shows an example row matching `PossibleMixed` styling.

## Domain impact

- Reads `VisitRepository.list` / `watch`.
- Reads `ConfirmationRequestRepository` (or equivalent) to render `Unconfirmed` rows.
- No mutations from Timeline itself; all writes flow through the Visits feature.
- Statistics chips on Chronological use **derived counts** computed in the BLoC from the loaded visit list — they do NOT call `StatisticsRepository`.

## Acceptance criteria

- [ ] Mode toggle persists per tab session (returning to Timeline preserves the chosen mode).
- [ ] Calendar grid renders flags only for days with at least one **confirmed** visit.
- [ ] Tapping a Calendar day opens `Day Detail`; tapping the back arrow returns to Calendar with the same month visible.
- [ ] Day Detail `+` opens Add Visit with the date fixed.
- [ ] Chronological orders country groups by **most recent end date** (descending) and city rows under each by the same rule.
- [ ] Country header chips obey the conditional rules (no `1 day` / `1 visit` chips; correct same-month / cross-month formatting).
- [ ] Tapping a country header in Chronological does nothing (no nav).
- [ ] Tapping a city row in Chronological opens `VisitDetailRoute` (edit dates only).
- [ ] Possible rows render with a **full-height amber stripe** and an `Unconfirmed` amber chip; never mixed silently into confirmed counts.
- [ ] FAB stays fixed to the bottom of the viewport and above the bottom tab bar in both modes; not part of the scroll list.
- [ ] Empty / Loading / Error frames are reachable and match Penpot.
- [ ] Date strings everywhere use **short month names** (`Jan`, `Feb`, …).

## Open questions / future work

- Multiple flags per day — design caps overflow (e.g. show first 3 + `+N`); confirm exact cap.
- Quick-edit affordance from Day Detail without going through Visit Detail — out of scope for MVP.
- Pinned "today" jump button when the user has scrolled far in either mode — out of scope; consider after usage data.
- "Possible" row promotion from Day Detail directly — currently happens through Settings / inline confirm prompt; unify in a future iteration.
