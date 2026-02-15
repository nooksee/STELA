# Technical Specification: tools/lint/factory.sh

## Purpose
Enforce synchronization and pointer integrity across agent, skill, and task definitions surfaces and registries.

## Invocation
- Command: `bash tools/lint/.sh`
- Required flags: none.
- Positional arguments: none.
- Expected exit behavior:
  - `0` when all definition checks pass.
  - `1` when one or more integrity failures are detected.
  - `2` when required registry files are missing.

## Inputs
- `docs/ops/registry/AGENTS.md`
- `docs/ops/registry/SKILLS.md`
- `docs/ops/registry/TASKS.md`
- `opt/_factory/agents/*.md`
- `opt/_factory/skills/*.md`
- `opt/_factory/tasks/*.md`
- Invokes `bash tools/lint/agent.sh` and `bash tools/lint/task.sh`.

## Outputs
- Writes no files.
- Stdout: verification banner and pass message (`OK: Factory Integrity Verified.`).
- Stderr: `FAIL:` diagnostics for dead ends, ghost artifacts, malformed pointers, and duplicate instruction patterns.

## Invariants and failure modes
- Registry entries must resolve to real files.
- Registry-managed directories must not contain unregistered artifacts.
- Skill pointers must be repo-relative and resolve to existing targets.
- Skills must remain pointer-first and must not include numbered step lists.
- Tasks that reference `S-LEARN-01` must not duplicate standard verification command boilerplate.

## Related pointers
- Registry entry: `docs/ops/registry/LINT.md` (`LINT-04`).
- Upstream registries: `docs/ops/registry/AGENTS.md`, `docs/ops/registry/SKILLS.md`, `docs/ops/registry/TASKS.md`.
- Adjacent linters: `tools/lint/agent.sh`, `tools/lint/task.sh`.
