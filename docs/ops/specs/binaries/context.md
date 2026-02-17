# Technical Specification: ops/bin/context

## Technical Specifications
- Wrapper over `ops/lib/scripts/synthesize.sh`.
- Runs `ops/bin/compile` before synthesis to ensure manifests are generated from templates.
- Defaults to `ops/lib/manifests/OPS.md` for session synthesis.
- Executes `ops/bin/open --out=auto` and injects the OPEN artifact into the emitted session stream.
- Supports `--manifest=<path>` override for alternate layer synthesis.
- Supports `--out=auto|<path>` to persist the assembled session stream.

## Requirements
- Must run from the repository root.
- Requires `ops/bin/compile`, `ops/bin/open`, and `ops/lib/scripts/synthesize.sh` to be executable.
- Requires write access to `storage/handoff/` and `var/tmp/` when `--out` is used.

## Usage
- `./ops/bin/context`
- `./ops/bin/context --out=auto`
- `./ops/bin/context --manifest=ops/lib/manifests/DISCOVERY.md --out=auto`

## Forensic Insight
`ops/bin/context` is the session entrypoint wrapper. It compiles manifests, binds OPEN state, and emits synthesized OPS-layer context into one deterministic stream.
