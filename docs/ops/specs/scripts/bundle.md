<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/lib/scripts/bundle.sh` centralizes bundle routing and artifact composition logic so `ops/bin/bundle` remains a thin telemetry-emitting entrypoint. The split prevents duplicated routing behavior and keeps transport policy in one deterministic implementation.

## Mechanics and Sequencing
The script provides `bundle_run` and helper functions for:
1. Argument parsing and validation for profile/out/project inputs.
2. Repo-relative path normalization and output confinement to `storage/handoff/`.
3. Auto route evaluation using PLAN presence and `tools/lint/plan.sh` status.
4. Prompt path resolution per resolved profile.
5. OPEN invocation and metadata extraction from the generated OPEN artifact.
6. Dump invocation (`full` scope for analyst/architect, `core` scope for audit, `project` scope for project profile).
7. Bundle text artifact rendering (pointer-first, prompt stance embedded verbatim, no dump payload inlining).
8. Machine-readable JSON sidecar emission with routing and pointer metadata.

## Anecdotal Anchor
Prior workflows assembled OPEN/dump/prompt context manually, which produced repeated drift in packet intake quality. Moving this logic into a shared script allows one audited route contract across direct bundle use and meta integration.

## Integrity Filter Warnings
The script assumes canonical prompt files exist at stable paths under `docs/ops/prompts/`. Any path movement without script updates causes hard failures. Output path enforcement intentionally rejects non-`storage/handoff/` destinations to prevent drift from the bundle contract.
