<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/factory.sh` preserves factory definition integrity by enforcing synchronized heads, registries, and definition leaves. The linter now also enforces a deterministic census ledger at `docs/ops/registry/factory.md` so every active factory definition and runtime path reference is explicitly classified (`keep`, `replace`, `remove`) with a reason code.

## Mechanics and Sequencing
1. Resolve repository root, emit telemetry, and require all factory heads, definition registries, and census registry.
2. Validate each head file (`AGENTS.md`, `TASKS.md`, `SKILLS.md`) as an exact four-line key sequence (`candidate`, `promotion`, `spec`, `registry`) with non-empty values.
3. Enforce expected `spec:` and `registry:` path equality and filesystem reachability.
4. Validate `candidate:` and `promotion:` values as either exact `-(origin)` sentinels or reachable `archives/definitions/*` leaf paths.
5. Invoke delegated linters (`tools/lint/agent.sh`, `tools/lint/task.sh`) and fail factory lint when either delegated gate fails.
6. Parse registry rows and verify all referenced files exist, then detect ghost files under `opt/_factory/agents`, `opt/_factory/skills`, and `opt/_factory/tasks`.
7. Parse census matrix rows from `docs/ops/registry/factory.md` and validate row schema:
   - kind in `{agent, skill, task}`
   - ID format aligned to kind (`R-AGENT-##`, `S-LEARN-##`, `B-TASK-##`)
   - path aligned to kind directory and present on disk
   - disposition in `{keep, replace, remove}`
   - reason-code prefix aligned to disposition (`K-`, `R-`, `X-`)
   - no duplicate `(kind,id)` rows and no duplicate paths
8. Enforce coverage:
   - every definition leaf under `opt/_factory/{agents,skills,tasks}/*.md` must have a census row
   - every direct runtime reference under `ops/`, `tools/`, and `docs/` to `opt/_factory/(agents|skills|tasks)/*.md` must resolve to a census row
9. Apply additional guardrails: skill-pointer token existence checks, numbered-list rejection in skill files, and duplicate verification-pattern checks inside task files that already invoke `S-LEARN-01`.

## Anecdotal Anchor
Cross-packet factory work exposed gaps where active definitions and runtime references existed without explicit disposition accounting. The census gate prevents silent definition drift by requiring a maintained usage matrix before closeout.

## Integrity Filter Warnings
The script depends on delegated outputs from `tools/lint/agent.sh` and `tools/lint/task.sh`; a failure in either script blocks factory lint even when head files are locally valid. Census validation is strict for row schema and path coverage and will fail when new factory leaves or runtime references are introduced without registry matrix updates.
