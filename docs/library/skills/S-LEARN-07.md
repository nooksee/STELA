# S-LEARN-07: Harvest and Promote Skills at DP Closeout

## Provenance
- Captured: 2026-02-01 16:25:52 UTC
- Branch: work/dp-ops-0011-skill-harvesting-2026-02-01
- Base ref: main...HEAD
- Active DP: Not provided
- Objective: Not provided
- Diff stat:
```text
(no changes)
```
- Diff files:
```text
(no changes)
```

## Scope
Production payload work only. Not platform maintenance.

## Invocation guidance
Use this skill when a DP requires skill capture and a reusable workflow must be captured during closeout. Apply the solution: run `ops/lib/skill/skill_lib.sh harvest` to create a draft with auto-generated provenance and semantic collision checks, review and refine the draft (do not edit Provenance), promote it into docs/library/skills, update docs/library/INDEX.md, and record proof in RESULTS.

## Drift preventers
- Stop if the DP scope is platform maintenance or if the DP does not explicitly request this skill.
- Stop if the Skills Context Hazard check fails.
- Stop if semantic collision warnings are unresolved. Use `--force` only with an explicit rationale recorded in RESULTS.
- Do not promote a draft that contains placeholder markers or missing required sections.
- Anti-hallucination: use repository files as SSOT and stop if required inputs are missing.
- Negative check: do not add Skills to ops/lib/manifests/CONTEXT.md.

## Procedure
1) Run `ops/lib/skill/skill_lib.sh check` and stop on failure.
2) Run `ops/lib/skill/skill_lib.sh harvest` with name, context, and solution values as needed to create a draft and record the draft path.
3) If semantic collision warnings appear, either revise the title or rerun with `--force` and record the rationale in RESULTS.
4) Review the draft in `storage/handoff/`. Verify Provenance (DP-ID, Branch, HEAD, Objective) and Friction Context (Hot Zone, High Churn). Do not edit the Provenance block.
5) Refine Invocation guidance, Drift preventers, Procedure, and Solution text so they are complete and accurate.
6) If promotion is warranted, run `ops/lib/skill/skill_lib.sh promote` with the draft path from harvest and confirm the new skill file and registry entry exist.
7) If promotion is not warranted, log "no new skill promoted" with a rationale in RESULTS.
8) Record RESULTS proof: command invocations, draft path, `grep` evidence for SKILL.md and docs/library/INDEX.md when promotion occurs, plus diff outputs.
