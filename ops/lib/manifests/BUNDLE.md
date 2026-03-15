<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Bundle Policy Manifest

## Parse Contract
`ops/lib/scripts/bundle.sh` reads this file before profile routing. Missing required keys or invalid values are fail-closed errors.
Stance contract bodies are rendered from `ops/src/stances/*.md.tpl` through `ops/bin/manifest` stance keys.
ATS schema policy is loaded from `ops/lib/manifests/ASSEMBLY.md` through the key `assembly_policy_manifest`.

bundle_manifest_version=1
supported_profiles=analyst,architect,audit,project,conform,foreman
auto_default_profile=analyst
auto_plan_profile=architect
project_profile=project
audit_profile=audit
foreman_profile=foreman
foreman_intent_form=ADDENDUM REQUIRED: <DECISION_ID> - <ONE-LINE BLOCKER>
architect_packet_id_seed=DP-OPS-0189
architect_packet_id_seed_slice=T1
profile_alias_legacy_hygiene_to=conform
profile_alias_legacy_hygiene_deprecation_status=sunset
profile_alias_legacy_hygiene_remove_after_dp=DP-OPS-0165
handoff_omit_profiles=audit,foreman

stance_template_analyst=stance-analyst
stance_template_architect=stance-architect
stance_template_audit=stance-auditor
stance_template_project=stance-analyst
stance_template_conform=stance-conformist
stance_template_foreman=stance-foreman

artifact_prefix_analyst=ANALYST
artifact_prefix_architect=ARCHITECT
artifact_prefix_audit=AUDIT
artifact_prefix_project=PROJECT
artifact_prefix_conform=CONFORM
artifact_prefix_foreman=FOREMAN
compatibility_legacy_bundle_prefix=BUNDLE
compatibility_emit_legacy_bundle_artifacts=false
frontdoor_canonical_binary=ops/bin/bundle
frontdoor_meta_mode=project_shim
frontdoor_meta_deprecation_status=not_scheduled
frontdoor_meta_remove_after_dp=none
assembly_policy_manifest=ops/lib/manifests/ASSEMBLY.md

dump_scope_analyst=full
dump_scope_architect=full
dump_scope_audit=core
dump_scope_project=project
dump_scope_conform=full
dump_scope_foreman=core

## Profile Attachment Contract
- analyst: `ANALYST-*.txt`, `ANALYST-*.manifest.json`, `storage/handoff/TOPIC.md`
- architect: `ARCHITECT-*.txt`, `ARCHITECT-*.manifest.json`, `storage/handoff/PLAN.md`, optional `--slice=<ID>` with request metadata (`slice_id`, `slice_validated`, `plan_source`, `packet_id`, `closing_sidecar`, `title_suffix`)
- audit: `AUDIT-*.txt`, `AUDIT-*.manifest.json`, DP RESULTS receipt
- foreman: `FOREMAN-*.txt`, `FOREMAN-*.manifest.json`
- project: `PROJECT-*.txt`, `PROJECT-*.manifest.json`
- conform: `CONFORM-*.txt`, `CONFORM-*.manifest.json`, draft DP input

## Analyst Transport Contract
- Analyst requires `storage/handoff/TOPIC.md` as input and fails closed when it is absent.
- Analyst emits request metadata `topic_source=storage/handoff/TOPIC.md` and `output_surface=storage/handoff/PLAN.md`.
- Analyst invokes the full dump with explicit `storage/handoff/TOPIC.md` inclusion so the dump payload contains the topic artifact as a file block.
- Analyst package members include `storage/handoff/TOPIC.md` and omit `storage/handoff/PLAN.md`.
- Analyst `PLAN.md` is output only and is never transported as analyst input context.

## Architect Transport Contract
- Architect packet identity is transport-defined when an explicit validated slice is present.
- `architect_packet_id_seed` defines the first dispatch-corridor packet id.
- `architect_packet_id_seed_slice` defines the slice bound to that seed.
- Runtime derives later architect packet ids by offset within `Execution Order` in `storage/handoff/PLAN.md`.
- `closing_sidecar` is derived as `storage/handoff/CLOSING-<packet_id>.md`.
- `title_suffix` is derived from the active slice heading text in `storage/handoff/PLAN.md`.
- Omitted `--slice` stays ad hoc unless `## Architect Handoff` explicitly opts into safe auto-bind with one unambiguous selected slice.
- Architect text artifacts emit a stripped active-slice projection built only from:
  - `Selected Option`
  - selected slice id
  - `Execution Order`
  - slice `Objective`
  - slice `Scope`
  - slice `Acceptance gate`
  - slice `Receipt contract` when present
  - `Architect Constraints`
  - transport-defined `packet_id`, `closing_sidecar`, and `title_suffix`

## Compatibility Notes
Canonical audit verdict profile is `audit`.
Canonical addendum authorization profile is `foreman`.
Legacy `hygiene` remains accepted as a compatibility alias and resolves to `conform`.
Alias routing values are loaded from `profile_alias_legacy_hygiene_to` at runtime.
Legacy `hygiene` alias deprecation status is `sunset`; removal target is `DP-OPS-0165`.
Legacy `BUNDLE-*` artifact names remain compatibility outputs during migration and are controlled by `compatibility_emit_legacy_bundle_artifacts`.
Canonical front door is `ops/bin/bundle`.
`ops/bin/meta` remains a project-only compatibility shim (`frontdoor_meta_mode=project_shim`).
Meta shim deprecation status is `not_scheduled`; removal target is `none`.
