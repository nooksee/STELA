# Project Truth — PHP-Nuke CE

If something conflicts with this file, this file wins.

## Identity
PHP-Nuke CE is a curated continuation of the PHP-Nuke lineage. It is not a rewrite and not a fork-dump.

## Upstream
Historical upstream: php-nuke/php-nuke. Upstream code is pulled intentionally and reviewed explicitly.

## Donor code
Titanium, Evo, Sentinel, and other derivatives are donor banks. We extract specific features and re-implement them with clear provenance.

## Tooling inspiration
- Snapshot tool inspired by repo2txt (MIT); reimplemented in-repo with no upstream code copied.

## Runtime hygiene
public_html is the deployable webroot. It must not contain archive snapshots, legacy graveyards, or development artifacts.

## Philosophy
Secure by default. Explainable operations. Auditable administration. Confidence over cleverness.

## Minimum Operator Effort
- Do not ask the operator to open/edit files unless the operator explicitly opts in.
- Workers draft diffs; integrator/operator reviews, commits, and opens PRs.
- Prefer "run command X" over "open file Y and edit line Z."
- Prefer front door scripts (`ops/bin/open`, `ops/bin/close`) over control words.
- If the operator says "merged + synced main", do not re-explain workflow.
- Proceed to the next agreed step or handle the reported errors.
- Do not ask questions you can answer from git state (branch already known).

## Focus Rule (Operator-Led Flow)
- If the operator says "merged + synced main", do not re-explain workflow.
- Proceed to the next agreed step or handle the reported errors.
- Do not ask questions you can answer from git state (branch already known).

## Docs Library Policy (Curated Surface)
- The docs library is the approved operator-facing surface. `ops/bin/help` only reads from `docs/library/LIBRARY_INDEX.md`.
- Nearly any change that ships (scripts, protocols, behavior rules) must add or update a docs library entry.
- The library is curated; do not list every .md. If it is not in the manifest, help will refuse to open it.

## DB-DATASET (Curated Dataset Library)
- DB-DATASET is the manifest-only dataset library for "mode training" and standards.
- Datasets are docs-only entries under `docs/library/datasets/`, listed in `docs/library/LIBRARY_INDEX.md`.
- No runtime behavior is implied; datasets are references only.

## Labels
- IN-LOOP: human-required step / explicit approval gate.

## Output Mechanics Contract
- Dispatch Packet (DP) output comes first whenever a DP is requested.
- DP must be a single fenced block containing: Freshness Gate, required NEW work branch (when changes are requested), Purpose, Scope, Files, Forbidden, Verification, Acceptance.
- DB-PR-META is only emitted when explicitly requested (e.g., "db-pr-meta", "yes please").
- DB-PR-META must be six separate copy blocks, each with a header line above the fence; each fence contains only the payload for that surface.
- Ordering: if the operator says "DP first", output only the DP and stop; if DB-PR-META is requested, output it after the DP as six blocks.
- Worker results must end with an After-Action Bundle (delivery format, not IN-LOOP permission).
- After-Action Bundle (required, last section, exact headings and order): `### After-Action Bundle` `### A) OPEN Output` (full, unmodified output of `./ops/bin/open`; must include branch name and HEAD short hash used during work) `### B) SNAPSHOT Output` (choose `--scope=icl` for doc/ops changes or `--scope=full` for structural or wide refactors; optional `--out=auto` and `--compress=tar.xz`; snapshot may be inline, truncated if necessary, or referenced by generated filename if archived).
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
- DB-PR-META may only be emitted after explicit approval with:
  - `I approve — DB-PR-META for <context>`
- If approval is missing, respond only with:
  - `Approval not given. DB-PR-META withheld.`

### Rule 4 — Copy Surface Integrity
- Headers outside fences; fence contains payload only; one fence per surface; no prose inside fences.
- If violated, output is invalid and must be reissued in full.

### Rule 5 — No Silent Creativity
- Do not invent new forms, add sections, or improve layouts unless a Dispatch Packet explicitly authorizes it.
- Default behavior is adherence, not enhancement.

### Rule 6 — Refusal Is Success
- If a rule blocks output, refusal is correct behavior.
- No apology. No explanation. Short, mechanical response only.
