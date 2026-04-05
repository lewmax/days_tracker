---
name: daystracker-domain
description: Provides shared domain knowledge and UX/product context for the DaysTracker app (travel diary plus light residency and Schengen awareness). Use when planning features, writing copy, modeling data, reviewing UX, or whenever product scope, personas, or non-goals matter for DaysTracker.
version: 0.1.0
---

# DaysTracker – Domain Skill

Shared context for **DaysTracker**: what the product is, who it is for, and core domain concepts. **Not frozen**—update this skill when direction, flows, or business rules change.

Treat this skill as the **starting point** for product understanding; refine using newer `docs/*.md` files and the user’s explicit instructions.

---

## 1. Product Overview

- **Working title:** DaysTracker  
- **Platforms:** Mobile — iOS and Android (Flutter).  
- **Core idea:** A **personal travel diary** recording where the user has been (countries and cities) and for how long.  
- **Secondary goal:** **Light** support for:
  - tax residency awareness (e.g. roughly how many days in Country X this year),
  - Schengen 90/180 awareness (e.g. proximity to 90 days in Schengen in the last 180 days),  
  without becoming a full legal or tax engine.

**Principles**

- **Diary first, admin second.** Calm personal log, not a tax form.  
- **Privacy-first.** Local on-device storage; no cloud or social in initial versions.  
- **Clarity over complexity.** Travel history and day counts understandable at a glance.

---

## 2. Primary Use Cases

Optimize UX and decisions around:

1. **Log where I’ve been**  
   Quick recording of visits (country, city, date range); later, background location → timeline of visits.

2. **See travel history as a diary**  
   Past trips by month/year, country/city, calendar or list — memory-log feel (“March between Warsaw and Berlin”).

3. **Understand day counts**  
   “How many days in X over Y?” — presets (7 / 31 / 183 / 365 / all time); custom ranges possible later.

4. **Light residency and Schengen (secondary)**  
   **Approximate** overview (e.g. 183 days in X this tax year; 90/180 Schengen). **Inform**, not advise: no detailed per-country rule engine; no compliance or legal guarantees.

---

## 3. Non-Goals (current direction)

Do **not** push the product here unless the user explicitly widens scope:

- Full **tax/legal advisory** or country-specific legal logic.  
- Complex **workflow automation** (forms, letters, accountant exports) in v1.  
- **Social** features: feeds, followers, public profiles, likes.  
- Heavy gamification or travel “achievements” by default.  
- Mandatory accounts / server-side storage in initial versions.

If newer instructions or docs change non-goals, **prefer the newer source**.

---

## 4. Target Users

Broad personas (unless updated):

1. **Digital nomad / remote worker** — frequent moves; simple log; rough feel for tax residency / Schengen.  
2. **Frequent traveller / consultant** — business trips; easy **days per country** checks.  
3. **New expat / migrant** — record of time inside/outside a country over the year.

**Tone:** neutral, respectful, non-technical, not fear-driven.

---

## 5. Core Domain Concepts (informal)

Conceptual, not code; align with but not limited by implementation.

| Concept | Meaning |
|--------|---------|
| **Country** | Sovereign country (ISO code, name, flag); groups visits and counts. |
| **City** | Locality within a country; often from reverse geocoding. |
| **Visit** | Continuous stay in a **city** (and its country). Start/end dates (inclusive), optional notes, manual vs automatic. **Must not overlap** in time for the same user. |
| **Day / presence** | Calendar day and whether the user was in a country/city; drives stats (“days in X in last 183”). Partial days, time zones — see technical docs; rules may evolve. |
| **Location ping** (later) | Lat/lon, accuracy, timestamp; background logic derives visits and daily presence; may be stored for audit/debug, not always shown in UI. |

Do not invent new domain entities unless the user or tech docs introduce them.

---

## 6. UX and Tone Guidelines

- **Diary feel:** chronological, human-readable; friendly labels (“Days in Germany this year”), not jargon.  
- **No fear or legal overpromising:** not legal/tax advice; use “approximate”, “for your reference”, disclaimers where appropriate.  
- **Quick daily use:** log visits in a few taps; recent history easy to scan.  
- **Offline-first:** local data, works without network; future online features respect privacy and are clearly explained.

More precise rules in future design docs **override or refine** this section.

---

## 7. Relationship to Other Docs

This file is a **domain overview**, not a full spec.

**More detail (when present):**

- `docs/01_research.md` — competitor and UX research  
- `docs/02_design_brief.md` — product and UX brief  
- `docs/design/04_screens_and_components.md` — screens and states  
- `docs/tech/architecture.md`, `docs/tech/domain_model.md`, `docs/features/*.md` — technical and feature detail  

**Conflict resolution:** follow **Conflict resolution (DaysTracker)** (workspace rule `daystracker-conflict-resolution`). This skill applies when newer `docs/` or user instructions do not cover the topic.

Expect **direction shifts** (diary vs residency emphasis, new personas or markets). Revise this skill when reality changes.
