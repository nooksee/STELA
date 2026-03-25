<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/bundle` produces delivery packets for planning, draft, audit, project, conform, and addenda profiles. It is a transport contract, not a free-form export path: profile routing, explicit disposable inputs, dump selection, and emitted artifact identity are deterministic.

## Shipping Spine Position
Bundle sits at two points in the shipping spine:
- **Planning/Draft input:** `--profile=planning` or `--profile=draft` delivers the context package that produces `PLAN.md` (planning) or the active DP draft at `storage/dp/intake/DP.md` (draft).
- **Audit delivery:** `--profile=audit` packages certify-generated RESULTS and CLOSING for audit review. This is the canonical audit intake mechanism and is **separate** from operator session refresh (`ops/bin/open`, `ops/bin/dump` for CDD). Do not conflate bundle audit with standalone `ops/bin/dump --scope=core` closeout steps.
- **Secondary lanes:** `--profile=addenda` is an intervention intake path (not a PASS/FAIL verdict workflow). `--profile=conform` is a structure normalization lane. Neither replaces RESULTS or audit truth.

## Active Surface Names
- Planning input: `storage/handoff/TOPIC.md` (latest-wins)
- Planning output: `storage/handoff/PLAN.md` (latest-wins)
- Draft output (active DP draft): `storage/dp/intake/DP.md` (printed in bundle `[REQUEST]` as `dp_draft_path`; `packet_id` retains `DP-OPS-XXXX`)
- Audit initial bundle: `storage/handoff/AUDIT-*.txt`
- Audit rerun bundle: `storage/handoff/AUDIT-R<index>-*.txt`

## Mechanics and Sequencing
1. Validate arguments and resolve the requested profile or `auto` route.
2. Load policy from `ops/lib/manifests/BUNDLE.md`.
3. Resolve a real current OPEN anchor for the active branch/head. Bundle consumes the latest matching `OPEN-*.txt` artifact and refreshes it through `ops/bin/open` when absent or stale. Bundle never invents standalone pseudo-OPEN trace ids.
4. Resolve stance template, artifact prefix, dump scope, and dump persistence profile from policy.
5. Resolve profile-scoped exact-file disposable inputs.
6. Invoke `ops/bin/dump` with explicit output path and explicit persistence profile.
7. Render bundle text, emit manifest, and emit package tar. For `--profile=draft`, bundle text also carries an embedded `DP AUTHORING SCAFFOLD` block rendered from the canonical DP template with canon-owned text already expanded and bundle-known packet metadata already populated.
8. The emitted `[OPEN]` block and manifest `open` object carry a pointer plus copied metadata from the real OPEN artifact; they are not an anchor substitute.
9. For audit reruns, emit fresh transport identity and submission lineage.

## Dump Scope Mapping
1. `planning|draft|conform` -> `ops/bin/dump --scope=full`
2. `audit` -> `ops/bin/dump --scope=core`
3. `addenda` -> `ops/bin/dump --scope=core`
4. `project` -> `ops/bin/dump --scope=project --project=<name>`

Profile-specific explicit includes:
- planning: `storage/handoff/TOPIC.md`
- draft: `storage/handoff/PLAN.md` when present
- audit: current `storage/handoff/RESULTS.md`, `storage/handoff/CLOSING.md`, authoritative current packet source file, and existing exact-file entries from the active packet source `3.2.2 DP-Scoped Load Order`

## Persistence-Tier Routing
1. Bundle passes the resolved profile name into dump as `--persistence-profile=<profile>`.
2. `ops/bin/dump` resolves tiered archive serialization from `ops/etc/persistence.manifest`.
3. Scope and persistence depth stay separate:
   - planning and draft remain `--scope=full`
   - audit and addenda remain `--scope=core`
   - cold archive compaction happens in dump serialization, not traversal selection

Compatibility alias: `--history-profile=<profile>` remains accepted by dump, but bundle emits the canonical persistence-profile contract.

## Disposable Transport Rule
Disposable inputs are exact file paths only. No directory sweeps, globs, or generic `storage/` capture are allowed.

Current live set:
- planning: `storage/handoff/TOPIC.md`
- draft: `storage/handoff/PLAN.md`
- audit: current `RESULTS`, current `CLOSING`, and active packet source file

## OPEN Anchor Contract
- OPEN remains the sole spine-grade trace anchor for certify lineage.
- Bundle consumes a current real `OPEN-*.txt` artifact for the active branch/head.
- If the latest OPEN is missing or stale for the current branch/head, bundle refreshes one through `ops/bin/open` before continuing.
- Bundle text/manifest may mirror OPEN fields (`artifact_path`, `branch`, `head_short`, `trace_id`, `intent`) but those mirrors are descriptive only; they do not replace the OPEN artifact.

## Planning Profile Surfaces
- `storage/handoff/TOPIC.md`: required input surface; bundle fails closed if absent.
- `PLANNING-*.txt`: emitted bundle artifact containing the dump payload and stance contract.
- `storage/handoff/PLAN.md`: model output surface, latest-wins; the model writes this file after each planning run.
- `var/tmp/PLAN.md.prev`: disposable safety backup written by bundle before each planning run if `storage/handoff/PLAN.md` is present. Not a certify input; prune may remove it.

## Draft Profile Surfaces
- `storage/handoff/PLAN.md`: required plan input surface for draft intake.
- `DRAFT-*.txt`: emitted bundle artifact containing the dump payload, stance contract, and embedded `DP AUTHORING SCAFFOLD` block.
- `storage/dp/intake/DP.md`: latest-wins active DP draft surface; printed in bundle `[REQUEST]` as `dp_draft_path`. Draft model output is a fenced worker-ready DP body saved here by the operator for dispatch.
- `packet_id`: process identity retained in bundle `[REQUEST]`, TASK/addendum lineage, audit transport, and telemetry (`DP-OPS-XXXX`). Runtime resolves the next packet id from the current certified TASK packet id plus one.

## Audit Submission Identity
- initial audit delivery: `AUDIT-*` (default; no `--rerun` flag required)
- rerun delivery: `AUDIT-R<index>-*` (requires explicit `--rerun` flag)
- prior local `AUDIT-*` artifacts do not promote delivery to rerun identity; explicit `--rerun` is the sole trigger
- explicit `--rerun` still emits rerun identity even when no local prior audit bundle is present; in that case `submission.supersedes_bundle_path` remains null and the first rerun index is `1`
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
