# Technical Specification: ops/bin/map

## Technical Specifications
- Deterministic update: rewrites only the auto-generated block inside `docs/MAP.md`.
- Sentinel control: uses HTML comment markers to bound the writable block.
- Directory index: emits a top-level index for `ops/`, `tools/`, `docs/`, and `storage/`.
- Project discovery: enumerates any `projects/*/STELA.md` files found at runtime.
- Check mode: `--check` exits non-zero if `docs/MAP.md` would change.

## Requirements
- Must run from the repository root.
- Requires `docs/MAP.md` to contain the auto-generated sentinel block.
- Requires write access to `docs/MAP.md` (unless `--check` is used).

## Usage
- `./ops/bin/map`
- `./ops/bin/map --check`

## Forensic Insight
`ops/bin/map` is the Wayfinding Maintainer. It keeps a stable, auto-generated map block without overwriting manual narrative prose.
