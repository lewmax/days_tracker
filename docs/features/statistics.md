# Feature — Statistics

> Penpot: `04 – Statistics` (`Top countries`, `Top cities`, `Top continents`, `Top week`, `Country cities`, `Continent detail`, `Empty — period`, `Loading`).

## Overview

`Statistics` answers "where did I spend my days?" with **one active period** and **one active category** at a time. The screen is an **answer surface**, not a dashboard: changing a chip swaps the content **in place** without tab animation. Schengen does **not** appear on this tab — it has its own surface (`schengen.md`).

## User stories

- As a user, I want to filter by period (`All`, `This year`, `Prev year`, `Last 183 days`) and see the answer change immediately.
- As a user, I want to flip between `Top countries`, `Top cities`, `Top continents`, and `Top week` without leaving the screen.
- As a user, I don't want to see chips that wouldn't produce meaningful data — they should be hidden, not disabled.
- As a user looking at `Top countries`, I want to tap a country to see its cities for the same period.
- As a user looking at `Top continents`, I want to tap a continent to see its countries (with nested cities).
- As a user, I want a calendar-style alternative for visualising presence patterns over time.

## Period chips

Always pill-shaped (matches Timeline / brief style):

- `All` — default; all confirmed history.
- `This year` — `[Jan 1 (local), today (local)]`.
- `Prev year` — previous full calendar year. **Hidden** when the previous calendar year does not contain enough confirmed data to feel meaningful (rule: at least 7 confirmed days in that year).
- `Last 183 days` — trailing 183-day window inclusive.

Selected chip uses the teal label + thin teal outline variant.

## Category chips (conditional)

Hidden when the dataset can't support a real comparison:

| Chip | Visible iff |
|---|---|
| `Top countries` | confirmed visits span **≥2 distinct countries** in the active period |
| `Top cities` | confirmed visits span **≥2 distinct cities** in the active period |
| `Top continents` | confirmed visits span **≥2 distinct continents** in the active period |
| `Top week` | total confirmed days in the active period ≥ **14** AND at least one rolling 7-day window contains **≥2 unique confirmed cities** |

If only one chip is eligible, that view renders without the chip strip. If none are eligible, the screen renders the `Empty — period` frame.

## Per-category content

### `Top countries` → frame `Statistics / Top countries`

- One **country summary card** per ranked country (Timeline country-group style).
- Chips per card (informational, wrap):
  - `{pct}%` — share of period confirmed days.
  - `{d}d` — days in country within period.
  - `{n} cities` — distinct cities (show even when `n == 1`).
- Whole card is tappable → `CountryCitiesRoute(countryCode, period)` (`Statistics / Country cities`).
- Sort: `pct` desc, then `days` desc.

### `Top cities` → frame `Statistics / Top cities`

- One **city summary card** per ranked city (Timeline city-row style).
- Chips per card: `{d}d`, `{pct}%`.
- Sort: `pct` desc.

### `Top continents` → frame `Statistics / Top continents`

- One **continent summary card** per ranked continent.
- Chips: `{pct}%`, `{d}d`, `{n} countries`, `{m} cities`.
- Whole card tappable → `ContinentDetailRoute(continentCode, period)` (`Statistics / Continent detail`).
- Sort: `pct` desc.

### `Top week` → frame `Statistics / Top week`

- Single **summary card** with chips: `{start}–{end} {Mon} {Year}`, `{n} cities`, `7d`.
- Below: nested **country → city** list using Timeline / Chronological card pattern, for places touched in the window.
- Selection rule: scan rolling 7-day windows over the active period; pick the one with the most distinct confirmed cities. **Tie-break: most recent window** (placeholder; confirm — see `architecture.md` §16.7).

## Drill-ins

### `Statistics / Country cities`

- Entry: tap a country card in `Top countries`.
- App bar: back to `Top countries`; title shows country flag + name.
- Body: scrollable city cards (Timeline city-row style); chips per row: `{d}d`, `{pct}%` (share of period days).
- Sort: `pct` desc; days as tie-break.

### `Statistics / Continent detail`

- Entry: tap a continent card in `Top continents`.
- App bar: back to `Top continents`; title shows continent name (and optional emoji/icon per design system).
- Body: country cards sorted by `pct` desc; each country card **nests** city rows/cards inside, also sorted by `pct` desc.
- Chips on country headers may repeat `Top countries` metrics or stay minimal — designer choice in Penpot.

## Top-level states

| State | Frame |
|---|---|
| Empty for active period | `Statistics / Empty — period` (copy: switch period or add visits from Timeline) |
| Loading | `Statistics / Loading` (skeleton rows + reassurance) |

## Calendar-style view

- Alternative view mode (toggle from app bar). Renders a calendar where each day is shaded by presence (e.g. country colour, neutral fill for "had a confirmed visit"). Out of scope to define exact visuals here — defer to Penpot extension.

## Domain impact

- `StatisticsRepository`:
  - `topCountries(period)`, `topCities(period)`, `topContinents(period)`, `topWeek(period)`, `citiesInCountry(code, period)`, `countriesInContinent(code, period)`, `hasEnoughDataForPrevYear()`.
- `ReferenceDataRepository.loadCountries` / `loadContinents` — needed for flags and continent display.
- All math is **confirmed-only**; possible visits are excluded from headline numbers.
- All percentages on a screen share the **same denominator** (total confirmed days in the active period) so rows compare cleanly.

## Acceptance criteria

- [ ] Period and category chips render only when their visibility rule passes.
- [ ] Switching a chip swaps the content in the same surface — no tab animation, no route change.
- [ ] All cards reuse the **Timeline** country-group / city-row visual vocabulary (chips muted, not the teal "selected filter" state).
- [ ] All `%` values share the same denominator within one screen.
- [ ] Tapping a country card in `Top countries` opens `Country cities` for that country and period.
- [ ] Tapping a continent card in `Top continents` opens `Continent detail` for that continent and period.
- [ ] `Top week` renders the rolling 7-day window with the most unique confirmed cities; ties resolved per the documented rule.
- [ ] `Empty — period` appears when no confirmed days fall in the active period; copy nudges towards switching period or adding visits.
- [ ] Loading frame matches `Statistics / Loading`.
- [ ] Schengen content is **never** shown on this tab.
- [ ] Date chips use **short month names** consistent with Timeline.

## Open questions / future work

- Tie-breaking rule for `Top week` (most recent vs earliest) — currently spec'd as most recent.
- Threshold for `Prev year` "enough data" — currently 7 confirmed days; confirm with product.
- Calendar-style view — visual details deferred to Penpot.
- Performance: large histories (multi-year) may benefit from precomputed daily aggregates in Drift; if needed, add a cache table.
