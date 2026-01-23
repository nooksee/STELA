# Contractor Brief Template (CANON) - Stela

Purpose: produce a paste-ready briefing for a Junior Implementer (Copilot/Codex/Gemini)
that results in a small, reviewable, doc-first PR slice.

This template is canon. If an AI output deviates, correct it back into this shape.

---

## A) What/Why (Explainer - max 8 lines)
- Repo state date: YYYY-MM-DD
- Canon sources used (exact files): <file1>, <file2>, <file3>
- Objective (1 sentence):
- Primary file(s) touched (exact paths):
- Secondary file(s) touched (only if canon law requires it):
- Risk level: Low/Med/High + why
- Drift prevention: (how this reduces future confusion)
- Verification: (NetBeans + repo-gates + any local scripts)

---

## B) COPY/PASTE (verbatim)

```text
COPY EVERYTHING BETWEEN THE LINES
------------------------------------------------------------

Contractor Briefing: Task [T-___] - <Short title>

ROLE
You are a Junior Implementer. You do NOT merge. You propose a small PR slice.

REPO RULES (NON-NEGOTIABLE)
- No direct pushes to `main`.
- Work happens only on `work/<topic>-YYYY-MM-DD`.
- PR-only merges; repo-gates must pass.
- No invention: do not add paths/files/claims not supported by canon.
- Do not modify files inside `upstream/` (read-only donor bank).
- Do not modify files inside `.github/` unless explicitly instructed.
- If canon/governance truth docs are impacted, update `SoP.md` in the same PR.

SCOPE (touch only these files)
- <path/to/file1>
- <path/to/file2>

MUST NOT TOUCH
- `public_html/` (unless explicitly instructed)
- `upstream/` (any files)
- `.github/` (any files)

TASK STEPS
1) Sync: pull latest `main` (do not edit on it).
2) Branch: create `work/<topic>-YYYY-MM-DD`.
3) Make the edit(s) exactly as described below:
   - <bullet 1>
   - <bullet 2>
4) Verify visually in NetBeans (Team -> Show Changes).
5) Run required local checks (if any): <command(s)>
6) Do not commit or push; deliver working tree diff only.
7) Operator commits/pushes after review.

OUTPUT REQUIRED (you must return these)
- Unified diff only (no prose inside diff).
- PR description (short).
- Verification checklist:
  [ ] Branch name correct
  [ ] Only scoped files changed
  [ ] No changes to forbidden zones
  [ ] repo-gates pass
  [ ] Worker did NOT commit/push (operator will handle)

------------------------------------------------------------
```

STOP COPYING
