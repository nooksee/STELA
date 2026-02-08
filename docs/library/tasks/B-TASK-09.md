# Task: Refresh + Conform DP

## Provenance
- **Captured:** 2026-02-08 01:51:44 UTC
- **DP-ID:** DP-OPS-0036
- **Branch:** work/task-hardening-0036
- **HEAD:** eeafcc36cda18155944a5441eaebe7fba4856cf8
- **Objective:** Bring the Task subsystem to pointer-first parity with Agents and Skills by adding a Task promotion ledger, a harvest and promote workflow, and lint enforcement, while refactoring B-TASK-01 through B-TASK-10 to the strict schema and aligning the registry.

## Orchestration
- **Primary Agent:** R-AGENT-04 (integrator)
- **Supporting Agents:** (none)

## Pointers
- **Constitution:** `PoT.md`
- **Governance:** `docs/GOVERNANCE.md`
- **Contract:** `TASK.md`
- **Registry:** `docs/ops/registry/TASKS.md`
- **Toolchain:** `ops/bin/open`, `ops/bin/dump`
- **JIT Skills:** (none)
- **Reference Docs:** `docs/MANUAL.md`

## Execution Logic
1. Require OPEN, dump, and the legacy DP artifact and stop if any are missing.
2. Use `TASK.md` as the template and conform the DP to the current heading order.
3. Output only the conformed DP content and nothing else.

## Scope Boundary
- **Allowed:** Conform an existing DP using provided artifacts and canon surfaces.
- **Forbidden:** Do not edit files, run commands, or alter DP intent.
- **Stop Conditions:** Stop if required artifacts or inputs are missing.
