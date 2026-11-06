<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Surface Specification: CONSULT

## Constitutional Anchor
`storage/handoff/CONSULT-<adapter>.md` is the landing surface for a bounded question put to an external runtime adapter (`ops/src/runbook/gpt.yaml`, `ops/src/runbook/claude.yaml`, `ops/src/runbook/gemini.yaml`). Latest-wins per adapter; disposable; git-ignored under `storage/handoff/`. One schema serves every adapter: adapters differ in role, not in what a bounded question needs.

## Operator Contract
- Transport: `./ops/bin/bundle --profile=consult --intent="CONSULT: <adapter> - <one-line question>" --out=auto` ships `storage/handoff/QUESTION.md`, the core dump, and the consult stance as `CONSULT-*.txt`, naming the attachment budget (`docs/ops/specs/stances/consult.md`).
- Placement: manual. Operator pastes the adapter's fenced response to `storage/handoff/CONSULT-<adapter>.md`; `<adapter>` is the adapter source basename (`gpt`, `claude`, `gemini`).
- Validator: `bash tools/lint/response.sh --mode=consult storage/handoff/CONSULT-<adapter>.md`, before the artifact is read for a decision.
- Envelope: exactly one fenced markdown code block; nothing outside it.
- First line: `### CONSULT <adapter> <YYYY-MM-DD>`; `<adapter>` must have a source under `ops/src/runbook/` with `adapter_class: external-runtime-adapter`.
- Sections, each present once, in this order, none empty:
  - `## C.1 Question`: the bounded question, as asked.
  - `## C.2 Attachments`: `Budget: <count>`, then one `- <path or name>` line per attachment (`- none` at budget zero). More items than the budget fails.
  - `## C.3 Context Mode`: exactly `in_thread` (delta context, running thread) or `fresh_thread` (rehydration context, new thread).
  - `## C.4 Findings`: what the adapter found, with evidence basis.
  - `## C.5 Recommendation`: what the adapter proposes.
  - `## C.6 Authority`: the sentence `Advisory. Subordinate to RESULTS, CLOSING, audit verdicts, and Operator approval.`
  - `## C.7 Disposition`: `Disposition: adopt|adapt|reject|pending` and `Recorded in: <pointer>`.
- Authorship: adapter emits C.1 to C.6 and leaves C.7 at `pending` with `Recorded in: none`; operator overwrites both C.7 lines at disposal.
- Disposition record rule: consult fed a packet, record in that packet's RESULTS worker narrative (`Recorded in: RESULTS narrative of DP-OPS-NNNN`); consult changed packet scope, record in that packet's `op` decision leaf (`Recorded in: archives/decisions/RoR-<date>-<seq>-op-NNNN.md`); rejected consult may stay at `none`. SoP.md is never the disposition record.
- Coherence enforced: `pending` requires `none`; `adopt` and `adapt` require a RESULTS narrative pointer or an `op` leaf path; `reject` accepts `none` or either pointer.
- Rejected in the body: audit verdict markers, `## Worker Execution Narrative`, receipt narrative subheadings, `Decision Required:` and `Decision Leaf:` fields, shared drift tokens.

## Mechanics and Sequencing
1. Operator writes the bounded question to `storage/handoff/QUESTION.md` and ships it with the consult bundle profile; the bundle declares the attachment budget.
2. Adapter answers in the envelope above; disposition stays `pending`.
3. Operator places the response at `storage/handoff/CONSULT-<adapter>.md` and runs the validator. A failing artifact is not read for a decision.
4. Operator disposes of the consult, records the disposition per the rule above, updates both C.7 lines, runs the validator again.
5. Artifact stays disposable. Nothing under `storage/handoff/` is committed; the record is the RESULTS narrative or the `op` leaf, never the artifact.

## Failure States and Drift Triggers
- Consult artifact cited as authority for scope or verdict. Authority stays with the packet, RESULTS, CLOSING, audit, operator approval.
- Disposition recorded only in SoP.md or only in the artifact.
- Attachments beyond the declared budget; budget not a non-negative integer.
- Context mode outside the two named values.
- Envelope carrying decision fields, an audit marker, or receipt narrative structure.
- Header adapter with no external-runtime-adapter source under `ops/src/runbook/`.

## Related Pointers
- `docs/ops/specs/tools/lint/response.md`
- `docs/ops/specs/stances/consult.md`
- `docs/ops/specs/runbook/gemini.md`
- `docs/ops/registry/runbook.md`
- `docs/MANUAL.md` (Consult Handling)
