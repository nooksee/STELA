<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
ledger.sh is required to keep history ledgers bounded and auditable by computing archive plans and enforcing receipt-pointer integrity before pruning entries.

## Mechanics and Sequencing
Count date-heading entries, compute prune threshold deltas, validate PoW receipt pointer presence and shape, verify pointer targets are tracked and clean, then split retained and archived blocks deterministically.

## Anecdotal Anchor
Prior pruning attempts risked deleting evidence referenced by PoW entries; the guarded validation flow exists to block archival when receipt linkage is incomplete.

## Integrity Filter Warnings
Prune operations fail on missing required PoW fields, malformed pointers, untracked or dirty pointer targets, or unresolved cut-line calculations; do not force continuation.