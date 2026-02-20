<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/lib/scripts/ledger.sh` preserves PoT.md Section 1.2 role separation for SoP and PoW by enforcing prune-time proof integrity before archival. The script exists because direct pruning or freeform ledger rewrites can erase receipt links, which violates SSOT evidence continuity and makes historical entries non-auditable.

## Mechanics and Sequencing
1. `ledger_entry_count` counts dated entry headings (`## YYYY-MM-DD ...`) in a target ledger.
2. `ledger_archive_plan` computes month-bucket archive targets for entries beyond `THRESHOLD` and emits an archive plan report.
3. `validate_pow_prune_candidates` parses PoW entries beyond threshold and enforces required fields plus receipt pointers for `RESULTS`, `OPEN`, and `DUMP`.
4. Pointer validation normalizes paths and enforces target shapes (`storage/handoff/*-RESULTS.md`, `storage/handoff/OPEN-*`, `storage/dumps/dump-*`), then verifies each target exists, is tracked, and has no staged or unstaged diff.
5. `ledger_extract_candidates` emits normalized pointer triplets for prunable PoW entries, keyed by entry index.
6. `ledger_prune_surface` splits retained and archived blocks by threshold cut-line, writes retained content back to the source ledger, writes archived blocks into monthly archive files, and prints summary lines.

## Anecdotal Anchor
PoW entry `2026-02-19 17:43:26 UTC — DP-OPS-0075 Administrative Closeout and Prune Guard Hardening` records prune-guard work that blocked deletion when uncommitted receipt artifacts were still present. That incident sits in the same failure class this script defends against: malformed or weakly validated ledger edits can sever proof pointers and break context hydration.

## Integrity Filter Warnings
- The script assumes caller context provides `REPO_ROOT`; default path expansions fail if that variable is unset.
- Threshold pruning assumes entry order is newest-first; noncanonical ordering causes incorrect retention and archival grouping.
- The prune flow writes keep/archive outputs in multiple filesystem steps without rollback semantics.
- Pointer-shape validation is strict; historical entries with legacy pointer formats will block prune until normalized.
