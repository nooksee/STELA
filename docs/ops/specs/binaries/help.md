<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/help` exists to provide deterministic CLI wayfinding for doctrine, specs, and operational command paths. It prevents a failure mode where operators search ad hoc documentation in inconsistent order and miss authoritative spec behavior while executing packet work.

## Mechanics and Sequencing
The binary initializes terminal color support, enforces repo-root execution, and accepts zero or one argument. With no argument it prints the command index and quick-start menu. In `specs` mode it recursively lists spec markdown files under `docs/ops/specs` grouped by top-level category with stable sort order. In `doctrine` mode it extracts Filing Doctrine, Axioms, Canon Surfaces, and read order lines from `PoT.md`. In `curriculum` mode it prints startup and closeout command sequences. In search mode it runs fixed-string search across specs first, then scans `docs` excluding specs, and prints results in that order.

## Anecdotal Anchor
Operator dispatch reviews identified recurring wayfinding misses where execution teams read narrative docs before normative spec surfaces. `ops/bin/help` addresses that class by making specs-first lookup and doctrine extraction available from the same CLI boundary used for execution.

## Integrity Filter Warnings
`ops/bin/help` fails when invoked outside repo root, when `git` is unavailable, when `docs` or `docs/ops/specs` is missing for the selected mode, or when argument count exceeds one. Search mode with zero matches returns an explicit no-reference report rather than an inferred answer.
