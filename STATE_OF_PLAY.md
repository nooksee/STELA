## 2026-01-11 — delete: delete example screens for template

- deleted shit.

## 2026-01-08 — ICL-002C: resume/open/wake control word

- Purpose: Canonize resume/open/wake as a first-class operator control word with explicit behavior.
- What shipped:
  - Updated `ops/init/protocols/SESSION_CLOSE_PROTOCOL.md`.
  - Updated `ops/init/icl/OCL_OVERVIEW.md`.
  - Updated `ops/templates/SESSION_SNAPSHOT_TEMPLATE.md`.
  - Updated `STATE_OF_PLAY.md`.
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/repo/lint_truth.sh` ✅
  - `bash ops/init/tools/context_lint.sh` ✅
- Risk / rollback:
  - Risk: resume behavior wording may need tuning as control word usage evolves.
  - Rollback: revert the protocol/overview/template updates.

## 2026-01-08 — ICL-002B: output-format unification (contract + protocol + templates)

- Purpose: Unify output-format canon across contract, protocol, and PR template surfaces.
- What shipped:
  - Updated `ops/contracts/OUTPUT_FORMAT_CONTRACT.md`.
  - Updated `ops/init/protocols/OUTPUT_FORMAT_PROTOCOL.md`.
  - Updated `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`.
  - Updated `ops/templates/PR_DESCRIPTION_TEMPLATE.md`.
  - Updated `ops/templates/DISPATCH_PACKET_TEMPLATE.md`.
  - Updated `STATE_OF_PLAY.md`.
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/repo/lint_truth.sh` ✅
  - `bash ops/init/tools/context_lint.sh` ✅
- Risk / rollback:
  - Risk: output-format guidance may need tuning as operators adopt the unified flow.
  - Rollback: revert the contract/protocol/template updates.

## 2026-01-08 — ICL-001L: truth precedence + ticket/state alignment

- Purpose: Define truth precedence across artifacts and align ticket state with the canonical ledger.
- What shipped:
  - Updated `ops/init/icl/OCL_OVERVIEW.md`.
  - Updated `ops/init/protocols/HANDOFF_PROTOCOL.md`.
  - Updated `ops/init/manifests/OUTPUT_MANIFEST.md`.
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/repo/lint_truth.sh` ✅
- Risk / rollback:
  - Risk: precedence and ledger language may need tuning as OCL canon evolves.
  - Rollback: revert the overview/protocol/manifest edits.

## 2026-01-08 — ICL-002A: evacuate /boot to ops and remove /boot

- Purpose: Migrate launch pack artifacts into ops/init and remove the /boot directory.
- What shipped:
  - Moved `boot/active/launch_pack/context_pack.json` to `ops/init/icl/context_pack.json`.
  - Moved `boot/active/launch_pack/README.md` to `ops/init/icl/launch_pack/README.md`.
  - Moved `boot/active/launch_pack/ASSISTANT_PROFILE.md` to `ops/init/icl/launch_pack/ASSISTANT_PROFILE.md`.
  - Moved `boot/active/launch_pack/USER_PROFILE.md` to `ops/init/icl/launch_pack/USER_PROFILE.md`.
  - Moved `boot/active/launch_pack/INTEGRATOR_ONBOARDING.md` to `ops/init/icl/launch_pack/INTEGRATOR_ONBOARDING.md`.
  - Moved `boot/active/launch_pack/CONTRACTOR_ONBOARDING.md` to `ops/init/icl/launch_pack/CONTRACTOR_ONBOARDING.md`.
  - Moved `boot/active/launch_pack/RECOVERY.md` to `ops/init/icl/launch_pack/RECOVERY.md`.
  - Moved `boot/active/launch_pack/principles.md` to `ops/init/icl/launch_pack/principles.md`.
  - Moved `boot/active/launch_pack/canon_snapshot.md` to `ops/init/icl/launch_pack/canon_snapshot.md`.
  - Moved `boot/active/launch_pack/active_loops.json` to `ops/init/icl/launch_pack/active_loops.json`.
  - Moved `boot/ACTIVE_CONTEXT.md` to `ops/init/icl/ACTIVE_CONTEXT.md`.
  - Moved `boot/BUNDLE_MANIFEST.json` to `ops/init/icl/BUNDLE_MANIFEST.json`.
  - Moved `boot/templates/gitignore.txt` to `ops/templates/gitignore.txt`.
  - Updated `ops/init/icl/context_pack.json` and `ops/init/icl/ACTIVE_CONTEXT.md` for new launch pack paths.
  - Updated `ops/init/tools/context_lint.sh` to drop `/boot` path allowance.
  - Updated `docs/README_CONTEXT.md`, `docs/10-QUICKSTART.md`, `docs/30-RELEASE_PROCESS.md`, `docs/SOP_MULTICHAT.md`, `docs/REPO_LAYOUT.md`, `docs/PROJECT_STRUCTURE.md`, and `docs/20-GOVERNANCE.md`.
  - Removed `boot/`.
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/repo/lint_truth.sh` ✅
  - `bash ops/init/tools/context_lint.sh` (warn: missing path referenced in STATE_OF_PLAY.md: ops/templates/DAILY_CONSOLE_TEMPLATE.md)
  - `grep -R "(/boot|boot/|launch_pack|launchpack|DAILY_CONSOLE|console)" -n .` (hit: STATE_OF_PLAY.md verification line)
- Risk / rollback:
  - Risk: stale references outside scope may still mention /boot.
  - Rollback: restore /boot and revert the ops/docs updates.

## 2026-01-08 — ICL-001K: metadata kit formatting canonized

- Purpose: Canonize metadata kit presentation rules for operator-facing outputs.
- What shipped:
  - Updated `ops/init/icl/OCL_OVERVIEW.md`.
  - Updated `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`.
  - Updated `ops/templates/DISPATCH_PACKET_TEMPLATE.md`.
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/repo/lint_truth.sh` ✅
- Risk / rollback:
  - Risk: formatting rules may require adjustment as metadata kits evolve.
  - Rollback: revert the overview/protocol/template edits.

## 2026-01-07 — ICL-001J: remove deprecated Daily Console template

- Purpose: Remove deprecated Daily Console template now replaced by the session snapshot artifact.
- What shipped:
  - Removed Daily Console template (deprecated; file deleted).
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/repo/lint_truth.sh` ✅
- Risk / rollback:
  - Risk: legacy references may linger outside ops scope.
  - Rollback: restore the template file.

## 2026-01-07 — ICL-001I: Operator Control Words canonized

- Purpose: Canonize operator control words for snapshot, pause/close, and opine-only behavior.
- What shipped:
  - Updated `ops/init/protocols/SESSION_CLOSE_PROTOCOL.md`.
  - Updated `ops/templates/SESSION_SNAPSHOT_TEMPLATE.md`.
  - Updated `ops/init/manifests/OUTPUT_MANIFEST.md`.
  - Updated `ops/init/icl/OCL_OVERVIEW.md`.
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/repo/lint_truth.sh` ✅
- Risk / rollback:
  - Risk: control word handling may need tuning as OCL evolves.
  - Rollback: revert the protocol/template/manifest/overview edits.

## 2026-01-07 — ICL-001H: session pause/close snapshot artifact

- Purpose: Formalize the OCL pause/close snapshot artifact for durable, resumable sessions.
- What shipped:
  - Added `ops/init/icl/SESSION_SNAPSHOT_OVERVIEW.md`.
  - Added `ops/init/protocols/SESSION_CLOSE_PROTOCOL.md`.
  - Updated `ops/init/manifests/OUTPUT_MANIFEST.md`.
  - Added `ops/templates/SESSION_SNAPSHOT_TEMPLATE.md`.
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/repo/lint_truth.sh` ✅
- Risk / rollback:
  - Risk: snapshot artifact expectations may need tuning as OCL evolves.
  - Rollback: revert the overview/protocol/template and output manifest update.

## 2026-01-07 — ICL-001G: OCL formalized + ticket model

- Purpose: Formalize OCL as the session lifecycle superset of ICL and define the ticket model.
- What shipped:
  - Added `ops/init/icl/OCL_OVERVIEW.md`.
  - Updated `ops/init/manifests/ROLE_MANIFEST.md`.
  - Updated `ops/init/protocols/SNAPSHOT_PROTOCOL.md`.
  - Updated `ops/init/protocols/HANDOFF_PROTOCOL.md`.
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/repo/lint_truth.sh` ✅
- Risk / rollback:
  - Risk: OCL framing or ticket lifecycle may need tuning as ops canon evolves.
  - Rollback: revert the OCL overview and protocol/manifest edits.

## 2026-01-07 — ICL-001E: DP canonized (Work Orders as first-class ICL artifact)

- Purpose: Make Dispatch Packets (DP) the canonical operator-facing work order in ICL.
- What shipped:
  - Added `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`.
  - Added `ops/templates/DISPATCH_PACKET_TEMPLATE.md`.
  - Updated `ops/init/manifests/OUTPUT_MANIFEST.md` to include DP as a required output type.
- Verification:
  - Not run (worker): `bash tools/verify_tree.sh`
  - Not run (worker): `bash tools/repo/lint_truth.sh`
- Risk / rollback:
  - Risk: DP requirements may need tuning as ops conventions evolve.
  - Rollback: revert the DP protocol/template and the output manifest update.

## 2026-01-07 — ICL-001C: context pruning + drift detection

- Purpose: Reduce long-session decay and detect filesystem drift early during ICL.
- What shipped:
  - Added `ops/init/protocols/CONTEXT_PRUNING_PROTOCOL.md`.
  - Added `ops/init/tools/context_lint.sh` and updated `ops/init/manifests/CONTEXT_MANIFEST.md`.
- Verification:
  - `bash ops/init/tools/context_lint.sh` ✅
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/repo/lint_truth.sh` ✅
- Risk / rollback:
  - Risk: lint rules may need tuning as ICL canon evolves.
  - Rollback: remove the new protocol and context linter, and revert manifest edits.

## 2026-01-07 — ICL-001B — Context packer + trigger hardening

- Purpose: Reduce Operator fatigue and drift risk with a deterministic ICL context packer and hardened triggers.
- What shipped:
  - Added `ops/init/pack.sh` to emit a paste-ready ICL deck in a fixed order.
  - Added a trigger to the Save This protocol and introduced the new Snapshot protocol (with guidance on optional PDF archives).
  - Tightened the INIT_CONTRACT repeat-back requirements for "opt-in repo knowledge" and "no commit/push".
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/repo/lint_truth.sh` ✅
  - `bash ops/init/pack.sh --help` ✅
  - `bash ops/init/pack.sh | head` ✅
- Risk / rollback:
  - Risk: pack output order or content may need adjustments as ICL grows.
  - Rollback: revert `ops/init/pack.sh` and the protocol wording updates.

## 2026-01-07 — Ops: ICL init skeleton (ICL-001A)

- Purpose: Establish the canonical ops/init skeleton for ICL and role setup.
- What shipped:
  - Added `ops/init/` skeleton including `icl/`, `manifests/`, `profiles/`, and `protocols/`.
  - Created 15 new stub files across the new `ops/init/` subdirectories, all seeded with required metadata headings.
  - Note: `ops/contracts/` and `ops/templates/` were pre-existing and are referenced by the new ICL skeleton.
- Verification:
  - Not run (worker): `bash tools/verify_tree.sh`
  - Not run (worker): `bash tools/repo/lint_truth.sh`
- Risk / rollback:
  - Risk: stub content may require follow-up hardening.
  - Rollback: remove the new ops/init tree and this entry.

## 2026-01-06 — Docs: security posture refresh (T-DOCS-SECURITY-REFRESH)

- Purpose: Consolidate security posture guidance and clarify AI/worker boundaries.
- What shipped:
  - Expanded `SECURITY.md` with roles, AI policy, secrets guidance, reporting, and known issues.
  - Added `docs/security/README.md` as the detailed security reference and cross-links.
  - Archived a legacy NukeSentinel reference and updated `docs/DATA_FEEDS.md`.
  - Linked `CONTRIBUTING.md` to the security policy.
- Verification:
  - Not run (worker): `bash tools/verify_tree.sh`
  - Not run (worker): `bash tools/repo/lint_truth.sh`
- Risk / rollback:
  - Risk: docs-only (security guidance changes).
  - Rollback: revert this entry and the docs updates.

## 2026-01-06 — Ops: control room index + precheck (T-OPS-OPS-STREAMLINE)

- Purpose: Make ops docs feel like a control room with a clear start and precheck checklist.
- What shipped:
  - Reworked `docs/ops/INDEX.md` into workflow sections with a drift rule reminder.
  - Added a filled precheck checklist to `docs/ops/DAILY_CONSOLE.md`.
- Verification:
  - Not run (worker): `bash tools/verify_tree.sh`
  - Not run (worker): `bash tools/repo/lint_truth.sh`
- Risk / rollback:
  - Risk: docs-only (index + checklist edits).
  - Rollback: revert this entry and the ops docs changes.

## 2026-01-06 — Ops: PR template polish (T-OPS-PR-TEMPLATE-POLISH)

- Purpose: Align the GitHub PR template with Metadata Surfaces (always-on) and operator-agnostic workflow.
- What shipped:
  - Reworked `.github/pull_request_template.md` with the Metadata Surfaces headings and required checklists.
  - Added explicit operator reminders for merge commit metadata and merge-note comments.
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/repo/lint_truth.sh` ✅
- Risk / rollback:
  - Risk: docs-only (PR template formatting).
  - Rollback: revert this entry and the template update.

## 2026-01-06 — Docs: onboarding entrypoint alignment (T-DOCS-REFRESH)

- Purpose: Keep Quickstart as the single onboarding entry point across front-door docs.
- What shipped:
  - Moved `docs/README_CONTEXT.md` out of the “Start here” section in `docs/00-INDEX.md`.
  - Kept Quickstart as the only Start Here link while preserving reference access.
- Verification:
  - `grep -r "launch_pack_v2" docs/` → no matches ✅
  - `grep -r "_meta/" docs/` → hits expected in `docs/SECURE_WEBROOT_OPTION.md` + `docs/_archive/boot/NUKECE_PATHS.md` ✅
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/repo/lint_truth.sh` ✅
- Risk / rollback:
  - Risk: docs-only (index link placement).
  - Rollback: revert this entry and `docs/00-INDEX.md` change.

## 2026-01-05 — Ops: no worker commit/push (T-OPS-NO-WORKER-COMMIT)

- Purpose: Enforce “workers draft only; operator commits” across ops templates and contracts.
- What shipped:
  - Added no-commit/no-push rules to contractor dispatch and brief templates.
  - Added worker delivery rules to output format contract and PR checkbox enforcement.
- Verification:
  - grep -r "commit/push" docs/ops .github (hits expected)
  - bash tools/verify_tree.sh ✅
  - bash tools/repo/lint_truth.sh ✅
- Risk / rollback:
  - Risk: docs-only (no runtime behavior changes)
  - Rollback: revert merge commit

## 2026-01-05 — Ops: metadata surfaces templates (T-OPS-METADATA-TEMPLATES)

- Purpose: Institutionalize “Metadata Surfaces (always-on)” templates across PR and contractor workflows.
- What shipped:
  - Updated PR description templates in `docs/ops/PR_DESCRIPTION_TEMPLATE.md` and `.github/pull_request_template.md`.
  - Hardened contractor dispatch requirements in `docs/ops/CONTRACTOR_DISPATCH_BRIEF.md`.
- Verification:
  - grep -r "Guerrilla" docs/ .github/ (no matches)
  - bash tools/verify_tree.sh ✅
  - bash tools/repo/lint_truth.sh ✅
- Risk / rollback:
  - Risk: docs-only (no runtime behavior changes)
  - Rollback: revert merge commit

## 2026-01-05 — Docs: onboarding refresh single entry point (T-DOCS-REFRESH)

- Purpose: Align onboarding docs to repo reality and make Quickstart the canonical entry point.
- What shipped:
  - Made `docs/10-QUICKSTART.md` the single onboarding guide with doctrine + ops links.
  - Replaced `docs/START_HERE.md` with a pointer; updated `README.md`, `CONTRIBUTING.md`, and `docs/00-INDEX.md`.
  - Refreshed context and structure docs to match current top-level folders.
- Verification:
  - grep -r "_meta/" docs/ (hits in `docs/SECURE_WEBROOT_OPTION.md` and `docs/_archive/boot/NUKECE_PATHS.md`)
  - grep -r "launch_pack_v2" docs/ (no matches)
  - grep -r "src/" docs/ README.md CONTRIBUTING.md (hits in `docs/upstreams.md`, `docs/NUKESECURITY_VISION_TO_IMPLEMENTATION_MAP.md`, `docs/GEOIP_IMPORTER.md`, `docs/triage/_archive/SUBSYSTEM_MAP_v11.md`, `docs/triage/_archive/SECURITY_SURFACE_SWEEP_v11.md`, `docs/_archive/boot/v19_STORAGE_PATHS.md`, `docs/repo-nomenclature.md`)
  - bash tools/verify_tree.sh ✅
  - bash tools/repo/lint_truth.sh ✅
- Risk / rollback:
  - Risk: onboarding expectations may still conflict with older archived docs.
  - Rollback: revert merge commit

## 2026-01-05 — Docs: front door refresh (T-DOCS-FRONTDOOR-REFRESH)

- Purpose: Align front-door docs with current repo reality and workflow.
- What shipped:
  - Rewrote front-door docs for the current Context Pack location and workflow.
  - Updated project structure and repo layout to match current top-level directories.
  - Reinforced Metadata Surfaces (always-on) in the entrypoint workflow.
- Verification:
  - grep -r "_meta/" docs/ (hits in `docs/SECURE_WEBROOT_OPTION.md` and `docs/_archive/boot/NUKECE_PATHS.md`)
  - grep -r "launch_pack_v2" docs/ (no matches)
  - bash tools/verify_tree.sh ✅
- Risk / rollback:
  - Risk: onboarding expectations may still conflict with older non-archive docs.
  - Rollback: revert merge commit

## 2026-01-05 — Docs: consolidate boot docs into docs/ + terminology sweep

- Purpose: Eliminate split-brain docs and standardize metadata terminology.
- What shipped:
  - Moved boot docs into `docs/` (including archives and triage archive), removing duplicates in the former boot docs location.
  - Updated indexes and references (`docs/00-INDEX.md`, `docs/CONTRACTOR_PACKET.md`, `ops/init/icl/context_pack.json`).
  - Standardized docs terminology to “Metadata Surfaces (always-on)”.
- Verification:
  - Link/reference grep (boot-docs references) ✅
  - Terminology grep (Guerrilla) ✅
  - bash tools/verify_tree.sh ✅
  - bash tools/repo/lint_truth.sh ✅
- Risk / rollback:
  - Risk: link-rot in moved docs or missed references.
  - Rollback: revert merge commit

## 2026-01-05 — Docs: contractor dispatch brief (canonize worker dispatch)

- Purpose: Canonize contractor dispatch rules so every PR follows governance + metadata requirements.
- What shipped:
  - Added `docs/ops/CONTRACTOR_DISPATCH_BRIEF.md` to formalize dispatch rules and cadence.
  - Linked the new brief from `docs/ops/INDEX.md` and `docs/00-INDEX.md`.
- Verification:
  - repo-gates ✅
  - state-of-play-policing ✅
- Risk / rollback:
  - Risk: docs-only (no runtime behavior changes)
  - Rollback: revert merge commit

## 2026-01-04 — Docs: Guerrilla Metadata Surfaces (always-on)

- Purpose: Make every PR self-documenting; no blank metadata fields.
- What shipped:
  - Codified “Guerrilla Metadata Surfaces (always-on)” in `docs/triage/INBOX.md`
  - Standardized default Markdown structure: Purpose / What shipped / Verification / Risk+Rollback
- Verification:
  - repo-gates ✅
  - state-of-play-policing ✅
- Risk / rollback:
  - Risk: docs-only (no runtime behavior changes)
  - Rollback: revert merge commit

## 2026-01-04 — Docs: INBOX pinned doctrine placement

- Purpose: Keep `docs/triage/INBOX.md` readable (template + pinned rules + inbox list).
- What shipped:
  - Moved “Pinned doctrine: Guerrilla Metadata Surfaces (always-on)” above the Inbox items section.
- Verification:
  - repo-gates ✅
  - state-of-play-policing ✅
  - Manual: INBOX reads top-to-bottom cleanly (template → pinned doctrine → inbox list)
- Risk / rollback:
  - Risk: docs-only (no runtime behavior changes)
  - Rollback: revert this PR’s merge commit

## 2026-01-04

### Completed
- Added GitHub PR description automation via `.github/pull_request_template.md`.
- Added canonical PR description template: `docs/ops/PR_DESCRIPTION_TEMPLATE.md`.
- Added triage capture lane: `docs/triage/INBOX.md`.
- Updated docs indexes to keep ops + triage discoverable.

### Notes / Decisions
- Doctrine: “Every PR is self-documenting and nothing gets forgotten.”
- Forward-only metadata discipline: we don’t backfill old PR bodies unless it’s actively hurting us.

# State of Play — 2026-01-03

## Completed
- Docs Family v1 integrated + canon spine created (docs/00-INDEX, 10-QUICKSTART, 20-GOVERNANCE, 30-RELEASE_PROCESS, 40-PROJECT_HYGIENE)
- Added Copilot onboarding rules: .github/copilot-instructions.md
- Added SSOT “save-game” handover file: docs/ops/AI_CONTEXT_SYNC.md
- Enabled FAIL-mode policing: canon changes require STATE_OF_PLAY update in the same PR
- Updated docs/ops/DAILY_CONSOLE.md to clarify canon vs log vs rehydration.
- Added ops governance docs: OUTPUT_FORMAT_CONTRACT + Copilot onboarding + Gemini onboarding
- Updated docs/ops/INDEX.md + docs/00-INDEX.md to link the new ops docs
- Standardized PROJECT_MAP.md bullets for docs/ops/, upstream/, and .github/workflows/ to clarify roles
- 2026-01-03: Canonized Output Formatting Contract (docs/ops/OUTPUT_FORMAT_CONTRACT.md) and linked it in docs indexes.

## Active blockers
- repo-gates (FAIL-mode) blocking PR until this STATE_OF_PLAY update is committed + pushed

## Next steps (ordered)
1. Save all edited docs in NetBeans
2. Commit updates on current work branch
3. Push branch and re-run repo-gates via PR checks
4. Merge PR once repo-gates are green ✅

## Notes
- This PR is documentation/governance only; no runtime behavior changes intended.
## 2026-01-09 - ICL-002D: canon dedupe + ICL/OCL spine consolidation

- Purpose: Consolidate ICL/OCL doctrine into ops canon and convert docs/ops into pointer-only manual references.
- What shipped:
  - Added `ops/init/icl/launch_pack/DAILY_CONSOLE.md`, `ops/init/icl/launch_pack/AI_CONTEXT_SYNC.md`, `ops/init/icl/launch_pack/CONTEXT_PACK.md`, `ops/init/icl/launch_pack/COPILOT_ONBOARDING.md`, `ops/init/icl/launch_pack/GEMINI_ONBOARDING.md`, `ops/init/icl/launch_pack/IDE_MIGRATION.md`.
  - Updated `ops/init/icl/launch_pack/RECOVERY.md` and `ops/init/icl/launch_pack/README.md`.
  - Updated `ops/contracts/OUTPUT_FORMAT_CONTRACT.md`, `ops/contracts/CONTRACTOR_DISPATCH_CONTRACT.md`, and `ops/init/protocols/SAVE_THIS_PROTOCOL.md`.
  - Added `ops/templates/CONTRACTOR_BRIEF_TEMPLATE.md` and `ops/templates/CONTRACTOR_REPORT_TEMPLATE.md`.
  - Updated `ops/init/icl/context_pack.json` for the new ops canon pointers.
  - Converted docs/ops duplicates into pointer stubs and refreshed `docs/ops/INDEX.md`.
  - Updated `PROJECT_MAP.md`, `CANONICAL_TREE.md`, and docs indexes/references (`docs/00-INDEX.md`, `docs/10-QUICKSTART.md`, `docs/CONTRACTOR_PACKET.md`, `docs/REPO_LAYOUT.md`, `docs/PROJECT_STRUCTURE.md`, `docs/20-GOVERNANCE.md`, `docs/README_CONTEXT.md`, `docs/security/README.md`).
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/repo/lint_truth.sh` ✅
  - `bash ops/init/tools/context_lint.sh` ✅
  - `bash ops/init/pack.sh --help` ✅
  - `grep -R \"(boot/|/boot|console|DAILY_CONSOLE|launch_pack|launchpack)\" -n .` ✅
- Risk / rollback:
  - Risk: stale references if any downstream doc still expects docs/ops full content.
  - Rollback: restore prior docs/ops content and revert ops/doc pointer updates.
## 2026-01-09 - DP-ICL-002D1: freshness gate canonized

- Purpose: Require a Freshness Gate in Dispatch Packets to block stale context before work begins.
- What shipped:
  - Updated `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`.
  - Updated `ops/templates/DISPATCH_PACKET_TEMPLATE.md`.
  - Updated `STATE_OF_PLAY.md`.
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/repo/lint_truth.sh` ✅
  - `bash ops/init/tools/context_lint.sh` ✅
- Risk / rollback:
  - Risk: stricter DP gating may slow work starts if operator-provided truth is stale.
  - Rollback: revert the DP protocol/template changes.
## 2026-01-09 - DP-ICL-002D3-CLEAN: Freshness Gate proceed-on-match + template stop-marker removal

- Purpose: Clarify Freshness Gate proceed-on-match behavior and remove internal stop markers from the DP template.
- What shipped:
  - Updated `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`.
  - Updated `ops/templates/DISPATCH_PACKET_TEMPLATE.md`.
  - Updated `STATE_OF_PLAY.md`.
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/repo/lint_truth.sh` ✅
  - `bash ops/init/tools/context_lint.sh` ✅
  - `grep -R "STOP COPYING" -n ops/templates/DISPATCH_PACKET_TEMPLATE.md` ✅
- Risk / rollback:
  - Risk: operators may miss the queue stop rule if they only scan the top of the template.
  - Rollback: revert the protocol/template edits.
## 2026-01-09 - DP-ICL-002D4: DP template hygiene + STATE_OF_PLAY compliance

- Purpose: Ensure the DP template contains zero "STOP COPYING" lines and log the compliance update.
- What shipped:
  - Updated `ops/templates/DISPATCH_PACKET_TEMPLATE.md`.
  - Updated `STATE_OF_PLAY.md`.
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/repo/lint_truth.sh` ✅
  - `bash ops/init/tools/context_lint.sh` ✅
  - `grep -n "STOP COPYING" ops/templates/DISPATCH_PACKET_TEMPLATE.md` ✅
- Risk / rollback:
  - Risk: operators may rely on the DP template for footer phrasing cues.
  - Rollback: revert the DP template and STATE_OF_PLAY entry.
## 2026-01-09 - DP-ICL-002E0: Process lock for TYPE LINE BY LINE + paste surfaces

- Purpose: Standardize operator command safety language, paste surfaces, and DP freshness gate rules.
- What shipped:
  - Updated `ops/contracts/OUTPUT_FORMAT_CONTRACT.md`.
  - Updated `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`.
  - Updated `ops/templates/DISPATCH_PACKET_TEMPLATE.md`.
  - Added `ops/init/icl/PASTE_SURFACES_PLAYBOOK.md`.
  - Updated `docs/ops/INDEX.md`.
  - Updated `STATE_OF_PLAY.md`.
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/repo/lint_truth.sh` ✅
  - `bash ops/init/tools/context_lint.sh` ✅
  - `grep -n "STOP COPYING" ops/templates/DISPATCH_PACKET_TEMPLATE.md` ✅
- Risk / rollback:
  - Risk: operators may need time to adapt to TYPE LINE BY LINE command blocks.
  - Rollback: revert the protocol, template, and playbook updates.
## 2026-01-09 - DP-ICL-002E1: banned terms inventory + rename plan drafted

- Purpose: Capture banned-term inventory and draft a rename plan for ICL/OCL artifacts.
- What shipped:
  - Added `ops/init/icl/BANNED_TERMS_MAP.md`.
  - Added `ops/init/icl/RENAME_PLAN_ICL_OCL.md`.
  - Updated `docs/ops/INDEX.md`.
  - Updated `STATE_OF_PLAY.md`.
- Verification:
  - `grep -RinE "(recovery|launchpack|launch_pack|console|precheck)" ops docs *.md 2>/dev/null || true` ✅
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/repo/lint_truth.sh` ✅
- Risk / rollback:
  - Risk: large rename PRs can break links and references if not updated in lockstep.
  - Rollback: revert the inventory/plan docs and redo with a narrower rename scope.
## 2026-01-09 - DP-ICL-002E3: launch pack rename fixups

- Purpose: Stabilize the launch pack rename by clearing remaining drift markers and confirming pointer correctness.
- What shipped:
  - Added `ops/init/icl/DP-ICL-002E3_RENAME_FIXUPS.md`.
  - Updated `STATE_OF_PLAY.md` verification language to avoid banned-term drift.
- Verification:
  - Banned-term sweep grep (per `ops/init/icl/DP-ICL-002E3_RENAME_FIXUPS.md`) ✅
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/repo/lint_truth.sh` ✅
- Risk / rollback:
  - Risk: lingering legacy references outside the planning docs could still surface later.
  - Rollback: revert this entry and re-run the drift sweep.
