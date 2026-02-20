# Technical Specification: tools/lint/agent.sh

## Purpose
Validate canon agent files against the agent registry and enforce pointer-first agent schema constraints.

## Invocation
- Command: `bash tools/lint/agent.sh`
- Required flags: none.
- Positional arguments: none.
- Expected exit behavior:
  - `0` when all checks pass.
  - `1` when one or more lint failures are detected.
  - `2` when required files (for example `docs/ops/registry/agents.md`) are missing.

## Inputs
- Git worktree root from `git rev-parse --show-toplevel`.
- `docs/ops/registry/agents.md`.
- `opt/_factory/agents/*.md`.

## Outputs
- Writes no files.
- Stdout: lint banner and terminal pass message (`OK: Agent immunological checks passed.`).
- Stderr: `FAIL:` diagnostics, including Level 1-5 enforcement failures.

## Invariants and failure modes
- Must run inside a git repository.
- Registry IDs must be unique and each registered agent file must exist.
- Agent files must include required sections and provenance fields.
- Pointers must be repo-relative, must exist, and must include `PoT.md`, `docs/GOVERNANCE.md`, and `TASK.md`.
- Authorized toolchain tokens are constrained to `ops/bin/*`, `tools/lint/*`, `tools/test/*`, or `tools/verify.sh`.
- Disposable artifact references and recursive context expansion patterns are rejected.

## Related pointers
- Registry entry: `docs/ops/registry/lint.md` (`LINT-01`).
- Upstream registry: `docs/ops/registry/agents.md`.
- Adjacent test: `tools/test/agent.sh` (`docs/ops/specs/tools/test/agent.md`).
