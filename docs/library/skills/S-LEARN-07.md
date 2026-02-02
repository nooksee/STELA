# S-LEARN-07: Harvest and Promote Skills

## Provenance
- Captured: 2026-02-01
- Origin: System Hardening (DP-OPS-0015)
- Source: Operator Institutional Knowledge
- Friction Context:
  - Hot Zone: Task Closeout
  - High Churn: Knowledge Loss

## Scope
Production payload work only. Not platform maintenance.

## Invocation guidance
Use this skill during DP closeout to capture reusable workflows. The Trap: "I will write the skill manually." (Missing forensic provenance). Solution: Always use the harvest tool to generate the draft.

## Drift preventers
- Stop if the Skills Context Hazard check fails (ops/lib/manifests/CONTEXT.md must not contain skills).
- Stop if the draft contains TODO or placeholders.

## Procedure
1) Harvest (Draft Generation):
   - Run `ops/lib/skill/skill_lib.sh harvest`.
   - Input: Provide concrete Context (When to use) and Solution (What to do).
   - Constraint: Do not edit the `## Provenance` block.
2) Refine (Quality Gate):
   - Review the generated draft in `storage/handoff/`.
   - Trap: Leaving "ENTER_SOLUTION" placeholders.
   - Solution: Run `grep -E "TODO|ENTER_|REPLACE_" <draft_path>`. If hits found, Fix before promoting.
3) Promote (Registry):
   - Run `ops/lib/skill/skill_lib.sh promote <draft_path>`.
   - Verify `docs/library/INDEX.md` contains the new entry.
4) Proof:
   - Include the harvest/promote command outputs in the DP RESULTS file.
