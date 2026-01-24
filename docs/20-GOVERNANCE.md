# Governance (how Stela stays coherent)

This project is built to resist drift. Governance is not “process theater” — it is the product.

## Non-negotiables
- **No direct pushes to `main`.** Work happens on `work/*` branches → PRs → merge.
- **repo-gates must pass.** If gates fail, we fix gates or the change — not the rules.
- **Truth-Layer is authoritative.** When in doubt, Truth-Layer wins.

## Truth-Layer (source of truth)
Authoritative docs (kept correct at all times):
- `TRUTH.md`
- `TRUTH.md Section 3`
- `SoP.md`
- `TRUTH.md Section 2`
- `docs/00-INDEX.md` (front door)

Rule: if canon changes, **SoP must be updated** (same PR when possible).

## Branch naming
`work/<topic>-YYYY-MM-DD`

Examples:
- `work/docs-canon-coherency-2026-01-01`
- `work/state-of-play-policing-2026-01-02`

## Pull Requests
A PR should be:
- single-purpose
- reviewable in NetBeans
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
- the Truth-Layer read order
- the “single deliverable PR” for the day
- strict instruction: no direct pushes to main, provide commands in small safe chunks

## Tone lanes (prevents "AI slop")
- Ops lane (allowed to be checklist-heavy): `ops/` and `docs/ops/INDEX.md` (pointer only)
- Public-facing lane (must stay human): root README, founders docs

We prefer: clear, explain-first, minimal filler.
