<!-- CCD: ff_target="operator-technical" ff_band="10-25" -->
# Bundle Policy Manifest

## Parse Contract
`ops/lib/scripts/bundle.sh` reads this file before profile routing. Missing required keys or invalid values are fail-closed errors.

bundle_manifest_version=1
supported_profiles=analyst,architect,audit,project,hygiene,auditor
auto_default_profile=analyst
auto_plan_profile=architect
project_profile=project
audit_profile=audit
auditor_profile=auditor
auditor_intent_form=ADDENDUM REQUIRED: <DECISION_ID> - <ONE-LINE BLOCKER>
handoff_omit_profiles=audit,auditor

prompt_path_analyst=docs/ops/prompts/e-prompt-04.md
prompt_path_architect=docs/ops/prompts/e-prompt-03.md
prompt_path_audit=docs/ops/prompts/e-prompt-01.md
prompt_path_project=docs/ops/prompts/e-prompt-04.md
prompt_path_hygiene=docs/ops/prompts/e-prompt-02.md
prompt_path_auditor=docs/ops/prompts/e-prompt-05.md

dump_scope_analyst=full
dump_scope_architect=full
dump_scope_audit=core
dump_scope_project=project
dump_scope_hygiene=full
dump_scope_auditor=core

## Profile Attachment Contract
- analyst: `BUNDLE-*.txt`, `BUNDLE-*.manifest.json`, query source
- architect: `BUNDLE-*.txt`, `BUNDLE-*.manifest.json`, `storage/handoff/PLAN.md`
- audit: `BUNDLE-*.txt`, `BUNDLE-*.manifest.json`, DP RESULTS receipt
- auditor: `BUNDLE-*.txt`, `BUNDLE-*.manifest.json`
- project: `BUNDLE-*.txt`, `BUNDLE-*.manifest.json`
- hygiene: `BUNDLE-*.txt`, `BUNDLE-*.manifest.json`, draft DP input

## Compatibility Notes
Current profile names remain unchanged in this packet. Alias and rename behavior is deferred to later DPs.
