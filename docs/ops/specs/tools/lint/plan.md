<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/plan.sh` is the deterministic safety-floor gate for the final `storage/handoff/PLAN.md` surface used by analyst output and architect intake.

## Mechanics and Sequencing
Modes:
1. `bash tools/lint/plan.sh [path]` (default `storage/handoff/PLAN.md`).
2. `bash tools/lint/plan.sh --test` fixture self-check mode.

Deterministic checks:
1. Target file exists.
2. File is non-empty.
3. File has at least one markdown heading.
4. File has at least one non-heading content line.
5. File has no unresolved `{{TOKEN}}` placeholders.
6. File contains the canonical final-plan headings:
   - `## Summary`
   - `## Key Changes`
   - `## Test Plan`
   - `## Assumptions`

On pass, lint prints `PLAN lint: PASS (<path>)` and exits 0.
On failure, lint prints `FAIL: ...` and exits non-zero.
`--test` includes positive and negative fixtures for the canonical final-plan shape.

## Integrity Filter Warnings
PLAN lint is a routing safety floor, not a prose/style rubric.
Do not add subjective checks or global gating expansion outside explicit routing and receipt contexts.
