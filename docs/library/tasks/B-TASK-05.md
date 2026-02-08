# Task: Refactor Clean

## Provenance
- **Captured:** 2026-02-08 01:51:44 UTC
- **DP-ID:** DP-OPS-0036
- **Branch:** work/task-hardening-0036
- **HEAD:** eeafcc36cda18155944a5441eaebe7fba4856cf8
- **Objective:** Bring the Task subsystem to pointer-first parity with Agents and Skills by adding a Task promotion ledger, a harvest and promote workflow, and lint enforcement, while refactoring B-TASK-01 through B-TASK-10 to the strict schema and aligning the registry.

## Orchestration
- **Primary Agent:** R-AGENT-05 (refactor-cleaner)
- **Supporting Agents:** R-AGENT-02 (code-reviewer)

## Pointers
- **Constitution:** `PoT.md`
- **Governance:** `docs/GOVERNANCE.md`
- **Contract:** `TASK.md`
- **Registry:** `docs/ops/registry/TASKS.md`
- **Toolchain:** `tools/verify.sh`, `tools/lint/style.sh`
- **JIT Skills:** `docs/library/skills/S-LEARN-06.md`
- **Reference Docs:** `docs/MANUAL.md`

## Execution Logic
1. Run `git status --porcelain` and stop if the working tree is not clean.
2. Run `git diff --name-only HEAD` to identify candidate files within scope.
3. For each candidate removal, run `git grep -n` against the symbol or path to confirm no remaining references.
4. Run `bash tools/verify.sh` and `bash tools/lint/style.sh` before deletions and stop if either fails.
5. Apply the deletion, then rerun `bash tools/verify.sh` and `bash tools/lint/style.sh` and stop if either fails.
6. Record the removed items and verification outcomes in RESULTS.

## Scope Boundary
- **Allowed:** Remove dead code within the DP allowlist after verification gates pass.
- **Forbidden:** Do not delete files outside the allowlist or skip verification gates.
- **Stop Conditions:** Stop if any verification command fails or if required inputs are missing.
