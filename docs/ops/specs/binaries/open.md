<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/open` exists to establish a verifiable freshness checkpoint before packet execution. It prevents stale-state execution by binding intent, branch, hash, and porcelain status to a timestamped artifact, which supports PoT drift detection and traceable operator handoff.

## Mechanics and Sequencing
The binary parses format, intent, DP label, output mode, and optional tag. It emits a new `STELA_TRACE_ID`, reads branch and short hash, and captures porcelain state on every run. If porcelain is non-empty it writes normalized porcelain lines to `storage/handoff/OPEN-PORCELAIN-...txt` and includes full or preview output in the prompt body based on line count threshold. It validates the required canon pointer files, builds an OPEN prompt document with freshness gate data and operational guidance, writes the prompt to `storage/handoff/OPEN-...txt`, mirrors prompt content to stdout, and prints `OPEN saved:` only when `--out=auto` is requested.

## Anecdotal Anchor
The DP-OPS-0065 freshness gate formalization addressed prior runs where work started from stale local state with no serialized checkpoint. `ops/bin/open` enforces that checkpoint and adds porcelain evidence so clean-state assertions are testable.

## Integrity Filter Warnings
`ops/bin/open` exits on unknown arguments, missing required canon files, or git command failures. It writes artifacts in `storage/handoff` and does not mutate tracked canon files. Dirty sessions produce a porcelain artifact; clean sessions suppress porcelain artifact creation by design.
