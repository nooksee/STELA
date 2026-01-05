## 2026-01-05 — Docs: contractor dispatch brief (canonize worker dispatch)

- Purpose: Canonize contractor dispatch rules so every PR follows governance + metadata requirements.
- What shipped:
  - Added `docs/ops/CONTRACTOR_DISPATCH_BRIEF.md` to formalize dispatch rules and cadence.
  - Linked the new brief from `docs/ops/INDEX.md` and `docs/00-INDEX.md`.
- Verification:
  - repo-gates ✅
  - state-of-play-policing ✅
- Risk / rollback:
  - Risk: docs-only (no runtime behavior changes)
  - Rollback: revert merge commit

## 2026-01-04 — Docs: Guerrilla Metadata Surfaces (always-on)

- Purpose: Make every PR self-documenting; no blank metadata fields.
- What shipped:
  - Codified “Guerrilla Metadata Surfaces (always-on)” in `docs/triage/INBOX.md`
  - Standardized default Markdown structure: Purpose / What shipped / Verification / Risk+Rollback
- Verification:
  - repo-gates ✅
  - state-of-play-policing ✅
- Risk / rollback:
  - Risk: docs-only (no runtime behavior changes)
  - Rollback: revert merge commit

## 2026-01-04 — Docs: INBOX pinned doctrine placement

- Purpose: Keep `docs/triage/INBOX.md` readable (template + pinned rules + inbox list).
- What shipped:
  - Moved “Pinned doctrine: Guerrilla Metadata Surfaces (always-on)” above the Inbox items section.
- Verification:
  - repo-gates ✅
  - state-of-play-policing ✅
  - Manual: INBOX reads top-to-bottom cleanly (template → pinned doctrine → inbox list)
- Risk / rollback:
  - Risk: docs-only (no runtime behavior changes)
  - Rollback: revert this PR’s merge commit

## 2026-01-04

### Completed
- Added GitHub PR description automation via `.github/pull_request_template.md`.
- Added canonical PR description template: `docs/ops/PR_DESCRIPTION_TEMPLATE.md`.
- Added triage capture lane: `docs/triage/INBOX.md`.
- Updated docs indexes to keep ops + triage discoverable.

### Notes / Decisions
- Doctrine: “Every PR is self-documenting and nothing gets forgotten.”
- Forward-only metadata discipline: we don’t backfill old PR bodies unless it’s actively hurting us.

# State of Play — 2026-01-03

## Completed
- Docs Family v1 integrated + canon spine created (docs/00-INDEX, 10-QUICKSTART, 20-GOVERNANCE, 30-RELEASE_PROCESS, 40-PROJECT_HYGIENE)
- Added Copilot onboarding rules: .github/copilot-instructions.md
- Added SSOT “save-game” handover file: docs/ops/AI_CONTEXT_SYNC.md
- Enabled FAIL-mode policing: canon changes require STATE_OF_PLAY update in the same PR
- Updated docs/ops/DAILY_COCKPIT.md to clarify canon vs log vs rehydration.
- Added ops governance docs: OUTPUT_FORMAT_CONTRACT + Copilot onboarding + Gemini onboarding
- Updated docs/ops/INDEX.md + docs/00-INDEX.md to link the new ops docs
- Standardized PROJECT_MAP.md bullets for docs/ops/, upstream/, and .github/workflows/ to clarify roles
- 2026-01-03: Canonized Output Formatting Contract (docs/ops/OUTPUT_FORMAT_CONTRACT.md) and linked it in docs indexes.

## Active blockers
- repo-gates (FAIL-mode) blocking PR until this STATE_OF_PLAY update is committed + pushed

## Next steps (ordered)
1. Save all edited docs in NetBeans
2. Commit updates on current work branch
3. Push branch and re-run repo-gates via PR checks
4. Merge PR once repo-gates are green ✅

## Notes
- This PR is documentation/governance only; no runtime behavior changes intended.
