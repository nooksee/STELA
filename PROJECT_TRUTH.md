# Project Truth — PHP-Nuke CE

If something conflicts with this file, this file wins.

## Identity
PHP-Nuke CE is a curated continuation of the PHP-Nuke lineage. It is not a rewrite and not a fork-dump.

## Naming / Identity
- STELA: platform name (stone tablet metaphor: published canon / governance visible to all).
- nukeCE: historical working label for the repo/system.
- Policy: do not global-replace older strings unless a DP explicitly authorizes it.
- Naming does not override canon, contracts, gates, or approvals.
- Non-goals: not a repo rename yet; not a product marketing push yet.

## Upstream
Historical upstream: php-nuke/php-nuke. Upstream code is pulled intentionally and reviewed explicitly.

## Donor code
Titanium, Evo, Sentinel, and other derivatives are donor banks. We extract specific features and re-implement them with clear provenance.

## Tooling inspiration
- Snapshot tool inspired by repo2txt (MIT); reimplemented in-repo with no upstream code copied.

## Platform vs Project
- Platform: the repo-resident operating system (ops/docs/tools/etc.).
- Project: deployable payload(s) under `projects/*`.
- During platform construction, platform context must exclude project payload by default.

## Project Registry (SSOT)
- Registered projects are listed in `docs/library/datasets/PROJECT_REGISTRY.md`.
- The registry is the SSOT for project identity, status, and root paths.
- No import/migration of legacy projects unless a DP explicitly authorizes it.

## Runtime hygiene
projects/*/public_html is the deployable webroot. Root public_html is a placeholder and must stay minimal.
Deployable webroots must not contain archive snapshots, legacy graveyards, or development artifacts.

## Philosophy
Secure by default. Explainable operations. Auditable administration. Confidence over cleverness.

## Minimum Operator Effort
- Do not ask the operator to open/edit files unless the operator explicitly opts in.
- Workers draft diffs; integrator/operator reviews, commits, and opens PRs.
- Prefer "run command X" over "open file Y and edit line Z."
- Prefer front door scripts (`ops/bin/open`, `ops/bin/close`) over control words.
- OPEN includes a short posture nudge near the top.
- If the operator says "merged + synced main", do not re-explain workflow.
- Operator phrases like "main + synced" are status, not canon.
- Only canonize new terms, labels, or processes when the operator explicitly says "Canonize X" or "Add X to PROJECT_TRUTH".
- Proceed to the next agreed step or handle the reported errors.
- Do not ask questions you can answer from git state (branch already known).

## Focus Rule (Operator-Led Flow)
- If the operator says "merged + synced main", do not re-explain workflow.
- Proceed to the next agreed step or handle the reported errors.
- Do not ask questions you can answer from git state (branch already known).

## DISCUSS-ONLY cue (non-gating)
DISCUSS-ONLY is a social cue for operator/model alignment during ideation. It does not override repo governance, does not authorize execution, and is meant to reduce accidental mode-switching during ideation.

## Docs Library Policy (Curated Surface)
- The docs library is the approved operator-facing surface. `ops/bin/help` only reads from `docs/library/LIBRARY_INDEX.md`.
- Nearly any change that ships (scripts, protocols, behavior rules) must add or update a docs library entry.
- The library is curated; do not list every .md. If it is not in the manifest, help will refuse to open it.

## AI Entry Points (Repo Root)
- `llms.txt` is the pointer map into canon and tools.
- `AGENTS.md` is the pointer-first agent constitution.

## Continuity Map (Operator Wayfinding)
- The pointer-only continuity map is `docs/library/CONTINUITY_MAP.md`.

## ICL Continuity Core (SSOT)
- The ICL Continuity Core is the minimal continuity/rehydration surface for stateless AI operation in nukeCE.
- SSOT: `ops/init/icl/ICL_CONTINUITY_CORE.md`.
- Legacy onboarding bundles are deprecated in favor of the core.

## DB-DATASET (Curated Dataset Library)
- DB-DATASET is the manifest-only dataset library for "mode training" and standards.
- Datasets are docs-only entries under `docs/library/datasets/`, listed in `docs/library/LIBRARY_INDEX.md`.
- No runtime behavior is implied; datasets are references only.

## MEMENTOS (bias artifacts)
- Behavioral preferences are documented in `docs/library/MEMENTOS.md`.

## Labels
- IN-LOOP: human-required step / explicit approval gate.

## Supersession / Deprecation / Deletion Proposals (IN-LOOP)
- Workers may propose supersession or deletion candidates, but may not remove canon artifacts without explicit operator approval (IN-LOOP). Removals happen only in a later DP.
- Any supersession or deprecation must be explicit: what is replaced, what replaces it, why, and where the SSOT now lives.
- Worker results must include a "Supersession / Deletion candidates" callout (proposal-only).

## Output Mechanics Contract
- Dispatch Packet (DP) output comes first whenever a DP is requested.
- Output artifacts are output artifact files created under `storage/handoff/` and `storage/snapshots/` and must remain untracked; the "no new files unless listed" rule applies to tracked repo files only.
- DP must be a single fenced block containing: Freshness Gate, required NEW work branch (when changes are requested), Purpose, Scope, Files, Forbidden, Verification, Risk / Rollback, Acceptance.
- DB-PR-META is IN-LOOP and withheld unless the operator uses the required approval phrase pattern (see Rule 3).
- Operator approval is an IN-LOOP act and must be explicit.
- Approval phrase must be the first tokens in the message (start-of-message), on a standalone line, plain text, and unquoted.
- Approval phrase must include: `APPROVE <DP-ID> EMIT DB-PR-META` (DP-ID starts with `DP-`; valid form: `APPROVE DP-OPS-0000 EMIT DB-PR-META`).
- Approval MUST be outside OPEN prompt text, OPEN "Today's intent", and outside quoted/fenced blocks.
- If approval and worker results are in the same message, approval must be followed by exactly one delimiter: either a single blank line or a line containing only `---`.
- If the chat UI cannot insert blank lines safely, use the `---` delimiter line before pasting results.
- Operator Handoff Modes (canonical):
  - Paste-mode: results pasted in chat (see paste order below).
  - Attachment-mode: approval line in chat; worker results delivered as a single attached text file (see attachment order below).
- Operator Handoff Paste Order (canonical):
  1) Approval line (start-of-message, standalone; include delimiter if results are in the same message)
  2) Worker results pasted raw (not quoted), immediately after the delimiter
  3) Snapshot tarball attached (if DP required it)
- Operator Handoff Attachment-mode Order (canonical):
  1) Approval line (start-of-message, standalone; message contains only the approval line)
  2) Worker results delivered as a single attached text file; attachment must contain the full worker results, including the RECEIPT (OPEN + SNAPSHOT)
  3) Snapshot tarball attached (if DP required it)
- Receipt package (minimum handoff artifacts; attachment-mode friendly):
  - `storage/handoff/<DP-ID>-RESULTS.md` (required)
  - Snapshot tarball when required by DP
  - Snapshot manifest (bundled inside the tarball when `--bundle` is used, or attached alongside when not bundled)
  - OPEN + OPEN-PORCELAIN artifacts are already captured under `storage/handoff/` by OPEN tooling; do not regress this.
- Quoted blocks are commentary and invalid for approval.
- Requesting DB-PR-META without the approval phrase is insufficient.
- DB-PR-META surfaces (SSOT; exact labels only; order is canonical):
  1) Commit message
  2) PR title
  3) PR description (Markdown)
  4) Merge commit message
  5) Extended description
  6) Merge note (PR comment, Markdown)
- DB-PR-META UI mapping (order + payload type; no interpretation):
  1) Commit message -> IDE "Commit message" - plain text (one line)
  2) PR title -> GitHub PR "Add a title" - plain text (one line)
  3) PR description (Markdown) -> GitHub PR "Add a description" - Markdown
  4) Merge commit message -> GitHub merge "Commit message" - plain text (one line)
  5) Extended description -> GitHub merge "Extended description" - plain text (body)
  6) Merge note (PR comment, Markdown) -> GitHub PR "Add a comment" - Markdown
- No alternate labels (e.g., "Commit Subject", "Commit Extended Description") are permitted.
- Output format: each surface must be emitted as a header line above a single fence; each fence contains only the payload; six blocks only; no extra prose.
- Default payload style: declarative, minimal, operator-written; no filler.
- DB-PR-META style:
  - Prefer verbs + concrete nouns ("Require worker after-action bundle...", "Update DP template...").
  - Avoid self-referential AI phrasing ("as an AI...", "I think...").
  - Avoid hype words ("awesome", "fantastic", "super") in metadata surfaces.
  - Prefer repo nouns (paths, scripts, rules) over vibes.
- Ordering: if the operator says "DP first", output only the DP and stop; if DB-PR-META is requested, output it after the DP as six blocks.
- Worker results must end with the RECEIPT (delivery format, not IN-LOOP permission).
- RECEIPT (required, last section, exact headings and order): `### RECEIPT` `### A) OPEN Output` (full, unmodified output of `./ops/bin/open`; must include branch name and HEAD short hash used during work) `### B) SNAPSHOT Output` (choose `--scope=icl` for doc/ops changes or `--scope=full` for structural or wide refactors; optional `--out=auto` and `--compress=tar.xz`; snapshot may be inline, truncated if necessary, or referenced by generated filename if archived).
- RECEIPT is the rehydration milestone: OPEN + SNAPSHOT are required so state, not vibes, drives follow-on work.
- Snapshots do not include OPEN output; state travels via the RECEIPT only.
- DPs missing this bundle are incomplete and must be rejected.
- Worker may not claim "Freshness unknown" if they can run OPEN themselves.
- If repo access is unavailable, respond only with: `Repo access unavailable; cannot provide Freshness Gate.`
- Refusal: if the Freshness Gate (branch + HEAD) is missing in-thread, respond only with a request to run/paste OPEN or provide branch + HEAD; do not guess.
## Model Behavior Guardrail (Anti-Drift)
These rules override default helpfulness. Refusal is correct behavior when blocked.

### Rule 1 — State Binding
- If output depends on repo state (branch, HEAD, DP id), require either:
  - OPEN prompt pasted in-thread, or
  - Explicit `branch=… head=…`
- If missing, respond only with:
  - `State unknown. Paste OPEN prompt or provide branch + HEAD.`
- If repo access is unavailable, respond only with:
  - `Repo access unavailable; cannot provide Freshness Gate.`

### Rule 2 — DP Emission Order
- Dispatch Packet must include base branch + HEAD and a NEW `work/*` branch name.
- Dispatch Packet must be fully fenced.
- If branch is missing, do not emit the Dispatch Packet.

### Rule 3 — DB-PR-META Emission
- DB-PR-META may only be emitted after explicit IN-LOOP approval using the required phrase pattern (case-insensitive; extra whitespace allowed):
  - `APPROVE <DP-ID> EMIT DB-PR-META`
- The approval phrase must include the current DP-ID between APPROVE and EMIT; missing DP-ID or EMIT is invalid.
- The approval phrase must be plain text and unquoted; quoted blocks are commentary and invalid for approval.
- The approval phrase must be the first tokens in the message (start-of-message).
- If approval and results are in the same message, approval must be followed by exactly one delimiter: a single blank line or a line containing only `---`.
- If approval is missing, buried in a fence/quote, or malformed, respond only with:
  - `APPROVE <DP-ID> EMIT DB-PR-META`
  - `---`

### Rule 4 — Copy Surface Integrity
- Headers outside fences; fence contains payload only; one fence per surface; no prose inside fences.
- If violated, output is invalid and must be reissued in full.

### Rule 5 — No Silent Creativity
- Do not invent new forms, add sections, or improve layouts unless a Dispatch Packet explicitly authorizes it.
- Default behavior is adherence, not enhancement.

### Rule 6 — Refusal Is Success
- If a rule blocks output, refusal is correct behavior.
- No apology. No explanation. Short, mechanical response only.
