# Technical Specification: tools/verify.sh

## Purpose
Enforce repository filing doctrine and baseline platform-structure hygiene checks.

## Invocation
- Command: `./tools/verify.sh`
- Required flags: none.
- Positional arguments: none.
- Expected exit behavior:
  - `0` when no hard errors are found (warnings allowed).
  - `1` when one or more hard errors are detected.

## Inputs
- Git worktree root from `git rev-parse --show-toplevel`.
- Expected directories:
  - `ops/`
  - `docs/`
  - `tools/`
  - `projects/`
  - `.github/`
- Storage subdirectories: `storage/handoff`, `storage/dumps`, `storage/tmp`.
- File-type checks for `docs/` and markdown policy checks for `ops/`.

## Outputs
- Writes no files.
- Stdout: verification banner and summary (`OK: Clean Platform State.` or `PASS (with N warnings).`).
- Stderr: `FAIL:` and `WARN:` diagnostics.

## Invariants and failure modes
- `docs/` must not contain binary files.
- `docs/` must contain markdown files only.
- Markdown under `ops/` is allowed only in `ops/lib/manifests/*` and `ops/lib/project/*`.
- Missing required root or storage directories is a hard failure.
- Unexpected storage items and missing project README files are warnings.

## Related pointers
- Registry entry: `docs/ops/registry/TOOLS.md` (`TOOL-01`).
- Adjacent gates: `tools/lint/context.sh`, `tools/lint/style.sh`, `tools/lint/truth.sh`.
- Filing doctrine source: `PoT.md`.
