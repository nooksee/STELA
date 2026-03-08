<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/response.sh` enforces raw-model response envelopes before intake. The goal is to fail malformed or contaminated responses early, before non-canonical payloads reach downstream contract checks. Cross-stance convergence freeze is enforced through shared stance contract keys in `ops/src/shared/stances.json`.

## Mechanics and Sequencing
Modes:
1. `bash tools/lint/response.sh --mode=dp [path|-]` (default mode, default input is stdin).
2. `bash tools/lint/response.sh --mode=audit [path|-]`.
3. `bash tools/lint/response.sh --mode=architect [path|-]`.
4. `bash tools/lint/response.sh --mode=analyst [path|-]`.
5. `bash tools/lint/response.sh --mode=foreman [path|-]`.
6. `bash tools/lint/response.sh --mode=conformist [path|-]`.
7. `bash tools/lint/response.sh --test` (runs deterministic fixtures for supported modes).

Deterministic checks:
1. In `dp`, `audit`, `architect`, `analyst`, `foreman`, and `conformist` modes, input must contain exactly one fenced markdown code block.
2. In `dp`, `audit`, `architect`, `analyst`, `foreman`, and `conformist` modes, non-whitespace text outside the fenced block is a hard failure.
3. Shared cross-stance freeze is defined in `ops/src/shared/stances.json` using keys `single_fence_contract_rules` and `non_audit_role_drift_rules`.
4. In `dp` mode, extracted body must start with `### DP-` on the first non-empty line.
5. In `audit` mode, extracted body must start with `**AUDIT -` (or `**AUDIT —`) on the first non-empty line.
6. Extracted body must not contain drift tokens:
   - `:contentReference[`
   - `oaicite`
   - `Show more`
   - `[cite_start]`
   - `[cite:`
   - `[/cite]`
   - `user prompt is empty`
   - `reading documents`
   - `running command`
7. In `architect` mode, envelope and DP-start checks are required, plus role-drift rejection:
   - reject audit-verdict marker lines (`**AUDIT -`),
   - reject `## Contractor Execution Narrative`,
   - reject receipt narrative subheadings (`### Preflight State`, `### Implemented Changes`, `### Closeout Notes`, `### Decision Leaf`).
8. In `analyst` mode, extracted body must start with `1. Analysis and Discussion` (markdown heading prefix optional).
9. In `analyst` mode, extracted body must include `2. Strategic Options` and an explicit recommendation line.
10. In `analyst` mode, reject role-drift markers:
   - audit-verdict markers (`**AUDIT -`),
   - `## Contractor Execution Narrative`,
   - receipt narrative subheadings (`### Preflight State`, `### Implemented Changes`, `### Closeout Notes`, `### Decision Leaf`),
   - audit/foreman decision fields (`Decision Required:`, `Decision Leaf:`),
   - policy-overcompensation prose (`Section 3.4.5`, `RECEIPT_EXTRA`, `ops/src/surfaces/dp.md.tpl`, or fenced-envelope instruction echo text).
11. In `dp` mode, on envelope pass, delegate body validation to `bash tools/lint/dp.sh`.
12. In `architect` mode, on envelope pass, delegate body validation to `bash tools/lint/dp.sh`.
13. In `foreman` mode, extracted body must start with `### Addendum` and include required addendum headings:
   - `## A.1 Authorization`
   - `## A.2 Scope Delta`
   - `## A.3 Addendum Objective`
   - `## A.4 Context Load`
   - `## A.5 Addendum Receipt (Proofs to collect) - MUST RUN`
14. In `foreman` mode, reject role-drift markers:
   - audit-verdict markers (`**AUDIT -`),
   - `## Contractor Execution Narrative`,
   - `## Verdict`.
15. In `foreman` mode, if `Decision Required:` and `Decision Leaf:` lines appear, require coherence:
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
- Pass: prints `OK: response lint passed (mode=<dp|audit|architect|analyst|foreman|conformist>)`.
- Fail: prints `FAIL: ...` and exits non-zero.

`--test` fixtures:
- PASS: `tools/lint/dp.sh --test` succeeds (delegate health check).
- PASS: single fenced block with valid DP envelope (`dp` mode; delegate skipped in self-test fixture for determinism).
- PASS: single fenced block with `**AUDIT -` marker (`audit` mode).
- PASS: single fenced block with valid DP body (`architect` mode).
- PASS: single fenced block with analyst sections and recommendation (`analyst` mode).
- PASS: single fenced block with addendum headings (`foreman` mode).
- PASS: single fenced block with valid DP heading and no drift markers (`conformist` mode).
- FAIL: text outside fence.
- FAIL: multiple fenced blocks.
- FAIL: drift token present.
- FAIL: citation token drift markers (`[cite_start]`, `[cite:`, `[/cite]`).
- FAIL: non-DP body start (`dp` mode).
- FAIL: plain audit body without fenced block (`audit` mode).
- FAIL: audit preface text outside fence (`audit` mode).
- FAIL: missing audit marker (`audit` mode).
- FAIL: audit meta chatter token (`audit` mode).
- FAIL: audit citation token (`audit` mode).
- FAIL: architect response containing audit marker (`architect` mode).
- FAIL: architect response containing Contractor Execution Narrative sections (`architect` mode).
- FAIL: analyst response containing audit marker (`analyst` mode).
- FAIL: analyst response containing Contractor Execution Narrative sections (`analyst` mode).
- FAIL: analyst response containing policy-overcompensation prose (`analyst` mode).
- FAIL: analyst response missing required strategic-options section (`analyst` mode).
- FAIL: foreman response containing audit marker (`foreman` mode).
- FAIL: foreman response missing required addendum headings (`foreman` mode).
- FAIL: foreman response with incoherent decision fields (`foreman` mode).
- FAIL: conformist response containing audit marker (`conformist` mode).
- FAIL: conformist response containing addendum heading (`conformist` mode).
- FAIL: conformist response containing decision fields (`conformist` mode).
- FAIL: trailing text outside fence.

## Anecdotal Anchor
DP drafting regressions showed repeated model output drift where correct content was wrapped with extra commentary or non-canonical fragments. Envelope gating isolates that class of failure at ingress.

## Integrity Filter Warnings
`response.sh` is an ingress contract gate. In `dp`, `architect`, and `conformist` modes, structural DP validation remains authoritative in `tools/lint/dp.sh` after envelope checks. In `audit` mode, strict single-fence envelope checks plus marker and drift checks are the hard floor.
UI-level "thinking" or progress text shown by model hosts is not part of the response payload contract; the payload contract applies to the emitted response body only.
