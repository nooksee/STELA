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
5. Scan `storage/handoff/CLOSING-*.md` and reject duplicate opening words across Mandatory Closing Block field entries.
6a. Check that the Confirm Merge (Add a Comment) field value ends with `?`; emit failure with filename when it does not.
6b. Check that every non-blank line in the Confirm Merge (Extended Description) field value matches a path pattern (two or more consecutive non-path tokens on a single line is a prose failure); emit failure with filename and line number for each detected prose line.
6c. Check that the PR Description field value contains at least one markdown construct — a heading beginning with `##`, a list item beginning with `-`, `*`, or a digit followed by `.`, or a bold span (`**`); emit failure with filename when none is found.
7. Check that `ops/src/stances/analyst.md.tpl` contains the exact analyst contract lines that restore discussion-mode optioning and recommendation behavior, preserve weak-topic handling, forbid unsupported repo-operating detail, and keep explicit plan-output mode tightly bounded.
8. Aggregate failures and exit non-zero when any check reports an error.

## Anecdotal Anchor
DP-OPS-0082 introduced spec-surface enforcement and anti-jargon checks after repeated review churn on docs that passed operational gates but still carried ambiguous structure or promotional language. Later packets used this gate to block malformed spec edits before certification.

## Integrity Filter Warnings
The scan set includes tracked markdown only; untracked drafts are outside enforcement until tracked. `storage/` is excluded from the bulk markdown scan. Jargon checks are fixed-string matches and can flag quoted historical text that appears in explanatory context. Spec structure checks activate only when `<!-- SPEC-SURFACE:REQUIRED -->` is present, so files without that marker are not subject to four-slot heading validation. Closing block structural checks preserve the legacy `DP-OPS-0080+` threshold guard and additionally grandfather pre-`DP-OPS-0094` handoff receipts so historical audit artifacts are not rewritten.

## Closing Block Structural Checks

### Closing Block Schema Authority
`ops/bin/certify` is the sole authority defining accepted closing sidecar label schemas. The current closeout label set is SSOT in `ops/lib/manifests/CLOSING.md` (Section 1). `tools/lint/style.sh` implements certify's contract and must remain synchronized with certify's accepted label sets when certify's schema definitions change.

The accepted closing sidecar schema is the current six-label form defined in `ops/lib/manifests/CLOSING.md` (Section 1): `Commit Message`, `Create Pull Request (Title)`, `Create Pull Request (Description)`, `Confirm Merge (Commit Message)`, `Confirm Merge (Extended Description)`, `Confirm Merge (Add a Comment)`.

Style.sh loads the closeout header-detection list from `ops/lib/manifests/CLOSING.md` (Section 1) and applies all three closing-block semantic checks (Conversation Starter question form, path-only `Confirm Merge (Extended Description)`, and markdown-bearing PR Description) to that current schema. Lead-word deduplication applies to recognized current-schema sidecars.

### Check 1: Conversation Starter must end in `?`
Detection logic: Extract the first non-blank line following `Confirm Merge (Add a Comment)` in each recognized current-schema `CLOSING-*.md` file. Trim trailing whitespace. Fail if the trimmed value does not end with `?`.
Failure message: `CLOSING BLOCK: Conversation Starter does not end in '?'. This field must be a genuine question.`
Rationale: A field value that does not end with `?` is a statement, not a question. The Conversation Starter field exists to prompt reviewer engagement on a specific tradeoff or risk. Statements do not fulfill that job.

### Check 2: Confirm Merge (Extended Description) must contain paths only
Detection logic: Extract the non-blank value lines of the `Confirm Merge (Extended Description)` field block in each recognized current-schema `CLOSING-*.md` file. For each line, tokenize on whitespace. Apply the prose heuristic: if two or more consecutive tokens are present that do not begin with a letter or digit and do not contain `/`, the line is classified as prose. Fail on the first prose line detected; emit the line number and text.
Failure message: `CLOSING BLOCK: <manifest field> contains prose on line N: "<line>". This field must contain file paths only.`
Rationale: The path-manifest field is consumed by automated tools and future archaeology. Prose in this field, even a single explanatory clause, breaks machine-readability and signals that the writer substituted explanation for path enumeration. Explanation belongs in the PR Description or equivalent narrative field.

### Check 3: PR Description must contain at least one markdown construct
Detection logic: Extract the value block of `Create Pull Request (Description)` in each recognized current-schema `CLOSING-*.md` file. Scan for: any heading line beginning with `##`, any list item beginning with `-` or `*` followed by a space, any ordered list item beginning with a digit followed by `.` and a space, or any occurrence of `**` (bold span). Fail if none of these constructs are present in the block.
Failure message: `CLOSING BLOCK: PR Description contains no markdown constructs. Use at least one heading (##), list item (- or 1.), or bold (**) to serve the reviewer interface.`
Rationale: The PR Description renders in the GitHub pull request interface, which supports full markdown. A plaintext paragraph in a markdown rendering surface indicates the writer used the field as a text box rather than a structured reviewer handoff. At minimum, one markdown construct is required to demonstrate intentional use of the rendering surface.

## Audit-Foreman Mode Split Guardrails

### Guard 1: Audit stance marker in `auditor.md.tpl`
Target file: `ops/src/stances/auditor.md.tpl`
Assertion: file must include `` `--profile=foreman` is addendum-authorization mode and is never valid for audit verdict workflows. ``
Failure message: `auditor.md.tpl missing audit-verdict stance marker`
Invariant: audit verdict flow and foreman authorization flow remain separated by explicit stance guidance.

### Guard 2: Audit attach-only line in `auditor.md.tpl`
Target file: `ops/src/stances/auditor.md.tpl`
Assertion: file must include `If user text is empty and required attachments are present, proceed and emit only the final audit block.`
Failure message: `auditor.md.tpl missing empty-input attach-only rule line`
Invariant: attach-only audit intake proceeds deterministically without requiring user text.

### Guard 3: Audit output contract line in `auditor.md.tpl`
Target file: `ops/src/stances/auditor.md.tpl`
Assertion: file must include `Output only: Complete audit report.`
Failure message: `auditor.md.tpl missing audit output contract line`
Invariant: auditor output remains deterministic.

### Guard 4: Audit first-line marker in `auditor.md.tpl`
Target file: `ops/src/stances/auditor.md.tpl`
Assertion: file must include `First non-empty line must start with \`**AUDIT -\`.`
Failure message: `auditor.md.tpl missing audit first-line marker output line`
Invariant: auditor output has a stable entry marker for deterministic intake checks.

### Guard 5: Audit no-citations line in `auditor.md.tpl`
Target file: `ops/src/stances/auditor.md.tpl`
Assertion: file must include `Do not emit citation tokens (\`:contentReference[\` or \`oaicite\`).`
Failure message: `auditor.md.tpl missing audit no-citations output line`
Invariant: auditor output avoids citation-token contamination.

### Guard 6: Audit evidence-authority conflict rule in `auditor.md.tpl`
Target file: `ops/src/stances/auditor.md.tpl`
Assertion: file must include `If interpretation conflicts with receipt command outputs, treat command outputs and lint results as authoritative and mark the interpretation as non-blocking.`
Failure message: `auditor.md.tpl missing audit evidence-authority conflict rule line`
Invariant: audit output resolves interpretation conflicts to tool evidence instead of inventing blockers.

### Guard 7: Audit allowlist-authority rule in `auditor.md.tpl`
Target file: `ops/src/stances/auditor.md.tpl`
Assertion: file must include `For allowlist interpretation, \`tools/lint/integrity.sh\` plus certify changed-file subset check are authoritative; raw \`comm\` output is informational.`
Failure message: `auditor.md.tpl missing audit allowlist-authority interpretation rule line`
Invariant: audit output does not misclassify raw comm output as a hard gate failure when authoritative checks pass.

### Guard 8: Foreman stance marker in `foreman.md.tpl`
Target file: `ops/src/stances/foreman.md.tpl`
Assertion: file must include `This stance is not used for audit PASS/FAIL verdicts.`
Failure message: `foreman.md.tpl missing addendum-authorization stance marker`
Invariant: foreman stance remains authorization-only and never drifts into verdict behavior.

### Guard 9: Canonical audit split line in bundle manifest
Target file: `ops/lib/manifests/BUNDLE.md`
Assertion: file must include `Canonical audit verdict profile is \`audit\`.`
Failure message: `BUNDLE.md missing canonical audit mode split line`
Invariant: runtime policy keeps audit mode semantics explicit and enforceable.

### Guard 10: Canonical foreman split line in bundle manifest
Target file: `ops/lib/manifests/BUNDLE.md`
Assertion: file must include `Canonical addendum authorization profile is \`foreman\`.`
Failure message: `BUNDLE.md missing canonical foreman mode split line`
Invariant: runtime policy keeps foreman mode semantics explicit and enforceable.

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

## Analyst Mode Contract Guardrails

### Guard 21: Analyst no-unsupported-operating-detail line
Target file: `ops/src/stances/analyst.md.tpl`
Assertion: file must include `For machine-ingest analyst mode: do not add repository-operating details, workflow examples, command families, or GitHub action lists unless they are directly visible in the attached artifacts.`
Failure message: `analyst.md.tpl missing analyst no-unsupported-operating-detail line`
Invariant: broad analyst topics do not silently expand into unsupported repo-operating detail.

### Guard 22: Analyst discussion-mode default line
Target file: `ops/src/stances/analyst.md.tpl`
Assertion: file must include `* Default analyst behavior is discussion mode.`
Failure message: `analyst.md.tpl missing analyst discussion-mode default line`
Invariant: analyst is not silently reduced to plan-only serialization.

### Guard 23: Analyst explicit plan-output trigger line
Target file: `ops/src/stances/analyst.md.tpl`
Assertion: file must include `* Explicit plan-output mode is allowed only when the attached topic explicitly asks for a plan, DP plan, architect handoff, or plan-only output.`
Failure message: `analyst.md.tpl missing analyst explicit plan-output trigger line`
Invariant: plan-only mode is explicit and does not erase default analyst discussion behavior.

### Guard 24: Analyst broad-topic genericity line
Target file: `ops/src/stances/analyst.md.tpl`
Assertion: file must include `For machine-ingest analyst mode: when the topic is broad, keep repo-specific claims generic and high-level rather than converting thin evidence into specific operating facts.`
Failure message: `analyst.md.tpl missing analyst broad-topic-genericity line`
Invariant: topic-driven analyst output stays high-level when attached evidence is thin.

### Guard 25: Analyst discussion-mode first-line marker
Target file: `ops/src/stances/analyst.md.tpl`
Assertion: file must include `For default analyst mode: first non-empty line inside the fenced body must start with \`1. Analysis and Discussion\`.`
Failure message: `analyst.md.tpl missing analyst discussion-mode first-line marker line`
Invariant: default analyst output stays in discussion mode instead of collapsing to plan-only output.

### Guard 26: Analyst three-options line
Target file: `ops/src/stances/analyst.md.tpl`
Assertion: file must include `For default analyst mode: include \`2. Strategic Options\` with exactly three options when the topic is actionable enough to support them.`
Failure message: `analyst.md.tpl missing analyst three-options line`
Invariant: actionable analyst topics produce real optioning instead of a single flattened plan.

### Guard 27: Analyst recommendation line
Target file: `ops/src/stances/analyst.md.tpl`
Assertion: file must include `For default analyst mode: include one \`Recommendation:\` line naming the preferred option.`
Failure message: `analyst.md.tpl missing analyst recommendation line`
Invariant: analyst mode makes a recommendation instead of dumping undirected options.

### Guard 28: Analyst conversation tail line
Target file: `ops/src/stances/analyst.md.tpl`
Assertion: file must include `For default analyst mode: end with \`Questions / Conversation:\` and short operator-facing prompts when clarification, tradeoff choice, or confirmation would help.`
Failure message: `analyst.md.tpl missing analyst questions line`
Invariant: analyst mode invites bounded operator conversation when it helps move the decision forward.

### Guard 29: Analyst weak-topic handling line
Target file: `ops/src/stances/analyst.md.tpl`
Assertion: file must include `For default analyst mode: if topic text is present but weak or ambiguous, interpret conservatively, state assumptions, and ask concise follow-up questions instead of forcing a plan-only artifact.`
Failure message: `analyst.md.tpl missing analyst weak-topic handling line`
Invariant: weak topics trigger bounded clarification rather than dead serialization.

### Guard 30: Analyst non-actionable-topic line
Target file: `ops/src/stances/analyst.md.tpl`
Assertion: file must include `For default analyst mode: if topic text is nonsensical or non-actionable, stop at the nearest truthful boundary and ask for clarification.`
Failure message: `analyst.md.tpl missing analyst non-actionable-topic line`
Invariant: nonsense topics stop truthfully instead of producing fabricated plans.

### Guard 31: Analyst plan-output-only line
Target file: `ops/src/stances/analyst.md.tpl`
Assertion: file must include `For explicit plan-output mode: output only the complete PLAN markdown code block.`
Failure message: `analyst.md.tpl missing analyst plan-output-only line`
Invariant: architect-ready plan serialization remains available as an explicit mode.

### Guard 32: Analyst plan-output first-line marker
Target file: `ops/src/stances/analyst.md.tpl`
Assertion: file must include `For explicit plan-output mode: first non-empty line inside the code block must start with \`# DP Plan:\`.`
Failure message: `analyst.md.tpl missing analyst plan-output first-line marker line`
Invariant: explicit plan-output mode still targets the canonical PLAN surface template.

### Guard 33: Analyst plan-output smallest-inference line
Target file: `ops/src/stances/analyst.md.tpl`
Assertion: file must include `For explicit plan-output mode: when required handoff fields force inference, make the smallest reasonable inference and avoid supporting detail that reads as established repository fact.`
Failure message: `analyst.md.tpl missing analyst plan-output smallest-inference line`
Invariant: explicit plan-output inference stays minimal and does not masquerade as established repository fact.
