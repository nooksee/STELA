<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Technical Specification: ops/src/stances/contractor.md.tpl

## Purpose
Define the template-backed Contractor stance for addendum authorization artifact assembly.

## Invocation
- Render path: `ops/bin/manifest render stance-contractor --out=-` (future mapping).
- Primary operator reference path: `docs/ops/prompts/e-prompt-06.md`.

## Inputs
- Template source: `ops/src/stances/contractor.md.tpl`
- Shared include source: `ops/src/shared/stances.json#stance_shared_rules`

## Outputs
- Rendered contractor procedure body beginning at `Rules:`.
- No unresolved include directives.

## Invariants and failure modes
- Include expansion is strict and fail-closed.
- Unresolved template tokens fail render in strict mode.
- Render output is deterministic for identical repository state.

## Related pointers
- `docs/ops/prompts/e-prompt-06.md`
- `ops/src/stances/foreman.md.tpl`
- `ops/src/stances/addendum.md.tpl`
