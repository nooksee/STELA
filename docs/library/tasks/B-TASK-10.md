# Task: Refresh + Audit

## Provenance
- **Captured:** 2026-02-08 01:51:44 UTC
- **DP-ID:** DP-OPS-0036
- **Branch:** work/task-hardening-0036
- **HEAD:** eeafcc36cda18155944a5441eaebe7fba4856cf8
- **Objective:** Bring the Task subsystem to pointer-first parity with Agents and Skills by adding a Task promotion ledger, a harvest and promote workflow, and lint enforcement, while refactoring B-TASK-01 through B-TASK-10 to the strict schema and aligning the registry.

## Orchestration
- **Primary Agent:** R-AGENT-02 (code-reviewer)
- **Supporting Agents:** R-AGENT-06 (security-reviewer)

## Pointers
- **Constitution:** `PoT.md`
- **Governance:** `docs/GOVERNANCE.md`
- **Contract:** `TASK.md`
- **Registry:** `docs/ops/registry/TASKS.md`
- **Toolchain:** `tools/lint/dp.sh`, `tools/lint/library.sh`
- **JIT Skills:** (none)
- **Reference Docs:** `docs/MANUAL.md`

## Execution Logic
1. Require RESULTS, OPEN, OPEN-PORCELAIN, dump, and dump manifest artifacts and stop if any are missing.
2. Validate the DP format with `bash tools/lint/dp.sh` against the provided DP file when one is available.
3. Confirm the receipt checklist, allowlist compliance, and verification outputs using `RESULTS`.
4. If any required proof is missing or incorrect, issue a disapproval with a patch request.

## Scope Boundary
- **Allowed:** Audit worker output using provided artifacts and required lints.
- **Forbidden:** Do not modify code or bypass missing proofs.
- **Stop Conditions:** Stop if required artifacts are missing or verification cannot be confirmed.
