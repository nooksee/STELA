<!-- CCD: ff_target="operator-technical" ff_band="25-35" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Integrity Scope Fixture Specification

## Purpose

`tools/test/integrity.sh` proves that packet scope and persistent policy are independent authorization gates.

## Fixture Contract

The test creates isolated Git repositories beneath `var/tmp/_smoke/`, copies the live shared helper and integrity lint into each scope fixture, copies the whole working tree into the certify dry-run fixture, and removes every fixture at exit. It does not mutate live TASK, policy, or packet surfaces.

The matrix must prove:

1. An exact packet path with persistent coverage passes.
2. A persistent wildcard cannot widen packet scope.
3. A packet declaration cannot bypass persistent policy.
4. An undeclared deletion fails.
5. A declared deletion may remove its own prior persistent entry while the deletion remains visible against `HEAD`.
6. A matching addendum extends packet scope by exact path.
7. A mismatched addendum fails closed.
8. An untracked compile leaf stamped with the fixture `HEAD` is reported as current-run output and passes without a packet declaration.
9. A compile leaf stamped with any other hash fails packet scope.
10. `IDLE/COMPLETED` maintenance uses persistent policy transparently.
11. An addendum is rejected while routing is idle.
12. A certify dry run passes on a synthetic packet (DP-OPS-0271). The test copies the working tree into a fresh repository and commits a baseline. It drafts `DP-OPS-9000` with `ops/bin/open` and `ops/bin/draft` on an `agent/dp-ops-9000-<date>` branch and commits the packet-open state. It stages one declared file, authors the heads, and writes a closing sidecar and a narrative. `./ops/bin/certify --dp=DP-OPS-9000 --dry-run` must print `CERTIFY-DRY-RUN: PASS` and emit no leaf.
13. The same fixture with one undeclared file fails closed at certify's integrity gate.

Any failed assertion exits nonzero and reports pass and fail counts.
