# nukeCE (PHP-Nuke CE)

nukeCE is an explainability-first, provenance-forward CMS program.

[![repo-gates](https://github.com/nooksee/php-nuke-ce/actions/workflows/repo_gates.yml/badge.svg)](https://github.com/nooksee/php-nuke-ce/actions/workflows/repo_gates.yml)

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

nukeCE is an **explainability-first, provenance-forward** CMS.  
If a change can’t explain itself, it doesn’t ship. 🔒

### What that means in practice
- **Upstreams are donors, not identity.** We preserve upstream snapshots read-only, and adapt intentionally.
- **Provenance is a feature.** Imports and major edits should include notes that answer: *where did this come from, why is it here, what changed?*
- **Epistemic friction, on purpose.** We prefer visible reasoning (docs, truth layers, gates) over “just trust the vibe.”
- **PR-only governance.** No direct pushes to `main`. Ever. (Yes, even for admins.)
- **Repo-gates are the front door.** If gates fail, we fix gates or the change — not the rules.

### The quick map (start here)
- `public_html/` — deployable webroot (what the server serves)
- `src/` — nukeCE core source (primary development)
- `packages/` — extracted/imported features adapted into nukeCE
- `upstream/` — read-only donor snapshots (do not edit)
- `docs/` — documentation, governance, release process, truth layers
- `scripts/` — build/sync/release tooling

### Working style (the human layer)
- NetBeans-first for review and confidence.
- Terminal commands are **small, deliberate, and one-at-a-time**.
- Changes land via: `work/*` branch → PR → repo-gates → merge ✅

(Yes, this is disciplined. That’s the point.)

