<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/context` exists to enforce PoT context hygiene by producing one session stream that binds current manifests and current OPEN state. It prevents a failure mode where operators synthesize context from stale manifests or omit the session freshness checkpoint artifact.

## Mechanics and Sequencing
The binary parses optional `--manifest`, `--dp`, and `--out` arguments, enforces repo-root execution, validates required binaries and the chosen manifest file, and runs `ops/bin/compile` first. It then runs `ops/bin/open --out=auto` with optional DP binding and extracts the `OPEN saved:` path from command output. It validates the OPEN artifact path, creates a temporary stream file in `var/tmp`, writes a header block, appends OPEN content, appends synthesized stream output from `ops/lib/scripts/synthesize.sh`, prints the assembled stream to stdout, and optionally writes it to `storage/handoff` or an explicit destination path.

## Anecdotal Anchor
Session preparation failures appeared when stale manifest state remained on disk while operators generated context for active packets. The compile-first requirement in `ops/bin/context` was introduced to remove that stale-manifest class before synthesis.

## Integrity Filter Warnings
The command fails on unknown arguments, missing or non-executable dependencies, missing target manifest, failure to parse an OPEN artifact path from `ops/bin/open`, or synthesis failures. It requires repo-root execution and does not emit a degraded stream when OPEN or synthesize steps fail.
