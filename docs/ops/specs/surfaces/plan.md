<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Surface Specification: PLAN

## Constitutional Anchor
`storage/handoff/PLAN.md` is an operator-authored planning surface used to drive architect-mode DP drafting.
It is not an execution gate by itself and does not replace DP execution controls.

## Operator Contract
- Canonical template source: `ops/src/surfaces/plan.md.tpl`.
- Minimal deterministic validation: `tools/lint/plan.sh`.
- Architect-targeted plans require `## Architect Handoff`.

Required `Architect Handoff` fields:
- `Selected Option:`
- `Slice Mode:` (`single|multi`)
- `Selected Slices:`
- `Execution Order:` (required when `Slice Mode=multi`)

## Mechanics and Sequencing
1. Analyst produces PLAN intent and optioning.
2. Operator records explicit handoff selections in `Architect Handoff`.
3. Architect consumes attached bundle artifacts plus PLAN and drafts DP using `ops/src/surfaces/dp.md.tpl`.
4. Execution-gate ownership remains in DP Section 3.1 at draft/execution time.

## Failure States and Drift Triggers
- Missing `Architect Handoff` fields in architect-targeted plans.
- Unresolved `{{TOKEN}}` placeholders.
- Heading-only plans with no non-heading content.

## Integrity Filter Warnings
`tools/lint/plan.sh` is a deterministic safety floor, not a style rubric.
Do not add subjective prose checks or global-gate expansion beyond route gating and explicit receipt contexts.
