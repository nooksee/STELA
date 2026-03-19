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
- Input surface: `storage/handoff/PLAN.md` is the latest-wins plan input written by the analyst model; operator ensures valid `## Architect Handoff` fields are present before each architect run.
- Active DP draft surface: `storage/dp/intake/DP.md` is the latest-wins output target; operator saves the fenced DP draft block output there for dispatch. Packet identity remains `DP-OPS-XXXX` and is printed in bundle `[REQUEST]`.
- Output contract requires exactly one fenced markdown code block.
- Output contract requires no text before or after the fenced code block.
- First non-empty line inside the fenced body must start with `### DP-`.
- Architect drafts express `Required Work Branch` in the canonical proposal form (`PROPOSED/work/...`) and do not add branch-state narration or replacement instructions.
- Output contract rejects Contractor Execution Narrative sections and receipt narrative subheadings.
- Architect handoff selections remain the governing scope, but directly visible attached artifacts may be used to correct stale or self-contradictory request details inside that selected scope.
- Architect may make the smallest bridge decisions needed to realize the selected slice when attached artifacts settle option, slice, and authority.
- Missing handoff detail is a hard stop only when option, slice, or authority remains unclear after inspecting attached artifacts.
- Architect may name repo/runtime contract defects plainly when those defects are directly visible in attached artifacts and the corrective work stays within the selected slice.
- Architect should emit a complete usable DP once selected scope is settled; the lane should not collapse to read-only summary when bounded in-scope continuity work is truthful and directly supported.
- Architect ingress lint delegates fenced DP bodies to `tools/lint/dp.sh`; canonical body rules (including `3.4.5` receipt shape and `3.5.1` closing-sidecar coherence) remain mandatory.

## Invariants and failure modes
- Include expansion is strict and fail-closed.
- Unresolved template tokens fail render in strict mode.
- Render output is deterministic for identical repository state.

## Shipping Spine Position
Architect is the third step in the main shipping spine: `TOPIC.md` → `PLAN.md` → architect bundle → `storage/dp/intake/DP.md` (active DP draft) → Worker execution. Architect output is a fenced DP draft block; the operator saves it to the `dp_draft_path` printed in bundle `[REQUEST]`. `packet_id` remains process-grade as `DP-OPS-XXXX`. Architect is not an audit lane; its output does not contain `## Contractor Execution Narrative`, receipt narrative subheadings, or audit verdict markers.

## Related pointers
- `ops/lib/manifests/BUNDLE.md`
- `ops/lib/scripts/bundle.sh`
- `ops/src/stances/architect.md.tpl`
