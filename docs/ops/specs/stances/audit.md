<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Technical Specification: ops/src/stances/audit.md.tpl

## Purpose
Define the template-backed Audit stance body used by bundle output contract rendering.

## Invocation
- Canonical render path: `ops/bin/manifest render stance-audit --out=-`
- Legacy render callers must use `stance-audit`.
- Runtime consumer: `ops/lib/scripts/bundle.sh`

## Inputs
- Template source: `ops/src/stances/audit.md.tpl`
- Shared include source: `ops/src/shared/stances.json#stance_shared_rules`
- Shared include source: `ops/src/shared/stances.json#single_fence_contract_rules`
- TASK evidence source is dump payload context; direct TASK attachment wording is not required.

## Ownership Model
- Runtime owner: `ops/src/stances/audit.md.tpl` plus the included shared contract keys in `ops/src/shared/stances.json`.
- Verifier: `tools/lint/style.sh` guards audit invariant families; it does not need to co-own every sentence of the runtime stance body.
- Mirror: this spec summarizes the audit contract families and ownership split; it does not override the runtime template.

## Verification Order
- `PRECONDITIONS`
- `PoT Compliance`
- `DP Integrity`
- `MACHINE PROVENANCE`
- `CLIPBOARD HYGIENE`
- `ALLOWLIST`
- `DRIFT`
- `GENERATED OUTPUTS`

`MACHINE PROVENANCE` verifies the tool-owned receipt frame: certify provenance, receipt replay structure, lint/hash/integrity outputs, and other deterministic machine signals.

This pass also requires explicit attestations for the currently proven machine-frame failure classes:
- command-log fence integrity inside `## Verification Command Log`
- `3.4.3` delete paths versus `3.2.2` load-order consistency
- allowlist-to-diff cross-reference interpreted through the existing authoritative gate hierarchy

`CLIPBOARD HYGIENE` separately inspects the human-authored fields carried inside or alongside that frame: `## Worker Execution Narrative`, closing-sidecar fields, and when present addendum or decision-leaf bodies. The machine-clean receipt frame does not delegate trust over those prose fields, and an early machine-layer pass signal must not short-circuit that traversal.

This pass now requires two explicit human-authored traversals before verdict:
- claim-by-claim verification for named success claims inside `### Closeout Notes`
- bidirectional reconciliation for `storage/handoff/CLOSING.md` `Confirm Merge (Extended Description)` path lists (`diff \ sidecar` and `sidecar \ diff`)

## Outputs
- Rendered stance body text beginning at `Rules:`.
- No unresolved include directives.
- Output contract requires exactly one fenced markdown code block.
- Output contract requires no text before or after the fenced code block.
- First line must be ```markdown.
- First non-empty line inside the fenced body must start with `**AUDIT -`.
- Last line must be ``` .
- Output contract rejects citation-token strings (`[cite_start]`, `[cite:`, `[/cite]`, `:contentReference[`, `oaicite`).

## Invariants and failure modes
- Include expansion is strict and fail-closed.
- Unresolved template tokens fail render in strict mode.
- Render output is deterministic for identical repository state.
- Verifier ownership stays thinner than runtime ownership: style lint protects audit contract families and critical anchor lines, while the full rendered prose remains owned by the runtime template.
- Audit trust boundaries stay explicit: machine provenance and clipboard hygiene are separate verification surfaces with different failure modes.

## Related pointers
- `ops/lib/manifests/BUNDLE.md`
- `ops/lib/scripts/bundle.sh`
- `ops/src/stances/audit.md.tpl`
