<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/plan.sh` is a deterministic safety-floor gate for PLAN-based routing. Structural prevention cannot guarantee operator-authored `storage/handoff/PLAN.md` quality at runtime, so bundle auto-routing requires binary PASS/FAIL checks.

## Mechanics and Sequencing
Modes:
1. `bash tools/lint/plan.sh [path]` (default `storage/handoff/PLAN.md`).
2. `bash tools/lint/plan.sh --test` fixture self-check mode.

Baseline deterministic checks:
1. Target file exists.
2. File is non-empty.
3. File has at least one markdown heading.
4. File has at least one non-heading content line.
5. File has no unresolved `{{TOKEN}}` placeholders.

Architect-targeted checks (only when `Architect Handoff` heading is present):
1. Require `Selected Option`, `Slice Mode`, and `Selected Slices` fields.
2. Require `Execution Order` when `Slice Mode=multi`.

On pass, lint prints `PLAN lint: PASS (<path>)` and exits 0.
On failure, lint prints `FAIL: ...` and exits non-zero.
`--test` includes positive and negative fixtures for both baseline and architect-targeted checks.

## Anecdotal Anchor
DP-OPS-0145 introduced route gating by PLAN lint. DP-OPS-0146 extended deterministic checks to support attach-only architect handoff flow without adding style enforcement.

## Integrity Filter Warnings
PLAN lint is a routing safety floor, not a prose/style rubric. Do not add subjective checks or global gating expansion outside explicit routing and receipt contexts.
