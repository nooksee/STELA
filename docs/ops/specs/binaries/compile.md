# Technical Specification: ops/bin/compile

## Technical Specifications
- Compiles manifest templates from `ops/src/manifests/*.md.tpl` into explicit manifests under `ops/lib/manifests/*.md`.
- Expands glob entries deterministically using tracked files only (`git ls-files`).
- Supports nested template inheritance via backticked `@manifest:<path>` tokens.
- Emits sorted, de-duplicated file memberships (`LC_ALL=C sort`).
- Writes generated headers in compiled outputs with source-template provenance.
- Emits one immutable compile snapshot leaf on every successful run under `archives/manifests/` using unified schema front-matter.

## Snapshot Leaf Contract
- Compile is an archiving event.
- Naming policy is:
  - `compile-YYYY-MM-DDTHHMMSS-<git_short_hash>.md` (UTC, no colon characters).
- `previous` resolution:
  - Select the most recent prior compile leaf in `archives/manifests/` by filename sort order.
  - Use `previous: (none)` when no prior compile leaf exists.
- Front-matter keys in emitted leaf:
  - `trace_id`
  - `packet_id`
  - `created_at`
  - `previous`
- Trace and packet conventions:
  - `trace_id` reuses `STELA_TRACE_ID` when present; otherwise compile generates a new local trace id.
  - `packet_id` reuses `STELA_PACKET_ID` when present; otherwise compile uses default `OPS-COMPILE`.
- Stdout contract:
  - On success, compile emits one parseable line with the repository-relative leaf path:
    - `MANIFEST_LEAF: archives/manifests/compile-...md`

## Atomic Integration Contract
- Compile templates into a temporary workspace under `var/tmp/` first.
- Assemble and write the snapshot leaf from temporary compiled manifests before modifying `ops/lib/manifests/`.
- If snapshot assembly or write fails, compile exits non-zero and does not update runtime manifests.
- After snapshot write succeeds, promote temporary compiled manifests into `ops/lib/manifests/`.

## Requirements
- Must run from the repository root.
- Requires `git` and `ops/lib/scripts/project.sh`.
- Requires tracked template files in `ops/src/manifests/`.
- Requires writable `archives/manifests/`, `ops/lib/manifests/`, and `var/tmp/`.

## Usage
- `./ops/bin/compile`

## Forensic Insight
`ops/bin/compile` keeps runtime manifests current while preserving immutable compile-state history in `archives/manifests/`. Context and llms generation consume runtime manifests; audits and chain traversal consume compile leaves.
