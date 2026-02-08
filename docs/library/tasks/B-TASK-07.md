# Task: Refresh + Discuss

## Provenance
- **Captured:** 2026-02-08 01:51:44 UTC
- **DP-ID:** DP-OPS-0036
- **Branch:** work/task-hardening-0036
- **HEAD:** eeafcc36cda18155944a5441eaebe7fba4856cf8
- **Objective:** Bring the Task subsystem to pointer-first parity with Agents and Skills by adding a Task promotion ledger, a harvest and promote workflow, and lint enforcement, while refactoring B-TASK-01 through B-TASK-10 to the strict schema and aligning the registry.

## Orchestration
- **Primary Agent:** R-AGENT-01 (architect)
- **Supporting Agents:** (none)

## Pointers
- **Constitution:** `PoT.md`
- **Governance:** `docs/GOVERNANCE.md`
- **Contract:** `TASK.md`
- **Registry:** `docs/ops/registry/TASKS.md`
- **Toolchain:** `ops/bin/open`, `ops/bin/dump`
- **JIT Skills:** (none)
- **Reference Docs:** `docs/MAP.md`

## Execution Logic
1. Require OPEN and dump artifacts for the active branch and stop if they are missing.
2. Read the attached artifacts and summarize the current state.
3. Discuss the requested topic without editing files or running commands.

## Scope Boundary
- **Allowed:** Discussion only based on provided artifacts and canon surfaces.
- **Forbidden:** Do not edit files, run commands, or draft new DPs.
- **Stop Conditions:** Stop if required artifacts are missing or if the request requires edits.
