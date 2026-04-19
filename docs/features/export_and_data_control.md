# Feature — Export and Data Control

> Penpot: `06 – Settings` (`Dialog / ExportData`, `Dialog / ClearData`).

## Overview

This feature owns the user's outbound data control surfaces:

- **Export** — write a portable JSON file to a user-chosen folder.
- **Clear data** — destructive reset of all local history (after confirmation).
- **Privacy notice** — short page describing what's stored locally and what's never sent off-device.

These are reachable from the Settings tab. Together with `import_data.md`, they reinforce the privacy-first promise: **everything stays local, the user is in control**.

## User stories

- As a user, I want to export my history to a file I can save anywhere on my device.
- As a user, I want to see exactly where the file will be saved before confirming.
- As a user, I want a single irreversible "clear everything" action with strong confirmation.
- As a user, I want a calm, plain-language privacy notice I can read at any time.

## Export (`Dialog / ExportData`)

Flow:

1. User taps `Export data` in Settings.
2. Folder picker opens (system intent on Android, share sheet / `Files` on iOS).
3. After folder selection, the confirm dialog `Dialog / ExportData` shows:
   - Visible **path preview** (e.g. `Documents/DaysTracker/days_tracker_2026-04-19.json`).
   - Summary: `N visits, M cities, K countries`.
   - `Cancel` / `Export` buttons.
4. Tapping `Export` writes the file synchronously, surfaces a success toast, and closes the dialog.
5. Failures (write error, cancelled picker) surface inline with retry.

File contents:

- Versioned JSON schema (`{ "version": 1, "exportedAtUtc": "...", "visits": [...], "cities": [...] }`).
- Cities are denormalised so an import on a fresh install can reconstruct without remote geocoding.
- No raw `LocationPing` data, no pending confirmation requests, no settings — only history the user explicitly created or accepted.

## Clear data (`Dialog / ClearData`)

Flow:

1. User taps `Clear data` in Settings.
2. `Dialog / ClearData` opens with destructive copy:
   - Title: `Clear all data?`
   - Body: `This deletes every visit, every photo suggestion, and resets your settings. It can't be undone. Export your data first if you want to keep a copy.`
   - Buttons: `Cancel` / `Clear` (destructive style).
3. Tapping `Clear` performs:
   - Wipe `visits`, `cities`, `location_pings`, `confirmation_requests`, `import_sessions`, `settings`.
   - Set `onboarding_done = false` so the user re-enters the onboarding flow.
   - Restart the app shell on the Onboarding route.

There is no soft-delete or undo. The dialog itself is the safety net.

## Privacy notice

- A read-only screen in Settings (e.g. `Settings → Privacy`) summarising:
  - Data is stored locally on the device only.
  - Background tracking is opt-in; pings stay on-device.
  - Photo import reads only EXIF location metadata, not photo content.
  - Reverse geocoding sends `(lat, lon)` to the configured geocoder when online; no other data is sent.
  - Reference data (countries → continents) is fetched from a public endpoint on app launch; no user data is sent in that request.
- Written in plain language, not policy language.
- No analytics, no third-party SDKs, no sharing — these are stated explicitly.

## Domain impact

- `JsonImportExportRepository.exportToFile()` — returns absolute path on success.
- A new domain operation (or a `SettingsRepository` method) `clearAllData()` — wipes local DB tables and resets `SettingsRepository`.
- Triggers the app shell to rebuild after a clear, returning to `OnboardingRoute`.

## Routing

- All flows run inline within `SettingsRoute` (modals / dialogs).
- Privacy notice is a pushed sub-route `PrivacyNoticeRoute` under Settings.

## Acceptance criteria

- [ ] Export shows a folder picker, then `Dialog / ExportData` with **visible path preview** and a summary.
- [ ] Cancelling the picker or the dialog leaves data untouched.
- [ ] Export writes a valid JSON matching the documented schema and surfaces a success toast.
- [ ] Clear data shows `Dialog / ClearData` with destructive button styling.
- [ ] Confirming clear wipes all user data, resets `onboarding_done`, and reloads the app into Onboarding.
- [ ] No background uploads of any kind happen during these flows.
- [ ] Privacy notice is reachable from Settings and matches the documented points.
- [ ] All copy is calm; the destructive confirm is direct without being alarmist.

## Open questions / future work

- Optional encrypted export (passphrase-protected) — out of scope for MVP.
- Multi-format export (CSV, ICS) — defer.
- Selective clear (e.g. by date range) — out of scope.
- iCloud / Google Drive folder defaults — defer to user-picker behaviour.
- Audit log of exports / clears — not in MVP.
