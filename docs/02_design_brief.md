# DaysTracker - Product & UX Design Brief

## 1. Product Overview

DaysTracker is a privacy-first, offline-first mobile app for iOS and Android that helps people track how many days they have spent in countries and cities. It is built for users who move across borders often enough that memory, notes, or spreadsheets stop being reliable, but who do not want a heavy compliance product or a social travel app.

DaysTracker is primarily a personal tracker for time spent in countries and cities, with secondary tools for light Schengen 90/180 awareness and a diary-like feel in the UX tone.

The product should feel calm, precise, and respectful. It should answer practical questions quickly, such as where the user has been, how many days they spent in a place, and how much Schengen allowance they roughly have left, while keeping all core data on the device and avoiding legalistic or fear-based framing.

## 2. Target Users and Use Cases

### Digital nomads

- **Goals**
  - Keep a clear record of time spent across multiple countries.
  - Avoid relying on spreadsheets.
  - Understand travel patterns over recent months.
- **Typical usage pattern**
  - Log or confirm visits regularly.
  - Check country totals often.
  - Review maps or journey views to reconstruct movement.
- **Pain points with existing tools**
  - Social travel apps feel irrelevant.
  - Manual spreadsheets are tedious.
  - Compliance apps feel heavier than the real need.

### Expats / new residents

- **Goals**
  - Understand how much time has been spent in a current or target country.
  - Maintain a dependable private history.
  - Keep a record that feels personal rather than bureaucratic.
- **Typical usage pattern**
  - Use the app as an ongoing log.
  - Check counts for one or two key countries repeatedly.
  - Import past history to establish a baseline quickly.
- **Pain points with existing tools**
  - Mental math is error-prone.
  - General travel apps do not answer day-count questions well.
  - Legal or tax products feel intimidating or overbuilt.

### Frequent travellers

- **Goals**
  - See recent travel footprint clearly.
  - Know how many days were spent where.
  - Keep light awareness of Schengen 90/180 status.
- **Typical usage pattern**
  - Add trips in batches.
  - Review `Statistics` and `Map` before or after travel.
  - Use Schengen information as a practical check rather than a central workflow.
- **Pain points with existing tools**
  - Standalone Schengen calculators solve only one narrow problem.
  - Travel diaries emphasize memories over structured counting.

### Shared characteristics

- They travel between countries often enough that day counts matter.
- They want a fast answer without opening a legal or tax dashboard.
- They care about privacy and do not want hidden uploads or account requirements.
- They benefit from a product that is precise in data handling but gentle in tone.

## 3. Core Value Proposition

- **Fast answers to a real question**
  - DaysTracker makes it easy to answer "How many days have I spent in this country or city?" without manual spreadsheets.
- **Useful from the first session**
  - `Import from Photos` can turn past travel history into meaningful data quickly, reducing blank-state friction.
- **Private by design**
  - The product reinforces that travel history stays on the device and under the user's control.
- **One calm place for counts, footprint, and Schengen**
  - Users do not need separate tools for day totals, maps, journey recall, and light Schengen awareness.
- **Retainable beyond urgent moments**
  - The app provides practical value, but its calm tone, map recall, and personal history also give it enough warmth to stay useful over months.

## 4. App Scope and Non-goals

### In scope

- **Manual visit logging**
  - Users can add visits with country, city, and date range.
  - Editing and deletion must be straightforward and reversible.
- **Background tracking**
  - Users can enable or disable background tracking.
  - Frequency options include `1h`, `2h`, `4h`, `8h`, `12h`, `24h`, and `Off`.
  - A visit is auto-created only if a city appears in two or more pings.
  - A single ping triggers a confirmation prompt: "You might have been in [City]. Were you there?"
  - When online geocoding is unavailable, the app should fail gracefully and retry later rather than silently losing history.
- **Photo-based history import**
  - `Import from Photos` is a primary onboarding path.
  - The app reads location metadata only, not photo contents.
  - Suggested visits can be accepted, edited, or dismissed before saving.
- **Simple statistics**
  - Users can review country and city day counts in `Statistics`.
  - Period filters include `7d`, `31d`, `183d`, `365d`, and `All time`.
  - The screen supports multiple view modes, including a calendar-style option.
- **Timeline**
  - Users can review visits in `Timeline`.
  - The screen supports multiple view modes for scanning and review.
- **Map and journey**
  - `Map` shows visited countries and cities.
  - `My Journey` is available from `Map` only.
  - The `My Journey` button appears only after the user has visited at least three cities.
  - Before that threshold, the button does not render.
- **Light Schengen helper**
  - The app shows days used, days remaining, rolling-window dates, and earliest possible re-entry when relevant.
  - This is presented as a helpful estimate, not legal advice.
- **Data control**
  - Import and export of user data in a portable format.
  - Clear-all-data flow with strong confirmation.
- **English-only MVP**
  - UX copy is optimized for one language first, to keep scope controlled.

### Out of scope for v1

- Legal or tax advice.
- Country-specific compliance engines beyond the MVP Schengen helper.
- Social features, sharing, followers, or public profiles.
- Trip planning for future travel.
- Multiple accounts or mandatory cloud sync.
- A note-first travel diary with photos, emotions, or journaling as the main product loop.
- `183-day` alerts, Schengen threshold alerts, and similar notification-heavy workflows.
- Advanced charts, expanded imports, achievements, and other scope-expanding retention mechanics.

## 5. High-level User Journeys

### First-time user

- The user opens the app and sees one universal onboarding flow.
- The onboarding screen presents `Import from Photos` as the primary recommended path.
- The same screen also offers `Add manually` and `Enable background tracking` as secondary options.
- The app explains privacy clearly before any sensitive permission request.
- If the user chooses `Import from Photos`, they see a short message explaining that only location metadata is read.
- The user grants permission, the app scans supported photo metadata on device, and suggested visits are grouped by place and date range.
- Each suggestion shows city, country, date range, number of photos, and a confidence label such as `Confirmed` or `Possible`.
- The user can accept all, accept selectively, edit dates, or dismiss suggestions.
- After import, the user lands in a meaningful state with real history visible in `Timeline`, `Statistics`, or `Map`.
- If the user skips import, they remain on a clear path to start manually or enable automatic tracking without feeling blocked.

### Returning user

- The user opens `Timeline` to review recent visits or add a new one quickly.
- The user can switch to `Statistics` to answer a question like "How many days was I in Portugal in the last 365 days?"
- The user opens `Map` to see visited countries and city pins.
- If the user has visited at least three cities, the `My Journey` button appears on `Map`.
- The user taps `My Journey` to see a connected route and a chronological list of visits.
- The user can also glance at the Schengen summary in `Statistics` to understand used and remaining days without entering a separate calculator flow.

### Edge user

- The user has many visits across countries and cities over multiple years.
- The app still makes scanning manageable through period filters, view modes, and grouped map pins.
- The user can narrow views by year or preset period instead of facing one long undifferentiated history.
- `My Journey` becomes a meaningful secondary lens once the map has enough data to justify it.
- Editing remains possible without forcing the user through complex workflows or legal terminology.

## 6. UX Principles and Tone

### UX principles

- **Personal tracker first**
  - Position the product as a calm tool for tracking time spent in places, not as a diary app and not as a compliance product.
- **Calm and precise**
  - The interface should feel trustworthy and exact without becoming severe or alarmist.
- **Fast to understand**
  - Each top-level screen should answer one clear question.
- **Privacy-first permissioning**
  - Sensitive permissions are requested only when the user asks for the feature that needs them.
- **Offline by default**
  - Core history, counts, and review flows should work without network access.
  - Any dependency on online geocoding should fail gracefully and retry later.
- **Confidence before automation**
  - Automatic tracking should feel helpful, but low-confidence events should ask for confirmation.
- **Always reversible**
  - Edits, dismissals, and destructive actions should be recoverable or clearly confirmed.

### Tone of language

- Calm, neutral, and plain-spoken.
- Non-legalistic and non-technical in everyday copy.
- Helpful rather than warning-heavy.
- Warm enough in onboarding and empty states to feel personal.
- Honest about limitations, especially around Schengen estimates and background automation.

Examples of preferred tone:

- "Days in Schengen in the last 180 days: 65 of 90"
- "We only read location tags from your photos"
- "You might have been in Vienna. Were you there?"

Examples to avoid:

- "Compliance risk"
- "Jurisdiction status"
- "Potential violation detected"

## 7. Information Architecture (IA)

### Navigation model

- Bottom tab bar with four entries: `Timeline`, `Statistics`, `Map`, `Settings`.
- Primary creation flow for visits is launched from a visible action inside the relevant surface, not from a hidden gesture.
- `My Journey` is not a tab. It is a secondary view entered from `Map`.
- `Import from Photos` is available during onboarding and later from `Settings`.

### `Timeline`

- **Purpose**
  - Show what visits are logged and make review or editing easy.
- **Main sections**
  - Filter or view-mode switcher.
  - Chronological visit list.
  - Add or edit entry point.
  - Empty, loading, and error states.
- **How a user gets there**
  - Bottom tab.
  - Natural landing state after the first successful import or first manual entry.

### `Statistics`

- **Purpose**
  - Answer how many days the user spent where.
- **Main sections**
  - Period presets.
  - Country and city summaries.
  - Alternative view modes.
  - Calendar-style view.
  - Schengen summary.
- **How a user gets there**
  - Bottom tab.
  - The "answer screen" when users need a number fast.

### `Map`

- **Purpose**
  - Show travel footprint visually through visited countries and city pins.
- **Main sections**
  - Year filter.
  - Filled-country view.
  - City pins with clustering.
  - Tap summaries for country or city totals.
  - Conditional `My Journey` button.
- **How a user gets there**
  - Bottom tab.
- **Special rule**
  - `My Journey` appears only when there are at least three visited cities. Below that threshold, no button is shown.

### `Settings`

- **Purpose**
  - Manage tracking behavior, import/export, permissions, and trust-related controls.
- **Main sections**
  - Background tracking.
  - Import/export.
  - Clear data.
  - Privacy notice.
  - App information.
- **How a user gets there**
  - Bottom tab.

### Secondary flows

- **Add/Edit Visit**
  - Purpose: create or correct structured history manually.
  - Main inputs: country, city, and date range.
  - Expected UX: simple, low-friction, and clearly confirmable.
- **Import from Photos**
  - Purpose: turn existing travel history into suggested visits.
  - Entry points: onboarding and `Settings`.
  - Expected UX: explain privacy first, show progress clearly, then present suggestions for review.
- **My Journey**
  - Purpose: show a full chronological route as a connected path on a map, plus a visit list below.
  - Entry point: button on `Map` only after at least three cities have been visited.
  - Product reason: this keeps the feature meaningful and prevents an empty or low-value destination early on.

## 8. Functional Requirements at UX Level

### Visit Logging

- **Manual visit entry**
  - What the user sees: a clear form for country, city, and date range, with editing available for existing visits.
  - What the user can do: add, edit, and delete visits without ambiguity.
  - UX success criteria: the flow feels faster than using a spreadsheet and clear enough for first-time users without explanation.
- **Background tracking**
  - What the user sees: an optional tracking section with on/off control, frequency options, permission status, and plain-language explanation of what tracking does.
  - What the user can do: enable tracking, change frequency, and confirm or dismiss low-confidence location suggestions.
  - UX success criteria: users understand the trade-off, trust the feature, and do not feel forced into always-on tracking.
- **Photo import**
  - What the user sees: a primary recommended onboarding option and a later settings entry point, followed by a review list of visit suggestions with confidence labels.
  - What the user can do: accept all, accept selectively, edit ranges before saving, or dismiss suggestions.
  - UX success criteria: the feature reduces blank-state pain and feels privacy-safe from the first permission prompt onward.

### Statistics

- **Country and city counts**
  - What the user sees: clear summaries of days spent in countries and cities across standard preset periods.
  - What the user can do: switch periods, switch view modes, and drill into a location for more detail.
  - UX success criteria: a user can answer "How many days was I there?" within seconds.
- **Calendar-style view**
  - What the user sees: a calendar representation of where days were spent, using lightweight visual cues that stay legible.
  - What the user can do: scan presence patterns and inspect specific days or periods.
  - UX success criteria: the calendar adds clarity rather than visual noise.

### Residency / Schengen helpers

- **Schengen summary**
  - What the user sees: days used, days remaining, rolling-window dates, and earliest re-entry date if over the limit, plus a calm status indicator.
  - What the user can do: understand their approximate standing quickly without leaving the app or learning legal terminology.
  - UX success criteria: the information is immediately understandable, visibly secondary to the main tracker experience, and never framed as legal advice.

### Map and Journey

- **Map footprint**
  - What the user sees: visited countries visually filled, visited cities shown as pins, and filters for year or all time.
  - What the user can do: tap a country or city to see total days and use the map as a visual recall tool.
  - UX success criteria: the map helps answer "where have I been?" rather than acting as decoration.
- **My Journey**
  - What the user sees: a route view plus a chronological list of visits.
  - What the user can do: review movement over time by year or across all history.
  - UX success criteria: the view feels earned and meaningful because it appears only after there is enough data to make it interesting.

### Settings and Data control

- **Tracking and permissions**
  - What the user sees: background tracking controls, permission state, and clear explanations of what each choice means.
  - What the user can do: turn tracking on or off, adjust frequency, and understand how to regain control if permissions are denied.
  - UX success criteria: settings reinforce trust rather than feeling technical or intimidating.
- **Import, export, and reset**
  - What the user sees: clear actions for photo import, data export, data import, and data deletion.
  - What the user can do: move data in and out of the app and clear it intentionally with strong confirmation.
  - UX success criteria: the product feels user-controlled, portable, and safe.

## 9. Risks and Trade-offs

- **Risk: drifting into a compliance product**
  - If Schengen and future threshold logic become too prominent, the app will feel stressful and narrow.
  - Strategy: keep country/city tracking as the hero job and position Schengen as a secondary summary.
- **Risk: automation reduces trust if it makes mistakes**
  - Background tracking and import features are valuable, but false positives can damage confidence quickly.
  - Strategy: use confidence-based review, plain explanations, and visible edit controls.
- **Risk: the product becomes too utilitarian to retain**
  - Purely functional trackers can be abandoned once the urgent question is answered.
  - Strategy: borrow warmth from diary products through tone, maps, onboarding, and meaningful history views without turning journaling into scope.
- **Risk: onboarding becomes complex**
  - Import, manual entry, and tracking can easily turn into three competing first-run experiences.
  - Strategy: keep one universal onboarding flow, recommend `Import from Photos`, and present the other two as clear secondary choices on the same screen.
- **Risk: map and journey features feel empty too early**
  - A journey screen with too little data has low value.
  - Strategy: hide the `My Journey` entry point until the user has visited at least three cities.
- **Risk: advanced setup leaks into mainstream UX**
  - Provider-specific or implementation-specific configuration can confuse ordinary users.
  - Strategy: keep the UX brief generic around location and geocoding services, and avoid exposing technical setup unless it becomes truly necessary.
- **Risk: future scope expands faster than the core loop stabilizes**
  - Alerts, additional imports, charts, and achievements can overwhelm the product before the core tracker is excellent.
  - Strategy: treat MVP as a discipline exercise: logging, reviewing, counting, mapping, and calm Schengen awareness first.
