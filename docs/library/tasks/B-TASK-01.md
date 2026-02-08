# Task: Code Review

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
- **Toolchain:** `tools/lint/style.sh`, `tools/lint/truth.sh`, `tools/verify.sh`
- **JIT Skills:** `docs/library/skills/S-LEARN-04.md`, `docs/library/skills/S-LEARN-05.md`
- **Reference Docs:** `docs/MANUAL.md`

## Execution Logic
1. Run `git diff --name-only HEAD` to enumerate changed files.
2. Run `git diff HEAD` and review the diff using `docs/library/skills/S-LEARN-04.md` and `docs/library/skills/S-LEARN-05.md`.
3. Run `bash tools/lint/style.sh` and stop if it fails.
4. If canon or governance surfaces changed, run `bash tools/lint/truth.sh` and stop if it fails.
5. Run `bash tools/verify.sh` and stop if it fails.
6. Record findings with severity, file, line, and remediation notes.

## Scope Boundary
- **Allowed:** Review only the diff for the active DP and the commands listed in this task.
- **Forbidden:** Do not edit files or expand scope beyond the active DP.
- **Stop Conditions:** Stop if any required command fails or if required inputs are missing.
