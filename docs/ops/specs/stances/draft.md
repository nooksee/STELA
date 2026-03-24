<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Technical Specification: ops/src/stances/draft.md.tpl

## Purpose
Define the template-backed draft stance body used by bundle output contract rendering.

## Invocation
- Render path: `ops/bin/manifest render stance-draft --out=-`
- Runtime consumer: `ops/lib/scripts/bundle.sh`

## Inputs
- Template source: `ops/src/stances/draft.md.tpl`
- Shared include source: `ops/src/shared/stances.json#stance_shared_rules`
- Shared include source: `ops/src/shared/stances.json#stance_hard_truth_rules`
- Shared include source: `ops/src/shared/stances.json#stance_output_guidance_rules`
- Shared include source: `ops/src/shared/stances.json#stance_continuity_rules`
- Shared include source: `ops/src/shared/stances.json#single_fence_contract_rules`
- Shared include source: `ops/src/shared/stances.json#non_audit_role_drift_rules`

## Outputs
- Rendered stance body text beginning at `Rules:`.
- No unresolved include directives.
- Input surface: `storage/handoff/PLAN.md` is the latest-wins plan input written by the Analyst.
- Draft bundle includes an embedded `DP AUTHORING SCAFFOLD` block containing the canonical full-DP scaffold with canon-owned text already expanded and bundle-known packet metadata already populated.
- Active DP draft surface: `storage/dp/intake/DP.md` is the latest-wins worker-ready DP surface saved directly from the Architect output, then validated with `tools/lint/dp.sh` before dispatch.
- Output contract requires exactly one fenced markdown code block containing the completed worker-ready DP body.
- Output contract requires no text before or after the fenced code block.
- First non-empty line inside the fenced body must start with `### DP-`.
- Architect reads the final plan body directly and uses `Summary`, `Key Changes`, `Test Plan`, and `Assumptions` when present to complete the DP from the embedded authoring scaffold.
- Architect may make the smallest bridge decisions needed to realize the settled plan when attached artifacts settle intent and authority.
- Architect does not expand or replace the settled plan scope.
- Operator saves the full DP output directly to `storage/dp/intake/DP.md` and validates it with `bash tools/lint/dp.sh storage/dp/intake/DP.md` before dispatch.

## Invariants and failure modes
- Include expansion is strict and fail-closed.
- Unresolved template tokens fail render in strict mode.
- Render output is deterministic for identical repository state.
- Draft bundle authoring scaffold must begin at `### DP-` and preserve the canonical DP section order from `ops/src/surfaces/dp.md.tpl`.

## Shipping Spine Position
Architect is the third step in the main shipping spine: `TOPIC.md` -> `PLAN.md` -> draft bundle -> embedded DP authoring scaffold -> `storage/dp/intake/DP.md` (active DP draft) -> Worker execution.
Architect output is a worker-ready full DP body completed from the embedded authoring scaffold; the operator saves it to `storage/dp/intake/DP.md`, validates with `bash tools/lint/dp.sh storage/dp/intake/DP.md`, and dispatches the passing packet.
`packet_id` remains process-grade as `DP-OPS-XXXX`.
Architect is not an audit lane; its output does not contain `## Contractor Execution Narrative`, receipt narrative subheadings, or audit verdict markers.

## Related pointers
- `ops/lib/manifests/BUNDLE.md`
- `ops/lib/scripts/bundle.sh`
- `ops/src/stances/draft.md.tpl`
