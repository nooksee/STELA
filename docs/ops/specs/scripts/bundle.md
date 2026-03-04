<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/lib/scripts/bundle.sh` centralizes routing, artifact composition, and manifest/package emission so `ops/bin/bundle` remains a thin telemetry entrypoint. This keeps transport policy deterministic and auditable in one place.

## Mechanics and Sequencing
The script provides `bundle_run` plus helpers for:
1. Argument parsing and validation (`profile`, `out`, `project`, `intent`).
2. Policy load from `ops/lib/manifests/BUNDLE.md` with required-key validation and fail-closed behavior.
3. Repo-relative path normalization and output confinement to `storage/handoff/`.
4. Auto routing using PLAN presence and `tools/lint/plan.sh` status.
5. Prompt path and dump scope resolution per resolved profile from policy mappings.
6. Deterministic embedded OPEN block generation (no internal `ops/bin/open` invocation).
7. Dump orchestration with explicit `.txt` output path under `storage/dumps/`.
8. Auditor intent parsing and decision-leaf validation against dump payload.
9. Bundle text rendering with embedded prompt contract text.
10. Manifest v2 emission and package `.tar` emission with manifest-aligned member list.

Prompt contract extraction rule:
- Strip only contiguous leading HTML comment lines and immediately following leading blank lines.
- If `Rules:` exists in the prompt, emit from `Rules:` through end-of-file.
- Otherwise emit the stripped prompt body as-is.

Text artifact profile conditional rule:
- Emit `[HANDOFF]` (`TOPIC.md` / `PLAN.md` presence) only when resolved profile is not `audit` and not `auditor`.

## Anecdotal Anchor
DP-OPS-0145 introduced bundle as a transport primitive. DP-OPS-0146 hardened it for attach-only architect workflows and addendum auditor flows by eliminating OPEN artifact dependence and adding deterministic package metadata.

## Integrity Filter Warnings
The script assumes canonical prompt files under `docs/ops/prompts/`. Path movement without policy updates causes hard failure. `ops/lib/manifests/BUNDLE.md` parse failures are fail-closed and block bundle generation. Runtime behavior must remain deterministic and pointer-first; dump payload bodies must not be inlined into bundle text.
