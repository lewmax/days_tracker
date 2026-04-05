---
name: daystracker-design-principles
description: Shared design principles, UX tone, and visual direction for the DaysTracker app (travel diary + light residency/Schengen awareness). Use when designing screens, writing UI copy, reviewing UX decisions, choosing color/typography/layout, or whenever visual style, interaction patterns, or tone of voice matter for DaysTracker.
version: 0.1.0
---

# Design Principles for DaysTracker

This skill defines **how DaysTracker should feel and behave as a product** from a UX/UI and copy perspective.

It is:
- a **guiding baseline** for designers, spec-writers, and dev agents,
- **not immutable** – when product direction, branding, or UX strategy changes, this skill should be updated.

When this skill disagrees with user instructions, `docs/`, or project rules, follow **Conflict resolution (DaysTracker)** (workspace rule `daystracker-conflict-resolution`).

---

## 1. Core Design Intent

- **Diary first, admin second**
  - Primary mental model: a **personal travel journal** that shows where you've been.
  - Residency/Schengen insights are secondary overlays, not the main identity of the app.
- **Privacy-first**
  - The app should feel safe, respectful, and minimal in data use:
    - clear why any data is collected,
    - no surprise sharing or uploads,
    - local-first storage by default.
- **Calm clarity**
  - Visuals and copy should reduce cognitive load:
    - minimal clutter,
    - clear hierarchy,
    - few, well-chosen actions per screen.

If a design decision increases complexity or anxiety (especially around "tax/residency"), agents should question it.

---

## 2. Visual Style and Atmosphere

- **Mood**
  - Calm, trustworthy, reflective – closer to a personal journal than a finance dashboard.
  - Avoid aggressive or "alarm" aesthetics (red warnings everywhere, harsh contrast for non-errors).
- **Color**
  - Base palette: soft neutrals and muted accent colors.
  - Use strong colors primarily for:
    - actionable elements (primary buttons, key highlights),
    - true warnings/limits (e.g. close to Schengen 90/180), used sparingly.
- **Typography**
  - Clean, modern sans-serif; prioritize legibility over stylistic flair.
  - Establish clear hierarchy:
    - large, friendly headings,
    - medium-weight labels,
    - body text that is comfortable for long reading (logs, notes).
- **Iconography and imagery**
  - Use simple, lightweight icons (e.g. location, calendar, flags).
  - Avoid heavy illustration styles that dominate content; trips and day counts are the heroes.

Concrete tokens and exact palettes should come from the design system (e.g. Penpot tokens) and can evolve over time.

---

## 3. Layout and Information Hierarchy

- **One clear "focus" per screen**
  - Each screen should have a primary question it answers (e.g. "Where was I this month?", "What are my days by country?").
  - Avoid mixing many unrelated modules above the fold.
- **Progressive disclosure**
  - Show simple summaries first (e.g. total days per country), then allow drilling into details (trip breakdowns, exact dates).
  - Hide rarely needed advanced options behind secondary actions or expandable sections.
- **Consistent structure**
  - Reuse patterns across screens:
    - section titles and spacing,
    - card layouts for lists of visits,
    - consistent empty/loading/error blocks.

---

## 4. Navigation and Main Surfaces

Until updated by more detailed design docs, agents can assume:

- **Bottom navigation**
  - 3–4 main tabs, for example:
    - **Timeline / Home** – recent and upcoming presence, quick entry.
    - **Statistics** – aggregated days per country/city, key periods.
    - **Calendar** – month view of days and locations.
    - **Settings** – app behavior, data control, residency/Schengen preferences.
- **Key secondary flows**
  - **Add/Edit Visit** – modal or full-screen flow started from a clear "+" or primary CTA.
  - **Day / Visit Details** – reachable from taps on timeline items or calendar cells.
- Navigation should be:
  - predictable (no hidden magic swipes for core actions),
  - reversible (easy to go back without losing context).

---

## 5. Core Interaction Patterns

- **Fast capture**
  - Adding a visit should be possible in a few simple steps:
    - choose country,
    - choose city (search/autocomplete),
    - date range picker,
    - optional note.
- **Calendar and timeline**
  - Calendar should be:
    - simple, legible, with clear indication of which days are "filled" and where,
    - enriched with minimal additional hints (e.g. flags, short codes) without clutter.
  - Timeline:
    - grouped by month or trip,
    - emphasizes readable period ranges ("5–12 March, Berlin, Germany").
- **States**
  - Every key screen should define:
    - **Empty state** (no visits yet / no data for filter),
    - **Loading state** (subtle spinners or skeletons),
    - **Error state** (clear message + recovery action),
    - **Overloaded state** (many items, scroll indicators, filters).

---

## 6. Privacy-First UX Patterns

- **Minimal data collection**
  - Ask only for permissions that are truly required (e.g. location when enabling background tracking).
  - Explain why the permission is needed in human language, not legalese.
- **On-device emphasis**
  - Make it clear that data is stored locally and not uploaded by default.
  - Backup/export features should be explicit, with clear user control.
- **Contextual consent**
  - Request sensitive permissions (e.g. background location) at the moment they provide clear value (e.g. enabling automatic day tracking), not at first launch.
- **User control**
  - Provide simple ways to:
    - pause or disable background tracking,
    - review and delete visits or histories,
    - export or clear data.

---

## 7. Copy & Tone of Voice

- **Neutral and reassuring**
  - Avoid fear-based language ("You are in DANGER of tax penalties!").
  - Prefer supportive phrasing ("You're approaching 90 days in Schengen. Consider reviewing your travel plans.").
- **Plain language**
  - Avoid legal and tax jargon where possible.
  - When technical terms are necessary, explain them briefly in tooltips or secondary text.
- **Honest about limitations**
  - Never promise legal/tax correctness.
  - Use disclaimers where appropriate, but keep them concise and readable.

Agents generating strings should default to this tone unless explicitly told otherwise.

---

## 8. Accessibility and Inclusivity

- **Readable by default**
  - Adequate text sizes and color contrast.
  - Avoid relying solely on color to convey important meaning (e.g. use icons/labels for thresholds).
- **Touch targets**
  - Buttons and tap areas suitable for mobile use (>=44x44dp).
- **Motion and animation**
  - Use gentle, purposeful transitions (e.g. for switching tabs, showing modals).
  - Avoid jarring or purely decorative animations, especially around "warning" moments.

When in doubt, prefer **simple, static clarity** over flashy effects.

---

## 9. Handling Residency & Schengen Features

- **Framing**
  - Always present these tools as **helpers** and **estimates**, not official calculators.
- **Visual treatment**
  - Integrate thresholds (e.g. 90/180 days) into existing views:
    - simple progress indicators,
    - small banners or cards summarizing status.
  - Avoid turning the whole app into a red warning dashboard.
- **User education**
  - Offer very short, optional explanations:
    - what 90/180 means,
    - how counts are approximated,
    - that rules may vary by country.
  - Link to external resources only if requested or if docs specify.

---

## 10. Evolution and Overrides

- This skill captures the **current design intent** but is explicitly **open to change**:
  - UX research (`01_research.md`), design brief (`02_design_brief.md`), and detailed screen docs may refine or override these principles.
  - The user (product owner) can shift emphasis (e.g. from "diary-first" to "residency-first"), and agents should then:
    - update this skill,
    - and treat the updated version as the new baseline.

When an agent detects repeated conflicts between actual design work and this skill, it should recommend revising the skill rather than silently ignoring it.
