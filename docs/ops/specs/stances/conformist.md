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

## Outputs
- Rendered stance body text beginning at `Rules:`.
- No unresolved include directives.
- Output contract requires exactly one fenced markdown code block.
- Output contract requires no text before or after the fenced code block.
- First non-empty line inside the fenced body must start with `### DP-`.
- For machine-ingest conformist mode, reject audit verdict markers and Contractor Execution Narrative sections.
- For machine-ingest conformist mode, reject addendum authorization headings and decision fields.

## Invariants and failure modes
- Include expansion is strict and fail-closed.
- Unresolved template tokens fail render in strict mode.
- Render output is deterministic for identical repository state.
- Conformist stance is not used for audit verdict workflows or addendum authorization workflows.

## Related pointers
- `ops/lib/manifests/BUNDLE.md`
- `ops/lib/scripts/bundle.sh`
- `ops/src/stances/conformist.md.tpl`
