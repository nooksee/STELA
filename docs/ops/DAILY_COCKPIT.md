# Daily Cockpit — YYYY-MM-DD

This file is your daily operating plan + notes. It’s meant to be *pleasant to read* and *useful at a glance*.

---

## Canon vs Log (read this once, then ignore it)

**Canon = repo truth.**  
Anything that must remain true for the project lives in canonical docs (ex: `PROJECT_TRUTH.md`, `PROJECT_MAP.md`, `STATE_OF_PLAY.md`, `docs/00-INDEX.md`, governance/release docs, etc.). If canon changes, it should be reflected in those files and (when required) in `STATE_OF_PLAY.md` **in the same PR**.

**Log = today’s plan + diary.**  
This `DAILY_COCKPIT.md` is allowed to be emotional, tactical, messy, and time-bound. It can mention ideas, experiments, and “what we did today,” but it should **not be the only place** a permanent truth exists.

**Rehydration ≠ Log.**  
- **Rehydration** = onboarding an AI/contractor back into *canon* using `docs/ops/AI_CONTEXT_SYNC.md` + `docs/ops/CONTEXT_PACK.md` (optional but powerful).  
- **Daily Cockpit** = your daily runbook + notes (always allowed; never the single source of truth).

---

## Non-negotiables (repo truth)

- **No direct pushes to `main`. Ever.**
- Work happens on **`work/<topic>-YYYY-MM-DD`** branches.
- **PR-only merges.**
- **repo-gates must be green** before merge.
- If a change affects canon/governance docs, **update `STATE_OF_PLAY.md` in the same PR**.

---

## Today’s intent (one sentence)

> _What is the one outcome that matters today?_  
- Intent:

---

## Quick status check (2 minutes)

- Current branch:
- Uncommitted changes? (yes/no)
- Any open PRs needing review/merge?
- repo-gates status (last run):
- “Anxiety level” check (0–10):  
  - If >6: reduce scope; smallest safe PR slice only.

---

## Start work (safe sequence)

1) **Sync**
- Pull latest `main` (no edits on main)
- Confirm branch protection mindset: PR-only

2) **Create branch**
- New branch name: `work/<topic>-YYYY-MM-DD`

3) **Open in NetBeans (Truth Cockpit)**
- Review-first mindset: tree + diffs + intent match

4) **Choose a PR slice (small + boring)**
- One purpose, minimal files, easy to review

---

## AI usage (bounded roles)

**Copilot (VS Code) = Junior Implementer / Drafter**
- Draft diffs, small PR slices, propose edits
- Output should include: summary, files touched, risks/collisions, suggested PR title

**Gemini (optional) = Librarian / Impact Analyst**
- Find call sites, collisions, hidden dependencies
- Produces risk list + safest path

**You (NetBeans) = Integrator / Gatekeeper**
- Decide what ships
- Visual review + PR discipline

---

## Work plan (ordered)

1.
2.
3.

---

## Changes made (what actually happened)

### PR Slice A (name it)
- Goal:
- Files touched:
- Notes:
- Risks/collisions spotted:

### PR Slice B (if any)
- Goal:
- Files touched:
- Notes:
- Risks/collisions spotted:

---

## Review checklist (before commit)

In NetBeans:
- Team → Show Changes (do changes match intent?)
- No drive-by refactors
- No accidental IDE/private metadata added

Sanity:
- Does this change require a `STATE_OF_PLAY.md` update?
- Are filenames/paths consistent with canon?
- Are we accidentally editing donor snapshots in `upstream/`? (should be read-only)

---

## Commit + PR (the only way)

- Commit message (boring is good):
- Push branch:
- Open PR:
- Wait for **repo-gates**:
- Merge only when green:

---

## Notes / decisions (today-only is fine)

- Decision:
- Why:
- Follow-up:

---

## “Nooksee news” (daily log vibe ✅)

- What surprised me:
- What felt good:
- What felt sketchy:
- What I learned:

---

## Next steps (tomorrow’s runway)

1.
2.
3.

---

## Contractor / Copilot reminder (un-losable)

If anyone besides “you-in-NetBeans” is touching work:
- **Prepare a contractor/AI briefing** (scope, rules, PR slice, definition of done)
- Ensure they reference canon (`PROJECT_TRUTH.md`, `PROJECT_MAP.md`, `docs/00-INDEX.md`)
- Enforce: `work/*` branches + PR-only + repo-gates
