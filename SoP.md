## 2026-01-22 — DP-OPS-0050A: Integrator Phase Discipline (Conformance-First + Phase-Locked Outputs)

- Purpose: Lock conformance-first DP refreshes, phase-locked outputs, receipt bundle always, and allow OPEN/snapshot to be operator-provided or locally generated per run.
- What shipped:
  - Added Integrator Phase Discipline rules (conformance-first, phase-locked outputs, receipt bundle always) to `TRUTH.md`.
  - Added Integrator Phase Discipline operator phrases, hard stops, and decision table to `docs/library/OPERATOR_MANUAL.md`.
  - Updated M-PHASE-01 to "Conformance First, Creativity After" with triggers in `docs/library/MEMENTOS.md`.
- Verification:
  - `bash tools/context_lint.sh`
  - Result: `[context_lint] Result: clean`
  - `bash tools/lint_truth.sh`
  - Result: `[lint_truth] OK`
- Risk / rollback:
  - Risk: Low (docs-only guidance updates).
  - Rollback: revert `TRUTH.md`, `docs/library/OPERATOR_MANUAL.md`, `docs/library/MEMENTOS.md`, and `SoP.md`.

## 2026-01-21 — DP-OPS-0050: Stelae Governance (Keep It Useful, Keep It Rare)

- Summary: Added Stelae governance + entry format rules, added operator Stelae usage guidance, and logged the DP.
- Verification:
  - `./tools/context_lint.sh`
  - Result: `/bin/bash: line 1: ./tools/context_lint.sh: No such file or directory`
  - `./ops/bin/lint_truth.sh`
  - Result: `/bin/bash: line 1: ./ops/bin/lint_truth.sh: No such file or directory`
- Risk / rollback:
  - Risk: Low (docs-only governance + guidance updates).
  - Rollback: revert `docs/library/[REMOVED].md`, `OPERATOR_MANUAL.md`, and `SoP.md`.

## 2026-01-21 — DP-OPS-0049: Stela Name Guardrails (Canonical Spelling + Lint)

- Purpose: Canonize Stela/Stelae spelling, declare SSOT, and add a lint guardrail for typos.
- What shipped:
  - Updated naming canon in `TRUTH.md`, operator guidance in `docs/library/OPERATOR_MANUAL.md`, and spelling policy in `docs/library/[REMOVED].md`.
  - Added forbidden spelling checks to `tools/lint_truth.sh`.
- Verification:
  - `bash tools/context_lint.sh`
  - Result: `[context_lint] Result: clean`
  - `bash tools/lint_truth.sh`
  - Result: `[lint_truth] OK`
  - `rg -n "Stela|Stelae" TRUTH.md docs/library/[REMOVED].md docs/library/OPERATOR_MANUAL.md`
  - Result:
    - `TRUTH.md:9:- Stela (S-T-E-L-A): only canonical project / platform name spelling (stone tablet metaphor: published canon / governance visible to all).`
    - `TRUTH.md:10:- Stelae (S-T-E-L-A-E): plural / collection label.`
    - `docs/library/[REMOVED].md:1:# Stelae`
    - `docs/library/[REMOVED].md:3:Stelae are short operator-facing reminders to keep conversations precise and calm.`
    - `docs/library/[REMOVED].md:8:- "Stela" is the singular project / platform name.`
    - `docs/library/[REMOVED].md:9:- "Stelae" is the plural / collection label.`
    - `docs/library/[REMOVED].md:11:- Correct: "Stela is the platform name."`
    - `docs/library/[REMOVED].md:12:- Correct: "These Stelae keep operator guidance consistent."`
    - `docs/library/OPERATOR_MANUAL.md:5:You may see legacy \`Stela\` strings; \`Stela\` is the platform name going forward.`
    - `docs/library/OPERATOR_MANUAL.md:116:- \`./ops/bin/project\` lists/initializes Stela-born projects (no import/migration).`
    - `docs/library/OPERATOR_MANUAL.md:180:- Canon spelling: Stela (singular) / Stelae (plural). Normalize voice-to-text variants before committing or approving.`
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
  - Rollback: revert `TRUTH.md`, `docs/library/OPERATOR_MANUAL.md`, `docs/library/[REMOVED].md`, `tools/lint_truth.sh`, and `SoP.md`.


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
  - Rollback: revert `docs/library/OPERATOR_MANUAL.md`, `ops/contracts/OUTPUT_FORMAT_CONTRACT.md`, `docs/library/MEMENTOS.md`, and `SoP.md`.

## 2026-01-21 — DP-OPS-0048D: Dispatch Packet template heading linter

- What changed:
  - Added `ops/bin/dispatch_packet_lint.sh` to enforce canonical DP A-E headings.
  - Required the linter in `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md` verification.
  - Listed the linter in `ops/bin/help`.
- Verification:
  - `./ops/bin/dispatch_packet_lint.sh`
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
    - `203:#### B) SNAPSHOT Output`
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

## 2026-01-19 — DP-OPS-0046: Retire close + canonize DISCUSS-ONLY

- Purpose: Retire the legacy close script and canonize DISCUSS-ONLY as the talk-only cue.
- What shipped:
  - Deleted the legacy close script and removed it from ICL snapshot inputs.
  - Updated DP protocol/template, operator manual, and TRUTH to define DISCUSS-ONLY and remove close guidance.
  - Updated help menu and `llms.txt` tool list to drop close references.
- Verification:
  - `bash tools/context_lint.sh`
  - `bash tools/lint_truth.sh`
  - `rg -n "close" .`
- Risk / rollback:
  - Risk: Low-medium; operators relying on close may need adjustment.
  - Rollback: restore the legacy close script and revert the touched files.

## 2026-01-19 — DP-OPS-0048: Stelae library seed

- Purpose: Seed a lightweight Stelae library page and wire it into canon pointers.
- What shipped:
  - Added `docs/library/[REMOVED].md` with 10 starter Stelae entries.
  - Linked [REMOVED] in `docs/00-INDEX.md` and `TRUTH.md Section 2`.
  - Added a [REMOVED] pointer line to `ops/bin/open`.
- Verification:
  - `bash tools/context_lint.sh`
  - Result: `[context_lint] Result: clean`
  - `bash tools/lint_truth.sh`
  - Result: `[lint_truth] OK`
  - `./ops/bin/open --intent="dp-ops-0048 verify" --dp="DP-OPS-0048 / 2026-01-19" | rg -n "[REMOVED]"`
  - `rg -n "[REMOVED]" docs/00-INDEX.md TRUTH.md Section 2 docs/library/[REMOVED].md`
- Risk / rollback:
  - Risk: Low; docs + small open pointer change.
  - Rollback: revert the touched files and remove `docs/library/[REMOVED].md`.

## 2026-01-19 — DP-OPS-0045: DP docket + DISCUSS-ONLY cue

- Purpose: Introduce an optional forward-looking docket (`docs/library/DOCKET.md`) and clarify DISCUSS-ONLY as a non-gating alignment cue.
- What shipped:
  - Added `docs/library/DOCKET.md` as the single forward-looking DP docket with NEXT_DP_ID.
  - Updated `docs/library/OPERATOR_MANUAL.md` with docket guidance and the DISCUSS-ONLY cue.
  - Updated `TRUTH.md` with DISCUSS-ONLY non-gating clarification.
- Verification:
  - `bash tools/context_lint.sh`
  - Result: `[context_lint] Result: clean`
  - `bash tools/lint_truth.sh`
  - Result: `[lint_truth] OK`
- Risk / rollback:
  - Risk: Low; doc-only operator guidance.
  - Rollback: revert the touched files and remove `docs/library/DOCKET.md`.

## 2026-01-18 — DP-OPS-0042: STELA naming seed (doc-only)

- Purpose: Seed STELA naming in canon with no-churn guardrails and explicit non-goals.
- What shipped:
  - Added Naming / Identity section to `TRUTH.md` defining STELA, Stela legacy label, and no-churn policy.
  - Added a short STELA note in the operator manual and a minimal naming doc with anti-drift bullets.
  - Added a single MEMENTOS clarification line about naming vs canon/contracts.
  - Registered the STELA naming doc in `docs/00-INDEX.md`.
- Verification:
  - `bash tools/context_lint.sh`
  - `bash tools/lint_truth.sh`
  - `rg -n "(STELA|Stela|Nuke CE)" TRUTH.md SoP.md docs/library/OPERATOR_MANUAL.md docs/library/MEMENTOS.md docs/library/STELA_NAMING.md docs/00-INDEX.md`
  - `git diff --name-only`
- Risk / rollback:
  - Risk: Low; doc-only naming alignment.
  - Rollback: revert the touched files to pre-DP-OPS-0042 state.

## 2026-01-18 — DP-OPS-0041: Snapshot receipt package bundling

- Purpose: Bundle snapshot manifest + payload inside tarball; canonize receipt package artifacts and reduce operator friction.
- What shipped:
  - Added `--bundle` to `ops/bin/dump` to include payload + manifest inside the tarball.
  - Updated DP protocol/template, operator manual, and TRUTH to describe receipt package artifacts and bundling expectations.
- Verification:
  - `bash tools/context_lint.sh`
  - `bash tools/lint_truth.sh`
  - `./ops/bin/dump --scope=icl --format=chatgpt --out=auto --bundle`
  - `tar -tf storage/dumps/snapshot-icl-work-dp-ops-0041-snapshot-receipt-package-2026-01-18-4adb71c4.tar.xz`
- Risk / rollback:
  - Risk: Medium-low; snapshot tooling + docs updates.
  - Rollback: revert the touched files; snapshot behavior returns to pre-DP defaults.

## 2026-01-17 — DP-OPS-0040A: Handoff artifacts + output-artifact clarification

- Purpose: Clarify tracked vs output artifacts, standardize RESULTS naming, add OPEN tag support, and default snapshot compression for full auto output.
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

## 2026-01-17 — DP-OPS-0040: Platform/project separation + platform snapshot scope

- Purpose: Separate platform vs project payloads and add a platform-only snapshot scope.
- What shipped:
  - Platform/project separation (platform vs project move).
  - Added `--scope=platform` to `./ops/bin/dump` for platform-only context.
- Verification:
  - Not recorded in repo; DP-OPS-0040 verification details not found. Operator confirmation required.
- Risk / rollback:
  - Risk: Low; platform-only scope may change operator expectations for snapshot content.
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
  - Required RECEIPT SNAPSHOT to include manifest path and tarball+manifest pair when archived.
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

- Purpose: Rename the worker-results bundle to RECEIPT, require Risk / Rollback in DP format, and reinforce OPEN + SNAPSHOT as the rehydration milestone.
- What shipped:
  - Replaced the legacy bundle label with RECEIPT across canon, protocol, template, and operator guidance.
  - Added Risk / Rollback as a required DP section and updated the DP template.
  - Updated worker-result rejection language to use RECEIPT.
  - Hardened the DP template (addendum): STOP on literal ellipsis placeholder, BLOCKED mini-receipt shape, explicit required output slots A) SUMMARY + SCOPE CONFIRMATION and D) PATCH / DIFF, verification discipline wording.
  - Updated snapshot behavior (addendum): snapshot writes chat payload .txt; snapshot writes tarball (when used) and ALWAYS writes manifest pointing to chat payload.
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
  - Added `docs/library/CONTINUITY_MAP.md` and wired it into the curated library and Operator Manual.
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
  - Added short notes about the posture nudge in `TRUTH.md` and `docs/library/OPERATOR_MANUAL.md`.
- Verification:
  - `rg -n "canon-governed system|Precision beats speed|If unsure, stop and ask" ops/bin/open TRUTH.md docs/library/OPERATOR_MANUAL.md`
  - `bash tools/context_lint.sh`
  - Manual check: OPEN output shows the 3-line block above [FRESHNESS GATE] with no other changes.
- Risk / rollback:
  - Risk: Low; output text + docs note only.
  - Rollback: revert `ops/bin/open`, `TRUTH.md`, `docs/library/OPERATOR_MANUAL.md`, and this entry.

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
  - Added pointer-only links in `TRUTH.md`, `docs/library/OPERATOR_MANUAL.md`, and `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`.
  - Removed legacy dataset and manifest entries for behavioral preferences.
- Verification:
  - `ls docs/library`
  - `rg -n "Behavioral preferences are documented" TRUTH.md docs/library/OPERATOR_MANUAL.md ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`
  - `bash tools/context_lint.sh`
- Risk / rollback:
  - Risk: Low; docs-only canon update.
  - Rollback: delete the behavioral preferences file and remove the pointer lines.

## 2026-01-14 — DP-OPS-0027: Approval line placement + handoff paste order

- Purpose: Stop "approval lost in the paste" by canonizing standalone approval line placement and deterministic handoff paste order.
- What shipped:
  - Canonized "Approval Line Placement" (standalone, outside OPEN/intent/quotes) in `TRUTH.md`.
  - Canonized "Operator Handoff Paste Order" (1. Approval, 2. Results, 3. Snapshot) in `TRUTH.md` and `docs/library/OPERATOR_MANUAL.md`.
- Verification:
  - Manual check: rules explicitly forbid approvals inside OPEN intent and inside quoted/fenced blocks.
  - `git diff --name-only`
  - `bash tools/context_lint.sh`
- Risk / rollback:
  - Risk: Low; docs-only canon update.

## 2026-01-14 — DP-OPS-0026: Operator approval + paste contract lock

- What shipped:
  - Canonized operator approval + paste contract requirements (plain text approval, raw paste, snapshot attachment, quoted blocks invalid) in `TRUTH.md`.
  - Documented the exact operator paste order in `docs/library/OPERATOR_MANUAL.md`.
- Verification:
  - `rg -n "APPROVE DP-" TRUTH.md`
  - Manual check: `docs/library/OPERATOR_MANUAL.md` documents the exact paste order.
  - `git diff --name-only`
  - `bash tools/context_lint.sh`
- Risk / rollback:
  - Risk: Low; docs-only canon + template/protocol updates.


- What shipped:
  - Added a short "How to approve" snippet in `docs/library/OPERATOR_MANUAL.md`.
- Verification:
  - `bash tools/context_lint.sh`
  - `git diff --name-only`
- Risk / rollback:
  - Risk: Low; docs-only canon + template updates.

## 2026-01-14 — DP-OPS-0024: Approval gate robustness + snapshot/OPEN decision

- What shipped:
  - Updated `docs/library/OPERATOR_MANUAL.md` to list approval phrases and document that snapshots do not include OPEN output.
- Verification:
  - Manual check: near-miss approval refusals include the paste-ready phrase.
  - `bash tools/context_lint.sh`
  - `git diff --name-only`
- Risk / rollback:
  - Risk: Low; canon/docs-only wording updates.

## 2026-01-14 — DP-OPS-0023: Bias artifacts canon + library wiring

- Purpose: Convert source texts into a canonical bias artifacts doc and wire it into the curated library with preferences-not-permissions defined.
- What shipped:
  - Added a bias artifacts dataset doc and library entries.
  - Added a pointer in the operator manual.
  - Defined bias artifacts in Project Truth.
- Verification:
  - `rg -n "bias artifacts" TRUTH.md docs/library/OPERATOR_MANUAL.md docs/library/LIBRARY_INDEX.md`
  - `bash ops/bin/help list`
  - `bash tools/context_lint.sh`
- Risk / rollback:
  - Risk: Low; docs-only canon update.
  - Rollback: revert the touched docs and this entry.


- What shipped:
- Verification:
  - Manual check: UI order matches IDE "Commit message" (plain text, one line), GitHub PR "Add a title" (plain text, one line), GitHub PR "Add a description" (Markdown), GitHub merge "Commit message" (plain text, one line), GitHub merge "Extended description" (plain text, body), GitHub PR "Add a comment" (Markdown).
  - `git diff --name-only`
  - `bash tools/context_lint.sh`
- Risk / rollback:
  - Risk: Low; docs-only wording updates.


- What shipped:
  - Added operator-idiom canonization guardrails in `TRUTH.md`.
- Verification:
  - `git diff --name-only`
  - `bash tools/context_lint.sh`
- Risk / rollback:
  - Risk: Low; docs-only wording updates.

## 2026-01-13 — DP-OPS-0020: Require Worker RECEIPT (OPEN + SNAPSHOT)

- Purpose: Require workers to end every DP result with the RECEIPT containing OPEN output plus SNAPSHOT output, and treat omission as a hard failure.
- What shipped:
  - Updated the RECEIPT definition and rejection rule in `TRUTH.md`.
  - Updated the DP protocol and DP template to mandate the new RECEIPT headings and rule.
  - Updated `docs/library/OPERATOR_MANUAL.md` to match the new RECEIPT format.
- Verification:
  - `rg -n "RECEIPT" ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`
  - Manual check: RECEIPT appears at end of DP template.
  - `git diff --name-only`
- Risk / rollback:
  - Risk: Low; docs-only wording updates.

## 2026-01-13 — DP-OPS-0019: Worker RECEIPT canon

- Purpose: Require workers to end every DP result with a full RECEIPT (OPEN output, status, last commit; optional snapshot pointer).
- What shipped:
  - Canonized the RECEIPT requirement in `TRUTH.md`.
  - Updated the DP protocol, DP template, and Operator Manual with copy-ready RECEIPT headings and end-of-message rule.
- Verification:
  - `git diff --name-only`
- Risk / rollback:
  - Risk: Low; docs-only change.
  - Rollback: revert the touched docs/templates and this entry.


- What shipped:
  - Required worker outputs to include OPEN output, `git status --porcelain`, and `git log -1 --oneline`, with a hard stop if repo access is unavailable.
- Verification:
  - `git diff --name-only`
  - `bash tools/context_lint.sh`
- Risk / rollback:
  - Risk: Low; wording-only changes.
  - Rollback: revert the touched docs/templates and this entry.

## 2026-01-13 — DP-OPS-0017: DB-DATASET system + DB-VOICE-0001 (Declarative Mode)

- Purpose: Introduce a manifest-only DB-DATASET library and seed DB-VOICE-0001 (Declarative Mode).
- What shipped:
  - Added dataset topics to `docs/library/LIBRARY_INDEX.md` and updated curated-surface docs.
- Verification:
  - `git diff --name-only`
  - `bash ops/bin/help list`
  - `bash ops/bin/help db-dataset`
  - `bash ops/bin/help db-voice-0001`
  - `bash tools/context_lint.sh`
- Risk / rollback:
  - Risk: Low; docs-only changes.
  - Rollback: revert the docs updates and this entry.

## 2026-01-13 — DP-OPS-0016: Operator Manual fence fix + docs library alignment

- Purpose: Fix Operator Manual fence integrity and align content with curated docs library/help topics.
- What shipped:
  - Repaired and expanded `docs/library/OPERATOR_MANUAL.md` with clean fences and current topics.
  - Confirmed curated docs library and help front door alignment in operator docs.
- Verification:
  - `git diff --name-only`
  - `rg -n "```" docs/library/OPERATOR_MANUAL.md`
  - `bash ops/bin/help list`
  - `bash ops/bin/help manual`
- Risk / rollback:
  - Risk: Low; docs-only edits.
  - Rollback: revert `docs/library/OPERATOR_MANUAL.md` and this entry.

## 2026-01-13 — DP-OPS-0015: Snapshot optional archive output (tar.xz) + Operator Manual

- Purpose: Add optional tar.xz archive output for snapshots and promote a real Operator Manual in the docs library.
- What shipped:
  - Added optional tar.xz archive output for `ops/bin/dump` (no default behavior changes).
  - Added `docs/library/OPERATOR_MANUAL.md` with a top-commands cheat sheet and archive usage.
  - Updated `docs/library/LIBRARY_INDEX.md` and `docs/ops/INDEX.md` to point to the new manual.
- Verification:
  - `git diff --name-only`
  - `bash tools/verify_tree.sh`
  - `bash tools/context_lint.sh`
  - `bash ops/bin/dump --scope=icl --format=chatgpt | head -n 40`
  - `bash ops/bin/dump --scope=icl --format=chatgpt --out=auto`
  - `bash ops/bin/dump --scope=icl --format=chatgpt --out=auto --compress=tar.xz`
  - `bash ops/bin/dump --scope=icl --format=chatgpt --out=auto.tar.xz`
  - `ls -la storage/dumps/ | tail -n 20`
  - `tar -tf storage/dumps/<newfile>.tar.xz | head`
  - `bash ops/bin/help list`
  - `bash ops/bin/help manual`
- Risk / rollback:
  - Risk: Low; new optional output path and docs only.
  - Rollback: revert `ops/bin/dump`, remove `docs/library/OPERATOR_MANUAL.md`, revert `docs/library/LIBRARY_INDEX.md`, `docs/ops/INDEX.md`, and this entry.

## 2026-01-13 — DP-OPS-0013: Help front door + curated docs library

- Purpose: Add a docs reader front door and formalize the curated docs library surface.
- What shipped:
  - Added `ops/bin/help` with manifest-only access and pager output.
  - Added `docs/library/LIBRARY_INDEX.md` as the curated docs manifest.
  - Updated `docs/ops/INDEX.md` with help usage and library rules.
  - Canonized the docs library policy in `TRUTH.md`.
- Verification:
  - `git diff --name-only`
  - `bash ops/bin/help`
  - `bash ops/bin/help list`
  - `bash ops/bin/help manual`
  - `bash ops/bin/help context-pack`
  - `bash tools/context_lint.sh`
- Risk / rollback:
  - Risk: Low; new helper script and docs/canon updates only.
  - Rollback: delete `ops/bin/help`, revert `docs/library/LIBRARY_INDEX.md`, `docs/ops/INDEX.md`, `TRUTH.md`, and this entry.

## 2026-01-12 — DP-OPS-0012: Hard-code DP + Metadata Kit mechanics (fences, ordering, freshness gate)

- Purpose: Canonize DP + Metadata Kit output mechanics so ordering, fences, and refusal behavior are deterministic.
- What shipped:
  - Added the Output Mechanics Contract to `TRUTH.md`.
  - Updated `SoP.md`.
- Verification:
  - `git diff --name-only`
  - `rg -n "Output Mechanics Contract" TRUTH.md`
  - `sed -n '1,80p' SoP.md`
- Risk / rollback:
  - Risk: Low; canon text only.
  - Rollback: revert `TRUTH.md` and `SoP.md`.
## 2026-01-12 — DP-OPS-0011: Anti-Drift Guardrail (Model Refusal Rules)

- Purpose: Eliminate conversational drift and enforce deterministic refusal when required state, structure, or approvals are missing.
- What shipped:
  - Added the Model Behavior Guardrail (Anti-Drift) canon section to `TRUTH.md`.
  - Codified hard refusal rules for state binding, DP emission order, Metadata Kit approval, copy surface integrity, and no silent creativity.
- Verification:
  - Manual review of `TRUTH.md` and this entry.
- Risk / rollback:
  - Risk: Low; canon text update only.
  - Rollback: revert `TRUTH.md` and this entry.

## 2026-01-12 — DP-OPS-0009: Snapshot tool tightening v1.1

- Purpose: Keep ICL snapshots paste-sized with deterministic truncation and add optional file output.
- What shipped:
  - Added `--max-lines` with scope defaults, per-file truncation markers, and header counts.
  - Capped `SoP.md` to the top 15 entries for ICL snapshots.
  - Added `--out=auto` for snapshot file output and updated snapshot pointers.
- Verification:
  - `git diff --name-only`
  - `bash ops/bin/dump --scope=icl --format=chatgpt | head -n 80`
  - `bash ops/bin/dump --scope=icl --format=chatgpt | tail -n 40`
  - `bash ops/bin/dump --scope=icl --format=chatgpt --max-lines=50 | head -n 120`
  - `bash ops/bin/dump --scope=icl --format=chatgpt --out=auto`
  - `ls -la storage/dumps/ | tail -n 20`
  - `bash ops/bin/open --intent="dp-ops-0009 test" --dp="DP-OPS-0009 / 2026-01-12" | head -n 180`
  - `bash tools/context_lint.sh`
- Risk / rollback:
  - Risk: Truncation may hide needed detail if the cap is too low.
  - Rollback: revert `ops/bin/dump`, `ops/bin/open`, and `ops/init/icl/context_pack.json`.

## 2026-01-12 — DP-OPS-0008: Internal repo snapshot tool v1

- Purpose: Bring repo snapshot generation in-house as `ops/bin/dump` and wire it into the ICL front door.
- What shipped:
  - Added `ops/bin/dump` with scope/format flags and deterministic output.
  - Updated `ops/bin/open` to point to snapshot for full repo context.
  - Added snapshot pointer to `ops/init/icl/context_pack.json`.
  - Added snapshot mention to `ops/init/icl/CONTEXT_PACK.md`.
  - Added repo2txt inspiration note to `TRUTH.md`.
- Verification:
  - `git diff --name-only`
  - `ls -la ops/bin/dump`
  - `bash ops/bin/dump --scope=icl --format=chatgpt | head -n 120`
  - `bash ops/bin/dump --scope=icl --format=chatgpt | tail -n 40`
  - `bash ops/bin/dump --scope=full --format=chatgpt | head -n 60`
  - `bash ops/bin/open --intent="dp-ops-0008 test" --dp="DP-OPS-0008 / 2026-01-12" | head -n 160`
  - `bash tools/context_lint.sh`
- Risk / rollback:
  - Risk: snapshot scope or exclude list may need tuning for size.
  - Rollback: delete `ops/bin/dump` and revert the pointer updates.

## 2026-01-11 — DP-OPS-0007: Doc/ops room cleanup + canon consolidation

- Purpose: Remove redundant doc/ops stubs and keep canon pointers clean.
- What shipped:
  - Deleted `docs/ops` pointer stubs now covered by ops canon (kept `docs/ops/INDEX.md`).
  - Updated canon references in `SECURITY.md` and `SoP.md`, plus the ICL rename artifacts (later retired).
- Verification:
  - `git diff --name-only`
  - `bash ops/bin/open --intent="dp-ops-0007 test" --dp="DP-OPS-0007 / 2026-01-11" | head -n 140`
  - Legacy close script output (retired).
  - `bash tools/context_lint.sh`
  - `rg -n "docs/ops/" docs/00-INDEX.md docs/** ops/**`
- Risk / rollback:
  - Risk: missed reference to removed stubs.
  - Rollback: restore deleted stubs and revert reference updates.

## 2026-01-11 — DP-OPS-0006B: Dispatch Packet branch requirement

- Purpose: Require explicit branch declaration in all Dispatch Packets.
- What shipped:
  - Updated `SoP.md`.
- Verification:
  - Manual review.
- Risk / rollback:
  - Risk: Low; template-only change.
## 2026-01-11 — DP-OPS-0005: Minimum Operator Effort canon

- Purpose: Codify minimum operator effort and no-editor-nagging guidance in canon.
- What shipped:
  - Updated `TRUTH.md` with the Minimum Operator Effort section.
  - Updated `SoP.md`.
- Verification:
  - `git diff --name-only`
  - `rg -n "Minimum Operator Effort|Focus Rule" TRUTH.md ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`
- Risk / rollback:
  - Risk: Low; canon text update only.
  - Rollback: revert `TRUTH.md` and this entry.

## 2026-01-11 — DP-OPS-0004: Front Door v1 close snapshot

- Purpose: Add a single-command close script that prints a copy-safe session snapshot receipt.
- What shipped:
  - Added the close script to emit the session snapshot.
  - Updated `SoP.md`.
- Verification:
  - `ls -la` (close script; legacy).
  - Legacy close script output (retired).
- Risk / rollback:
  - Risk: Low; new ops helper script only.
  - Rollback: delete the close script and remove this entry.

## 2026-01-11 — DP-OPS-0003: Front Door v2 open prompt

- Purpose: Auto-fill branch + HEAD in the open prompt, add optional intent/DP fields, and codify the Focus Rule.
- What shipped:
  - Updated `ops/bin/open` to Front Door v2 with git auto-detection and new flags.
  - Updated `TRUTH.md` with the Focus Rule (Operator-Led Flow).
  - Updated `SoP.md`.
- Verification:
  - `git diff --name-only`
  - `ls -la ops/bin/open`
  - `bash ops/bin/open | head -n 120`
  - `bash ops/bin/open --intent="test intent" --dp="DP-OPS-0003 / 2026-01-11" | head -n 120`
- Risk / rollback:
  - Risk: Low; ops helper script and canon text update only.
  - Rollback: revert `ops/bin/open`, `TRUTH.md`, and this entry.

## 2026-01-11 — DP-OPS-0002: Front Door v1 open prompt

- Purpose: Add a front door command that prints a ready-to-paste Open Prompt with canon pointers, a freshness gate, and the Metadata Kit instruction.
- What shipped:
  - Added `ops/bin/open` (front door prompt generator).
  - Updated `SoP.md`.
- Verification:
  - `ls -la ops/bin/open`
  - `bash ops/bin/open | head -n 80`
- Risk / rollback:
  - Risk: Low; new ops helper script only.
  - Rollback: delete `ops/bin/open` and remove this entry.

## 2026-01-11 — DP-OPS-0001E: Metadata Kit v1 per-surface copy blocks

- Purpose: Make Metadata Kit v1 copy/paste perfect by giving each surface its own dedicated fenced block; remove branch-name helper line; reduce operator friction.
- What shipped:
  - Updated `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`.
  - Updated `SoP.md`.
- Verification:
  - `git diff --name-only`
- Risk / rollback:
  - Risk: Low; documentation-only adjustments.

## 2026-01-11 — DP-OPS-0001D: Metadata Kit v1 boundary normalization

- Purpose: Normalize template boundaries and codify fence rules for Metadata Kit v1 and DP presentation.
- What shipped:
  - Updated `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`.
  - Updated `SoP.md`.
- Verification:
  - Checked diff scope and scanned for copy-boundary markers and triple-backtick leakage in the template.
  - Verified six metadata surfaces remain in order with ~~~md for markdown fields.
- Risk / rollback:
  - Risk: Low; documentation-only adjustments.

## 2026-01-11 — DP-OPS-0001C: Metadata Kit v1 hygiene + integrator gate

- Purpose: Remove copy-boundary anti-patterns, tighten Metadata Kit v1 hygiene, and codify the Integrator Review Gate.
- What shipped:
  - Updated `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`.
  - Updated `SoP.md`.
- Verification:
  - Doc-only change; reviewed diff.
  - Confirmed no STOP COPYING / COPY EVERYTHING markers or triple-backtick fences in the template.
  - Confirmed six metadata surfaces, correct order, and markdown fences use ~~~md.
- Risk / rollback:
  - Risk: Low; documentation-only adjustments.

## 2026-01-11 — DP-OPS-0001B: Metadata Kit v1 fixups

- Purpose: Fix Metadata Kit v1 so it matches real IDE/GitHub metadata planes; remove sloppy formatting; close governance loop.
- What shipped:
  - Updated `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md` to align metadata surfaces/types/order and clarify tilde fence usage.
  - Updated `SoP.md`.
- Verification:
  - Doc-only change; reviewed diff.
  - Scanned template/protocol for "yaml" misuse; none.
  - Confirmed the kit lists all six surfaces in order with types and no coaching prose inside copy blocks.
- Risk / rollback:
  - Risk: Low; minor wording drift possible as operators adopt the kit.

## 2026-01-11 — delete: delete example screens for template

- deleted shit.

## 2026-01-08 — ICL-002C: resume/open/wake control word

- Purpose: Canonize resume/open/wake as a first-class operator control word with explicit behavior.
- What shipped:
  - Updated `ops/init/protocols/SESSION_CLOSE_PROTOCOL.md`.
  - Updated `ops/init/icl/OCL_OVERVIEW.md`.
  - Updated `SoP.md`.
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/lint_truth.sh` ✅
  - `bash tools/context_lint.sh` ✅
- Risk / rollback:
  - Risk: resume behavior wording may need tuning as control word usage evolves.
  - Rollback: revert the protocol/overview/template updates.

## 2026-01-08 — ICL-002B: output-format unification (contract + protocol + templates)

- Purpose: Unify output-format canon across contract, protocol, and PR template surfaces.
- What shipped:
  - Updated `ops/contracts/OUTPUT_FORMAT_CONTRACT.md`.
  - Updated `ops/init/protocols/OUTPUT_FORMAT_PROTOCOL.md`.
  - Updated `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`.
  - Updated `SoP.md`.
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/lint_truth.sh` ✅
  - `bash tools/context_lint.sh` ✅
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
  - `bash tools/lint_truth.sh` ✅
- Risk / rollback:
  - Risk: precedence and ledger language may need tuning as OCL canon evolves.
  - Rollback: revert the overview/protocol/manifest edits.

## 2026-01-08 — ICL-002A: evacuate /boot to ops and remove /boot

- Purpose: Migrate launch pack artifacts into ops/init and remove the /boot directory.
- What shipped:
  - Moved `boot/active/launch_pack/context_pack.json` to `ops/init/icl/context_pack.json`.
  - Moved `boot/active/launch_pack/README.md` to `ops/init/icl/ICL_CONTINUITY_CORE.md`.
  - Moved `boot/active/launch_pack/ASSISTANT_PROFILE.md` to `ops/init/icl/ASSISTANT_PROFILE.md`.
  - Moved `boot/active/launch_pack/USER_PROFILE.md` to `ops/init/icl/USER_PROFILE.md`.
  - Moved `boot/active/launch_pack/INTEGRATOR_ONBOARDING.md` to `ops/init/icl/deprecated/INTEGRATOR_ONBOARDING.md`.
  - Moved `boot/active/launch_pack/CONTRACTOR_ONBOARDING.md` to `ops/init/icl/deprecated/CONTRACTOR_ONBOARDING.md`.
  - Moved `boot/active/launch_pack/RECOVERY.md` to `ops/init/icl/RECOVERY.md`.
  - Moved `boot/active/launch_pack/principles.md` to `ops/init/icl/principles.md`.
  - Moved `boot/active/launch_pack/canon_snapshot.md` to `ops/init/icl/deprecated/canon_snapshot.md`.
  - Moved `boot/active/launch_pack/active_loops.json` to `ops/init/icl/deprecated/active_loops.json`.
  - Moved `boot/ACTIVE_CONTEXT.md` to `ops/init/icl/ACTIVE_CONTEXT.md`.
  - Moved `boot/BUNDLE_MANIFEST.json` to `ops/init/icl/BUNDLE_MANIFEST.json`.
  - Updated `ops/init/icl/context_pack.json` and `ops/init/icl/ACTIVE_CONTEXT.md` for new launch pack paths.
  - Updated `tools/context_lint.sh` to drop `/boot` path allowance.
  - Updated `docs/README_CONTEXT.md`, `docs/10-QUICKSTART.md`, `docs/30-RELEASE_PROCESS.md`, `docs/SOP_MULTICHAT.md`, `docs/REPO_LAYOUT.md`, `docs/PROJECT_STRUCTURE.md`, and `docs/20-GOVERNANCE.md`.
  - Removed `boot/`.
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/lint_truth.sh` ✅
  - `grep -R "(/boot|boot/|launch_pack|launchpack|DAILY_CONSOLE|console)" -n .` (hit: SoP.md verification line)
- Risk / rollback:
  - Risk: stale references outside scope may still mention /boot.
  - Rollback: restore /boot and revert the ops/docs updates.

## 2026-01-08 — ICL-001K: metadata kit formatting canonized

- Purpose: Canonize metadata kit presentation rules for operator-facing outputs.
- What shipped:
  - Updated `ops/init/icl/OCL_OVERVIEW.md`.
  - Updated `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`.
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/lint_truth.sh` ✅
- Risk / rollback:
  - Risk: formatting rules may require adjustment as metadata kits evolve.
  - Rollback: revert the overview/protocol/template edits.

## 2026-01-07 — ICL-001J: remove deprecated Daily Console template

- Purpose: Remove deprecated Daily Console template now replaced by the session snapshot artifact.
- What shipped:
  - Removed Daily Console template (deprecated; file deleted).
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/lint_truth.sh` ✅
- Risk / rollback:
  - Risk: legacy references may linger outside ops scope.
  - Rollback: restore the template file.

## 2026-01-07 — ICL-001I: Operator Control Words canonized

- Purpose: Canonize operator control words for snapshot, pause/close, and opine-only behavior.
- What shipped:
  - Updated `ops/init/protocols/SESSION_CLOSE_PROTOCOL.md`.
  - Updated `ops/init/manifests/OUTPUT_MANIFEST.md`.
  - Updated `ops/init/icl/OCL_OVERVIEW.md`.
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/lint_truth.sh` ✅
- Risk / rollback:
  - Risk: control word handling may need tuning as OCL evolves.
  - Rollback: revert the protocol/template/manifest/overview edits.

## 2026-01-07 — ICL-001H: session pause/close snapshot artifact

- Purpose: Formalize the OCL pause/close snapshot artifact for durable, resumable sessions.
- What shipped:
  - Added `ops/init/icl/SESSION_SNAPSHOT_OVERVIEW.md`.
  - Added `ops/init/protocols/SESSION_CLOSE_PROTOCOL.md`.
  - Updated `ops/init/manifests/OUTPUT_MANIFEST.md`.
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/lint_truth.sh` ✅
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
  - `bash tools/lint_truth.sh` ✅
- Risk / rollback:
  - Risk: OCL framing or ticket lifecycle may need tuning as ops canon evolves.
  - Rollback: revert the OCL overview and protocol/manifest edits.

## 2026-01-07 — ICL-001E: DP canonized (Work Orders as first-class ICL artifact)

- Purpose: Make Dispatch Packets (DP) the canonical operator-facing work order in ICL.
- What shipped:
  - Added `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`.
  - Updated `ops/init/manifests/OUTPUT_MANIFEST.md` to include DP as a required output type.
- Verification:
  - Not run (worker): `bash tools/verify_tree.sh`
  - Not run (worker): `bash tools/lint_truth.sh`
- Risk / rollback:
  - Risk: DP requirements may need tuning as ops conventions evolve.
  - Rollback: revert the DP protocol/template and the output manifest update.

## 2026-01-07 — ICL-001C: context pruning + drift detection

- Purpose: Reduce long-session decay and detect filesystem drift early during ICL.
- What shipped:
  - Added `ops/init/protocols/CONTEXT_PRUNING_PROTOCOL.md`.
  - Added `tools/context_lint.sh` and updated `ops/init/manifests/CONTEXT_MANIFEST.md`.
- Verification:
  - `bash tools/context_lint.sh` ✅
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/lint_truth.sh` ✅
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
  - `bash tools/lint_truth.sh` ✅
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
- Verification:
  - Not run (worker): `bash tools/verify_tree.sh`
  - Not run (worker): `bash tools/lint_truth.sh`
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
  - Not run (worker): `bash tools/lint_truth.sh`
- Risk / rollback:
  - Risk: docs-only (security guidance changes).
  - Rollback: revert this entry and the docs updates.

## 2026-01-06 — Ops: control room index + precheck (T-OPS-OPS-STREAMLINE)

- Purpose: Make ops docs feel like a control room with a clear start and precheck checklist.
- What shipped:
  - Reworked `docs/ops/INDEX.md` into workflow sections with a drift rule reminder.
  - Added a filled precheck checklist to `ops/init/icl/DAILY_CONSOLE.md`.
- Verification:
  - Not run (worker): `bash tools/verify_tree.sh`
  - Not run (worker): `bash tools/lint_truth.sh`
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
  - `bash tools/lint_truth.sh` ✅
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
  - `grep -r "_meta/" docs/` → hits expected in `docs/SECURE_WEBROOT_OPTION.md` ✅
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/lint_truth.sh` ✅
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
  - bash tools/lint_truth.sh ✅
- Risk / rollback:
  - Risk: docs-only (no runtime behavior changes)
  - Rollback: revert merge commit

## 2026-01-05 — Ops: metadata surfaces templates (T-OPS-METADATA-TEMPLATES)

- Purpose: Institutionalize “Metadata Surfaces (always-on)” templates across PR and contractor workflows.
- What shipped:
  - Hardened contractor dispatch requirements in `ops/contracts/CONTRACTOR_DISPATCH_CONTRACT.md`.
- Verification:
  - grep -r "Guerrilla" docs/ .github/ (no matches)
  - bash tools/verify_tree.sh ✅
  - bash tools/lint_truth.sh ✅
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
  - grep -r "_meta/" docs/ (hits in `docs/SECURE_WEBROOT_OPTION.md`)
  - grep -r "launch_pack_v2" docs/ (no matches)
  - grep -r "src/" docs/ README.md CONTRIBUTING.md (hits in `docs/upstreams.md`, `docs/NUKESECURITY_VISION_TO_IMPLEMENTATION_MAP.md`, `docs/GEOIP_IMPORTER.md`, `docs/triage/_archive/SUBSYSTEM_MAP_v11.md`, `docs/triage/_archive/SECURITY_SURFACE_SWEEP_v11.md`, `docs/repo-nomenclature.md`)
  - bash tools/verify_tree.sh ✅
  - bash tools/lint_truth.sh ✅
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
  - grep -r "_meta/" docs/ (hits in `docs/SECURE_WEBROOT_OPTION.md`)
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
  - bash tools/lint_truth.sh ✅
- Risk / rollback:
  - Risk: link-rot in moved docs or missed references.
  - Rollback: revert merge commit

## 2026-01-05 — Docs: contractor dispatch brief (canonize worker dispatch)

- Purpose: Canonize contractor dispatch rules so every PR follows governance + metadata requirements.
- What shipped:
  - Added `ops/contracts/CONTRACTOR_DISPATCH_CONTRACT.md` to formalize dispatch rules and cadence.
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
- Added triage capture lane: `docs/triage/INBOX.md`.
- Updated docs indexes to keep ops + triage discoverable.

### Notes / Decisions
- Doctrine: “Every PR is self-documenting and nothing gets forgotten.”
- Forward-only metadata discipline: we don’t backfill old PR bodies unless it’s actively hurting us.

# State of Play — 2026-01-03

## Completed
- Docs Family v1 integrated + canon spine created (docs/00-INDEX, 10-QUICKSTART, 20-GOVERNANCE, 30-RELEASE_PROCESS, 40-PROJECT_HYGIENE)
- Added Copilot onboarding rules: .github/copilot-instructions.md
- Added SSOT “save-game” handover file: ops/init/icl/AI_CONTEXT_SYNC.md
- Enabled FAIL-mode policing: canon changes require SoP update in the same PR
- Updated ops/init/icl/DAILY_CONSOLE.md to clarify canon vs log vs rehydration.
- Added ops governance docs: OUTPUT_FORMAT_CONTRACT + Copilot onboarding + Gemini onboarding
- Updated docs/ops/INDEX.md + docs/00-INDEX.md to link the new ops docs
- Standardized TRUTH.md Section 3 bullets for docs/ops/, upstream/, and .github/workflows/ to clarify roles
- 2026-01-03: Canonized Output Formatting Contract (ops/contracts/OUTPUT_FORMAT_CONTRACT.md) and linked it in docs indexes.

## Active blockers
- repo-gates (FAIL-mode) blocking PR until this SoP update is committed + pushed

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
  - Added `ops/init/icl/DAILY_CONSOLE.md`, `ops/init/icl/AI_CONTEXT_SYNC.md`, `ops/init/icl/CONTEXT_PACK.md`, `ops/init/icl/deprecated/COPILOT_ONBOARDING.md`, `ops/init/icl/deprecated/GEMINI_ONBOARDING.md`, `ops/init/icl/deprecated/IDE_MIGRATION.md`.
  - Updated `ops/init/icl/RECOVERY.md` and `ops/init/icl/ICL_CONTINUITY_CORE.md`.
  - Updated `ops/contracts/OUTPUT_FORMAT_CONTRACT.md`, `ops/contracts/CONTRACTOR_DISPATCH_CONTRACT.md`, and `ops/init/protocols/SAVE_THIS_PROTOCOL.md`.
  - Updated `ops/init/icl/context_pack.json` for the new ops canon pointers.
  - Converted docs/ops duplicates into pointer stubs and refreshed `docs/ops/INDEX.md`.
  - Updated `TRUTH.md Section 3`, `TRUTH.md Section 2`, and docs indexes/references (`docs/00-INDEX.md`, `docs/10-QUICKSTART.md`, `docs/CONTRACTOR_PACKET.md`, `docs/REPO_LAYOUT.md`, `docs/PROJECT_STRUCTURE.md`, `docs/20-GOVERNANCE.md`, `docs/README_CONTEXT.md`, `docs/security/README.md`).
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/lint_truth.sh` ✅
  - `bash tools/context_lint.sh` ✅
  - `bash ops/init/pack.sh --help` ✅
  - `grep -R \"(boot/|/boot|console|DAILY_CONSOLE|launch_pack|launchpack)\" -n .` ✅
- Risk / rollback:
  - Risk: stale references if any downstream doc still expects docs/ops full content.
  - Rollback: restore prior docs/ops content and revert ops/doc pointer updates.
## 2026-01-09 - DP-ICL-002D1: freshness gate canonized

- Purpose: Require a Freshness Gate in Dispatch Packets to block stale context before work begins.
- What shipped:
  - Updated `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`.
  - Updated `SoP.md`.
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/lint_truth.sh` ✅
  - `bash tools/context_lint.sh` ✅
- Risk / rollback:
  - Risk: stricter DP gating may slow work starts if operator-provided truth is stale.
  - Rollback: revert the DP protocol/template changes.
## 2026-01-09 - DP-ICL-002D3-CLEAN: Freshness Gate proceed-on-match + template stop-marker removal

- Purpose: Clarify Freshness Gate proceed-on-match behavior and remove internal stop markers from the DP template.
- What shipped:
  - Updated `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`.
  - Updated `SoP.md`.
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/lint_truth.sh` ✅
  - `bash tools/context_lint.sh` ✅
- Risk / rollback:
  - Risk: operators may miss the queue stop rule if they only scan the top of the template.
  - Rollback: revert the protocol/template edits.
## 2026-01-09 - DP-ICL-002D4: DP template hygiene + SoP compliance

- Purpose: Ensure the DP template contains zero "STOP COPYING" lines and log the compliance update.
- What shipped:
  - Updated `SoP.md`.
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/lint_truth.sh` ✅
  - `bash tools/context_lint.sh` ✅
- Risk / rollback:
  - Risk: operators may rely on the DP template for footer phrasing cues.
  - Rollback: revert the DP template and SoP entry.
## 2026-01-09 - DP-ICL-002E0: Process lock for TYPE LINE BY LINE + paste surfaces

- Purpose: Standardize operator command safety language, paste surfaces, and DP freshness gate rules.
- What shipped:
  - Updated `ops/contracts/OUTPUT_FORMAT_CONTRACT.md`.
  - Updated `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`.
  - Added `ops/init/icl/PASTE_SURFACES_PLAYBOOK.md`.
  - Updated `docs/ops/INDEX.md`.
  - Updated `SoP.md`.
- Verification:
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/lint_truth.sh` ✅
  - `bash tools/context_lint.sh` ✅
- Risk / rollback:
  - Risk: operators may need time to adapt to TYPE LINE BY LINE command blocks.
  - Rollback: revert the protocol, template, and playbook updates.
## 2026-01-09 - DP-ICL-002E1: banned terms inventory + rename plan drafted

- Purpose: Capture banned-term inventory and draft a rename plan for ICL/OCL artifacts.
- What shipped:
  - Added ICL banned-terms map (later retired).
  - Added ICL/OCL rename plan (later retired).
  - Updated `docs/ops/INDEX.md`.
  - Updated `SoP.md`.
- Verification:
  - `grep -RinE "(recovery|launchpack|launch_pack|console|precheck)" ops docs *.md 2>/dev/null || true` ✅
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/lint_truth.sh` ✅
- Risk / rollback:
  - Risk: large rename PRs can break links and references if not updated in lockstep.
  - Rollback: revert the inventory/plan docs and redo with a narrower rename scope.
## 2026-01-09 - DP-ICL-002E3: launch pack rename fixups

- Purpose: Stabilize the launch pack rename by clearing remaining drift markers and confirming pointer correctness.
- What shipped:
  - Added ICL rename fixups note (later retired).
  - Updated `SoP.md` verification language to avoid banned-term drift.
- Verification:
  - Banned-term sweep grep (per ICL rename fixups note) ✅
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/lint_truth.sh` ✅
- Risk / rollback:
  - Risk: lingering legacy references outside the planning docs could still surface later.
  - Rollback: revert this entry and re-run the drift sweep.
## 2026-01-18 - DP-OPS-0043: Project Registry v1 (minimal womb + registration)

- Purpose: Introduce a minimal project registry SSOT and a guarded init flow for STELA-born projects.
- What shipped:
  - Added `storage/PROJECT_REGISTRY.md` and pointers in `TRUTH.md`.
  - Added `ops/bin/project`, `ops/lib/project/`, and `ops/init/projects/` scaffolds.
  - Added `projects/README.md` and updated `docs/library/OPERATOR_MANUAL.md`.
- Verification:
  - `bash tools/context_lint.sh` ✅
  - `bash tools/lint_truth.sh` ✅
  - `./ops/bin/project list` ✅
  - `./ops/bin/project current` ✅
  - `./ops/bin/project init demo --dry-run` ✅
- Risk / rollback:
  - Risk: Medium-low (new subsystem surface area).
  - Rollback: revert the FILES touched.
## 2026-01-24 — DP-OPS-001: Stela Initialization & Scope Repair

- Purpose: Reset canon + scope boundaries, move the registry into ops, and align platform dump behavior.
- What shipped:
  - Updated `ops/bin/dump` platform scope to include `projects/README.md` while excluding other project payloads.
  - Rebuilt `TRUTH.md` from CONTEXT/CANONICAL_TREE/PROJECT_MAP and removed the source files.
  - Moved project registry to `storage/PROJECT_REGISTRY.md` and removed legacy datasets/templates.
  - Updated references in `docs/library/OPERATOR_MANUAL.md`, `docs/library/CONTINUITY_MAP.md`, `docs/ops/INDEX.md`, `ops/lib/project/`, and `ops/bin/help`.
  - Reset `TASK.md` to the new dashboard template.
- Verification:
  - `bash tools/context_lint.sh`
  - Result: `[context_lint] Result: warnings detected` (missing paths referenced in SoP.md).
  - `bash tools/lint_truth.sh`
  - Result: `[lint_truth] OK`
  - `./ops/bin/dump --scope=platform --format=chatgpt --max-lines=1 --out=auto --bundle`
  - Result:
    - `Dump payload: ./storage/dumps/dump-platform-ops-stela-boot-v1-b953fba1.txt`
    - `Dump tarball: ./storage/dumps/dump-platform-ops-stela-boot-v1-b953fba1.tar.xz`
    - `Dump manifest: ./storage/dumps/dump-platform-ops-stela-boot-v1-b953fba1.manifest.txt`
  - `rg -n "^- projects/" storage/dumps/dump-platform-ops-stela-boot-v1-b953fba1.manifest.txt`
  - Result: `- projects/README.md`
- Risk / rollback:
  - Risk: Medium (canon reshaping + template removal could break legacy references).
  - Rollback: restore deleted files and revert the touched scripts/docs.
