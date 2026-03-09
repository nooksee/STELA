<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/factory.sh` preserves factory definition integrity by enforcing synchronized heads, registries, and definition leaves. F2 extends this with baseline schema checks so every active agent/skill/task leaf carries deterministic contract fields.

## Mechanics and Sequencing
1. Resolve repository root, emit telemetry, and require all factory heads, registries, and census registry.
2. Validate each head file (`AGENTS.md`, `TASKS.md`, `SKILLS.md`) as an exact four-line key sequence (`candidate`, `promotion`, `spec`, `registry`) with non-empty values.
3. Enforce expected `spec:` and `registry:` path equality and filesystem reachability.
4. Validate `candidate:` and `promotion:` values as either exact origin sentinels or reachable `archives/definitions/*` leaf paths.
5. Invoke delegated linters (`tools/lint/agent.sh`, `tools/lint/task.sh`) and fail factory lint when either delegated gate fails.
6. Parse registry rows and verify all referenced files exist; detect ghost files under `opt/_factory/agents`, `opt/_factory/skills`, and `opt/_factory/tasks`.
7. Parse census matrix rows from `docs/ops/registry/factory.md` and validate row schema:
   - kind in `{agent, skill, task}`
   - ID format aligned to kind (`R-AGENT-##`, `S-LEARN-##`, `B-TASK-##`)
   - path aligned to kind directory and present on disk
   - disposition in `{keep, replace, remove}`
   - reason-code prefix aligned to disposition (`K-`, `R-`, `X-`)
   - no duplicate `(kind,id)` rows and no duplicate paths
8. Enforce census coverage:
   - every definition leaf under `opt/_factory/{agents,skills,tasks}/*.md` has a census row
   - every direct runtime reference under `ops/`, `tools/`, and `docs/` to `opt/_factory/(agents|skills|tasks)/*.md` resolves to a census row
9. Enforce F2 baseline contract checks:
   - agent `## Identity Contract` must include `agent_id`, `runtime_role`, `stance_id`
   - allowed runtime-role and stance values are exactly `{foreman, auditor, conformist}`
   - skill `## Method Contract` must include `skill_id`, `method`, `inputs`, `outputs`, `invariants`
   - task `## Objective Contract` must include `task_id`, `objective`, `inputs`, `outputs`, `invariants`
   - `skill_id` and `task_id` must match filename-derived IDs
10. Apply additional guardrails:
    - skill pointer-token reachability
    - numbered-list rejection in skills
    - duplicate verification-pattern checks in tasks that already invoke `S-LEARN-01`

## Integrity Filter Warnings
The script depends on delegated outputs from `tools/lint/agent.sh` and `tools/lint/task.sh`; a failure in either script blocks factory lint even when head files are locally valid. Census validation and F2 contract checks are fail-closed and deterministic.
