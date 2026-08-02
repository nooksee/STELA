<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Technical Specification: ops/src/stances/planning.md.tpl

## Purpose
Define the template-backed Planning stance body used by bundle output contract rendering.

## Invocation
- Render path: `ops/bin/manifest render stance-planning --out=-`
- Runtime consumer: `ops/lib/scripts/bundle.sh`

## Inputs
- Template source: `ops/src/stances/planning.md.tpl`
- Shared include source: `ops/src/shared/stances.json#stance_shared_rules`
- Shared include source: `ops/src/shared/stances.json#stance_hard_truth_rules`
- Shared include source: `ops/src/shared/stances.json#stance_output_guidance_rules`
- Shared include source: `ops/src/shared/stances.json#stance_continuity_rules`
- Shared include source: `ops/src/shared/stances.json#non_audit_role_drift_rules`

## Ownership Model
- Runtime owner: `ops/src/stances/planning.md.tpl` plus the included shared contract keys in `ops/src/shared/stances.json`.
- Verifier: `tools/lint/style.sh` guards planning invariant families; it does not need to co-own every sentence of the runtime stance body.
- Mirror: this spec summarizes the contract families and ownership split; it does not override the runtime template.

## Outputs
- Rendered stance body text beginning at `Rules:`.
- No unresolved include directives.
- Core planning contract:
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
  - Machine-ingest planning mode must not add repository-operating details, workflow examples, command families, or GitHub action lists unless they are directly visible in the attached artifacts.
  - Machine-ingest planning mode keeps repo-specific claims generic when evidence is thin and makes concrete repo-specific claims when the relevant surfaces are directly attached and sufficient.
- Portable clarification transport:
  - Planning clarification mode must ask the question first; it does not require retired question-mode wrapper headings or footers.
  - Planning clarification mode does not use a fenced markdown block; fenced markdown remains the final-plan output contract only.
  - Structured question mode permits at most 3 questions per run; each question starts with a short prose question sentence and is followed immediately by exactly 3 short standalone answer lines: `A.` first substantive option, `B.` second substantive option, and `C. Tell Analyst to do something else instead.`.
  - Planning clarification mode keeps options concise enough to bias host UIs toward clickable rendering when supported, but the stance itself does not guarantee widget or button presentation.
  - Planning clarification mode marks at most one substantive option per question `(Recommended)` and only when directly visible attached evidence actually justifies it; the redirect option is never marked `(Recommended)`.
  - Planning clarification mode does not invent extra substantive branches solely to satisfy formatting; the third displayed choice is the standard redirect option.
  - Planning clarification mode does not add analysis paragraphs between the question sentence and the options.
- Host overlay:
  - When a host-provided single-select question tool is available, it may replace the portable `A./B./C.` fallback using the same two substantive options plus the final redirect option, and it does not also print the prose `A./B./C.` lines.
  - If the host does not support a single-select question tool, planning emits the portable 4-line question output and nothing else.
  - Popup rendering remains host/UI behavior and cannot be guaranteed by stance text alone.
  - In the Claude.ai overlay, `ask_user_input_v0` with `type: single_select` is the concrete widget path; if that tool is unavailable, planning falls back to the portable 4-line output and nothing else.
- Final plan mode:
  - Final plan mode emits only the complete `PLAN.md` draft in a single fenced markdown code block using the required core headings plus any needed peer sections.
  - Final plan mode emits no text before or after the fenced markdown code block.
  - Final plan mode keeps `Summary`, `Key Changes`, `Test Plan`, and `Assumptions` as required core headings.
  - Final plan mode may add peer sections when needed to keep a broad-topic handoff truthful and narrow.
  - When additional headings are needed, they appear as proper peer sections rather than being buried under a required heading.
  - Once the immediate packet boundary is settled, final plan mode emits the final `storage/handoff/PLAN.md`.
- Output surface: `storage/handoff/PLAN.md` is the latest-wins model output, overwritten on each final-plan planning run.
- Safety backup: bundle writes a disposable copy of the prior `storage/handoff/PLAN.md` to `var/tmp/PLAN.md.prev` before each planning run when that file exists.

## Invariants and failure modes
- Include expansion is strict and fail-closed.
- Unresolved template tokens fail render in strict mode.
- Render output is deterministic for identical repository state.
- Verifier ownership stays thinner than runtime ownership: style lint protects planning contract families and critical anchor lines, while the full rendered prose remains owned by the runtime template.
- Planning does not emit structureless questions; when question mode is used, the question comes first, the portable fallback stays bounded, and any host overlay preserves the same substantive choices and final redirect.
- For multi-family topics, question mode has priority over final-plan mode unless the immediate packet is explicit under the narrow definition above.

## Related pointers
- `ops/lib/manifests/BUNDLE.md`
- `ops/lib/scripts/bundle.sh`
- `ops/src/stances/planning.md.tpl`
