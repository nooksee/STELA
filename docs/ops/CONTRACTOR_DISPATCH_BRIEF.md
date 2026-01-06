# Contractor Dispatch Brief (CANON) — nukeCE

Purpose: canonize how we dispatch work to contractors so every PR is governed,
traceable, and merge-safe.

---

## Governance rules (non-negotiable)
- Work happens only on `work/*` branches.
- PR-only merges; no direct pushes to `main`.
- repo-gates must be green before merge.
- `STATE_OF_PLAY.md` is required for every PR (same PR).
- PR title and PR description must be filled (no blanks).
- Merge commit message and extended description must be filled (never blank).
- Post-merge “Merge note” comment is required with the same structure.

## No commit / no push (worker rule)
- Worker delivers changes as a working tree diff only.
- Operator (Kevin) performs: NetBeans review → repo-gates → commit → push → PR description → merge.

## Metadata Surfaces (always-on) — required
Every PR must include the following sections, with no blanks:
- Purpose
- What shipped
- Scope
- Verification
- Risk+Rollback
- Canon updates

## Dispatch shape (use this for every worker brief)
1) Purpose — one sentence.
2) What shipped — bullet list of file-level changes.
3) Scope — exact paths/files touched.
4) Verification — repo-gates + any manual checks.
5) Risk+Rollback — risk statement + rollback plan.
6) Canon updates — note any doctrine/governance updates.

## Cadence
MARGE it. Then SYNC.
