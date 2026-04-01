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
* Primary output is the final `storage/handoff/PLAN.md`; planning does not execute implementation.
* Emit the final `storage/handoff/PLAN.md` when remaining ambiguity no longer materially changes the immediate packet boundary or implementation handoff.
* When ambiguity remains, present 2-3 bounded options to resolve it.
* If the topic spans multiple independent work families, ask one slicing question or emit a staged queue with an explicit immediate packet and deferred packets.
* Final `PLAN.md` must include `Summary`, `Key Changes`, `Test Plan`, and `Assumptions`; additional bounded sections are allowed when needed.
* Logic: `PoT.md`. Reference: `docs/MAP.md` and `SoP.md`.
* Structure output for direct operator handoff.

Steps:
0. **PRECONDITIONS**: If attached `storage/handoff/TOPIC.md` is missing: **STOP** and report the missing topic artifact.
1. Read the attached topic and directly attached bundle evidence first.
2. If remaining ambiguity materially changes the immediate packet boundary or implementation handoff, ask the minimum bounded clarification needed instead of forcing a final plan.
3. In question mode:
   * Ask the question first.
   * Allow at most 3 questions. Each question must present 2-3 meaningful, mutually exclusive options. Prefer the smallest truthful option set: use 2 options for a real binary choice and 3 only when the third branch is genuinely distinct and evidence-grounded.
   * Mark at most one option `(Recommended)` and only when attached evidence actually justifies it.
   * Do not invent extra branches solely to satisfy formatting.
   * Do not use a fenced markdown block.
4. In final plan mode:
   * Emit the final plan in one fenced markdown code block generated against `ops/src/stances/plan.md.tpl`.
   * Keep `Summary`, `Key Changes`, `Test Plan`, and `Assumptions` as required core sections; add a small extra section only when it is needed to keep the handoff truthful and narrow.
   * Make the handoff decision-complete enough for direct draft drafting.

For machine-ingest planning mode: require attached `storage/handoff/TOPIC.md`; do not use inline query fallback.
For machine-ingest planning mode: use attached evidence first.
For machine-ingest planning mode: do not add repository-operating details, workflow examples, command families, or GitHub action lists unless they are directly visible in the attached artifacts.
For machine-ingest planning mode: when the topic is broad, keep repo-specific claims generic and high-level rather than converting thin evidence into specific operating facts.
For machine-ingest planning mode: when a topic spans multiple independent work families, do not force one omnibus first packet; ask one slicing question or emit a staged queue with an explicit immediate packet and deferred packets.
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
For final plan mode: emit the final plan when remaining ambiguity no longer materially changes the immediate packet boundary or implementation handoff.
{{@include:ops/src/shared/stances.json#non_audit_role_drift_rules}}
