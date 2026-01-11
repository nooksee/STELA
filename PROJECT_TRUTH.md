# Project Truth — PHP-Nuke CE

If something conflicts with this file, this file wins.

## Identity
PHP-Nuke CE is a curated continuation of the PHP-Nuke lineage. It is not a rewrite and not a fork-dump.

## Upstream
Historical upstream: php-nuke/php-nuke. Upstream code is pulled intentionally and reviewed explicitly.

## Donor code
Titanium, Evo, Sentinel, and other derivatives are donor banks. We extract specific features and re-implement them with clear provenance.

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
