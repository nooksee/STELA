# nukeCE Canonical Tree

This repo root is the developer workspace.

## Runtime webroot
- `public_html/` is the Apache DocumentRoot.

## Non-runtime (developer/support)
- `ops/` ICL/OCL canon (protocols, contracts, templates, boot pack)
- `docs/` project manual (points into ops canon)
- `tools/` scripts (verify, build, apply)
- `patches/` optional patch queue (small deltas when used)
- `releases/` release notes/manifests (no embedded zip artifacts in-repo)
- `storage/` local dev storage (not deployed; keep empty in repo)

## In public_html
- `admin/` admin UI entry + admin modules
- `modules/` site modules
- `addons/` optional legacy/extra modules (not required for core)
- `src/` modern internal code (Core/Security/etc.)
- `includes/` classic include layer / bootstrap
- `uploads/` user uploads (writable; deny PHP execution)
- `cache/`, `tmp/`, `logs/` writable runtime surfaces (writable; not versioned)

If something is unclear, treat this file as the map and the code as evidence.
