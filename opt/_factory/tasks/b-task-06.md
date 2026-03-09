# Task: Update Documentation

## Provenance
- **Captured:** 2026-02-10 01:27:17 UTC
- **DP-ID:** DP-OPS-0039
- **Branch:** work/task-serviceability-0038
- **HEAD:** 03f47297e
- **Objective:** Certify the B-TASK definitions for serviceable execution by enforcing explicit Closeout pointers, strengthening quantitative reporting expectations, and hardening task lint to prevent drift.

## Orchestration
- **Primary Agent:** R-AGENT-03 (doc-updater)
- **Supporting Agents:** R-AGENT-02 (code-reviewer)

## Objective Contract
- `task_id`: `B-TASK-06`
- `objective`: `Update Documentation`
- `inputs`: `active DP scope, assigned agent set, and required tools`
- `outputs`: `bounded change set, receipt evidence, and closeout-ready status`
- `invariants`: `stop on failing gates, no out-of-scope edits, closeout follows TASK Section 3.5`

## Pointers
- **Constitution:** `PoT.md`
- **Governance:** `docs/GOVERNANCE.md`
- **Contract:** `TASK.md`
- **Registry:** `docs/ops/registry/tasks.md`
- **Toolchain:** `ops/bin/map`, `tools/lint/style.sh`
- **JIT Skills:** (none)
- **Reference Docs:** `docs/MANUAL.md`, `docs/MAP.md`, `docs/INDEX.md`

## Execution Logic
1. Run `ops/bin/map --check` and stop if it fails.
2. Run `git diff --name-only HEAD` to identify documentation files in scope.
3. Update documentation within the allowlist and align references to `docs/MANUAL.md` and `docs/MAP.md`.
4. Run `bash tools/lint/style.sh` and stop if it fails.
5. Record updated documents and verification outcomes in RESULTS.
6. Complete Closeout per `TASK.md` Section 3.5.

## Scope Boundary
- **Allowed:** Update documentation files within the DP allowlist and perform Closeout duties per `TASK.md` Section 3.5.
- **Forbidden:** Do not edit files outside the allowlist or skip lint checks.
- **Stop Conditions:** Stop if any required command fails or if required inputs are missing.
