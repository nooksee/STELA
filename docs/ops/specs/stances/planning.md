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
- Shared include source: `ops/src/shared/stances.json#non_audit_role_drift_rules`

## Outputs
- Rendered stance body text beginning at `Rules:`.
- No unresolved include directives.
- Machine-ingest planning mode requires attached `storage/handoff/TOPIC.md` and has no inline-query fallback.
- Planning uses attached evidence first.
- Planning produces `storage/handoff/PLAN.md` only; it does not execute implementation.
- If a topic spans multiple independent work families and the topic does not explicitly identify the immediate packet, planning asks one slicing or prioritization question before writing the final plan.
- The immediate packet is explicit only if the topic directly names the first packet or first work family, the attached evidence directly requires a first packet ordering, or the user explicitly prioritizes one work family.
- Planning does not infer or choose the immediate packet unilaterally from repo context alone when multiple work families are in scope.
- Three or more distinct deliverables in one topic count as multiple independent work families regardless of domain overlap.
- Planning does not substitute a staged queue, proposed sequencing, or assistant-chosen first packet for a missing slicing decision.
- Planning defaults to question mode for multi-family topics; it skips the slicing question only when the operator's topic text directly names the immediate packet.
- If remaining ambiguity still materially changes the immediate packet boundary or implementation handoff, planning asks the minimum additional bounded clarification needed.
- Planning clarification mode must ask the question first; it does not require retired question-mode wrapper headings or footers.
- Planning clarification mode does not use a fenced markdown block; fenced markdown remains the final-plan output contract only.
- Structured question mode permits at most 3 questions per run; each question presents 2-3 meaningful, mutually exclusive options; the smallest truthful option set is preferred, so 2 options are used for a real binary choice and 3 only when the third branch is genuinely distinct and evidence-grounded.
- Planning clarification mode marks at most one option per question `(Recommended)` and only when directly visible attached evidence actually justifies it.
- Planning clarification mode does not invent extra branches solely to satisfy formatting.
- Final plan mode emits only the complete `PLAN.md` draft in a single fenced markdown code block using the canonical plan shape.
- Final plan mode emits no text before or after the fenced markdown code block.
- Final plan mode keeps `Summary`, `Key Changes`, `Test Plan`, and `Assumptions` as required core headings.
- Final plan mode may add bounded extra sections when needed to keep a broad-topic handoff truthful and narrow.
- Once the immediate packet boundary is settled, final plan mode emits the final `storage/handoff/PLAN.md`.
- Output surface: `storage/handoff/PLAN.md` is the latest-wins model output, overwritten on each final-plan planning run.
- Safety backup: bundle writes a disposable copy of the prior `storage/handoff/PLAN.md` to `var/tmp/PLAN.md.prev` before each planning run when that file exists.
- Machine-ingest planning mode must not add repository-operating details, workflow examples, command families, or GitHub action lists unless they are directly visible in the attached artifacts.
- Machine-ingest planning mode keeps repo-specific claims generic when evidence is thin and makes concrete repo-specific claims when the relevant surfaces are directly attached and sufficient.

## Invariants and failure modes
- Include expansion is strict and fail-closed.
- Unresolved template tokens fail render in strict mode.
- Render output is deterministic for identical repository state.
- Planning does not emit structureless questions; when question mode is used, the question comes first, options remain bounded, and the smallest truthful option set is required.
- For multi-family topics, question mode has priority over final-plan mode unless the immediate packet is explicit under the narrow definition above.

## Related pointers
- `ops/lib/manifests/BUNDLE.md`
- `ops/lib/scripts/bundle.sh`
- `ops/src/stances/planning.md.tpl`
