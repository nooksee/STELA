# Operator Manual (Curated)

This manual is the operator-facing entrypoint for day-to-day commands and the curated docs library.
It is intentionally short and maintained; if it drifts, fix it.
You may see legacy `Stela` strings; `Stela` is the platform name going forward.

## Top Commands (cheat sheet)
~~~bash
./ops/bin/open --intent="short-intent" --dp="DP-XXXX / YYYY-MM-DD"
./ops/bin/dump --scope=platform --format=chatgpt
./ops/bin/dump --scope=platform --format=chatgpt --out=auto
./ops/bin/dump --scope=platform --format=chatgpt --include-dir=ops --include-dir=docs --out=auto
./ops/bin/dump --scope=platform --format=chatgpt --include-binary=raw --out=auto   # rare; literal bytes
./ops/bin/dump --scope=full --format=chatgpt --out=auto
./ops/bin/dump --scope=platform --format=chatgpt --out=auto --compress=tar.xz
./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle
./ops/bin/dump --scope=platform --format=chatgpt --out=auto.tar.xz
./ops/bin/help
./ops/bin/help continuity
~~~

## Docs library (curated surface)
The docs library is the approved, curated surface for operators.  
`ops/bin/help` searches `docs/` and prints matching lines with numbers.

Library location:
- Root: `docs/library/`
- Index: `docs/library/LIBRARY_INDEX.md` (curated topic list)

Add a new entry by editing the index and keeping the list curated (not every `.md`).

Continuity Map (operator wayfinding):
- `./ops/bin/help continuity`

## Platform vs Project
- Platform is the repo-resident operating system (ops/docs/tools/etc.).
- Project payloads live under `projects/*`.
- During platform construction, use platform context by default (exclude project payload).

## Open
- `./ops/bin/open` prints the copy-safe Open Prompt with the freshness gate and canon pointers.
- `./ops/bin/open` writes the OPEN prompt to `storage/handoff/OPEN-<tag>-<branch>-<HEAD>.txt` and captures porcelain to `storage/handoff/OPEN-PORCELAIN-<tag>-<branch>-<HEAD>.txt`; stdout still prints the OPEN prompt.
- Use `--tag=<token>` to include a filename tag; if omitted, filenames omit the tag.
- OPEN includes a brief posture nudge near the top.

Paste-ready delimiter example: `---`

## When to DISAPPROVE
- Missing proof bundle (git status --porcelain, git diff --name-only, git diff --stat, required verification outputs).
- Missing RECEIPT or missing RESULTS file.
- Forbidden path touched or scope mismatch.
- Verification missing or failed.
- Results claims do not match `git diff --name-only` or `git diff --stat`.

## DISAPPROVE message (copy/paste template)
~~~text
DISAPPROVE <DP-ID>
Why (facts): <brief, factual bullets>
Required patch (do these steps): <numbered steps>
Re-run verification + regenerate receipt: <commands or checklist>
~~~

## Branch protection
Branch protection on `main` should be enabled in GitHub settings.

## What workers must return
Worker guardrails (summary):
- Reuse-first; duplication check before creating anything (near-duplicates included).
- No new files unless listed in the DP FILES block.
- Declare the SSOT file for each touched topic; if unclear, STOP.
- Canon spelling: Stela. Normalize voice-to-text variants before committing or approving.
- If duplicates / near-duplicates / out-of-place artifacts are found, list them only under Supersession / Deletion candidates with a crisp plan; no deletions or moves unless explicitly authorized by the DP.
- Output artifacts are output artifact files created under `storage/handoff/` and `storage/dumps/` and must remain untracked.
- "No new files unless listed" applies to tracked repo files only.
- Worker must write the full results message (A/B/C/D + RECEIPT) to `storage/handoff/<DP-ID>-RESULTS.md`; contents must match the paste-mode results exactly.

Receipt package (minimum handoff artifacts; attachment-mode friendly):
- `storage/handoff/<DP-ID>-RESULTS.md` (required)
- Dump tarball when required by the DP
- Dump manifest (bundled inside the tarball when `--bundle` is used, or attached alongside when not bundled)
- OPEN + OPEN-PORCELAIN artifacts are already captured under `storage/handoff/` by OPEN tooling; do not regress this.

Use the exact headings and order:
- `### RECEIPT`
- `### A) OPEN Output` (full, unmodified output of `./ops/bin/open`; must include branch name and HEAD short hash used during work)
- `### B) DUMP Output` (paths or archived filenames; choose `--scope=platform` for doc/ops changes or `--scope=full` for structural or wide refactors; optional `--out=auto` and `--bundle` (tarball includes payload + manifest); for large `--scope=full` dumps, prefer `--compress=tar.xz`; dump may be inline, truncated if necessary, or referenced by generated filename if archived)

Include the manifest path when present (the manifest points to the chat payload file to paste).  
If a tarball is produced, include BOTH: the tarball path and the manifest path.

DPs missing the RECEIPT are incomplete and must be rejected.  
Workers may not claim "Freshness unknown" if they can run OPEN themselves.  
Attachment-mode handoff artifacts must be repo-local: use `storage/handoff/` (never `/tmp` or user temp dirs).

Canonical results filename:
- `storage/handoff/<DP-ID>-RESULTS.md` (basename UPPERCASE; `.md` lowercase).

For attachment-mode: the attached results file MUST include the RECEIPT (OPEN + DUMP).  
If OPEN exceeds message/file limits (edge case), attach the OPEN file from `storage/handoff/` and in `A) OPEN Output` include the exact path plus the one-line note: "OPEN attached; see path above."

What to look for (handoff artifacts):
- `storage/handoff/<DP-ID>-RESULTS.md`
- `storage/handoff/OPEN-<tag>-<branch>-<HEAD>.txt` (optional; if OPEN used `--out=auto`)
- Dump artifacts under `storage/dumps/`, as referenced by the RECEIPT

## Dump
`./ops/bin/dump` emits a repo dump (stdout by default). Use `--out=auto` to write to `storage/dumps/`.

Scopes:
- `--scope=platform` (default; platform context; excludes `projects/*`)
- `--scope=full` (full repo scope)
- `--scope=project --target=<slug>` (platform + a single project payload)

Binary handling (important):
- Default: `--include-binary=meta` (LLM-friendly) → binaries are **not embedded**; dump prints **path + bytes + sha256**.
- Optional:
  - `--include-binary=raw` (literal bytes; huge/noisy)
  - `--include-binary=base64` (safe text, still huge)

Refiners (optional; apply after scope selection; may be repeated):
- `--include-dir=DIR` → restrict output to files under DIR (e.g., `ops`, `docs`, `tools`)
- `--exclude-dir=DIR` → remove files under DIR
- `--ignore-file=GLOB` → remove files matching a glob against repo-relative paths (e.g., `*.png`, `docs/**/draft-*`)

Guidance:
- Use `--scope=platform` for platform build and governance work.
- Use `--scope=full` when project payloads must be included.
- Use `--scope=project --target=<slug>` for a single project focus view.
- For large dumps, prefer archive output (`--compress=tar.xz`) to keep artifacts attachable.
- Use refiners for narrow, task-specific dumps (e.g., `--include-dir=ops --include-dir=docs`) to reduce noise.

Optional archive output (tar.xz):
~~~bash
./ops/bin/dump --scope=platform --format=chatgpt --out=auto --compress=tar.xz
./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle     # tarball includes payload + manifest
./ops/bin/dump --scope=platform --format=chatgpt --out=auto.tar.xz
~~~

Auto-compress default:
- For `--scope=full` with `--out=auto` and no explicit `--compress`, `--compress=tar.xz` is assumed.

Archive behavior:
- Output is a `.tar.xz` archive in `storage/dumps/`.
- By default, the archive contains the generated dump text only.
- With `--bundle`, the archive contains the dump text plus the manifest.

Note: dumps do not include OPEN output; state travels via the RECEIPT (OPEN + DUMP).

## Help
`./ops/bin/help` is the operator front door for curated docs.
- `./ops/bin/help` shows the command menu and quick start.
- `./ops/bin/help <term>` searches `docs/` with line numbers.
