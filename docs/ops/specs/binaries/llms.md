# Technical Specification: ops/bin/llms

## Technical Specifications
- Wrapper over `ops/lib/scripts/synthesize.sh`.
- Generates `llms-core.txt` from `ops/lib/manifests/CORE.md`.
- Generates `llms-full.txt` from `ops/lib/manifests/DISCOVERY.md`.
- Regenerates `llms.txt` as the root pointer index.
- Supports `--out-dir=<path>` for mirrored output copies while always refreshing root files.
- Supports manifest overrides via `--core-manifest` and `--full-manifest`.

## Requirements
- Must run from the repository root.
- Requires `ops/lib/scripts/synthesize.sh` to be executable.
- Requires `ops/lib/manifests/CORE.md` and `ops/lib/manifests/DISCOVERY.md` to exist.
- Requires write access to repository root and to any `--out-dir` target.

## Usage
- `./ops/bin/llms`
- `./ops/bin/llms --out-dir="$(pwd)"`
- `./ops/bin/llms --core-manifest=ops/lib/manifests/CORE.md --full-manifest=ops/lib/manifests/DISCOVERY.md`

## Forensic Insight
`ops/bin/llms` is the static discovery wrapper. It enforces One Truth by delegating all parsing, hazard policy, and emission format logic to `ops/lib/scripts/synthesize.sh`.
