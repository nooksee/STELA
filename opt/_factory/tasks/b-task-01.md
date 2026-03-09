# Task: Code Review

## Provenance
- **Captured:** 2026-02-10 01:27:17 UTC
- **DP-ID:** DP-OPS-0039
- **Branch:** work/task-serviceability-0038
- **HEAD:** 03f47297e
- **Objective:** Certify the B-TASK definitions for serviceable execution by enforcing explicit Closeout pointers, strengthening quantitative reporting expectations, and hardening task lint to prevent drift.

## Orchestration
- **Primary Agent:** R-AGENT-02 (code-reviewer)
- **Supporting Agents:** R-AGENT-06 (security-reviewer)

## Objective Contract
- `task_id`: `B-TASK-01`
- `objective`: `Code Review`
- `inputs`: `active DP scope, assigned agent set, and required tools`
- `outputs`: `bounded change set, receipt evidence, and closeout-ready status`
- `invariants`: `stop on failing gates, no out-of-scope edits, closeout follows TASK Section 3.5`

## Pointers
- **Constitution:** `PoT.md`
- **Governance:** `docs/GOVERNANCE.md`
- **Contract:** `TASK.md`
- **Registry:** `docs/ops/registry/tasks.md`
- **Toolchain:** `tools/lint/style.sh`, `tools/lint/truth.sh`, `tools/verify.sh`
- **JIT Skills:** `opt/_factory/skills/s-learn-04.md`, `opt/_factory/skills/s-learn-05.md`, `opt/_factory/skills/s-learn-06.md`
- **Reference Docs:** `docs/MANUAL.md`

## Execution Logic
1. Run `git diff --name-only HEAD` to enumerate changed files.
2. Run `git diff HEAD` and review the diff using `opt/_factory/skills/s-learn-04.md` and `opt/_factory/skills/s-learn-05.md`.
3. If the change touches hot zones or high churn areas, apply `opt/_factory/skills/s-learn-06.md` for Hot Zone and churn detection forensics.
4. Run `bash tools/lint/style.sh`, stop if it fails, and capture the pass or fail summary in RESULTS.
5. If canon or governance surfaces changed, run `bash tools/lint/truth.sh` and stop if it fails.
6. Run `bash tools/verify.sh`, stop if it fails, and capture the pass or fail summary in RESULTS.
7. Record findings with severity, file, line, and remediation notes.
8. Complete Closeout per `TASK.md` Section 3.5.

## Scope Boundary
- **Allowed:** Review only the diff for the active DP, run the commands listed in this task, and perform Closeout duties per `TASK.md` Section 3.5.
- **Forbidden:** Do not edit files or expand scope beyond the active DP.
- **Stop Conditions:** Stop if any required command fails or if required inputs are missing.
