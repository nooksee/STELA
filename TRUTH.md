## 1. STELA FILING DOCTRINE
The 4-Line Heuristic:
> 1. Does it RUN the system? -> `ops/` (Binaries, Registry)
> 2. Does it EXPLAIN the system? -> `docs/` (Manuals)
> 3. Is it the WORK itself? -> `projects/` (Code)
> 4. Is it TEMPORARY trash? -> `storage/` (Logs/Cache)

## 2. CONTEXT
Project Context: php-nuke-ce (Stela)
Goal
Explainable, governable legacy modernization. We prioritize clear provenance and working code over process.

Critical Rules (Gates)
- No direct pushes to main. Work on work/* branches -> PR -> merge.
- Run verification before review: bash tools/verify_tree.sh

Repository Map
public_html/: Runtime webroot. The code that runs.
upstream/: Read-only donor snapshots. Reference only.
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
- `public_html/` is the Apache DocumentRoot.

## Non-runtime (developer/support)
- `ops/` ICL/OCL canon (protocols, contracts, templates, launch pack)
- `docs/` project manual (points into ops canon)
- `tools/` scripts (verify, build, apply)
- `patches/` optional patch queue (small deltas when used)
- `releases/` release notes/manifests (no embedded zip artifacts in-repo)
- `storage/` local dev storage (not deployed; keep empty in repo)

## Docs library (curated)
- `docs/library/` operator-facing curated library.
- `docs/library/[REMOVED].md` Stelae operator nudges.

## In public_html
- `admin/` admin UI entry + admin modules
- `modules/` site modules
- `addons/` optional legacy/extra modules (not required for core)
- `src/` modern internal code (Core/Security/etc.)
- `includes/` classic include layer / bootstrap
- `uploads/` user uploads (writable; deny PHP execution)
- `cache/`, `tmp/`, `logs/` writable runtime surfaces (writable; not versioned)

If something is unclear, treat this file as the map and the code as evidence.

## 4. MAP
# Project Map — PHP-Nuke CE

This file is the stable blueprint. Update only when structure or core architecture changes.

## Repo layout (what lives where)
- public_html/      deployable webroot (what the server serves)
- ops/              ICL/OCL canon (protocols, contracts, templates, launch pack)
- docs/             project manual (start at docs/00-INDEX.md; points into ops canon)
- docs/ops/         pointer index into ops canon
- tools/            verification + truth checks (support for repo-gates)
- scripts/          helper scripts (build/sync/release tooling when used)
- upstream/ — Read-Only Donor Bank
- patches/          optional patch queue (use only when needed; keep small)
-.github/workflows/ — repo-gates / CI enforcement location
- .github/          Copilot instructions + PR templates, etc.
- addons/           optional legacy/extra modules (not required for core)

## Ops policy
- /ops may contain: ICL/OCL doctrine, protocols, contracts, templates, manifests, profiles, and launch pack materials.
- /ops must not contain: runtime code, upstream snapshots, or general documentation that belongs in docs/.
- /docs is the project manual and index; it points into /ops instead of duplicating canon.

## Key runtime entrypoints
- public_html/index.php       router entry
- public_html/modules.php     legacy entry (modules.php?name=...)
- public_html/mainfile.php    legacy compat include

## Naming rules
- Module directories are lowercase.
- Admin modules are prefixed admin_.
- No archive dumps inside public_html.
