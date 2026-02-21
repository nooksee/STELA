<!-- CCD: ff_target="operator-technical" ff_band="35-50" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/factory` exists to enforce deterministic definition rendering for agent, task, and skill surfaces under PoT SSOT and generation mandates. It prevents manual formatting drift by binding output structure to template metadata, include resolution, and explicit slot replacement rules.

## Mechanics and Sequencing
The binary parses render target and option flags, resolves template paths for `agent`, `task`, or `skill`, optionally loads slot blocks from a slots file, applies `--slot` overrides, parses template frontmatter, and parses metadata keys including `requires_slots` and `includes`. It validates metadata include references, recursively expands in-body include directives with section-anchor support, rejects include cycles, applies slot token substitutions, enforces required-slot presence and non-empty values in strict mode, checks unresolved include directives and unresolved slot placeholders, and writes output to file or stdout.

## Anecdotal Anchor
Before rendering was centralized in the DP-OPS-0077 definition fission timeline, promoted definition files frequently drifted in heading and token layout because authors copied and adjusted markdown manually. `ops/bin/factory` was introduced to bind definition output to one rendering path.
Think of `ops/bin/factory` like a jig in a machine shop that keeps every output shape aligned before it leaves the bench.

## Integrity Filter Warnings
`ops/bin/factory` exits on unknown template keys, invalid slot token names, missing slots file, malformed slot pairs, unclosed frontmatter, missing include file, missing include section anchor, circular include graphs, missing required slots in strict mode, unresolved placeholders in strict mode, and unresolved include directives after expansion. `--dry-run` validates argument shape only and does not validate downstream write permissions.
