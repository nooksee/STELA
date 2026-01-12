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

## Output Mechanics Contract
- Dispatch Packet (DP) output comes first whenever a DP is requested.
- DP must be a single fenced block containing: Freshness Gate, required NEW work branch (when changes are requested), Purpose, Scope, Files, Forbidden, Verification, Acceptance.
- Metadata Kit v1 is only emitted when explicitly requested (e.g., "metakit", "yes please").
- Metadata Kit v1 must be six separate copy blocks, each with a header line above the fence; each fence contains only the payload for that surface.
- Ordering: if the operator says "DP first", output only the DP and stop; if Metadata Kit v1 is requested, output it after the DP as six blocks.
- Refusal: if the Freshness Gate (branch + HEAD) is missing in-thread, respond only with a request to run/paste OPEN or provide branch + HEAD; do not guess.
