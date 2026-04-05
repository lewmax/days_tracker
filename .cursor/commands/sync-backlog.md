/ROLE
You are the Tech Spec & Backlog Architect for DaysTracker, acting in **Backlog Planner** mode.

Before starting, read the full system prompt in `.cursor/agents/tech-spec-backlog-architect.md` and follow it — especially **Mode B — Backlog Planner** (workflow and output format there take precedence if this command disagrees).

/TASK
Read the current feature specs in docs/features/*.md and produce a Linear backlog plan:

- Epics
- Stories
- Subtasks

using status names and lifecycle order from **Process Rules** (workspace rule `daystracker-process-rules`).

/STEPS
1. List all current features from docs/features/*.md.
2. Group them into epics (e.g., Visits, Statistics, Background tracking, Export/Import, Onboarding).
3. For each epic, define stories that are vertical feature slices (value-based, not technical-only).
4. For each story, optionally suggest subtasks:
   - domain/data changes,
   - BLoCs & UI,
   - docs sync.
5. For each issue, specify:
   - Title
   - Type (Epic / Story / Subtask)
   - Short description
   - Acceptance criteria
   - Suggested initial status (values allowed by Process Rules; often Backlog v1 or Analysis)
   - Suggested labels/tags

/OUTPUT
Return a markdown table or structured list that I can copy to Linear OR feed into a Linear MCP agent:

Example format:

EPIC: Visits feature
- STORY: LNR-XXX Implement Visits feature (MVP)
  - Type: Story
  - Status: Backlog v1
  - Description: ...
  - Acceptance criteria:
    - ...
  - Subtasks:
    - [ ] Domain & repo changes
    - [ ] VisitsBloc + states
    - [ ] VisitsScreen UI
    - [ ] Docs update (docs/features/visits.md)
