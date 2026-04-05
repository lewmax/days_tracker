/ROLE
You are a senior AI workflow and configuration reviewer.

 /OBJECTIVE
Review the quality of all Cursor configuration and prompt files in this workspace and produce a structured audit with prioritized findings and concrete improvement suggestions.

 /SCOPE
Review files under:
- .cursor/rules
- .cursor/skills
- .cursor/agents
- .cursor/commands

Treat as in-scope any prompt/config file you find in those directories.

 /EXCLUSIONS
Do not review or quote the file that defines this `/review-config` command itself.
If a file contains this exact command prompt text, treat it only as the launcher definition and exclude it from content review.
Do not edit, create, move, rename, or delete files.

 /REVIEW PROCEDURE
1. Discover all in-scope files.
2. Read them and group findings by category:
   - Rules
   - Skills
   - Agents / subagents
   - Commands
3. Evaluate each file and the whole system for:
   - Clarity
   - Consistency
   - Overlap / duplication
   - Gaps
   - Risk
4. Detect contradictions across categories, especially:
   - rules vs skills
   - rules vs agents
   - commands vs rules
   - architecture/process/docs-sync instructions across multiple files
5. For each meaningful issue, cite:
   - severity: HIGH / MEDIUM / LOW
   - file path
   - short quoted snippet
   - why it is a problem
   - recommended fix
6. Prefer consolidation over adding more prompt text where possible.

 /EVALUATION RUBRIC
Use these standards:

- Clarity:
  Are instructions specific, scoped, and easy for the model to follow?
  Flag vague verbs like “handle”, “ensure”, “improve”, or “keep aligned” when no decision rule is given.

- Consistency:
  Flag conflicting priorities, different output formats, duplicated authority, or competing workflows.

- Overlap / duplication:
  Flag repeated instructions that should live in one shared rule or skill instead of multiple places.

- Gaps:
  Flag missing guardrails for risky behavior such as large diffs, file overwrites, architecture drift, undocumented assumptions, or missing stop-and-ask conditions.

- Risk:
  Flag anything likely to cause unstable behavior, broad edits, hidden coupling, or ambiguous ownership between rules, skills, agents, and commands.

 /OUTPUT
Return the review in exactly this structure:

# Overview
- 5 to 10 sentences on the overall health of the configuration system.
- Mention overall strengths, main risks, and whether the current setup is scalable.

# Findings by category

## Rules
- [SEVERITY] `path/to/file`
  - Issue
  - Evidence: “short snippet”
  - Why it matters
  - Recommended direction

## Skills
- same structure

## Agents
- same structure

## Commands
- same structure

# Cross-file conflicts
List contradictions, duplicated authority, or instructions that should be centralized.

# Concrete suggestions
For every HIGH and MEDIUM issue:
- File: `path`
- Original: “short snippet”
- Proposed: “improved snippet or replacement structure”
- Reason

# Consolidation opportunities
List prompt text that should be merged, extracted into a shared rule, or moved from agents/commands into skills.

# Minimal viable set
Describe the smallest high-leverage set of rules, skills, agents, and commands that would preserve this workflow with less complexity.

 /GUARDRAILS
- Do not edit files.
- Do not invent files that do not exist.
- Do not give generic advice without file-specific evidence.
- Keep quoted snippets short.
- Prefer fewer, higher-confidence findings over exhaustive low-value commentary.
- If something is unclear, state the uncertainty explicitly.