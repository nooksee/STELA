<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/lib/scripts/bundle.sh` centralizes routing, artifact composition, and manifest/package emission so `ops/bin/bundle` remains a thin telemetry entrypoint. This keeps transport policy deterministic and auditable in one place.

## Mechanics and Sequencing
The script provides `bundle_run` plus helpers for:
1. Argument parsing and validation (`profile`, `out`, `project`, `intent`, `slice`, ATS triplet flags).
2. Policy load from `ops/lib/manifests/BUNDLE.md` with required-key validation and fail-closed behavior.
   - Includes compatibility alias key `profile_alias_legacy_hygiene_to` consumed at runtime.
   - Includes required compatibility alias deprecation keys `profile_alias_legacy_hygiene_deprecation_status` and `profile_alias_legacy_hygiene_remove_after_dp`.
   - Runtime reads canonical alias keys only and fails closed when either canonical key is missing.
3. ATS policy load from the manifest-linked `ops/lib/manifests/ASSEMBLY.md` with required-key validation and fail-closed behavior.
4. ATS validation for `agent_id`, `skill_id`, and `task_id`:
   - all-or-none flag set required,
   - pattern checks from assembly policy keys,
   - canonical ID existence checks against `docs/ops/registry/agents.md`, `docs/ops/registry/skills.md`, and `docs/ops/registry/tasks.md`.
5. Repo-relative path normalization and output confinement to `storage/handoff/`.
6. Auto routing using PLAN presence and `tools/lint/plan.sh` status.
7. Dump scope and stance template key resolution per resolved profile from policy mappings.
   - Artifact naming prefix resolution per resolved profile from policy keys (`artifact_prefix_<profile>`).
   - Compatibility legacy artifact emission controlled by `compatibility_emit_legacy_bundle_artifacts` and `compatibility_legacy_bundle_prefix`.
8. Deterministic embedded OPEN block generation (no internal `ops/bin/open` invocation).
9. Dump orchestration with explicit `.txt` output path under `storage/dumps/`.
10. Foreman intent parsing and decision-leaf validation against dump payload.
11. Architect slice parsing and validation:
   - `--slice=<ID>` accepted only for resolved profile `architect`.
   - blank `--slice=` fails before artifact emission.
   - architect slice IDs must match `Selected Slices` in `storage/handoff/PLAN.md` (`## Architect Handoff`).
   - unknown architect slices fail before artifact emission.
   - omitted `--slice` keeps architect in ad hoc mode unless the Architect Handoff explicitly enables safe auto-bind with one unambiguous selected slice.
12. Architect request metadata emission:
   - text artifact emits `[REQUEST]` block with `slice_id`, `slice_validated`, `plan_source`, `packet_id`, `closing_sidecar`, and `title_suffix`.
   - manifest emits `request` object with `request.slice_id`, `request.slice_validated`, `request.plan_source`, `request.packet_id`, `request.closing_sidecar`, and `request.title_suffix`.
   - packet identity comes from bundle policy seed (`architect_packet_id_seed`, `architect_packet_id_seed_slice`) plus `Execution Order` in `storage/handoff/PLAN.md`, never from archive or TASK inference.
13. Architect active-slice projection emission:
   - validated architect slice runs emit `[ACTIVE SLICE PROJECTION]` in the text artifact,
   - projection is built only from active-slice handoff data (`Selected Option`, `Execution Order`, selected slice field blocks, `Architect Constraints`) plus transport-defined packet identity.
14. Bundle text rendering with embedded stance contract text rendered through `ops/bin/manifest` stance template keys.
15. Manifest v2 emission and package `.tar` emission with manifest-aligned member list.
16. Canonical profile-prefixed artifact output in `storage/handoff/` with optional legacy `BUNDLE-*` compatibility copies.
17. Alias-route metadata emission in manifest (`profile_alias.applied`, `.from`, `.to`, `.deprecation_status`, `.remove_after_dp`) when compatibility aliases are used.
18. Assembly metadata emission in manifest with ATS IDs, schema version, validation source pointers, and advisory-input status (`STELA.md`, `SCAFFOLD.md`).
19. Deterministic runtime assembly pointer emission when ATS is applied:
   - path derived from canonical bundle artifact path with policy suffix/format,
   - manifest `assembly.pointer` metadata emitted (`emitted`, `path`, `format`),
   - pointer artifact added to package members.
20. No pointer emission when ATS is not applied (`assembly.pointer.emitted=false`, `path=null`).
21. Analyst handoff and request emission:
   - fail closed when `storage/handoff/TOPIC.md` is absent,
   - emit analyst `[REQUEST]` metadata `topic_source` and `output_surface`,
   - invoke analyst full dump with explicit `--include-file=storage/handoff/TOPIC.md`,
   - omit `storage/handoff/PLAN.md` from analyst package members and analyst handoff reporting.
22. Profile-scoped disposable input transport:
   - resolve outgoing disposable inputs as exact file paths only,
   - add those files to dump explicit includes,
   - add those files to package members,
   - never widen to directory sweeps or generic `storage/` capture.
23. Architect disposable transport:
   - include `storage/handoff/PLAN.md` when present,
   - emit architect `[HANDOFF]` for `PLAN.md` only,
   - preserve existing architect request metadata and active-slice projection behavior.
24. Audit disposable transport:
   - resolve current packet id from the current TASK surface,
   - require current `storage/handoff/<DP_ID>-RESULTS.md` and `storage/handoff/CLOSING-<DP_ID>.md`,
   - invoke audit core dump with explicit include for those two files,
   - include those two files in audit package members.

Stance contract extraction and render rules:
- Resolve profile stance template key from `ops/lib/manifests/BUNDLE.md`.
- Render stance body via `ops/bin/manifest render <stance-key> --out=-`.
- Strip only contiguous leading HTML comment lines and immediately following leading blank lines.
- If `Rules:` exists in the rendered stance body, emit from `Rules:` through end-of-file.
- Otherwise emit the stripped stance body as-is.

Text artifact profile conditional rule:
- Emit `[HANDOFF]` only when resolved profile is not `audit` and not `foreman`.
- For `analyst`, `[HANDOFF]` reports `TOPIC.md` presence only, `[REQUEST]` reports `topic_source` plus `output_surface`, and the dump payload embeds `storage/handoff/TOPIC.md` as an explicit include.
- For `architect`, `[HANDOFF]` reports `PLAN.md` presence only when present.
- Profiles without disposable inputs emit no `[HANDOFF]` block.

## Anecdotal Anchor
DP-OPS-0145 introduced bundle as a transport primitive. DP-OPS-0146 hardened it for attach-only architect workflows and addendum authorization flows by eliminating OPEN artifact dependence and adding deterministic package metadata.

## Integrity Filter Warnings
The script assumes canonical stance templates under `ops/src/stances/` via manifest key mapping. Path/key drift without policy updates causes hard failure. `ops/lib/manifests/BUNDLE.md` and `ops/lib/manifests/ASSEMBLY.md` parse failures are fail-closed and block bundle generation. Runtime behavior must remain deterministic and pointer-first; dump payload bodies must not be inlined into bundle text.
