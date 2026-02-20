# Technical Specification: tools/lint/factory.sh

## Purpose
Enforce factory pointer-head invariants and registry integrity across agent, task, and skill definition surfaces.

## Invocation
- Command: `bash tools/lint/factory.sh`
- Exit behavior:
  - `0` when all checks pass.
  - `1` when one or more integrity checks fail.
  - `2` when required files are missing.

## Inputs
- Factory heads:
  - `opt/_factory/AGENTS.md`
  - `opt/_factory/TASKS.md`
  - `opt/_factory/SKILLS.md`
- Definition specs:
  - `docs/ops/specs/definitions/agents.md`
  - `docs/ops/specs/definitions/tasks.md`
  - `docs/ops/specs/definitions/skills.md`
- Registries:
  - `docs/ops/registry/agents.md`
  - `docs/ops/registry/tasks.md`
  - `docs/ops/registry/skills.md`
- Canon definition directories under `opt/_factory/`.
- Delegated linters:
  - `tools/lint/agent.sh`
  - `tools/lint/task.sh`

## Checks
- Each factory head file has exactly four lines in this key order: `candidate`, `promotion`, `spec`, `registry`.
- `spec:` pointers match expected definition-spec paths and resolve on disk.
- `registry:` pointers match expected registry paths and resolve on disk.
- `candidate:` and `promotion:` values are valid when either:
  - origin sentinel ending with `-(origin)` and matching expected chain sentinel, or
  - reachable leaf path under `archives/definitions/`.
- Registry dead-end checks for agent, task, and skill canonical files.
- Ghost artifact checks for unregistered files in `opt/_factory/agents/`, `opt/_factory/tasks/`, and `opt/_factory/skills/`.
- Existing skill pointer hygiene and task duplicate-verification-pattern checks.

## Output Contract
- No file mutations.
- Emits `FAIL:` diagnostics for each violation.
- Emits `OK: Factory Integrity Verified.` only when all checks pass.

## Related pointers
- Registry entry: `docs/ops/registry/lint.md` (`LINT-04`).
- Upstream head specs: `docs/ops/specs/definitions/agents.md`, `docs/ops/specs/definitions/tasks.md`, `docs/ops/specs/definitions/skills.md`.
