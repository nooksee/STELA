<!-- CCD: ff_target="operator-technical" ff_band="25-35" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Integrity Scope Fixture Specification

## Purpose

`tools/test/integrity.sh` proves that packet scope and persistent policy are independent authorization gates.

## Fixture Contract

The test creates isolated Git repositories beneath `var/tmp/_smoke/`, copies the live shared helper and integrity lint into each fixture, and removes every fixture at exit. It does not mutate live TASK, policy, or packet surfaces.

The matrix must prove:

1. An exact packet path with persistent coverage passes.
2. A persistent wildcard cannot widen packet scope.
3. A packet declaration cannot bypass persistent policy.
4. An undeclared deletion fails.
5. A declared deletion may remove its own prior persistent entry while the deletion remains visible against `HEAD`.
6. A matching addendum extends packet scope by exact path.
7. A mismatched addendum fails closed.
8. `IDLE/COMPLETED` maintenance uses persistent policy transparently.
9. An addendum is rejected while routing is idle.

Any failed assertion exits nonzero and reports pass and fail counts.
