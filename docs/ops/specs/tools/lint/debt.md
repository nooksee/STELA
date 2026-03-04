<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/debt.sh` exists to stop temporary guard accumulation from becoming silent system drift. It enforces lifecycle metadata for temporary checks and fails when active debt passes the declared removal packet threshold.

## Mechanics and Sequencing
The linter parses `ops/lib/manifests/DEBT.md` and validates row format:
`guard_id|added_in|owner|remove_by_dp|reason|status`.

Validation steps:
1. Require schema and entries sections.
2. Parse entry rows and reject malformed column counts.
3. Validate DP identifiers (`DP-OPS-####`) for `added_in` and `remove_by_dp` on non-sentinel rows.
4. Enforce status values (`active` or `resolved`).
5. Resolve current packet number from active work branch (`work/dp-ops-####-...`) with TASK fallback.
6. Fail when an `active` row has `current_dp > remove_by_dp`.

`--test` runs deterministic fixtures for malformed rows, valid active rows, and stale active rows.
`--list-stale` emits stale row tuples for tooling consumption.

## Anecdotal Anchor
DP-OPS-0149 introduces debt lifecycle hardening after repeated one-off guard additions accumulated without explicit sunset enforcement.

## Integrity Filter Warnings
`tools/lint/debt.sh` exits non-zero on missing registry file, malformed rows, invalid DP identifiers, invalid status values, unresolved current DP context, and stale active rows past `remove_by_dp`. The linter does not mutate registry content.
