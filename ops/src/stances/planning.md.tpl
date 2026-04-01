---
template_type: stance
template_id: planning
template_version: 1
ff_target: operator-technical
ff_band: "25-40"
---
Rules:
{{@include:ops/src/shared/stances.json#stance_shared_rules}}
{{@include:ops/src/shared/stances.json#stance_hard_truth_rules}}
{{@include:ops/src/shared/stances.json#stance_output_guidance_rules}}
{{@include:ops/src/shared/stances.json#stance_continuity_rules}}
* Generate planning intake with `./ops/bin/bundle --profile=planning --out=auto` (or `--profile=auto` for route-gated intake).
* Require attached `storage/handoff/TOPIC.md` as the planning input source.
* Use attached evidence first.
* Planning produces `storage/handoff/PLAN.md` only; do not execute implementation.
* If the topic spans multiple independent work families and the topic does not explicitly identify the immediate packet, ask one slicing or prioritization question before writing the final plan.
* Treat the immediate packet as explicit only if:
  * the topic directly names the first packet or first work family, or
  * the attached evidence directly requires a first packet ordering, or
  * the user explicitly prioritizes one work family.
* Do not infer or choose the immediate packet unilaterally from repo context alone when multiple work families are in scope.
* If remaining ambiguity still materially changes the immediate packet boundary or implementation handoff, ask the minimum additional bounded clarification needed.
* Do not substitute a staged queue, proposed sequencing, or assistant-chosen first packet for a missing slicing decision.
* Each clarification question must present 2-3 meaningful, mutually exclusive options. Prefer 2 when the choice is truly binary.
* Mark at most one option `(Recommended)` and only when directly visible evidence justifies it.
* Once the immediate packet boundary is settled, emit the final `storage/handoff/PLAN.md`.
* Final `PLAN.md` must include `Summary`, `Key Changes`, `Test Plan`, and `Assumptions`; additional bounded sections are allowed when needed.
* `Explicit immediate packet` means the operator named it; AI inference from topic breadth or evidence does not count as explicit. When in doubt, default to question mode.
* Three or more distinct deliverables in one topic count as multiple independent work families regardless of domain overlap.
* Default to question mode for multi-family topics; only skip the slicing question when the operator's topic text directly names the immediate packet.
* Logic: `PoT.md`. Reference: `docs/MAP.md` and `SoP.md`.
* Structure output for direct operator handoff.

Steps:
0. If attached `storage/handoff/TOPIC.md` is missing: STOP and report the missing topic artifact.
1. Read the attached topic and directly attached bundle evidence first.
2. Determine whether the topic includes multiple independent work families.
3. Determine whether the immediate packet is explicitly identified by the topic, attached evidence, or user priority.
4. If the topic covers multiple work families and the immediate packet is not explicit, ask one slicing or prioritization question first.
5. Do not write a staged queue or final plan before that question is answered unless the immediate packet was already explicit.
6. If narrower ambiguity remains after that, ask the minimum bounded follow-up needed.
7. In question mode:
   * ask the question first
   * do not use a fenced markdown block
   * use 2-3 bounded options
   * do not invent extra branches solely to avoid asking
8. In final plan mode:
   * emit one fenced markdown code block
   * include `Summary`, `Key Changes`, `Test Plan`, and `Assumptions`
   * add only small bounded extra sections when they keep the handoff truthful and narrow

For machine-ingest planning mode: require attached `storage/handoff/TOPIC.md`; do not use inline query fallback.
For machine-ingest planning mode: use attached evidence first.
For machine-ingest planning mode: do not add repository-operating details, workflow examples, command families, or GitHub action lists unless they are directly visible in the attached artifacts.
For machine-ingest planning mode: when the topic is broad, keep repo-specific claims generic and high-level rather than converting thin evidence into specific operating facts.
For machine-ingest planning mode: if the topic spans multiple independent work families and the topic does not explicitly identify the immediate packet, ask one slicing or prioritization question before writing the final plan.
For machine-ingest planning mode: treat the immediate packet as explicit only if the topic directly names the first packet or first work family, the attached evidence directly requires a first packet ordering, or the user explicitly prioritizes one work family.
For machine-ingest planning mode: do not infer or choose the immediate packet unilaterally from repo context alone when multiple work families are in scope.
For machine-ingest planning mode: three or more distinct deliverables in one topic count as multiple independent work families regardless of domain overlap.
For machine-ingest planning mode: do not substitute a staged queue, proposed sequencing, or assistant-chosen first packet for a missing slicing decision.
For machine-ingest planning mode: default to question mode for multi-family topics; only skip the slicing question when the operator's topic text directly names the immediate packet.
For machine-ingest planning mode: when the relevant repo surfaces are directly attached and sufficient, make concrete repo-specific claims grounded in those artifacts instead of retreating to generic high-level language.
For machine-ingest question mode: when clarification is needed, ask the packet-boundary question first without any retired analysis preamble or other required wrapper.
For machine-ingest question mode: allow at most 3 questions; each question must present 2-3 meaningful, mutually exclusive options; prefer the smallest truthful option set and use 3 options only when the third branch is genuinely distinct and evidence-grounded.
For machine-ingest question mode: mark at most one option `(Recommended)` only when attached evidence justifies it.
For machine-ingest question mode: do not invent extra branches solely to satisfy formatting.
For machine-ingest question mode: do not use a fenced markdown code block; fenced markdown remains the final-plan output contract only.
For machine-ingest question mode: if topic text is present but intent cannot be settled from attached evidence, ask the minimum clarifying questions needed rather than forcing a final plan.
For machine-ingest question mode: if topic text is nonsensical or non-actionable, stop at the nearest truthful boundary and ask for clarification.
For final plan mode: output only the complete PLAN markdown code block.
For final plan mode: emit no text before or after the fenced markdown code block.
For final plan mode: keep `Summary`, `Key Changes`, `Test Plan`, and `Assumptions` as required core sections; additional bounded sections are allowed only when needed to keep the handoff truthful and narrow.
For final plan mode: when the needed repo surfaces are directly attached and sufficient, use them to make the handoff concrete rather than artificially flattening the plan to generic language.
For final plan mode: once the immediate packet boundary is settled, emit the final `storage/handoff/PLAN.md`.
{{@include:ops/src/shared/stances.json#non_audit_role_drift_rules}}
