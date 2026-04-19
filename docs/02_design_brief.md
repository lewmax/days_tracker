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
  - Users can review confirmed day counts and rankings in `Statistics` across countries, cities, continents, and **Top week** (rolling 7-day window with the most unique cities visited).
  - Period chips are `All` (default), `This year`, `Prev year`, and `Last 183 days`; `Prev year` appears only when the previous calendar year contains enough confirmed data to feel meaningful.
  - Category chips appear only when the current confirmed dataset can support a real comparison, and switching a chip updates the same content area without tab animation.
  - The screen supports alternative views, including a calendar-style option.
- **Timeline**
  - Users can review visits in `Timeline`.
  - The screen supports multiple view modes for scanning and review.
- **Map and Year rewind**
  - `Map` shows visited countries (filled) and optional city pins; a **Display Cities?** control is a **toggle** (track + knob, not a checkbox row): **on** shows city pins (with **clustering when zoomed out**); **off** hides pins for a calmer map. Subcopy in Penpot: *Pins for places you’ve logged*.
  - **Year rewind** is a secondary experience: chronological visits for a chosen **calendar year** on a real map, with playback and a timeline sheet (see Secondary flows).
  - **Eligibility (hard rule):** Year rewind for calendar year **Y** exists only after that year has **fully ended**. Concretely, **Rewind Y** unlocks on **1 January Y+1** (device **local calendar**). Example: **Rewind 2026** is available from **1 January 2027** onward; it is **not** offered while **2026** is still in progress.
  - On `Map`, a **Rewind {year}** button (e.g. **Rewind 2026**) opens Year rewind for the **same calendar year as the map’s active year filter**, but **only if that year is eligible** per the rule above. The button also requires at least **three** cities visited (**all time**); below that threshold it does not render on `Map`.
  - **`Settings` → Rewinds history** opens a **Rewinds** list screen: every **eligible** completed calendar year the user can open as a rewind (newest first), with optional subtitle chips (e.g. cities / countries); **empty state** when none exist yet. Optional secondary row **Check out Rewind {year}** may still highlight the **latest completed** year (same **Y+1** unlock rule) for discovery; it does not replace the history list.
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
- The user can switch to `Statistics`, which opens on `All` by default, then change the period or category chip to answer a question like "How many days was I in Portugal this year?"
- The user opens `Map` to see visited countries filled; city pins are optional via the **Display Cities?** toggle.
- If the user has visited at least three cities **and** the map’s selected year **Y** is already **complete** (today is **on or after 1 January Y+1**), **Rewind Y** appears on `Map`.
- The user taps **Rewind Y** to open **Year rewind**: a connected route for that calendar year plus a chronological list of visits (playback, progress, snap sheet — see Secondary flows). For the **current** calendar year, there is **no** rewind control until the following **1 January**.
- The user can open the light Schengen helper when needed (for example from **`Map`** or the dedicated **Schengen** flow in Penpot — not on the `Statistics` tab, which stays focused on country/city/continent/week answers).

### Edge user

- The user has many visits across countries and cities over multiple years.
- The app still makes scanning manageable through period filters, conditional category chips, view modes, and grouped map pins.
- The user can narrow views by answer type or time period instead of facing one long undifferentiated history.
- **Year rewind** becomes a meaningful secondary lens once a calendar year has **ended**, the user has enough cities for the `Map` control, and they browse **past** years on the map; clustering keeps city pins readable at scale.
- Editing remains possible without forcing the user through complex workflows or legal terminology.

## 6. UX Principles and Tone

### UX principles

- **Personal tracker first**
  - Position the product as a calm tool for tracking time spent in places, not as a diary app and not as a compliance product.
- **Calm and precise**
  - The interface should feel trustworthy and exact without becoming severe or alarmist.
- **Fast to understand**
  - Each top-level screen should answer one clear question.
  - On `Statistics`, one active category and one active period should drive the content at a time so the screen behaves like an answer surface, not a dashboard.
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
- **Year rewind** is not a tab. It is a secondary view for **completed** calendar years only, entered from **`Map`** (**Rewind Y** when **Y** is eligible) and from **`Settings` → Rewinds history** (list of years); optional **Check out Rewind {year}** can still highlight the latest completed year.
- `Import from Photos` is available during onboarding and later via **`Settings` → Import data** (hub), not as a standalone root screen.

### `Timeline`

- **Purpose**
  - Show what visits are logged and make review or editing easy.
- **Main sections**
  - **Two modes only:** **`Calendar`** (month grid, scroll through months; days show **country flags**) and **`Chronological`** (scrollable list of **country groups** with **nested city rows**).
  - **`Chronological` — country group header:** **No semicolons, no bullet lines.** Show the **country name** (with flag) as the **primary title**. Under it, show aggregate facts as **chips** in the **same visual language as period filters** on the **`Statistics`** screen in **Penpot** (pill presets: muted fill, selected = teal label + thin outline): **pill-shaped** (large corner radius), **slightly elevated surface** vs. the row background, **secondary/muted label** inside each chip, **even horizontal spacing**, **`Wrap`** layout so chips **flow to the next row** when width runs out. **Flag emoji** in Penpot and in the app must use a typeface that actually draws colour flags (e.g. **Noto Emoji** in Penpot; on device, use **`fontFamilyFallback`** with an emoji-capable font or split flag vs body so regional-indicator pairs are not blank). The **country name** must start **after** the flag: **`nameLeft = flagLeft + flagWidth + gap`** (e.g. **8px**) so the title **never** overlaps the flag’s glyph box (overlap hides the flag even when the font is correct).  
    - **Chip strip** (the `Wrap` / flex container): **no** fill — chips sit **directly on** the row/card background. Each chip is a **pill** whose **width follows the label** (horizontal padding only), not a fixed circle that clips text.  
    - **Default (informational) chips** — like **2024 / 2025 / 2026** in the reference: **no** teal border; label colour **muted** (not primary body white).  
    - **Selected chip** (use only when one chip is the active choice, e.g. a tappable filter) — like **All** in the reference: **teal/cyan label** and a **thin teal outline** around the pill. On **Chronological** list rows, treat stats chips as **informational (default)** unless the product explicitly adds a selectable chip.  
    - **`{m} visits`** = number of **visit rows** under that country (revisits count as separate rows). **`{d} days`** = **total days** summed across those visits. **Dates in chips** use **short month names** (**`Jan`**, **`Feb`**, …).  
    - **Which aggregate chips to show:** **`{n} cities`** only if **`n > 1`**. **`{m} visits`** only if **`m > 1`** — **never** show a **`1 visit`** chip. If **`d = 1`** (single calendar day for that country block), **do not** show a **`1 day`** chip — show **only** **`{day} {Mon}`** (e.g. **`4 Jan`**). If **`d > 1`**, show a **`{d} days`** chip plus a **span** chip unless start and end are the **same calendar day** (then **one** date chip, not a duplicated range).  
    - **Same calendar month:** use **`{d1}-{d2} {Mon}`** (e.g. **`1-5 Jan`**, **`2-12 Feb`**), **not** **`1 January - 5 January`**. **Across months:** **`{d1} {Mon1} - {d2} {Mon2}`** (e.g. **`31 Jan - 4 Feb`**).
  - **`Chronological` — city / stay row:** **No semicolons, no bullet lines.** **City name** is the primary label; facts as **pill chips** in a **wrapping row** (same reference styling).  
    - **Single-calendar-day stay:** show **only** **`{day} {Mon}`** (e.g. **`4 Jan`**). **Do not** show **`1 day`**.  
    - **Multi-day stay:** show **`{N} days`** plus a **range** chip using the **same-month** or **cross-month** rules above (e.g. **`3-5 Jan`**; **`31 Jan - 4 Feb`**).  
    - **Sort order:** visit rows under a country are ordered **newest to oldest** by **end date** (descending).
  - **Example (Germany, illustrative):**  
    - **Title:** **`Germany`**. **Chips (when counts apply):** **`5 cities`** **`7 visits`** **`22 days`** **`15 Jan - 12 Feb`** (wrap as needed). The dense Penpot frame adds **three older Jan** stays below the first four city rows (Hamburg, Cologne, second Düsseldorf).  
    - **City rows (newest first):** **Berlin** + **`12 Feb`** only; **Düsseldorf** + **`10 days`** **`2-12 Feb`**; **Berlin** + **`5 days`** **`31 Jan - 4 Feb`**; **Mannheim** + **`3 Feb`** only; then …
  - Add or edit entry point (app bar `+` and FAB). **FAB (`+`):** always **fixed to the bottom of the viewport**, horizontally centred (or end-aligned per platform), **above** the bottom tab bar, and **above** the scrolling list in the **z-order** (`Stack`: `Positioned.fill` scrollable content + `Positioned` FAB). It must **not** sit in the scrollable column as if it were another row — same on-screen position in **Calendar** and **Chronological**. In **Penpot**, `FAB / AddVisit` is placed **just above** the bottom **`Timeline` / `Statistics` / …** labels on each phone frame (`03 – Timeline`).
  - Empty, loading, and error states.
- **`Day Detail`** (entered **only** from **`Calendar`**)
  - **Entry:** user taps a day in the month grid. There is **no** equivalent entry from **`Chronological`**.
  - **Content:** information for **that single calendar day** only (places / cities present that day). The **screen header** carries the fixed calendar day. **Place rows** may still use **chip rows** for **stay-level** metadata (aggregates, **short months**, **same-month** span form, omit **`1 day`** / **`1 visit`** when the value is **1**) — same vocabulary as **Chronological** — so each row reads like the same card component without re-stating “today” as a lone date chip.
  - **`+`:** opens **create visit** with the **date (range) fixed** to that **Day Detail** day. The user **only** fills **city** (text / search); **no** date controls on this path.
- **`Visit Detail`** (entered **only** from **`Chronological`**)
  - **Entry:** user taps a **city** row (a concrete stay under a country). **On `Timeline` / `Chronological` only, tapping the country row / header does nothing** (no navigation, no drill-in). On **`Statistics` / `Top countries`**, country **summary cards** are tappable and open **`Statistics / Country cities`** (see **`Statistics`** IA).
  - **Editing:** user may change **dates only**. The **city** (and country) line is **read-only**: show it **greyed / disabled**, with **no** chevron to change place and **no** location / map control (identity of the stay is the city they tapped).
- **How a user gets there**
  - Bottom tab.
  - Natural landing state after the first successful import or first manual entry.
- **Penpot**
  - **`Day Detail`** artboards use the prefix **`Timeline / Calendar / Day Detail`** (on the **`03 – Timeline`** page in Penpot). Place rows use the same **chip layout** and **copy rules** as **Chronological** (including **short months** and **full-height amber** stripe for possible rows). **`PossibleMixed`** day-detail matches Chronological **Lisbon**: **`Unconfirmed`** (**amber / yellow** pill) + **`6 Jan`** only; **amber vertical line** spans the **full height** of the row card. **Stacking:** nested country/city rows must use **vertical spacing ≥ row height + gap** so cards never overlap (frames **`HeavyStack`**, **`MultiCountryMultiCity`**, base **`Day Detail`**). **Do not** commit Penpot **screenshot PNGs** into **`docs/design/assets/`** — that folder is not the UI source of truth; keep visuals in **Penpot** only.
  - **Chronological — dense two-country example:** **`Timeline / Chronological / TwoCountriesRepeatVisits`** — **Germany** and **France** only; **five cities per country** with **repeat visits**; country and city rows use **wrapping chip rows** as above (**end-date sort**). Use for scroll overlap and legibility checks with the FAB.
  - **Possible / unconfirmed places (tracking or import):** use the **left-accent row** pattern (**option B**): **amber vertical stripe** from **top to bottom of the row card** (full height); **city name** as title; **`Unconfirmed`** as an **amber/yellow** chip (distinct from neutral stat chips); **single suggested day:** date chip only (**`6 Jan`**), **no** **`1 day`**. **Multi-day:** **`{N} days`** + range with **short months** and **same-month** hyphen form where applicable. Teal **Confirm** stays separate; **dismiss** (🗑). Reflected in Penpot on **`Timeline / Chronological / PossibleMixed`** and **`Timeline / Calendar / Day Detail / PossibleMixed`**.
  - **Help · Possible places:** Penpot **`Timeline / Help / PossiblePlaces`** — copy explains the flow; the **example row** matches **`PossibleMixed`** (chips **`Unconfirmed`** + **`6 Jan`**, no **`1 day`** line, compact row height, square amber stripe).
  - **`Edit visit`** (including **`VisitDetailFromChrono`** when used) matches **`AddVisit / EditFilled`**: title **Edit visit** or **Visit detail**, **city** line **muted / secondary** colour, **no** chevron and **no** **⌖** on the city row; **dates** row stays normal and editable.
  - **`Add visit` from a calendar day** is **`AddVisit / FromDayDetail`** on the Add Visit page (`Day` row shows the fixed day; **city** remains editable; no date picker row). On the Penpot **Add Visit** page, each **row** is one feature: **create visit** (empty, filled, saving, **date range** via **`AddVisit / DialogCalendar`** — centred sheet on dim scrim, **month title** with **‹ ›**, **Mon–Sun** headers, **6×7 day grid**, in-range days use **teal** with **stronger endpoints**, summary line **5 Mar – 12 Mar 2025**, **Cancel** / **Save range**), **edit / contextual forms** (edit, **`VisitDetailFromChrono`** when present, from day), **delete-visit dialog** alone, **choose city** (`CitySearch / MapPickEmpty`, **`CitySearch / SearchFocused`** (was *Default*), **`CitySearch / Results`**, **`CitySearch / NoResults`**, **`CitySearch / MapPinSelected`**) — align copy and layout with **Choose city** in Secondary flows.

### `Statistics`

- **Purpose**
  - Answer how many days the user spent where, using confirmed data only and one active answer lens at a time.
- **Main sections**
  - Period presets (use the **same pill-chip pattern** as in **Penpot** on **`Statistics`** / **`Timeline`**: default = muted fill + muted label; **selected** preset = **teal label + thin teal outline**). The available period chips are **`All`** (default), **`This year`** (**1 Jan -> today**), **`Prev year`** (**previous full calendar year**), and **`Last 183 days`**. Hide **`Prev year`** when the previous calendar year does not contain enough confirmed data to feel meaningful.
  - Category chips shown only when the current confirmed dataset can support a meaningful comparison: **`Top countries`** (only if there are at least **2 countries**), **`Top cities`** (at least **2 cities**), **`Top continents`** (at least **2 continents**), and **`Top week`** (only if there are at least **14 tracked days** overall and at least one rolling **7-day** span with **2 or more unique confirmed cities**).
  - One content area that updates **in place** when a category chip is selected. There is no tab animation; the user stays on the same screen and the answer changes immediately.
  - **Ranking lists** use the **same card vocabulary as `Timeline` / `Chronological`**: elevated row surfaces, flag + primary title, and **informational pill chips** (muted fill, muted label — **not** the teal “selected filter” state unless the chip is an actual filter). Reuse **Penpot** `03 – Timeline` **country group** and **city row** components as the visual reference for **Statistics** list cards.
  - **`%` time spent** on every statistics card that shows it means **share of total confirmed days in the active period** (the period selected by the period chips). Same denominator for all visible rows on that screen so percentages are comparable.
  - Alternative view modes, including a calendar-style view.
  - **No Schengen block on `Statistics`** — that tab stays dedicated to the four category answers above; Schengen remains available elsewhere (see **Residency / Schengen helpers** and Penpot **11 – Schengen Detail**).
- **`Top countries` (list)**
  - **Cards:** one **country summary card** per ranked country, **Timeline country-group style** (see **`Chronological` — country group header** in **`Timeline`**).
  - **Chips on each card (informational, wrap):** **`{pct}%`** (share of period), **`{d}d`** (days in that country within the period), **`{n} cities`** (distinct cities with any confirmed presence in that country during the period — show even when **`n` is 1**).
  - **Tap:** the whole country card opens **`Statistics / Country cities`** for that country (full list of cities in the active period).
- **`Top cities` (list)**
  - **Cards:** one **city summary card** per ranked city, **Timeline city-row style** (nested visual weight: same chip strip language as **`Chronological` — city / stay row**, adapted to a full-width statistics card).
  - **Chips on each card (informational, wrap):** **`{d}d`**, **`{pct}%`** (days in the city within the period, then share of period).
- **`Top continents` (list)**
  - **Cards:** one **continent summary card** per ranked continent, **same surface pattern as Timeline country cards** (title = continent label + optional emoji / icon per design system).
  - **Chips on each card (informational, wrap):** **`{pct}%`**, **`{d}d`**, **`{n} countries`**, **`{m} cities`** (all within the active period).
  - **Tap:** opens **`Statistics / Continent detail`** — a screen of **country cards** sorted by **`{pct}%`** descending; each country card **nests Timeline-style city rows** (or city mini-cards) underneath, also sorted by **`{pct}%`** descending within that country.
- **`Top week`**
  - **Summary card** (same family as country summary cards): chips **`{start}–{end} {Mon} {Year}`** (e.g. **`10–16 Sep 2025`**), **`{n} cities`**, **`7d`** (rolling window length; use the same short **days** style as elsewhere).
  - **Below the summary card:** a **nested list by country**, each country block containing **city rows/cards** ( **`Timeline` / `Chronological`** nesting pattern) for places touched in that window.
- **How a user gets there**
  - Bottom tab.
  - The "answer screen" when users need a number fast.

### `Map`

- **Purpose**
  - Show travel footprint visually through visited countries and optional city pins.
- **Main sections**
  - Year filter (drives which year’s footprint is shown; **Rewind {year}** targets the same **Y** only when **Y** has ended — see eligibility rule in **Map and Year rewind** above).
  - Filled-country view for visited countries in the active **year filter** (align exact rules with Penpot and Statistics period semantics).
  - **Display Cities?** toggle (Penpot: **`Map / Display cities`**): when **on**, show city pins for the active scope (**cluster when zoomed out**); when **off**, only country fills. Toggle sits on a **raised dark card** under the year chips (not a high-contrast white strip).
  - Tap summaries for country or city totals.
  - Conditional **Rewind Y** button (e.g. **Rewind 2026**), only for **completed** years (available from **1 January (Y+1)** local).
- **How a user gets there**
  - Bottom tab.
- **Special rules**
  - **Rewind Y** on `Map` appears only when **(1)** today **≥ 1 January Y+1** (local), **and (2)** at least **three** visited cities (all time). If the map year is the **current** incomplete year, **do not** show a rewind button for that year.
  - **`Settings` → Rewinds history** lists all eligible years; optional **Check out Rewind {year}** (if present) follows the same unlock rule and promotes the **latest completed** calendar year (e.g. during 2027, **Check out Rewind 2026**).
  - A logged visit **always** includes a **city**; country-only visits are **not** a supported data shape, so the map does not need a separate “country without city” affordance.

### `Settings`

- **Purpose**
  - Manage tracking behavior, data import/export, and trust-related controls (permission UX is led by the OS when enabling tracking — no separate “location permission” row in Settings).
- **Main sections**
  - Background tracking (master toggle; frequency picker **disabled and de-emphasized** when tracking is off).
  - Import data (hub: JSON, photos, future sources).
  - Export data (confirm dialog + save location + path preview).
  - Clear data (destructive confirm).
  - **Rewinds history:** section **REWINDS** with one tappable row aligned like other Settings rows: primary label **Rewinds history** (same typography as **Import data**), a **chip** **`Chip / New rewind`** (**New** — teal outline on dark fill) when a **new eligible rewind** is available (hide or soften the chip when there is nothing new), then the **›** chevron → **`12 – Rewinds`** list. Optional **Check out Rewind {year}** row may still appear; same **Y+1** unlock and sparse-data rules as on `Map`.
  - Privacy notice.
  - App information.
- **How a user gets there**
  - Bottom tab.

### Secondary flows

- **Add/Edit Visit**
  - Purpose: create or correct structured history manually.
  - **Create (new visit):** user picks **city** via the **Choose city** flow (map + search + pin and/or list; see **Choose city** below), then sets **dates**. On the **Add Visit** screen, the city row **does not** show a trailing chevron on the field; **use current location** is a **prominent** control (e.g. a **circular** teal **location** button on the right, ~44pt), separate from tapping the city label to open search.
  - **Edit (existing visit):** user may change **dates only**. The **city name is not editable** — show it **greyed**; **do not** show the **location / map** button or any control that implies changing the place.
  - **From `Day Detail` (`+`):** this is **create**, not edit — date (range) is **fixed** to the selected day; **only the city field** is editable (see `Day Detail` above).
  - **From `Visit Detail`:** **edit** — same rules as **Edit** above.
  - Expected UX: simple, low-friction, and clearly confirmable.
- **Choose city** (city picker when **creating** a visit)
  - **Chrome:** **Back** on the left and the **search field in the same app bar row** (inline with the back control), not a separate title row below.
  - **Default view:** **Map is visible** under that app bar. The user can **drop a pin** on the map (e.g. long-press). When a place is resolved, show the **city name on or above the pin**. When a city is selected (via pin or list — see below), show a **primary action at the bottom**: **Select this city: {City}** (e.g. `Select this city: Lviv`), using the resolved display name.
  - **Search path:** The user can also type in the search field and pick a row from the **results list**. When the user **focuses the search field**, **hide the map** and show the **list** (and keyboard). After the user **selects a city from the list**, **show the map again**, **zoom to that city**, **drop the pin** there, update the **search field text** to the chosen option, and show the same bottom button **Select this city: {City}**.
  - **Consistency:** Pin-from-map and pick-from-list should end in the **same** on-screen state (map visible, pin at city, field matches selection, CTA visible) so the user always confirms with one control.
- **Import data (includes photos)**
  - Purpose: bring data in via **JSON** or **photo metadata** (and future sources), with confirmations where needed.
  - Entry points: onboarding (photos path) and **`Settings` → Import data**.
  - Expected UX: hub lists options; photos path keeps privacy-first copy, scanning progress, and review list — **no separate top-level “Photo Import” screen** in the information architecture.
- **Year rewind**
  - Purpose: for a **calendar year**, show a chronological route on a **real map**, with **playback** (play/stop), **progress**, and a **snap bottom sheet** (default ~40% open, collapsible to ~10%) for the timeline list. Frame as **visit-to-visit** story for that year, not a promise of a continuous GPS-quality track unless the product later adds that data.
  - Entry points: **`Rewind Y`** on `Map` (only when the map’s active year **Y** is **complete**: today **≥ 1 January Y+1**, local; and at least **three** cities visited, all time); **`Settings` → Rewinds history`** → pick a year row (same eligibility per year); optional **`Settings` → Check out Rewind {year}** for the latest completed year (same **Y+1** unlock; empty/teaser when that year has sparse data).
  - Product reason: restricting rewind to **finished** years avoids a “living year” recap that keeps changing; the conditional `Map` button and city threshold keep the surface meaningful.
- **`Statistics` → Country cities** (from **`Top countries`**)
  - Purpose: show **every city** with confirmed time in the chosen **country** for the active **period**.
  - **Entry:** user taps a **country summary card** on **`Statistics` / `Top countries`**.
  - **Chrome:** **Back** returns to **`Top countries`**; title shows **country** (flag + name, same layout rules as **`Timeline`**).
  - **Content:** scrollable **city cards** in **`Timeline` / `Chronological` city-row style**; chips per city: **`{d}d`**, **`{pct}%`** (share of **period** days).
  - **Sort:** descending by **`{pct}%`**, then by days as a tie-break.
- **`Statistics` → Continent detail** (from **`Top continents`**)
  - Purpose: break down a **continent** into **countries** and **cities** for the active **period**.
  - **Entry:** user taps a **continent summary card** on **`Statistics` / `Top continents`**.
  - **Chrome:** **Back** returns to **`Top continents`**; title shows **continent**.
  - **Content:** **Country cards** sorted by **`{pct}%`** descending (share of **period**). Each country card **nests** **city rows/cards** (same visual system as **`Timeline`** city rows), sorted by **`{pct}%`** descending within the country.
  - **Chips on country headers inside this screen** may repeat the same metrics as **`Top countries`** for that slice (optional secondary line) or stay minimal — designer chooses in **Penpot**, but hierarchy must stay readable.

## 8. Functional Requirements at UX Level

### Visit Logging

- **Manual visit entry**
  - What the user sees: for **new** visits — **Choose city** (map-first under an app bar with **back + inline search field**, pin drop, list search when the field is focused, bottom **Select this city: {City}** when a city is chosen) and **dates**. For **editing** an existing visit — **city shown greyed and non-editable**, **no** location / map control; **dates** remain the only place-related change.
  - **`Day Detail` → `+`:** create flow with **that day** pre-selected; **city** is the primary editable field.
  - **`Chronological` → city row → `Visit Detail`:** **edit** rules — **dates** editable; **city** greyed, **no** location control. **Country** taps do not open this screen.
  - What the user can do: add, edit, and delete visits without ambiguity.
  - UX success criteria: the flow feels faster than using a spreadsheet and clear enough for first-time users without explanation.
- **Background tracking**
  - What the user sees: a **toggle**, **frequency** row that is **greyed out when tracking is off**, and plain-language explanation (no dedicated Settings row for raw permission status).
  - What the user can do: enable tracking, change frequency when enabled, and confirm or dismiss low-confidence location suggestions.
  - UX success criteria: users understand the trade-off, trust the feature, and do not feel forced into always-on tracking.
- **Import (photos + files)**
  - What the user sees: an **Import data** hub; photos is one branch with the same review list and confidence labels as before.
  - What the user can do: import JSON (with confirm), run photo import, export with explicit save location, clear data with confirm.
  - UX success criteria: the product feels user-controlled, portable, and safe without scattering import entry points across many screens.

### Statistics

- **Answer-first summaries**
  - What the user sees: a single `Statistics` surface with one active period chip and one active category chip at a time. The content below updates in place rather than opening a separate tab or animated panel.
  - What the user can do: switch between `Top countries`, `Top cities`, `Top continents`, and `Top week` when those chips are available.
  - UX success criteria: a user can answer "How many days was I there?" or "Where did I spend the most time?" within seconds, without scanning a dashboard.
- **Period filters**
  - What the user sees: four possible period chips — `All` (default), `This year`, `Prev year`, and `Last 183 days`.
  - What the user can do: change the time window for the active statistics view. `Prev year` appears only when the user has enough confirmed data in the previous calendar year for the filter to be meaningful.
  - UX success criteria: period options feel relevant and trustworthy rather than exhaustive or cluttered.
- **Conditional category visibility**
  - What the user sees: category chips appear only when the selected confirmed dataset supports a meaningful comparison.
  - What the user can do: compare only categories that have enough data to produce a useful answer.
  - UX success criteria: users never interpret a disabled or empty chip as broken UI.
- **Category rules**
  - What the user sees: `Top countries` only when there are at least `2 countries`, `Top cities` only when there are at least `2 cities`, `Top continents` only when there are at least `2 continents`, and `Top week` only when there are at least `14 tracked days` in total and at least one rolling `7-day` span with `2+` unique confirmed cities.
  - What the user can do: move between rankings and summary lenses while staying inside the same screen context.
  - UX success criteria: every visible chip changes understanding, rather than restating a single-item history.
- **Top week**
  - What the user sees: the **best rolling 7-day window** (highest unique confirmed cities). A **summary card** shows chips **`{start}–{end} {Mon} {Year}`**, **`{n} cities`**, **`7d`**, then a **nested country → city** list using the same card patterns as **`Timeline` / `Chronological`**.
  - What the user can do: see which places contributed to that week without leaving the statistics mental model.
  - UX success criteria: the layout reads as “one highlighted week + its footprint,” not a separate analytics module.
- **Country / continent drill-ins**
  - What the user sees: **`Statistics / Country cities`** and **`Statistics / Continent detail`** as full screens with **`Timeline`-consistent** cards and chips (see Secondary flows).
  - What the user can do: move from an aggregate row to **city lists** or **nested country/city** breakdowns without changing visual language.
  - UX success criteria: users never think they left the app; **Back** always returns to the exact statistics list they came from.
- **Calendar-style view**
  - What the user sees: a calendar representation of where days were spent, using lightweight visual cues that stay legible.
  - What the user can do: scan presence patterns and inspect specific days or periods.
  - UX success criteria: the calendar adds clarity rather than visual noise.

### Residency / Schengen helpers

- **Schengen summary**
  - What the user sees: days used, days remaining, rolling-window dates, and earliest re-entry date if over the limit, plus a calm status indicator — **not** embedded in the `Statistics` tab (see `Statistics` IA above).
  - What the user can do: understand their approximate standing quickly without learning legal terminology, from the entry point defined in Penpot (e.g. **`Map`** or **`11 – Schengen Detail`**).
  - UX success criteria: the information is immediately understandable, visibly secondary to the main tracker experience, and never framed as legal advice.

### Map and Year rewind

- **Map footprint**
  - What the user sees: a **real map** (e.g. OSM tiles), visited countries filled for the active scope, optional city pins (via **Display Cities?** toggle), **clustering at low zoom** and **individual pins when zoomed in**, year filter, and **on-map controls** (zoom, current location, compass / north-up).
  - What the user can do: toggle city pins on or off; tap a country or city to see totals; use the map as a visual recall tool; open **Rewind {year}** when the entry point is visible.
  - UX success criteria: the map helps answer "where have I been?" rather than acting as decoration; with pins on, density stays readable thanks to clustering.
- **Year rewind**
  - What the user sees: a year-scoped route view plus a chronological list of visits for that calendar year, with playback affordances.
  - What the user can do: review movement through that year from **`Map`** or **`Settings`** discovery.
  - UX success criteria: the experience feels meaningful on `Map` once the year is **complete**, the three-city threshold is met, and the user picks a **past** map year; **Settings** discovery stays aligned with the **Y+1** unlock rule and uses clear empty/teaser copy when that year has little data.

### Settings and Data control

- **Tracking**
  - What the user sees: background tracking **toggle**, **frequency** dependent on toggle, and plain-language explanation.
  - What the user can do: turn tracking on or off; change interval only when on.
  - UX success criteria: settings reinforce trust rather than feeling technical or intimidating.
- **Import, export, and reset**
  - What the user sees: **Import data** hub; **export** confirm with **folder/file picker** and **visible path**; **clear** destructive confirm; JSON import confirm where needed.
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
- **Risk: map and Year rewind feel empty too early**
  - A rewind screen with too little data has low value; offering rewind for the **current** year would also keep changing as new visits arrive.
  - Strategy: only unlock **Rewind Y** after **1 January Y+1**; hide **Rewind Y** on `Map` until the user has visited at least three cities (all time); **`Settings` → Rewinds history** should stay honest when the list is empty; optional **Check out Rewind {year}** uses empty/teaser copy so discovery does not promise a full “movie” before data exists.
- **Risk: advanced setup leaks into mainstream UX**
  - Provider-specific or implementation-specific configuration can confuse ordinary users.
  - Strategy: keep the UX brief generic around location and geocoding services, and avoid exposing technical setup unless it becomes truly necessary.
- **Risk: future scope expands faster than the core loop stabilizes**
  - Alerts, additional imports, charts, and achievements can overwhelm the product before the core tracker is excellent.
  - Strategy: treat MVP as a discipline exercise: logging, reviewing, counting, mapping, and calm Schengen awareness first.

## 10. Penpot (visual source of truth)

- **File:** `days_tracker` (connected via Penpot MCP in the workspace session).
- **Statistics:** page **04 – Statistics** — hi-fi references (no Schengen on these):
  - **Lists:** `Statistics / Top countries`, `Statistics / Top cities`, `Statistics / Top continents`, `Statistics / Top week` — each uses **`03 – Timeline` / `Chronological`** **country** and **city** card patterns for list rows; chips per **§7 `Statistics`** (`%` = share of **active period** confirmed days).
  - **Drill-ins:** `Statistics / Country cities` (from **`Top countries`** tap) and `Statistics / Continent detail` (from **`Top continents`** tap) — **Back** to parent list; nested sorting and chips per Secondary flows above. List content aligns with the same **vertical offset** as list screens (below chips), with **flag / continent** in the app bar where applicable.
  - **Empty (reference):** `Statistics / Empty — period` — same **Statistics** shell when the active period has **no confirmed days**; copy nudges users to change the period or add visits from **Timeline**.
  - **Loading (reference):** `Statistics / Loading` — same shell while aggregates refresh; skeleton rows + short reassurance copy (device-local).
- **Map:** page **05 – Map** — hi-fi frames **`Map / Normal`**, **`Map / Empty`**, **`Map / MultiCountryOneDay`**: year chips; **`Map / Display cities`** card — title **Display Cities?** (**Work Sans** semibold), subtitle *Pins for places you’ve logged*, **iOS-style switch** (teal track, white knob **on** — add an **off** variant frame later if needed); **`Map / Base map`** = **`docs/design/assets/osm-map-tile-europe.png`**; **`Map / Map scrim`** + **`Map / Visited wash`** (design-only footprint hint); city markers **BER / WAW / LIS** or **CDG / FRA / WAW**; **Rewind 2025** pill (dark label on teal, text inside pill); zoom / locate / north; tab bar.
- **Settings:** page **06 – Settings** — **`Settings / TrackingOn`** & **`Settings / TrackingOff`**: section **REWINDS** + **`Settings / Rewinds history row`**: flex row (**space-between**), **Rewinds history** label + **`Chip / New rewind`** when applicable + **›**, same line weight as **Import data** rows.
- **Rewinds list:** page **12 – Rewinds** — **`Rewinds / List`** (Back, title **Rewinds**, example rows **Rewind 2025** … with subtitle chips) and **`Rewinds / Empty`** (empty copy). Tapping a row → **Year rewind** for that year (**§4** eligibility).
- **Year rewind:** page **07 – Map / Year rewind** — frames **`Year rewind / Idle`**, **`Year rewind / SheetClosed`**, **`Year rewind / Playing`**, **`Year rewind / Stopped`**, **`Year rewind / Loading`**, **`Year rewind / Error`**, **`Year rewind / FilteredEmpty`**: app bar **Rewind 2025**, playback, **Rewind timeline**; align with **Secondary flows → Year rewind**.
