<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
Manifest rendering is required to produce canonical worker-facing surfaces (dp, results, task-surface, spec) from templates while preventing schema drift across operations.

## Mechanics and Sequencing
Select template by render key, parse metadata and include declarations, expand include graph deterministically, apply slot substitutions, run strict unresolved-token checks, and write output to file or stdout.

## Anecdotal Anchor
Dispatch and closeout reliability improved only after template-driven generation replaced manual packet and receipt assembly, making lint failures deterministic instead of interpretive.

## Integrity Filter Warnings
Rendering aborts on unknown keys, malformed frontmatter, missing include anchors, duplicate packet hazards (dp mode), or unresolved placeholders in strict mode.