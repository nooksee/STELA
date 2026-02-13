# Technical Specification: tools/lint/style.sh

## Purpose
Enforce the no-contractions writing rule across markdown surfaces.

## Invocation
- Command: `bash tools/lint/style.sh`
- Required flags: none.
- Positional arguments: none.
- Expected exit behavior:
  - `0` when no contraction tokens are found.
  - `1` when dependencies are missing or contraction matches are detected.

## Inputs
- Git worktree root from `git rev-parse --show-toplevel`.
- `rg` for regex scanning.
- Markdown files under repo root with exclusions:
  - `!**/storage/**`
  - `!**/.git/**`

## Outputs
- Writes no files.
- Stderr on failure:
  - dependency errors (`rg` missing, not in git repo).
  - contraction match list with file and line numbers.
- No success banner is emitted on pass.

## Invariants and failure modes
- Contraction pattern includes ASCII and Unicode apostrophes.
- Scan scope is markdown only (`*.md`).
- Any match is a hard failure.

## Related pointers
- Registry entry: `docs/ops/registry/LINT.md` (`LINT-07`).
- Behavioral policy source: `PoT.md` Section 4.2.
- Adjacent policy lint: `tools/lint/truth.sh`.
