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

### Guard 13: Hygiene alias deprecation status key line
Target file: `ops/lib/manifests/BUNDLE.md`
Assertion: file must include `profile_alias_legacy_hygiene_deprecation_status=`
Failure message: `BUNDLE.md missing hygiene alias deprecation status key line`
Invariant: compatibility alias policy is explicit and machine-checkable.

### Guard 14: Hygiene alias remove-after key line
Target file: `ops/lib/manifests/BUNDLE.md`
Assertion: file must include `profile_alias_legacy_hygiene_remove_after_dp=`
Failure message: `BUNDLE.md missing hygiene alias remove-after key line`
Invariant: compatibility alias policy includes a bounded removal target.

### Guard 16: Hygiene alias sunset-window compatibility note
Target file: `ops/lib/manifests/BUNDLE.md`
Assertion: file must include `Legacy \`hygiene\` alias deprecation status is \`sunset\`; removal target is \`DP-OPS-0165\`.`
Failure message: `BUNDLE.md missing hygiene alias sunset-window compatibility note`
Invariant: human-readable policy text matches machine-enforced alias deprecation configuration.

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

### Guard 21: Planning no-unsupported-operating-detail line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `For machine-ingest planning mode: do not add repository-operating details, workflow examples, command families, or GitHub action lists unless they are directly visible in the attached artifacts.`
Failure message: `planning.md.tpl missing planning no-unsupported-operating-detail line`
Invariant: broad planning topics do not silently expand into unsupported repo-operating detail.

### Guard 22: Planning evidence-first line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `* Use attached evidence first.`
Failure message: `planning.md.tpl missing planning evidence-first line`
Invariant: planning keeps bundle-attached evidence ahead of generic planner behavior.

### Guard 23: Planning multi-family question-first line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `* If the topic spans multiple independent work families and the topic does not explicitly identify the immediate packet, ask one slicing or prioritization question before writing the final plan.`
Failure message: `planning.md.tpl missing planning multi-family question-first line`
Invariant: broad multi-family topics do not skip clarification by assistant-selected first-packet staging.

### Guard 23a: Planning explicit-packet gate line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `* Treat the immediate packet as explicit only if:`
Failure message: `planning.md.tpl missing planning explicit-packet gate line`
Invariant: immediate-packet explicitness is defined by the contract instead of inferred loosely from topic breadth.

### Guard 23b: Planning no-unilateral-packet-inference line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `* Do not infer or choose the immediate packet unilaterally from repo context alone when multiple work families are in scope.`
Failure message: `planning.md.tpl missing planning no-unilateral-packet-inference line`
Invariant: planner autonomy does not replace operator packet selection on multi-family topics.

### Guard 23c: Planning follow-up ambiguity line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `* If remaining ambiguity still materially changes the immediate packet boundary or implementation handoff, ask the minimum additional bounded clarification needed.`
Failure message: `planning.md.tpl missing planning follow-up ambiguity line`
Invariant: after the first slicing decision, only material remaining ambiguity justifies more questions.

### Guard 23d: Planning bounded-options line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `* Each clarification question must present exactly 2 substantive, mutually exclusive options when the decision is binary.`
Failure message: `planning.md.tpl missing planning bounded-options line`
Invariant: popup-biased clarification keeps the substantive choice set narrow instead of expanding into open-ended questionnaires.

### Guard 23e: Planning redirect-option line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `* After those substantive options, always include a fixed redirect option labeled \`C. Tell Analyst to do something else instead.\``
Failure message: `planning.md.tpl missing planning redirect-option line`
Invariant: popup-biased clarification always exposes the same role-native escape hatch.

### Guard 23f: Planning standalone-option-lines line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `* Present options as short standalone lines with letter labels (\`A.\`, \`B.\`, \`C.\`) and no nested bullets under the options.`
Failure message: `planning.md.tpl missing planning standalone-option-lines line`
Invariant: the option transport stays short and popup-biased instead of drifting back into prose lists.

### Guard 23g: Planning click-bias line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `* Keep each option concise enough to render cleanly as a clickable choice when the host UI supports it; the stance biases toward clickable rendering but does not guarantee widget behavior.`
Failure message: `planning.md.tpl missing planning click-bias line`
Invariant: the contract biases toward clickable rendering without pretending the repo can guarantee host UI behavior.

### Guard 23h: Planning recommended-option line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `* Mark at most one substantive option \`(Recommended)\` and only when directly visible evidence justifies it.`
Failure message: `planning.md.tpl missing planning recommended-option line`
Invariant: recommendation markup remains evidence-bound and limited to substantive choices.

### Guard 23i: Planning redirect-not-recommended line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `* Do not mark the redirect option \`(Recommended)\`.`
Failure message: `planning.md.tpl missing planning redirect-not-recommended line`
Invariant: the standard redirect choice stays neutral.

### Guard 23j: Planning no-staged-queue-substitute line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `* Do not substitute a staged queue, proposed sequencing, or assistant-chosen first packet for a missing slicing decision.`
Failure message: `planning.md.tpl missing planning no-staged-queue-substitute line`
Invariant: staged queues cannot replace the required slicing decision.

### Guard 23k: Planning settled-boundary emit line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `* Once the immediate packet boundary is settled, emit the final \`storage/handoff/PLAN.md\`.`
Failure message: `planning.md.tpl missing planning settled-boundary emit line`
Invariant: final-plan output happens only after the immediate packet boundary is actually settled.

### Guard 24: Planning final-plan no-outside-text line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `For final plan mode: emit no text before or after the fenced markdown code block.`
Failure message: `planning.md.tpl missing planning final-plan no-outside-text line`
Invariant: final-plan serialization stays fence-only even though clarification mode is plain text.

### Guard 25: Planning broad-topic genericity line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `For machine-ingest planning mode: when the topic is broad, keep repo-specific claims generic and high-level rather than converting thin evidence into specific operating facts.`
Failure message: `planning.md.tpl missing planning broad-topic-genericity line`
Invariant: topic-driven planning output stays high-level when attached evidence is thin.

### Guard 26: Machine-ingest evidence-first line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `For machine-ingest planning mode: use attached evidence first.`
Failure message: `planning.md.tpl missing machine-ingest evidence-first line`
Invariant: the machine-ingest contract explicitly keeps attached evidence ahead of generic planning priors.

### Guard 27: Planning question-first line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `For machine-ingest question mode: when clarification is needed, ask the packet-boundary question first as a short prose sentence without any retired analysis preamble or other required wrapper.`
Failure message: `planning.md.tpl missing planning question-first line`
Invariant: clarification mode asks the blocking boundary question directly instead of reintroducing analysis wrapper text.

### Guard 28: Planning question-choice-transport line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `For machine-ingest question mode: allow at most 3 questions; each question must immediately follow the prose question with exactly 3 short standalone answer lines: \`A.\` first substantive option, \`B.\` second substantive option, and \`C. Tell Analyst to do something else instead.\``
Failure message: `planning.md.tpl missing planning question-choice-transport line`
Invariant: machine-ingest clarification uses the popup-biased A/B/C transport instead of a loose generic option set.

### Guard 28a: Planning question-mode no-analysis-paragraphs line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `For machine-ingest question mode: keep each option to one short line when possible; do not add analysis paragraphs between the question and the options.`
Failure message: `planning.md.tpl missing planning question-mode no-analysis-paragraphs line`
Invariant: machine-ingest clarification stays question-first and transport-oriented instead of expanding into rationale between the question and choices.

### Guard 28b: Planning question-mode recommended guard line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `For machine-ingest question mode: mark at most one substantive option \`(Recommended)\` only when attached evidence justifies it; never mark the redirect option \`(Recommended)\`.`
Failure message: `planning.md.tpl missing planning question-mode recommended guard line`
Invariant: recommendation markup remains bounded to substantive options during popup-biased clarification.

### Guard 28c: Planning question-mode fixed-redirect line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `For machine-ingest question mode: do not invent extra substantive branches solely to satisfy formatting; the third displayed choice is the standard redirect option.`
Failure message: `planning.md.tpl missing planning question-mode fixed-redirect line`
Invariant: the popup-biased transport preserves a fixed third redirect choice instead of drifting back to three substantive branches.

### Guard 28d: Planning question-mode no-fence line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `For machine-ingest question mode: do not use a fenced markdown code block; fenced markdown remains the final-plan output contract only.`
Failure message: `planning.md.tpl missing planning question-mode no-fence line`
Invariant: clarification mode remains plain-text question transport while final-plan mode stays fenced.

### Guard 29: Planning non-actionable-topic line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `For machine-ingest question mode: if topic text is nonsensical or non-actionable, stop at the nearest truthful boundary and ask for clarification.`
Failure message: `planning.md.tpl missing planning nonsensical-topic line`
Invariant: nonsense topics still stop truthfully rather than forcing fabricated plans.

### Guard 30: Planning broad-topic slicing line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `For machine-ingest planning mode: if the topic spans multiple independent work families and the topic does not explicitly identify the immediate packet, ask one slicing or prioritization question before writing the final plan.`
Failure message: `planning.md.tpl missing planning broad-topic-slicing line`
Invariant: machine-ingest planning asks before planning when a multi-family topic lacks an explicit first packet.

### Guard 30a: Machine-ingest explicit-packet line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `For machine-ingest planning mode: treat the immediate packet as explicit only if the topic directly names the first packet or first work family, the attached evidence directly requires a first packet ordering, or the user explicitly prioritizes one work family.`
Failure message: `planning.md.tpl missing machine-ingest explicit-packet line`
Invariant: machine-ingest planning uses the same narrow explicitness definition as the top-level contract.

### Guard 30b: Machine-ingest no-inference line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `For machine-ingest planning mode: do not infer or choose the immediate packet unilaterally from repo context alone when multiple work families are in scope.`
Failure message: `planning.md.tpl missing machine-ingest no-inference line`
Invariant: machine-ingest planning does not self-authorize first-packet choice from repo context alone.

### Guard 30c: Machine-ingest multi-family threshold line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `For machine-ingest planning mode: three or more distinct deliverables in one topic count as multiple independent work families regardless of domain overlap.`
Failure message: `planning.md.tpl missing machine-ingest multi-family-threshold line`
Invariant: broad single-domain omnibus topics cannot dodge multi-family handling by domain-label compression.

### Guard 30d: Machine-ingest no-staged-queue-substitute line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `For machine-ingest planning mode: do not substitute a staged queue, proposed sequencing, or assistant-chosen first packet for a missing slicing decision.`
Failure message: `planning.md.tpl missing machine-ingest no-staged-queue-substitute line`
Invariant: machine-ingest planning cannot satisfy a missing slicing decision by producing a staged queue.

### Guard 30e: Machine-ingest default-question-mode line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `For machine-ingest planning mode: default to question mode for multi-family topics; only skip the slicing question when the operator's topic text directly names the immediate packet.`
Failure message: `planning.md.tpl missing machine-ingest default-question-mode line`
Invariant: machine-ingest planning defaults to question mode on multi-family topics unless the operator has already named the immediate packet.

### Guard 31: Planning plan-output-only line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `For final plan mode: output only the complete PLAN markdown code block.`
Failure message: `planning.md.tpl missing planning plan-output-only line`
Invariant: draft-ready plan serialization remains available once intent is settled.

### Guard 32: Planning final-plan shape line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `For final plan mode: keep \`Summary\`, \`Key Changes\`, \`Test Plan\`, and \`Assumptions\` as required core sections; additional bounded sections are allowed only when needed to keep the handoff truthful and narrow.`
Failure message: `planning.md.tpl missing planning final-plan shape line`
Invariant: final plan mode keeps the required Stela handoff sections without turning them into an exclusive cage.

### Guard 33: Planning final-plan emission line
Target file: `ops/src/stances/planning.md.tpl`
Assertion: file must include `For final plan mode: once the immediate packet boundary is settled, emit the final \`storage/handoff/PLAN.md\`.`
Failure message: `planning.md.tpl missing planning final-plan emit line`
Invariant: final plan output happens only after the immediate packet boundary is actually settled.
