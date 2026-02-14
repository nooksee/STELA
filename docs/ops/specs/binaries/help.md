# Technical Specification: ops/bin/help

## Constitutional Anchor
`ops/bin/help` is the CLI wayfinding surface for the Explain layer.
It operationalizes the same navigation intent as `docs/MAP.md`: constitution, ledgers, interface, and bridge commands.

## Operator Contract
- Invocation:
  - `./ops/bin/help`
  - `./ops/bin/help specs`
  - `./ops/bin/help doctrine`
  - `./ops/bin/help curriculum`
  - `./ops/bin/help <term>`
- Modes:
  - Menu mode: command index plus quick-start wayfinding.
  - Specs mode: recursive, grouped listing of `docs/ops/specs/**/*.md`.
  - Doctrine mode: PoT axioms and canon pointers in operator-ready form.
  - Curriculum mode: startup and closeout sequences aligned with `docs/MANUAL.md` and TASK routing discipline.
  - Search mode: term lookup with specs-first priority, then broader docs scan.
- Determinism:
  - Specs listings are stable and sorted with `LC_ALL=C` order.
  - Search output is deterministic for the current repository state.
- Mutation policy:
  - Read-only behavior.
  - No tracked file writes.

## Failure States and Drift Triggers
- Not running from repository root.
- `git` missing on `PATH`.
- `docs/` or `docs/ops/specs/` missing.
- Unknown subcommand or too many arguments.
- No matches for a search term.

These failures are explicit and non-destructive.
They indicate navigation drift, environment misconfiguration, or missing documentation surfaces.

## Mechanics and Sequencing
1. Validate runtime context (`git` present, repo root).
2. Parse zero-or-one argument mode.
3. Dispatch by mode:
- `specs`: recursively discover spec markdown, group by category, print sorted list.
- `doctrine`: surface Filing Doctrine, Axioms, Canon Surfaces, and read sequence pointers from PoT.
- `curriculum`: print guided startup and closeout command paths tied to MANUAL and TASK contract behavior.
- `<term>`: search specs first, then search remaining docs.
- default: show menu and command index.
4. Return zero on successful mode execution, non-zero on explicit failure paths.

Pointer-first search contract:
- Specs are queried before narrative docs.
- When spec matches exist, they are shown first as authoritative behavior references.
- Secondary docs scan excludes `docs/ops/specs` to reduce duplicate noise.

## Forensic Insight
`ops/bin/help` keeps operational navigation inside the CLI boundary where execution happens.
By combining doctrine, curriculum, and specs-first search, it lowers operator ambiguity and reduces drift between enforcement code and documentation interpretation.
