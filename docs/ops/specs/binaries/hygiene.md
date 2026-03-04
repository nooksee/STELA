<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/hygiene` exists to provide deterministic maintenance reporting without autonomous repository mutation. It surfaces stale guard debt and writes patch candidates into `var/tmp/` for operator review.

## Mechanics and Sequencing
The binary parses options, resolves repository root, and reads stale debt data via `tools/lint/debt.sh --list-stale`. It prints a deterministic summary and optional detail lines.

Modes:
- default report mode: print stale debt summary and entries.
- `--emit-patch-candidates`: write candidate patch guidance to `var/tmp/` only.
- `--one-time-sweep`: generate a one-time scan report for likely temporary or one-off guard markers under `docs/`, `ops/`, and `tools/`, written to `var/tmp/` (or `--sweep-out=PATH`).

The binary does not apply patches and does not modify tracked files. All candidate outputs are disposable runtime artifacts.

## Anecdotal Anchor
DP-OPS-0149 adds `ops/bin/hygiene` to complement debt lint enforcement with operator-friendly stale debt reporting.

## Integrity Filter Warnings
`ops/bin/hygiene` exits non-zero when debt lint invocation fails, stale listing cannot be parsed, sweep output cannot be written, or candidate output path cannot be written under `var/tmp/`. The command intentionally does not support direct repository mutation.
