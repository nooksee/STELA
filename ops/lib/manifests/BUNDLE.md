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
smoke_handoff_root=var/tmp/_smoke/handoff
smoke_dump_root=var/tmp/_smoke/dumps
audit_resubmission_prefix=AUDIT-R
audit_submission_kind_initial=audit_submission
audit_submission_kind_rerun=audit_resubmission
audit_refresh_reason_initial=initial
audit_refresh_reason_rerun=rerun
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

## Persistence-Tier Routing Contract
- Bundle does not serialize cold archive policy itself. It routes a persistence profile into `ops/bin/dump`, and `ops/bin/dump` resolves tiered archive serialization from `ops/etc/persistence.manifest`.
- Current routing is profile-name aligned:
  - analyst -> `--persistence-profile=analyst`
  - architect -> `--persistence-profile=architect`
  - audit -> `--persistence-profile=audit`
  - project -> `--persistence-profile=project`
  - conform -> `--persistence-profile=conform`
  - foreman -> `--persistence-profile=foreman`
- Scope and persistence profile are independent:
  - analyst and architect still use `--scope=full`
  - audit and foreman still use `--scope=core`
  - persistence-tier compaction happens inside dump serialization, not traverse selection

## Profile Attachment Contract
- analyst: `ANALYST-*.txt`, `ANALYST-*.manifest.json`, transport-managed `storage/handoff/TOPIC.md`
- architect: `ARCHITECT-*.txt`, `ARCHITECT-*.manifest.json`, transport-managed `storage/handoff/PLAN.md` with request metadata (`plan_source`, `packet_id`, `closing_sidecar`, `dp_draft_path`)
- audit: initial `AUDIT-*.txt`, rerun `AUDIT-R*-*.txt`, matching `.manifest.json`/`.tar`, transport-managed current DP `storage/handoff/RESULTS.md` and `storage/handoff/CLOSING.md`
- foreman: `FOREMAN-*.txt`, `FOREMAN-*.manifest.json`
- project: `PROJECT-*.txt`, `PROJECT-*.manifest.json`
- conform: `CONFORM-*.txt`, `CONFORM-*.manifest.json`, draft DP input

## Disposable Transport Contract
- Disposable transport is profile-scoped exact-file wiring only. No directory sweeps, globs, or generic `storage/` capture are allowed.
- Current live disposable inputs are:
  - analyst: `storage/handoff/TOPIC.md`
  - architect: `storage/handoff/PLAN.md`
  - audit: current `storage/handoff/RESULTS.md` and `storage/handoff/CLOSING.md`
- Future disposable additions must be exact file paths added deliberately in runtime wiring, specs, and smoke tests.

## Analyst Transport Contract
- Analyst requires `storage/handoff/TOPIC.md` as input and fails closed when it is absent.
- Analyst emits request metadata `topic_source=storage/handoff/TOPIC.md` and `output_surface=storage/handoff/PLAN.md`.
- Analyst invokes the full dump with explicit `storage/handoff/TOPIC.md` inclusion so the dump payload contains the topic artifact as a file block.
- Analyst package members include `storage/handoff/TOPIC.md` and omit `storage/handoff/PLAN.md`.
- Analyst `PLAN.md` is output only and is never transported as analyst input context.
- `storage/handoff/TOPIC.md` is the latest-wins input surface; the operator replaces its content before each analyst run.
- `storage/handoff/PLAN.md` is the latest-wins output surface written by the model after each analyst run.
- Before each analyst run, bundle writes a disposable copy of the prior `storage/handoff/PLAN.md` to `var/tmp/PLAN.md.prev` if that file exists. This copy is a scratch artifact only; certify has no dependency on it and prune may remove it.

## Architect Transport Contract
- Architect requires `storage/handoff/PLAN.md`.
- Architect invokes the full dump with explicit `storage/handoff/PLAN.md` inclusion.
- Architect package members include `storage/handoff/PLAN.md` only.
- Runtime derives architect `packet_id` from the current certified TASK packet id plus one.
- `closing_sidecar` is the active latest-wins sidecar `storage/handoff/CLOSING.md`; packet identity remains explicit in request metadata and sidecar content.
- `storage/handoff/PLAN.md` is the latest-wins architect plan input surface.
- `storage/dp/intake/DP.md` is the deterministic active DP draft surface; architect model output is a fenced DP draft block that the operator saves to this path for dispatch.

## Audit Transport Contract
- Audit resolves the current certified packet id from the current TASK surface.
- Audit requires `storage/handoff/RESULTS.md` and `storage/handoff/CLOSING.md` for that current packet and fails closed when either file is missing.
- Audit invokes the core dump with explicit inclusion of those two files, the authoritative current packet source file, and existing exact-file entries from the active packet's `3.2.2 DP-Scoped Load Order` so new packet-substantive canon files are inspectable even when they are not yet tracked.
- Audit package members include the resolved current `RESULTS` and `CLOSING` files.
- Audit reruns must emit fresh artifact identity under `audit_resubmission_prefix` and record submission lineage in the emitted manifest.
- Audit rerun identity is gated on explicit `--rerun` intent. Prior local `AUDIT-*` artifacts do not force rerun naming without `--rerun`.

## Smoke Transport Contract
- Quarantined smoke outputs use `smoke_handoff_root` and `smoke_dump_root`.
- Smoke outputs are resume/scratch artifacts under `var/tmp/`, not payload artifacts under `storage/`.

## Shipping Spine Contract
The canonical operator shipping chain uses bundle at two points:
- `--profile=analyst`: deliver context + TOPIC.md to analyst model; analyst writes PLAN.md
- `--profile=architect`: deliver context + PLAN.md to architect model; architect emits fenced DP draft block; operator saves to `storage/dp/intake/DP.md` while packet identity remains `DP-OPS-XXXX`
- Worker executes DP; certify generates RESULTS + emits surface leaves
- `--profile=audit`: package RESULTS + CLOSING for auditor review; audit bundle dump is the canonical audit evidence payload
- Operator commits on work branch, opens PR per CLOSING sidecar, merges to main

Secondary lanes are bounded and do not replace RESULTS or audit truth:
- `--profile=foreman`: intervention intake only (not PASS/FAIL); intent form must be `ADDENDUM REQUIRED: <DECISION_ID> - <BLOCKER>`
- `--profile=conform`: structure normalization; output is a revised DP draft, not an audit verdict
- execution-decision: disposable/manual placement, not a bundle profile

Audit dump generation is owned by `--profile=audit`. Standalone `ops/bin/dump --scope=core` in DP closeout is not a universal requirement and is not equivalent to the audit bundle dump.

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
