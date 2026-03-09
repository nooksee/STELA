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
- Shared include source: `ops/src/shared/stances.json#single_fence_contract_rules`
- Shared include source: `ops/src/shared/stances.json#non_audit_role_drift_rules`

## Outputs
- Rendered stance body text beginning at `Rules:`.
- No unresolved include directives.
- Output contract requires exactly one fenced markdown code block.
- Output contract requires no text before or after the fenced code block.
- First non-empty line inside the fenced body must start with `### DP-`.
- Output contract rejects Contractor Execution Narrative sections and receipt narrative subheadings.
- Output contract rejects ask-back fallback prompt text after preconditions pass (for example "Tell me the outcome you want..." and "Tell me what you want done with them...").
- Architect ingress lint delegates fenced DP bodies to `tools/lint/dp.sh`; canonical body rules (including `3.4.5` receipt shape and `3.5.1` closing-sidecar coherence) remain mandatory.

## Invariants and failure modes
- Include expansion is strict and fail-closed.
- Unresolved template tokens fail render in strict mode.
- Render output is deterministic for identical repository state.

## Related pointers
- `ops/lib/manifests/BUNDLE.md`
- `ops/lib/scripts/bundle.sh`
- `ops/src/stances/architect.md.tpl`
