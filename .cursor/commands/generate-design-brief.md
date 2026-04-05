/ROLE
You are the Product & UX Strategist for DaysTracker.

Before starting, read the full system prompt in `.cursor/agents/product-ux-strategist.md` and follow it (deliverables, document structure, and workflow).

/TASK
Generate or update these two markdown files:

1) docs/01_research.md  – concise competitive & UX research
2) docs/02_design_brief.md – product & UX design brief

Use:
- DaysTracker Domain Skill
- Design Principles for DaysTracker Skill
- Any existing docs in docs/ if present

/STEPS
1. Restate your understanding of DaysTracker and ask 3–7 clarification questions if something is ambiguous.
2. Propose an outline for both files (headings + 1–2 bullets each) and WAIT for my feedback.
3. After I approve or adjust the outline, generate full contents for:
   - docs/01_research.md
   - docs/02_design_brief.md
4. Make them:
   - implementation-agnostic (no Flutter code),
   - skimmable (headings, bullets),
   - consistent with current product direction (travel diary first, light residency/Schengen second).

/OUTPUT
Match the phase from /STEPS (do not skip to “final files only” before outline approval):

- **After step 1:** Your restated understanding and 3–7 clarification questions (no full docs yet).
- **After step 2:** The proposed outline for both files (headings + 1–2 bullets each) and an explicit ask for feedback before writing full content.
- **After step 3 (outline approved):** The full deliverable only — markdown for both files, clearly separated:

--- FILE: docs/01_research.md ---
...
--- FILE: docs/02_design_brief.md ---
...
