/ROLE
You are a senior AI workflow & configuration reviewer.

I want you to REVIEW the quality of all my Cursor prompts and configs
(Rules, Skills, Subagents, Commands) in this workspace.

/SCOPE
Consider every prompt/config file under:
- .cursor/rules
- .cursor/skills
- .cursor/agents
- .cursor/commands

EXCEPT:
- the file that contains THIS command definition (the “/review-config” command itself).
If you see this exact prompt text in a file, ignore that file from content review
and only treat it as the launcher.

/TASK
1) Discover & read all relevant prompt/config files:
   - Rules (architecture, documentation, process, etc.)
   - Skills (domain, design); Flutter stack/presentation in Architecture & Code Rules
   - Subagents / agents (all roles under `.cursor/agents/`)
   - Commands (other /commands we created)

2) For each category, evaluate:
   - Clarity: are instructions unambiguous and easy for the model to follow?
   - Consistency: any contradictions between files (e.g., rules vs skills vs subagents)?
   - Overlap / duplication: places where multiple prompts say the same thing.
   - Gaps: missing instructions that are important for a stable workflow.
   - Risk: anything likely to cause bad behavior (huge diffs, overwrites, confusion).

3) Propose improvements:
   - Concrete text edits (shorter, clearer, or better-scoped instructions).
   - Suggestions to merge/simplify rules or skills.
   - Renames or re-scoping of subagents/commands where helpful.
   - Notes on which parts should move into shared Skills vs per-agent prompts.

4) Prioritise findings:
   - HIGH: can break architecture, docs sync, or process; or likely to create unsafe edits.
   - MEDIUM: likely to confuse agents, cause duplicated work, or drift between docs and code.
   - LOW: style, naming, or minor consistency tweaks.

/OUTPUT
Return a structured review:

1. Overview
   - 5–10 sentences on overall health of the config.

2. Findings by category
   - Rules
   - Skills
   - Subagents
   - Commands
   For each, list issues with severity (HIGH/MEDIUM/LOW) and file references.

3. Concrete suggestions
   - For each HIGH/MEDIUM issue:
     - show the original snippet (short),
     - propose an improved version or alternative structure.

4. Minimal viable set (optional)
   - If helpful, describe what a “minimal but powerful” subset of rules/skills/agents/commands
     would look like for this workflow.

Do NOT edit or delete any files yourself. Only analyse and propose changes.
