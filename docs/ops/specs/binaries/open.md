<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/open` establishes a verifiable freshness checkpoint before packet execution. It prevents stale-state execution by binding intent, branch, hash, trace id, and porcelain status to a serialized OPEN artifact. In bundle-first intake flows, OPEN remains the packet-start freshness authority and `ops/bin/bundle` consumes its artifact path and metadata without inventing a second authority. When the current branch/head lacks a matching OPEN artifact, bundle refreshes one through `ops/bin/open` instead of inventing a pseudo-OPEN trace id.

## OPEN Trace Dependency
`ops/bin/certify` requires a `STELA_TRACE_ID` to generate archive surface leaves. For standard packets it now prefers the opening OPEN trace id recorded in packet truth. The fallback order remains: (1) the `STELA_TRACE_ID` environment variable, or (2) the current `storage/handoff/OPEN-*.txt` artifact when packet-bound anchor data is unavailable. Running `./ops/bin/open --out=auto` before bundle-first drafting remains the standard method for establishing trace continuity. Bundle transport may quote OPEN metadata, but the packet-bound opening OPEN remains the authority for packet start.

## OPEN-PORCELAIN Contract
`storage/handoff/OPEN-PORCELAIN-*.txt` is conditionally emitted: it is written only when `git status --porcelain` returns non-empty output (dirty working tree). Clean sessions suppress OPEN-PORCELAIN by design. OPEN-PORCELAIN is dirty-state evidence, not a universal shipping requirement. Certify excludes it from OPEN artifact selection and redacts its path from receipt replays.

## Mechanics and Sequencing
The binary parses format, intent, DP label, output mode, and optional tag. It emits a `STELA_TRACE_ID`, reads branch and short hash, and captures porcelain state on every run. If porcelain is non-empty it writes normalized porcelain lines to `storage/handoff/OPEN-PORCELAIN-...txt` by default. `OPEN_HANDOFF_BASE` is an internal test/runtime override that redirects OPEN artifact writes under a repo-relative handoff root while preserving the same emitted repo-relative paths. OPEN remains pointer-first: it includes porcelain summary lines and the `Porcelain saved` artifact path, and does not inline full or preview porcelain payload blocks. It validates required canon pointer files, builds an OPEN prompt document with freshness gate data and operational guidance, and wraps the emitted document with canonical marker lines. On the same branch/head path, later OPEN refreshes rewrite the current OPEN artifact; packet-start authority is preserved by binding the opening OPEN fields into packet truth.

Draft path: OPEN detects `storage/handoff/PLAN.md` presence and reflects its status in `[NEXT OPERATOR MOVES]` so the operator can see whether the draft plan input surface is ready. The operator move is `./ops/bin/bundle --profile=draft --out=auto`. Draft surface details (`packet_id`, `dp_draft_path=storage/dp/intake/DP.md`, `closing_sidecar`) are bundle-mediated and appear in the bundle `[REQUEST]` block, not in OPEN output.
- `===== STELA OPEN PROMPT =====`
- `===== END STELA OPEN PROMPT =====`
The legacy wrapper `===== OPEN PROMPT =====` and legacy standalone title line `Stela OPEN PROMPT` are retired. The binary writes the prompt to `storage/handoff/OPEN-...txt` by default (or the repo-relative `OPEN_HANDOFF_BASE` override when used by internal tests/runtime helpers), mirrors prompt content to stdout, and prints `OPEN saved:` only when `--out=auto` is requested. The Next Operator Moves block includes non-blocking guidance for `ops/bin/bundle --profile=auto --out=auto`.

## OPEN Authority Boundary
OPEN may be run on `main` for context refresh or intake routing. OPEN does not authorize packet execution or mutation on `main`; that authority is governed by `PoT.md` Section 6.

## Anecdotal Anchor
The DP-OPS-0065 freshness gate formalization addressed prior runs where work started from stale local state with no serialized checkpoint. OPEN plus bundle routing in DP-OPS-0145 preserves this checkpoint while reducing ad hoc operator assembly steps.

## Integrity Filter Warnings
`ops/bin/open` exits on unknown arguments, missing required canon files, or git command failures. It writes artifacts in `storage/handoff` and does not mutate tracked canon files. Dirty sessions produce an OPEN-PORCELAIN artifact and OPEN references that path without duplicating the detailed payload inline. Clean sessions suppress porcelain artifact creation by design.
