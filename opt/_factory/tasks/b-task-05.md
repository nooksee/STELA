# Task: Refactor Clean

## Provenance
- **Captured:** 2026-02-10 01:27:17 UTC
- **DP-ID:** DP-OPS-0039
- **Branch:** work/task-serviceability-0038
- **HEAD:** 03f47297e
- **Objective:** Certify the B-TASK definitions for serviceable execution by enforcing explicit Closeout pointers, strengthening quantitative reporting expectations, and hardening task lint to prevent drift.

## Orchestration
- **Primary Agent:** R-AGENT-05 (refactor-cleaner)
- **Supporting Agents:** R-AGENT-02 (code-reviewer)

## Objective Contract
- `task_id`: `B-TASK-05`
- `objective`: `Refactor Clean`
- `inputs`: `active DP scope, assigned agent set, and required tools`
- `outputs`: `bounded change set, receipt evidence, and closeout-ready status`
- `invariants`: `stop on failing gates, no out-of-scope edits, closeout follows TASK Section 3.5`

## Pointers
- **Constitution:** `PoT.md`
- **Governance:** `docs/GOVERNANCE.md`
- **Contract:** `TASK.md`
- **Registry:** `docs/ops/registry/tasks.md`
- **Toolchain:** `ops/bin/open`, `tools/verify.sh`, `tools/lint/style.sh`
- **JIT Skills:** ``
- **Reference Docs:** `docs/MANUAL.md`

## Execution Logic
1. Run `ops/bin/open --intent="Refactor clean" --out=auto` to satisfy freshness gating, capture the OPEN artifact, and stop if the command fails or the artifact is missing.
2. Run `git status --porcelain` and stop if the working tree is not clean.
3. Run `git diff --name-only HEAD` to identify candidate files within scope.
4. For each candidate removal, run `git grep -n` against the symbol or path to confirm no remaining references.
5. Run `bash tools/verify.sh` and `bash tools/lint/style.sh` before deletions, stop if either fails, and capture the pass or fail summary for each command in RESULTS.
6. Apply the deletion, then rerun `bash tools/verify.sh` and `bash tools/lint/style.sh`, stop if either fails, and capture the pass or fail summary for each command in RESULTS.
7. Record the removed items and verification outcomes in RESULTS.
8. Complete Closeout per `TASK.md` Section 3.5.

## Scope Boundary
- **Allowed:** Remove dead code within the DP allowlist after verification gates pass and perform Closeout duties per `TASK.md` Section 3.5.
- **Forbidden:** Do not delete files outside the allowlist or skip verification gates.
- **Stop Conditions:** Stop if any verification command fails or if required inputs are missing.
