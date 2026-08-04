<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
# Surface Specification: PoW.md

## Constitutional Anchor
`PoW.md` is the canonical root pointer for the Proof of Work surface.
`PoW.md` does not store ledger body text directly in Phase 2+ operation; it stores exactly one pointer to the current PoW leaf.

## Phase 2 Surface Model
- `PoW.md` must contain a single repository-relative pointer:
  - `archives/surfaces/PoW-YYYY-MM-DD-<hash>.md`
- Each PoW leaf must carry unified schema front matter:
  - `trace_id`
  - `packet_id`
  - `created_at`
  - `previous`
  - `proof_model: durable-v1`
  - `proof_state: complete|legacy-gap`
- Each PoW leaf body must contain one PoW entry block only (header + fields), with no global guidance preamble.

## PoW Entry Contract (Canonical)
- Header pattern:
  - `## YYYY-MM-DD HH:MM:SS UTC — DP-OPS-XXXX <summary>`
- Required field order inside the entry:
  - `Packet ID`
  - `Timestamp`
  - `Work Branch`
  - `Base HEAD`
  - `Scope`
  - `Target Files allowlist`
  - `Receipt pointers` (`RESULTS`, `PACKET`)
  - `Notes`
- Receipt pointer expectations:
  - `RESULTS`: `archives/surfaces/RESULTS-DP-OPS-XXXX[-ADDENDUM-X]-<hash>.md`
  - `PACKET`: the authoritative `archives/surfaces/TASK-...` or `archives/surfaces/ADDENDUM-...` lineage leaf
- `proof_state: complete` requires both durable pointer targets. `proof_state: legacy-gap` is reserved for an explicitly identified historical receipt body that was not retained; it must say `RESULTS: unavailable (legacy body not retained)` and must still carry the durable packet pointer.

## Operator Guidance
- Author PoW entry content before running `ops/bin/certify`.
- The pre-certify single-entry-head authoring rule and a worked example are documented in `docs/MANUAL.md` in the Log step section of the Closeout Cycle.
- Treat `PoW.md` and `archives/surfaces/PoW-*.md` as generated surfaces once certify snapshots are emitted.
- Do not embed raw OPEN or other transport payloads inside PoW entries. The durable packet leaf retains opening authority.
- Do not reproduce the full verification command list in PoW entries; the archived RESULTS leaf is the SSOT for command-by-command proof.
- `Notes` are artifact-level context only (scope anomalies affecting the artifact inventory). Execution narrative and anomaly resolution belong in RESULTS Worker Execution Narrative.
