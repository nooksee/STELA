<!-- CCD: ff_target="operator-technical" ff_band="10-25" -->
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
handoff_omit_profiles=audit,foreman

prompt_path_analyst=docs/ops/prompts/e-prompt-04.md
prompt_path_architect=docs/ops/prompts/e-prompt-03.md
prompt_path_audit=docs/ops/prompts/e-prompt-01.md
prompt_path_project=docs/ops/prompts/e-prompt-04.md
prompt_path_conform=docs/ops/prompts/e-prompt-02.md
prompt_path_foreman=docs/ops/prompts/e-prompt-05.md

stance_template_analyst=stance-analyst
stance_template_architect=stance-architect
stance_template_audit=stance-auditor
stance_template_project=stance-analyst
stance_template_conform=stance-conformist
stance_template_foreman=stance-foreman

dump_scope_analyst=full
dump_scope_architect=full
dump_scope_audit=core
dump_scope_project=project
dump_scope_conform=full
dump_scope_foreman=core

## Profile Attachment Contract
- analyst: `BUNDLE-*.txt`, `BUNDLE-*.manifest.json`, query source
- architect: `BUNDLE-*.txt`, `BUNDLE-*.manifest.json`, `storage/handoff/PLAN.md`
- audit: `BUNDLE-*.txt`, `BUNDLE-*.manifest.json`, DP RESULTS receipt
- foreman: `BUNDLE-*.txt`, `BUNDLE-*.manifest.json`
- project: `BUNDLE-*.txt`, `BUNDLE-*.manifest.json`
- conform: `BUNDLE-*.txt`, `BUNDLE-*.manifest.json`, draft DP input

## Compatibility Notes
Canonical addendum authorization profile is `foreman`.
Legacy `auditor` remains accepted as a compatibility alias and resolves to `foreman`.
Legacy `hygiene` remains accepted as a compatibility alias and resolves to `conform`.
