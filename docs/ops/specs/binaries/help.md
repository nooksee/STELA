<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/help` exists to provide deterministic CLI wayfinding for doctrine, specs, and operational command paths. It prevents a failure mode where operators search ad hoc documentation in inconsistent order and miss authoritative spec behavior while executing packet work.

## Mechanics and Sequencing
The binary initializes terminal color support, enforces repo-root execution, and accepts zero or one argument. With no argument it prints the command index and quick-start menu. In `specs` mode it recursively lists spec markdown files under `docs/ops/specs` grouped by top-level category with stable sort order. In `doctrine` mode it extracts Filing Doctrine, Axioms, Canon Surfaces, and the numbered read sequence from `PoT.md`. The read-order heading may use either the original plain form or the current fully bolded form. Every doctrine heading must occur exactly once, each extracted block must be non-empty and bounded by its declared successor, and read-order numbering must begin at `1` and remain consecutive. In `curriculum` mode it prints startup and closeout command sequences. In search mode it runs fixed-string search across specs first, then scans `docs` excluding specs, and prints results in that order. `--test` runs six isolated doctrine-contract cases, including the live PoT, both accepted heading forms, missing and duplicate headings, and malformed numbering.

## Anecdotal Anchor
Operator dispatch reviews identified recurring wayfinding misses where execution teams read narrative docs before normative spec surfaces. A later PoT emphasis change bolded the read-order heading without changing its words; the former parser missed that boundary, placed later constitutional sections under Canon Surfaces, and printed escaped fallback text as doctrine. The repaired parser treats formatting as an explicit accepted form and fails closed when structural boundaries are absent or ambiguous.

## Integrity Filter Warnings
`ops/bin/help` fails when invoked outside repo root, when `git` is unavailable, when `docs` or `docs/ops/specs` is missing for the selected mode, when argument count exceeds one, or when doctrine headings, boundaries, non-empty bodies, or consecutive numbering do not satisfy the extraction contract. Doctrine mode never substitutes fallback prose for missing constitutional source text. Search mode with zero matches returns an explicit no-reference report rather than an inferred answer. GitHub runs `ops/bin/help --test` so malformed doctrine output cannot pass merely because the command exits successfully.
