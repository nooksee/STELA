# Technical Specification: ops/bin/compile

## Technical Specifications
- Compiles manifest templates from `ops/src/manifests/*.md.tpl` into explicit manifests under `ops/lib/manifests/*.md`.
- Expands glob entries deterministically using tracked files only (`git ls-files`).
- Supports nested template inheritance via backticked `@manifest:<path>` tokens.
- Emits sorted, de-duplicated file memberships (`LC_ALL=C sort`).
- Writes generated headers in compiled outputs with source-template provenance.

## Requirements
- Must run from the repository root.
- Requires `git` and `ops/lib/scripts/project.sh`.
- Requires tracked template files in `ops/src/manifests/`.

## Usage
- `./ops/bin/compile`

## Forensic Insight
`ops/bin/compile` removes runtime manifest ambiguity by making `ops/lib/manifests/*.md` generated artifacts. Context and llms generation consume only compiled explicit manifests.
