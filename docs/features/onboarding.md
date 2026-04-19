# Feature — Onboarding

> Penpot: `10 – Onboarding` (`Welcome`, `Setup`).

## Overview

Onboarding is a single, universal first-run flow shown until the user explicitly completes it. It establishes the product's identity (private personal tracker), recommends `Import from Photos` as the fastest path to value, and offers two secondary paths (`Add manually`, `Enable background tracking`) on the same screen. It does **not** branch by persona.

## User stories

- As a new user, I want a calm intro that explains what the app does and why it's safe before being asked for permissions.
- As a new user, I want a single screen where I can pick how I'd like to start, with `Import from Photos` clearly recommended.
- As a new user who skips import, I want a clear path to either add a visit manually or enable tracking — without feeling pushed.
- As a returning user who has completed onboarding, I want to never see it again unless I clear app data.

## States & UX

| State | What the user sees | Source frame |
|---|---|---|
| `Welcome` | Brand + one-line value prop + privacy promise + `Continue` | `Onboarding / Welcome` |
| `Setup` | Three options on one screen: **Import from Photos** (primary, recommended), **Add manually** (secondary), **Enable background tracking** (secondary). Short tone-matched copy under each. A `Skip for now` link continues to the empty Timeline. | `Onboarding / Setup` |
| Photo path entered | Hands off to `ImportPhotosRoute` (see `import_data.md`). On completion or cancel, marks onboarding done and lands on Timeline. | n/a |
| Manual path entered | Hands off to `AddVisitRoute()` (no pre-set date). On save or cancel, marks onboarding done and lands on Timeline. | n/a |
| Tracking path entered | Hands off to the OS permission flow via `BackgroundTrackingRepository.updateSettings(enabled: true, frequency: h4)` (default frequency on first opt-in). Marks onboarding done regardless of permission outcome. | n/a |
| Skipped | Onboarding is marked done; user lands on Timeline empty state. | `Timeline / Empty` |

## Domain impact

- Reads / writes `SettingsRepository.isOnboardingDone()` and `markOnboardingDone()`.
- Triggers `PhotoImportRepository.startScan()` on the photo path.
- Triggers `BackgroundTrackingRepository.updateSettings()` on the tracking path.
- No new domain entities introduced by onboarding itself.

## Routing

- App launch reads `isOnboardingDone()`. If `false`, `OnboardingRoute` replaces the shell; otherwise the bottom-tab shell loads.
- The router guard for onboarding lives in `presentation/router/`; it must not call repositories from inside `lib/main.dart`.

## Acceptance criteria

- [ ] On first launch, the user sees `Onboarding / Welcome` followed by `Onboarding / Setup`.
- [ ] On `Setup`, `Import from Photos` is visually primary; the other two are equally weighted secondaries.
- [ ] Choosing any option (or `Skip for now`) sets onboarding done **before** transitioning to the next screen, so backgrounding the app mid-flow doesn't replay onboarding.
- [ ] Permissions for photos and location are **not** requested on `Welcome` or `Setup` themselves — only inside the chosen branch.
- [ ] After onboarding completes, the user lands on `TimelineRoute` (Empty if no data, populated otherwise).
- [ ] Copy is calm and plain-language; no fear-based or legalistic phrasing on either frame.
- [ ] Onboarding never appears again unless the user clears app data (which resets `SettingsRepository`).

## Open questions / future work

- Default tracking frequency on first opt-in — currently spec'd as `h4`. Confirm with product before Bootstrap.
- Should `Skip for now` show a one-time toast on the empty Timeline ("You can import any time from Settings") to soften the empty state? Brief doesn't specify.
- Tracking permission denial UX — go back to `Setup` or just proceed and surface a hint in Settings? Currently the spec proceeds and surfaces in Settings.
