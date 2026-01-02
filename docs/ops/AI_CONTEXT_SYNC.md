# AI Context Sync (SSOT “save game”)

> Purpose: a single file Kevin can paste to Copilot/Gemini/ChatGPT to rehydrate context fast.

## Legend
- ✅ shipped today
- ▶️ in progress
- ⏭️ leftover (repeat verbatim until resolved — avoids duplicate search hits)

---

## Date
2026-01-02

## Current deliverable PR
`work/docs-canon-coherency-2026-01-01` → merge into `main`

## What changed (summary)
- ✅ Docs “family v1” integrated + canonical docs spine started
- ▶️ Fill placeholders: `docs/10-QUICKSTART.md`, `docs/20-GOVERNANCE.md`
- ▶️ Add Copilot wall rules: `.github/copilot-instructions.md`
- ▶️ Add strict policing: CI fails if canon changes without `STATE_OF_PLAY.md`

## Repo rules (non-negotiable)
- No direct pushes to `main`
- Work branches only: `work/*`
- PR-only merges
- repo-gates must pass

## Truth-Layer read order
1) `PROJECT_TRUTH.md`
2) `STATE_OF_PLAY.md`
3) `PROJECT_MAP.md`
4) `docs/00-INDEX.md`

## Contractor briefing request phrase
When Kevin says: **“Prepare a briefing for the contractor”**:
- respond with a concise impact-aware summary suitable to paste into Gemini (full-repo auditor)

## Open questions / next decisions
- ⏭️ Decide whether to archive daily cockpits as `docs/ops/log/YYYY-MM-DD.md`
- ⏭️ Decide whether policing carve-outs should include `docs/ops/DAILY_COCKPIT.md`

