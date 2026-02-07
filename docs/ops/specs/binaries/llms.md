# Technical Specification: ops/bin/llms

## Technical Specifications
- Manifest Parsing: reads `ops/lib/manifests/CONTEXT.md` for small and full bundles, plus `ops/lib/manifests/LLMS.md` for scope bundles.
- Hazard Exclusion: rejects any bundle path that resolves to `docs/library/agents`, `docs/library/tasks`, or `docs/library/skills`.
- Redaction: strips common secret patterns before writing output.
- Output Bundles: generates `llms-small.txt`, `llms-full.txt`, `llms-ops.txt`, and `llms-governance.txt`, plus optional profile bundles.
- Flat Truth Enforcement: always writes bundles to the repository root. If `--out-dir` is provided, it also writes a copy there.
- Profile Support: supports `--profile=architect|security` with optional `--project=<id>` override.
- Freshness Metadata: `llms.txt` includes HEAD short hash, HEAD commit timestamp, and the refresh command.

## Requirements
- Must run from the repository root.
- Requires `ops/lib/manifests/CONTEXT.md` to exist and list valid files.
- Requires `ops/lib/manifests/LLMS.md` to exist and list valid files.
- Requires write access to the repository root and to any `--out-dir` target.

## Usage
- `./ops/bin/llms`
- `./ops/bin/llms --profile=architect`
- `./ops/bin/llms --project=example-project --profile=security`

## Forensic Insight
`ops/bin/llms` is the Context Bundler. Flat Truth requires the bundle to remain visible at the repository root to prevent a hidden, stale, or competing truth surface.
