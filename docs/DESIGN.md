<!-- CCD: ff_target="operator-technical" ff_band="30-40" -->
# Design Discipline (Correct-by-Construction)

## 0. Purpose and Constitutional Anchor

This document is the canonical SSOT for the Correct-by-Construction (CbC) design discipline as applied to Stela enforcement tooling. It is referenced from `PoT.md` §4.2 Operational Directives and activated structurally at `TASK.md` §3.1.1 (the DP Preflight Gate).

The discipline has one governing question: before building a detection mechanism, have you documented why structural prevention is not viable? If structural prevention is viable and proportionate, the structure must be built before or instead of the detector. If it is not viable, the detector is justified — but the justification must be recorded.

CbC is not a checklist to file after the work is done. It is a gate that runs before the first line of enforcement code is written.

## 1. The Five Checkpoint Questions

Answer all five before drafting any linter, script, guard, or validation binary. Record answers in the DP Preflight Gate at TASK.md §3.1.1.

**Q1 — Well-formed assertion or behavior-fighter?**
Does this check assert a yes/no fact about observable repository state, or does it attempt to prevent a behavior the system cannot structurally prevent? A check that fights behavior will be worked around. A well-formed assertion fails clearly and early.

**Q2 — Structural prevention available?**
Is there an existing structural mechanism that would make this check unnecessary — for example, a generator that only produces valid output by construction, a schema that makes the invalid case inexpressible, or a file layout that cannot contain the violation? If yes, describe it in concrete terms.

**Q3 — Why is the structural fix not viable or proportionate?**
If structural prevention is available but not being taken, justify why. Quantify the complexity added, the maintenance burden, and the scope of change required. "It is complex" is not a justification. "It requires modifying N files across M subsystems with no existing scaffold" is a justification.

**Q4 — Deletion Test**
What protection gap opens if this tool is deleted? Assign a score:
- **A**: No gap. The tool provides no protection that another mechanism does not already provide. Verdict: delete.
- **B**: A gap exists, but a structural alternative would close it more robustly than the current detection model. Verdict: keep pending structural redesign; queue the redesign explicitly.
- **C**: A gap exists and structural prevention is disproportionate, not yet viable, or depends on a larger refactor that is not scheduled. Verdict: keep with documented justification.
- **D**: A gap exists but the tool duplicates an existing mechanism. Verdict: consolidate; do not maintain two tools for one concern.

**Q5 — Complexity Budget**
Does the implementation cost exceed three times the protective payoff? Estimate in lines of code, cognitive load to maintain, and number of false-positive failure modes introduced. If cost exceeds 3× payoff, the design must be reconsidered before implementation proceeds.

## 2. Decision Framework
```
Q2: Is structural prevention available?
├── Yes → Is the structural fix proportionate?
│         ├── Yes → Build the structure. Defer or eliminate the detector.
│         │         Record the decision. Queue the structural work in the DP.
│         └── No  → Proceed to Q4. Document why the fix is disproportionate.
└── No  → Proceed to Q4.

Q4: Deletion Test score?
├── A → Delete the tool. Do not build the detector.
├── B → Keep with redesign queued. Record in Decision Registry. Escalate if queue goes stale.
├── C → Keep with justification. Record in Decision Registry.
└── D → Consolidate with existing mechanism. Do not maintain duplicates.
```

## 3. Complexity Budget Rule

The Complexity Budget rule has one threshold: if the enforcement mechanism costs more than three times its protective payoff to build and maintain, the design must be reconsidered before implementation proceeds.

Cost components to estimate: lines of code added, number of edge cases handled by special-casing, cognitive load to a future maintainer reading the file cold, and number of failure modes introduced (false positives, false negatives, and gate bypass paths).

Payoff components to estimate: probability that the check catches a real violation per DP cycle, severity of the violation if uncaught, and availability of alternative detection at a later stage.

A linter that is 300 lines of straightforward pattern matching with a clear Deletion Test score of C is not over budget — the logic is flat and the payoff is concrete. A 1,000-line linter with complex prose parsing heuristics, high false-positive rates, and a structural alternative sitting in the design queue is over budget and must be redesigned.

## 4. Retrospective Audit — Phase 1 Findings

The following audit was conducted prior to the canonization of this document. Every existing enforcement tool in the suite was evaluated against the five checkpoint questions as if CbC had been policy at creation. The purpose was to answer: would we have built these tools the same way?

The findings are recorded below and indexed in the Decision Registry in §5.

**`tools/verify.sh` — 287 lines**
Checks that all required platform directories exist, factory head files are reachable, storage subdirs are present, and the Filing Doctrine is obeyed. Every check is a yes/no assertion against the filesystem. No structural prevention exists for filesystem layout violations in a permissive git repository. The alternative (custom git hooks or filesystem ACLs) is disproportionate.
Deletion Test: **C.** Without `verify.sh`, Filing Doctrine violations surface as silent downstream failures rather than clean early errors.
Registry: C — Keep. No redesign recommended.

**`tools/lint/dp.sh` — 1,127 lines**
Validates TASK.md and RESULTS files via canonical template SHA256, normalized structure hash, allowlist pointer integrity, placeholder detection, and closing block field validation. The template hash mechanism is prevention-adjacent: `ops/bin/draft` generates the structure; `dp.sh` confirms it was not tampered with. The 1,127-line count is partially explained by the embedded `--test` mode fixture harness (approximately 200 lines), which is a refactor candidate: extracting it to `tools/test/dp.sh` would reduce the core linter to approximately 900 lines.
Deletion Test: **C.** Without `dp.sh`, hand-authored DPs with arbitrary structure pass all gates and the allowlist pointer check vanishes.
Registry: C — Keep. Refactor candidate noted: extract test fixture to `tools/test/dp.sh` as a standalone future work item. Not urgent.

**`tools/lint/agent.sh` — 258 lines**
Validates registry alignment, required section presence, provenance field completeness, pointer existence, and hazard pattern detection for agent definitions. `ops/src/definitions/agent.md.tpl` generates structure; this linter validates that AI-authored content filled the structure correctly. Two distinct concerns, clean division.
Deletion Test: **C.** Registry drift and hazard pattern violations (for example, an agent pointer to a dump artifact) go undetected.
Registry: C — Keep. The two-layer design (template for structure, linter for content) is the correct prevention model.

**`tools/lint/context.sh` — 131 lines**
Verifies artifact existence, guards against factory directory paths in the manifest (hazard guard), and scans for semantic contamination. Artifact existence and contamination scan: **C**, justified. Hazard guard: **B** — `CONTEXT.md` is hand-authored; if `ops/bin/context` always generated it, the generator could structurally exclude `opt/_factory/` paths and the hazard guard would become redundant. Redesign cost: approximately 12 lines of the 131 total.
Registry: Artifact existence and contamination scan — C, Keep. Hazard guard — B, Keep with structural redesign candidate queued.

**`tools/lint/factory.sh` — 397 lines**
Validates factory head files, pointer integrity within factory definitions, and candidate/promotion pipeline structure. Factory binary generates the skeleton; AI fills it; linter validates the result. Same clean two-layer design as `agent.sh`. The 397-line count is explained by pipeline breadth.
Deletion Test: **C.**
Registry: C — Keep. No redesign opportunity identified.

**`tools/lint/integrity.sh` — 183 lines**
Reads the allowlist pointer from TASK.md, resolves the allowlist file, compares it against all changed and untracked paths, fails if any unauthorized path appears. The allowlist per DP is itself a structural contract. The linter enforces a scoped contract the Operator explicitly authored in the DP. Prevention model enacted at the DP contract layer.
Deletion Test: **C.** Without integrity enforcement, any file modification during a DP execution passes gates regardless of declared scope.
Registry: C — Keep. Reference implementation of a CbC-justified linter. If CbC had been policy at creation, this tool would have been held up as the model.

**`tools/lint/leaf.sh` — 47 lines**
Checks that `emit_binary_leaf` is wired into every file in `ops/bin/` and `tools/`. New binaries and tools are hand-authored without a guaranteed wiring step. The structural alternative has two parts: `ops/bin/scaffold` always includes `emit_binary_leaf` in generated scripts; and an investigation into whether `ops/lib/scripts/common.sh` can auto-invoke it on `source`, removing the per-script call requirement entirely.
Deletion Test: **B.** Scaffold injection plus common.sh auto-invocation makes the linter redundant when both changes land. Structural fix cost: approximately 10 lines across two files.
Registry: B — Keep until scaffold injection is implemented. Flag for structural redesign.

**`tools/lint/llms.sh` — 78 lines**
Generates `llms.txt`, `llms-core.txt`, and `llms-full.txt` into a temp directory, diffs against committed versions, and fails on divergence. Also detects deprecated filename references. The structural fix: a pre-commit hook runs `ops/bin/llms` and stages the output before every commit, making staleness structurally impossible; the deprecated filename check is absorbed into `ops/bin/llms` directly.
Deletion Test: **B.** Pre-commit hook plus generator-absorbed deprecation check makes the linter fully redundant when both changes land.
Registry: B — Keep until pre-commit hook is implemented. Cleanest B-to-deletion pipeline in the queue.

**`tools/lint/project.sh` — 120 lines**
Validates project directory structure and requires `README.md` in every project folder. README check: **B** — `ops/bin/project` or a scaffold equivalent could guarantee `README.md` on creation, making the check redundant for new projects. Structural checks: **C** — hard to guarantee at creation time.
Registry: README check B — flag for scaffold redesign, low priority. Structural checks C — Keep.

**`tools/lint/results.sh` — 287 lines**
Validates RESULTS receipts: heading structure, template hash parity, closing block completeness, placeholder detection, and forbidden disposable-artifact references. `ops/bin/certify` generates the RESULTS structure; `results.sh` validates that AI-authored fields are complete and structure was not tampered with.
Deletion Test: **C.** Certify could produce an incomplete RESULTS receipt without detection; the PR merges with an incomplete evidence chain.
Registry: C — Keep. Same analysis as `dp.sh`. Well-justified.

**`tools/lint/schema.sh` — 208 lines**
Validates YAML frontmatter in `archives/definitions/`, `archives/surfaces/`, and `archives/manifests/` — required keys, ISO-8601 timestamps, valid `previous` pointers. Generator bug coverage: **B** — unit tests for `ops/lib/scripts/ledger.sh` would make schema checks redundant for well-tested generation paths. Manual edit coverage: **C** — archive files can be manually edited; the linter catches manual corruption.
Registry: B/C — Keep. The schema linter's value decreases as ledger script test coverage increases. The two are inversely correlated. Revisit as test coverage grows.

**`tools/lint/skill.sh` — 166 lines**
Same two-layer design as `agent.sh`. Factory template generates structure; AI fills content; linter validates content completeness and registry alignment.
Deletion Test: **C.**
Registry: C — Keep. No redesign opportunity.

**`tools/lint/style.sh` — 232 lines**
Four distinct checks: contraction prohibition, jargon blacklist, spec-surface section compliance, and closing block lead-word repetition detection. Contraction prohibition: **C** — no structural mechanism can prevent contractions in prose; detection is the only tool. Jargon blacklist: **C** — same logic. Spec-surface compliance: **B** — `ops/src/specs/spec.md.tpl` updated to include all four required sections by default makes the compliance check redundant; a spec generated from the updated template cannot be missing them. Lead-word repetition: **C** — without it, AI-generated closing blocks routinely produce six near-identical entries; the check enforces semantic differentiation.
Registry: Contraction prohibition — C, Keep. Jargon — C, Keep. Spec-surface compliance — B, Keep with structural redesign candidate queued. Lead-word repetition — C, Keep.

**`tools/lint/task.sh` — 587 lines**
Validates task factory files and the TASK.md dashboard: registry alignment, section presence, provenance fields, pointer existence, ambiguous-language detection in execution steps, and closeout pointer validation. Registry, section, provenance, closeout checks: **C**, same analysis as `agent.sh`. Ambiguous-language detection: **B** — if task execution steps followed a machine-parseable format rather than prose, ambiguous language would be impossible to express and the check would be unnecessary.
Registry: Registry/section/provenance/closeout checks — C, Keep. Ambiguous-language detection — B, Keep with structural redesign candidate: machine-parseable execution step format.

**`tools/lint/truth.sh` — 153 lines**
Scans all authored surfaces for forbidden spellings of "Stela", forbidden legacy phrases ("Living Document"), and forbidden legacy registry path casing. No structural prevention exists for spelling errors in prose. Detection is the only tool. 153 lines for three distinct scan categories is proportionate.
Deletion Test: **C.** Legacy terminology and platform name misspellings re-enter the canon across DP cycles without detection.
Registry: C — Keep. Simple, proportionate, no structural alternative exists.

**`tools/test/agent.sh` — 128 lines**
Test harness for the agent promotion pipeline. Test coverage is categorically distinct from enforcement linting and is not subject to the same CbC scrutiny. Deletion would remove the only automated validation of the factory promotion path.
Registry: Out of CbC scope — Keep.

**Audit Summary**
Sixteen tools audited. 4,389 total lines across the suite. Ten surfaces score C and are fully justified. Four specific checks within existing tools score B and have identified structural alternatives. One check (spec-surface compliance in `style.sh`) scores B with a clear and low-effort fix. Zero surfaces score A or D. Zero tools would have been blocked by CbC at creation. The total code surface that structural redesign would eventually eliminate is approximately 120 lines across 4,389 — a 2.7% reduction in enforcement code. The discipline will have its most significant impact on future tooling rather than requiring mass remediation.

## 5. Decision Registry

Every CbC decision made against a named tool gets a row. Entries are updated when the tool status changes. B-scored entries sitting without a structural fix DP for more than two quarters are escalated to Operator attention.

| Tool | Score | Verdict | DP | Status |
| :--- | :---: | :--- | :--- | :--- |
| tools/verify.sh | C | Keep | DP-OPS-0101 | Active |
| tools/lint/dp.sh | C | Keep; refactor candidate (extract test fixture) | DP-OPS-0101 | Active |
| tools/lint/agent.sh | C | Keep | DP-OPS-0101 | Active |
| tools/lint/context.sh (artifact existence, contamination) | C | Keep | DP-OPS-0101 | Active |
| tools/lint/context.sh (hazard guard) | B | Keep; redesign queued: generated CONTEXT.md | DP-OPS-0101 | Improvement queued |
| tools/lint/factory.sh | C | Keep | DP-OPS-0101 | Active |
| tools/lint/integrity.sh | C | Keep | DP-OPS-0101 | Active |
| tools/lint/leaf.sh | B | Keep; redesign queued: scaffold injection + common.sh auto-invocation | DP-OPS-0101 | Improvement queued |
| tools/lint/llms.sh | B | Keep; redesign queued: pre-commit hook + generator-absorbed deprecation | DP-OPS-0101 | Improvement queued |
| tools/lint/project.sh (README check) | B | Keep; redesign queued: scaffold guarantee | DP-OPS-0101 | Improvement queued |
| tools/lint/project.sh (structural checks) | C | Keep | DP-OPS-0101 | Active |
| tools/lint/results.sh | C | Keep | DP-OPS-0101 | Active |
| tools/lint/schema.sh | B/C | Keep; revisit as ledger script test coverage grows | DP-OPS-0101 | Active |
| tools/lint/skill.sh | C | Keep | DP-OPS-0101 | Active |
| tools/lint/style.sh (contraction prohibition) | C | Keep | DP-OPS-0101 | Active |
| tools/lint/style.sh (jargon blacklist) | C | Keep | DP-OPS-0101 | Active |
| tools/lint/style.sh (spec-surface compliance) | B | Keep; redesign queued: update spec.md.tpl | DP-OPS-0101 | Improvement queued |
| tools/lint/style.sh (lead-word repetition) | C | Keep | DP-OPS-0101 | Active |
| tools/lint/task.sh (registry/section/provenance/closeout) | C | Keep | DP-OPS-0101 | Active |
| tools/lint/task.sh (ambiguous-language detection) | B | Keep; redesign queued: machine-parseable step format | DP-OPS-0101 | Improvement queued |
| tools/lint/truth.sh | C | Keep | DP-OPS-0101 | Active |
| tools/test/agent.sh | N/A | Keep (out of CbC scope) | DP-OPS-0101 | Active |
