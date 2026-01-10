# README_CONTEXT - Context Pack overview

## What the Context Pack is
The Context Pack is the minimal, curated set of documents that lets a new operator or AI assistant rehydrate project reality without guessing.

## Where it lives today
- `ops/init/icl/context_pack.json` is the index of active pointers.
- The rest of the pack lives alongside it in `ops/init/icl/launch_pack/`.

## How to keep it current
- When docs move, update `ops/init/icl/context_pack.json` to point at the new locations.
- Keep `ops/init/icl/launch_pack/RECOVERY.md` aligned with current workflow and repo-gates.
- Keep onboarding pointers aligned to `docs/10-QUICKSTART.md`.
- Keep onboarding docs in the pack in sync with governance and the front-door docs.

## What it is not
- It is not runtime configuration.
- It is not a deployment artifact.
- It does not replace canon in `ops/` or the Truth-Layer docs.
