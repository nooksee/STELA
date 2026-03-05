<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/lib/scripts/bundle.sh` centralizes routing, artifact composition, and manifest/package emission so `ops/bin/bundle` remains a thin telemetry entrypoint. This keeps transport policy deterministic and auditable in one place.

## Mechanics and Sequencing
The script provides `bundle_run` plus helpers for:
1. Argument parsing and validation (`profile`, `out`, `project`, `intent`).
2. Policy load from `ops/lib/manifests/BUNDLE.md` with required-key validation and fail-closed behavior.
   - Includes compatibility alias keys (`profile_alias_legacy_auditor_to`, `profile_alias_legacy_hygiene_to`) consumed at runtime.
   - Runtime keeps one-cycle fallback support for old key names (`profile_alias_auditor`, `profile_alias_hygiene`) and fails closed if neither key set is present.
3. Repo-relative path normalization and output confinement to `storage/handoff/`.
4. Auto routing using PLAN presence and `tools/lint/plan.sh` status.
5. Dump scope and stance template key resolution per resolved profile from policy mappings.
6. Deterministic embedded OPEN block generation (no internal `ops/bin/open` invocation).
7. Dump orchestration with explicit `.txt` output path under `storage/dumps/`.
8. Foreman intent parsing and decision-leaf validation against dump payload.
9. Bundle text rendering with embedded stance contract text rendered through `ops/bin/manifest` stance template keys.
10. Manifest v2 emission and package `.tar` emission with manifest-aligned member list.
11. Alias-route metadata emission in manifest (`profile_alias.applied`, `.from`, `.to`) when compatibility aliases are used.

Stance contract extraction and render rules:
- Resolve profile stance template key from `ops/lib/manifests/BUNDLE.md`.
- Render stance body via `ops/bin/manifest render <stance-key> --out=-`.
- Strip only contiguous leading HTML comment lines and immediately following leading blank lines.
- If `Rules:` exists in the rendered stance body, emit from `Rules:` through end-of-file.
- Otherwise emit the stripped stance body as-is.

Text artifact profile conditional rule:
- Emit `[HANDOFF]` (`TOPIC.md` / `PLAN.md` presence) only when resolved profile is not `audit` and not `foreman`.

## Anecdotal Anchor
DP-OPS-0145 introduced bundle as a transport primitive. DP-OPS-0146 hardened it for attach-only architect workflows and addendum authorization flows by eliminating OPEN artifact dependence and adding deterministic package metadata.

## Integrity Filter Warnings
The script assumes canonical stance templates under `ops/src/stances/` via manifest key mapping. Path/key drift without policy updates causes hard failure. `ops/lib/manifests/BUNDLE.md` parse failures are fail-closed and block bundle generation. Runtime behavior must remain deterministic and pointer-first; dump payload bodies must not be inlined into bundle text.
