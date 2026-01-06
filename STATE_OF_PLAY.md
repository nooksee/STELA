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
  - `grep -r "boot_pack_v2" docs/` → no matches ✅
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
  - grep -r "boot_pack_v2" docs/ (no matches)
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
  - grep -r "boot_pack_v2" docs/ (no matches)
  - bash tools/verify_tree.sh ✅
- Risk / rollback:
  - Risk: onboarding expectations may still conflict with older non-archive docs.
  - Rollback: revert merge commit

## 2026-01-05 — Docs: consolidate boot docs into docs/ + terminology sweep

- Purpose: Eliminate split-brain docs and standardize metadata terminology.
- What shipped:
  - Moved boot docs into `docs/` (including archives and triage archive), removing duplicates in the former boot docs location.
  - Updated indexes and references (`docs/00-INDEX.md`, `docs/CONTRACTOR_PACKET.md`, `boot/active/boot_pack/context_pack.json`).
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
- Updated docs/ops/DAILY_COCKPIT.md to clarify canon vs log vs rehydration.
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
