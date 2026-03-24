<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/lib/scripts/bundle.sh` centralizes routing, artifact composition, and manifest/package emission so `ops/bin/bundle` remains a thin entrypoint and transport behavior stays deterministic.

## Mechanics and Sequencing
The script provides `bundle_run` plus helpers for:
1. Argument parsing and validation (`profile`, `out`, `project`, `intent`, ATS triplet flags).
2. Policy load from `ops/lib/manifests/BUNDLE.md`.
3. ATS policy load from `ops/lib/manifests/ASSEMBLY.md`.
4. OPEN-anchor resolution for the active branch/head. The script consumes a current real OPEN artifact under the active handoff root and refreshes it through `ops/bin/open` when absent or stale; it never invents a transport-only trace id.
5. Output confinement to `storage/handoff/` for operator-facing artifacts or `var/tmp/_smoke/handoff/` for quarantined smoke runs.
6. Auto routing using PLAN presence and `tools/lint/plan.sh` status.
7. Dump scope and stance template resolution per resolved profile.
8. Dump orchestration with explicit `.txt` output path plus explicit `--persistence-profile=<resolved-profile>`.
   - operator-facing dump outputs remain under `storage/dumps/`
   - quarantined smoke dump outputs go under `var/tmp/_smoke/dumps/`
   - audit auto output uses artifact-stem dump naming so reruns stay distinct
9. Audit submission identity handling:
   - initial audit delivery uses `AUDIT-*` (default; no `--rerun` required)
   - reruns emit `AUDIT-R<index>-*` only when `--rerun` is explicitly supplied
   - prior local `AUDIT-*` artifacts do not force rerun identity without `--rerun`
   - manifest records submission lineage (`kind`, `resubmission_index`, `supersedes_bundle_path`, `refresh_reason`)
10. Draft plan-intake request metadata emission.
11. Planning, draft, and audit exact-file disposable transport.
12. Manifest v2 emission and package `.tar` emission with manifest-aligned member list, including OPEN pointer metadata sourced from the real artifact.

## Persistence Routing Contract
The script routes persistence profile into `ops/bin/dump`; it does not implement cold archive policy itself.
- bundle policy resolves the profile name
- dump reads `ops/etc/persistence.manifest`
- scope and persistence depth remain separate concerns

## Integrity Filter Warnings
`ops/lib/manifests/BUNDLE.md` and `ops/lib/manifests/ASSEMBLY.md` parse failures are fail-closed and block bundle generation. Runtime behavior must remain deterministic and pointer-first; dump payload bodies must not be inlined into bundle text.
