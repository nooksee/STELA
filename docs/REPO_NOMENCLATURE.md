# Repo nomenclature

This document standardizes names used across issues, branches, PRs, and docs.

## Primary surfaces

**Current:**
- `public_html/` — deployable webroot (what the server serves)
- `tools/` — repo gates + verification tooling
- `docs/` — operator docs and governance
- `upstream/` — donor snapshots (read-only posture)

**Planned / evolving:**
- `src/` — Stela core source (primary development surface once extracted)
- `packages/` — imported features adapted into Stela

## Branch naming

- Work branches: `work/<topic>-YYYY-MM-DD`
- Never work directly on `main`.

## PR naming

- Title: concise, imperative, scoped to the change.
- Prefer one topic per PR.

## Commit prefixes (suggested)

- `docs:` documentation-only
- `ci:` automation / workflows
- `chore:` repo hygiene, non-functional
- `feat:` new capability
- `fix:` bug fix
- `refactor:` structural change (no behavior change intended)
