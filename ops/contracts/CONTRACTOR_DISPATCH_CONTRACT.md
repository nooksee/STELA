# Contractor Dispatch Contract

## Purpose
Define dispatch rules for worker assignments.

## Scope
Applies to contractor briefs and worker tasks.

## Requirements
- Work happens only on `work/*` branches; no direct pushes to `main`.
- PR-only merges; repo-gates must be green before merge.
- `SoP.md` must be updated when canon/governance changes (same PR).
- Metadata surfaces are required for every PR: Purpose / What shipped / Scope / Verification / Risk+Rollback / Canon updates.
- Worker delivers changes as a working tree diff only. Operator handles commit/push/merge.

## Dispatch shape (required)
1) Purpose - one sentence.
2) What shipped - bullet list of file-level changes.
3) Scope - exact paths/files touched.
4) Verification - repo-gates + any manual checks.
5) Risk+Rollback - risk statement + rollback plan.
6) Canon updates - note any doctrine/governance updates.

## Verification
- Not run (operator): align with current dispatch policies.

## Risk+Rollback
- Risk: inconsistent dispatch expectations.
- Rollback: restore prior contract language.

## Canon Links
- ops/contracts/OUTPUT_FORMAT_CONTRACT.md
- ops/templates/CONTRACTOR_BRIEF_TEMPLATE.md
- ops/templates/CONTRACTOR_REPORT_TEMPLATE.md
