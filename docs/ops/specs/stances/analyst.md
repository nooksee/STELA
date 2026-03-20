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
- Shared include source: `ops/src/shared/stances.json#stance_hard_truth_rules`
- Shared include source: `ops/src/shared/stances.json#stance_output_guidance_rules`
- Shared include source: `ops/src/shared/stances.json#stance_continuity_rules`
- Shared include source: `ops/src/shared/stances.json#single_fence_contract_rules`
- Shared include source: `ops/src/shared/stances.json#non_audit_role_drift_rules`

## Outputs
- Rendered stance body text beginning at `Rules:`.
- No unresolved include directives.
- Machine-ingest analyst mode requires attached `storage/handoff/TOPIC.md` and has no inline-query fallback.
- Machine-ingest analyst mode outputs exactly one fenced markdown code block.
- Analyst remains conversational while material ambiguity is still open.
- Conversational mode first non-empty line is `1. Analysis and Discussion`.
- Conversational mode ends with `Questions / Conversation:` when clarification, tradeoff choice, or confirmation would help.
- Final plan mode emits only the complete `PLAN.md` draft in the canonical plan shape.
- Final plan mode uses the headings `Summary`, `Key Changes`, `Test Plan`, and `Assumptions`.
- Output surface: `storage/handoff/PLAN.md` is the latest-wins model output, overwritten on each final-plan analyst run.
- Safety backup: bundle writes a disposable copy of the prior `storage/handoff/PLAN.md` to `var/tmp/PLAN.md.prev` before each analyst run when that file exists.
- Machine-ingest analyst mode must not add repository-operating details, workflow examples, command families, or GitHub action lists unless they are directly visible in the attached artifacts.
- Machine-ingest analyst mode keeps repo-specific claims generic when evidence is thin and makes concrete repo-specific claims when the relevant surfaces are directly attached and sufficient.

## Invariants and failure modes
- Include expansion is strict and fail-closed.
- Unresolved template tokens fail render in strict mode.
- Render output is deterministic for identical repository state.

## Related pointers
- `ops/lib/manifests/BUNDLE.md`
- `ops/lib/scripts/bundle.sh`
- `ops/src/stances/analyst.md.tpl`
