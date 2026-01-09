# AI Context Sync (SSOT "save game")

> Purpose: a single file Operator can paste to Copilot/Gemini/ChatGPT to rehydrate context fast.

## Legend
- [NEW] New today
- [KEEP] Carry-over (unchanged; referenced by ID)
- [DONE] Done (move to Completed)
- [BLOCK] Blocker

## Date
2026-01-03

## Rehydration (source of truth)
Any fresh AI can rehydrate from:
1) PROJECT_TRUTH.md
2) STATE_OF_PLAY.md
3) PROJECT_MAP.md
4) docs/00-INDEX.md
...plus this file as the "save game".

Optional: Rehydration drill is a test, not a ritual. Run it only when onboarding a new AI surface or debugging drift.

## Daily cockpit (not the truth ledger)
`ops/init/icl/boot_pack/DAILY_COCKPIT.md` is the operating rhythm checklist.
No project truth should live only in a cockpit. If something becomes policy/structure, promote it into the truth-layer docs above.

## Current deliverable PR
`work/output-format-contract-2026-01-03` -> merge into `main`

## Active items (ID-based)
- [KEEP] [T-002] Thicken PROJECT_MAP.md with: ops/ (canon), upstream/, .github/workflows/ loc_
