# Operator Manual (Curated)

This manual is the operator-facing entrypoint for day-to-day commands and the curated docs library.
It is intentionally short and maintained; if it drifts, fix it.

## Top Commands (cheat sheet)
```
./ops/bin/open --intent="..." --dp="DP-XXXX / YYYY-MM-DD"
./ops/bin/close
./ops/bin/snapshot --scope=icl --format=chatgpt
./ops/bin/snapshot --scope=icl --format=chatgpt --out=auto
./ops/bin/snapshot --scope=full --format=chatgpt --out=auto
./ops/bin/snapshot --scope=icl --format=chatgpt --out=auto --compress=tar.xz
./ops/bin/snapshot --scope=icl --format=chatgpt --out=auto.tar.xz
./ops/bin/help
./ops/bin/help list
./ops/bin/help manual
```

## Docs library (curated surface)
The docs library is the approved, curated surface for operators.
`ops/bin/help` will only open documents listed in `docs/library/LIBRARY_INDEX.md`.
If a document is not in the manifest, help will refuse to open it.

Library location:
- Root: `docs/library/`
- Manifest: `docs/library/LIBRARY_INDEX.md` (format: `topic | title | path`)

Add a new entry by editing the manifest and keeping the list curated (not every .md).

Continuity Map (operator wayfinding):
- `./ops/bin/help continuity-map`

ICL Continuity Core (operator wayfinding):
- `./ops/bin/help icl-continuity-core`

Datasets:
- Datasets live under `docs/library/datasets/` and are manifest-only.
- Use `./ops/bin/help db-dataset` for the dataset library overview.
- Use `./ops/bin/help db-pr-meta` for DB-PR-META surface rules.

Behavioral preferences:
- Behavioral preferences are documented in `docs/library/MEMENTOS.md`.

## Open / Close
- `./ops/bin/open` prints the copy-safe Open Prompt with the freshness gate and canon pointers.
- `./ops/bin/close` prints a copy-safe session receipt.
- OPEN includes a brief posture nudge near the top.

## DB-PR-META (approval-gated metadata surfaces)
DB-PR-META is the approval-gated six-surface metadata output used for commits, PRs, and merge notes.
How to approve (IN-LOOP):
Approval phrase (required): `APPROVE <DP-ID> EMIT DB-PR-META`
Paste-ready delimiter example:
`APPROVE DP-OPS-0025 EMIT DB-PR-META`
`---`
Operator Handoff Paste Order (single message, exact order):
1) Approval line (start-of-message, plain text, unquoted): `APPROVE <DP-ID> EMIT DB-PR-META`
2) Paste worker results raw, unquoted, unedited (after a delimiter: a single blank line or a line containing only `---`).
3) Attach the snapshot file in the same message (if DP required it).
If the chat UI cannot insert blank lines safely, use the `---` delimiter line before pasting results.
MEMENTO: M-HANDOFF-01 (docs/library/MEMENTOS.md).
Approval must be the first tokens in the message (start-of-message) and outside OPEN prompt text, OPEN intent, and outside quoted/fenced blocks.
Quoted blocks are commentary and invalid for approval. If approval is buried, DB-PR-META is withheld.
Emission gate: approval phrase required; no exceptions.
Dataset reference: `./ops/bin/help db-pr-meta`
UI order + payload types are canonical; use the DB-PR-META dataset as the SSOT.

## What workers must return
Every worker result message must end with the RECEIPT (delivery format, not IN-LOOP permission):
- Use the exact headings and order:
  - `### RECEIPT`
  - `### A) OPEN Output` (full, unmodified output of `./ops/bin/open`; must include branch name and HEAD short hash used during work)
  - `### B) SNAPSHOT Output` (choose `--scope=icl` for doc/ops changes or `--scope=full` for structural or wide refactors; optional `--out=auto` and `--compress=tar.xz`; snapshot may be inline, truncated if necessary, or referenced by generated filename if archived)
DPs missing the RECEIPT are incomplete and must be rejected.
Workers may not claim "Freshness unknown" if they can run OPEN themselves.

## Snapshot
`./ops/bin/snapshot` emits a repo snapshot (stdout by default). Use `--out=auto` to write to `storage/snapshots/`.
Scopes:
- `--scope=icl` (default, curated operator scope)
- `--scope=full` (full repo scope)
Note: snapshots do not include OPEN output; state travels via the RECEIPT.

Optional archive output (tar.xz):
- `./ops/bin/snapshot --scope=icl --format=chatgpt --out=auto --compress=tar.xz`
- `./ops/bin/snapshot --scope=icl --format=chatgpt --out=auto.tar.xz`

Archive behavior:
- Output is a `.tar.xz` archive in `storage/snapshots/`.
- The archive contains exactly one file: the generated snapshot text.

## Help
`./ops/bin/help` is the operator front door for curated docs.
- `./ops/bin/help list` shows approved topics from the library manifest.
- `./ops/bin/help <topic>` opens that doc in `less` (color via `bat` when available).

Current help topics (from the manifest):
```
manual
continuity-map
icl-continuity-core
db-dataset
db-voice-0001
db-pr-meta
quickstart
docs-index
context-pack
daily-console
recovery
output-format-contract
contractor-dispatch-contract
project-truth
state-of-play
```
