<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Technical Specification: ops/src/stances/conformist.md.tpl

## Purpose
Define the template-backed conformist stance body used by bundle output contract rendering.

## Invocation
- Canonical render path: `ops/bin/manifest render stance-conformist --out=-`
- Legacy alias: `ops/bin/manifest render stance-hygiene --out=-`
- Runtime consumer: `ops/lib/scripts/bundle.sh`

## Inputs
- Template source: `ops/src/stances/conformist.md.tpl`
- Shared include source: `ops/src/shared/stances.json#stance_shared_rules`
- Shared include source: `ops/src/shared/stances.json#stance_hard_truth_rules`
- Shared include source: `ops/src/shared/stances.json#stance_output_guidance_rules`
- Shared include source: `ops/src/shared/stances.json#stance_continuity_rules`
- Shared include source: `ops/src/shared/stances.json#single_fence_contract_rules`
- Shared include source: `ops/src/shared/stances.json#non_audit_role_drift_rules`

## Outputs
- Rendered stance body text beginning at `Rules:`.
- No unresolved include directives.
- First non-empty line inside the fenced body must start with `### DP-`.
- For machine-ingest conformist mode, reject addendum authorization headings and decision fields.
- Conformist is a bounded normalizer: visible draft intent plus repo patterns may settle ordinary continuity gaps without forcing a STOP.
- Conformist still stops when missing detail leaves the normalization target or scope unclear.

## Invariants and failure modes
- Include expansion is strict and fail-closed.
- Unresolved template tokens fail render in strict mode.
- Render output is deterministic for identical repository state.
- Conformist stance is not used for audit verdict workflows or addendum authorization workflows.

## Shipping Spine Position
Conformist is a bounded secondary lane in the shipping spine. It provides structure normalization: the conformist model receives a draft DP and outputs a structurally corrected version. Conformist output is not an audit verdict, not a RESULTS receipt, and not an addendum authorization. It is subordinate to RESULTS, CLOSING, and audit truth.

## Related pointers
- `ops/lib/manifests/BUNDLE.md`
- `ops/lib/scripts/bundle.sh`
- `ops/src/stances/conformist.md.tpl`
