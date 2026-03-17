<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/bundle` produces delivery packets for analyst, architect, audit, project, conform, and foreman roles. It is a transport contract, not a free-form export path: profile routing, explicit disposable inputs, dump selection, and emitted artifact identity are deterministic.

## Mechanics and Sequencing
1. Validate arguments and resolve the requested profile or `auto` route.
2. Load policy from `ops/lib/manifests/BUNDLE.md`.
3. Resolve stance template, artifact prefix, dump scope, and dump persistence profile from policy.
4. Resolve profile-scoped exact-file disposable inputs.
5. Invoke `ops/bin/dump` with explicit output path and explicit persistence profile.
6. Render bundle text, emit manifest, and emit package tar.
7. For audit reruns, emit fresh transport identity and submission lineage.

## Dump Scope Mapping
1. `analyst|architect|conform` -> `ops/bin/dump --scope=full`
2. `audit` -> `ops/bin/dump --scope=core`
3. `foreman` -> `ops/bin/dump --scope=core`
4. `project` -> `ops/bin/dump --scope=project --project=<name>`

Profile-specific explicit includes:
- analyst: `storage/handoff/TOPIC.md`
- architect: `storage/handoff/PLAN.md` when present
- audit: current `storage/handoff/<DP_ID>-RESULTS.md`, `storage/handoff/CLOSING-<DP_ID>.md`, authoritative current packet source file, and existing exact-file entries from the active packet source `3.2.2 DP-Scoped Load Order`

## Persistence-Tier Routing
1. Bundle passes the resolved profile name into dump as `--persistence-profile=<profile>`.
2. `ops/bin/dump` resolves tiered archive serialization from `ops/etc/persistence.manifest`.
3. Scope and persistence depth stay separate:
   - analyst and architect remain `--scope=full`
   - audit and foreman remain `--scope=core`
   - cold archive compaction happens in dump serialization, not traversal selection

Compatibility alias: `--history-profile=<profile>` remains accepted by dump, but bundle emits the canonical persistence-profile contract.

## Disposable Transport Rule
Disposable inputs are exact file paths only. No directory sweeps, globs, or generic `storage/` capture are allowed.

Current live set:
- analyst: `storage/handoff/TOPIC.md`
- architect: `storage/handoff/PLAN.md`
- audit: current `RESULTS`, current `CLOSING`, and active packet source file

## Audit Submission Identity
- initial audit delivery: `AUDIT-*` (default; no `--rerun` flag required)
- rerun delivery: `AUDIT-R<index>-*` (requires explicit `--rerun` flag)
- prior local `AUDIT-*` artifacts do not promote delivery to rerun identity; explicit `--rerun` is the sole trigger
- manifest lineage fields:
  - `submission.kind`
  - `submission.resubmission_index`
  - `submission.supersedes_bundle_path`
  - `submission.refresh_reason`

Audit dump naming follows the emitted audit artifact stem so rerun bundle, manifest, package, and dump identities stay aligned.

## Smoke and Quarantine Contract
Operator-facing outputs remain under `storage/handoff/` and `storage/dumps/`.
Quarantined smoke outputs are resume/scratch artifacts under:
- `var/tmp/_smoke/handoff/`
- `var/tmp/_smoke/dumps/`

## Integrity Filter Warnings
Bundle enforces operator-facing outputs under `storage/handoff/` and quarantined smoke outputs under `var/tmp/_smoke/handoff/`. Project profile rejects missing or invalid slugs. PLAN lint remains a deterministic safety floor. Policy parse errors in `ops/lib/manifests/BUNDLE.md` are fail-closed.
