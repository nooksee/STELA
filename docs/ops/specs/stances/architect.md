<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Technical Specification: ops/src/stances/architect.md.tpl

## Purpose
Define the template-backed Architect stance body used by bundle output contract rendering.

## Invocation
- Render path: `ops/bin/manifest render stance-architect --out=-`
- Runtime consumer: `ops/lib/scripts/bundle.sh`

## Inputs
- Template source: `ops/src/stances/architect.md.tpl`
- Shared include source: `ops/src/shared/stances.json#stance_shared_rules`
- Shared include source: `ops/src/shared/stances.json#stance_hard_truth_rules`
- Shared include source: `ops/src/shared/stances.json#stance_output_guidance_rules`
- Shared include source: `ops/src/shared/stances.json#stance_continuity_rules`
- Shared include source: `ops/src/shared/stances.json#single_fence_contract_rules`
- Shared include source: `ops/src/shared/stances.json#non_audit_role_drift_rules`

## Outputs
- Rendered stance body text beginning at `Rules:`.
- No unresolved include directives.
- Input surface: `storage/handoff/PLAN.md` is the latest-wins plan input written by the planning model.
- Active DP draft surface: `storage/dp/intake/DP.md` is the latest-wins output target; operator saves the fenced DP draft block output there for dispatch.
- Output contract requires exactly one fenced markdown code block.
- Output contract requires no text before or after the fenced code block.
- First non-empty line inside the fenced body must start with `### DP-`.
- Architect reads the final plan body directly and uses `Summary`, `Key Changes`, `Test Plan`, and `Assumptions` when present to build the DP.
- Architect may make the smallest bridge decisions needed to realize the settled plan when attached artifacts settle intent and authority.
- Architect does not expand or replace the settled plan scope.
- Architect ingress lint delegates fenced DP bodies to `tools/lint/dp.sh`.

## Invariants and failure modes
- Include expansion is strict and fail-closed.
- Unresolved template tokens fail render in strict mode.
- Render output is deterministic for identical repository state.
- Architect does not STOP for missing section heading labels when plan intent and authority are visible.

## Shipping Spine Position
Architect is the third step in the main shipping spine: `TOPIC.md` -> `PLAN.md` -> architect bundle -> `storage/dp/intake/DP.md` (active DP draft) -> Worker execution.
Architect output is a fenced DP draft block; the operator saves it to the `dp_draft_path` printed in bundle `[REQUEST]`.
`packet_id` remains process-grade as `DP-OPS-XXXX`.
Architect is not an audit lane; its output does not contain `## Contractor Execution Narrative`, receipt narrative subheadings, or audit verdict markers.

## Related pointers
- `ops/lib/manifests/BUNDLE.md`
- `ops/lib/scripts/bundle.sh`
- `ops/src/stances/architect.md.tpl`
