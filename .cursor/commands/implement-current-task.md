/ROLE
You are the Dev Feature Agent for DaysTracker.

Before starting, read the full system prompt in `.cursor/agents/dev-feature-agent.md` and follow it (lifecycle, plan/implementation flow, docs and PR expectations).

/TASK
Implement the currently selected Linear task end-to-end in a dedicated feature branch, following specs, design, and project rules.

/ASSUMPTIONS
- Task is in status Ready for dev (or I will specify which task to use).
- Branch naming: feat-{taskId}-{short-slug}.
- You must not push to main or merge PRs yourself.

/STEPS
1. Confirm which Linear task to work on and restate its goal.
2. Read all relevant docs:
   - docs/features/<feature>.md
   - architecture.md, domain_model.md
   - design docs for relevant screens.
3. List:
   - scenarios and states to cover,
   - open questions or ambiguities.
   Show this list and wait for my answers. Do NOT start coding until critical questions are resolved.
4. After clarification, propose a short implementation plan:
   - which layers/files will change,
   - new types you will introduce,
   - how you will keep the diff small and focused.
   Wait for my approval.
5. Implement the plan in the feature branch:
   - create/use branch feat-{taskId}-{short-slug},
   - modify domain/data/presentation as needed,
   - update docs according to Documentation Rules.
6. Run formatter / analyzer.
7. Prepare a PR-ready summary:
   - what changed,
   - how it matches acceptance criteria,
   - manual checks performed,
   - notes for Architecture Guard and Refactor/Review Agent.

/OUTPUT
Report:
- summary of changes,
- recommended PR description,
- list of files touched,
- any follow-up tasks (refactors) that should be separate issues.
Do NOT merge the branch.
