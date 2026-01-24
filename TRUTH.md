## 1. STELA FILING DOCTRINE
The 4-Line Heuristic:
> 1. Does it RUN the system? -> `ops/` (Binaries, Registry)
> 2. Does it EXPLAIN the system? -> `docs/` (Manuals)
> 3. Is it the WORK itself? -> `projects/` (Code)
> 4. Is it TEMPORARY trash? -> `storage/` (Logs/Cache)

## 2. CONTEXT
Project Context: Stela
Goal
Explainable, governable legacy modernization. We prioritize clear provenance and working code over process.

Critical Rules (Gates)
- No direct pushes to main. Work on work/* branches -> PR -> merge.
- Run verification before review: bash tools/verify_tree.sh

Repository Map
tools/: Verification scripts and repo tooling.
docs/: Human reference.

Workflow
Read TASK.md (local).
Edit code in a work/* branch.
Verify: bash tools/verify_tree.sh
Commit and open a PR.

## 3. STRUCTURE
# Stela Canonical Tree

This repo root is the developer workspace.

## Runtime webroot
- 

## Non-runtime (developer/support)
- `ops/` ICL/OCL canon (protocols, contracts, templates, launch pack)
- `docs/` project manual (points into ops canon)
- `tools/` scripts (verify, build, apply)
- `storage/` local dev storage (not deployed; keep empty in repo)

## Docs library (curated)
- `docs/library/` operator-facing curated library.

If something is unclear, treat this file as the map and the code as evidence.

## 4. MAP
# Project Map

This file is the stable blueprint. Update only when structure or core architecture changes.

## Repo layout (what lives where)
- ops/              
- docs/             project manual (start at docs/00_INDEX.md; points into ops canon)
- docs/ops/         pointer index into ops canon
- tools/            verification + truth checks (support for repo-gates)
-.github/workflows/ — repo-gates / CI enforcement location
- .github/          Copilot instructions + PR templates, etc.

## Ops policy
- /docs is the project manual and index; it points into /ops instead of duplicating canon.

## Key runtime entrypoints

## Naming rules
- Module directories are lowercase.
- Admin modules are prefixed admin_.
- No archive dumps inside public_html.
