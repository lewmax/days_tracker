# Feature — Map

> Penpot: `05 – Map` (`Map / Normal` — additional frames for `Empty`, `MultiCountryOneDay`, and `Display cities` toggle states are referenced in the brief but **not yet drawn**; flagged as design work).

## Overview

`Map` shows the user's travel footprint visually on a real map, with visited countries filled and an optional layer of city pins. It is also the **primary entry point** for `Year Rewind` (`Rewind {year}` button) when the active year filter is on a completed calendar year.

Renderer: **`mapbox_gl`** (per `architecture.md`). Country fills come from a bundled GeoJSON dataset; city pins are clustered at low zoom.

## User stories

- As a user, I want to see which countries I've visited shaded on a real map.
- As a user, I want to switch the year filter to focus a specific year.
- As a user, I want to toggle city pins on/off depending on whether I'm browsing or zooming in to detail.
- As a user, I want to tap a country or city to see how many days I've spent there.
- As a user, when I'm looking at a completed year, I want a clear way to open Year Rewind for that year.

## Layout

- Map fills the full screen under the bottom tab bar.
- **Year chips** at the top (e.g. `All`, `2026`, `2025`, `2024`, …). The set is bounded by the years with confirmed visits.
- A **raised dark card** floats below the year chips containing the **Display Cities?** toggle (track + knob, iOS-style switch). Subcopy: *Pins for places you've logged*.
- **On-map controls** stacked on the right: zoom in/out, current location, north/compass.
- **Rewind {year}** button (when eligible) appears as a pill above the bottom tab bar.

## Year filter

- Chips at the top filter the **footprint** (which countries are filled and which cities have pins) and drive `Rewind {year}` eligibility.
- `All` is the default.
- A specific year `Y` shows only confirmed visits intersecting that calendar year.

## Display Cities? toggle

- **On:** show city pins for the current scope.
  - Below a configurable zoom threshold, pins **cluster** with a count badge.
  - Above the threshold, individual pins render with the city label on tap.
- **Off:** only country fills, no pins. Calmer for high-level scanning.

## Country fills

- Visited country = country containing **≥1 confirmed visit** in the active scope.
- Fill colour pulls from `secondary` token (or `primary.muted` per design — pick during Penpot extension).
- Fills come from a bundled GeoJSON dataset keyed by ISO-3166 alpha-2.

## Tap interactions

- **Tap a filled country** → opens a small bottom sheet summary: country name + flag, total days in active period, distinct city count, button to open `Statistics / Country cities` for that country in the active period.
- **Tap a city pin (or expanded cluster pin)** → opens a similar sheet: city name, country, total days in scope, button to open `VisitDetailRoute` for the most recent visit there (or a list when multiple).
- **Tap a cluster pin** → zoom in (Mapbox default behaviour) until pins separate.

## Rewind {year} button

- Appears on `Map` only when **both**:
  - The active year filter `Y` is **complete** (today local ≥ `1 January Y+1`), and
  - The user has visited **≥3 distinct cities all-time** (per `domain_model.md`).
- If the year filter is `All`, the button does **not** appear (no specific year to rewind).
- Tapping opens `RewindRoute(year)` — see `year_rewind.md`.

## States

| State | Frame | Notes |
|---|---|---|
| Normal | `Map / Normal` | At least one confirmed visit in the active scope. |
| Empty (no visits in scope) | **TBD — to draw in Penpot** | Map renders without fills/pins; copy hints to add visits or change year. |
| One-day multi-country | **TBD — to draw in Penpot** | Stress test for fills + pins on a busy day. |
| Display cities toggle off | **TBD — to draw in Penpot** | Country fills only. |
| Schengen entry | (component) | Floating Schengen pill / summary tile per Penpot — opens `SchengenDetailRoute`. |

## Domain impact

- Reads `VisitRepository.list({fromUtc, toUtc, ...})` filtered by year scope.
- Reads `ReferenceDataRepository.loadCountries` for flags / names.
- Calls `StatisticsRepository.topCountries(period)` and `citiesInCountry(...)` to produce the tap-summary numbers (period derived from year filter).
- Reads `RewindRepository.eligibleYears` to gate the `Rewind {year}` button.
- Reads `SchengenRepository.currentStatus` if the Schengen entry surface is shown.

## Routing

- `MapRoute` (tab 3 in shell).
- Pushes:
  - `RewindRoute(year)` from the Rewind button.
  - `SchengenDetailRoute` from the Schengen entry.
  - `CountryCitiesRoute(...)` / `VisitDetailRoute(...)` from tap summaries.

## Acceptance criteria

- [ ] Map renders using `mapbox_gl` with the configured style and Mapbox API key from `--dart-define`.
- [ ] Year chips reflect the years with confirmed visits, `All` always present.
- [ ] Country fills update when the year filter changes.
- [ ] `Display Cities?` toggle controls pin visibility; clusters appear at low zoom.
- [ ] Tapping a country opens a summary with link to `Statistics / Country cities`.
- [ ] Tapping a city pin opens a summary with link to the relevant Visit Detail.
- [ ] `Rewind {year}` button visibility obeys the **(1) Y completed** AND **(2) ≥3 cities all-time** rule.
- [ ] On-map controls (zoom, locate, compass) are present and functional.
- [ ] When offline: map tiles may degrade gracefully (greyed background); country fills from bundled GeoJSON still render.
- [ ] Schengen content does not render on this tab unless explicitly via the dedicated Schengen entry surface.

## Open questions / future work

- Penpot frames for `Map / Empty`, `MultiCountryOneDay`, `Display cities` on/off — not drawn yet. Needs design pass.
- Cluster pin appearance (count badge styling, max cluster size) — defer to Penpot.
- Offline tile pack support — out of scope for MVP.
- Country boundary GeoJSON dataset choice — pending (`architecture.md` §16.5).
- Heatmap/density alternative to fills — not in scope.
