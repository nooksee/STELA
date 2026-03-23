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
* Default planning behavior is conversational planning.
* When the topic and attached evidence settle intent enough for direct draft handoff, emit the final `PLAN.md` draft in one fenced markdown block.
* Logic: `PoT.md`. Reference: `docs/MAP.md` and `SoP.md`.
* Structure output for direct operator handoff.

Steps:
0. **PRECONDITIONS**: If attached `storage/handoff/TOPIC.md` is missing: **STOP** and report the missing topic artifact.
1. Read the attached topic and all directly attached bundle evidence before reaching any conclusion or asking any question.
2. Apply the material-ambiguity threshold:
   * If a gap is low-impact, choose the smallest justified assumption and proceed without asking.
   * If a gap would materially change the plan, stay in question mode.
   * If intent is fully settled, emit only a complete `PLAN.md` draft in a markdown code block generated against `ops/src/stances/plan.md.tpl`.
3. In conversational planning mode, output one fenced markdown block:
   * First non-empty line: `1. Analysis and Discussion`
   * Add a `2. Decision Questions` section when questions are needed.
   * Allow at most 3 questions. Each question must present exactly 3 meaningful, mutually exclusive options. Mark exactly one option `(Recommended)`. If 3 real options do not exist, make the smallest justified assumption instead of asking.
   * Include a concise operator response format after the options such as `Q1:A, Q2:C` or `Use recommended options`.
   * End with `Questions / Conversation:`.
4. In final plan mode:
   * Use only the plan sections: `Summary`, `Key Changes`, `Test Plan`, and `Assumptions`.
   * Make the plan decision-complete enough for direct draft drafting.

Canonical question-mode format (worker must implement lint against this exact shape):
```
1. Analysis and Discussion
<analysis prose>

2. Decision Questions

Q1. <question text>
- A. <option text>
- B. <option text> (Recommended)
- C. <option text>

Q2. <question text>
- A. <option text>
- B. <option text>
- C. <option text> (Recommended)

Questions / Conversation:
Q1:B, Q2:C — or: Use recommended options
```
Lint patterns: questions are `Q1.`/`Q2.`/`Q3.` prefixed lines; options are `- A.`/`- B.`/`- C.` bullets; `(Recommended)` appears inline at end of exactly one option line per question.

{{@include:ops/src/shared/stances.json#single_fence_contract_rules}}
For machine-ingest planning mode: require attached `storage/handoff/TOPIC.md`; do not use inline query fallback.
For machine-ingest planning mode: do not add repository-operating details, workflow examples, command families, or GitHub action lists unless they are directly visible in the attached artifacts.
For machine-ingest planning mode: when the topic is broad, keep repo-specific claims generic and high-level rather than converting thin evidence into specific operating facts.
For machine-ingest planning mode: when the relevant repo surfaces are directly attached and sufficient, make concrete repo-specific claims grounded in those artifacts instead of retreating to generic high-level language.
For conversational planning mode: first non-empty line inside the fenced body must start with `1. Analysis and Discussion`.
For conversational planning mode: when asking questions, use a `2. Decision Questions` section; allow at most 3 questions; each question must present exactly 3 meaningful options with one marked `(Recommended)`; end with `Questions / Conversation:` and a concise operator response format such as `Q1:A, Q2:C` or `Use recommended options`.
For conversational planning mode: if topic text is present but weak or ambiguous, interpret conservatively, state assumptions, and ask concise follow-up questions instead of forcing a final plan.
For conversational planning mode: if topic text is nonsensical or non-actionable, stop at the nearest truthful boundary and ask for clarification.
For final plan mode: output only the complete PLAN markdown code block.
For final plan mode: use the canonical plan template shape with `Summary`, `Key Changes`, `Test Plan`, and `Assumptions`.
For final plan mode: when the needed repo surfaces are directly attached and sufficient, use them to make the handoff concrete rather than artificially flattening the plan to generic language.
For final plan mode: emit the final plan only when the topic and attached evidence settle intent enough for direct draft drafting.
{{@include:ops/src/shared/stances.json#non_audit_role_drift_rules}}
