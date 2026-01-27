# Governance (how Stela stays coherent)

This project is built to resist drift. Governance is not “process theater” — it is the product.

## Non-negotiables
- **No direct pushes to `main`.** Work happens on `work/*` branches → PRs → merge.
- **repo-gates must pass.** If gates fail, we fix gates or the change — not the rules.
- **Canon surfaces are authoritative.** When in doubt, `TRUTH.md` wins.

## Canon surfaces (source of truth)
Authoritative docs (kept correct at all times):
- `TRUTH.md` (constitution + filing doctrine + structure/map)
- `TASK.md` (DP contract + living work surface/log)
- `SoP.md` (history ledger)
- `docs/INDEX.md` (front door)
- `docs/library/OPERATOR_MANUAL.md` (operator mechanics; pointer-only)

Rule: if canon changes, **SoP must be updated** (same PR when possible).

## Branch naming
`work/<topic>-YYYY-MM-DD`

Examples:
- `work/docs-canon-coherency-2026-01-01`
- `work/state-of-play-policing-2026-01-02`

## Pull Requests
A PR should be:
- single-purpose
- reviewable in an IDE
- mergeable with repo-gates green

Recommended PR description:
- What changed
- Why
- Any follow-ups (explicit)

## Contractors (humans + AI)
All contractors operate under Integrator governance:
- they propose
- the Integrator reviews
- changes ship only via PR + repo-gates

AI contractors should be given:
- the canon read order (`TRUTH.md`, `SoP.md`, `TASK.md`, `docs/INDEX.md`, `docs/library/OPERATOR_MANUAL.md`)
- the “single deliverable PR” for the day
- strict instruction: no direct pushes to main, provide commands in small safe chunks

## Tone lanes (prevents "AI slop")
- Ops lane (allowed to be checklist-heavy): `ops/` and `docs/ops/INDEX.md` (pointer only)
- Public-facing lane (must stay human): root README, founders docs

We prefer: clear, explain-first, minimal filler.
