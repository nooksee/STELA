# Task: Factory Chain Validation

## Provenance
- **Captured:** 2026-02-19 01:53:08 UTC
- **DP-ID:** DP-OPS-0074
- **Branch:** work/dp-ops-0074-2026-02-18
- **HEAD:** 45af651efaa13ad13c457c708b399b07497a3819
- **Objective:** Validate pointer-first factory candidate and promotion chain workflows.

## Orchestration
- **Primary Agent:** R-AGENT-07 (factory-chain-agent-test)
- **Supporting Agents:** R-AGENT-04 (integrator)

## Objective Contract
- `task_id`: `B-TASK-07`
- `objective`: `Factory Chain Validation`
- `inputs`: `active DP scope, assigned agent set, and required tools`
- `outputs`: `bounded change set, receipt evidence, and closeout-ready status`
- `invariants`: `stop on failing gates, no out-of-scope edits, closeout follows TASK Section 3.5`

## Pointers
- **Constitution:** `PoT.md`
- **Governance:** `docs/GOVERNANCE.md`
- **Contract:** `TASK.md`
- **Registry:** `docs/ops/registry/tasks.md`
- **Toolchain:** `bash tools/lint/factory.sh`, `bash tools/verify.sh`, `bash tools/lint/style.sh`
- **JIT Skills:** `opt/_factory/skills/s-learn-07.md`
- **Reference Docs:** `docs/MANUAL.md`, `docs/ops/registry/factory.md`

## Execution Logic
1. Run `bash tools/lint/factory.sh` and stop if it fails.
2. Run `bash tools/verify.sh` and stop if it fails.
3. If factory docs/specs changed, run `bash tools/lint/style.sh` and stop if it fails.
4. Record pass or fail evidence for each command in RESULTS.
5. Complete Closeout per `TASK.md` Section 3.5.

## Scope Boundary
- **Allowed:** Validate and report factory chain integrity within active DP scope and perform Closeout duties per `TASK.md` Section 3.5.
- **Forbidden:** Do not modify out-of-scope files or bypass failing verification gates.
- **Stop Conditions:** Stop on missing required inputs, lint failures, or scope expansion.
