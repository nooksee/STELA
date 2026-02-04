# TRUTH.md

## 1. Filing Doctrine
Filing:
- `ops/` = Run (binaries, manifests, automation).
- `docs/` = Explain (manuals and rationale).
- `projects/` = Work (payload code).
- `storage/` = Trash (local artifacts, never canon).

## 2. Axioms (Constitution)
- Precedence: TRUTH is final authority; if conflict exists, stop and ask.
- SSOT: one canonical file per domain; other mentions are pointers.
- Reuse-first: search ops/ for an existing template before creating a new artifact.
- Context Hazard: any inclusion of `docs/library/agents`, `docs/library/tasks`, or `docs/library/skills` in the global context manifest is a failure.
- Drift: any divergence between canon and repository state, or duplication of canon outside SSOT, is a failure state that requires stop and correction.
- SoP: history ledger only; no permanent rules live there.

## 3. Canon Surfaces
- `TRUTH.md` - constitution and invariants.
- `TASK.md` - active work surface and DP contract.
- `SoP.md` - history ledger and shipment record.
- `AGENTS.md` - staffing protocol and behavioral logic.
- `docs/library/MANUAL.md` - operator mechanics.
- `docs/library/MAP.md` - context wayfinding.
- `ops/lib/manifests/CONTEXT.md` - required context set.
- `llms.txt` - discovery entry point.
