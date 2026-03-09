<!-- CCD: ff_target="operator-technical" ff_band="35-50" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/factory` enforces deterministic definition rendering for agent, task, and skill surfaces under PoT SSOT and generation mandates. It prevents manual formatting drift by binding output structure to template metadata, include resolution, and explicit slot replacement rules.

## Mechanics and Sequencing
The binary parses render target and option flags, resolves template paths for `agent`, `task`, or `skill`, optionally loads slot blocks from a slots file, applies `--slot` overrides, parses template frontmatter (`requires_slots`, `includes`), resolves includes, and renders deterministic output.

## F2 Contract Alignment
Rendered definitions are expected to satisfy the F2 baseline:
- agents: identity contract with runtime-role naming and stance binding,
- skills: method contract fields,
- tasks: objective contract fields.
Validation authority remains `tools/lint/factory.sh`.

## Integrity Filter Warnings
`ops/bin/factory` exits on unknown template keys, invalid slot token names, missing slots file, malformed slot pairs, unclosed frontmatter, missing include file/section, circular include graphs, missing required slots in strict mode, unresolved placeholders in strict mode, and unresolved include directives after expansion.
`--dry-run` validates argument shape only and does not validate downstream write permissions.
