# PROJECT_STRUCTURE - current repo folders

This file summarizes the current repo layout. It should match the actual top-level directories.

## Top-level
- `.github/` - CI workflows, governance templates, and repo policy automation.
- `addons/` - optional legacy or extra modules not required for core runtime.
- `ops/` - ICL/OCL canon (protocols, contracts, templates, boot pack); non-runtime.
- `docs/` - project manual that points into ops canon (no duplicated doctrine).
- `patches/` - optional patch queue; keep small and explicit.
- `public_html/` - deployable webroot and runtime code/assets.
- `storage/` - local dev storage; not deployed.
- `tests/` - test scaffolding and fixtures.
- `tools/` - repo-gates and verification scripts.
- `upstream/` - read-only donor snapshots.
