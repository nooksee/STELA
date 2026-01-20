# Operator Manual (Curated)

This manual is the operator-facing entrypoint for day-to-day commands and the curated docs library.
It is intentionally short and maintained; if it drifts, fix it.
You may see legacy `nukeCE` strings; `STELA` is the platform name going forward.

## Top Commands (cheat sheet)
```
./ops/bin/open --intent="..." --dp="DP-XXXX / YYYY-MM-DD"
./ops/bin/snapshot --scope=icl --format=chatgpt
./ops/bin/snapshot --scope=icl --format=chatgpt --out=auto
./ops/bin/snapshot --scope=platform --format=chatgpt --out=auto
./ops/bin/snapshot --scope=full --format=chatgpt --out=auto
./ops/bin/snapshot --scope=icl --format=chatgpt --out=auto --compress=tar.xz
./ops/bin/snapshot --scope=icl --format=chatgpt --out=auto --bundle
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

## DP docket (optional)
Use the docket (`docs/library/DOCKET.md`) when you want a light forward-looking queue:
- Creative sessions, mobile sessions, or multi-day work (less DP-number drift).
- Keep `NEXT_DP_ID` updated to avoid DP-number confusion.
- Optional; you can skip it and run DPs normally.

## Talk-only mode (DISCUSS-ONLY)
Use `DISCUSS-ONLY` to signal ideation only; it is a non-gating cue and does not authorize execution.
When to use:
- Early scoping, open-ended brainstorming, or when you want alignment without action.
What to expect:
- The model will discuss and ask clarifying questions.
- No commands run, no file edits, and no approval-dependent artifacts until a DP (and approval phrase when required) is provided.

## Platform vs Project
- Platform is the repo-resident operating system (ops/docs/tools/etc.).
- Project payloads live under `projects/*`.
- During platform construction, use platform context by default (exclude project payload).

## Project registry
- SSOT: `docs/library/datasets/PROJECT_REGISTRY.md`.
- `./ops/bin/project` lists/initializes STELA-born projects (no import/migration).
- `./ops/bin/project init <name>` requires `--dry-run` or `--confirm` (no silent payload creation).

## Projects
- `./ops/bin/project new --name "..." --dry-run` previews a new project with auto id/slug; `--confirm` creates it and sets the current pointer.
- `./ops/bin/project use <project_id> --dry-run|--confirm` updates the current project pointer for a registered id.
- `./ops/bin/project current` reports the current project id or `none`.
- Recommended flow: run `project new --dry-run`, review output, then `--confirm` and check `project current`.

## Open
- `./ops/bin/open` prints the copy-safe Open Prompt with the freshness gate and canon pointers.
- `./ops/bin/open` writes the OPEN prompt to `storage/handoff/OPEN-<tag>-<branch>-<HEAD>.txt` and captures porcelain to `storage/handoff/OPEN-PORCELAIN-<tag>-<branch>-<HEAD>.txt`; stdout still prints the OPEN prompt.
- Use `--tag=<token>` to include a filename tag; if omitted, filenames omit the tag.
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
Attachment-mode (lowest-friction default when the operator is on mobile):
1) Approval line in chat (start-of-message, plain text, unquoted).
2) Attach the worker-results text file from `storage/handoff/<DP-ID>-RESULTS.md` (full worker results, including the RECEIPT (OPEN + SNAPSHOT)).
3) Attach snapshot artifacts when required.
Minimal attachment-mode handoff: one approval line + results artifact attachment, plus the snapshot bundle when required. Paste-mode remains valid.
If the chat UI cannot insert blank lines safely, use the `---` delimiter line before pasting results.
MEMENTO: M-HANDOFF-01 (docs/library/MEMENTOS.md).
Approval must be the first tokens in the message (start-of-message) and outside OPEN prompt text, OPEN intent, and outside quoted/fenced blocks.
Quoted blocks are commentary and invalid for approval. If approval is buried, DB-PR-META is withheld.
Emission gate: approval phrase required; no exceptions.
Dataset reference: `./ops/bin/help db-pr-meta`
UI order + payload types are canonical; use the DB-PR-META dataset as the SSOT.
Micro-style: avoid exact-duplicate strings across Commit message, PR title, Merge commit message; similar is OK.

## When to DISAPPROVE
- Missing proof bundle (git status --porcelain, git diff --name-only, git diff --stat, required verification outputs).
- Missing RECEIPT or missing RESULTS file.
- Forbidden path touched or scope mismatch.
- Verification missing or failed.
- Results claims do not match `git diff --name-only` or `git diff --stat`.

## DISAPPROVE message (copy/paste template)
```
DISAPPROVE <DP-ID>
Why (facts): <brief, factual bullets>
Required patch (do these steps): <numbered steps>
Re-run verification + regenerate receipt: <commands or checklist>
```
Note: this is a worker feedback format; it is not the approval phrase.

## Branch protection
Branch protection on `main` should be enabled in GitHub settings.

## What workers must return
Worker guardrails (summary):
- Reuse-first; duplication check before creating anything (near-duplicates included).
- No new files unless listed in the DP FILES block.
- Declare the SSOT file for each touched topic; if unclear, STOP.
- If duplicates / near-duplicates / out-of-place artifacts are found, list them only under Supersession / Deletion candidates with a crisp plan; no deletions or moves unless explicitly authorized by the DP.
- Output artifacts are output artifact files created under `storage/handoff/` and `storage/snapshots/` and must remain untracked.
- "No new files unless listed" applies to tracked repo files only.
- Worker must write the full results message (A/B/C/D + RECEIPT) to `storage/handoff/<DP-ID>-RESULTS.md`; contents must match the paste-mode results exactly.
Receipt package (minimum handoff artifacts; attachment-mode friendly):
- `storage/handoff/<DP-ID>-RESULTS.md` (required)
- Snapshot tarball when required by the DP
- Snapshot manifest (bundled inside the tarball when `--bundle` is used, or attached alongside when not bundled)
- OPEN + OPEN-PORCELAIN artifacts are already captured under `storage/handoff/` by OPEN tooling; do not regress this.

Every worker result message must end with the RECEIPT (delivery format, not IN-LOOP permission):
- Use the exact headings and order:
  - `### RECEIPT`
  - `### A) OPEN Output` (full, unmodified output of `./ops/bin/open`; must include branch name and HEAD short hash used during work)
  - `### B) SNAPSHOT Output` (paths or archived filenames; choose `--scope=icl` for doc/ops changes or `--scope=full` for structural or wide refactors; optional `--out=auto` and `--bundle` (tarball includes payload + manifest); for large `--scope=full` snapshots, prefer `--compress=tar.xz`; snapshot may be inline, truncated if necessary, or referenced by generated filename if archived)
  - Include the manifest path when present (the manifest points to the chat payload file to paste).
  - If a tarball is produced, include BOTH: the tarball path and the manifest path.
DPs missing the RECEIPT are incomplete and must be rejected.
Workers may not claim "Freshness unknown" if they can run OPEN themselves.
Attachment-mode handoff artifacts must be repo-local: use `storage/handoff/` (never `/tmp` or user temp dirs). Canonical results filename: `storage/handoff/<DP-ID>-RESULTS.md` (basename UPPERCASE; `.md` lowercase).
For attachment-mode: the attached results file MUST include the RECEIPT (OPEN + SNAPSHOT). If OPEN exceeds message/file limits (edge case), attach the OPEN file from `storage/handoff/` and in `A) OPEN Output` include the exact path plus the one-line note: "OPEN attached; see path above."

What to look for (handoff artifacts):
- `storage/handoff/<DP-ID>-RESULTS.md`
- `storage/handoff/OPEN-...txt` (optional; if OPEN used `--out=auto`)
- Snapshot artifacts under `storage/snapshots/`, as referenced by the RECEIPT

## Snapshot
`./ops/bin/snapshot` emits a repo snapshot (stdout by default). Use `--out=auto` to write to `storage/snapshots/`.
Scopes:
- `--scope=icl` (default, curated operator scope)
- `--scope=platform` (platform-only context; excludes `projects/*` and `public_html/*`)
- `--scope=full` (full repo scope)
Note: snapshots do not include OPEN output; state travels via the RECEIPT.

Guidance:
- Use `--scope=platform` for full platform context during platform build.
- Use `--scope=full` when project payload must be included.
- For large `--scope=full` snapshots, prefer `--compress=tar.xz` to keep artifacts attachable.

Optional archive output (tar.xz):
- `./ops/bin/snapshot --scope=icl --format=chatgpt --out=auto --compress=tar.xz`
- `./ops/bin/snapshot --scope=icl --format=chatgpt --out=auto --bundle`
- `./ops/bin/snapshot --scope=icl --format=chatgpt --out=auto.tar.xz`

Auto-compress default:
- For `--scope=full` with `--out=auto` and no explicit `--compress`, `--compress=tar.xz` is assumed.

Archive behavior:
- Output is a `.tar.xz` archive in `storage/snapshots/`.
- By default, the archive contains the generated snapshot text only.
- With `--bundle`, the archive contains the snapshot text plus the manifest.

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
