# Technical Specification: tools/lint/truth.sh

## Purpose
Guard canon spelling integrity by rejecting forbidden platform spellings in authored surfaces.

## Invocation
- Command: `bash tools/lint/truth.sh`
- Required flags: none.
- Positional arguments: none.
- Expected exit behavior:
  - `0` when no forbidden spelling matches are found.
  - `1` when one or more forbidden tokens are detected.

## Inputs
- Git tracked files under:
  - `docs/`
  - `tools/`
  - `.github/`
  - `ops/`
- Root canon files when present:
  - `PoT.md`
  - `TASK.md`
  - `README.md`
  - `llms.txt`
- Forbidden token set is embedded in script.

## Outputs
- Writes no files.
- Stdout: verification banner and pass summary (`OK: Truth Integrity Verified.`).
- Stderr: `FAIL:` lines including offending file and line details.

## Invariants and failure modes
- `tools/lint/truth.sh` excludes itself from scan.
- Only existing regular files are scanned.
- Any forbidden token match is a hard failure.

## Related pointers
- Registry entry: `docs/ops/registry/LINT.md` (`LINT-09`).
- Policy source: `PoT.md`.
- Adjacent style gate: `tools/lint/style.sh`.
