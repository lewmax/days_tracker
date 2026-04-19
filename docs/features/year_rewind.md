# Feature — Year Rewind (and Rewinds history)

> Penpot: `07 – Map / Year rewind` (`Year rewind / {Idle, SheetClosed, Playing, Stopped, Loading, Error, FilteredEmpty}`, `Rewinds / {List, Empty}`).
> **Note:** the design brief mentions a separate `12 – Rewinds` page, but in the actual Penpot file the Rewinds frames live on page `07`. This spec aligns with the file.

## Overview

Year Rewind is a secondary lens on the Map: for a **completed calendar year**, it shows the user's confirmed visits as a connected route on the map, with **playback** (play/stop), **progress**, and a **bottom snap sheet** containing the chronological list. It is framed as a **visit-to-visit story** for the year, not a continuous GPS recap.

`Rewinds history` is a list of all eligible past years, opened from Settings.

## Eligibility (hard rule)

For a calendar year `Y`:

- Year Rewind exists iff `today (local) ≥ 1 January Y+1`. Example: `Rewind 2026` is available from `1 January 2027` onward.
- The `Map` button (`Rewind {year}`) **also** requires `confirmedDistinctCityCountAllTime ≥ 3`.
- `Settings → Rewinds history` lists **all** eligible years, even when the user is below the 3-city threshold (the list itself can still be empty).

## Entry points

| Entry | Behaviour |
|---|---|
| `Map` `Rewind {year}` button | Pushes `RewindRoute(year)` for the map's active year filter, only when both eligibility conditions pass. |
| `Settings → Rewinds history` row → `Rewinds / List` | Lists eligible years (newest first); tap a row → `RewindRoute(year)`. |
| `Settings` optional `Check out Rewind {year}` row | Promotes the **latest completed** year (same Y+1 unlock); empty/teaser copy when that year has sparse data. |

## Screens & states

### Year rewind playback view

| State | Frame | Notes |
|---|---|---|
| Idle (sheet open) | `Year rewind / Idle` | Map shows the connected route + city pins; sheet at default ~40% open with chronological visit list. Play button visible. |
| Sheet collapsed | `Year rewind / SheetClosed` | Sheet snaps to ~10%; map is the focus. |
| Playing | `Year rewind / Playing` | Progress indicator advances; the highlighted visit on the map and in the sheet syncs. |
| Stopped | `Year rewind / Stopped` | Playback paused mid-sequence; user can resume or scrub. |
| Loading | `Year rewind / Loading` | Initial route + visits loading. |
| Error | `Year rewind / Error` | Map / data load failed; calm copy + retry. |
| Filtered empty | `Year rewind / FilteredEmpty` | Eligible year exists but no confirmed visits inside it (e.g. user was tracking but everything is `possible`). Copy: "No confirmed visits in {year} yet." |

### Rewinds history

| State | Frame | Notes |
|---|---|---|
| List | `Rewinds / List` | Title `Rewinds`. Rows: `Rewind {year}` with optional subtitle chips (e.g. `{n} cities` / `{m} countries`). Newest first. |
| Empty | `Rewinds / Empty` | No eligible years yet. Copy explains the unlock rule (`Y+1`). |

## Snap-sheet behaviour

- Default open state covers ~40% of the screen height; collapsed snap = ~10%.
- Sheet content = chronological list of visits in `Y`, grouped by country (Timeline-like card vocabulary).
- Tapping a visit row in the sheet:
  - Centres the map on the visit's city.
  - Highlights the visit in the sheet.
  - Does **not** open Visit Detail (this is a story view, not an edit surface).

## Playback rules

- Playback advances visit-by-visit (not day-by-day) along the connected route.
- Default speed: ~1 visit per 1.5 s; tap to pause/resume.
- The sheet auto-scrolls so the active visit stays visible.
- Stopping playback leaves the map and sheet on the current visit (state `Stopped`).

## Domain impact

- `RewindRepository.eligibleYears()` — returns all `Y` where `today >= Jan 1, Y+1` AND at least one confirmed visit intersects `Y`. (Years with only possible visits surface in the `FilteredEmpty` state when entered explicitly via `Map` button — but typically don't appear in the history list.)
- `RewindRepository.load(year)` — returns a `RewindSession` with `visits`, `cityCount`, `countryCount`.
- `SettingsRepository.readLastSeenRewindYear()` / `writeLastSeenRewindYear(year)` — drives the **`New`** chip on the Settings → Rewinds history row when a newly-eligible year hasn't been opened.
- `ReferenceDataRepository` — for country names + flags inside the sheet.

## Routing

- `RewindRoute(year)` — primary playback view.
- `RewindsHistoryRoute` — list view, accessed from `SettingsRoute`.

## Settings entry detail

- Section header: `REWINDS`.
- Row: primary label `Rewinds history` (typography matches `Import data`), optional **`Chip / New rewind`** (teal outline on dark fill) when there is a newly-eligible year unseen by the user; chevron `›` opens `Rewinds / List`.
- Optional secondary row `Check out Rewind {year}` highlights the latest completed year; same Y+1 rule. Hidden when no eligible year exists or when the latest is sparse.

## Acceptance criteria

- [ ] `Rewind {year}` is **never** offered for the current incomplete year.
- [ ] `Map` `Rewind {year}` button appears only when (a) the active year filter is a completed calendar year **and** (b) the user has ≥3 distinct confirmed cities all-time.
- [ ] `Settings → Rewinds history` lists all eligible years (newest first); opens `Rewinds / List`.
- [ ] `Rewinds / Empty` renders when no eligible years exist.
- [ ] Opening a year shows `Year rewind / Idle` with the snap sheet at ~40%.
- [ ] Playback progresses visit-by-visit; pause leaves state `Stopped`.
- [ ] Tapping a visit row in the sheet centres the map without opening Visit Detail.
- [ ] `FilteredEmpty` renders when an eligible year has no confirmed visits.
- [ ] Loading and Error frames are reachable and match Penpot.
- [ ] The `New` chip on the Settings row appears only when a newly-eligible year hasn't been opened by the user.

## Open questions / future work

- Should playback step day-by-day (with a per-day "where I was" highlight) instead of visit-by-visit? Currently visit-by-visit per brief.
- Sharing a rewind (export gif/video) — explicitly out of scope for MVP.
- Animations for the route line drawing in real time during playback — design call.
- Multi-year rewind (e.g. last 365 days regardless of calendar boundary) — out of scope.
- Persist last sheet snap position per year — minor polish; defer.
