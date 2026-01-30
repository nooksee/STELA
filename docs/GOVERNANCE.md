# Governance (how Stela stays coherent)

This project is built to resist drift.
Governance is not “process theater” — it is the product.

## Non-negotiables
- **No direct pushes to `main`.** Work happens on `work/*` branches → PRs → merge.
- **repo-gates must pass.** If gates fail, we fix gates or the change — not the rules.
- **Canon surfaces are authoritative.** When in doubt, `TRUTH.md` wins.

## Canon surfaces (source of truth)
Authoritative docs (kept correct at all times):
- `TRUTH.md` — constitution + filing doctrine + structure/map (SSOT).
- `TASK.md` — DP contract + living work surface/log (SSOT for current thread).
- `SoP.md` — history ledger only (what shipped, when, why).
- `AGENTS.md` — jurisdiction definitions and behavioral logic standards.
- `llms.txt` — discovery entry point for AI agents (pointer-first).
- `docs/INDEX.md` — front door to the manual.
- `docs/library/MANUAL.md` — operator mechanics; pointer-only.

Rule: if canon changes, **SoP must be updated** (same PR when possible).

## Branch naming
`work/<topic>-YYYY-MM-DD`

## Staffing Protocol
All work follows the jurisdictional boundaries defined in `AGENTS.md`:
- **Operator (Human):** Final authority for approvals, commits, and secrets.
- **Integrator (Lead AI):** Guardian of governance and structural integrity.
- **Contractor (Guest AI):** Execution arm for logic, implementation, and drafting.

## AI Contractors
- All AI agents and contractors operate under the logic-first parameters defined in `AGENTS.md`.
- **Execution Rule:** No logic changes shall be proposed without an active Dispatch Packet (DP) as defined in `TASK.md`.

## Tone lanes (prevents "AI slop")
- Ops lane (checklist-heavy): `ops/` and `docs/ops/INDEX.md` (pointer only).
- Public-facing lane (human-centric): root README, founders docs.

We prefer: clear, explain-first, minimal filler.