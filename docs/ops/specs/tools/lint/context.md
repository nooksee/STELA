# Technical Specification: tools/lint/context.sh

## Purpose
Enforce context manifest completeness and reject context contamination in canonical surfaces.

## Invocation
- Command: `bash tools/lint/context.sh`
- Required flags: none.
- Positional arguments: none.
- Expected exit behavior:
  - `0` when context checks pass (warnings allowed).
  - `1` when one or more context failures are detected.
  - `2` when `ops/lib/manifests/CONTEXT.md` is missing.

## Inputs
- Git worktree root from `git rev-parse --show-toplevel`.
- `ops/lib/manifests/CONTEXT.md` (backticked artifact extraction source).
- Canon contamination scan targets: `PoT.md`, `SoP.md`, `TASK.md`, `docs/MAP.md`, `llms.txt`.

## Outputs
- Writes no files.
- Stdout: verification banner and pass summary (`OK: Context Complete.`).
- Stderr: `FAIL:` and `WARN:` lines for missing artifacts, hazards, or contamination patterns.

## Invariants and failure modes
- Global context manifest must not include `opt/_factory/agents`, `opt/_factory/tasks`, or `opt/_factory/skills`.
- Legacy paths (`docs//agents`, `docs//tasks`, `docs//skills`) are also rejected as context hazards.
- Every backticked path in `CONTEXT.md` must exist.
- Canon files must not contain dump/paste contamination markers.

## Related pointers
- Registry entry: `docs/ops/registry/LINT.md` (`LINT-02`).
- Context source: `ops/lib/manifests/CONTEXT.md`.
- Adjacent truth checks: `tools/lint/truth.sh`.
