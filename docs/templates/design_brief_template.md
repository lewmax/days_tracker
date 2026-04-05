# Template: `docs/02_design_brief.md`

**Purpose:** Structure for **DaysTracker – Product & UX Design Brief**. Used by the Product & UX Strategist agent and anyone drafting `docs/02_design_brief.md`.

This is the main document designers and later agents will use.

**Quality bar:**

- As if you are giving it to a professional UX designer and future spec-writer.
- Clear structure, headings, bullet points, no fluff.

---

# DaysTracker – Product & UX Design Brief

## 1. Product Overview

- 1–2 paragraphs describing the product.
- One clear sentence: “DaysTracker is primarily a travel diary, with secondary tools for residency day counting and Schengen 90/180 awareness.”

## 2. Target Users and Use Cases

- Define 2–3 primary personas (e.g., digital nomad, frequent business traveler, new expat).
- For each persona:
  - Goals,
  - Typical usage patterns,
  - Pain points with existing tools.

## 3. Core Value Proposition

- 3–5 bullet points describing why someone would keep using DaysTracker after 3+ months.
- Emphasize:
  - emotional value (memory / diary),
  - practical value (rough idea of “where I stand” for tax/Schengen).

## 4. App Scope and Non-goals

- IN SCOPE:
  - Manual visit logging (country, city, dates).
  - Automatic day tracking (later via background pings) – state clearly it will be added but focus first on UX.
  - Simple statistics (days per country/city, basic periods like 7/31/183/365/all time).
  - Light residency / Schengen helpers (high-level overview, not full legal engine).
- OUT OF SCOPE for v1:
  - Legal/tax advice, full compliance calculators.
  - Social / feed / public sharing.
  - Complex reminders / workflows.

## 5. High-level User Journeys

Describe step-by-step flows for:

- First-time user:
  - onboarding,
  - first visit entry,
  - first look at “where have I been”.
- Returning user:
  - quickly logging a new trip,
  - checking day counts for recent months,
  - getting a sense of “am I close to residency thresholds / Schengen limits?”
- “Edge” user:
  - many countries and cities logged,
  - messy travel history.

Use bullet-based pseudo-stories, e.g.:

- “User opens the app, sees Today and a quick summary of this month’s locations…”

## 6. UX Principles and Tone

- Define 5–7 UX principles, e.g.:
  - “Diary first, admin second.”
  - “Reassuring, never alarming.”
  - “Always reversible (no destructive actions without clear confirmation).”
  - “Inform, don’t overwhelm (for tax/Schengen).”
- Define the tone of language:
  - calm, neutral, non-legalistic,
  - avoids fear-driven copy.

## 7. Information Architecture (IA)

- List all planned top-level screens (e.g., Home/Timeline, Statistics, Calendar, Settings).
- For each screen:
  - purpose,
  - main sections,
  - how a user gets there.
- Describe navigation model:
  - likely bottom tab bar with 3–4 entries (your proposal),
  - any modals (e.g., Add Visit),
  - any special views (e.g., full calendar, day details).

## 8. Functional Requirements at UX Level

- A distilled, non-technical list of features grouped by:
  - Visit Logging,
  - Statistics,
  - Residency/Schengen helpers,
  - Settings & Data control.
- For each feature:
  - what the user sees,
  - what actions they can perform,
  - success criteria from UX point of view (not code-level).

## 9. Risks and Trade-offs

- Where the product could become too complex or too scary (especially around “tax”).
- Proposed strategies to keep it lightweight.
