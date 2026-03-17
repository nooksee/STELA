<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/open` establishes a verifiable freshness checkpoint before packet execution. It prevents stale-state execution by binding intent, branch, hash, and porcelain status to a timestamped artifact. In bundle-first intake flows, OPEN remains the freshness authority and `ops/bin/bundle` consumes its artifact path and metadata without changing OPEN semantics.

## Mechanics and Sequencing
The binary parses format, intent, DP label, output mode, and optional tag. It emits a new `STELA_TRACE_ID`, reads branch and short hash, and captures porcelain state on every run. If porcelain is non-empty it writes normalized porcelain lines to `storage/handoff/OPEN-PORCELAIN-...txt`. OPEN remains pointer-first: it includes porcelain summary lines and the `Porcelain saved` artifact path, and does not inline full or preview porcelain payload blocks. It validates required canon pointer files, builds an OPEN prompt document with freshness gate data and operational guidance, and wraps the emitted document with canonical marker lines.

Architect path: OPEN detects `storage/handoff/PLAN.md` presence and reflects its status in `[NEXT OPERATOR MOVES]` so the operator can see whether the architect plan input surface is ready. Architect surface details (packet identity, `dp_draft_path`, `closing_sidecar`) are bundle-mediated and appear in the bundle `[REQUEST]` block, not in OPEN output.
- `===== STELA OPEN PROMPT =====`
- `===== END STELA OPEN PROMPT =====`
The legacy wrapper `===== OPEN PROMPT =====` and legacy standalone title line `Stela OPEN PROMPT` are retired. The binary writes the prompt to `storage/handoff/OPEN-...txt`, mirrors prompt content to stdout, and prints `OPEN saved:` only when `--out=auto` is requested. The Next Operator Moves block includes non-blocking guidance for `ops/bin/bundle --profile=auto --out=auto`.

## Anecdotal Anchor
The DP-OPS-0065 freshness gate formalization addressed prior runs where work started from stale local state with no serialized checkpoint. OPEN plus bundle routing in DP-OPS-0145 preserves this checkpoint while reducing ad hoc operator assembly steps.

## Integrity Filter Warnings
`ops/bin/open` exits on unknown arguments, missing required canon files, or git command failures. It writes artifacts in `storage/handoff` and does not mutate tracked canon files. Dirty sessions produce an OPEN-PORCELAIN artifact and OPEN references that path without duplicating the detailed payload inline. Clean sessions suppress porcelain artifact creation by design.
