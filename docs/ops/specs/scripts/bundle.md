<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/lib/scripts/bundle.sh` centralizes routing, artifact composition, and manifest/package emission so `ops/bin/bundle` remains a thin telemetry entrypoint. This keeps transport policy deterministic and auditable in one place.

## Mechanics and Sequencing
The script provides `bundle_run` plus helpers for:
1. Argument parsing and validation (`profile`, `out`, `project`, `intent`).
2. Repo-relative path normalization and output confinement to `storage/handoff/`.
3. Auto routing using PLAN presence and `tools/lint/plan.sh` status.
4. Prompt path resolution per resolved profile.
5. Deterministic embedded OPEN block generation (no internal `ops/bin/open` invocation).
6. Dump orchestration with explicit `.txt` output path under `storage/dumps/`.
7. Auditor intent parsing and decision-leaf validation against dump payload.
8. Bundle text rendering with embedded prompt stance text.
9. Manifest v2 emission and package `.tar` emission with manifest-aligned member list.

Prompt embedding rule:
- Strip only contiguous leading HTML comment lines and immediately following leading blank lines.
- Preserve all remaining prompt content verbatim.

## Anecdotal Anchor
DP-OPS-0145 introduced bundle as a transport primitive. DP-OPS-0146 hardened it for attach-only architect workflows and addendum auditor flows by eliminating OPEN artifact dependence and adding deterministic package metadata.

## Integrity Filter Warnings
The script assumes canonical prompt files under `docs/ops/prompts/`. Path movement without map updates causes hard failure. Runtime behavior must remain deterministic and pointer-first; dump payload bodies must not be inlined into bundle text.
