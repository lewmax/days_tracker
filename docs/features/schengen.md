# Feature — Schengen helper

> Penpot: `11 – Schengen Detail` (`SchengenDetail / Normal`).

## Overview

The Schengen helper gives the user a calm, plain-language read on their Schengen 90/180 standing. It is **explicitly informational**, not legal advice, and stays **off** the `Statistics` tab. Entry points: the dedicated `SchengenDetailRoute` (linked from `Map` and / or a small entry surface defined in Penpot).

## User stories

- As a user, I want to know how many days I've used in the trailing 180-day Schengen window.
- As a user, I want to know how many days I have left.
- As a user who is over the limit, I want to know the earliest re-entry date.
- As a user, I never want this feature to lecture me or use legal language.

## Surface (`SchengenDetail / Normal`)

- App bar with back navigation; title `Schengen 90/180`.
- Headline number: `{daysUsed} of 90 days used in the last 180 days`.
- Secondary line: `{daysRemaining} days remaining` (or, if over limit: `{over} days over the limit`).
- Window strip: `Window: {windowStartLocal} – {windowEndLocal}`.
- Earliest re-entry block (only when over limit): `Earliest possible re-entry: {dateLocal}` with a one-line plain-language explanation.
- Disclaimer (small, calm): `This is a personal estimate based on your confirmed visits. It's not legal advice.`

## Calm-status indicator

A simple visual indicator (no large red blocks):

| Range | Tone |
|---|---|
| `daysUsed ≤ 60` | Neutral / `safe` token. |
| `60 < daysUsed ≤ 90` | `caution` token; gentle copy ("approaching the limit"). |
| `daysUsed > 90` | `over` token; supportive copy with the earliest re-entry date. |

No red flashing, no warning icons in the title, no "violation" language.

## Math (per `domain_model.md` §7)

- Window: trailing 180 days inclusive of today (`[today - 179 days, today]` UTC).
- A calendar day counts as a Schengen day iff there's a **confirmed** visit whose city's country is in the Schengen list active that day.
- Confirmed-only: `possible` visits never affect the headline.
- `earliestReentryUtc` is computed as the first future date `D` such that the rolling 180-day window ending at `D` would contain `< 90` Schengen days, given **only what's already known** (no extrapolation).

## Schengen country list

- Hardcoded in `lib/domain/schengen/schengen_countries.dart` (ISO-3166 alpha-2).
- Updated manually when membership changes (rare). Surface a TODO in `architecture.md` §16.6.

## Domain impact

- `SchengenRepository.currentStatus({referenceUtc})` — returns `SchengenStatus`.
- Reads visits from `VisitRepository` indirectly (via the Schengen impl).

## Routing

- `SchengenDetailRoute` (pushed from Map and / or a Schengen entry surface to be defined in Penpot).
- **Never** rendered on `Statistics`.

## Acceptance criteria

- [ ] Headline shows `{daysUsed} of 90 days used in the last 180 days` using **confirmed** visits only.
- [ ] Days remaining and over-limit messaging match the documented tone (no legal phrasing).
- [ ] Window dates display in **local** time on screen; underlying math is in UTC.
- [ ] Earliest re-entry block appears only when the user is over the limit and shows a valid future date.
- [ ] The disclaimer text is present and matches the documented copy.
- [ ] Visual tone follows `safe` / `caution` / `over` tokens — never red flashing.
- [ ] Schengen content is **never** rendered on `Statistics`.
- [ ] Schengen country list is sourced from a single domain constant.

## Open questions / future work

- Should the helper offer a small chart of the trailing window (days per day for last 180 days)? Out of scope for MVP — Penpot may add later.
- Forecast / "what-if I stay X more days" — out of scope (would push toward planner identity).
- Country-specific rolling rules beyond Schengen — out of scope.
- Notifications when approaching the limit — explicitly out of scope (brief).
- Bulgaria / Romania / Croatia / etc. membership changes — manual update path; consider a small reference fetch in a future iteration.
