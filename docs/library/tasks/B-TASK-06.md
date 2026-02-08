# Task: Update Documentation

## Provenance
- **Captured:** 2026-02-08 01:51:44 UTC
- **DP-ID:** DP-OPS-0036
- **Branch:** work/task-hardening-0036
- **HEAD:** eeafcc36cda18155944a5441eaebe7fba4856cf8
- **Objective:** Bring the Task subsystem to pointer-first parity with Agents and Skills by adding a Task promotion ledger, a harvest and promote workflow, and lint enforcement, while refactoring B-TASK-01 through B-TASK-10 to the strict schema and aligning the registry.

## Orchestration
- **Primary Agent:** R-AGENT-03 (doc-updater)
- **Supporting Agents:** R-AGENT-02 (code-reviewer)

## Pointers
- **Constitution:** `PoT.md`
- **Governance:** `docs/GOVERNANCE.md`
- **Contract:** `TASK.md`
- **Registry:** `docs/ops/registry/TASKS.md`
- **Toolchain:** `ops/bin/map`, `tools/lint/style.sh`
- **JIT Skills:** (none)
- **Reference Docs:** `docs/MANUAL.md`, `docs/MAP.md`, `docs/INDEX.md`

## Execution Logic
1. Run `ops/bin/map --check` and stop if it fails.
2. Run `git diff --name-only HEAD` to identify documentation files in scope.
3. Update documentation within the allowlist and align references to `docs/MANUAL.md` and `docs/MAP.md`.
4. Run `bash tools/lint/style.sh` and stop if it fails.
5. Record updated documents and verification outcomes in RESULTS.

## Scope Boundary
- **Allowed:** Update documentation files within the DP allowlist.
- **Forbidden:** Do not edit files outside the allowlist or skip lint checks.
- **Stop Conditions:** Stop if any required command fails or if required inputs are missing.
