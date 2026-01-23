# DB-DATASET - Curated Dataset Library

DB-DATASET is the curated, manifest-only dataset library for this repo.
Datasets are docs-only references used for "mode training" and standards.

## Scope
- Docs only; no runtime wiring or directory crawlers.
- Datasets live under `docs/library/datasets/`.
- Each dataset must be listed in `docs/library/LIBRARY_INDEX.md` to be visible via `ops/bin/help`.

## Dataset format
Each dataset doc should include:
- ID and title in the filename and H1.
- Purpose and boundaries.
- Any labels required for interpretation (for example, IN-LOOP for a human-required gate).

## Add a dataset
1) Create a new doc in `docs/library/datasets/` with the DB- prefix and numeric ID.
2) Add a manifest entry (topic | title | path) in `docs/library/LIBRARY_INDEX.md`.
3) Update curated-surface indexes when needed (`docs/library/OPERATOR_MANUAL.md`, `docs/ops/INDEX.md`).

## Non-goals
- No runtime behavior changes.
- No auto-discovery; manifest only.
