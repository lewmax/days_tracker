# Feature — Import data (JSON + Photos)

> Penpot: `09 – Import data` (`ImportData / {Hub, HubHelp, JSONConfirm}`, `ImportPhotos / {Permission, Scanning, Results, ResultsSwipe, Done, NoResults, Error}`).

## Overview

The Import surface centralises every way to bring history into the app:

- **JSON** — restore from a previous export.
- **Photos** — derive suggested visits from photo metadata (location only, never photo content).

Both branches enforce a **review-before-save** model: nothing is written to the user's history without explicit confirmation.

Entry points: `Settings → Import data` and the **Onboarding** photo path (which deep-links into `ImportPhotosRoute`).

## User stories

- As a returning user, I want to restore my exported history from a JSON file with one confirmation.
- As a new user, I want to seed my history from photos I already have, without revealing the photos themselves to the app.
- As a user reviewing photo suggestions, I want to accept all, accept some, edit dates, or dismiss — fast.
- As a user, I want clear privacy messaging before any permission request.

## Hub (`ImportData / Hub`)

- Title `Import data`.
- Two primary cards:
  - `Restore from JSON` — opens `ImportData / JSONConfirm` after the user picks a file.
  - `Import from Photos` — opens `ImportPhotos / Permission`.
- Help affordance (`?` icon) opens `ImportData / HubHelp` — short explainer, plain-language.

## JSON branch

| State | Frame | Notes |
|---|---|---|
| Confirm | `ImportData / JSONConfirm` | Shows summary of the file (`N visits`, `M cities`, `K countries`, `date range`). User picks a merge strategy: `Replace all data` (destructive, requires extra confirm) or `Merge non-conflicting` (default — adds visits that don't overlap existing confirmed visits). |
| Apply | (transient progress) | One-shot operation; on success returns to Settings or Onboarding with a brief toast. |
| Failure | (inline) | Validation errors surface in the confirm sheet; the import doesn't run. |

Validation:

- File must be a recognised DaysTracker export schema (versioned).
- Visits must respect domain invariants (`startUtc <= endUtc`, city present).
- Conflicting visits (overlap with existing **confirmed** visits) are surfaced per row in the confirm sheet; `Merge non-conflicting` skips them, `Replace all data` overwrites.

## Photos branch

| State | Frame | Notes |
|---|---|---|
| Permission | `ImportPhotos / Permission` | Privacy-first explainer: *We only read location tags from your photos.* `Continue` triggers the OS permission flow. |
| Scanning | `ImportPhotos / Scanning` | Progress indicator + reassurance copy (e.g. `Looking through location tags…`). |
| Results (list) | `ImportPhotos / Results` | List of suggestions grouped by city + date range. Each row: `{City}, {Country}` + `{N photos}` chip + `{date range}` chip + confidence label `Confirmed` or `Possible`. Bulk action `Accept all` at the top; per-row `Accept` / `Edit` / `Dismiss`. |
| Results (swipe) | `ImportPhotos / ResultsSwipe` | One-at-a-time swipe variant (right = accept, left = dismiss, tap = edit). |
| No results | `ImportPhotos / NoResults` | No photos with location tags found. Calm copy + retry / done. |
| Done | `ImportPhotos / Done` | Summary: `Added {N} visits`. Returns to Timeline (or Onboarding completion). |
| Error | `ImportPhotos / Error` | Permission denied, scan failed, geocoder error. Calm copy + retry where possible. |

Suggestion edit:

- Editing a suggestion opens the same date picker (`AddVisit / DialogCalendar`) used by the Visits feature.
- City is **not** editable in MVP photo flow (the location tag determined it).
- Edited suggestions retain `decision = edited` and apply with the user's date range.

## Confidence labels (photos)

- `Confirmed` — sufficient photo density (e.g. ≥3 photos within the date range, or photos on multiple days within the range). Visual: neutral chip.
- `Possible` — sparse evidence (single photo, ambiguous geography). Visual: amber chip; the resulting `Visit` keeps `confidence = possible` until the user reviews.

Exact thresholds — see `domain_model.md` §3 (`ImportSuggestion`); refined empirically post-MVP.

## Domain impact

- Entities: `ImportSession`, `ImportSuggestion`, `Visit`, `City`.
- Repositories:
  - `JsonImportExportRepository.importFromFile(path, strategy)`.
  - `PhotoImportRepository.ensurePermission`, `startScan`, `watchSession`, `listSuggestions`, `updateSuggestion`, `applyAccepted`, `cancel`.
  - `GeocodingRepository.reverseGeocode` — needed to resolve photo coordinates to cities (offline pings deferred analogously to background tracking).
- Writes happen only when the user confirms (`applyAccepted` / JSON `Apply`).

## Routing

- `ImportHubRoute` — pushed from `Settings → Import data`.
- `ImportPhotosRoute` — pushed from the hub OR deep-linked from Onboarding.
- The JSON confirm sheet renders inside `ImportHubRoute` as a modal — no separate route needed.

## Acceptance criteria

- [ ] Hub renders both `Restore from JSON` and `Import from Photos` with equal weight.
- [ ] JSON import requires explicit merge-strategy selection; `Replace all data` requires an extra destructive confirm.
- [ ] JSON import validates the file schema and refuses malformed input with a clear inline error.
- [ ] Conflicts on `Merge non-conflicting` are listed per row and skipped.
- [ ] Photos branch shows the privacy explainer **before** triggering the OS permission prompt.
- [ ] Photo scan never reads photo contents — only EXIF / location metadata.
- [ ] Suggestions are listed with city, country, date range, photo count, confidence label.
- [ ] Bulk `Accept all` works; per-row `Accept` / `Edit` / `Dismiss` works.
- [ ] Editing a suggestion opens `AddVisit / DialogCalendar`; city stays read-only in this flow.
- [ ] `ResultsSwipe` variant supports right-accept / left-dismiss / tap-edit gestures.
- [ ] Applying creates `Visit`s with `origin = photoImport`; `confirmed` for `Confirmed` suggestions, `possible` for `Possible` suggestions.
- [ ] `Done` frame summarises the count and returns the user to Timeline (or Onboarding completion).
- [ ] All copy is calm and plain-language; no legal disclaimers in the photo flow itself (the photo permission OS prompt does the real ask).

## Open questions / future work

- Photo-metadata reader package — TBD (`architecture.md` §16.2).
- Confidence thresholds — placeholders; refine after first dogfood.
- Inline city edit on suggestions — out of scope for MVP.
- Cloud photo libraries (iCloud, Google Photos) — out of scope.
- Background "drip" import as new photos arrive — out of scope.
- JSON export schema versioning + migration — single version in MVP; add a migrator when schema evolves.
