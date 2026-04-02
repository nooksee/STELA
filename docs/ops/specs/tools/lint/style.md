<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/style.sh` enforces linguistic precision and structural explainability for markdown governance surfaces. The gate exists because ambiguous writing, jargon-heavy prose, and malformed spec structure reduce machine-checkable clarity and increase operator interpretation drift, which conflicts with PoT Section 4.2 precision directives.

## Mechanics and Sequencing
1. Resolve repository root and enumerate tracked markdown files with `git ls-files '*.md'`, excluding `storage/`.
2. Search all tracked markdown for contraction tokens using regex patterns that cover ASCII and Unicode apostrophes.
3. Enforce anti-jargon policy by scanning case-insensitive fixed matches for every term in `JARGON_BLACKLIST`.
4. For each spec file under `docs/ops/specs/` that contains `<!-- SPEC-SURFACE:REQUIRED -->`, require the four canonical H2 headings.
5. Scan the active current closing sidecar `storage/handoff/CLOSING.md` plus legacy `storage/handoff/CLOSING-*.md` artifacts and reject duplicate opening words across Mandatory Closing Block field entries.
6a. Check that the Confirm Merge (Add a Comment) field value ends with `?`; emit failure with filename when it does not.
6b. Check that every non-blank line in the Confirm Merge (Extended Description) field value matches a path pattern (two or more consecutive non-path tokens on a single line is a prose failure); emit failure with filename and line number for each detected prose line.
6c. Check that the PR Description field value contains at least one markdown construct — a heading beginning with `##`, a list item beginning with `-`, `*`, or a digit followed by `.`, or a bold span (`**`); emit failure with filename when none is found.
7. Check that `ops/src/stances/planning.md.tpl` contains the exact planning contract lines that preserve final-plan-first behavior, weak-topic handling, bounded clarification, and the planning question-mode transport split between plain clarification output and fenced final-plan output.
8. Aggregate failures and exit non-zero when any check reports an error.

## Anecdotal Anchor
DP-OPS-0082 introduced spec-surface enforcement and anti-jargon checks after repeated review churn on docs that passed operational gates but still carried ambiguous structure or promotional language. Later packets used this gate to block malformed spec edits before certification.

## Integrity Filter Warnings
The scan set includes tracked markdown only; untracked drafts are outside enforcement until tracked. `storage/` is excluded from the bulk markdown scan. Jargon checks are fixed-string matches and can flag quoted historical text that appears in explanatory context. Spec structure checks activate only when `<!-- SPEC-SURFACE:REQUIRED -->` is present, so files without that marker are not subject to four-slot heading validation. Closing block structural checks inspect the active current sidecar `storage/handoff/CLOSING.md` when present, preserve the legacy `DP-OPS-0080+` threshold guard for `CLOSING-*.md`, and additionally grandfather pre-`DP-OPS-0094` historical handoff receipts so old audit artifacts are not rewritten.

## Closing Block Structural Checks

### Closing Block Schema Authority
`ops/bin/certify` is the sole authority defining accepted closing sidecar label schemas. The current closeout label set is SSOT in `ops/lib/manifests/CLOSING.md` (Section 1). `tools/lint/style.sh` implements certify's contract and must remain synchronized with certify's accepted label sets when certify's schema definitions change.

The accepted closing sidecar schema is the current six-label form defined in `ops/lib/manifests/CLOSING.md` (Section 1): `Commit Message`, `Create Pull Request (Title)`, `Create Pull Request (Description)`, `Confirm Merge (Commit Message)`, `Confirm Merge (Extended Description)`, `Confirm Merge (Add a Comment)`.

Style.sh loads the closeout header-detection list from `ops/lib/manifests/CLOSING.md` (Section 1) and applies all three closing-block semantic checks (Conversation Starter question form, path-only `Confirm Merge (Extended Description)`, and markdown-bearing PR Description) to that current schema. Lead-word deduplication applies to recognized current-schema sidecars.

### Check 1: Conversation Starter must end in `?`
Detection logic: Extract the first non-blank line following `Confirm Merge (Add a Comment)` in the active `storage/handoff/CLOSING.md` file when present, plus any recognized current-schema legacy `CLOSING-*.md` artifacts. Trim trailing whitespace. Fail if the trimmed value does not end with `?`.
Failure message: `CLOSING BLOCK: Conversation Starter does not end in '?'. This field must be a genuine question.`
Rationale: A field value that does not end with `?` is a statement, not a question. The Conversation Starter field exists to prompt reviewer engagement on a specific tradeoff or risk. Statements do not fulfill that job.

### Check 2: Confirm Merge (Extended Description) must contain paths only
Detection logic: Extract the non-blank value lines of the `Confirm Merge (Extended Description)` field block in the active `storage/handoff/CLOSING.md` file when present, plus any recognized current-schema legacy `CLOSING-*.md` artifacts. For each line, tokenize on whitespace. Apply the prose heuristic: if two or more consecutive tokens are present that do not begin with a letter or digit and do not contain `/`, the line is classified as prose. Fail on the first prose line detected; emit the line number and text.
Failure message: `CLOSING BLOCK: <manifest field> contains prose on line N: "<line>". This field must contain file paths only.`
Rationale: The path-manifest field is consumed by automated tools and future archaeology. Prose in this field, even a single explanatory clause, breaks machine-readability and signals that the writer substituted explanation for path enumeration. Explanation belongs in the PR Description or equivalent narrative field.

### Check 3: PR Description must contain at least one markdown construct
Detection logic: Extract the value block of `Create Pull Request (Description)` in the active `storage/handoff/CLOSING.md` file when present, plus any recognized current-schema legacy `CLOSING-*.md` artifacts. Scan for: any heading line beginning with `##`, any list item beginning with `-` or `*` followed by a space, any ordered list item beginning with a digit followed by `.` and a space, or any occurrence of `**` (bold span). Fail if none of these constructs are present in the block.
Failure message: `CLOSING BLOCK: PR Description contains no markdown constructs. Use at least one heading (##), list item (- or 1.), or bold (**) to serve the reviewer interface.`
Rationale: The PR Description renders in the GitHub pull request interface, which supports full markdown. A plaintext paragraph in a markdown rendering surface indicates the writer used the field as a text box rather than a structured reviewer handoff. At minimum, one markdown construct is required to demonstrate intentional use of the rendering surface.

## Audit-Addenda Mode Split Guardrails

### Guard 1: Audit stance marker in `audit.md.tpl`
Target file: `ops/src/stances/audit.md.tpl`
Assertion: file must include `` `--profile=addenda` is addenda mode and is never valid for audit verdict workflows. ``
Failure message: `audit.md.tpl missing audit-verdict stance marker`
Invariant: audit verdict flow and addenda authorization flow remain separated by explicit stance guidance.

### Guard 2: Audit attach-only line in `audit.md.tpl`
Target file: `ops/src/stances/audit.md.tpl`
Assertion: file must include `If user text is empty and required attachments are present, proceed and emit only the final audit block.`
Failure message: `audit.md.tpl missing empty-input attach-only rule line`
Invariant: attach-only audit intake proceeds deterministically without requiring user text.

### Guard 3: Audit output contract line in `audit.md.tpl`
Target file: `ops/src/stances/audit.md.tpl`
Assertion: file must include `Output only: Complete audit report.`
Failure message: `audit.md.tpl missing audit output contract line`
Invariant: audit output remains deterministic.

### Guard 4: Audit first-line marker in `audit.md.tpl`
Target file: `ops/src/stances/audit.md.tpl`
Assertion: file must include `First non-empty line must start with \`**AUDIT -\`.`
Failure message: `audit.md.tpl missing audit first-line marker output line`
Invariant: audit output has a stable entry marker for deterministic intake checks.

### Guard 5: Audit no-citations line in `audit.md.tpl`
Target file: `ops/src/stances/audit.md.tpl`
Assertion: file must include `Do not emit citation tokens (\`:contentReference[\` or \`oaicite\`).`
Failure message: `audit.md.tpl missing audit no-citations output line`
Invariant: audit output avoids citation-token contamination.

### Guard 6: Audit evidence-authority conflict rule in `audit.md.tpl`
Target file: `ops/src/stances/audit.md.tpl`
Assertion: file must include `If interpretation conflicts with receipt command outputs, treat command outputs and lint results as authoritative and mark the interpretation as non-blocking.`
Failure message: `audit.md.tpl missing audit evidence-authority conflict rule line`
Invariant: audit output resolves interpretation conflicts to tool evidence instead of inventing blockers.

### Guard 7: Audit allowlist-authority rule in `audit.md.tpl`
Target file: `ops/src/stances/audit.md.tpl`
Assertion: file must include `For allowlist interpretation, \`tools/lint/integrity.sh\` plus certify changed-file subset check are authoritative; raw \`comm\` output is informational.`
Failure message: `audit.md.tpl missing audit allowlist-authority interpretation rule line`
Invariant: audit output does not misclassify raw comm output as a hard gate failure when authoritative checks pass.

### Guard 8: Addenda stance marker in `addenda.md.tpl`
Target file: `ops/src/stances/addenda.md.tpl`
Assertion: file must include `This stance is not used for audit PASS/FAIL verdicts.`
Failure message: `addenda.md.tpl missing addendum-authorization stance marker`
Invariant: addenda stance remains authorization-only and never drifts into verdict behavior.

### Guard 9: Canonical audit split line in bundle manifest
Target file: `ops/lib/manifests/BUNDLE.md`
Assertion: file must include `Canonical audit verdict profile is \`audit\`.`
Failure message: `BUNDLE.md missing canonical audit mode split line`
Invariant: runtime policy keeps audit mode semantics explicit and enforceable.

### Guard 10: Canonical addenda split line in bundle manifest
Target file: `ops/lib/manifests/BUNDLE.md`
Assertion: file must include `Canonical addenda profile is \`addenda\`.`
Failure message: `BUNDLE.md missing canonical addenda mode split line`
Invariant: runtime policy keeps addenda mode semantics explicit and enforceable.

## OPEN Marker Contract Guardrails

### Guard 17: Canonical OPEN begin marker in `ops/bin/open`
Target file: `ops/bin/open`
Assertion: file must include `===== STELA OPEN PROMPT =====`
Failure message: `ops/bin/open missing canonical OPEN begin marker`
Invariant: OPEN envelope start marker is deterministic and canonical.

### Guard 18: Canonical OPEN end marker in `ops/bin/open`
Target file: `ops/bin/open`
Assertion: file must include `===== END STELA OPEN PROMPT =====`
Failure message: `ops/bin/open missing canonical OPEN end marker`
Invariant: OPEN envelope end marker is deterministic and canonical.

### Guard 19: Legacy OPEN begin marker removed from `ops/bin/open`
Target file: `ops/bin/open`
Assertion: file must not include `===== OPEN PROMPT =====`
Failure message: `ops/bin/open still contains legacy OPEN begin marker`
Invariant: legacy marker regression is blocked.

### Guard 20: Legacy standalone OPEN title removed from `ops/bin/open`
Target file: `ops/bin/open`
Assertion: file must not include `Stela OPEN PROMPT`
Failure message: `ops/bin/open still contains legacy standalone OPEN title line`
Invariant: legacy header regression is blocked.

## Planning Mode Contract Guardrails

`check_planning_mode_contract()` treats `ops/src/stances/planning.md.tpl` as the runtime owner and verifies planning by contract families instead of freezing every sentence individually. The guardrail still fails when a required family or anchor line disappears, but it no longer requires sentence-for-sentence duplication of the entire planning template in the verifier.

### Guard 21: Core planning decision anchors
Target file: `ops/src/stances/planning.md.tpl`
Assertions:
- topic source line exists
- evidence-first anchor exists
- no unsupported repo-operating-detail line exists
- multi-family ask-first, explicit-packet, no-inference, follow-up ambiguity, and no-staged-queue-substitute anchors exist
- machine-ingest default-question-mode anchor exists
- broad-topic genericity anchor exists
Failure examples:
- `planning.md.tpl missing planning topic-source line`
- `planning.md.tpl missing planning no-unilateral-packet-inference line`
- `planning.md.tpl missing machine-ingest default-question-mode line`
Invariant: planning still asks before planning on unresolved multi-family topics and does not self-authorize packet choice from repo context.

### Guard 22: Portable clarification transport family
Target file: `ops/src/stances/planning.md.tpl`
Assertions:
- `Portable question transport:` section exists
- the section still requires exactly 2 substantive options
- the fixed redirect choice remains `C. Tell Analyst to do something else instead.`
- clickable-choice bias remains present
Failure examples:
- `planning.md.tpl missing portable-question-transport section`
- `planning.md.tpl missing planning bounded-options invariant`
- `planning.md.tpl missing planning click-bias invariant`
Invariant: portable clarification stays bounded, popup-biased, and redirect-stable.

### Guard 23: Machine-ingest question-mode family
Target file: `ops/src/stances/planning.md.tpl`
Assertions:
- packet-boundary question-first anchor exists
- exact A/B/C answer-line transport anchor exists
- no-analysis-between-question-and-options anchor exists
- no-fence-in-question-mode anchor exists
Failure examples:
- `planning.md.tpl missing planning question-first line`
- `planning.md.tpl missing planning question-choice-transport line`
- `planning.md.tpl missing planning question-mode no-fence line`
Invariant: machine-ingest clarification remains question-first plain-text transport rather than falling back into explanatory prose.

### Guard 24: Host overlay family
Target file: `ops/src/stances/planning.md.tpl`
Assertions:
- `Question mode (host overlay):` section exists
- host-tool path, popup caveat, and Claude-specific tool path remain visible
- machine-ingest host/Claude overlay anchors remain present
Failure examples:
- `planning.md.tpl missing planning host-overlay section`
- `planning.md.tpl missing planning Claude.ai overlay line`
- `planning.md.tpl missing machine-ingest host-overlay line`
Invariant: host/widget behavior stays additive, truthful, and separate from the portable fallback.

### Guard 25: Final-plan family
Target file: `ops/src/stances/planning.md.tpl`
Assertions:
- final-plan output-only anchor exists
- no-text-outside-fence anchor exists
- required core-heading floor anchor exists
- peer-sections anchor exists
- settled-boundary emit anchor exists
Failure examples:
- `planning.md.tpl missing planning plan-output-only line`
- `planning.md.tpl missing planning final-plan shape line`
- `planning.md.tpl missing planning final-plan emit line`
Invariant: final plans remain fenced, bounded, and compatible with the PLAN surface contract.

### Guard 26: Shared non-audit include
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `{{@include:ops/src/shared/stances.json#non_audit_role_drift_rules}}`
Failure message: `planning.md.tpl missing shared non-audit include line`
Invariant: planning continues to inherit the shared non-audit role-drift guard instead of restating it ad hoc.
