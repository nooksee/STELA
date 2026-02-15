# Task: Verification Command

## Provenance
- **Captured:** 2026-02-10 01:27:17 UTC
- **DP-ID:** DP-OPS-0039
- **Branch:** work/task-serviceability-0038
- **HEAD:** 03f47297e
- **Objective:** Certify the B-TASK definitions for serviceable execution by enforcing explicit Closeout pointers, strengthening quantitative reporting expectations, and hardening task lint to prevent drift.

## Orchestration
- **Primary Agent:** R-AGENT-02 (code-reviewer)
- **Supporting Agents:** (none)

## Pointers
- **Constitution:** `PoT.md`
- **Governance:** `docs/GOVERNANCE.md`
- **Contract:** `TASK.md`
- **Registry:** `docs/ops/registry/TASKS.md`
- **Toolchain:** `tools/verify.sh`, `tools/lint/context.sh`, `tools/lint/truth.sh`, `tools/lint/.sh`, `tools/lint/dp.sh`
- **JIT Skills:** `opt/_factory/skills/S-LEARN-01.md`
- **Reference Docs:** `docs/MANUAL.md`

## Execution Logic
1. Run `bash tools/verify.sh` and stop if it fails.
2. Run `bash tools/lint/context.sh` and stop if it fails.
3. If canon or governance surfaces changed, run `bash tools/lint/truth.sh` and stop if it fails.
4. Run `bash tools/lint/.sh` and stop if it fails.
5. If the DP format is in scope, run `bash tools/lint/dp.sh --test` and stop if it fails.
6. Record pass or fail outcomes in RESULTS.
7. Complete Closeout per `TASK.md` Section 3.5.

## Scope Boundary
- **Allowed:** Run only the verification commands listed in this task, report results, and perform Closeout duties per `TASK.md` Section 3.5.
- **Forbidden:** Do not modify files or bypass failing gates.
- **Stop Conditions:** Stop if any required command fails or if required inputs are missing.
