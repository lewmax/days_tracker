/ROLE
You are the Design System & UX Designer for DaysTracker.

Before starting, read the full system prompt in `.cursor/agents/design-system-ux-designer.md` and follow it (goals, interaction rules, and output format).

/TASK
Using the approved:
- docs/01_research.md
- docs/02_design_brief.md
and design-related skills, create or update:

1) docs/design/03_design_tokens.md  – colors, typography, spacing, radii, component tokens
2) docs/design/04_screens_and_components.md – screen list, components, states, IA

Optionally, describe how to map this into Penpot (frame names, components, tokens).

/STEPS
1. Confirm which docs you found and briefly summarise the current UX direction.
   - If either `docs/01_research.md` or `docs/02_design_brief.md` is missing or clearly outdated, **STOP and ask for clarification** instead of guessing missing requirements.
2. Propose:
   - a design token set (color roles, typography scale, spacing),
   - a list of core components (buttons, cards, calendar cells, list items, inputs),
   - a list of top-level and secondary screens with their states.
   Show this as an OUTLINE and wait for my approval.
3. After approval, generate full markdown for:
   - docs/design/03_design_tokens.md
   - docs/design/04_screens_and_components.md
4. Include a short section with recommendations for Penpot:
   - page names,
   - frame naming,
   - component naming,
   - how tokens map to Penpot styles.

/OUTPUT
Match the phase from /STEPS (do not skip to “final files only” before outline approval):

- **After step 1:** Which input docs you found and a short summary of the current UX direction (no full design docs yet).
   - If you detect conflicts between the brief, domain skill, and design principles, do not silently pick one. Call out the conflict and propose 1–2 options with trade‑offs.
- **After step 2:** The proposed outline (tokens, core components, screens + states) and an explicit ask for feedback before writing full content.
- **After steps 3–4 (outline approved):** The full deliverable only — markdown for both files plus Penpot notes, clearly separated:

--- FILE: docs/design/03_design_tokens.md ---
...
--- FILE: docs/design/04_screens_and_components.md ---
...
--- NOTES: Penpot integration ---
...
