<!-- CCD: ff_target="operator-technical" ff_band="35-50" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/manifest` exists to render worker-facing packet and receipt surfaces from canonical templates under PoT generation requirements. It prevents schema drift that appears when DP, RESULTS, TASK surface, addendum intake, closing sidecar, or spec files are hand-assembled instead of rendered through one deterministic include and slot pipeline.

## Mechanics and Sequencing
The binary parses render target and options, resolves template paths for `dp`, `results`, `task-surface`, `addendum`, `closing`, `spec`, and stance templates. Stance render keys are canonical process-named keys: `stance-planning`, `stance-draft`, `stance-audit`, and `stance-addenda`. It loads slot values from optional slots files and inline overrides, parses and strips YAML frontmatter from template bodies, parses metadata includes, validates include references, recursively expands include directives with section-anchor support, and rejects include cycles. For DP renders it resolves TASK source and blocks duplicate packet IDs already present in active TASK content. When `TASK.md` is a pointer head, the duplicate-ID hazard check records both the source path (`TASK.md`) and the resolved TASK surface path in the failure diagnostic so pointer-first coupling is explicit. It then applies slot substitutions, enforces unresolved-token failure in strict mode, and writes output to stdout or the requested destination.

## Anecdotal Anchor
In the DP-OPS-0065 immutable workflow cutover, manual packet and receipt assembly caused inconsistent section shape and repeated lint failures. Routing these surfaces through `ops/bin/manifest` converted packet and receipt generation into a deterministic render step.
Think of `ops/bin/manifest` like a press template that keeps each packet surface in the same frame before it is handed to a worker.

## Integrity Filter Warnings
`ops/bin/manifest` exits on unknown render keys, missing template files, malformed slot tokens, unclosed frontmatter, missing include files, missing include anchors, include cycles, duplicate packet ID hazards in DP mode, and unresolved placeholders in strict mode. Duplicate-ID hazard failures now include a named guard condition and `task_source_path`/`task_resolved_path` fields. Targeted success tails return success explicitly to prevent shell tail-status leakage; enforcement semantics are unchanged. Non-strict mode still enforces include resolution and does not allow unresolved include directives.
