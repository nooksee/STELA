# Task: Plan Command

## Provenance
- **Captured:** 2026-02-10 01:27:17 UTC
- **DP-ID:** DP-OPS-0039
- **Branch:** work/task-serviceability-0038
- **HEAD:** 03f47297e
- **Objective:** Certify the B-TASK definitions for serviceable execution by enforcing explicit Closeout pointers, strengthening quantitative reporting expectations, and hardening task lint to prevent drift.

## Orchestration
- **Primary Agent:** R-AGENT-04 (integrator)
- **Supporting Agents:** R-AGENT-01 (architect)

## Objective Contract
- `task_id`: `B-TASK-04`
- `objective`: `Plan Command`
- `inputs`: `active DP scope, assigned agent set, and required tools`
- `outputs`: `bounded change set, receipt evidence, and closeout-ready status`
- `invariants`: `stop on failing gates, no out-of-scope edits, closeout follows TASK Section 3.5`

## Pointers
- **Constitution:** `PoT.md`
- **Governance:** `docs/GOVERNANCE.md`
- **Contract:** `TASK.md`
- **Registry:** `docs/ops/registry/tasks.md`
- **Toolchain:** `ops/bin/map`, `ops/bin/llms`
- **JIT Skills:** `opt/_factory/skills/s-learn-02.md`
- **Reference Docs:** `docs/MANUAL.md`, `docs/MAP.md`

## Execution Logic
1. Run `ops/bin/map --check` and stop if it fails.
2. If the DP requires refreshed context bundles, run `ops/bin/llms` and stop if it fails.
3. Use `opt/_factory/agents/r-agent-04.md` to draft the implementation plan and capture phases, risks, and dependencies.
4. If architecture changes are required, use `opt/_factory/agents/r-agent-01.md` to review and adjust the plan.
5. Present the plan and wait for explicit approval before execution.
6. Complete Closeout per `TASK.md` Section 3.5.

## Scope Boundary
- **Allowed:** Produce a plan, gather approvals for the active DP, and perform Closeout duties per `TASK.md` Section 3.5.
- **Forbidden:** Do not begin implementation before approval.
- **Stop Conditions:** Stop if required inputs are missing or if approval is not granted.
