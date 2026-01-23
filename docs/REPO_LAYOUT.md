# Repo layout - operating zones

This is the "what goes where" map for current operations.

## Operating zones
- Runtime: `public_html/` only. Everything here is deployable.
- Governance and docs: `.github/` and `docs/` (manual + indexes).
- Ops canon: `ops/` (system operations, contracts, templates).
- Tooling and verification: `tools/` and `tests/`.
- Donor and optional inputs: `upstream/`, `addons/`, and `patches/`.
- Local-only storage: `storage/`.

## Top-level directories (current)
- `.github/` - CI workflows, governance templates, and repo policy automation.
- `addons/` - optional legacy or extra modules not required for core runtime.
- `ops/` - system operations (contracts, templates); non-runtime.
- `docs/` - project manual that points into ops canon (no duplicated doctrine).
- `patches/` - optional patch queue; keep small and explicit.
- `public_html/` - deployable webroot and runtime code/assets.
- `storage/` - local dev storage; not deployed.
- `tests/` - test scaffolding and fixtures.
- `tools/` - repo-gates and verification scripts.
- `upstream/` - read-only donor snapshots.
