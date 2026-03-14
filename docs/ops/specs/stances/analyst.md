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
- Machine-ingest analyst mode requires attached `storage/handoff/TOPIC.md` and has no inline-query fallback.
- Machine-ingest analyst mode outputs exactly one fenced markdown code block.
- Machine-ingest analyst mode emits only a complete `PLAN.md` draft.
- Machine-ingest analyst mode first non-empty line inside the fenced body must start with `# DP Plan:`.
- Machine-ingest analyst mode must not emit discussion/option menus or recommendation lines.

## Invariants and failure modes
- Include expansion is strict and fail-closed.
- Unresolved template tokens fail render in strict mode.
- Render output is deterministic for identical repository state.

## Related pointers
- `ops/lib/manifests/BUNDLE.md`
- `ops/lib/scripts/bundle.sh`
- `ops/src/stances/analyst.md.tpl`
