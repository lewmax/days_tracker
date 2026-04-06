# DaysTracker - Screens and Components

This document defines every screen, reusable component, and UI state for the DaysTracker MVP. It is the primary reference for wireframing, hi-fi design, and Flutter implementation.

All color, typography, spacing, and motion values reference tokens from `03_design_tokens.md`.

---

## Part 1: Core Components

### Button

Rectangular, `radius-md`, minimum touch target 44x44dp.

| Variant | Appearance | Use |
|---|---|---|
| Primary | Filled `primary`, `on-primary` text | Main actions: Save visit, Accept all, Confirm |
| Secondary | Outlined `outline` border, `primary` text | Supporting actions: Cancel, Edit, Filter |
| Text | No background, `primary` text | Inline actions: links, tertiary actions |
| Icon-only | Circular `radius-full`, `primary` icon | FAB, add button, close button |
| Destructive | Filled `error`, `on-error` text | Delete visit, Clear all data |

States: default, pressed, disabled.

---

### Card/Visit

Used in `Timeline` and visit lists throughout the app.

| Element | Token | Notes |
|---|---|---|
| Container | `surface-card`, `radius-md`, optional `outline` border | Full-width within screen padding |
| Flag | Emoji flag | Leading element, sized to `title` line height |
| City, Country | `on-surface-primary` / `title` | Primary label |
| Date range | `on-surface-secondary` / `body-small` | "5–12 Mar 2026" format |
| Days count | `on-surface-primary` / `headline` | Trailing, right-aligned |
| Source badge | `Badge/Confidence` | `Confirmed`, `Possible`, or `Manual` |
| Internal padding | `space-lg` all sides | |
| Tap behavior | Navigate to `Visit Detail` | Entire card is tappable |

---

### Card/CountryStat

Used in `Statistics` for country-level day counts.

| Element | Token | Notes |
|---|---|---|
| Container | `surface-card`, `radius-md` | |
| Flag | Emoji flag | Leading |
| Country name | `on-surface-primary` / `title` | |
| Days count | `on-surface-primary` / `headline` | Trailing |
| Optional bar | `primary` fill on `outline` track | Proportional to max country in the list |
| Tap behavior | Navigate to `Country Detail` | |

---

### Card/CityStat

Used in `Statistics` for city-level day counts. Same structure as `Card/CountryStat`, scoped to city.

| Element | Token | Notes |
|---|---|---|
| Container | `surface-card`, `radius-md` | |
| Flag | Emoji flag (country of the city) | Leading |
| City name | `on-surface-primary` / `title` | Primary label |
| Country name | `on-surface-secondary` / `body-small` | Below city name |
| Days count | `on-surface-primary` / `headline` | Trailing |
| Optional bar | `primary` fill on `outline` track | Proportional to max city in the list |
| Tap behavior | Navigate to `City Detail` | |

---

### Card/Schengen

Used in `Statistics` as a summary card and as the entry point to `Schengen Detail`.

| Element | Token | Notes |
|---|---|---|
| Container | `surface-card`, `radius-md` | |
| Title | "Schengen (last 180 days)" / `title` | |
| Days used / remaining | `headline` | e.g. "65 of 90 days used" |
| Progress bar | `ProgressBar/Schengen` | Colored by threshold |
| Status label | `caption` | "25 days remaining" or "Limit reached" |
| Window dates | `on-surface-secondary` / `caption` | Start and end of the 180-day window |
| Earliest re-entry | `on-surface-secondary` / `caption` | Shown only when over limit |
| Disclaimer | `on-surface-disabled` / `caption` | "Approximate — not legal advice" |
| Tap behavior | Navigate to `Schengen Detail` | |

---

### Chip/Period

Horizontal scrollable row of period presets.

| State | Background | Text | Border |
|---|---|---|---|
| Unselected | Transparent | `on-surface-secondary` | `outline` |
| Selected | `primary` at 15% opacity | `primary` | `primary` |

Values: `7d`, `31d`, `183d`, `365d`, `All time`.
Shape: `radius-sm`, height 32, horizontal padding `space-md`.

---

### Chip/ViewMode

Same visual style as `Chip/Period`, used for switching view modes in `Timeline` and `Statistics`.

Timeline modes: `By month`, `By country`, `By city`, `Compact`.
Statistics modes: `Countries`, `Cities`, `Calendar`.

---

### CalendarCell

Used in the calendar view mode within `Statistics` and in `Schengen Detail`.

| Element | Token | Notes |
|---|---|---|
| Container | 44x44dp minimum | Touch target compliance |
| Date number | `body-small` / `on-surface-primary` | Center-aligned |
| Presence indicator | Dot below the number | Color = `primary` for general presence, Schengen-specific colors in Schengen Detail |
| No-presence state | `on-surface-disabled` for the date number, no dot | |
| Today marker | Ring of `primary` around the cell | |
| Selected state | Filled `primary` background, `on-primary` text | When tapped for detail |

---

### Input/Text

Standard text field.

| Element | Token |
|---|---|
| Container | `surface-card` background, `outline` border, `radius-md` |
| Label | `caption` / `on-surface-secondary`, floats above on focus |
| Value text | `body` / `on-surface-primary` |
| Helper text | `caption` / `on-surface-secondary` |
| Error text | `caption` / `error` |
| Focus border | `outline-focus` |

---

### Input/Search

Search field with leading icon. Used for country and city selection in `Add/Edit Visit`.

| Element | Token |
|---|---|
| Container | `surface-card`, `outline` border, `radius-md` |
| Search icon | `on-surface-secondary`, 20x20 |
| Placeholder text | `body` / `on-surface-disabled` |
| Value text | `body` / `on-surface-primary` |
| Clear button | `on-surface-secondary` icon, appears when field has value |

---

### Input/DateRange

Date range picker trigger. Tapping opens a calendar-based picker (bottom sheet or full-screen).

| Element | Token |
|---|---|
| Container | Same as `Input/Text` |
| Label | "Dates" / `caption` |
| Display value | "5 Mar – 12 Mar 2026" / `body` / `on-surface-primary` |
| Calendar icon | Trailing, `on-surface-secondary` |

---

### BottomNavBar

Fixed at the bottom of the screen. Four tabs.

| Element | Token |
|---|---|
| Background | `surface-elevated` |
| Top border | `outline`, 1px |
| Active icon + label | `primary` |
| Inactive icon + label | `on-surface-disabled` |
| Icon size | 24x24 |
| Label | `caption` |
| Height | 64 (includes safe area on notched devices) |

Tabs: `Timeline`, `Statistics`, `Map`, `Settings`.

---

### TopBar

Standard app bar at the top of each screen.

| Element | Token |
|---|---|
| Background | `surface-base` (transparent scroll-under) or `surface-card` (opaque) |
| Title | `display` / `on-surface-primary` |
| Leading action | Back arrow when inside a secondary screen |
| Trailing action | Context-dependent (e.g. add button on Timeline) |
| Height | 56 |

---

### EmptyState

Centered block shown when a screen or section has no content.

| Element | Token |
|---|---|
| Icon or illustration | 48x48, `on-surface-disabled` tint | Lightweight, line-style |
| Title | `title` / `on-surface-primary` |
| Description | `body-small` / `on-surface-secondary` |
| Optional CTA | `Button/Primary` or `Button/Text` |
| Vertical padding | `space-3xl` above and below |

---

### LoadingState

Skeleton shimmer matching the shape of the content it replaces.

| Element | Token |
|---|---|
| Skeleton blocks | `surface-card` with a shimmer gradient sweeping left-to-right |
| Shape | Matches the component layout (card rectangles, text bars, avatar circles) |
| Animation | `motion-standard` continuous loop |

---

### ErrorState

Shown when data loading or an operation fails.

| Element | Token |
|---|---|
| Icon | 48x48, `error` tint |
| Title | `title` / `on-surface-primary` |
| Description | `body-small` / `on-surface-secondary`, explains what went wrong |
| Recovery CTA | `Button/Secondary` ("Try again") |

---

### MapPin

Used on the `Map` screen.

| Variant | Appearance |
|---|---|
| Single city | Filled circle `primary`, 12dp, with `on-primary` dot center |
| Cluster | Filled circle `primary`, 28dp, with `on-primary` count text (`caption`) |
| Selected | Scaled up (1.3x), ring of `primary` with `surface-base` gap |

---

### Badge/Confidence

Small pill-shaped label indicating visit source or confidence.

| Variant | Background | Text |
|---|---|---|
| Confirmed | `success` at 15% opacity | `success` |
| Possible | `warning` at 15% opacity | `warning` |
| Manual | `primary` at 15% opacity | `primary` |

Shape: `radius-sm`, horizontal padding `space-sm`, vertical padding `space-xs`.
Typography: `caption`.

---

### Toggle

On/off switch for background tracking.

| State | Track | Thumb |
|---|---|---|
| Off | `outline` | `on-surface-disabled` |
| On | `primary` | `on-primary` |

---

### BottomSheet

Slides up from the bottom with `motion-sheet`.

| Element | Token |
|---|---|
| Background | `surface-elevated` |
| Radius | `radius-lg` top corners only |
| Handle | Centered pill, `outline`, 36x4 |
| Scrim | `surface-overlay` |

---

### Dialog/Confirm

Standard confirmation dialog.

| Element | Token |
|---|---|
| Container | `surface-elevated`, `radius-lg`, centered |
| Title | `title` / `on-surface-primary` |
| Message | `body-small` / `on-surface-secondary` |
| Cancel action | `Button/Text` |
| Confirm action | `Button/Primary` |

---

### Dialog/Destructive

Same layout as `Dialog/Confirm`, with destructive emphasis.

| Element | Token |
|---|---|
| Confirm action | `Button/Destructive` instead of Primary |
| Message | Includes explicit consequence: "This will permanently delete all your visits." |

---

### Banner/Privacy

Inline informational banner for privacy explanations.

| Element | Token |
|---|---|
| Background | `primary` at 8% opacity |
| Border-left | 3px `primary` |
| Icon | Lock or shield, `primary`, 20x20 |
| Text | `body-small` / `on-surface-primary` |
| Radius | `radius-sm` |

---

### ProgressBar/Schengen

Horizontal bar for the Schengen summary.

| Element | Token |
|---|---|
| Track | `outline`, 8dp height, `radius-full` |
| Fill | `schengen-safe`, `schengen-caution`, or `schengen-over` depending on threshold |
| Thresholds | Green up to 75 days, amber 76–89 days, red 90+ days |

---

### SectionHeader

Separates content groups within a screen.

| Element | Token |
|---|---|
| Label | `overline` / `on-surface-secondary` |
| Trailing action | Optional `Button/Text` (e.g. "See all") |
| Bottom spacing | `space-sm` |

---

### Divider

Thin horizontal separator.

| Element | Token |
|---|---|
| Color | `outline` |
| Thickness | 1px |
| Horizontal inset | Optional `space-lg` on both sides for indented dividers |

---

### ImportSuggestion

Row used in the `Import from Photos` review list.

| Element | Token | Notes |
|---|---|---|
| Container | `surface-card`, `radius-md` | Full-width card |
| Flag | Emoji flag | Leading |
| City, Country | `title` / `on-surface-primary` | Primary label |
| Date range | `body-small` / `on-surface-secondary` | |
| Photo count | `caption` / `on-surface-secondary` | e.g. "4 photos" |
| Confidence badge | `Badge/Confidence` | `Confirmed` or `Possible` |
| Accept action | `Button/Primary` (compact) | Trailing |
| Dismiss action | `Button/Text` or swipe-to-dismiss | |
| Edit date action | Tap date range to open `Input/DateRange` | Inline edit before accepting |

---

### LocationConfirmCard

Inline card pinned at the bottom of `Timeline` when a single-ping background detection needs confirmation. Not a modal.

| Element | Token | Notes |
|---|---|---|
| Container | `surface-elevated`, `radius-lg` top corners, shadow level 2 | Sits above the list, below the bottom nav |
| Icon | Location pin, `primary` | Leading |
| Message | `body` / `on-surface-primary` | "You might have been in [City, Country]. Were you there?" |
| Confirm action | `Button/Primary` (compact) | "Yes" |
| Dismiss action | `Button/Text` | "No" |
| Animation | `motion-sheet` | Slides up into view |

When the app is backgrounded, this prompt is delivered as a system notification instead.

---

## Part 2: Screens

### Screen 1: Timeline

**Tab:** first tab in `BottomNavBar`.
**Question it answers:** "What visits do I have logged?"

#### Layout

- `TopBar` with screen title "Timeline" and trailing add button (icon-only `+`).
- `Chip/ViewMode` row: `By month`, `By country`, `By city`, `Compact`.
- Scrollable visit list using `Card/Visit` components.
- `LocationConfirmCard` pinned at the bottom when a single-ping event is pending.

#### View modes

- **By month** (default): visits grouped under month headers (`SectionHeader`). Most recent month first.
- **By country**: visits grouped under country headers (flag + country name).
- **By city**: visits grouped under city headers (flag + city, country).
- **Compact**: condensed list without cards, one line per visit (flag, city, date range, days).

#### States

| State | Content |
|---|---|
| Empty | `EmptyState`: "No visits yet" / "Import from your photos or add your first visit." CTA: "Import from Photos" (primary), "Add manually" (text). |
| Loading | `LoadingState`: 4–6 skeleton cards matching `Card/Visit` shape. |
| Normal | Grouped list of `Card/Visit` cards. |
| Error | `ErrorState`: "Could not load visits" / "Try again." |
| Filtered-empty | `EmptyState` variant: "No visits match this view" / "Try a different view mode." No CTA. |

#### Microcopy

- Screen title: "Timeline"
- Add button tooltip: "Add visit"
- Empty state title: "No visits yet"
- Empty state description: "Import from your photos or add your first visit."
- Error title: "Something went wrong"
- Error description: "We couldn't load your visits. Please try again."
- Error CTA: "Try again"

---

### Screen 2: Statistics

**Tab:** second tab in `BottomNavBar`.
**Question it answers:** "How many days was I where?"

#### Layout

- `TopBar` with screen title "Statistics".
- `Chip/Period` row: `7d`, `31d`, `183d`, `365d`, `All time`.
- `Chip/ViewMode` row: `Countries`, `Cities`, `Calendar`.
- Content area changes based on selected view mode.
- `Card/Schengen` at the bottom of the list (always visible regardless of view mode, scrolls with content).

#### View modes

- **Countries** (default): sorted list of `Card/CountryStat` for the selected period. Sorted by days descending.
- **Cities**: sorted list of `Card/CityStat` for the selected period. Sorted by days descending.
- **Calendar**: month-by-month calendar grid using `CalendarCell`. Presence days marked with colored dots. Swipe or arrow buttons to navigate months.

#### States

| State | Content |
|---|---|
| Empty | `EmptyState`: "No days tracked yet" / "Start by adding a visit or importing from your photos." CTA: "Add visit" (primary). |
| Loading | `LoadingState`: skeleton for stat cards and Schengen card. |
| Normal | Stat list or calendar + Schengen card. |
| Error | `ErrorState`: "Could not load statistics" / "Try again." |
| Filtered-empty | `EmptyState` variant: "No data for this period" / "Try a longer time range." |

#### Microcopy

- Screen title: "Statistics"
- Empty state title: "No days tracked yet"
- Empty state description: "Start by adding a visit or importing from your photos."
- Schengen card disclaimer: "Approximate — not legal advice"
- Schengen safe label: "[X] days remaining"
- Schengen over label: "Limit reached — earliest re-entry [date]"

---

### Screen 3: Map

**Tab:** third tab in `BottomNavBar`.
**Question it answers:** "What countries and cities have I visited?"

#### Layout

- Full-screen map canvas (OpenStreetMap tiles).
- `TopBar` overlaid (transparent background), title "Map".
- Year filter chips at the top edge of the map: `2024`, `2025`, `2026`, `All time`.
- Visited countries filled with `secondary` color.
- Visited cities shown as `MapPin` (single or clustered).
- `My Journey` button: floating action button or bottom-edge button, rendered only when the user has visited 3 or more distinct cities. Does not render below that threshold.

#### Interactions

- Tap country fill: `BottomSheet` showing country name, flag, total days for the selected period.
- Tap city pin: `BottomSheet` showing city name, country, flag, total days for the selected period.
- Tap cluster: zoom into the cluster area.
- Tap `My Journey` button: navigate to `My Journey` screen.

#### States

| State | Content |
|---|---|
| Empty | Map with no fills or pins. `EmptyState` card overlaid: "Your map is empty" / "Add visits to see your travel footprint." |
| Normal | Countries filled, city pins visible, My Journey button conditionally visible. |
| Loading | Map tiles loading indicator. |
| Error | Map tile load failure: inline banner "Map could not load. Check your connection." |

#### Microcopy

- Screen title: "Map"
- Empty state title: "Your map is empty"
- Empty state description: "Add visits to see your travel footprint."
- My Journey button label: "My Journey"
- Country tap sheet: "[Flag] [Country] — [X] days"
- City tap sheet: "[Flag] [City], [Country] — [X] days"

---

### Screen 4: Settings

**Tab:** fourth tab in `BottomNavBar`.
**Question it answers:** "How do I control tracking, data, and permissions?"

#### Layout

- `TopBar` with screen title "Settings".
- Scrollable list of `ListItem/Setting` grouped into sections with `SectionHeader`.

#### Sections

**Background Tracking**
- Toggle: "Background tracking" — `Toggle` (on/off).
- Frequency: "Check every" — trailing value showing current selection (e.g. "4 hours"). Taps open a picker `BottomSheet` with options: `1h`, `2h`, `4h`, `8h`, `12h`, `24h`.
- Permission status: "Location permission" — trailing label showing current state (`Always`, `When in use`, `Denied`). Taps open system settings if denied.
- Explanation: `Banner/Privacy` — "DaysTracker checks your location in the background to log visits automatically. You can turn this off at any time."

**Data & Import**
- "Import from Photos" — chevron, navigates to `Import from Photos` flow.
- "Export data" — chevron, triggers export action (JSON file).
- "Import data" — chevron, triggers file picker for JSON import.
- "Clear all data" — red text, triggers `Dialog/Destructive`.

**About**
- "App version" — trailing label with version number.
- `Banner/Privacy` — "All data is stored locally on your device. No cloud sync. No accounts."

#### States

Settings does not have empty, loading, or error states as a whole. Individual actions (export, import, clear) handle their own confirmation and error flows.

#### Microcopy

- Screen title: "Settings"
- Tracking explanation: "DaysTracker checks your location in the background to log visits automatically. You can turn this off at any time."
- Clear data dialog title: "Clear all data?"
- Clear data dialog message: "This will permanently delete all your visits. This cannot be undone."
- Clear data confirm: "Delete everything"
- Clear data cancel: "Cancel"
- Privacy notice: "All data is stored locally on your device. No cloud sync. No accounts."

---

### Screen 5: My Journey

**Entry point:** button on `Map` screen, rendered only when 3+ distinct cities have been visited.
**Question it answers:** "What does my full travel route look like?"

#### Layout

- `TopBar` with back arrow and title "My Journey".
- Top half: map canvas showing a connected polyline route between visited cities, chronologically ordered.
- Year filter chips: same set as `Map` screen.
- Bottom half: scrollable list of visits in chronological order, each showing flag, city, country, date range, days count.

#### States

| State | Content |
|---|---|
| Normal | Route line on map + visit list below. |
| Filtered-empty | "No visits in [year]" / "Try a different year or view all time." |
| Loading | Skeleton map + skeleton list. |
| Error | `ErrorState`: "Could not load your journey" / "Try again." |

#### Microcopy

- Screen title: "My Journey"
- Filtered-empty: "No visits in [year]"

---

### Screen 6: Add / Edit Visit

**Entry points:** add button on `Timeline`, edit action from `Visit Detail`.
**Presentation:** full-screen with `TopBar` (back arrow + title).

#### Layout

- Title: "Add visit" or "Edit visit".
- `Input/Search` for country selection (with flag results).
- `Input/Search` for city selection (filtered to selected country, with autocomplete).
- `Input/DateRange` for start and end dates.
- `Button/Primary`: "Save visit".
- In edit mode: `Button/Destructive` at the bottom: "Delete visit".

#### States

| State | Content |
|---|---|
| Create mode | Empty fields, "Add visit" title, Save disabled until country + city + dates are filled. |
| Edit mode | Pre-filled fields, "Edit visit" title, Delete button visible. |
| Validation error | Inline error text below the offending field (e.g. "End date must be after start date"). |
| Saving | Save button shows a loading spinner, fields disabled. |

#### Microcopy

- Create title: "Add visit"
- Edit title: "Edit visit"
- Country placeholder: "Search country"
- City placeholder: "Search city"
- Date range label: "Dates"
- Save button: "Save visit"
- Delete button: "Delete visit"
- Delete dialog title: "Delete this visit?"
- Delete dialog message: "This visit will be permanently removed."
- Delete confirm: "Delete"
- Validation: "End date must be after start date"

---

### Screen 7: Import from Photos

**Entry points:** onboarding flow, `Settings` > "Import from Photos".
**Presentation:** full-screen flow with multiple steps.

#### Steps

**Step 1: Permission**
- `Banner/Privacy`: "We only read location tags from your photos. We never access the photos themselves."
- `Button/Primary`: "Allow access to photo library"
- `Button/Text`: "Not now" (returns to previous screen).

**Step 2: Scanning**
- Progress indicator (linear or circular).
- Label: "Scanning your photo library..."
- `caption`: "[X] photos scanned"

**Step 3: Results**
- Header: "[X] visits found"
- `Button/Primary`: "Accept all" (top-right or above the list).
- Scrollable list of `ImportSuggestion` cards.
- Each card has individual accept/dismiss actions plus editable date range.

**Step 4: Confirmation**
- Summary: "[X] visits added to your timeline."
- `Button/Primary`: "Go to Timeline"

#### States

| State | Content |
|---|---|
| Permission-needed | Step 1 UI. |
| Scanning | Step 2 UI. |
| Results | Step 3 UI with suggestion list. |
| No results | `EmptyState`: "No location data found" / "Your photos don't contain location metadata, or access was limited." CTA: "Go back." |
| Error | `ErrorState`: "Something went wrong while scanning" / "Try again." |

#### Microcopy

- Privacy banner: "We only read location tags from your photos. We never access the photos themselves."
- Permission button: "Allow access to photo library"
- Scanning label: "Scanning your photo library..."
- Results header: "[X] visits found"
- Accept all: "Accept all"
- No results title: "No location data found"
- No results description: "Your photos don't contain location metadata, or access was limited."
- Confirmation: "[X] visits added to your timeline."

---

### Screen 8: Onboarding

**Trigger:** first app launch only. Not re-shown after completion or skip.
**Presentation:** full-screen flow.

#### Steps

**Step 1: Welcome**
- App name and tagline: "DaysTracker" / "Track where you've been."
- 2–3 short value points:
  - "See your days by country and city."
  - "Private and offline — your data stays on your device."
  - "Light Schengen awareness, no legal complexity."
- `Button/Primary`: "Get started"

**Step 2: Setup**
- Single screen with three options, Photo Import visually prioritized:
  - **Primary CTA**: "Import from Photos" — `Button/Primary`, full-width.
    - Subtitle: "The fastest way to get started. We only read location tags."
  - **Secondary option**: "Add manually" — `Button/Secondary`.
  - **Secondary option**: "Enable background tracking" — `Button/Secondary`.
  - **Skip**: "I'll set up later" — `Button/Text` at the bottom.
- Choosing "Import from Photos" transitions to `Import from Photos` flow (Screen 7).
- Choosing "Add manually" transitions to `Add/Edit Visit` (Screen 6).
- Choosing "Enable background tracking" shows the tracking permission prompt, then transitions to `Timeline`.
- Choosing "I'll set up later" transitions directly to `Timeline` (empty state).

#### States

Onboarding does not have loading or error states. It is a static informational flow.

#### Microcopy

- Tagline: "Track where you've been."
- Value point 1: "See your days by country and city."
- Value point 2: "Private and offline — your data stays on your device."
- Value point 3: "Light Schengen awareness, no legal complexity."
- Get started: "Get started"
- Import CTA: "Import from Photos"
- Import subtitle: "The fastest way to get started. We only read location tags."
- Manual CTA: "Add manually"
- Tracking CTA: "Enable background tracking"
- Skip: "I'll set up later"

---

### Screen 9: Country Detail

**Entry point:** tap `Card/CountryStat` in `Statistics`.
**Question it answers:** "What visits do I have in this country?"

#### Layout

- `TopBar` with back arrow, title: "[Flag] [Country]".
- Summary: total days for the selected period, displayed as `headline`.
- `Chip/Period` row (same as Statistics, preserving the user's current selection).
- Scrollable list of visits in this country, using `Card/Visit`.

#### States

| State | Content |
|---|---|
| Normal | Summary + visit list. |
| Empty | "No visits in [Country] for this period." |
| Loading | Skeleton summary + skeleton cards. |

---

### Screen 10: City Detail

**Entry point:** tap `Card/CityStat` in `Statistics`.
**Question it answers:** "What visits do I have in this city?"

Same layout and states as `Country Detail`, scoped to a single city. Title: "[Flag] [City], [Country]".

---

### Screen 11: Visit Detail

**Entry point:** tap `Card/Visit` in `Timeline` or any visit list.
**Question it answers:** "What are the details of this visit?"

#### Layout

- `TopBar` with back arrow, trailing edit button (icon).
- Flag + City, Country as `display` heading.
- Date range: `body` / `on-surface-secondary`.
- Days count: `headline`.
- Source: `Badge/Confidence` (`Confirmed`, `Possible`, or `Manual`).
- `Button/Destructive`: "Delete visit" at the bottom.

#### Actions

- Edit button → navigates to `Add/Edit Visit` in edit mode.
- Delete button → `Dialog/Destructive`.

#### States

Normal only. If the visit no longer exists (deleted elsewhere), navigate back to the previous screen.

---

### Screen 12: Location Confirmation Prompt

**Trigger:** background tracking registers a single ping in a city.
**Presentation:**
- **App is in foreground:** `LocationConfirmCard` pinned at the bottom of `Timeline` (inline, not modal).
- **App is backgrounded:** system push notification with the same copy.

#### Content

- Message: "You might have been in [City, Country]. Were you there?"
- Confirm: "Yes" (`Button/Primary`, compact).
- Dismiss: "No" (`Button/Text`).

#### Behavior

- Confirming creates a visit with the detected city and the ping's date.
- Dismissing removes the prompt and discards the pending ping.
- Multiple pending pings can stack, showing the most recent first.

---

### Screen 13: Schengen Detail

**Entry point:** tap `Card/Schengen` in `Statistics`.
**Question it answers:** "Which visits are counting toward my Schengen total?"

#### Layout

- `TopBar` with back arrow, title "Schengen Detail".
- Summary section at the top:
  - Days used / days remaining: `headline`.
  - `ProgressBar/Schengen`.
  - Window dates: "Window: [start date] – [end date]" / `body-small` / `on-surface-secondary`.
  - Earliest re-entry (only when over limit): `body-small` / `schengen-over`.
- Calendar section:
  - Month-by-month calendar grid using `CalendarCell`.
  - Schengen presence days marked with `schengen-safe`, `schengen-caution`, or `schengen-over` dots depending on their position in the 90-day accumulation.
  - Non-Schengen days: no dot.
  - Navigate months with arrow buttons or swipe.
  - The calendar covers the 180-day window (roughly 6 months).
- Contributing visits list:
  - `SectionHeader`: "Contributing visits"
  - List of visits in Schengen-zone countries within the 180-day window, using `Card/Visit`.
  - Each card shows flag, city, country, date range, and days count.
- Disclaimer: `Banner/Privacy`-style inline note at the bottom: "This is an approximate calculation based on your logged visits. It is not legal advice."

#### States

| State | Content |
|---|---|
| Normal | Summary + calendar + visit list + disclaimer. |
| Empty | `EmptyState`: "No Schengen visits logged" / "Add visits in Schengen-zone countries to see your rolling count here." |
| Loading | Skeleton summary + skeleton calendar + skeleton cards. |

#### Microcopy

- Screen title: "Schengen Detail"
- Window label: "Window: [start] – [end]"
- Earliest re-entry: "Earliest re-entry: [date]"
- Section header: "Contributing visits"
- Disclaimer: "This is an approximate calculation based on your logged visits. It is not legal advice."
- Empty title: "No Schengen visits logged"
- Empty description: "Add visits in Schengen-zone countries to see your rolling count here."

---

## Part 3: Penpot Integration Notes

### Page naming

| Page | Contents |
|---|---|
| `01 – Tokens` | Color swatches, type scale samples, spacing/radius reference, motion notes |
| `02 – Components` | All reusable components with variants and states |
| `03 – Timeline` | Timeline screen: all view modes and states |
| `04 – Statistics` | Statistics screen: all view modes and states |
| `05 – Map` | Map screen: empty, normal, tap sheets |
| `06 – Settings` | Settings screen and sub-flows (tracking, data, about) |
| `07 – Map / My Journey` | My Journey sub-view of Map: route + visit list |
| `08 – Add Visit` | Add/Edit Visit: create mode, edit mode, validation |
| `09 – Photo Import` | Import from Photos flow: all steps |
| `10 – Onboarding` | Onboarding flow: welcome + setup |
| `11 – Schengen Detail` | Schengen Detail: summary, calendar, contributing visits |

### Component naming convention

Use slash-separated hierarchy:

- `Button/Primary`, `Button/Secondary`, `Button/Destructive`
- `Card/Visit`, `Card/CountryStat`, `Card/CityStat`, `Card/Schengen`
- `Chip/Period`, `Chip/ViewMode`
- `CalendarCell/Default`, `CalendarCell/Presence`, `CalendarCell/Today`, `CalendarCell/Selected`
- `Input/Text`, `Input/Search`, `Input/DateRange`
- `Badge/Confirmed`, `Badge/Possible`, `Badge/Manual`
- `State/Empty`, `State/Loading`, `State/Error`
- `Nav/BottomBar`, `Nav/TopBar`
- `Sheet/Bottom`, `Dialog/Confirm`, `Dialog/Destructive`
- `Banner/Privacy`
- `MapPin/Single`, `MapPin/Cluster`
- `Bar/Schengen`

### Frame naming per screen

Each screen page contains frames for every relevant state:

- `Timeline/Empty`, `Timeline/Normal/ByMonth`, `Timeline/Normal/ByCountry`, `Timeline/Normal/Compact`, `Timeline/Loading`, `Timeline/Error`, `Timeline/WithConfirmCard`
- `Statistics/Empty`, `Statistics/Normal/Countries`, `Statistics/Normal/Cities`, `Statistics/Normal/Calendar`, `Statistics/Loading`
- `Map/Empty`, `Map/Normal`, `Map/TapCountry`, `Map/TapCity`
- `Settings/Normal`
- `Journey/Normal`, `Journey/FilteredEmpty`
- `AddVisit/Create`, `AddVisit/Edit`, `AddVisit/Validation`
- `PhotoImport/Permission`, `PhotoImport/Scanning`, `PhotoImport/Results`, `PhotoImport/NoResults`, `PhotoImport/Confirmation`
- `Onboarding/Welcome`, `Onboarding/Setup`
- `SchengenDetail/Normal`, `SchengenDetail/Empty`, `SchengenDetail/Loading`

### Token-to-Penpot style mapping

- **Colors:** create Penpot color styles named identically to the token names (e.g. `surface-base`, `primary`, `schengen-safe`). Group under `Surface`, `Content`, `Accent`, `Semantic`, `Schengen`.
- **Typography:** create Penpot text styles named to match the type scale (`display`, `headline`, `title`, `body`, `body-small`, `caption`, `overline`). Each style includes size, weight, line height, and letter spacing.
- **Spacing and radii:** document as reference on the `01 – Tokens` page. Penpot does not have native spacing tokens, so these serve as manual reference for frame padding and auto-layout gaps.
- **Motion:** document curves and durations on the `01 – Tokens` page as reference. Penpot does not support animation tokens natively.
