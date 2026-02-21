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
  - `Receipt pointers` (`RESULTS`, `OPEN`, `DUMP`)
  - `Verification commands`
  - `Notes`
- Receipt pointer expectations:
  - `RESULTS`: `storage/handoff/DP-OPS-XXXX-RESULTS.md`
  - `OPEN`: `storage/handoff/OPEN-*.txt`
  - `DUMP`: `storage/dumps/dump-*.txt`

## Operator Guidance
- Author PoW entry content before running `ops/bin/certify`.
- Treat `PoW.md` and `archives/surfaces/PoW-*.md` as generated surfaces once certify snapshots are emitted.
- Do not embed raw OPEN or DUMP payloads inside PoW entries.
- `Notes` must include material negative proof context when it affected execution.
