<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/lib/scripts/skill.sh` enforces a canonical skill lifecycle so reusable guidance enters canon through one promotion gate with provenance and pointer-head continuity. This protects PoT.md Section 1.2 Reuse-first and Drift axioms by preventing unsupervised edits to skill files and registry rows.

## Mechanics and Sequencing
1. Entry dispatch accepts four routes: `harvest`, `promote`, `check`, and a legacy three-positional alias that forwards into `harvest`.
2. `harvest` sequence:
   - Collect explicit flags, optional stdin blocks, and optional `--force`.
   - Derive default name/context from hot-zone and high-churn heuristics when fields are omitted.
   - Insert placeholder `REPLACE_SOLUTION` when no solution is provided and print a warning.
   - Run semantic-collision checks against canonical skills and draft leaves; block unless `--force` is present.
   - Resolve packet and trace metadata, render template slots through `ops/bin/template`, redact output, write candidate leaf, and rewrite `candidate:` pointer in `opt/_factory/SKILLS.md`.
3. `promote` sequence:
   - Resolve draft path explicitly or via newest draft selection.
   - Validate header, required sections, non-placeholder fields, and context hazard constraints.
   - Allocate next `S-LEARN-XX` identifier from canon files and registry rows.
   - Materialize promoted skill content (header rewrite plus pointer section injection when absent), write canonical skill file, insert registry row, emit promotion leaf, and rewrite `promotion:` pointer.
4. `check` enforces Skills Context Hazard by rejecting skill references in `ops/lib/manifests/CONTEXT.md`.
5. Optional `--delete-draft` on promotion removes the candidate leaf after successful promotion.

## Anecdotal Anchor
SoP entry `2026-02-10 15:03:09 UTC — DP-OPS-0041 Skills System Overhaul` records a subsystem recertification that realigned S-LEARN files, registry rows, and enforcement tooling. That remediation maps directly to the failure class this script now blocks: manual skill edits caused canon and registry divergence before lifecycle gating was tightened.

## Integrity Filter Warnings
- `--force` allows semantic-collision override and can introduce near-duplicate skill concepts.
- Promotion has no rollback transaction; failure after canonical file write can leave registry or pointer state partially advanced.
- Draft auto-selection fails when multiple draft files share identical newest timestamps.
- Placeholder solution text can persist in candidate leaves until promotion-time validation rejects it.
