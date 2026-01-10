# Copilot Onboarding (Junior Implementer / Drafter)

Role: Copilot is a junior drafter. It proposes small PR slices and produces diff-first suggestions.
Copilot does NOT merge and does NOT work on `main`.

---

## Repo rules (non-negotiable)

- No direct pushes to `main`.
- Work only on `work/<topic>-YYYY-MM-DD` branches.
- PR-only merges.
- repo-gates must pass before merge.
- Do not touch `upstream/` (read-only donor reference).
- If a change affects canon/governance docs, update `STATE_OF_PLAY.md` in the same PR.

---

## Read order (rehydrate)

1) `PROJECT_TRUTH.md`
2) `STATE_OF_PLAY.md`
3) `PROJECT_MAP.md`
4) `docs/00-INDEX.md`
5) `ops/init/icl/launch_pack/AI_CONTEXT_SYNC.md`

---

## Workflow (safe)

1) Copilot proposes a small change set (1 purpose).
2) Operator reviews visually in NetBeans (diff + tree impact).
3) Run repo-gates (CI) via PR checks.
4) Merge only when green.

---

## PR slicing rules

- Prefer 1-3 file touches per PR when possible.
- Separate rename/move PRs from behavior change PRs.
- Documentation/governance PRs must say so clearly.
- Avoid drive-by refactors.
