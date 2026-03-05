<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Bundle Policy Manifest

## Parse Contract
`ops/lib/scripts/bundle.sh` reads this file before profile routing. Missing required keys or invalid values are fail-closed errors.
Stance contract bodies are rendered from `ops/src/stances/*.md.tpl` through `ops/bin/manifest` stance keys.

bundle_manifest_version=1
supported_profiles=analyst,architect,audit,project,conform,foreman
auto_default_profile=analyst
auto_plan_profile=architect
project_profile=project
audit_profile=audit
foreman_profile=foreman
foreman_intent_form=ADDENDUM REQUIRED: <DECISION_ID> - <ONE-LINE BLOCKER>
profile_alias_legacy_auditor_to=foreman
profile_alias_legacy_hygiene_to=conform
profile_alias_legacy_auditor_deprecation_status=active
profile_alias_legacy_auditor_remove_after_dp=DP-OPS-0156
profile_alias_legacy_hygiene_deprecation_status=active
profile_alias_legacy_hygiene_remove_after_dp=DP-OPS-0156
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
compatibility_emit_legacy_bundle_artifacts=true

dump_scope_analyst=full
dump_scope_architect=full
dump_scope_audit=core
dump_scope_project=project
dump_scope_conform=full
dump_scope_foreman=core

## Profile Attachment Contract
- analyst: `ANALYST-*.txt`, `ANALYST-*.manifest.json`, query source
- architect: `ARCHITECT-*.txt`, `ARCHITECT-*.manifest.json`, `storage/handoff/PLAN.md`
- audit: `AUDIT-*.txt`, `AUDIT-*.manifest.json`, DP RESULTS receipt
- foreman: `FOREMAN-*.txt`, `FOREMAN-*.manifest.json`
- project: `PROJECT-*.txt`, `PROJECT-*.manifest.json`
- conform: `CONFORM-*.txt`, `CONFORM-*.manifest.json`, draft DP input

## Compatibility Notes
Canonical audit verdict profile is `audit`.
Canonical addendum authorization profile is `foreman`.
Legacy `auditor` remains accepted as a compatibility alias and resolves to `foreman`.
Legacy `hygiene` remains accepted as a compatibility alias and resolves to `conform`.
Alias routing values are loaded from `profile_alias_legacy_auditor_to` and `profile_alias_legacy_hygiene_to` at runtime.
Legacy `auditor` alias deprecation status is `active`; removal target is `DP-OPS-0156`.
Legacy `hygiene` alias deprecation status is `active`; removal target is `DP-OPS-0156`.
Legacy `BUNDLE-*` artifact names remain compatibility outputs during migration and are controlled by `compatibility_emit_legacy_bundle_artifacts`.
