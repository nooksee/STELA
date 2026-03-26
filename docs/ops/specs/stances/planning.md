<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Technical Specification: ops/src/stances/planning.md.tpl

## Purpose
Define the template-backed Planning stance body used by bundle output contract rendering.

## Invocation
- Render path: `ops/bin/manifest render stance-planning --out=-`
- Legacy alias: `ops/bin/manifest render stance-analyst --out=-`
- Runtime consumer: `ops/lib/scripts/bundle.sh`

## Inputs
- Template source: `ops/src/stances/planning.md.tpl`
- Shared include source: `ops/src/shared/stances.json#stance_shared_rules`
- Shared include source: `ops/src/shared/stances.json#stance_hard_truth_rules`
- Shared include source: `ops/src/shared/stances.json#stance_output_guidance_rules`
- Shared include source: `ops/src/shared/stances.json#stance_continuity_rules`
- Shared include source: `ops/src/shared/stances.json#single_fence_contract_rules`
- Shared include source: `ops/src/shared/stances.json#non_audit_role_drift_rules`

## Outputs
- Rendered stance body text beginning at `Rules:`.
- No unresolved include directives.
- Machine-ingest planning mode requires attached `storage/handoff/TOPIC.md` and has no inline-query fallback.
- Machine-ingest planning mode outputs exactly one fenced markdown code block.
- Planning reads topic and all directly attached bundle evidence before asking anything (explore-first).
- Material-ambiguity threshold: low-impact gaps are absorbed as smallest justified assumptions; only gaps that would materially change the plan trigger question mode.
- Planning emits the final plan immediately when topic and evidence settle intent; clarification questions are the narrow exception, not the default mode.
- Subordinate choices that do not change the immediate packet boundary are settled directly in the plan rather than asked as questions.
- One real packet-boundary question is preferred over a broad questionnaire when a question is needed; up to 3 questions are permitted in a single run.
- After clarification, emit the final plan immediately.
- Structured question mode: at most 3 questions per run; each question presents exactly 3 meaningful, mutually exclusive options; exactly one option per question is marked `(Recommended)`.
- Conversational mode ends with `Questions / Conversation:` when clarification, tradeoff choice, or confirmation would help.
- Final plan mode emits only the complete `PLAN.md` draft in the canonical plan shape.
- Final plan mode uses the headings `Summary`, `Key Changes`, `Test Plan`, and `Assumptions`.
- Output surface: `storage/handoff/PLAN.md` is the latest-wins model output, overwritten on each final-plan planning run.
- Safety backup: bundle writes a disposable copy of the prior `storage/handoff/PLAN.md` to `var/tmp/PLAN.md.prev` before each planning run when that file exists.
- Machine-ingest planning mode must not add repository-operating details, workflow examples, command families, or GitHub action lists unless they are directly visible in the attached artifacts.
- Machine-ingest planning mode keeps repo-specific claims generic when evidence is thin and makes concrete repo-specific claims when the relevant surfaces are directly attached and sufficient.

## Invariants and failure modes
- Include expansion is strict and fail-closed.
- Unresolved template tokens fail render in strict mode.
- Render output is deterministic for identical repository state.
- Planning does not emit structureless questions; when question mode is used, the Q1./Q2./Q3. format with A./B./C. options and one `(Recommended)` per question is required.

## Related pointers
- `ops/lib/manifests/BUNDLE.md`
- `ops/lib/scripts/bundle.sh`
- `ops/src/stances/planning.md.tpl`
