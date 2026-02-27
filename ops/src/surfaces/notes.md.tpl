---
template_type: surface
template_id: notes
template_version: 1
ff_target: operator-technical
ff_band: "25-40"
---
# Contractor Notes — {{DP_ID}}

## Scope Confirmation
State what was executed versus what was scoped. Note any items deliberately not
performed and state the reason for each omission.

## Anomalies Encountered
Describe friction items, unexpected behaviors, and workaround decisions encountered
during execution. State "None." if no anomalies occurred.

## Open Items / Residue
List anything unresolved, non-blocking residue, or audit hazards remaining after
execution. State "None." if all items are resolved.

## Execution Decision Record
Decision Required: Yes|No
Decision Pointer: archives/decisions/... or None

Authoring rules:
- `Decision Required: No` is allowed only when `Anomalies Encountered` is "None."
  and `Open Items / Residue` is "None."
- `Decision Required: Yes` requires `Decision Pointer` to be a repo-relative path
  under `archives/decisions/`.

## Closing Schema Baseline
State which closing schema was assumed for this packet. Default: current six-label
schema (post-0116+A baseline). Historical packet references may appear in narrative
text elsewhere, but this field describes only the active packet's schema assumptions.
Record an explicit exception here only when this packet intentionally tests or touches
historical artifacts or compatibility paths.
