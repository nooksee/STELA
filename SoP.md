Archive policy: keep most recent 30 entries; older entries moved to `storage/archives/root/SoP-archive-2026-01-27.md`.

## 2026-01-29 — DP-OPS-FIX-01: TASK heading sync + authoring-time artifacts removal

- Purpose: Align TASK Section III heading format and remove the authoring-time artifacts block to reduce dp_lint friction.
- What shipped:
  - Confirmed Section III heading is a single line (`## III. EXECUTION PLAN (A–E CANON)`).
  - Removed the authoring-time artifacts block from Section I required context.
  - Added a scope lock: when canon/governance surfaces change, `SoP.md` must be in the allowlist and updated.
  - Required a RESULTS Status block with Scope summary, Tracked change, and Verification bullets.
  - Added DP-OPS-FIX-01 receipt and refreshed OPEN and dump artifacts.
- Verification:
  - `grep -n "## III. EXECUTION PLAN" TASK.md`
  - `git status --porcelain`
  - `git diff --name-only`
  - `git diff --stat`
  - `git diff`
- Risk / rollback:
  - Risk: Low (TASK-only adjustment plus receipt artifacts).
  - Rollback: revert `TASK.md`, `storage/handoff/DP-OPS-FIX-01-RESULTS.md`, and updated OPEN and dump artifacts.

## 2026-01-27 — DP-OPS-0004: SoP prune + archives museum + context lint alignment

- Purpose: Prune SoP to a recent window, preserve history in an untracked museum, and align lint behavior for historical references.
- What shipped:
  - Moved older SoP entries into `storage/archives/root/SoP-archive-2026-01-27.md` (untracked museum).
  - Trimmed SoP to the most recent 30 entries and added an archive policy pointer.
  - Updated `tools/context_lint.sh` to skip SoP historical path enforcement.
- Verification:
  - `bash tools/context_lint.sh`
  - Result: `[context_lint] Result: clean`
- Risk / rollback:
  - Risk: Low (log + lint alignment only).
  - Rollback: restore SoP from archive and revert lint edits.

## 2026-01-27 — DP-OPS-0005: TASK hardening (worker git authority + dump-as-command + real Work Log + task gate + DP lint sync)

- Purpose: Harden TASK + gates for worker git authority, dump-as-command, and real Work Log discipline.
- What shipped:
  - Updated `TASK.md` DP template (freshness gate wording, worker git authority block, dump-as-command phrasing, Work Log expectation + example).
  - Synced `tools/dp_lint.sh` to TASK headings and broadened lint field parsing for DP suffixes/parenthetical labels and in-scope format.
  - Added TASK policing in `.github` (`sop_policing.yml` update + new `task_policing.yml`).
- Verification:
  - `bash tools/dp_lint.sh storage/handoff/DP-OPS-0005_v2.md`
  - Result: `OK: DP lint passed`
  - `bash tools/context_lint.sh`
  - Result: `[context_lint] Result: warnings detected` (missing paths referenced in `SoP.md`).
- Risk / rollback:
  - Risk: Low (process/gate updates only).
  - Rollback: revert `TASK.md`, `tools/dp_lint.sh`, `.github/workflows/sop_policing.yml`, `.github/workflows/task_policing.yml`, and `SoP.md`.

## 2026-01-27 — DP-OPS-0003: Canon truth consolidation from legacy mementos (v3)

- Purpose: Consolidate high-value truth into canon surfaces and remove scatter/duplication.
- What shipped:
  - Reshaped `TRUTH.md` into filing doctrine + constitution/invariants.
  - Tightened `TASK.md` closeout outputs (diff name-only/stat + NEXT).
  - Updated `docs/library/MANUAL.md`, `docs/QUICKSTART.md`, `docs/GOVERNANCE.md`, and `docs/INDEX.md` to use pointer-based canon references.
- Results: `storage/handoff/DP-OPS-0003-RESULTS.md`
- Verification:
  - `bash tools/verify_tree.sh`
  - Result: `4 issue(s)` (missing expected directories: `modules/`, `admin/`, `includes/`, `themes/`).
  - `bash tools/context_lint.sh`
  - Result: `[context_lint] Result: warnings detected` (missing paths referenced in `SoP.md`).
  - `bash tools/lint_truth.sh`
  - Result: `[lint_truth] OK`
- Risk / rollback:
  - Risk: Low (canon/doc reshaping only).
  - Rollback: revert `TRUTH.md`, `TASK.md`, `docs/library/MANUAL.md`, `docs/QUICKSTART.md`, `docs/GOVERNANCE.md`, `docs/INDEX.md`, and `SoP.md`.

## 2026-01-22 — DP-OPS-0050A: Integrator Phase Discipline (Conformance-First + Phase-Locked Outputs)

- Purpose: Lock conformance-first DP refreshes, phase-locked outputs, receipt bundle always, and allow OPEN/dump to be operator-provided or locally generated per run.
- What shipped:
  - Added Integrator Phase Discipline rules (conformance-first, phase-locked outputs, receipt bundle always) to `TRUTH.md`.
  - Added Integrator Phase Discipline operator phrases, hard stops, and decision table to `docs/library/MANUAL.md`.
  - Updated M-PHASE-01 to "Conformance First, Creativity After" with triggers in `docs/library/MEMENTOS.md`.
- Verification:
  - `bash tools/context_lint.sh`
  - Result: `[context_lint] Result: clean`
  - `bash tools/lint_truth.sh`
  - Result: `[lint_truth] OK`
- Risk / rollback:
  - Risk: Low (docs-only guidance updates).
  - Rollback: revert `TRUTH.md`, `docs/library/MANUAL.md`, `docs/library/MEMENTOS.md`, and `SoP.md`.

## 2026-01-21 — DP-OPS-0050: Stelae Governance (Keep It Useful, Keep It Rare)

- Summary: Added Stelae governance + entry format rules, added operator Stelae usage guidance, and logged the DP.
- Verification:
  - `./tools/context_lint.sh`
  - Result: `/bin/bash: line 1: ./tools/context_lint.sh: No such file or directory`
  - `./ops/bin/lint_truth.sh`
  - Result: `/bin/bash: line 1: ./ops/bin/lint_truth.sh: No such file or directory`
- Risk / rollback:
  - Risk: Low (docs-only governance + guidance updates).
  - Rollback: revert `docs/library/[REMOVED].md`, `MANUAL.md`, and `SoP.md`.

## 2026-01-21 — DP-OPS-0049: Stela Name Guardrails (Canonical Spelling + Lint)

- Purpose: Canonize Stela/Stelae spelling, declare SSOT, and add a lint guardrail for typos.
- What shipped:
  - Updated naming canon in `TRUTH.md`, operator guidance in `docs/library/MANUAL.md`, and spelling policy in `docs/library/[REMOVED].md`.
  - Added forbidden spelling checks to `tools/lint_truth.sh`.
- Verification:
  - `bash tools/context_lint.sh`
  - Result: `[context_lint] Result: clean`
  - `bash tools/lint_truth.sh`
  - Result: `[lint_truth] OK`
  - `rg -n "Stela|Stelae" TRUTH.md docs/library/[REMOVED].md docs/library/MANUAL.md`
  - Result:
    - `TRUTH.md:9:- Stela (S-T-E-L-A): only canonical project / platform name spelling (stone tablet metaphor: published canon / governance visible to all).`
    - `TRUTH.md:10:- Stelae (S-T-E-L-A-E): plural / collection label.`
    - `docs/library/[REMOVED].md:1:# Stelae`
    - `docs/library/[REMOVED].md:3:Stelae are short operator-facing reminders to keep conversations precise and calm.`
    - `docs/library/[REMOVED].md:8:- "Stela" is the singular project / platform name.`
    - `docs/library/[REMOVED].md:9:- "Stelae" is the plural / collection label.`
    - `docs/library/[REMOVED].md:11:- Correct: "Stela is the platform name."`
    - `docs/library/[REMOVED].md:12:- Correct: "These Stelae keep operator guidance consistent."`
    - `docs/library/MANUAL.md:5:You may see legacy \`Stela\` strings; \`Stela\` is the platform name going forward.`
    - `docs/library/MANUAL.md:116:- \`./ops/bin/project\` lists/initializes Stela-born projects (no import/migration).`
    - `docs/library/MANUAL.md:180:- Canon spelling: Stela (singular) / Stelae (plural). Normalize voice-to-text variants before committing or approving.`
  - `rg -n "Steela|Stila|Stella" . || true`
  - Result:
    - `./projects/default/upstream/php-nuke/includes/vendor/mobiledetect/mobiledetectlib/MobileDetect.json:160:            "iJoyTablet": "Tablet (Spirit 7|Essentia|Galatea|Fusion|Onix 7|Landa|Titan|Scooby|Deox|Stella|Themis|Argon|Unique 7|Sygnus|Hexen|Finity 7|Cream|Cream X2|Jade|Neon 7|Neron 7|Kandy|Scape|Saphyr 7|Rebel|Biox|Rebel|Rebel 8GB|Myst|Draco 7|Myst|Tab7-004|Myst|Tadeo Jones|Tablet Boing|Arrow|Draco Dual Cam|Aurix|Mint|Amity|Revolution|Finity 9|Neon 9|T9w|Amity 4GB Dual Cam|Stone 4GB|Stone 8GB|Andromeda|Silken|X2|Andromeda II|Halley|Flame|Saphyr 9,7|Touch 8|Planet|Triton|Unique 10|Hexen 10|Memphis 4GB|Memphis 8GB|Onix 10)"`
    - `./projects/default/upstream/php-nuke/includes/vendor/mobiledetect/mobiledetectlib/src/MobileDetect.php:577:        'iJoyTablet' => 'Tablet (Spirit 7|Essentia|Galatea|Fusion|Onix 7|Landa|Titan|Scooby|Deox|Stella|Themis|Argon|Unique 7|Sygnus|Hexen|Finity 7|Cream|Cream X2|Jade|Neon 7|Neron 7|Kandy|Scape|Saphyr 7|Rebel|Biox|Rebel|Rebel 8GB|Myst|Draco 7|Myst|Tab7-004|Myst|Tadeo Jones|Tablet Boing|Arrow|Draco Dual Cam|Aurix|Mint|Amity|Revolution|Finity 9|Neon 9|T9w|Amity 4GB Dual Cam|Stone 4GB|Stone 8GB|Andromeda|Silken|X2|Andromeda II|Halley|Flame|Saphyr 9,7|Touch 8|Planet|Triton|Unique 10|Hexen 10|Memphis 4GB|Memphis 8GB|Onix 10)'`
    - `./projects/default/public_html/includes/vendor/mobiledetect/mobiledetectlib/MobileDetect.json:160:            "iJoyTablet": "Tablet (Spirit 7|Essentia|Galatea|Fusion|Onix 7|Landa|Titan|Scooby|Deox|Stella|Themis|Argon|Unique 7|Sygnus|Hexen|Finity 7|Cream|Cream X2|Jade|Neon 7|Neron 7|Kandy|Scape|Saphyr 7|Rebel|Biox|Rebel|Rebel 8GB|Myst|Draco 7|Myst|Tab7-004|Myst|Tadeo Jones|Tablet Boing|Arrow|Draco Dual Cam|Aurix|Mint|Amity|Revolution|Finity 9|Neon 9|T9w|Amity 4GB Dual Cam|Stone 4GB|Stone 8GB|Andromeda|Silken|X2|Andromeda II|Halley|Flame|Saphyr 9,7|Touch 8|Planet|Triton|Unique 10|Hexen 10|Memphis 4GB|Memphis 8GB|Onix 10)"`
    - `./projects/default/public_html/includes/vendor/mobiledetect/mobiledetectlib/src/MobileDetect.php:577:        'iJoyTablet' => 'Tablet (Spirit 7|Essentia|Galatea|Fusion|Onix 7|Landa|Titan|Scooby|Deox|Stella|Themis|Argon|Unique 7|Sygnus|Hexen|Finity 7|Cream|Cream X2|Jade|Neon 7|Neron 7|Kandy|Scape|Saphyr 7|Rebel|Biox|Rebel|Rebel 8GB|Myst|Draco 7|Myst|Tab7-004|Myst|Tadeo Jones|Tablet Boing|Arrow|Draco Dual Cam|Aurix|Mint|Amity|Revolution|Finity 9|Neon 9|T9w|Amity 4GB Dual Cam|Stone 4GB|Stone 8GB|Andromeda|Silken|X2|Andromeda II|Halley|Flame|Saphyr 9,7|Touch 8|Planet|Triton|Unique 10|Hexen 10|Memphis 4GB|Memphis 8GB|Onix 10)'`
    - `./TRUTH.md:11:- Policy: treat "Steela", "Stella", and "Stila" as typos; correct on sight.`
    - `./tools/lint_truth.sh:14:  Steela`
    - `./tools/lint_truth.sh:15:  Stila`
    - `./tools/lint_truth.sh:16:  Stella`
    - `./projects/default/upstream/titanium/includes/vendor/mobiledetect/mobiledetectlib/MobileDetect.json:160:            "iJoyTablet": "Tablet (Spirit 7|Essentia|Galatea|Fusion|Onix 7|Landa|Titan|Scooby|Deox|Stella|Themis|Argon|Unique 7|Sygnus|Hexen|Finity 7|Cream|Cream X2|Jade|Neon 7|Neron 7|Kandy|Scape|Saphyr 7|Rebel|Biox|Rebel|Rebel 8GB|Myst|Draco 7|Myst|Tab7-004|Myst|Tadeo Jones|Tablet Boing|Arrow|Draco Dual Cam|Aurix|Mint|Amity|Revolution|Finity 9|Neon 9|T9w|Amity 4GB Dual Cam|Stone 4GB|Stone 8GB|Andromeda|Silken|X2|Andromeda II|Halley|Flame|Saphyr 9,7|Touch 8|Planet|Triton|Unique 10|Hexen 10|Memphis 4GB|Memphis 8GB|Onix 10)"`
    - `./projects/default/upstream/titanium/includes/vendor/mobiledetect/mobiledetectlib/src/MobileDetect.php:577:        'iJoyTablet' => 'Tablet (Spirit 7|Essentia|Galatea|Fusion|Onix 7|Landa|Titan|Scooby|Deox|Stella|Themis|Argon|Unique 7|Sygnus|Hexen|Finity 7|Cream|Cream X2|Jade|Neon 7|Neron 7|Kandy|Scape|Saphyr 7|Rebel|Biox|Rebel|Rebel 8GB|Myst|Draco 7|Myst|Tab7-004|Myst|Tadeo Jones|Tablet Boing|Arrow|Draco Dual Cam|Aurix|Mint|Amity|Revolution|Finity 9|Neon 9|T9w|Amity 4GB Dual Cam|Stone 4GB|Stone 8GB|Andromeda|Silken|X2|Andromeda II|Halley|Flame|Saphyr 9,7|Touch 8|Planet|Triton|Unique 10|Hexen 10|Memphis 4GB|Memphis 8GB|Onix 10)'`
- Risk / rollback:
  - Risk: Low (docs-only naming updates + lint tightening).
  - Rollback: revert `TRUTH.md`, `docs/library/MANUAL.md`, `docs/library/[REMOVED].md`, `tools/lint_truth.sh`, and `SoP.md`.


- Purpose: Phase lock outputs to operator step and provide deterministic recovery commands.
- What changed:
  - Added Phase-Locked Output Protocol guidance and Phase Lock contract rules.
  - Added M-PHASE-01, logged the DP, and produced receipt bundle artifacts under `storage/handoff/`.
- Verification:
  - `./tools/context_lint.sh`
  - Result: `/bin/bash: line 1: ./tools/context_lint.sh: No such file or directory`
  - `./ops/bin/lint_truth.sh`
  - Result: `/bin/bash: line 1: ./ops/bin/lint_truth.sh: No such file or directory`
- Risk / rollback:
  - Risk: Medium-low (workflow wording could be misread; primary risk is operator confusion if phrasing drifts).
  - Rollback: revert `docs/library/MANUAL.md`, `ops/contracts/OUTPUT_FORMAT_CONTRACT.md`, `docs/library/MEMENTOS.md`, and `SoP.md`.

## 2026-01-21 — DP-OPS-0048D: Dispatch Packet template heading linter

- What changed:
  - Added `tools/dp_lint.sh` to enforce canonical DP A-E headings.
  - Required the linter in `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md` verification.
  - Listed the linter in `ops/bin/help`.
- Verification:
  - `./tools/dp_lint.sh`
  - Result: `FAIL: expected heading '### A) STATE' but found '### A) SUMMARY + SCOPE CONFIRMATION'`
  - `./tools/context_lint.sh`
  - Result: `[context_lint] Result: clean`
  - `./ops/init/tools/lint_truth.sh`
  - Result: `/bin/bash: line 1: ./ops/init/tools/lint_truth.sh: No such file or directory`
- Risk / rollback:
  - Risk: Low; adds a gate that currently fails until the DP template headings are updated.
  - Rollback: revert the linter and protocol/help changes.

## 2026-01-21 — DP-OPS-0048C: DP Run Hygiene v1: Placeholder-Marker Ban + Memento Seed

- What changed: Added a no placeholder-marker rule for run DPs and worker results, seeded M-RUN-01, and logged this DP.
- Verification:
  - `bash tools/context_lint.sh`
  - Result: `[context_lint] Result: clean`
  - `bash tools/lint_truth.sh`
  - Result: `[lint_truth] OK`
- Risk / rollback:
  - Risk: Low; doc-only policy and ledger updates.
  - Rollback: revert the touched files.

## 2026-01-20 — DP-OPS-0048B: DP template headings + RECEIPT structure

- Purpose: Normalize DP worker-results headings to canonical A–E + RECEIPT and complete RECEIPT subheadings for consistent handoff bundles.
- What shipped:
- Verification:
  - `bash tools/context_lint.sh`
  - Result: `[context_lint] Result: clean`
  - `bash tools/lint_truth.sh`
  - Result: `[lint_truth] OK`
  - Result:
    - `126:### A) SUMMARY + SCOPE CONFIRMATION`
    - `130:### B) PATHS TOUCHED`
    - `134:### C) VERIFICATION`
    - `136:### D) PATCH / DIFF`
    - `145:### E) NOTES`
  - Result: `197:### RECEIPT`
  - Result:
    - `199:#### A) OPEN Output`
    - `203:#### B) dump Output`
    - `214:#### C) PORCELAIN Output`
    - `217:#### D) DP-RESULTS.md Output`
    - `219:#### E) NOTES (optional)`
- Risk / rollback:
  - Risk: Low; template-only formatting changes.
  - Rollback: revert the touched files.

## 2026-01-20 — DP-OPS-0048A: Proof-first review gate + disapproval protocol

- Purpose: Require a minimal proof bundle in DP RESULTS and add a canonical DISAPPROVE response shape.
- What shipped:
  - DP protocol/template: required proof bundle (git status --porcelain, git diff --name-only, git diff --stat, plus verification outputs).
  - Operator manual: disapproval checklist + copy/paste DISAPPROVE template.
  - TRUTH: proof-bundle reject rule added.
- Verification:
  - `bash tools/context_lint.sh`
  - Result: `[context_lint] Result: clean`
  - `bash tools/lint_truth.sh`
  - Result: `[lint_truth] OK`
- Risk / rollback:
  - Risk: Low; doc-only protocol/template updates.
  - Rollback: revert the touched files.

## 2026-01-19 — DP-OPS-0047: Project womb v2 (new/current + standard skeleton)

- Purpose: Extend project tooling with `new/use/current`, auto ID/slug, and a standard skeleton that includes upstream/addons/patches stubs.
- What shipped:
  - Added project helpers for next-id generation, slugging, and current-project pointer management.
  - Extended `ops/bin/project` with `new`, `use`, and real `current`, plus standard subdir scaffolding.
  - Added default upstream/addons/patches README templates and updated registry/operator docs.
- Verification:
  - `./ops/bin/project list`
  - `./ops/bin/project current`
  - `./ops/bin/project new --name "Demo Project" --dry-run`
  - `./ops/bin/project use <an-existing-id> --dry-run`
  - `./tools/context_lint.sh`
  - `./ops/bin/lint_truth.sh`
- Risk / rollback:
  - Risk: Medium; bash tooling changes and registry format updates can drift.
  - Rollback: revert edits to `ops/bin/project`, `ops/lib/project/project_lib.sh`, and docs/templates.

## 2026-01-19 — DP-OPS-0048: Stelae library seed

- Purpose: Seed a lightweight Stelae library page and wire it into canon pointers.
- What shipped:
  - Added `docs/library/[REMOVED].md` with 10 starter Stelae entries.
  - Linked [REMOVED] in `docs/INDEX.md` and `TRUTH.md Section 2`.
  - Added a [REMOVED] pointer line to `ops/bin/open`.
- Verification:
  - `bash tools/context_lint.sh`
  - Result: `[context_lint] Result: clean`
  - `bash tools/lint_truth.sh`
  - Result: `[lint_truth] OK`
  - `./ops/bin/open --intent="dp-ops-0048 verify" --dp="DP-OPS-0048 / 2026-01-19" | rg -n "[REMOVED]"`
  - `rg -n "[REMOVED]" docs/INDEX.md TRUTH.md Section 2 docs/library/[REMOVED].md`
- Risk / rollback:
  - Risk: Low; docs + small open pointer change.
  - Rollback: revert the touched files and remove `docs/library/[REMOVED].md`.

## 2026-01-18 — DP-OPS-0042: STELA naming seed (doc-only)

- Purpose: Seed STELA naming in canon with no-churn guardrails and explicit non-goals.
- What shipped:
  - Added Naming / Identity section to `TRUTH.md` defining STELA, Stela legacy label, and no-churn policy.
  - Added a short STELA note in the operator manual and a minimal naming doc with anti-drift bullets.
  - Added a single MEMENTOS clarification line about naming vs canon/contracts.
  - Registered the STELA naming doc in `docs/INDEX.md`.
- Verification:
  - `bash tools/context_lint.sh`
  - `bash tools/lint_truth.sh`
  - `rg -n "(STELA|Stela|Nuke CE)" TRUTH.md SoP.md docs/library/MANUAL.md docs/library/MEMENTOS.md docs/library/STELA_NAMING.md docs/INDEX.md`
  - `git diff --name-only`
- Risk / rollback:
  - Risk: Low; doc-only naming alignment.
  - Rollback: revert the touched files to pre-DP-OPS-0042 state.

## 2026-01-18 — DP-OPS-0041: Snapshot receipt package bundling

- Purpose: Bundle dump manifest + payload inside tarball; canonize receipt package artifacts and reduce operator friction.
- What shipped:
  - Added `--bundle` to `ops/bin/dump` to include payload + manifest inside the tarball.
  - Updated DP protocol/template, operator manual, and TRUTH to describe receipt package artifacts and bundling expectations.
- Verification:
  - `bash tools/context_lint.sh`
  - `bash tools/lint_truth.sh`
  - `./ops/bin/dump --scope=icl --format=chatgpt --out=auto --bundle`
  - `tar -tf storage/dumps/dump-icl-work-dp-ops-0041-dump-receipt-package-2026-01-18-4adb71c4.tar.xz`
- Risk / rollback:
  - Risk: Medium-low; dump tooling + docs updates.
  - Rollback: revert the touched files; dump behavior returns to pre-DP defaults.

## 2026-01-17 — DP-OPS-0040A: Handoff artifacts + output-artifact clarification

- Purpose: Clarify tracked vs output artifacts, standardize RESULTS naming, add OPEN tag support, and default dump compression for full auto output.
- What shipped:
  - Canonized output artifacts as untracked under `storage/handoff/` and `storage/dumps/`.
  - Required `<DP-ID>-RESULTS.md` naming in DP protocol/template and operator guidance.
  - Added `--tag` support for OPEN output filenames and default `--compress=tar.xz` for `--scope=full --out=auto` snapshots.
- Verification:
  - `bash tools/context_lint.sh`
  - `bash tools/lint_truth.sh`
  - `./ops/bin/open --out=auto --tag=dp-ops-0040a-2026-01-17`
  - `./ops/bin/dump --scope=full --format=chatgpt --out=auto`
- Risk / rollback:
  - Risk: Low; contract/tooling changes only.
  - Rollback: revert the touched files to pre-DP-OPS-0040A state.

## 2026-01-17 — DP-OPS-0040 Addendum-01: Handoff artifacts (repo-local)

- Purpose: Canonize repo-local handoff artifacts, RESULTS file requirement, and OPEN porcelain capture/preview rules.
- What shipped:
  - Defined `storage/handoff/` as the canonical handoff directory and required a DP-ID RESULTS markdown file (DP-ID-RESULTS.md naming; basename uppercase).
  - Canonized OPEN/OPEN-PORCELAIN capture filenames and updated OPEN to save full porcelain with a preview cap for large states.
  - Snapshot now prints payload/manifest/tarball paths and ensures handoff dir exists; docs now prefer `--compress=tar.xz` for large `--scope=full` snapshots.
- Verification:
  - `bash tools/context_lint.sh`
  - `bash tools/lint_truth.sh`
  - `./ops/bin/open`
- Risk / rollback:
  - Risk: Low; handoff + logging changes only.
  - Rollback: revert the touched docs/scripts and delete local `storage/handoff/` artifacts (output-only).

## 2026-01-17 — DP-OPS-0040: Platform/project separation + platform dump scope

- Purpose: Separate platform vs project payloads and add a platform-only dump scope.
- What shipped:
  - Platform/project separation (platform vs project move).
  - Added `--scope=platform` to `./ops/bin/dump` for platform-only context.
- Verification:
  - Not recorded in repo; DP-OPS-0040 verification details not found. Operator confirmation required.
- Risk / rollback:
  - Risk: Low; platform-only scope may change operator expectations for dump content.
  - Rollback: revert DP-OPS-0040 changes (platform/project separation + `--scope=platform`) to pre-DP behavior.

## 2026-01-17 — DP-OPS-0039: Attachment-mode handoff + branch safety tightening

- Purpose: Canonize attachment-mode handoff and tighten branch safety STOP rules for DP execution.
- What shipped:
  - Added attachment-mode as an explicit operator handoff option with attachment content requirements, keeping paste-mode intact.
  - Added STOP rules for main-branch work, branch mismatch, and missing required work branch name in DP protocol/template.
  - Clarified no-delete/no-move policy as "unless explicitly authorized by the DP" and documented mobile attachment-mode + branch protection reminder.
- Verification:
  - `bash tools/context_lint.sh`
  - `bash tools/lint_truth.sh`
- Risk / rollback:
  - Risk: Medium-low; workflow wording could be misread by operators/workers.

## 2026-01-17 — DP-OPS-0038: DP contract binding + RECEIPT manifest requirements

- Purpose: Tighten DP contract for reuse-first, duplication checks, SSOT declarations, and RECEIPT manifest requirements while keeping repo-shape neutral.
- What shipped:
  - Hardened DP template/protocol with required SCOPE/FILES/FORBIDDEN blocks, STOP/BLOCKED enforcement, reuse-first + duplication checks, SSOT declaration, and no-new-files constraint.
  - Added supersession proposal-only guidance with crisp plan requirements.
  - Required RECEIPT dump to include manifest path and tarball+manifest pair when archived.
- Verification:
  - `bash tools/context_lint.sh`
  - `bash tools/lint_truth.sh`
- Risk / rollback:
  - Risk: Low to medium-low; tighter constraints may slow work if wording is misread.
  - Rollback: revert the touched files to the pre-DP-OPS-0038 state.

## 2026-01-16 — DP-OPS-0037: MEMENTOS artifacts + interpretation/tone tightening

- Purpose: Harden MEMENTOS SSOT with quoteable artifacts, remove ambiguity in multi-interpretation handling, and calibrate tone guidance.
- What shipped:
  - Added one-line artifacts for M-ATTN-01, M-COMMIT-01, M-HANDOFF-01, and M-EMIT-01 under the MEMENTOS index.
  - Replaced the multi-interpretation handling rule to require enumeration plus operator choice unless canon/inputs determine the answer.
  - Updated tone guidance to default to calm, precise language and avoid cheerleading or implied authority.
- Verification:
  - `bash tools/context_lint.sh`
  - `rg -n "M-ATTN-01|M-COMMIT-01|M-HANDOFF-01|M-EMIT-01" docs/library/MEMENTOS.md`
- Risk / rollback:
  - Risk: Low. MEMENTOS become more explicit; may slightly change stop/ask behavior in edge cases.
  - Rollback: revert `docs/library/MEMENTOS.md` and `SoP.md` to pre-DP-OPS-0037 state.

## 2026-01-16 — DP-OPS-0035: RECEIPT rename + DP Risk / Rollback requirement

- Purpose: Rename the worker-results bundle to RECEIPT, require Risk / Rollback in DP format, and reinforce OPEN + dump as the rehydration milestone.
- What shipped:
  - Replaced the legacy bundle label with RECEIPT across canon, protocol, template, and operator guidance.
  - Added Risk / Rollback as a required DP section and updated the DP template.
  - Updated worker-result rejection language to use RECEIPT.
  - Hardened the DP template (addendum): STOP on literal ellipsis placeholder, BLOCKED mini-receipt shape, explicit required output slots A) SUMMARY + SCOPE CONFIRMATION and D) PATCH / DIFF, verification discipline wording.
  - Updated dump behavior (addendum): dump writes chat payload .txt; dump writes tarball (when used) and ALWAYS writes manifest pointing to chat payload.
- Verification:
  - `bash tools/context_lint.sh`
- Risk / rollback:
  - Risk: Medium-low; doc/template rename could break operator expectations if any old label lingers.
  - Rollback: revert the touched files and restore the previous label and DP template section ordering.

## 2026-01-16 — DP-OPS-0034: Root AI entry points (llms.txt + AGENTS.md)

- Purpose: Add repo-root AI entry points that map existing canon without duplication.
- What shipped:
  - Added `llms.txt` as a pointer map into canon and tools.
  - Added `AGENTS.md` as a pointer-first agent constitution.
  - Declared the entry points in `TRUTH.md`.
- Verification:
  - `test -f llms.txt`
  - `test -f AGENTS.md`
  - `rg -n "llms\\.txt|AGENTS\\.md" TRUTH.md`
  - `bash tools/context_lint.sh`
- Risk / rollback:
  - Risk: Low; docs-only pointer additions.
  - Rollback: delete `llms.txt` and `AGENTS.md`, revert `TRUTH.md`, and remove this entry.

## 2026-01-15 — DP-OPS-0033: ICL Continuity Core + legacy onboarding retirement

- Purpose: Define the ICL Continuity Core, retire the legacy onboarding directory, and triage ICL continuity files.
- What shipped:
  - Added `ops/init/icl/ICL_CONTINUITY_CORE.md` and wired it into `TRUTH.md`, the continuity map, and the docs library.
  - Moved core continuity files into `ops/init/icl/` and updated references across ops/docs.
  - Moved legacy onboarding files into `ops/init/icl/deprecated/` with deprecation notices.
  - Removed obsolete ICL rename artifacts and the legacy onboarding folder stub.
  - Updated `ops/bin/open`, `ops/bin/dump`, and `ops/init/icl/context_pack.json` for the new core paths.
- Verification:
  - `rg -n "launch_pack" ops/`
  - `git diff --name-only`
  - `bash tools/context_lint.sh`
- Risk / rollback:
  - Risk: missed pointer update could break operator wayfinding.
  - Rollback: revert the touched files and restore the prior ICL layout.

## 2026-01-15 — DP-OPS-0032: Continuity map + supersession hygiene

- Purpose: Make continuity surfaces findable; canonize supersession/deprecation/deletion proposals; add a later bucket label.
- What shipped:
  - Added `docs/library/MAP.md` and wired it into the curated library and Operator Manual.
  - Canonized supersession/deprecation/deletion proposal rules in `TRUTH.md`.
  - Added a "Later bucket" section in `SoP.md` for dedupe / clone detection ideas.
- Verification:
  - `bash tools/context_lint.sh`
  - `bash ops/bin/help list`
- Risk / rollback:
  - Risk: Low; docs-only canon updates.
  - Rollback: revert the touched docs and this entry.

## Later bucket (ideas only; no implementation)

- Dedupe / clone detection ideas: record here; do not implement.

## 2026-01-15 — DP-OPS-0030: OPEN posture nudge

- Purpose: Add a minimal posture nudge to OPEN for precision and stop-when-uncertain behavior.
- What shipped:
  - Inserted the 3-line posture nudge before [FRESHNESS GATE] in `ops/bin/open`.
  - Added short notes about the posture nudge in `TRUTH.md` and `docs/library/MANUAL.md`.
- Verification:
  - `rg -n "canon-governed system|Precision beats speed|If unsure, stop and ask" ops/bin/open TRUTH.md docs/library/MANUAL.md`
  - `bash tools/context_lint.sh`
  - Manual check: OPEN output shows the 3-line block above [FRESHNESS GATE] with no other changes.
- Risk / rollback:
  - Risk: Low; output text + docs note only.
  - Rollback: revert `ops/bin/open`, `TRUTH.md`, `docs/library/MANUAL.md`, and this entry.

## 2026-01-15 — DP-OPS-0031: MEMENTOS strategic placement

- Purpose: Place a small set of inference-timed MEMENTOS and pointers without duplication.
- What shipped:
  - Added a MEMENTO index and updated placement references in `docs/library/MEMENTOS.md`.
- Verification:
  - `rg -n "M-ATTN-01|M-COMMIT-01|M-HANDOFF-01|M-EMIT-01" docs/library/MEMENTOS.md`
  - `git diff --name-only`
- Risk / rollback:
  - Risk: Low; docs-only pointer/index changes.

## 2026-01-15 — DP-OPS-0029: Approval prefix + delimiter for chat UI paste

- Purpose: Fix "approval lost in paste" by canonizing approval-prefix + delimiter for same-message paste.
- What shipped:
- Verification:
  - Manual check: all docs agree on approval pattern, start-of-message requirement, delimiter rule, and paste order.
  - `git diff --name-only`
  - `bash tools/context_lint.sh`
- Risk / rollback:
  - Risk: Low; docs-only canon update.
  - Rollback: revert the touched docs and this entry.

## 2026-01-14 — DP-OPS-0028: Behavioral preferences placement + operator wayfinding

- Purpose: Define the single source of truth for behavioral preferences and make wayfinding pointer-only.
- What shipped:
  - Added the behavioral preferences file in the curated library.
  - Added pointer-only links in `TRUTH.md`, `docs/library/MANUAL.md`, and `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`.
  - Removed legacy dataset and manifest entries for behavioral preferences.
- Verification:
  - `ls docs/library`
  - `rg -n "Behavioral preferences are documented" TRUTH.md docs/library/MANUAL.md ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`
  - `bash tools/context_lint.sh`
- Risk / rollback:
  - Risk: Low; docs-only canon update.
  - Rollback: delete the behavioral preferences file and remove the pointer lines.

## 2026-01-14 — DP-OPS-0027: Approval line placement + handoff paste order

- Purpose: Stop "approval lost in the paste" by canonizing standalone approval line placement and deterministic handoff paste order.
- What shipped:
  - Canonized "Approval Line Placement" (standalone, outside OPEN/intent/quotes) in `TRUTH.md`.
  - Canonized "Operator Handoff Paste Order" (1. Approval, 2. Results, 3. Snapshot) in `TRUTH.md` and `docs/library/MANUAL.md`.
- Verification:
  - Manual check: rules explicitly forbid approvals inside OPEN intent and inside quoted/fenced blocks.
  - `git diff --name-only`
  - `bash tools/context_lint.sh`
- Risk / rollback:
  - Risk: Low; docs-only canon update.
