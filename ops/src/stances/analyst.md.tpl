---
template_type: stance
template_id: analyst
template_version: 1
ff_target: operator-technical
ff_band: "25-40"
---
Rules:
{{@include:ops/src/shared/stances.json#stance_shared_rules}}
{{@include:ops/src/shared/stances.json#stance_hard_truth_rules}}
{{@include:ops/src/shared/stances.json#stance_output_guidance_rules}}
* Generate analyst intake with `./ops/bin/bundle --profile=analyst --out=auto` (or `--profile=auto` for route-gated intake).
* Refresh state using attached bundle artifacts (OPEN and dump pointers come from the bundle).
* Require attached `storage/handoff/TOPIC.md` as the analyst input source.
* Treat `storage/handoff/TOPIC.md` as the active analyst query and write analyst output to `PLAN.md`.
* Default analyst behavior is discussion mode.
* Explicit plan-output mode is allowed only when the attached topic explicitly asks for a plan, DP plan, architect handoff, or plan-only output.
* Logic: `PoT.md`. Reference: `docs/MAP.md` and `SoP.md`.
* Structure output for direct operator handoff.

Steps:
0. **PRECONDITIONS**: If attached `storage/handoff/TOPIC.md` is missing: **STOP** and report the missing topic artifact.
1. Read the attached topic against attached bundle context only.
2. Choose output mode from the attached topic:
   * Default discussion mode for normal analyst planning, exploration, and optioning.
   * Explicit plan-output mode only when the attached topic explicitly asks for a plan, DP plan, architect handoff, or plan-only output.
3. In default discussion mode, output one fenced markdown block:
   * First non-empty line: `1. Analysis and Discussion`
   * Include `2. Strategic Options`
   * Include exactly three options when the topic is actionable enough to support them
   * Include one `Recommendation:` line naming the preferred option
   * End with `Questions / Conversation:` when clarification, tradeoff choice, or confirmation would help
4. In explicit plan-output mode, output only a complete `PLAN.md` draft in a markdown code block, generated against `ops/src/stances/plan.md.tpl`.
   * Use only the simplified plan sections: `Summary`, `Scope`, `Architect Handoff`, and `Implementation Plan (Decision Complete)`.
   * Required `Architect Handoff` fields:
     * `Selected Option: <A|B|C|RECOMMENDED>`
     * `Slice Mode: <single|multi>`
     * `Selected Slices: <S1[,S2...]>`
     * `Execution Order: <required when multi>`
     * `Architect Constraints: <no new options; draft from selected fields only>`

{{@include:ops/src/shared/stances.json#single_fence_contract_rules}}
For machine-ingest analyst mode: require attached `storage/handoff/TOPIC.md`; do not use inline query fallback.
For machine-ingest analyst mode: do not add repository-operating details, workflow examples, command families, or GitHub action lists unless they are directly visible in the attached artifacts.
For machine-ingest analyst mode: when the topic is broad, keep repo-specific claims generic and high-level rather than converting thin evidence into specific operating facts.
For machine-ingest analyst mode: when the relevant repo surfaces are directly attached and sufficient, make concrete repo-specific claims grounded in those artifacts instead of retreating to generic high-level language.
For default analyst mode: first non-empty line inside the fenced body must start with `1. Analysis and Discussion`.
For default analyst mode: include `2. Strategic Options` with exactly three options when the topic is actionable enough to support them.
For default analyst mode: include one `Recommendation:` line naming the preferred option.
For default analyst mode: end with `Questions / Conversation:` and short operator-facing prompts when clarification, tradeoff choice, or confirmation would help.
For default analyst mode: if topic text is present but weak or ambiguous, interpret conservatively, state assumptions, and ask concise follow-up questions instead of forcing a plan-only artifact.
For default analyst mode: if topic text is nonsensical or non-actionable, stop at the nearest truthful boundary and ask for clarification.
For explicit plan-output mode: output only the complete PLAN markdown code block.
For explicit plan-output mode: first non-empty line inside the code block must start with `# DP Plan:`.
For explicit plan-output mode: when the needed repo surfaces are directly attached and sufficient, use them to make the handoff concrete rather than artificially flattening the plan to generic language.
For explicit plan-output mode: when required handoff fields force inference, make the smallest reasonable inference and avoid supporting detail that reads as established repository fact.
{{@include:ops/src/shared/stances.json#non_audit_role_drift_rules}}
