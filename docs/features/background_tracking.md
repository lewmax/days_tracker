# Feature — Background tracking

> Penpot: `06 – Settings` (`Settings / TrackingOn`, `Settings / TrackingOff`).
> Implementation mechanism (`flutter_background_service` vs `workmanager` vs native isolate) is **TBD** — see `architecture.md` §16.1.

## Overview

Background tracking is an **opt-in** assistant that records periodic location pings, derives visits from clusters of pings, and asks the user to confirm low-confidence single pings. It is **not** the hero feature — the brief explicitly says it should feel optional and supportive.

Posture:

- Off by default.
- Frequencies: `Off`, `1h`, `2h`, `4h`, `8h`, `12h`, `24h`.
- A visit is auto-created (`confirmed`, `origin = backgroundTracking`) only when a city appears in **≥2 pings**.
- A single ping creates a `ConfirmationRequest` (`possible`) the user must accept or dismiss.
- Reverse geocoding is online-only; offline pings are stored unresolved and retried later.
- Privacy-first: no continuous foreground location, no network on cellular if not needed (best-effort), no analytics.

## User stories

- As a user, I want to enable tracking with one toggle and pick how often the app samples my location.
- As a user, I want to disable tracking at any time without orphan state.
- As a user, I want to be asked before a low-confidence visit is added to my history.
- As a user, I want the app to retry pending location resolution after I'm online again, not silently lose history.

## Settings UI

| State | Frame | Notes |
|---|---|---|
| Tracking on | `Settings / TrackingOn` | Toggle ON; frequency row enabled with current value (default `4h` on first opt-in). |
| Tracking off | `Settings / TrackingOff` | Toggle OFF; frequency row **greyed out / de-emphasised** but visible (shows the last-selected value or `4h`). |

There is **no** dedicated "Location permission" row in Settings — the OS-led permission flow runs when the user enables tracking.

## Permission flow

1. User flips toggle ON.
2. App calls `permission_handler` (or equivalent) for `locationAlways` (Android) / `whenInUse` upgrade to `always` (iOS).
3. If granted: writes `TrackingSettings(enabled: true, frequency: previousOrDefault)`, schedules first ping.
4. If denied: toggle remains OFF, surfaces a calm inline message ("Tracking needs location access. You can enable it in system settings.") and links to system settings.
5. If "while in use" only: still records pings while the app is foreground; backgrounding stops new pings until upgrade.

## Ping pipeline (data layer)

1. **Wake on schedule** at the configured frequency.
2. Fetch a single location fix via `geolocator` (`bestForNavigation` accuracy not required; `medium` is fine).
3. Persist a `LocationPing` (`processed = false`).
4. **Reverse geocode** asynchronously:
   - Online → set `resolvedCityId` + `resolvedCountryCode`.
   - Offline / failure → leave nulls; the next pipeline pass retries.
5. **Derivation pass** (runs after each successful resolution):
   - Group resolved pings within the same calendar day (UTC) by `resolvedCityId`.
   - **≥2 pings same city same day** → create or extend a `confirmed` visit (`origin = backgroundTracking`) for that day.
   - **Single resolved ping** → create a `ConfirmationRequest` (`pending`) for that day + city.
6. Mark consumed pings `processed = true`.

The pipeline is **idempotent**: re-running on the same set of pings must not create duplicate visits or duplicate confirmation requests.

## Confirmation prompts

Surfaced in two places:

- **Foreground inline prompts** when the user opens the app: a small banner / sheet `You might have been in {City}. Were you there?` with `Yes` / `Not really` buttons.
- **Possible rows** in Timeline (Chronological + Calendar Day Detail) showing the suggestion as `Unconfirmed` (amber stripe) — see `timeline.md`.

Accepting → promotes to `Visit (confirmed, origin=backgroundTracking)`.
Dismissing → marks the ping as processed, no visit created, suggestion is gone.

There are **no** background notifications for confirmation prompts in MVP (avoids the "fear" tone).

## Frequency change behaviour

- Changing the frequency reschedules the next ping; in-flight pings continue.
- Switching to `Off` cancels all scheduled work but **keeps** pending `ConfirmationRequest`s the user can still resolve from Timeline.

## Domain impact

- Entities: `LocationPing`, `ConfirmationRequest`, `Visit`, `TrackingSettings`.
- Repositories:
  - `BackgroundTrackingRepository` (settings + pending confirmations stream + accept/dismiss).
  - `LocationPingRepository` (write/read pings).
  - `GeocodingRepository` (reverse-geocode pings; same interface used by Choose City — see `visits.md`).
  - `VisitRepository.create` and `promoteToConfirmed`.

## Acceptance criteria

- [ ] Toggle ON triggers OS permission flow; OFF cancels all scheduled work.
- [ ] Frequency picker is enabled iff the toggle is ON; greyed otherwise.
- [ ] Default first-opt-in frequency = `4h` (configurable in code).
- [ ] A ping is persisted regardless of geocoding outcome (offline-safe).
- [ ] Two pings in the same UTC day for the same city auto-create a `confirmed` visit (`origin = backgroundTracking`).
- [ ] A single resolved ping creates exactly one `ConfirmationRequest` for that day+city.
- [ ] Foreground confirmation prompt copy matches: `You might have been in {City}. Were you there?`.
- [ ] Accepting a request promotes to `Visit (confirmed)`; dismissing marks the ping `processed`.
- [ ] Pipeline is idempotent; re-running over the same pings does not duplicate visits or requests.
- [ ] Disabling tracking leaves existing pending requests intact; the user can still resolve them.
- [ ] No background push notifications are sent.
- [ ] No raw location data leaves the device.

## Open questions / future work

- Background mechanism — `flutter_background_service` vs `workmanager` vs native (`architecture.md` §16.1).
- iOS background-fetch reliability — frequency floors imposed by iOS may make `1h` aspirational; document actual behaviour after Bootstrap.
- Battery budget telemetry (local only) — defer.
- Ping retention horizon — default 30 days post-derivation; revisit.
- Geocoding rate limits and backoff strategy — depends on chosen geocoder.
- Smarter clustering (DBSCAN-style) for noisy GPS — out of scope for MVP.
