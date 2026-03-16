<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Verify Lane Policy Manifest

## Parse Contract
`tools/verify.sh` and `ops/bin/certify` read this file for lane order, lane ownership,
reason-class policy, and packet-local selection. Parse failure is fail-closed.

verify_manifest_version=2
default_mode=full
certify_mode=certify-critical

## Lane Definitions
lane=open-dedup|order=10|modes=full,certify-critical|command=bash tools/test/open.sh|scope=closeout-critical|owner=TEST-03|registry_table=test|registry_path=tools/test/open.sh|reason_class=closeout-critical|decision_leaf=archives/decisions/RoR-2026-03-16-001-cbc-0202.md|match=ops/bin/open,tools/test/open.sh,docs/ops/specs/binaries/open.md,docs/ops/specs/tools/test/open.md
lane=editor-scaffold|order=20|modes=full|command=bash tools/test/editor.sh|scope=standalone-full-only|owner=TEST-04|registry_table=test|registry_path=tools/test/editor.sh|reason_class=standalone-full-only|decision_leaf=archives/decisions/RoR-2026-03-16-001-cbc-0202.md|match=ops/bin/draft,tools/test/editor.sh,docs/ops/specs/binaries/draft.md,docs/ops/specs/tools/test/editor.md
lane=guard-debt-lint|order=30|modes=full|command=bash tools/lint/debt.sh|scope=standalone-full-only|owner=LINT-18|registry_table=lint|registry_path=tools/lint/debt.sh|reason_class=standalone-full-only|decision_leaf=archives/decisions/RoR-2026-03-16-001-cbc-0202.md|match=ops/lib/manifests/DEBT.md,tools/lint/debt.sh,docs/ops/specs/tools/lint/debt.md
lane=factory-smoke|order=40|modes=full,certify-critical|command=bash tools/test/factory.sh|scope=packet-local|owner=TEST-05|registry_table=test|registry_path=tools/test/factory.sh|reason_class=packet-local|decision_leaf=archives/decisions/RoR-2026-03-16-003-cbc-0202.md|match=tools/test/factory.sh,docs/ops/specs/tools/test/factory.md,ops/lib/manifests/ASSEMBLY.md,docs/ops/registry/agents.md,docs/ops/registry/skills.md,docs/ops/registry/tasks.md,docs/ops/registry/test.md,ops/bin/meta
lane=response-self-test|order=50|modes=full,certify-critical|command=bash tools/lint/response.sh --test|scope=packet-local|owner=LINT-17|registry_table=lint|registry_path=tools/lint/response.sh|reason_class=packet-local|decision_leaf=archives/decisions/RoR-2026-03-16-001-cbc-0202.md|match=tools/lint/response.sh,docs/ops/specs/tools/lint/response.md,ops/src/shared/stances.json
lane=bundle-smoke|order=60|modes=full,certify-critical|command=bash tools/test/bundle.sh|scope=closeout-critical|owner=TEST-02|registry_table=test|registry_path=tools/test/bundle.sh|reason_class=closeout-critical|decision_leaf=archives/decisions/RoR-2026-03-16-002-cbc-0202.md|match=ops/bin/bundle,ops/bin/dump,ops/bin/meta,ops/lib/scripts/bundle.sh,tools/test/bundle.sh,docs/ops/specs/binaries/bundle.md,docs/ops/specs/binaries/dump.md,docs/ops/specs/binaries/meta.md,docs/ops/specs/scripts/bundle.md,docs/ops/specs/tools/test/bundle.md,docs/ops/specs/surfaces/results.md,docs/ops/specs/surfaces/task.md

## Reason Class Meanings
reason=closeout-critical|meaning=Required inside certify because it proves a current closeout or audit-delivery invariant.
reason=packet-local|meaning=Run inside certify only when the active packet changed files owned by this lane.
reason=standalone-full-only|meaning=Remain available in full repo verify, but do not replay inside certify.
