<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Surface Specification: PLAN

## Constitutional Anchor
`storage/handoff/PLAN.md` is the operator-facing planning surface produced by the planning lane and consumed by the draft lane.
It remains planning-only; execution control still lives in the DP.

## Operator Contract
- Canonical template source: `ops/src/stances/plan.md.tpl`.
- Deterministic validation: `tools/lint/plan.sh`.
- Required core headings:
  - `# <Plan Title>`
  - `## Summary`
  - `## Key Changes`
  - `## Test Plan`
  - `## Assumptions`
- Additional bounded sections are allowed when they are needed to keep a broad-topic handoff truthful and narrow.

## Mechanics and Sequencing
1. Planning works from `storage/handoff/TOPIC.md`.
2. While remaining ambiguity still materially changes the immediate packet boundary or implementation handoff, planning may ask bounded clarification questions instead of forcing a final plan.
3. Once remaining ambiguity no longer materially changes the immediate packet boundary or implementation handoff, planning emits the final `PLAN.md` using the required core headings; additional bounded sections are allowed when needed to keep the handoff truthful and narrow.
4. Architect consumes that final plan directly and drafts the DP.

## Failure States and Drift Triggers
- Missing any required core heading.
- Unresolved `{{TOKEN}}` placeholders.
- Heading-only plans with no non-heading content.
- Drift back to generated slice or handoff-field machinery.

## Integrity Filter Warnings
`tools/lint/plan.sh` is a structural safety floor, not a prose/style rubric.
Do not add subjective checks or route-unrelated gate expansion.
