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
  - `Receipt pointers` (`RESULTS`, `OPEN`; `DUMP` only when the packet explicitly emitted a canonical dump artifact before certify)
  - `Notes`
- Receipt pointer expectations:
  - `RESULTS`: `storage/handoff/RESULTS.md`
  - `OPEN`: `storage/handoff/OPEN-*.txt`
  - `DUMP`: optional `storage/dumps/dump-*.txt` when the current packet intentionally emitted a canonical dump artifact before certify

## Operator Guidance
- Author PoW entry content before running `ops/bin/certify`.
- The pre-certify single-entry-head authoring rule and a worked example are documented in `docs/MANUAL.md` in the Log step section of the Closeout Cycle.
- Treat `PoW.md` and `archives/surfaces/PoW-*.md` as generated surfaces once certify snapshots are emitted.
- Do not embed raw OPEN or DUMP payloads inside PoW entries.
- Do not reproduce the full verification command list in PoW entries; `RESULTS.md` is the SSOT for command-by-command proof.
- `Notes` are artifact-level context only (scope anomalies affecting the artifact inventory). Execution narrative and anomaly resolution belong in RESULTS Contractor Execution Narrative.
