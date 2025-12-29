# nukeCE (PHP-Nuke CE)

nukeCE is an explainability-first, provenance-forward CMS program.

## Repo map (start here)
- `public_html/` — deployable webroot (what the server serves)
- `src/` — nukeCE core source (primary development)
- `packages/` — extracted/imported features adapted into nukeCE (e.g., Sentinel → nukeSecurity later)
- `upstream/` — read-only snapshots of donor projects
  - `upstream/php-nuke/` — Burzi upstream
  - `upstream/titanium/` — Titanium upstream
- `docs/` — documentation, architecture, ethos, release process
- `scripts/` — build/sync/release tooling

## Development philosophy
- Upstreams are donors, not identity.
- nukeCE work happens in `src/` and `packages/`.
- Every import is tracked with provenance notes.
