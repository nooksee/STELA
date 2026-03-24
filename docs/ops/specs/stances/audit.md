<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Technical Specification: ops/src/stances/audit.md.tpl

## Purpose
Define the template-backed Audit stance body used by bundle output contract rendering.

## Invocation
- Canonical render path: `ops/bin/manifest render stance-audit --out=-`
- Legacy render callers must use `stance-audit`.
- Runtime consumer: `ops/lib/scripts/bundle.sh`

## Inputs
- Template source: `ops/src/stances/audit.md.tpl`
- Shared include source: `ops/src/shared/stances.json#stance_shared_rules`
- Shared include source: `ops/src/shared/stances.json#single_fence_contract_rules`
- TASK evidence source is dump payload context; direct TASK attachment wording is not required.

## Outputs
- Rendered stance body text beginning at `Rules:`.
- No unresolved include directives.
- Output contract requires exactly one fenced markdown code block.
- Output contract requires no text before or after the fenced code block.
- First line must be ```markdown.
- First non-empty line inside the fenced body must start with `**AUDIT -`.
- Last line must be ``` .
- Output contract rejects citation-token strings (`[cite_start]`, `[cite:`, `[/cite]`, `:contentReference[`, `oaicite`).

## Invariants and failure modes
- Include expansion is strict and fail-closed.
- Unresolved template tokens fail render in strict mode.
- Render output is deterministic for identical repository state.

## Related pointers
- `ops/lib/manifests/BUNDLE.md`
- `ops/lib/scripts/bundle.sh`
- `ops/src/stances/audit.md.tpl`
