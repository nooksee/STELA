<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/context.sh` exists to keep global session context deterministic and contamination-free. The script prevents stale or polluted manifests from injecting non-canonical state into worker sessions, which enforces PoT context hygiene directives and protects against contractor hallucination triggered by invalid pointers or pasted dump fragments.

## Mechanics and Sequencing
1. Resolve repository root, emit lifecycle telemetry, and require `ops/lib/manifests/CONTEXT.md`.
Note (Section 1.1 — Hazard Guard): Removed in DP-OPS-0108. Structural prevention is
in effect: ops/lib/manifests/CONTEXT.md is a generated surface produced by
ops/bin/compile from ops/src/manifests/context.md.tpl. The source template contains no
opt/_factory/ paths. Contamination at generation time is structurally impossible without
a template edit. The guard was B-scored in DP-OPS-0101 and deprecated upon confirmation
of generation model.
3. Extract every backticked token with `awk` and treat each token as a required artifact path.
4. Verify existence of each extracted artifact and fail each missing path.
5. Run semantic contamination scans on canonical surfaces (`PoT.md`, `SoP.md`, `TASK.md`, `docs/MAP.md`, `llms.txt`) using strict dump-marker patterns.
6. Emit warning-only diagnostics when a scan target is absent, but emit hard failures for contamination matches and missing required manifest artifacts.

## Anecdotal Anchor
The contamination scan was added after drift incidents where dump markers and factory payload fragments were pasted into canon-facing files and later consumed as if they were authoritative state. That class of error required manual cleanup across multiple surfaces before normal preflight gates could resume.

## Integrity Filter Warnings
Missing `ops/lib/manifests/CONTEXT.md` exits with critical status and stops execution. The artifact verifier only checks backticked entries, so plain text paths outside backticks are not part of required-artifact validation. The script distinguishes warnings from failures: missing scan targets produce warnings, while hazard patterns, contamination markers, and missing required artifacts block closeout.
