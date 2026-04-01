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
2. If a topic spans multiple independent work families and the immediate packet is not explicit, planning asks one slicing or prioritization question before any staged queue or final plan output.
3. The immediate packet is explicit only if the topic directly names the first packet or first work family, the attached evidence directly requires a first packet ordering, or the user explicitly prioritizes one work family. Assistant inference from repo context alone does not qualify.
4. Three or more distinct deliverables in one topic count as multiple independent work families regardless of domain overlap.
5. Planning does not substitute a staged queue, proposed sequencing, or assistant-chosen first packet for a missing slicing decision.
6. If narrower ambiguity still materially changes the immediate packet boundary or implementation handoff after that first slicing decision, planning may ask the minimum bounded follow-up needed instead of forcing a final plan.
7. Once the immediate packet boundary is settled, planning emits the final `PLAN.md` using the required core headings; additional bounded sections are allowed when needed to keep the handoff truthful and narrow.
8. Architect consumes that final plan directly and drafts the DP.

## Failure States and Drift Triggers
- Missing any required core heading.
- Unresolved `{{TOKEN}}` placeholders.
- Heading-only plans with no non-heading content.
- Drift back to generated slice or handoff-field machinery.

## Integrity Filter Warnings
`tools/lint/plan.sh` is a structural safety floor, not a prose/style rubric.
Do not add subjective checks or route-unrelated gate expansion.
