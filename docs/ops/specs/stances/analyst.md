<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Technical Specification: ops/src/stances/analyst.md.tpl

## Purpose
Define the template-backed Analyst stance body used by bundle output contract rendering.

## Invocation
- Render path: `ops/bin/manifest render stance-analyst --out=-`
- Runtime consumer: `ops/lib/scripts/bundle.sh`

## Inputs
- Template source: `ops/src/stances/analyst.md.tpl`
- Shared include source: `ops/src/shared/stances.json#stance_shared_rules`
- Shared include source: `ops/src/shared/stances.json#single_fence_contract_rules`
- Shared include source: `ops/src/shared/stances.json#non_audit_role_drift_rules`

## Outputs
- Rendered stance body text beginning at `Rules:`.
- No unresolved include directives.
- Machine-ingest analyst mode first non-empty line inside the fenced body must start with `1. Analysis and Discussion`.
- Machine-ingest analyst mode requires `2. Strategic Options` and a `Recommendation:` line.
- PLAN output mode contract requires exactly one fenced markdown code block.
- PLAN output mode contract requires no text before or after the fenced code block.
- PLAN output mode first non-empty line inside the fenced body must start with `# DP Plan:`.

## Invariants and failure modes
- Include expansion is strict and fail-closed.
- Unresolved template tokens fail render in strict mode.
- Render output is deterministic for identical repository state.

## Related pointers
- `ops/lib/manifests/BUNDLE.md`
- `ops/lib/scripts/bundle.sh`
- `ops/src/stances/analyst.md.tpl`
