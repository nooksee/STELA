# Quickstart (Stela)

This repo is governed. The fastest way to succeed here is to follow the rules *exactly*.

## First steps (read in this order)
1) `TRUTH.md` (Filing Doctrine + Constitution + Structure/Map)
2) `SoP.md`
3) `TASK.md`
4) `docs/INDEX.md`
5) `docs/library/OPERATOR_MANUAL.md`

## Workflow doctrine (non-negotiable)
- One slice per PR.
- Green checks before merge (repo-gates).
- Metadata Surfaces (always-on): Purpose / What shipped / Verification / Risk+Rollback.
- If there’s a PR, there’s a `SoP.md` entry.

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
- `ci: enforce SoP update when canon changes`

## Where things live (mental model)
- `main` = the locked classroom whiteboard
- `work/*` = your notebook
- `docs/` = project manual that points into ops canon
- `ops/` = system operations
- `.github/` = governance (repo-gates, PR templates, Copilot instructions)

## NetBeans-only comfort path (no terminal required)
- **Status / Diff:** Team → Git → Show Changes
- **Commit:** Team → Commit…
- **Push:** Team → Remote → Push…
- **Pull:** Team → Remote → Pull…

If anything feels risky: stop and re-read `TRUTH.md` and `SoP.md`. `SoP.md` shows what shipped most recently.
