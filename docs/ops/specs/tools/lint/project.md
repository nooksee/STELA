<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/project.sh` protects project contract routing by rejecting `STELA.md` references that point to undefined agent, task, or skill identifiers. The script prevents runtime dead pointers that would route execution toward non-existent definitions and violate project-to-registry contract integrity.

## Mechanics and Sequencing
1. Require `git` and `rg`, resolve repository root, and emit telemetry.
2. Require all three registries: `docs/ops/registry/agents.md`, `docs/ops/registry/tasks.md`, and `docs/ops/registry/skills.md`.
3. Discover project contracts at `projects/*/STELA.md` using depth-2 search.
4. Parse valid ID sets from registries with `awk`.
5. Extract `R-AGENT-*`, `B-TASK-*`, and `S-LEARN-*` tokens from each STELA file with `rg`.
6. Cross-reference each extracted token against the corresponding registry set and fail unknown IDs.
7. Return pass when all references resolve or when no project STELA files exist.

## Anecdotal Anchor
DP-OPS-0078 fission expansion exposed a dead-pointer class where STELA contracts referenced newly introduced identifiers before matching registry entries were committed. This linter now blocks that ordering error at preflight time.

## Integrity Filter Warnings
The script hard-fails when `rg` is missing. Discovery scope is limited to depth 2 under `projects/`, so deeper contract placements are not scanned. Token extraction validates identifier existence only; it does not verify semantic correctness of surrounding task logic.
