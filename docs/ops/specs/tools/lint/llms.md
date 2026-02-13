# Technical Specification: tools/lint/llms.sh

## Purpose
Verify that committed llms bundle outputs are byte-equivalent to fresh generator output.

## Invocation
- Command: `bash tools/lint/llms.sh`
- Required flags: none.
- Positional arguments: none.
- Expected exit behavior:
  - `0` when generated bundles match root `llms*.txt` files.
  - `1` when required files are missing, generator is unavailable, or diffs are non-empty.

## Inputs
- `ops/bin/llms` executable.
- Root bundle files:
  - `llms-small.txt`
  - `llms-full.txt`
  - `llms-ops.txt`
  - `llms-governance.txt`
  - `llms.txt`
- Temporary output directory from `mktemp -d`.

## Outputs
- Writes temporary generated bundles, then removes the temp directory.
- Stdout: unified diff output when mismatches exist and final success line on pass.
- Stderr: missing dependency or missing file diagnostics.

## Invariants and failure modes
- Generator path is fixed to `${REPO_ROOT}/ops/bin/llms`.
- All five root bundle files must exist before comparison starts.
- Any diff mismatch is a hard failure.

## Related pointers
- Registry entry: `docs/ops/registry/LINT.md` (`LINT-05`).
- Generator spec: `docs/ops/specs/binaries/llms.md`.
- Manifest source: `ops/lib/manifests/LLMS.md`.
