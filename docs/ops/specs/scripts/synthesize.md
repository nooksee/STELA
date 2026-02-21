<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/lib/scripts/synthesize.sh` is the context assembly boundary that enforces PoT.md Section 1.2 SSOT and context-hazard doctrine for worker-facing bundles. `ops/bin/context` and `ops/bin/llms` depend on this script so manifest intent, include resolution, and emitted context bytes stay deterministic and auditable.

## Mechanics and Sequencing
1. Parse CLI arguments:
   - `--manifest=PATH` selects source manifest (default `ops/lib/manifests/OPS.md`).
   - `--mode=stream|list` or `--list` selects output form.
2. Resolve manifest path relative to repo root and fail when file is missing or empty.
3. Resolve manifest content recursively:
   - Extract backticked tokens.
   - Follow `@manifest:<path>` includes depth-first.
   - Reject runtime glob tokens (`*`, `?`, `[`).
   - Keep first-seen path order and de-duplicate repeated entries.
4. Enforce hazard blacklist before emission, blocking references to skill/task/agent canon paths.
5. Emit output:
   - `list`: resolved paths only.
   - `stream`: `## <path>` header plus file body.
   - Strip TOC sections.
   - Redact common credential signatures.
   - For `SoP.md`, emit only the newest heading block range controlled by `SYNTHESIZE_SOP_LIMIT` (default `10`) before TOC stripping and redaction.
6. Fail fast on unknown args, unresolved members, empty resolution sets, hazard hits, or missing files at emit time.

## Anecdotal Anchor
SoP entry `2026-02-14 19:29:25 UTC — DP-OPS-0064 Phase 2 Structural Restructuring` records deterministic manifest compilation and context-surface hardening across synthesis consumers. That entry represents the same operational failure class this script prevents: stale or incomplete manifest synthesis fed outdated layer state into worker prompts and produced context drift.

## Integrity Filter Warnings
- Manifest include cycles are suppressed through a seen-manifest set and do not emit explicit cycle diagnostics, which can hide accidental recursive include topology.
- Hazard blacklist entries are literal path prefixes; unlisted aliases or path-shape variants can bypass intent if manifests are malformed.
- Missing manifest members are hard failures; no soft-degradation path exists for partial context emission.
- SoP truncation intentionally drops older entries, which can omit forensic context unless callers raise `SYNTHESIZE_SOP_LIMIT`.
