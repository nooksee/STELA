# Task: Factory Testing Gates

## Provenance
- **Captured:** 2026-03-09 22:40:10 UTC
- **DP-ID:** DP-OPS-0181
- **Branch:** work/dp-ops-0181-factory-testing-gates-2026-03-09
- **HEAD:** b2ad3d17
- **Objective:** Add first-class factory testing definitions and execution gates.

## Orchestration
- **Primary Agent:** R-AGENT-09 (factory-testing-gatekeeper)
- **Supporting Agents:** R-AGENT-04 (integrator)

## Objective Contract
- `task_id`: `B-TASK-09`
- `objective`: `Factory Testing Gates`
- `inputs`: `active DP scope, assigned agent set, and required tools`
- `outputs`: `bounded change set, receipt evidence, and closeout-ready status`
- `invariants`: `stop on failing gates, no out-of-scope edits, closeout follows TASK Section 3.5`

## Pointers
- **Constitution:** `PoT.md`
- **Governance:** `docs/GOVERNANCE.md`
- **Contract:** `TASK.md`
- **Registry:** `docs/ops/registry/tasks.md`
- **Toolchain:** `bash tools/lint/factory.sh`, `bash tools/test/factory.sh`, `bash tools/test/bundle.sh`, `bash tools/verify.sh`, `bash tools/lint/style.sh`
- **JIT Skills:** `opt/_factory/skills/s-learn-09.md`
- **Reference Docs:** `docs/MANUAL.md`, `docs/ops/registry/factory.md`, `docs/ops/specs/tools/test/factory.md`

## Execution Logic
1. Run `bash tools/lint/factory.sh` and stop if it fails.
2. Run `bash tools/test/factory.sh` and stop if it fails.
3. Run `bash tools/test/bundle.sh` and stop if ATS assembly assertions fail.
4. Run `bash tools/verify.sh` and stop if any required test surface fails.
5. Record deterministic outcomes for all gates and complete Closeout per `TASK.md` Section 3.5.

## Scope Boundary
- **Allowed:** Execute factory testing-gate work within active DP scope and perform Closeout duties per `TASK.md` Section 3.5.
- **Forbidden:** Do not bypass failing ATS checks or expand into unrelated slices.
- **Stop Conditions:** Stop on missing required inputs, lint/test failures, or scope expansion.
