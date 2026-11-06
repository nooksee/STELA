<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/response.sh` enforces raw-model response envelopes before intake. The goal is to fail malformed or contaminated responses early, before non-canonical payloads reach downstream contract checks. Cross-stance envelope and role-drift convergence freeze is enforced through shared stance contract keys in `ops/src/shared/stances.json`; bounded continuity behavior remains a stance-contract concern rather than a response-envelope concern. The verifier owns repeated ingress helpers once, then layers bounded mode-specific rules on top, so shared response-surface checks do not have to be re-stated per mode.

## Mechanics and Sequencing
Modes:
1. `bash tools/lint/response.sh --mode=dp [path|-]` (default mode, default input is stdin).
2. `bash tools/lint/response.sh --mode=audit [path|-]`.
3. `bash tools/lint/response.sh --mode=draft [path|-]`.
4. `bash tools/lint/response.sh --mode=planning [path|-]`.
5. `bash tools/lint/response.sh --mode=addenda [path|-]`.
6. `bash tools/lint/response.sh --mode=execution-decision [path|-]`.
7. `bash tools/lint/response.sh --mode=consult [path|-]`.
8. `bash tools/lint/response.sh --test` (runs deterministic fixtures for supported modes).

Deterministic checks:
1. In `dp`, `audit`, `draft`, `addenda`, `execution-decision`, and `consult` modes, input must contain exactly one fenced markdown code block.
2. In `dp`, `audit`, `draft`, `addenda`, `execution-decision`, and `consult` modes, non-whitespace text outside the fenced block is a hard failure.
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
8. In `draft` mode, envelope and DP-start checks are required, plus the full non-audit receipt-drift family:
   - reject audit-verdict marker lines (`**AUDIT -`),
   - reject `## Worker Execution Narrative`,
   - reject receipt narrative subheadings (`### Preflight State`, `### Implemented Changes`, `### Closeout Notes`, `### Decision Leaf`).
9. In `planning` mode, input is accepted in one of two shapes:
   - final-plan mode: exactly one fenced markdown code block whose extracted body satisfies `bash tools/lint/plan.sh <extracted-body>`, or
   - clarification mode: plain text with no fenced code block; the first non-empty line asks the question; later questions may be plain `...?` lines or numbered `Q<n>. ...?` lines; option lines remain option lines even if their text ends in `?`; each question must use the ordered short standalone `A.` / `B.` / `C.` set, where `C.` is the fixed redirect line `C. Tell Analyst to do something else instead.`; only substantive `A.` / `B.` lines may be marked `(Recommended)`; reply-instruction lines are not part of the popup-biased transport.
10. In `planning` mode, reuse the same non-audit receipt-drift family as `draft`, then add planning-only rejections for:
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
14. In `addenda` mode, reuse the shared non-audit audit-marker / worker-narrative rejection subset, then add the addenda-only verdict-section rejection:
   - audit-verdict markers (`**AUDIT -`),
   - `## Worker Execution Narrative`,
   - `## Verdict`.
15. In `addenda` mode, if `Decision Required:` and `Decision Leaf:` lines appear, require coherence:
   - `Decision Required: Yes` requires `Decision Leaf: archives/decisions/RoR-*.md`.
   - `Decision Required: No` requires `Decision Leaf: None`.
16. In `execution-decision` mode, input must contain one fenced markdown code block whose body includes the required constraint labels and at least one complete step block.
17. In `audit` mode, envelope, marker, and drift checks are authoritative.
18. In `consult` mode, extracted body must start with `### CONSULT <adapter> <YYYY-MM-DD>` where `ops/src/runbook/<adapter>.yaml` exists with `adapter_class: external-runtime-adapter`, and must include each of `## C.1 Question`, `## C.2 Attachments`, `## C.3 Context Mode`, `## C.4 Findings`, `## C.5 Recommendation`, `## C.6 Authority`, `## C.7 Disposition` exactly once, in that order, none empty.
19. In `consult` mode, field rules: `## C.2 Attachments` declares `Budget: <non-negative integer>` and lists no more `- ` items than the budget (`- none` is not counted); `## C.3 Context Mode` reads exactly `in_thread` or `fresh_thread`; `## C.6 Authority` contains the sentence `Advisory. Subordinate to RESULTS, CLOSING, audit verdicts, and Operator approval.`; `## C.7 Disposition` carries `Disposition:` (`adopt`, `adapt`, `reject`, `pending`) and `Recorded in:` with coherence: `pending` requires `none`; `adopt` and `adapt` require `RESULTS narrative of DP-OPS-NNNN` or `archives/decisions/RoR-*-op-NNNN.md`; `reject` accepts `none` or either pointer.
20. In `consult` mode, reuse the non-audit receipt-drift family (audit-verdict marker, `## Worker Execution Narrative`, receipt narrative subheadings) and reject `Decision Required:` and `Decision Leaf:` lines; the surface contract is `docs/ops/specs/surfaces/consult.md`.

Exit behavior:
- Pass: prints `OK: response lint passed (mode=<dp|audit|draft|planning|addenda|execution-decision|consult>)`.
- Fail: prints `FAIL: ...` and exits non-zero.

`--test` fixtures:
- PASS: single fenced block with valid DP envelope (`dp` mode; delegate skipped in self-test fixture for determinism).
- PASS: single fenced block with `**AUDIT -` marker (`audit` mode).
- PASS: single fenced block with valid DP body (`draft` mode).
- PASS: single fenced block with valid final `PLAN` body (`planning` mode).
- PASS: plain-text planning clarification with popup-biased `A.` / `B.` / `C.` options and fixed Analyst redirect (`planning` mode).
- PASS: plain-text planning clarification with popup-biased `A.` / `B.` / `C.` options and one substantive `(Recommended)` marker (`planning` mode).
- PASS: plain-text planning clarification with a plain follow-up question after the first question (`planning` mode).
- PASS: plain-text planning clarification where an option line ends in `?` (`planning` mode).
- PASS: single fenced block with addendum headings (`addenda` mode).
- PASS: single fenced block with required constraint labels and one complete step block (`execution-decision` mode).
- PASS: single fenced block with the consult header, seven sections in order, budget-bounded attachments, a named context mode, the authority sentence, and a coherent pending disposition (`consult` mode).
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
- FAIL: draft response containing Worker Execution Narrative sections (`draft` mode).
- FAIL: planning response containing audit marker (`planning` mode).
- FAIL: planning response containing Worker Execution Narrative sections (`planning` mode).
- FAIL: planning response containing policy-overcompensation prose (`planning` mode).
- FAIL: planning response using retired question-mode wrapper text (`planning` mode).
- FAIL: planning clarification response with 4 options (`planning` mode).
- FAIL: planning clarification response with a non-canonical redirect option (`planning` mode).
- FAIL: planning clarification response with a reply-instruction line (`planning` mode).
- FAIL: planning clarification response with more than 3 questions (`planning` mode).
- FAIL: planning response missing both valid clarification-question structure and valid final PLAN structure (`planning` mode).
- FAIL: addenda response containing audit marker (`addenda` mode).
- FAIL: addenda response missing required addendum headings (`addenda` mode).
- FAIL: addenda response with incoherent decision fields (`addenda` mode).
- FAIL: execution-decision response missing one required constraint label (`execution-decision` mode).
- FAIL: execution-decision response missing a complete seven-label step block (`execution-decision` mode).
- FAIL: consult response missing a required section (`consult` mode).
- FAIL: consult response with sections out of order (`consult` mode).
- FAIL: consult response with an empty section (`consult` mode).
- FAIL: consult response listing more attachments than its budget (`consult` mode).
- FAIL: consult response with an unknown context mode (`consult` mode).
- FAIL: consult response without the authority sentence (`consult` mode).
- FAIL: consult response with `adopt` and `Recorded in: none` (`consult` mode).
- FAIL: consult response naming a header adapter with no external-runtime-adapter source (`consult` mode).
- FAIL: consult response carrying `Decision Required:` and `Decision Leaf:` fields (`consult` mode).
- FAIL: trailing text outside fence.

## Integrity Filter Warnings
`response.sh` is an ingress contract gate. In `dp` and `draft` modes, structural DP validation remains authoritative in `tools/lint/dp.sh` after envelope checks. In `audit` mode, strict single-fence envelope checks plus marker and drift checks are the hard floor. In `consult` mode, a passing artifact is still advisory; the lint proves shape and coherence, not the disposition itself, which lives in the RESULTS narrative or an `op` leaf.
UI-level "thinking" or progress text shown by model hosts is not part of the response payload contract; the payload contract applies to the emitted response body only.
