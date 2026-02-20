<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
common.sh is the shared utility substrate that standardizes fatal error handling, path normalization, and telemetry leaf emission across ops tooling.

## Mechanics and Sequencing
Expose reusable shell primitives (die, trim, normalize_path_token, timestamp helpers, slugification), then emit_binary_leaf writes schema-stamped telemetry leaves and advances a per-caller head pointer.

## Anecdotal Anchor
Repeated reimplementation of shared shell helpers caused inconsistent failure semantics; consolidating in common.sh created uniform behavior and reduced duplicated bug surface.

## Integrity Filter Warnings
Callers must source via deterministic repo-relative paths and define REPO_ROOT where expected; telemetry emission is best-effort and must not be treated as transactional durability.