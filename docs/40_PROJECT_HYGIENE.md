# Project hygiene

This repository is structured to keep deployable code, tooling, and documentation cleanly separated.

## Boundaries

- `public_html/` is **deployable**. Treat it as production-facing.
- Everything else is **non-deployable** by default (docs, tooling, storage, donor inputs).

## Governance

- Work happens on `work/*` branches.
- Merges happen by PR only.
- Required checks (repo-gates) must pass before merge.

## Hygiene rules

- Avoid committing machine-specific paths, hostnames, or personal identifiers into docs/config.
- Keep PRs small and scoped.
- Prefer repo-relative paths (e.g., `public_html/includes`) in documentation.
