# Contractor Notes — DP-OPS-0139

## Scope Confirmation
All in-scope items from Section 3.3 executed as specified:
- ops/src/decisions/exec.md.tpl: created with taxonomy-specific YAML frontmatter and exec body sections.
- ops/src/decisions/cbc.md.tpl: created with CbC preflight Q1-Q5 structure and verdict slot.
- ops/src/decisions/op.md.tpl: created with operator authorization fields.
- ops/src/decisions/dec.md.tpl: updated template_version to 2 and added legacy-compatibility note in frontmatter.
- ops/bin/decision: updated to support --type=exec|cbc|op taxonomy routing, RoR-YYYY-MM-DD-NNN leaf naming (scanning both DEC and RoR leaves for sequence), RoR.md update on each successful write, and explicit case-statement template paths satisfying receipt grep commands.
- .gitignore: extended with !archives/decisions/RoR-????-??-??-*.md allow rule.
- RoR.md: updated by ops/bin/decision after cbc leaf write.
- docs/ops/specs/binaries/decision.md: rewritten to document taxonomy, RoR naming contract, and RoR.md update behavior.
- docs/ops/registry/templates.md: registered TPL-18, TPL-19, TPL-20 for the three new decision templates.
- tools/lint/integrity.sh: updated to enforce CbC preflight linkage — fails when TASK CbC preflight slot is applicable and no archives/decisions/*-cbc-* entry exists in the allowlist.
- docs/ops/specs/tools/lint/integrity.md: updated to document the CbC preflight enforcement rule and failure message.
- storage/dp/active/allowlist.txt: updated with all new in-scope paths and RoR cbc pattern.
- archives/decisions/RoR-2026-03-01-001-cbc-0139.md: generated via updated ops/bin/decision, Q1-Q5 answers populated post-generation.
- storage/handoff/CLOSING-DP-OPS-0139.md: created and maintained throughout execution.
- SoP.md and PoW.md: authored as single-entry pre-certify heads.

Items not in scope (confirmed skipped per DP Section 3.3 Out of scope):
- No changes to ops/bin/certify or results template (RoR-D3).
- No prefix migration of existing DEC leaves (RoR-D4).
- No CLOSING schema changes.
- No factory content changes.

## Anomalies Encountered
1. ff.sh pre-existing failure on RoR.md: After running tools/lint/ff.sh, one failure was observed: FAIL: RoR.md: missing required CCD header. Stash-test confirmed this failure exists on the committed HEAD (from DP-OPS-0138) and was not introduced by DP-OPS-0139 changes. RoR.md is a single-line pointer file (identical structure to SoP.md, PoW.md, TASK.md) but is not in the wave0_exempt list in ff.sh. Correcting the ff.sh exemption is out of scope for this DP.

2. Receipt grep pattern mismatch: Initial ops/bin/decision implementation used dynamic string construction for template paths which did not contain the literal strings required by the DP receipt grep commands. Resolved by converting resolve_template_path to an explicit case statement with literal path strings. No behavior change.

3. style.sh rejection of .gitignore in Confirm Merge (Extended Description): The closing sidecar initially included .gitignore in the Extended Description field. style.sh rejected it because the path does not match the required regex (leading dot). Removed .gitignore from the Extended Description field. The change is noted in the PR Description narrative instead.

## Open Items / Residue
1. RoR.md CCD header gap: ff.sh will FAIL on RoR.md until the wave0_exempt list in ff.sh is extended to include RoR.md alongside SoP.md, PoW.md, and TASK.md. This is a follow-on fix outside DP-OPS-0139 scope. Risk: low non-blocking failure.
Decision Pointer: archives/decisions/RoR-2026-03-01-001-cbc-0139.md

## Execution Decision Record
Decision Required: Yes
Decision Pointer: archives/decisions/RoR-2026-03-01-001-cbc-0139.md

## Closing Schema Baseline
Assumed the current six-label closing schema (post-0116+A baseline) for this active packet. No historical compatibility paths touched.
