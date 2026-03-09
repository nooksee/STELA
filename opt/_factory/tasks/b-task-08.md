# Task: Bundle Orchestration

## Provenance
- **Captured:** 2026-03-03 05:57:42 UTC
- **DP-ID:** DP-OPS-0145
- **Branch:** work/dp-ops-0145-bundle-primitive-2026-03-03
- **HEAD:** 8c0a088bf0bafaa429950eb7dfad9f9ab27d348a
- **Objective:** Govern bundle artifact contract and profile routing expectations.

## Orchestration
- **Primary Agent:** R-AGENT-08 (bundle-coordinator)
- **Supporting Agents:** R-AGENT-01 (architect)

## Objective Contract
- `task_id`: `B-TASK-08`
- `objective`: `Bundle Orchestration`
- `inputs`: `active DP scope, assigned agent set, and required tools`
- `outputs`: `bounded change set, receipt evidence, and closeout-ready status`
- `invariants`: `stop on failing gates, no out-of-scope edits, closeout follows TASK Section 3.5`

## Pointers
- **Constitution:** `PoT.md`
- **Governance:** `docs/GOVERNANCE.md`
- **Contract:** `TASK.md`
- **Registry:** `docs/ops/registry/tasks.md`
- **Toolchain:** `bash tools/test/bundle.sh`, `bash tools/verify.sh`, `bash tools/lint/style.sh`
- **JIT Skills:** `opt/_factory/skills/s-learn-08.md`
- **Reference Docs:** `docs/MANUAL.md`, `docs/ops/specs/binaries/bundle.md`, `docs/ops/specs/scripts/bundle.md`

## Execution Logic
1. Run bundle-related gates required by the active DP.
2. Run `bash tools/verify.sh` and stop if it fails.
3. Run `bash tools/lint/style.sh` when docs/spec surfaces are modified and stop if it fails.
4. Record deterministic command outcomes in RESULTS.
5. Complete Closeout per `TASK.md` Section 3.5.

## Scope Boundary
- **Allowed:** Execute bundle-contract tasks within active DP scope and perform Closeout duties per `TASK.md` Section 3.5.
- **Forbidden:** Do not bypass failing bundle gates or expand into unrelated slices.
- **Stop Conditions:** Stop on missing required inputs, lint failures, or scope expansion.
