<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Technical Specification: ops/src/stances/foreman.md.tpl

## Purpose
Define the template-backed foreman stance body used for `foreman` profile bundle contract rendering.

## Invocation
- Canonical render path: `ops/bin/manifest render stance-foreman --out=-`
- Legacy alias: `ops/bin/manifest render stance-authority --out=-`
- Runtime consumer: `ops/lib/scripts/bundle.sh`

## Inputs
- Template source: `ops/src/stances/foreman.md.tpl`
- Shared include source: `ops/src/shared/stances.json#stance_shared_rules`

## Outputs
- Rendered stance body text beginning at `Rules:`.
- No unresolved include directives.

## Invariants and failure modes
- Include expansion is strict and fail-closed.
- Unresolved template tokens fail render in strict mode.
- Render output is deterministic for identical repository state.

## Related pointers
- `ops/lib/manifests/BUNDLE.md`
- `ops/lib/scripts/bundle.sh`
- `ops/src/stances/foreman.md.tpl`
