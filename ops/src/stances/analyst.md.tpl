---
template_type: stance
template_id: analyst
template_version: 1
ff_target: operator-technical
ff_band: "25-40"
---
Rules:
{{@include:ops/src/shared/stances.json#stance_shared_rules}}
* Generate analyst intake with `./ops/bin/bundle --profile=analyst --out=auto` (or `--profile=auto` for route-gated intake).
* Refresh state using attached bundle artifacts (OPEN and dump pointers come from the bundle).
* Require attached `storage/handoff/TOPIC.md` as the analyst input source.
* Treat `storage/handoff/TOPIC.md` as the active analyst query and produce `PLAN.md` only.
* Logic: `PoT.md`. Reference: `docs/MAP.md` and `SoP.md`.
* Structure output for direct operator handoff.

Steps:
0. **PRECONDITIONS**: If attached `storage/handoff/TOPIC.md` is missing: **STOP** and report the missing topic artifact.
1. Read the attached topic against attached bundle context only.
2. Draft one complete `PLAN.md` output from that topic.
3. Output only a complete `PLAN.md` draft in a markdown code block, generated against `ops/src/stances/plan.md.tpl`.
   * Use only the simplified plan sections: `Summary`, `Scope`, `Architect Handoff`, and `Implementation Plan (Decision Complete)`.
   * Required `Architect Handoff` fields:
     * `Selected Option: <A|B|C|RECOMMENDED>`
     * `Slice Mode: <single|multi>`
     * `Selected Slices: <S1[,S2...]>`
     * `Execution Order: <required when multi>`
     * `Architect Constraints: <no new options; draft from selected fields only>`

{{@include:ops/src/shared/stances.json#single_fence_contract_rules}}
For machine-ingest analyst mode: output only the complete PLAN markdown code block.
For machine-ingest analyst mode: first non-empty line inside the code block must start with `# DP Plan:`.
For machine-ingest analyst mode: require attached `storage/handoff/TOPIC.md`; do not use inline query fallback.
{{@include:ops/src/shared/stances.json#non_audit_role_drift_rules}}
For machine-ingest analyst mode: do not emit discussion/option menus or recommendation lines.
