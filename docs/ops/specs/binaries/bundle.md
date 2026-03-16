<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/bundle` is the deterministic transport primitive and canonical front door for workflow intake. It unifies OPEN freshness metadata, dump pointers, stance contract text, and route metadata into one portable contract so operator handoffs do not depend on manual copy or ad hoc artifact selection.

## Mechanics and Sequencing
Public interface:
1. `--profile=auto|analyst|architect|audit|project|conform|hygiene|foreman`
   - Canonical conformance profile is `conform`.
   - Legacy `hygiene` is accepted as a compatibility alias to `conform`.
   - Canonical addendum authorization profile is `foreman`.
2. `--out=auto|PATH`
3. `--project=<name>` (required only for `project`)
4. `--intent=<text>` (required for `foreman`)
5. `--agent-id=<R-AGENT-..> --skill-id=<S-LEARN-..> --task-id=<B-TASK-..>` (optional ATS triplet; all-or-none)
6. `--slice=<ID>` (optional; architect profile only)

Policy source:
1. Runtime contract is loaded from `ops/lib/manifests/BUNDLE.md`.
2. Missing required policy keys or invalid values are fail-closed errors.
3. Profile routing, dump scopes, and stance template render keys are resolved from this manifest.
4. ATS schema linkage is resolved from `assembly_policy_manifest` in `ops/lib/manifests/BUNDLE.md`.
5. Runtime ATS schema and validation rules are loaded from `ops/lib/manifests/ASSEMBLY.md`.
6. ATS validation sources are canonical registry IDs in:
   - `docs/ops/registry/agents.md`
   - `docs/ops/registry/skills.md`
   - `docs/ops/registry/tasks.md`
7. Compatibility alias routing is resolved from manifest keys:
   - `profile_alias_legacy_hygiene_to`
   - `profile_alias_legacy_hygiene_deprecation_status`
   - `profile_alias_legacy_hygiene_remove_after_dp`
8. Front-door policy is resolved from manifest keys:
   - `frontdoor_canonical_binary`
   - `frontdoor_meta_mode`
   - `frontdoor_meta_deprecation_status`
   - `frontdoor_meta_remove_after_dp`

Front-door contract:
1. Canonical front door is `ops/bin/bundle`.
2. `ops/bin/meta` is a project-only compatibility shim and must not contain independent routing logic.
3. `ops/bin/meta` delegates to `ops/bin/bundle --profile=project --project=<name> --out=<resolved-value>` only, where meta defaults to `--out=auto` and may pass through an explicit `--out=PATH` without adding independent routing logic.

Profile intent split:
1. `audit` is the audit-verdict intake profile.
2. `foreman` is addendum-authorization intake profile.
3. `foreman` is not a substitute for `audit`.

Compatibility alias deprecation window:
1. Legacy alias acceptance is in `sunset` status during the deprecation window.
2. Each legacy alias must publish deprecation metadata in policy (`*_deprecation_status`, `*_remove_after_dp`).
3. Bundle manifest output must include alias deprecation metadata whenever `profile_alias.applied` is true.

Routing rules:
1. Explicit supported profile selects that profile.
2. `--profile=auto` resolves to `auto_plan_profile` when `storage/handoff/PLAN.md` exists and `tools/lint/plan.sh` passes.
3. Otherwise auto resolves to `auto_default_profile`.

Architect slice gate:
1. `--slice=<ID>` is accepted only when resolved profile is `architect`.
2. Blank `--slice=` fails before artifact emission.
3. Architect slice values are validated against `Selected Slices` in `storage/handoff/PLAN.md` under `## Architect Handoff`.
4. Unknown architect slices fail before artifact emission.
5. Omitting `--slice` keeps architect in ad hoc mode unless `## Architect Handoff` explicitly opts into safe auto-bind with one unambiguous selected slice.

Architect transport metadata:
1. When architect slice validation succeeds, transport derives packet identity from `architect_packet_id_seed`, `architect_packet_id_seed_slice`, and `Execution Order` in `storage/handoff/PLAN.md`.
2. `closing_sidecar` is derived as `storage/handoff/CLOSING-<packet_id>.md`.
3. `title_suffix` is derived from the selected slice heading text in `storage/handoff/PLAN.md`.
4. Architect text artifacts emit a stripped `[ACTIVE SLICE PROJECTION]` block limited to:
   - `Selected Option`
   - selected slice id
   - `Execution Order`
   - slice `Objective`
   - slice `Scope`
   - slice `Acceptance gate`
   - slice `Receipt contract` when present
   - `Architect Constraints`
   - transport-defined `packet_id`, `closing_sidecar`, and `title_suffix`

Artifact contract (written under `storage/handoff/`):
1. Bundle text artifact (`.txt`) with embedded OPEN block, dump pointers, stance contract source marker, stance template key, and embedded stance contract excerpt.
2. Bundle manifest (`.manifest.json`) with `bundle_version: "2"` and structured metadata:
   - profile routing metadata
   - profile alias metadata (`applied`, `from`, `to`, `deprecation_status`, `remove_after_dp`)
   - embedded OPEN metadata (`embedded`, `branch`, `head_short`, `trace_id`, `intent`)
   - dump pointers
   - topic/plan presence
   - profile-specific request metadata:
     - analyst: `request.topic_source`, `request.output_surface`
     - architect: `request.slice_id`, `request.slice_validated`, `request.plan_source`, `request.packet_id`, `request.closing_sidecar`, `request.title_suffix`
   - stance template metadata (`stance_template_key`)
   - addendum metadata (`required`, `decision_id`, `decision_leaf_present`)
   - package metadata (`path`, `files`)
3. Bundle package (`.tar`) containing bundle `.txt`, manifest, dump payload, dump manifest, and profile-specific handoff members.
   - analyst includes `TOPIC.md` only and analyst dump payload embeds `storage/handoff/TOPIC.md`
   - architect includes `PLAN.md` when present and architect dump payload embeds `storage/handoff/PLAN.md`
   - audit includes current `RESULTS` and `CLOSING` files and audit dump payload embeds both
4. Canonical bundle artifact names use policy-defined profile prefixes (`artifact_prefix_<profile>` in `ops/lib/manifests/BUNDLE.md`), for example `AUDIT-*` and `FOREMAN-*`.
5. Legacy `BUNDLE-*` artifacts are compatibility outputs during migration when `compatibility_emit_legacy_bundle_artifacts=true`.
6. Manifest `artifact_naming` metadata records canonical and compatibility artifact paths plus `legacy_emitted` status.
7. Manifest includes `assembly` metadata block:
   - `applied`
   - `schema_version`
   - `policy_manifest`
   - ATS IDs (`agent_id`, `skill_id`, `task_id`) when applied
   - `validated_against` registry pointers
   - `pointer` metadata (`emitted`, `path`, `format`)
   - advisory-input status for `STELA.md` and `SCAFFOLD.md`
8. When ATS is applied and assembly pointer policy is `emit_when_applied`, runtime emits a deterministic pointer artifact under `storage/handoff/`.
9. When ATS is not applied, `assembly.pointer.emitted` is `false` and runtime emits no assembly pointer artifact.

Text artifact profile conditional block:
1. The `[HANDOFF]` block is emitted for non-audit profiles.
2. For `audit` and `foreman` resolved profiles, the text artifact omits `[HANDOFF]` to avoid unrelated intake noise in audit flows.
3. For `analyst`, the text artifact emits `[REQUEST]` with `topic_source` and `output_surface`, and `[HANDOFF]` reports `TOPIC.md` only.
4. For `architect`, the text artifact emits a `[REQUEST]` block with slice metadata and packet identity metadata, and `[HANDOFF]` reports `PLAN.md` only when present.
5. Profiles without disposable input files emit no `[HANDOFF]` block.
6. For validated architect slice runs, the text artifact also emits `[ACTIVE SLICE PROJECTION]`.

Foreman gate:
1. `--profile=foreman` requires `--intent`.
2. Intent format must be `ADDENDUM REQUIRED: <DECISION_ID> - <ONE-LINE BLOCKER>`.
3. Bundle runtime verifies `<DECISION_ID>` exists in dump payload; missing decision leaf is a hard failure.

Dump scope mapping by resolved profile:
1. `analyst|architect|conform` -> `ops/bin/dump --scope=full`.
   - analyst adds explicit `--include-file=storage/handoff/TOPIC.md`
   - architect adds explicit `--include-file=storage/handoff/PLAN.md` when present
2. `audit` -> `ops/bin/dump --scope=core`.
   - audit adds explicit `--include-file=storage/handoff/<DP_ID>-RESULTS.md`
   - audit adds explicit `--include-file=storage/handoff/CLOSING-<DP_ID>.md`
   - audit adds explicit `--include-file=storage/dp/processed/<DP_ID>.md` or `storage/dp/intake/<DP_ID>.md` for the current packet source
3. `foreman` -> `ops/bin/dump --scope=core`.
4. `project` -> `ops/bin/dump --scope=project --project=<name>`.

History-tier routing:
1. Bundle passes the resolved profile name into dump as `--history-profile=<profile>`.
2. `ops/bin/dump` resolves tiered archive serialization from `ops/lib/manifests/HISTORY.md`.
3. Scope and history depth remain separate concerns:
   - analyst and architect stay on `--scope=full`
   - audit and foreman stay on `--scope=core`
   - cold archive compaction happens in dump serialization, not traversal selection

Disposable transport rule:
1. Disposable inputs are profile-scoped exact file paths only.
2. Current live set is:
   - analyst `storage/handoff/TOPIC.md`
   - architect `storage/handoff/PLAN.md`
   - audit current `storage/handoff/<DP_ID>-RESULTS.md`, `storage/handoff/CLOSING-<DP_ID>.md`, and the active packet source file at `storage/dp/processed/<DP_ID>.md` or `storage/dp/intake/<DP_ID>.md`
3. Future additions must be exact-file policy wiring plus matching smoke-test proof.

Bundle runtime invokes dump with explicit `.txt` output path and explicit `--history-profile=<resolved-profile>` to suppress dump auto-compression side effects during bundle orchestration while keeping history depth deterministic. When bundle output uses an explicit non-`auto` path, bundle derives a matching explicit dump payload path so concurrent smoke runs do not reuse the same branch/head dump artifact names. Explicit operator-facing outputs remain under `storage/handoff/`; smoke and validation runs may target quarantined paths under `storage/_smoke/handoff/` with matching dump outputs under `storage/_smoke/dumps/`.

ATS validation gate:
1. ATS flags are all-or-none. Any partial ATS argument set fails before artifact emission.
2. ATS IDs must match policy patterns from `ops/lib/manifests/ASSEMBLY.md`.
3. ATS IDs must resolve in canonical registries (`agents`, `skills`, `tasks`) before artifact emission.
4. `STELA.md` and `SCAFFOLD.md` remain advisory-only and non-gating in this phase.
5. ATS success may emit a pointer artifact and must never inline full registry payloads into bundle text or manifest fields.

## Integrity Filter Warnings
Bundle enforces output paths under `storage/handoff/` for operator-facing artifacts and under `storage/_smoke/handoff/` for quarantined smoke outputs only. Project profile rejects missing or invalid slugs. PLAN lint remains a deterministic safety floor; it validates structure, not plan quality. Policy parse errors in `ops/lib/manifests/BUNDLE.md` are fail-closed. Bundle runtime must remain deterministic and must not parse factory markdown governance files at runtime.
