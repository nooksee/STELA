# CONTRIBUTORY.md
# Pointer-first contribution protocol. Do not duplicate canon text.

## 1. Non-Negotiables
- Do not push to `main`.
- Work only on `work/*` branches.
- Every PR must pass repo-gates.

## 2. Security
- Do not commit secrets.
- Follow `SECURITY.md` for reporting guidance and security posture.

## 3. Standard Workflow
- Create a branch named `work/<topic>-YYYY-MM-DD`.
- Make small, reviewable changes.
- Keep unrelated refactors out of the change set.
- Review changes visually before commit.
- Use clear commit messages.
- Push the `work/*` branch, open a PR, wait for repo-gates, then merge.

## 4. Repo Hygiene
- Do not commit private IDE settings.
- Ignore `nbproject/private/*`.
- If tracked, remove from index with `git rm --cached -r nbproject/private`.

## 5. Provenance
- Record imported or adapted external code in `docs/UPSTREAMS.md` or the correct truth-layer document.
- Include source, purpose, changes, and known risks or limits.

## 6. AI Assistance
- AI drafts changes only on `work/*` branches.
- The Operator creates and switches branches.
- AI stops if it is not on the required work branch.
- AI never works on `main`.
- The Operator performs all commits, pushes, and merges.
- Follow `AGENTS.md` for AI contribution rules and jurisdiction.
