# Contributing to Stela

Welcome. You’re allowed to be clever here — but you must also be **traceable**. 😄

Source of truth for onboarding and workflow: `docs/QUICKSTART.md`.

## Non-negotiables
- **No direct pushes to `main`.** Ever.
- Work happens on **`work/*` branches** only.
- Every PR must pass **repo-gates**.

## Security policy
See `SECURITY.md` for reporting guidance and security posture.
Do not commit secrets to the repo.

## The standard workflow (IDE-first)
1) Create a branch
- Name format: `work/<topic>-YYYY-MM-DD`
- Examples:
  - `work/readme-philosophy-2025-12-31`
  - `work/docs-stylize-2025-12-31`

2) Make changes (small batches)
- Prefer small, reviewable PRs.
- Keep “drive-by refactors” out of unrelated changes.

3) Review changes visually
- In IDE: **Team → Show Changes**
- Sanity-check: do the changes match the intent?

4) Commit
- Use clear, boring commit messages. Boring is good.
  - `docs: expand development philosophy`
  - `chore: ignore IDE private settings`

5) Push + PR
- Push your `work/*` branch
- Open PR
- Wait for **repo-gates** ✅
- Merge

## Repo hygiene (IDE metadata)
Do not commit private IDE settings:
- `nbproject/private/*` should be ignored
- If you ever accidentally tracked it, remove from index:
  - `git rm --cached -r nbproject/private`

## Provenance expectations
If you import or adapt external code:
- Add notes in `docs/UPSTREAMS.md` (or the appropriate truth-layer doc)
- Include: source, purpose, what changed, and any known risks/limits

## Using Codex (approved “junior contractor” mode)
Codex may draft changes **only** on `work/*` branches.
A human (Operator) reviews visually in an IDE before merging.
Repo-gates must pass. PR-only merges. No exceptions.
