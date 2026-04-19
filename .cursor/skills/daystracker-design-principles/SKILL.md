---
name: daystracker-design-principles
description: Shared design principles, UX tone, and visual direction for the DaysTracker app (travel diary + light residency & Schengen awareness). Use when designing screens, writing UI copy, reviewing UX decisions, choosing color/typography/layout at a principle level, or whenever visual style, interaction patterns, or tone of voice matter for DaysTracker.
version: 0.2.0
---

# Design Principles for DaysTracker

This skill defines **how DaysTracker should feel and behave as a product** from a UX/UI and copy perspective.

It is:
- a **guiding baseline** for designers, spec-writers, and dev agents,
- **not immutable** – when product direction, branding, or UX strategy changes, this skill should be updated.

When this skill disagrees with user instructions, `docs/`, or project rules, follow **Conflict resolution (DaysTracker)** (workspace rule `daystracker-conflict-resolution`).

## Scope: what belongs here vs elsewhere

| **Keep in this skill** | **Do not duplicate here** |
|--------------------------|----------------------------|
| Product personality: diary-first, calm, privacy-first | Exact layouts, spacing, component variants |
| Tone of voice and copy guidelines | Pixel sizes, chip labels, date string formats, FAB position |
| High-level IA (e.g. one focus per screen; progressive disclosure) | Frame names, Penpot page paths, token hex values |
| Accessibility *principles* (contrast, tap targets, color + label) | Per-screen specs and “how row X looks” rules |
| How to frame Schengen/residency (helper, not alarm dashboard) | Add-visit step-by-step UI choreography |
| Reusable heuristics (empty/loading/error/success patterns in words) | Anything that changes when design files change often |

**Authoritative for screens and visual detail:** **`Penpot`**, plus **`docs/02_design_brief.md`** and **`docs/features/*.md`**. If a past version of this skill listed micro-rules (chips, FAB, etc.), **ignore stale detail**—follow the live design and brief.

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

Concrete tokens and exact palettes come from the design system (**Penpot**); they can evolve without updating every line here.

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

- **Primary structure** (names and exact flows): follow **`docs/02_design_brief.md`** and **Penpot** — e.g. main tabs, how Timeline relates to Calendar vs list views, Settings, etc.
- **Navigation quality**
  - Predictable: no hidden magic swipes for core actions.
  - Reversible: easy to go back without losing context.
- **Secondary flows** (add/edit visit, day vs visit detail, edit constraints): **do not** invent here; use the brief, feature docs, and Penpot as the source of truth.

---

## 5. Core Interaction Patterns

- **Fast capture**
  - Logging a visit should stay **short** (country → place/city → dates → optional note, or equivalent per design).
  - **Create** vs **edit** should differ clearly: e.g. choosing a place when adding vs read-only fields when only dates or notes change—**exact behavior** is defined in design/brief, not in this skill.
- **Calendar and timeline**
  - Calendar: legible; make it obvious which days have data vs empty days; avoid cluttering cells.
  - Timeline/list: human-readable ranges and grouping; prefer **newest-first** or another consistent order as specified in product docs.
  - List/timeline **layout, chips, badges, FAB, flags**: implement to **Penpot**; do not treat old markdown micro-specs as binding.
- **States**
  - Every key screen should account for:
    - **Empty**, **loading**, **success**, **error** (and edge cases like filters with no results where relevant).

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
  - Buttons and tap areas suitable for mobile use (e.g. ~44×44dp minimum where applicable).
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

- UX research (`01_research.md`), design brief (`02_design_brief.md`), Penpot, and feature specs may refine or override these principles.
- The user (product owner) can shift emphasis (e.g. diary-first vs residency-first); agents should then **update this skill** to match.

When implementation repeatedly diverges from this skill because the **design file** is ahead, **update the skill’s principles**—do not resurrect obsolete micro-rules.

---

## 11. Quick checklist per screen

- [ ] **One clear primary question** this screen answers.
- [ ] **Diary-first framing** — travel history first; residency/Schengen hints second.
- [ ] **Consistent** cards, lists, and empty states with the rest of the app.
- [ ] **States** — empty, loading, normal, error (and edge cases where relevant).
- [ ] **No fear-based language** around residency/Schengen; calm, informative tone.
- [ ] **Key actions visible** without hunting in hidden menus or gestures.
- [ ] **Microcopy** — short labels, verb-led buttons, errors that suggest recovery.
- [ ] **Accessibility basics** — contrast, tap targets, don’t rely on color alone.
