# Technical Specification: tools/lint/llms.sh

## Purpose
Verify that committed llms bundle outputs are byte-equivalent to fresh generator output and reject deprecated slice artifacts.

## Invocation
- Command: `bash tools/lint/llms.sh`
- Required flags: none.
- Positional arguments: none.
- Expected exit behavior:
  - `0` when generated bundles match root files and no deprecated slices exist.
  - `1` when required files are missing, generator is unavailable, deprecated files exist, or diffs are non-empty.

## Inputs
- `ops/bin/llms` executable.
- Root bundle files:
  - `llms.txt`
  - `llms-core.txt`
  - `llms-full.txt`
- Deprecated bundle disallow list:
  - `llms-small.txt`
  - `llms-ops.txt`
  - `llms-governance.txt`
- Temporary output directory from `mktemp -d`.

## Outputs
- Writes temporary generated bundles, then removes the temp directory.
- Stdout: unified diff output when mismatches exist and final success line on pass.
- Stderr: missing dependency, missing file, or deprecated-artifact diagnostics.

## Invariants and failure modes
- Generator path is fixed to `${REPO_ROOT}/ops/bin/llms`.
- All three root bundle files must exist before comparison starts.
- Presence of any deprecated root llms slice file is a hard failure.
- Any diff mismatch is a hard failure.

## Related pointers
- Registry entry: `docs/ops/registry/LINT.md` (`LINT-05`).
- Generator spec: `docs/ops/specs/binaries/llms.md`.
- Manifest sources: `ops/lib/manifests/CORE.md`, `ops/lib/manifests/OPS.md`, `ops/lib/manifests/DISCOVERY.md`.
