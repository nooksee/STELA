## 2026-01-16 — DP-OPS-0035: RECEIPT rename + DP Risk / Rollback requirement

- Purpose: Rename the worker-results bundle to RECEIPT, require Risk / Rollback in DP format, and reinforce OPEN + SNAPSHOT as the rehydration milestone.
- What shipped:
  - Replaced the legacy bundle label with RECEIPT across canon, protocol, template, and operator guidance.
  - Added Risk / Rollback as a required DP section and updated the DP template.
  - Updated worker-result rejection language to use RECEIPT.
- Verification:
  - `rg -n "### RECEIPT|RECEIPT" PROJECT_TRUTH.md ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md ops/templates/DISPATCH_PACKET_TEMPLATE.md docs/library/OPERATOR_MANUAL.md`
  - `rg -n "Risk / Rollback" ops/templates/DISPATCH_PACKET_TEMPLATE.md PROJECT_TRUTH.md`
  - `bash ops/init/tools/context_lint.sh`
- Risk / rollback:
  - Risk: Medium-low; doc/template rename could break operator expectations if any old label lingers.
  - Rollback: revert the touched files and restore the previous label and DP template section ordering.

## 2026-01-16 — DP-OPS-0034: Root AI entry points (llms.txt + AGENTS.md)

- Purpose: Add repo-root AI entry points that map existing canon without duplication.
- What shipped:
  - Added `llms.txt` as a pointer map into canon and tools.
  - Added `AGENTS.md` as a pointer-first agent constitution.
  - Declared the entry points in `PROJECT_TRUTH.md`.
- Verification:
  - `test -f llms.txt`
  - `test -f AGENTS.md`
  - `rg -n "llms\\.txt|AGENTS\\.md" PROJECT_TRUTH.md`
  - `bash ops/init/tools/context_lint.sh`
- Risk / rollback:
  - Risk: Low; docs-only pointer additions.
  - Rollback: delete `llms.txt` and `AGENTS.md`, revert `PROJECT_TRUTH.md`, and remove this entry.

## 2026-01-15 — DP-OPS-0033: ICL Continuity Core + legacy onboarding retirement

- Purpose: Define the ICL Continuity Core, retire the legacy onboarding directory, and triage ICL continuity files.
- What shipped:
  - Added `ops/init/icl/ICL_CONTINUITY_CORE.md` and wired it into `PROJECT_TRUTH.md`, the continuity map, and the docs library.
  - Moved core continuity files into `ops/init/icl/` and updated references across ops/docs.
  - Moved legacy onboarding files into `ops/init/icl/deprecated/` with deprecation notices.
  - Removed obsolete ICL rename artifacts and the legacy onboarding folder stub.
  - Updated `ops/bin/open`, `ops/bin/snapshot`, and `ops/init/icl/context_pack.json` for the new core paths.
- Verification:
  - `rg -n "launch_pack" ops/`
  - `git diff --name-only`
  - `bash ops/init/tools/context_lint.sh`
- Risk / rollback:
  - Risk: missed pointer update could break operator wayfinding.
  - Rollback: revert the touched files and restore the prior ICL layout.

## 2026-01-15 — DP-OPS-0032: Continuity map + supersession hygiene

- Purpose: Make continuity surfaces findable; canonize supersession/deprecation/deletion proposals; add a later bucket label.
- What shipped:
  - Added `docs/library/CONTINUITY_MAP.md` and wired it into the curated library and Operator Manual.
  - Canonized supersession/deprecation/deletion proposal rules in `PROJECT_TRUTH.md`.
  - Added a required "Supersession / Deletion candidates" callout to `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md` and `ops/templates/DISPATCH_PACKET_TEMPLATE.md`.
  - Added a "Later bucket" section in `STATE_OF_PLAY.md` for dedupe / clone detection ideas.
- Verification:
  - `rg -n "Continuity Map|CONTINUITY_MAP|supersession|deprecation|proposal-only|Later bucket" PROJECT_TRUTH.md docs/library/OPERATOR_MANUAL.md ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md ops/templates/DISPATCH_PACKET_TEMPLATE.md docs/library/LIBRARY_INDEX.md`
  - `bash ops/init/tools/context_lint.sh`
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
  - Added short notes about the posture nudge in `PROJECT_TRUTH.md` and `docs/library/OPERATOR_MANUAL.md`.
- Verification:
  - `rg -n "canon-governed system|Precision beats speed|If unsure, stop and ask" ops/bin/open PROJECT_TRUTH.md docs/library/OPERATOR_MANUAL.md`
  - `bash ops/init/tools/context_lint.sh`
  - Manual check: OPEN output shows the 3-line block above [FRESHNESS GATE] with no other changes.
- Risk / rollback:
  - Risk: Low; output text + docs note only.
  - Rollback: revert `ops/bin/open`, `PROJECT_TRUTH.md`, `docs/library/OPERATOR_MANUAL.md`, and this entry.

## 2026-01-15 — DP-OPS-0031: MEMENTOS strategic placement

- Purpose: Place a small set of inference-timed MEMENTOS and pointers without duplication.
- What shipped:
  - Added a MEMENTO index and updated placement references in `docs/library/MEMENTOS.md`.
  - Added MEMENTO pointer references in `ops/bin/open`, `ops/templates/DISPATCH_PACKET_TEMPLATE.md`, `docs/library/OPERATOR_MANUAL.md`, and `docs/library/datasets/DB-PR-META.md`.
- Verification:
  - `rg -n "MEMENTO: M-" ops/bin/open ops/templates/DISPATCH_PACKET_TEMPLATE.md docs/library/OPERATOR_MANUAL.md docs/library/datasets/DB-PR-META.md`
  - `rg -n "M-ATTN-01|M-COMMIT-01|M-HANDOFF-01|M-EMIT-01" docs/library/MEMENTOS.md`
  - `git diff --name-only`
- Risk / rollback:
  - Risk: Low; docs-only pointer/index changes.
  - Rollback: revert `docs/library/MEMENTOS.md`, `ops/bin/open`, `ops/templates/DISPATCH_PACKET_TEMPLATE.md`, `docs/library/OPERATOR_MANUAL.md`, `docs/library/datasets/DB-PR-META.md`, and this entry.

## 2026-01-15 — DP-OPS-0029: Approval prefix + delimiter for chat UI paste

- Purpose: Fix "approval lost in paste" by canonizing approval-prefix + delimiter for same-message paste.
- What shipped:
  - Added start-of-message approval + delimiter rule and chat-UI fallback to `PROJECT_TRUTH.md`, `docs/library/datasets/DB-PR-META.md`, and `docs/library/OPERATOR_MANUAL.md`.
  - Updated operator handoff paste order to include the delimiter rule in `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md` and `ops/templates/DISPATCH_PACKET_TEMPLATE.md`.
  - Updated refusal text to return a paste-ready approval + delimiter example in `PROJECT_TRUTH.md` and `docs/library/datasets/DB-PR-META.md`.
- Verification:
  - `rg -n "approval|APPROVE|Handoff Paste Order|delimiter|---" PROJECT_TRUTH.md docs/library/datasets/DB-PR-META.md docs/library/OPERATOR_MANUAL.md ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md ops/templates/DISPATCH_PACKET_TEMPLATE.md`
  - Manual check: all docs agree on approval pattern, start-of-message requirement, delimiter rule, and paste order.
  - `git diff --name-only`
  - `bash ops/init/tools/context_lint.sh`
- Risk / rollback:
  - Risk: Low; docs-only canon update.
  - Rollback: revert the touched docs and this entry.

## 2026-01-14 — DP-OPS-0028: Behavioral preferences placement + operator wayfinding

- Purpose: Define the single source of truth for behavioral preferences and make wayfinding pointer-only.
- What shipped:
  - Added the behavioral preferences file in the curated library.
  - Added pointer-only links in `PROJECT_TRUTH.md`, `docs/library/OPERATOR_MANUAL.md`, and `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`.
  - Removed legacy dataset and manifest entries for behavioral preferences.
- Verification:
  - `ls docs/library`
  - `rg -n "Behavioral preferences are documented" PROJECT_TRUTH.md docs/library/OPERATOR_MANUAL.md ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`
  - `bash ops/init/tools/context_lint.sh`
- Risk / rollback:
  - Risk: Low; docs-only canon update.
  - Rollback: delete the behavioral preferences file and remove the pointer lines.

## 2026-01-14 — DP-OPS-0027: Approval line placement + handoff paste order

- Purpose: Stop "approval lost in the paste" by canonizing standalone approval line placement and deterministic handoff paste order.
- What shipped:
  - Canonized "Approval Line Placement" (standalone, outside OPEN/intent/quotes) in `PROJECT_TRUTH.md`.
  - Canonized "Operator Handoff Paste Order" (1. Approval, 2. Results, 3. Snapshot) in `PROJECT_TRUTH.md` and `docs/library/OPERATOR_MANUAL.md`.
  - Wired new rules into `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`, `ops/templates/DISPATCH_PACKET_TEMPLATE.md`, and `docs/library/datasets/DB-PR-META.md`.
- Verification:
  - `rg -n "Approval line|standalone|APPROVE DP-OPS-|Handoff paste order" PROJECT_TRUTH.md docs/library/OPERATOR_MANUAL.md ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md ops/templates/DISPATCH_PACKET_TEMPLATE.md docs/library/datasets/DB-PR-META.md`
  - Manual check: rules explicitly forbid approvals inside OPEN intent and inside quoted/fenced blocks.
  - `git diff --name-only`
  - `bash ops/init/tools/context_lint.sh`
- Risk / rollback:
  - Risk: Low; docs-only canon update.
  - Rollback: revert `PROJECT_TRUTH.md`, `docs/library/OPERATOR_MANUAL.md`, `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`, `ops/templates/DISPATCH_PACKET_TEMPLATE.md`, `docs/library/datasets/DB-PR-META.md`, and this entry.

## 2026-01-14 — DP-OPS-0026: Operator approval + paste contract lock

- Purpose: Lock the operator approval + paste contract so approval, paste order, and DB-PR-META emission are deterministic.
- What shipped:
  - Canonized operator approval + paste contract requirements (plain text approval, raw paste, snapshot attachment, quoted blocks invalid) in `PROJECT_TRUTH.md`.
  - Documented the exact operator paste order in `docs/library/OPERATOR_MANUAL.md`.
  - Added the operator approval + paste contract notes to `ops/templates/DISPATCH_PACKET_TEMPLATE.md` and `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`.
- Verification:
  - `rg -n "APPROVE DP-" PROJECT_TRUTH.md`
  - Manual check: `docs/library/OPERATOR_MANUAL.md` documents the exact paste order.
  - Manual check: `ops/templates/DISPATCH_PACKET_TEMPLATE.md` includes the approval contract note.
  - `git diff --name-only`
  - `bash ops/init/tools/context_lint.sh`
- Risk / rollback:
  - Risk: Low; docs-only canon + template/protocol updates.
  - Rollback: revert `PROJECT_TRUTH.md`, `docs/library/OPERATOR_MANUAL.md`, `ops/templates/DISPATCH_PACKET_TEMPLATE.md`, `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`, and this entry.

## 2026-01-14 — DP-OPS-0025: DB-PR-META approval phrase canon + DP template/protocol wiring

- Purpose: Canonize the IN-LOOP DB-PR-META approval phrase pattern with DP-ID + EMIT, and wire it into the DP protocol/template and operator docs.
- What shipped:
  - Updated DB-PR-META approval gating and refusal line in `PROJECT_TRUTH.md` and `docs/library/datasets/DB-PR-META.md`.
  - Added the approval phrase line + emission reminder to `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md` and `ops/templates/DISPATCH_PACKET_TEMPLATE.md`.
  - Added a short "How to approve" snippet in `docs/library/OPERATOR_MANUAL.md`.
- Verification:
  - `rg -n "APPROVE|EMIT DB-PR-META|Approval phrase" PROJECT_TRUTH.md ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md ops/templates/DISPATCH_PACKET_TEMPLATE.md docs/library/OPERATOR_MANUAL.md docs/library/datasets/DB-PR-META.md`
  - Manual check: `PROJECT_TRUTH.md` includes the required approval pattern, refusal paste-line, and the canonical 1-6 DB-PR-META order.
  - `bash ops/init/tools/context_lint.sh`
  - `git diff --name-only`
- Risk / rollback:
  - Risk: Low; docs-only canon + template updates.
  - Rollback: revert `PROJECT_TRUTH.md`, `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`, `ops/templates/DISPATCH_PACKET_TEMPLATE.md`, `docs/library/OPERATOR_MANUAL.md`, `docs/library/datasets/DB-PR-META.md`, and this entry.

## 2026-01-14 — DP-OPS-0024: Approval gate robustness + snapshot/OPEN decision

- Purpose: Make DB-PR-META approval recoverable with tolerant phrasing and paste-ready refusal, and document snapshot/OPEN handling.
- What shipped:
  - Added acceptable DB-PR-META approval phrases and paste-ready refusal text in `PROJECT_TRUTH.md` and `docs/library/datasets/DB-PR-META.md`.
  - Updated `docs/library/OPERATOR_MANUAL.md` to list approval phrases and document that snapshots do not include OPEN output.
- Verification:
  - `rg -n "Approval not given|DB-PR-META|approval phrase" PROJECT_TRUTH.md docs/library/OPERATOR_MANUAL.md docs/library/datasets/DB-PR-META.md`
  - Manual check: near-miss approval refusals include the paste-ready phrase.
  - `bash ops/init/tools/context_lint.sh`
  - `git diff --name-only`
- Risk / rollback:
  - Risk: Low; canon/docs-only wording updates.
  - Rollback: revert `PROJECT_TRUTH.md`, `docs/library/datasets/DB-PR-META.md`, `docs/library/OPERATOR_MANUAL.md`, and this entry.

## 2026-01-14 — DP-OPS-0023: Bias artifacts canon + library wiring

- Purpose: Convert source texts into a canonical bias artifacts doc and wire it into the curated library with preferences-not-permissions defined.
- What shipped:
  - Added a bias artifacts dataset doc and library entries.
  - Added a pointer in the operator manual.
  - Defined bias artifacts in Project Truth.
- Verification:
  - `rg -n "bias artifacts" PROJECT_TRUTH.md docs/library/OPERATOR_MANUAL.md docs/library/LIBRARY_INDEX.md`
  - `bash ops/bin/help list`
  - `bash ops/init/tools/context_lint.sh`
- Risk / rollback:
  - Risk: Low; docs-only canon update.
  - Rollback: revert the touched docs and this entry.

## 2026-01-14 — DP-OPS-0022: Lock DB-PR-META UI mapping (order + payload types)

- Purpose: Lock the UI-to-DB-PR-META surface mapping with explicit order, UI field references, and payload types (plain text vs Markdown).
- What shipped:
  - Updated DB-PR-META UI mapping lines to use the GitHub UI field labels (Add a title, Add a description, merge dialog labels, Add a comment) with explicit payload types in `PROJECT_TRUTH.md` and `docs/library/datasets/DB-PR-META.md`.
- Verification:
  - `rg -n "DB-PR-META surfaces" PROJECT_TRUTH.md`
  - `rg -n "DB-PR-META" PROJECT_TRUTH.md docs/library/datasets/DB-PR-META.md docs/library/OPERATOR_MANUAL.md docs/library/LIBRARY_INDEX.md STATE_OF_PLAY.md`
  - Manual check: UI order matches IDE "Commit message" (plain text, one line), GitHub PR "Add a title" (plain text, one line), GitHub PR "Add a description" (Markdown), GitHub merge "Commit message" (plain text, one line), GitHub merge "Extended description" (plain text, body), GitHub PR "Add a comment" (Markdown).
  - `git diff --name-only`
  - `bash ops/init/tools/context_lint.sh`
- Risk / rollback:
  - Risk: Low; docs-only wording updates.
  - Rollback: revert `PROJECT_TRUTH.md`, `docs/library/datasets/DB-PR-META.md`, `docs/library/OPERATOR_MANUAL.md`, and this entry.

## 2026-01-13 — DP-OPS-0021: Lock DB-PR-META surfaces + anti-slop style + operator-idiom guardrail

- Purpose: Lock DB-PR-META surface labels/format, add anti-slop micro-style, and prevent canonizing operator idioms; add dataset entry.
- What shipped:
  - Canonized DB-PR-META surface names, output format, and style in `PROJECT_TRUTH.md`.
  - Added operator-idiom canonization guardrails in `PROJECT_TRUTH.md`.
  - Added the DB-PR-META dataset doc and wired it into the curated library.
- Verification:
  - `git diff --name-only`
  - `rg -n "DB-PR-META" PROJECT_TRUTH.md docs/library/datasets/DB-PR-META.md docs/library/LIBRARY_INDEX.md docs/library/OPERATOR_MANUAL.md STATE_OF_PLAY.md`
  - Manual check: DB-PR-META section lists the six exact surface names.
  - `bash ops/init/tools/context_lint.sh`
- Risk / rollback:
  - Risk: Low; docs-only wording updates.
  - Rollback: revert `PROJECT_TRUTH.md`, `docs/library/datasets/DB-PR-META.md`, `docs/library/LIBRARY_INDEX.md`, `docs/library/OPERATOR_MANUAL.md`, and this entry.

## 2026-01-13 — DP-OPS-0020: Require Worker RECEIPT (OPEN + SNAPSHOT)

- Purpose: Require workers to end every DP result with the RECEIPT containing OPEN output plus SNAPSHOT output, and treat omission as a hard failure.
- What shipped:
  - Updated the RECEIPT definition and rejection rule in `PROJECT_TRUTH.md`.
  - Updated the DP protocol and DP template to mandate the new RECEIPT headings and rule.
  - Updated `docs/library/OPERATOR_MANUAL.md` to match the new RECEIPT format.
- Verification:
  - `rg -n "RECEIPT" ops/templates/DISPATCH_PACKET_TEMPLATE.md`
  - `rg -n "RECEIPT" ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`
  - Manual check: RECEIPT appears at end of DP template.
  - `git diff --name-only`
- Risk / rollback:
  - Risk: Low; docs-only wording updates.
  - Rollback: revert `PROJECT_TRUTH.md`, `ops/templates/DISPATCH_PACKET_TEMPLATE.md`, `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`, `docs/library/OPERATOR_MANUAL.md`, and this entry.

## 2026-01-13 — DP-OPS-0019: Worker RECEIPT canon

- Purpose: Require workers to end every DP result with a full RECEIPT (OPEN output, status, last commit; optional snapshot pointer).
- What shipped:
  - Canonized the RECEIPT requirement in `PROJECT_TRUTH.md`.
  - Updated the DP protocol, DP template, and Operator Manual with copy-ready RECEIPT headings and end-of-message rule.
- Verification:
  - `rg -n "RECEIPT" PROJECT_TRUTH.md ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md ops/templates/DISPATCH_PACKET_TEMPLATE.md docs/library/OPERATOR_MANUAL.md`
  - `git diff --name-only`
- Risk / rollback:
  - Risk: Low; docs-only change.
  - Rollback: revert the touched docs/templates and this entry.

## 2026-01-13 — DP-OPS-0018: DB-PR-META rename + Freshness Gate evidence requirement

- Purpose: Normalize operator-facing kit terminology to DB-PR-META and require Freshness Gate evidence in worker outputs.
- What shipped:
  - Renamed kit references to DB-PR-META across canon, templates, and protocols (approval phrase included).
  - Updated the Open Prompt and Operator Manual to reflect DB-PR-META naming.
  - Required worker outputs to include OPEN output, `git status --porcelain`, and `git log -1 --oneline`, with a hard stop if repo access is unavailable.
- Verification:
  - `git diff --name-only`
  - `rg -n "DB-PR-META" PROJECT_TRUTH.md docs/library/OPERATOR_MANUAL.md ops/** STATE_OF_PLAY.md`
  - `bash ops/init/tools/context_lint.sh`
- Risk / rollback:
  - Risk: Low; wording-only changes.
  - Rollback: revert the touched docs/templates and this entry.

## 2026-01-13 — DP-OPS-0017: DB-DATASET system + DB-VOICE-0001 (Declarative Mode)

- Purpose: Introduce a manifest-only DB-DATASET library and seed DB-VOICE-0001 (Declarative Mode).
- What shipped:
  - Added DB-DATASET and DB-VOICE-0001 dataset docs under `docs/library/datasets/`.
  - Added dataset topics to `docs/library/LIBRARY_INDEX.md` and updated curated-surface docs.
  - Canonized DB-DATASET and IN-LOOP meaning in `PROJECT_TRUTH.md`.
- Verification:
  - `git diff --name-only`
  - `bash ops/bin/help list`
  - `bash ops/bin/help db-dataset`
  - `bash ops/bin/help db-voice-0001`
  - `bash ops/init/tools/context_lint.sh`
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
  - Added optional tar.xz archive output for `ops/bin/snapshot` (no default behavior changes).
  - Added `docs/library/OPERATOR_MANUAL.md` with a top-commands cheat sheet and archive usage.
  - Updated `docs/library/LIBRARY_INDEX.md` and `docs/ops/INDEX.md` to point to the new manual.
- Verification:
  - `git diff --name-only`
  - `bash tools/verify_tree.sh`
  - `bash ops/init/tools/context_lint.sh`
  - `bash ops/bin/snapshot --scope=icl --format=chatgpt | head -n 40`
  - `bash ops/bin/snapshot --scope=icl --format=chatgpt --out=auto`
  - `bash ops/bin/snapshot --scope=icl --format=chatgpt --out=auto --compress=tar.xz`
  - `bash ops/bin/snapshot --scope=icl --format=chatgpt --out=auto.tar.xz`
  - `ls -la storage/snapshots/ | tail -n 20`
  - `tar -tf storage/snapshots/<newfile>.tar.xz | head`
  - `bash ops/bin/help list`
  - `bash ops/bin/help manual`
- Risk / rollback:
  - Risk: Low; new optional output path and docs only.
  - Rollback: revert `ops/bin/snapshot`, remove `docs/library/OPERATOR_MANUAL.md`, revert `docs/library/LIBRARY_INDEX.md`, `docs/ops/INDEX.md`, and this entry.

## 2026-01-13 — DP-OPS-0013: Help front door + curated docs library

- Purpose: Add a docs reader front door and formalize the curated docs library surface.
- What shipped:
  - Added `ops/bin/help` with manifest-only access and pager output.
  - Added `docs/library/LIBRARY_INDEX.md` as the curated docs manifest.
  - Updated `docs/ops/INDEX.md` with help usage and library rules.
  - Canonized the docs library policy in `PROJECT_TRUTH.md`.
- Verification:
  - `git diff --name-only`
  - `bash ops/bin/help`
  - `bash ops/bin/help list`
  - `bash ops/bin/help manual`
  - `bash ops/bin/help context-pack`
  - `bash ops/init/tools/context_lint.sh`
- Risk / rollback:
  - Risk: Low; new helper script and docs/canon updates only.
  - Rollback: delete `ops/bin/help`, revert `docs/library/LIBRARY_INDEX.md`, `docs/ops/INDEX.md`, `PROJECT_TRUTH.md`, and this entry.

## 2026-01-12 — DP-OPS-0012: Hard-code DP + Metadata Kit mechanics (fences, ordering, freshness gate)

- Purpose: Canonize DP + Metadata Kit output mechanics so ordering, fences, and refusal behavior are deterministic.
- What shipped:
  - Added the Output Mechanics Contract to `PROJECT_TRUTH.md`.
  - Updated `STATE_OF_PLAY.md`.
- Verification:
  - `git diff --name-only`
  - `rg -n "Output Mechanics Contract" PROJECT_TRUTH.md`
  - `sed -n '1,80p' STATE_OF_PLAY.md`
- Risk / rollback:
  - Risk: Low; canon text only.
  - Rollback: revert `PROJECT_TRUTH.md` and `STATE_OF_PLAY.md`.
## 2026-01-12 — DP-OPS-0011: Anti-Drift Guardrail (Model Refusal Rules)

- Purpose: Eliminate conversational drift and enforce deterministic refusal when required state, structure, or approvals are missing.
- What shipped:
  - Added the Model Behavior Guardrail (Anti-Drift) canon section to `PROJECT_TRUTH.md`.
  - Codified hard refusal rules for state binding, DP emission order, Metadata Kit approval, copy surface integrity, and no silent creativity.
- Verification:
  - Manual review of `PROJECT_TRUTH.md` and this entry.
- Risk / rollback:
  - Risk: Low; canon text update only.
  - Rollback: revert `PROJECT_TRUTH.md` and this entry.

## 2026-01-12 — DP-OPS-0009: Snapshot tool tightening v1.1

- Purpose: Keep ICL snapshots paste-sized with deterministic truncation and add optional file output.
- What shipped:
  - Added `--max-lines` with scope defaults, per-file truncation markers, and header counts.
  - Capped `STATE_OF_PLAY.md` to the top 15 entries for ICL snapshots.
  - Added `--out=auto` for snapshot file output and updated snapshot pointers.
- Verification:
  - `git diff --name-only`
  - `bash ops/bin/snapshot --scope=icl --format=chatgpt | head -n 80`
  - `bash ops/bin/snapshot --scope=icl --format=chatgpt | tail -n 40`
  - `bash ops/bin/snapshot --scope=icl --format=chatgpt --max-lines=50 | head -n 120`
  - `bash ops/bin/snapshot --scope=icl --format=chatgpt --out=auto`
  - `ls -la storage/snapshots/ | tail -n 20`
  - `bash ops/bin/open --intent="dp-ops-0009 test" --dp="DP-OPS-0009 / 2026-01-12" | head -n 180`
  - `bash ops/init/tools/context_lint.sh`
- Risk / rollback:
  - Risk: Truncation may hide needed detail if the cap is too low.
  - Rollback: revert `ops/bin/snapshot`, `ops/bin/open`, and `ops/init/icl/context_pack.json`.

## 2026-01-12 — DP-OPS-0008: Internal repo snapshot tool v1

- Purpose: Bring repo snapshot generation in-house as `ops/bin/snapshot` and wire it into the ICL front door.
- What shipped:
  - Added `ops/bin/snapshot` with scope/format flags and deterministic output.
  - Updated `ops/bin/open` to point to snapshot for full repo context.
  - Added snapshot pointer to `ops/init/icl/context_pack.json`.
  - Added snapshot mention to `ops/init/icl/CONTEXT_PACK.md`.
  - Added repo2txt inspiration note to `PROJECT_TRUTH.md`.
- Verification:
  - `git diff --name-only`
  - `ls -la ops/bin/snapshot`
  - `bash ops/bin/snapshot --scope=icl --format=chatgpt | head -n 120`
  - `bash ops/bin/snapshot --scope=icl --format=chatgpt | tail -n 40`
  - `bash ops/bin/snapshot --scope=full --format=chatgpt | head -n 60`
  - `bash ops/bin/open --intent="dp-ops-0008 test" --dp="DP-OPS-0008 / 2026-01-12" | head -n 160`
  - `bash ops/init/tools/context_lint.sh`
- Risk / rollback:
  - Risk: snapshot scope or exclude list may need tuning for size.
  - Rollback: delete `ops/bin/snapshot` and revert the pointer updates.

## 2026-01-11 — DP-OPS-0007: Doc/ops room cleanup + canon consolidation

- Purpose: Remove redundant doc/ops stubs and keep canon pointers clean.
- What shipped:
  - Deleted `docs/ops` pointer stubs now covered by ops canon (kept `docs/ops/INDEX.md`).
  - Updated canon references in `SECURITY.md` and `STATE_OF_PLAY.md`, plus the ICL rename artifacts (later retired).
- Verification:
  - `git diff --name-only`
  - `bash ops/bin/open --intent="dp-ops-0007 test" --dp="DP-OPS-0007 / 2026-01-11" | head -n 140`
  - `bash ops/bin/close | head -n 200`
  - `bash ops/init/tools/context_lint.sh`
  - `rg -n "docs/ops/" docs/00-INDEX.md docs/** ops/**`
- Risk / rollback:
  - Risk: missed reference to removed stubs.
  - Rollback: restore deleted stubs and revert reference updates.

## 2026-01-11 — DP-OPS-0006B: Dispatch Packet branch requirement

- Purpose: Require explicit branch declaration in all Dispatch Packets.
- What shipped:
  - Updated `ops/templates/DISPATCH_PACKET_TEMPLATE.md`.
  - Updated `STATE_OF_PLAY.md`.
- Verification:
  - Manual review.
- Risk / rollback:
  - Risk: Low; template-only change.
  - Rollback: revert `ops/templates/DISPATCH_PACKET_TEMPLATE.md` and this entry.
## 2026-01-11 — DP-OPS-0005: Minimum Operator Effort canon

- Purpose: Codify minimum operator effort and no-editor-nagging guidance in canon.
- What shipped:
  - Updated `PROJECT_TRUTH.md` with the Minimum Operator Effort section.
  - Updated `STATE_OF_PLAY.md`.
- Verification:
  - `git diff --name-only`
  - `rg -n "Minimum Operator Effort|Focus Rule" PROJECT_TRUTH.md ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`
- Risk / rollback:
  - Risk: Low; canon text update only.
  - Rollback: revert `PROJECT_TRUTH.md` and this entry.

## 2026-01-11 — DP-OPS-0004: Front Door v1 close snapshot

- Purpose: Add a single-command close script that prints a copy-safe session snapshot receipt.
- What shipped:
  - Added `ops/bin/close` to emit the session snapshot.
  - Updated `STATE_OF_PLAY.md`.
- Verification:
  - `ls -la ops/bin/close`
  - `bash ops/bin/close | head -n 160`
- Risk / rollback:
  - Risk: Low; new ops helper script only.
  - Rollback: delete `ops/bin/close` and remove this entry.

## 2026-01-11 — DP-OPS-0003: Front Door v2 open prompt

- Purpose: Auto-fill branch + HEAD in the open prompt, add optional intent/DP fields, and codify the Focus Rule.
- What shipped:
  - Updated `ops/bin/open` to Front Door v2 with git auto-detection and new flags.
  - Updated `PROJECT_TRUTH.md` with the Focus Rule (Operator-Led Flow).
  - Updated `STATE_OF_PLAY.md`.
- Verification:
  - `git diff --name-only`
  - `ls -la ops/bin/open`
  - `bash ops/bin/open | head -n 120`
  - `bash ops/bin/open --intent="test intent" --dp="DP-OPS-0003 / 2026-01-11" | head -n 120`
- Risk / rollback:
  - Risk: Low; ops helper script and canon text update only.
  - Rollback: revert `ops/bin/open`, `PROJECT_TRUTH.md`, and this entry.

## 2026-01-11 — DP-OPS-0002: Front Door v1 open prompt

- Purpose: Add a front door command that prints a ready-to-paste Open Prompt with canon pointers, a freshness gate, and the Metadata Kit instruction.
- What shipped:
  - Added `ops/bin/open` (front door prompt generator).
  - Updated `STATE_OF_PLAY.md`.
- Verification:
  - `ls -la ops/bin/open`
  - `bash ops/bin/open | head -n 80`
- Risk / rollback:
  - Risk: Low; new ops helper script only.
  - Rollback: delete `ops/bin/open` and remove this entry.

## 2026-01-11 — DP-OPS-0001E: Metadata Kit v1 per-surface copy blocks

- Purpose: Make Metadata Kit v1 copy/paste perfect by giving each surface its own dedicated fenced block; remove branch-name helper line; reduce operator friction.
- What shipped:
  - Updated `ops/templates/DISPATCH_PACKET_TEMPLATE.md`.
  - Updated `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`.
  - Updated `STATE_OF_PLAY.md`.
- Verification:
  - `git diff --name-only`
  - `rg -n "```" ops/templates/DISPATCH_PACKET_TEMPLATE.md`
  - `rg -n "~~~" ops/templates/DISPATCH_PACKET_TEMPLATE.md`
- Risk / rollback:
  - Risk: Low; documentation-only adjustments.
  - Rollback: revert `ops/templates/DISPATCH_PACKET_TEMPLATE.md`, `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`, and this entry.

## 2026-01-11 — DP-OPS-0001D: Metadata Kit v1 boundary normalization

- Purpose: Normalize template boundaries and codify fence rules for Metadata Kit v1 and DP presentation.
- What shipped:
  - Updated `ops/templates/DISPATCH_PACKET_TEMPLATE.md`.
  - Updated `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`.
  - Updated `STATE_OF_PLAY.md`.
- Verification:
  - Checked diff scope and scanned for copy-boundary markers and triple-backtick leakage in the template.
  - Verified six metadata surfaces remain in order with ~~~md for markdown fields.
- Risk / rollback:
  - Risk: Low; documentation-only adjustments.
  - Rollback: revert `ops/templates/DISPATCH_PACKET_TEMPLATE.md`, `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`, and this entry.

## 2026-01-11 — DP-OPS-0001C: Metadata Kit v1 hygiene + integrator gate

- Purpose: Remove copy-boundary anti-patterns, tighten Metadata Kit v1 hygiene, and codify the Integrator Review Gate.
- What shipped:
  - Updated `ops/templates/DISPATCH_PACKET_TEMPLATE.md`.
  - Updated `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`.
  - Updated `STATE_OF_PLAY.md`.
- Verification:
  - Doc-only change; reviewed diff.
  - Confirmed no STOP COPYING / COPY EVERYTHING markers or triple-backtick fences in the template.
  - Confirmed six metadata surfaces, correct order, and markdown fences use ~~~md.
- Risk / rollback:
  - Risk: Low; documentation-only adjustments.
  - Rollback: revert `ops/templates/DISPATCH_PACKET_TEMPLATE.md`, `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`, and this entry.

## 2026-01-11 — DP-OPS-0001B: Metadata Kit v1 fixups

- Purpose: Fix Metadata Kit v1 so it matches real IDE/GitHub metadata planes; remove sloppy formatting; close governance loop.
- What shipped:
  - Updated `ops/templates/DISPATCH_PACKET_TEMPLATE.md` to add the derived branch line and rewrite Metadata Kit v1 with plain-text vs markdown surfaces and ~~~md blocks.
  - Updated `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md` to align metadata surfaces/types/order and clarify tilde fence usage.
  - Updated `STATE_OF_PLAY.md`.
- Verification:
  - Doc-only change; reviewed diff.
  - Scanned template/protocol for "yaml" misuse; none.
  - Confirmed the kit lists all six surfaces in order with types and no coaching prose inside copy blocks.
- Risk / rollback:
  - Risk: Low; minor wording drift possible as operators adopt the kit.
  - Rollback: revert `ops/templates/DISPATCH_PACKET_TEMPLATE.md`, `ops/init/protocols/DISPATCH_PACKET_PROTOCOL.md`, and this entry.

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
  - Added a filled precheck checklist to `ops/init/icl/DAILY_CONSOLE.md`.
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
  - `grep -r "_meta/" docs/` → hits expected in `docs/SECURE_WEBROOT_OPTION.md` ✅
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
  - Updated PR description templates in `ops/templates/PR_DESCRIPTION_TEMPLATE.md` and `.github/pull_request_template.md`.
  - Hardened contractor dispatch requirements in `ops/contracts/CONTRACTOR_DISPATCH_CONTRACT.md`.
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
  - grep -r "_meta/" docs/ (hits in `docs/SECURE_WEBROOT_OPTION.md`)
  - grep -r "launch_pack_v2" docs/ (no matches)
  - grep -r "src/" docs/ README.md CONTRIBUTING.md (hits in `docs/upstreams.md`, `docs/NUKESECURITY_VISION_TO_IMPLEMENTATION_MAP.md`, `docs/GEOIP_IMPORTER.md`, `docs/triage/_archive/SUBSYSTEM_MAP_v11.md`, `docs/triage/_archive/SECURITY_SURFACE_SWEEP_v11.md`, `docs/repo-nomenclature.md`)
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
  - bash tools/repo/lint_truth.sh ✅
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
- Added canonical PR description template: `ops/templates/PR_DESCRIPTION_TEMPLATE.md`.
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
- Enabled FAIL-mode policing: canon changes require STATE_OF_PLAY update in the same PR
- Updated ops/init/icl/DAILY_CONSOLE.md to clarify canon vs log vs rehydration.
- Added ops governance docs: OUTPUT_FORMAT_CONTRACT + Copilot onboarding + Gemini onboarding
- Updated docs/ops/INDEX.md + docs/00-INDEX.md to link the new ops docs
- Standardized PROJECT_MAP.md bullets for docs/ops/, upstream/, and .github/workflows/ to clarify roles
- 2026-01-03: Canonized Output Formatting Contract (ops/contracts/OUTPUT_FORMAT_CONTRACT.md) and linked it in docs indexes.

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
  - Added `ops/init/icl/DAILY_CONSOLE.md`, `ops/init/icl/AI_CONTEXT_SYNC.md`, `ops/init/icl/CONTEXT_PACK.md`, `ops/init/icl/deprecated/COPILOT_ONBOARDING.md`, `ops/init/icl/deprecated/GEMINI_ONBOARDING.md`, `ops/init/icl/deprecated/IDE_MIGRATION.md`.
  - Updated `ops/init/icl/RECOVERY.md` and `ops/init/icl/ICL_CONTINUITY_CORE.md`.
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
  - Added ICL banned-terms map (later retired).
  - Added ICL/OCL rename plan (later retired).
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
  - Added ICL rename fixups note (later retired).
  - Updated `STATE_OF_PLAY.md` verification language to avoid banned-term drift.
- Verification:
  - Banned-term sweep grep (per ICL rename fixups note) ✅
  - `bash tools/verify_tree.sh` ✅
  - `bash tools/repo/lint_truth.sh` ✅
- Risk / rollback:
  - Risk: lingering legacy references outside the planning docs could still surface later.
  - Rollback: revert this entry and re-run the drift sweep.
