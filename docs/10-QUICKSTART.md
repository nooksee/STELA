# Quickstart (nukeCE)

This repo is governed. The fastest way to succeed here is to follow the rules *exactly*.

## First steps (read in this order)
1) `PROJECT_TRUTH.md`
2) `STATE_OF_PLAY.md`
3) `PROJECT_MAP.md`
4) `docs/00-INDEX.md`
5) `ops/init/icl/DAILY_CONSOLE.md`
6) `ops/contracts/CONTRACTOR_DISPATCH_CONTRACT.md`

## Workflow doctrine (non-negotiable)
- One slice per PR.
- Green checks before merge (repo-gates).
- Metadata Surfaces (always-on): Purpose / What shipped / Verification / Risk+Rollback.
- If there’s a PR, there’s a `STATE_OF_PLAY.md` entry.

## The only workflow we use (PR-only)
**Rule:** No direct pushes to `main`. Ever.

1) **Start clean**: check Git Status (NetBeans) — you want “nothing to commit”.
2) **Create a work branch**: `work/<topic>-YYYY-MM-DD`
3) **Edit** in NetBeans.
4) **Review changes** (diff) in NetBeans.
5) **Commit** (small, descriptive message).
6) **Push** your branch.
7) **Open PR** → repo-gates ✅ → merge → delete branch.

## Commit message style
Use a simple prefix:
- `docs:` documentation changes
- `ci:` workflow / repo-gates changes
- `chore:` housekeeping
- `feat:` new feature
- `fix:` bug fix

Examples:
- `docs: add governance + quickstart`
- `ci: enforce STATE_OF_PLAY update when canon changes`

## Where things live (mental model)
- `main` = the locked classroom whiteboard
- `work/*` = your notebook
- `docs/` = project manual that points into ops canon
- `ops/` = ICL/OCL canon (protocols, contracts, templates, continuity core)
- `ops/init/icl/` = rehydration + ICL Continuity Core (stateless continuity surface)
- `.github/` = governance (repo-gates, PR templates, Copilot instructions)

## NetBeans-only comfort path (no terminal required)
- **Status / Diff:** Team → Git → Show Changes
- **Commit:** Team → Commit…
- **Push:** Team → Remote → Push…
- **Pull:** Team → Remote → Pull…

If anything feels risky: stop and read `STATE_OF_PLAY.md` again. That file is the truth of “what’s real today”.
