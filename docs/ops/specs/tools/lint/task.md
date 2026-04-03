<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/task.sh` protects the highest-risk planning surfaces by enforcing both task-definition schema integrity and TASK dashboard container integrity. The script exists to prevent ambiguous dispatch contracts that trigger misexecution or STOP states, directly addressing the PoT Section 2 Ambiguity failure mode.

## Mechanics and Sequencing
1. Resolve repository root, emit telemetry, and require task registry plus task directory.
2. Lint task-definition corpus:
   - Reject contractions and legacy inline-session-state phrases.
   - Parse registry rows and enforce unique IDs, unique paths, and reachable files.
   - Detect ghost task files not present in the registry.
   - For each task file, enforce header identity, required sections, non-placeholder required fields, pointer token reachability, referenced agent/skill existence, and execution-logic constraints including mandatory final closeout pointer to `TASK.md` Section 3.5.
3. Resolve TASK dashboard path (direct file or archives pointer target), then lint container contract:
   - Enforce required heading set and order.
   - Reject forbidden legacy sections and inline branch/hash mirrors.
   - Enforce canonical seven-item load order and receipt command contract in Section 3.4.5.
   - Enforce `### 3.5.1 Mandatory Closing Sidecar` heading and closeout labels.
4. Aggregate all failures and exit non-zero when any task-definition or TASK-container check fails.

## Anecdotal Anchor
Before this gate existed, TASK container drift repeatedly preserved forbidden sections such as `Thread Transition` and inline branch/hash mirrors across sessions. That pattern produced inconsistent worker routing and manual cleanup cycles before dispatch could continue.

## Integrity Filter Warnings
Domain boundaries are intentional: `tools/lint/task.sh` enforces TASK container schema, while `tools/lint/dp.sh` enforces Section 3 transaction integrity. The script prefers `rg` for reference scans and falls back to `grep -E` when `rg` is unavailable. Canon-load enforcement applies only to the seven numbered items in `3.2.1`; the injected execution brief `## Rules` block between `3.2.1` and `3.2.2` is not part of that count. When TASK is a single-line pointer and its target is missing, lint fails before container checks run.
