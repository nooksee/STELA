<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Technical Specification: ops/src/stances/consult.md.tpl

## Purpose
Define the template-backed consult stance body used for `consult` profile bundle contract rendering: a bounded question to an external runtime adapter, answered in the consult envelope of `docs/ops/specs/surfaces/consult.md`.

## Invocation
- Canonical render path: `ops/bin/manifest render stance-consult --out=-`
- Runtime consumer: `ops/lib/scripts/bundle.sh`

## Inputs
- Template source: `ops/src/stances/consult.md.tpl`
- Shared include source: `ops/src/shared/stances.json#stance_shared_rules`
- Shared include source: `ops/src/shared/stances.json#single_fence_contract_rules`
- Shared include source: `ops/src/shared/stances.json#non_audit_role_drift_rules`

## Ownership Model
- Runtime owner: `ops/src/stances/consult.md.tpl` plus the included shared contract keys in `ops/src/shared/stances.json`.
- Verifier: `tools/test/bundle.sh --slice=consult-contract` proves the rendered stance reaches the bundle text with its header rule; `tools/lint/response.sh --mode=consult` proves the landed answer.
- Mirror: this spec summarizes the consult contract families and ownership split; it does not override the runtime template.

## Outputs
- Rendered stance body text beginning at `Rules:`.
- No unresolved include directives.
- First non-empty line inside the fenced body must start with `### CONSULT`.
- For machine-ingest consult mode, output must include `## C.1 Question` through `## C.7 Disposition`, once each, in order, none empty, with `Disposition: pending` and `Recorded in: none`.
- No `Decision Required:` or `Decision Leaf:` lines.

## Invariants and failure modes
- Include expansion is strict and fail-closed.
- Unresolved template tokens fail render in strict mode.
- Render output is deterministic for identical repository state.
- The stance states advisory authority in its rules and in C.6; an answer that claims repository authority, proposes repo edits, or claims inspection beyond the attached bundle is out of contract.

## Shipping Spine Position
Consult is a bounded secondary lane: an advisory question transport, not a verdict and not a packet. The consult chain:
1. Operator writes the bounded question to `storage/handoff/QUESTION.md`.
2. Operator runs: `./ops/bin/bundle --profile=consult --intent="CONSULT: <adapter> - <one-line question>" --out=auto`; the adapter must have a source `ops/src/runbook/<adapter>.yaml` with `adapter_class: external-runtime-adapter`.
3. Adapter receives `CONSULT-*.txt` with its package and answers in the consult envelope, C.7 at `pending`.
4. Operator places the answer at `storage/handoff/CONSULT-<adapter>.md` and runs `bash tools/lint/response.sh --mode=consult` on it before reading it for a decision.
5. Operator disposes of the consult and records the disposition in the RESULTS narrative of the packet the consult fed, or in that packet's `op` leaf when the consult changed its scope; never in SoP.md.

The consult lane does not replace RESULTS, CLOSING, or audit truth; its output is subordinate to all three and to Operator approval.

## Related pointers
- `ops/lib/manifests/BUNDLE.md`
- `ops/lib/scripts/bundle.sh`
- `ops/src/stances/consult.md.tpl`
- `docs/ops/specs/surfaces/consult.md`
- `docs/ops/specs/tools/lint/response.md`
