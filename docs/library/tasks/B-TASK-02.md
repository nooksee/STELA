# Task: Verification Command

## Provenance
- **Captured:** 2026-02-08 01:51:44 UTC
- **DP-ID:** DP-OPS-0036
- **Branch:** work/task-hardening-0036
- **HEAD:** eeafcc36cda18155944a5441eaebe7fba4856cf8
- **Objective:** Bring the Task subsystem to pointer-first parity with Agents and Skills by adding a Task promotion ledger, a harvest and promote workflow, and lint enforcement, while refactoring B-TASK-01 through B-TASK-10 to the strict schema and aligning the registry.

## Orchestration
- **Primary Agent:** R-AGENT-02 (code-reviewer)
- **Supporting Agents:** (none)

## Pointers
- **Constitution:** `PoT.md`
- **Governance:** `docs/GOVERNANCE.md`
- **Contract:** `TASK.md`
- **Registry:** `docs/ops/registry/TASKS.md`
- **Toolchain:** `tools/verify.sh`, `tools/lint/context.sh`, `tools/lint/truth.sh`, `tools/lint/library.sh`, `tools/lint/dp.sh`
- **JIT Skills:** `docs/library/skills/S-LEARN-01.md`
- **Reference Docs:** `docs/MANUAL.md`

## Execution Logic
1. Run `bash tools/verify.sh` and stop if it fails.
2. Run `bash tools/lint/context.sh` and stop if it fails.
3. If canon or governance surfaces changed, run `bash tools/lint/truth.sh` and stop if it fails.
4. Run `bash tools/lint/library.sh` and stop if it fails.
5. If the DP format is in scope, run `bash tools/lint/dp.sh --test` and stop if it fails.
6. Record pass or fail outcomes in RESULTS.

## Scope Boundary
- **Allowed:** Run only the verification commands listed in this task and report results.
- **Forbidden:** Do not modify files or bypass failing gates.
- **Stop Conditions:** Stop if any required command fails or if required inputs are missing.
