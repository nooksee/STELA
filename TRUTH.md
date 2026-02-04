## 1. STELA FILING DOCTRINE
The 4-Line Heuristic:
> 1. Does it RUN the system? -> `ops/` (Binaries, Registry)
> 2. Does it EXPLAIN the system? -> `docs/` (Manuals)
> 3. Is it the WORK itself? -> `projects/` (Code)
> 4. Is it TEMPORARY trash? -> `storage/` (Logs/Cache)

Canon surfaces (what lives where):
- `TRUTH.md` — constitution + invariants (SSOT).
- `TASK.md` — DP contract + living work surface/log (SSOT for the current thread).
- `SoP.md` — history ledger only (what shipped, when, why).
- `docs/library/MANUAL.md` — operator mechanics + commands (pointer-first).
- `docs/` — rationale + expanded guidance (not SSOT).

## 2. CONSTITUTION (INVARIANTS + ANTI-DRIFT)
Mnemonic principles (optional, high-signal):
- Governance beats heroics.
- Structure beats memory.
- Version-noise is a bug.

Anti-drift invariants:
- If uncertain: STOP; ask for the missing input. Do not assume.
- Reuse-first; run a duplication check before creating new artifacts.
- SSOT discipline: one canonical file per domain; other mentions are pointers.
- Context Hazard: Library directories (`docs/library/agents`, `docs/library/tasks`, `docs/library/skills`) are JIT-only resources and must not reside in the global context manifest.
- SoP is history only; no permanent rules live there.

## 3. STRUCTURE
# Stela Canonical Tree

This repo root is the developer workspace.

## Non-runtime (developer/support)
- `docs/` project manual (points into ops canon)
- `tools/` scripts (verify, build, apply)
- `storage/` local dev storage (not deployed; keep empty in repo)

## Docs library (curated)
- `docs/library/` operator-facing curated library.

If something is unclear, treat this file as the map and the code as evidence.

## Repo layout (what lives where)
- ops/              
- docs/             project manual (start at docs/INDEX.md; points into ops canon)
- docs/ops/         pointer index into ops canon
- tools/            verification + truth checks (support for repo-gates)
-.github/workflows/ — repo-gates / CI enforcement location
- .github/          Copilot instructions + PR templates, etc.

## Ops policy
- /docs is the project manual and index; it points into /ops instead of duplicating canon.

## Key runtime entrypoints
