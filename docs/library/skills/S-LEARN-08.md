# S-LEARN-08: Prune SoP and Regenerate Context Bundles

## Provenance
- **Captured:** 2026-02-04 16:36:53 UTC
- **DP-ID:** Not provided
- **Branch:** work/phase-two-doctrine-2026-02-04
- **HEAD:** 0a98ad2182b5a02708b367bf42673583faf45b45
- **Objective:** Not provided
- **Friction Context:**
  - Hot Zone: None
  - High Churn: None
- **Diff Stat:**
```text
(no changes)
```

## Scope
Production payload work only. Not platform maintenance.

## Invocation guidance
Use this skill when a DP changes canon or context bundles and requires updated SoP pruning and llms bundle refresh. Apply the solution: run ops/bin/prune, run ops/bin/llms, verify llms with tools/lint/llms.sh, run tools/lint/style.sh, and record results in RESULTS.

## Drift preventers
- Stop if the DP scope is platform maintenance or if the DP does not explicitly request this skill.
- Anti-hallucination: use repository files as SSOT and stop if required inputs are missing.
- Negative check: do not add Skills to ops/lib/manifests/CONTEXT.md.

## Procedure
1) Review the context and desired outcome.
2) Apply the solution steps captured in this skill.
3) Verify results and record required evidence in RESULTS.
