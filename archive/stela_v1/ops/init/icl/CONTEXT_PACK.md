# nukeCE Context Pack (Recovery Card)

This file is the canonical read-in for anyone (Integrator, contractor, Codex) joining midstream.
If a chat blows up, a laptop dies, or context is missing: start here.

---

## Prime directive
- **No direct pushes to `main`.**
- Work happens on `work/*` -> PR -> **repo-gates green** -> merge.
- Prefer **NetBeans-first** workflow. Terminal is allowed, but used carefully.

---

## Repo gates
Required checks (PR):
- `repo-gates / gates (pull_request)`

Local helpers:
- `bash tools/verify_tree.sh`
- `bash tools/repo/lint_truth.sh`

---

## Roles

### Integrator (you / senior operator)
- Keeps changes small and reviewable
- Enforces PR-only + gates
- Updates canon docs when process changes (ops + SOPs)
- Never merges red checks

### Contractor / Codex (junior contractor)
- Works only on `work/*`
- Submits PRs only (no merges)
- Makes minimal, scoped changes
- Adds provenance notes when importing/adapting anything

---

## NetBeans-first operating rhythm
1) **Confirm branch** (top-left project title): should NOT be `main` while editing.
2) **Team -> Show Changes**: review diffs before commit
3) **Team -> Commit...**
4) **Team -> Remote -> Push...** (push ONLY the current `work/*` branch)
5) Open PR -> wait for gates -> merge

Terminal safety:
- Prefer typing commands (avoid paste surprises)
- If a command runs long, do not spam Enter

---

## Current canon snapshot
- Upstream snapshots remain read-only under `upstream/`
- Authored surfaces: `docs/`, `ops/`, `tools/`, `.github/`, selected root docs
- "Corporate clean" rule: no personal names, machine names, or local absolute paths in public docs.

---

## Active focus (update this as the project evolves)
- [ ] ops docs are canonical and clean
- [ ] PR workflow enforced
- [ ] contractor packet stays current
- [ ] nbproject/private remains local-only (do not commit)

---

## Start-here checklist (when context is missing)
- What branch am I on?
- Do I have uncommitted changes?
- Is there an open PR? Is repo-gates green?
- If anything is unclear: stop and open `ops/init/icl/DAILY_CONSOLE.md`
- If repo context is still missing, run `./ops/bin/snapshot --scope=icl --format=chatgpt`.

---

## "Recovery prompt" (paste into any new chat)
You are the Integrator for the nukeCE repo.
Read `ops/init/icl/CONTEXT_PACK.md` first, then ask me:
1) current branch name
2) Team -> Show Changes summary
3) link to current PR (if any)
Then guide me NetBeans-first: commit -> push -> PR -> gates -> merge.
