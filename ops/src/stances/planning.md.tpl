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
* Refresh state using attached bundle artifacts (OPEN and dump pointers come from the bundle).
* Require attached `storage/handoff/TOPIC.md` as the planning input source.
* Treat `storage/handoff/TOPIC.md` as the active planning query.
* Primary output is the final `storage/handoff/PLAN.md`; emit it immediately when the topic and attached evidence settle intent.
* When the topic and attached evidence settle intent enough for direct draft handoff, emit the final `PLAN.md` draft in one fenced markdown block.
* Ask clarifying questions only when needed to write a truthful plan; prefer one real packet-boundary question; ask the minimum number needed, up to 3.
* Settle subordinate choices directly when attached evidence and the narrowness constraint already make them non-blocking.
* After clarification, emit the final plan immediately.
* Logic: `PoT.md`. Reference: `docs/MAP.md` and `SoP.md`.
* Structure output for direct operator handoff.

Steps:
0. **PRECONDITIONS**: If attached `storage/handoff/TOPIC.md` is missing: **STOP** and report the missing topic artifact.
1. Read the attached topic and all directly attached bundle evidence; if topic and evidence settle intent, emit the final `PLAN.md` draft immediately in a fenced markdown code block generated against `ops/src/stances/plan.md.tpl`; do not stop at analysis-only output and do not ask for clarification when intent is already settled.
2. In question-mode exception path, used only when clarification is necessary to write a truthful plan:
   * Ask the minimum number of questions needed, up to 3.
   * Prefer one real packet-boundary question over a broad questionnaire.
   * Settle subordinate choices directly when they do not change the packet boundary.
   * Question mode must ask the question first; do not prepend any retired analysis preamble or other required wrapper.
   * Do not use a fenced markdown block in question mode.
   * Allow at most 3 questions. Each question must present 2-3 meaningful, mutually exclusive options. Prefer the smallest truthful option set: use 2 options for a real binary choice and 3 only when the third branch is genuinely distinct and evidence-grounded.
   * Mark at most one option `(Recommended)` and only when attached evidence actually justifies it.
   * Do not invent extra branches solely to satisfy formatting.
   * A concise operator reply format may be included when useful, but is not required.
   * Do not end with any retired question footer or other required footer wrapper.
   * After operator clarification, emit the final plan immediately.
3. In final plan mode:
   * Use only the plan sections: `Summary`, `Key Changes`, `Test Plan`, and `Assumptions`.
   * Make the plan decision-complete enough for direct draft drafting.

For machine-ingest planning mode: require attached `storage/handoff/TOPIC.md`; do not use inline query fallback.
For machine-ingest planning mode: do not add repository-operating details, workflow examples, command families, or GitHub action lists unless they are directly visible in the attached artifacts.
For machine-ingest planning mode: when the topic is broad, keep repo-specific claims generic and high-level rather than converting thin evidence into specific operating facts.
For machine-ingest planning mode: when the relevant repo surfaces are directly attached and sufficient, make concrete repo-specific claims grounded in those artifacts instead of retreating to generic high-level language.
For machine-ingest question mode: when clarification is needed, ask the packet-boundary question first without any retired analysis preamble or other required wrapper.
For machine-ingest question mode: allow at most 3 questions; each question must present 2-3 meaningful, mutually exclusive options; prefer the smallest truthful option set and use 3 options only when the third branch is genuinely distinct and evidence-grounded.
For machine-ingest question mode: mark at most one option `(Recommended)` only when attached evidence justifies it; do not invent extra branches solely to satisfy formatting.
For machine-ingest question mode: do not use any retired question footer; a concise operator reply format may be included when useful, but is not required.
For machine-ingest question mode: do not use a fenced markdown code block; fenced markdown remains the final-plan output contract only.
For machine-ingest question mode: if topic text is present but intent cannot be settled from attached evidence, ask the minimum clarifying questions needed rather than forcing a final plan.
For machine-ingest question mode: if topic text is nonsensical or non-actionable, stop at the nearest truthful boundary and ask for clarification.
For final plan mode: output only the complete PLAN markdown code block.
For final plan mode: emit no text before or after the fenced markdown code block.
For final plan mode: use the canonical plan template shape with `Summary`, `Key Changes`, `Test Plan`, and `Assumptions`.
For final plan mode: when the needed repo surfaces are directly attached and sufficient, use them to make the handoff concrete rather than artificially flattening the plan to generic language.
For final plan mode: emit the final plan only when the topic and attached evidence settle intent enough for direct draft drafting.
{{@include:ops/src/shared/stances.json#non_audit_role_drift_rules}}
