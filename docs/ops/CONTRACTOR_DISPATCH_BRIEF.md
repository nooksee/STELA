# Contractor Dispatch Brief (CANON) — nukeCE

Purpose: canonize how we dispatch work to contractors so every PR is governed,
traceable, and merge-safe.

---

## Governance rules (non-negotiable)
- Work happens only on `work/*` branches.
- PR-only merges; no direct pushes to `main`.
- repo-gates must be green before merge.
- `STATE_OF_PLAY.md` is required for every PR (same PR).

## Guerrilla Metadata Surfaces (always-on) — required
Every PR must include the following sections, with no blanks:
- Purpose
- What shipped
- Verification
- Risk+Rollback

## Dispatch shape (use this for every worker brief)
1) Purpose — one sentence.
2) What shipped — bullet list of file-level changes.
3) Verification — repo-gates + any manual checks.
4) Risk+Rollback — risk statement + rollback plan.

## Cadence
MARGE it. Then SYNC.
