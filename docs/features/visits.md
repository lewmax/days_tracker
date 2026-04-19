# Feature — Visits (create / edit / delete + Choose City)

> Penpot: `08 – Add Visit` (`AddVisit / *`, `CitySearch / *`); related entries from `03 – Timeline / Calendar / Day Detail` and `Timeline / Chronological`.

## Overview

A **visit** is a continuous stay in **one city** with a start and end date. This feature owns:

- Manual create (from Timeline FAB or Day Detail `+`).
- Edit (dates only — city is immutable per `domain_model.md`).
- Delete (with confirmation dialog).
- The shared **Choose City** flow used by create.

Visits created here become the canonical local record consumed by Timeline, Statistics, Map, Year Rewind, and Schengen.

## User stories

- As a user, I want to add a visit by picking a city and date range with minimal friction.
- As a user adding a visit from a calendar day, I want the date pre-set so I only choose the city.
- As a user, I want to use the map or a search field to pick a city — both should end in the same confirm state.
- As a user, I want to use my current location to pre-fill the city when creating a visit.
- As a user editing a visit, I want to change dates but **not** the place — the city should be greyed and read-only.
- As a user, I want to delete a visit with one extra confirmation step so accidents are reversible.

## Flows & states

### Create visit (default — from FAB)

| Step | Frame | Notes |
|---|---|---|
| Empty form | `AddVisit / CreateEmpty` | Title `Add visit`. City row empty (placeholder), prominent location button on the right; Date row empty. Save disabled. |
| Choose city | `CitySearch / *` (see below) | Returns selected `City`. |
| City selected | `AddVisit / CreateFilled` | City label set; chevron-less. Date row still empty until picker is opened. |
| Date range | `AddVisit / DialogCalendar` | Centred sheet on dim scrim; month nav `‹ ›`; Mon–Sun headers; teal in-range; summary `5 Mar – 12 Mar 2025`; `Cancel` / `Save range`. |
| Saving | `AddVisit / CreateSaving` | Save button shows spinner; form disabled. |
| Done | n/a | Pops back to Timeline (or whatever invoked it); list refreshes. |

### Create visit (from `Day Detail` `+`)

- Frame: `AddVisit / FromDayDetail` (variant of `CreateFilled`).
- The **date row is fixed** to the selected day and not editable. No date picker is reachable.
- Only the **city** field is editable (full Choose City flow available).

### Edit visit (from `Timeline / Chronological` city row → `Visit Detail`)

| Step | Frame | Notes |
|---|---|---|
| Open | `AddVisit / EditFilled` | Title `Edit visit` (or `Visit detail`). City row is **muted/secondary** colour, no chevron, no location button — read-only. Dates row is normal and editable. |
| Date range | `AddVisit / DialogCalendar` | Same dialog as create. |
| Delete | `AddVisit / EditDeleteDialog` | Confirm dialog: `Delete visit?` body + `Cancel` / `Delete`. |
| Saving / done | reuse `CreateSaving` shell | Returns to Timeline. |

### Choose City (city picker)

> Used **only** when **creating** a visit. Edit never opens this flow.

Initial state — `CitySearch / MapPickEmpty`:

- Top row = back button + **inline search field** in the same app bar row (no separate title bar).
- Map fills the rest of the screen below the app bar.
- User can long-press the map to drop a pin; on resolve, city name appears on/above the pin and a primary bottom button `Select this city: {City}` becomes visible.

Search-focused — `CitySearch / SearchFocused`:

- Tapping the search field hides the map and shows the keyboard + an empty results list.

Search results — `CitySearch / Results`:

- Typing populates a list of city options (powered by `GeocodingRepository.searchByName`).
- Tapping a row: hide the list, **show map again**, **zoom to that city**, **drop the pin**, update the search field text to the chosen option, and reveal `Select this city: {City}`.

No results — `CitySearch / NoResults`:

- Empty results message with a hint to drop a pin on the map instead.

Pin selected — `CitySearch / MapPinSelected`:

- The unified end state regardless of source (search vs pin). One `Select this city: {City}` confirm button.

**Use current location:**

- Prominent circular teal location button on the right of the city row in `AddVisit / CreateEmpty`.
- Triggers `GeocodingRepository.reverseGeocode(currentLat, currentLon)`; on success, fills the city field and skips Choose City.
- On permission denied or geocoding failure, surfaces an inline message and leaves the field empty.

## Domain impact

- **Entities:** `Visit`, `City`, `ConfirmationRequest` (when promoting a tracking suggestion is implicit, not part of this flow).
- **Repositories used:**
  - `VisitRepository.create` / `updateDates` / `delete`.
  - `GeocodingRepository.reverseGeocode` and `searchByName`.
- **Pure rules enforced (per `domain_model.md`):**
  - `startUtc <= endUtc`.
  - No overlap with existing **confirmed** visits — `ConflictFailure.visitOverlap` is surfaced as an inline error.
  - `cityId` is set on create and never modified on update.

## Acceptance criteria

- [ ] Create visit from Timeline FAB lands on `AddVisit / CreateEmpty` with both rows empty and Save disabled.
- [ ] City row in create has **no** chevron and **does** have a prominent circular location button.
- [ ] Tapping the city label opens `CitySearch / MapPickEmpty`; tapping the location button calls reverse-geocode on current position.
- [ ] Date picker is `AddVisit / DialogCalendar` exclusively; same component reused for create and edit.
- [ ] Save is disabled until both city and dates are valid (`startUtc <= endUtc`).
- [ ] Save displays `AddVisit / CreateSaving` while the repository call is in flight; failure surfaces an inline error and re-enables the form.
- [ ] Overlap with a confirmed visit blocks save with a calm inline message that names the conflicting visit's city + date range.
- [ ] Edit visit shows `AddVisit / EditFilled` with city greyed, no chevron, no location button.
- [ ] Edit cannot be used to switch cities; the BLoC rejects any update that includes a `cityId` change.
- [ ] Delete shows `AddVisit / EditDeleteDialog`; confirm calls `VisitRepository.delete`.
- [ ] Choose City: pin-drop and list-pick converge to the same `MapPinSelected` state with one `Select this city: {City}` button.
- [ ] Selecting a city from the list re-shows the map, zooms to the city, drops the pin, and updates the search field text.
- [ ] All copy is calm and plain-language; date formatting uses short month names (`Jan`, `Feb`, …) consistent with Timeline.
- [ ] All `DateTime` written to the repository is **UTC**; conversion happens at the BLoC ↔ widget boundary.

## Open questions / future work

- Multi-city visits in a single calendar day — out of scope for this feature, but the data model supports two adjacent visits with the same end-day / start-day. Confirm UX treatment in Timeline.
- Notes field — schema supports it, MVP UI omits it (per brief). Add later if desired.
- Inline edit of dates without leaving Timeline — currently always pushes `VisitDetailRoute`. Acceptable for MVP.
- "Use current location" while the user is offline — geocoder will fail. Acceptable to surface "couldn't resolve, try search" until offline geocoding exists.
