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

nukeCE is built to be explainable on purpose.

- **Explanation-first, not novelty-first.** If we can’t explain it, we don’t ship it.
- **Provenance-forward.** Upstreams are *donors*, not identity. Imports get notes and context.
- **No silent magic.** “Where did this come from?” should always have an answer.
- **Small, reversible changes.** Work happens on `work/*` branches with PR-only merges.
- **Repo-gates are law.** If CI says “no,” it’s “no” — even for admins.
- **Visual workflow friendly.** NetBeans-first review; terminal only for surgical moves.

