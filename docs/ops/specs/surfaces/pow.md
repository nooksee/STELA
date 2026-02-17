# Surface Specification: PoW.md

## Constitutional Anchor
`PoW.md` is the root proof ledger defined by PoT and the closeout doctrine in `docs/MANUAL.md`.
It is not narrative history. It is structured evidence that links work claims to executable receipts.

## Operator Contract
- Surface: `PoW.md`.
- Entry model: append-only, newest entry first.
- Header pattern:
  - `## YYYY-MM-DD HH:MM:SS UTC — DP-OPS-XXXX <summary>`
- Required schema and order:
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
  - `RESULTS` points to `storage/handoff/DP-OPS-XXXX-RESULTS.md`.
  - `OPEN` points to `storage/handoff/OPEN-*.txt`.
  - `DUMP` points to `storage/dumps/dump-*.txt`.

## Failure States and Drift Triggers
- Missing required fields or field order drift in new entries.
- Missing or malformed receipt pointers.
- Pointer paths that do not resolve to committed, clean artifacts.
- Deletions or rewrites of prior PoW entries.
- Code-bearing changes without a PoW update.

Enforcement linkage:
- `.github/workflows/pow_policing.yml` fails pull requests when code-bearing surfaces change without a PoW update.
- The same workflow enforces append-only integrity by rejecting deletion lines in `PoW.md`.
- `ops/bin/prune --target=pow` blocks pruning if prune-candidate entries are incomplete or if receipt pointers are not committed and clean.

## Mechanics and Sequencing
1. Run verification gates first.
2. Generate `OPEN`, `DUMP`, and `RESULTS` artifacts.
3. Append PoW entry with exact schema and concrete artifact pointers.
4. Commit canon and artifacts.
5. Run prune only after proof exists and pointers are clean.

Retention mechanics:
- Keep the most recent `30` PoW entries in `PoW.md`.
- Archive overflow entries to `archives/surfaces/PoW-archive-YYYY-MM.md` via `ops/bin/prune`.

## Forensic Insight
PoW converts process claims into auditable evidence chains.
The ledger, policing workflow, and prune guards form a three-layer proof system: CI requires the ledger update, the ledger names the receipts, and prune refuses to destroy old entries unless those receipts are structurally valid and committed.
