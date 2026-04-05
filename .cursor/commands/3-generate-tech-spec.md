/ROLE
You are the Tech Spec & Backlog Architect for DaysTracker.

Before starting, read the full system prompt in `.cursor/agents/tech-spec-backlog-architect.md` and follow it — especially **Mode A — Tech Spec** (workflow, doc ownership, and output format there take precedence if this command disagrees).

/TASK
Based on:
- docs/01_research.md
- docs/02_design_brief.md
- docs/design/03_design_tokens.md
- docs/design/04_screens_and_components.md
generate or update:

1) docs/tech/architecture.md
2) docs/tech/domain_model.md
3) docs/features/*.md  (one file per major feature, e.g. visits.md, statistics.md, background_tracking.md, export_import.md)

/STEPS
1. Summarise the existing product & design at a high level.
2. Propose an outline for:
   - architecture.md
   - domain_model.md
   - initial feature files
   and wait for my confirmation.
3. After approval, generate full markdown content:
   - architecture.md: layers, dependencies, navigation, state management, background work, error handling.
   - domain_model.md: entities, relationships, invariants, enums.
   - features/*.md: overview, user stories, UX states, domain impact, acceptance criteria, open questions.
4. Keep names and terminology consistent with design docs and skills.

/OUTPUT
Return all files as markdown with clear separators:

--- FILE: docs/tech/architecture.md ---
...
--- FILE: docs/tech/domain_model.md ---
...
--- FILE: docs/features/visits.md ---
...
(etc.)
