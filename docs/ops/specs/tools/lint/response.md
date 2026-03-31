<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/response.sh` enforces raw-model response envelopes before intake. The goal is to fail malformed or contaminated responses early, before non-canonical payloads reach downstream contract checks. Cross-stance envelope and role-drift convergence freeze is enforced through shared stance contract keys in `ops/src/shared/stances.json`; bounded continuity behavior remains a stance-contract concern rather than a response-envelope concern.

## Mechanics and Sequencing
Modes:
1. `bash tools/lint/response.sh --mode=dp [path|-]` (default mode, default input is stdin).
2. `bash tools/lint/response.sh --mode=audit [path|-]`.
3. `bash tools/lint/response.sh --mode=draft [path|-]`.
4. `bash tools/lint/response.sh --mode=planning [path|-]`.
5. `bash tools/lint/response.sh --mode=addenda [path|-]`.
6. `bash tools/lint/response.sh --mode=conformist [path|-]`.
7. `bash tools/lint/response.sh --test` (runs deterministic fixtures for supported modes).

Deterministic checks:
1. In `dp`, `audit`, `draft`, `addenda`, and `conformist` modes, input must contain exactly one fenced markdown code block.
2. In `dp`, `audit`, `draft`, `addenda`, and `conformist` modes, non-whitespace text outside the fenced block is a hard failure.
3. In `planning` mode, final-plan output uses exactly one fenced markdown code block; clarification output is plain text with no fenced code block.
4. Shared cross-stance freeze is defined in `ops/src/shared/stances.json` using keys `single_fence_contract_rules` and `non_audit_role_drift_rules`.
5. In `dp` mode, extracted body must start with `### DP-` on the first non-empty line.
6. In `audit` mode, extracted body must start with `**AUDIT -` (or `**AUDIT —`) on the first non-empty line.
7. Extracted body must not contain drift tokens:
   - `:contentReference[`
   - `oaicite`
   - `[cite_start]`
   - `[cite:`
   - `[/cite]`
8. In `draft` mode, envelope and DP-start checks are required, plus role-drift rejection:
   - reject audit-verdict marker lines (`**AUDIT -`),
   - reject `## Contractor Execution Narrative`,
   - reject receipt narrative subheadings (`### Preflight State`, `### Implemented Changes`, `### Closeout Notes`, `### Decision Leaf`).
9. In `planning` mode, input is accepted in one of two shapes:
   - final-plan mode: exactly one fenced markdown code block whose extracted body satisfies `bash tools/lint/plan.sh <extracted-body>`, or
   - clarification mode: plain text with no fenced code block; the first non-empty line asks the question; later questions may be plain `...?` lines or numbered `Q<n>. ...?` lines; each question presents 2-3 meaningful mutually exclusive options; the smallest truthful option set is preferred; optional reply instruction lines are allowed.
10. In `planning` mode, reject role-drift markers:
   - audit-verdict markers (`**AUDIT -`),
   - `## Contractor Execution Narrative`,
   - receipt narrative subheadings (`### Preflight State`, `### Implemented Changes`, `### Closeout Notes`, `### Decision Leaf`),
   - audit/addenda decision fields (`Decision Required:`, `Decision Leaf:`),
   - policy-overcompensation prose (`Section 3.4.5`, `RECEIPT_EXTRA`, `ops/src/surfaces/dp.md.tpl`, or fenced-envelope instruction echo text),
   - retired planning question-mode wrappers (`1. Analysis and Discussion`, `2. Decision Questions`, `Questions / Conversation:`).
11. In `dp` mode, on envelope pass, delegate body validation to `bash tools/lint/dp.sh`.
12. In `draft` mode, on envelope pass, delegate body validation to `bash tools/lint/dp.sh`.
13. In `addenda` mode, extracted body must start with `### Addendum` and include required addendum headings:
   - `## A.1 Authorization`
   - `## A.2 Scope Delta`
   - `## A.3 Addendum Objective`
   - `## A.4 Context Load`
   - `## A.5 Addendum Receipt (Proofs to collect) - MUST RUN`
14. In `addenda` mode, reject role-drift markers:
   - audit-verdict markers (`**AUDIT -`),
   - `## Contractor Execution Narrative`,
   - `## Verdict`.
15. In `addenda` mode, if `Decision Required:` and `Decision Leaf:` lines appear, require coherence:
   - `Decision Required: Yes` requires `Decision Leaf: archives/decisions/RoR-*.md`.
   - `Decision Required: No` requires `Decision Leaf: None`.
16. In `conformist` mode, extracted body must start with `### DP-` and reject role-drift markers:
   - audit-verdict markers (`**AUDIT -`),
   - `## Contractor Execution Narrative`,
   - receipt narrative subheadings (`### Preflight State`, `### Implemented Changes`, `### Closeout Notes`, `### Decision Leaf`),
   - addendum headings (`### Addendum`, `## A.1` through `## A.5`),
   - decision fields (`Decision Required:`, `Decision Leaf:`).
17. In `audit` mode, envelope, marker, and drift checks are authoritative.

Exit behavior:
- Pass: prints `OK: response lint passed (mode=<dp|audit|draft|planning|addenda|conformist>)`.
- Fail: prints `FAIL: ...` and exits non-zero.

`--test` fixtures:
- PASS: single fenced block with valid DP envelope (`dp` mode; delegate skipped in self-test fixture for determinism).
- PASS: single fenced block with `**AUDIT -` marker (`audit` mode).
- PASS: single fenced block with valid DP body (`draft` mode).
- PASS: single fenced block with valid final `PLAN` body (`planning` mode).
- PASS: plain-text planning clarification with 2 options (`planning` mode).
- PASS: plain-text planning clarification with 3 options (`planning` mode).
- PASS: plain-text planning clarification with a plain follow-up question after the first question (`planning` mode).
- PASS: single fenced block with addendum headings (`addenda` mode).
- PASS: single fenced block with valid DP heading and no drift markers (`conformist` mode).
- FAIL: text outside fence.
- FAIL: multiple fenced blocks.
- FAIL: drift token present.
- FAIL: citation token drift markers (`[cite_start]`, `[cite:`, `[/cite]`).
- FAIL: non-DP body start (`dp` mode).
- FAIL: plain audit body without fenced block (`audit` mode).
- FAIL: audit preface text outside fence (`audit` mode).
- FAIL: missing audit marker (`audit` mode).
- FAIL: audit citation token (`audit` mode).
- FAIL: draft response containing audit marker (`draft` mode).
- FAIL: draft response containing Contractor Execution Narrative sections (`draft` mode).
- FAIL: planning response containing audit marker (`planning` mode).
- FAIL: planning response containing Contractor Execution Narrative sections (`planning` mode).
- FAIL: planning response containing policy-overcompensation prose (`planning` mode).
- FAIL: planning response using retired question-mode wrapper text (`planning` mode).
- FAIL: planning clarification response with 4 options (`planning` mode).
- FAIL: planning clarification response with more than 3 questions (`planning` mode).
- FAIL: planning response missing both valid clarification-question structure and valid final PLAN structure (`planning` mode).
- FAIL: addenda response containing audit marker (`addenda` mode).
- FAIL: addenda response missing required addendum headings (`addenda` mode).
- FAIL: addenda response with incoherent decision fields (`addenda` mode).
- FAIL: conformist response containing audit marker (`conformist` mode).
- FAIL: conformist response containing addendum heading (`conformist` mode).
- FAIL: conformist response containing decision fields (`conformist` mode).
- FAIL: trailing text outside fence.

## Integrity Filter Warnings
`response.sh` is an ingress contract gate. In `dp`, `draft`, and `conformist` modes, structural DP validation remains authoritative in `tools/lint/dp.sh` after envelope checks. In `audit` mode, strict single-fence envelope checks plus marker and drift checks are the hard floor.
UI-level "thinking" or progress text shown by model hosts is not part of the response payload contract; the payload contract applies to the emitted response body only.
