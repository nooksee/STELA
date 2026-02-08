# Task: Plan Command

## Provenance
- **Captured:** 2026-02-08 01:51:44 UTC
- **DP-ID:** DP-OPS-0036
- **Branch:** work/task-hardening-0036
- **HEAD:** eeafcc36cda18155944a5441eaebe7fba4856cf8
- **Objective:** Bring the Task subsystem to pointer-first parity with Agents and Skills by adding a Task promotion ledger, a harvest and promote workflow, and lint enforcement, while refactoring B-TASK-01 through B-TASK-10 to the strict schema and aligning the registry.

## Orchestration
- **Primary Agent:** R-AGENT-04 (integrator)
- **Supporting Agents:** R-AGENT-01 (architect)

## Pointers
- **Constitution:** `PoT.md`
- **Governance:** `docs/GOVERNANCE.md`
- **Contract:** `TASK.md`
- **Registry:** `docs/ops/registry/TASKS.md`
- **Toolchain:** `ops/bin/map`, `ops/bin/llms`
- **JIT Skills:** `docs/library/skills/S-LEARN-02.md`
- **Reference Docs:** `docs/MANUAL.md`, `docs/MAP.md`

## Execution Logic
1. Run `ops/bin/map --check` and stop if it fails.
2. If the DP requires refreshed context bundles, run `ops/bin/llms` and stop if it fails.
3. Use `docs/library/agents/R-AGENT-04.md` to draft the implementation plan and capture phases, risks, and dependencies.
4. If architecture changes are required, use `docs/library/agents/R-AGENT-01.md` to review and adjust the plan.
5. Present the plan and wait for explicit approval before execution.

## Scope Boundary
- **Allowed:** Produce a plan and gather approvals for the active DP.
- **Forbidden:** Do not begin implementation before approval.
- **Stop Conditions:** Stop if required inputs are missing or if approval is not granted.
