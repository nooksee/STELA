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
Leaf: archives/decisions/RoR-2026-03-01-003-cbc-0140.md

**`tools/lint/dp.sh` — 1,127 lines**
Validates TASK.md and RESULTS files via canonical template SHA256, normalized structure hash, allowlist pointer integrity, placeholder detection, and delegated RESULTS schema validation. The template hash mechanism is prevention-adjacent: `ops/bin/draft` generates the structure; `dp.sh` confirms it was not tampered with. The 1,127-line count is partially explained by the embedded `--test` mode fixture harness (approximately 200 lines), which is a refactor candidate: extracting it to `tools/test/dp.sh` would reduce the core linter to approximately 900 lines.
Deletion Test: **C.** Without `dp.sh`, hand-authored DPs with arbitrary structure pass all gates and the allowlist pointer check vanishes.
Registry: C — Keep. Refactor candidate noted: extract test fixture to `tools/test/dp.sh` as a standalone future work item. Not urgent.
Leaf: archives/decisions/RoR-2026-03-01-004-cbc-0140.md

**`tools/lint/agent.sh` — 258 lines**
Validates registry alignment, required section presence, provenance field completeness, pointer existence, and hazard pattern detection for agent definitions. `ops/src/definitions/agent.md.tpl` generates structure; this linter validates that AI-authored content filled the structure correctly. Two distinct concerns, clean division.
Deletion Test: **C.** Registry drift and hazard pattern violations (for example, an agent pointer to a dump artifact) go undetected.
Registry: C — Keep. The two-layer design (template for structure, linter for content) is the correct prevention model.
Leaf: archives/decisions/RoR-2026-03-01-005-cbc-0140.md

**`tools/lint/context.sh` — 131 lines**
Verifies artifact existence, guards against factory directory paths in the manifest (hazard guard), and scans for semantic contamination. Artifact existence and contamination scan: **C**, justified. Hazard guard: **B** — `CONTEXT.md` is hand-authored; if `ops/bin/context` always generated it, the generator could structurally exclude `opt/_factory/` paths and the hazard guard would become redundant. Redesign cost: approximately 12 lines of the 131 total.
Registry: Artifact existence and contamination scan — C, Keep. Hazard guard — B, Keep with structural redesign candidate queued.
Leaf (artifact existence, contamination): archives/decisions/RoR-2026-03-01-006-cbc-0140.md
Leaf (hazard guard): archives/decisions/RoR-2026-03-01-007-cbc-0140.md

**`tools/lint/factory.sh` — 397 lines**
Validates factory head files, pointer integrity within factory definitions, and candidate/promotion pipeline structure. Factory binary generates the skeleton; AI fills it; linter validates the result. Same clean two-layer design as `agent.sh`. The 397-line count is explained by pipeline breadth.
Deletion Test: **C.**
Registry: C — Keep. No redesign opportunity identified.
Leaf: archives/decisions/RoR-2026-03-01-008-cbc-0140.md

**`tools/lint/integrity.sh` — 183 lines**
Reads the allowlist pointer from TASK.md, resolves the allowlist file, compares it against all changed and untracked paths, fails if any unauthorized path appears. The allowlist per DP is itself a structural contract. The linter enforces a scoped contract the Operator explicitly authored in the DP. Prevention model enacted at the DP contract layer.
Deletion Test: **C.** Without integrity enforcement, any file modification during a DP execution passes gates regardless of declared scope.
Registry: C — Keep. Reference implementation of a CbC-justified linter. If CbC had been policy at creation, this tool would have been held up as the model.
Leaf: archives/decisions/RoR-2026-03-01-009-cbc-0140.md

**`tools/lint/leaf.sh` — 47 lines**
Checks that `emit_binary_leaf` is wired into every file in `ops/bin/` and `tools/`. New binaries and tools are hand-authored without a guaranteed wiring step. The originally proposed structural alternative had two parts: scaffold injection (`ops/bin/scaffold` pre-wiring `emit_binary_leaf` in generated scripts) and common.sh auto-invocation (`ops/lib/scripts/common.sh` invoking `emit_binary_leaf` at source time, removing per-script calls entirely). Both parts were investigated in the DP-OPS-0109 pre-draft Integrator analysis and found not viable. Common.sh auto-invoke cannot replicate the EXIT trap lifecycle event: the trap must be registered in the sourcing script's execution context to fire on that script's exit; a source-time invocation in the library fires once at source, producing one weak event rather than the two semantically distinct start and finish events the current per-script model provides. Scaffold injection assumed `ops/bin/scaffold` generates shell scripts; it does not. The binary provisions project directory trees from `ops/lib/project/SCAFFOLD.md` and performs no bash script generation. No proportionate structural fix exists. The linter is retained permanently as the correct detection mechanism for enforcing telemetry wiring across pre-scaffold and manually authored scripts.
Deletion Test: **C.** Without `leaf.sh`, `emit_binary_leaf` wiring gaps in `ops/bin/` and `tools/` go undetected, breaking proof reconstruction and violating the PoT proof discipline that requires generated evidence rather than inferred narratives.
Registry: C — Keep. Structural redesign evaluated and rejected in DP-OPS-0109 pre-draft analysis.
Leaf: archives/decisions/RoR-2026-03-01-010-cbc-0140.md

**`tools/lint/llms.sh` — 78 lines**
Generates `llms.txt`, `llms-core.txt`, and `llms-full.txt` into a temp directory, diffs against committed versions, and fails on divergence. Also detects deprecated filename references. The structural fix: a llms hook runs `ops/bin/llms` and stages the output before every commit, making staleness structurally impossible; the deprecated filename check is absorbed into `ops/bin/llms` directly.
Deletion Test: **B.** LLMS hook plus generator-absorbed deprecation check makes the linter fully redundant when both changes land.
Registry: B — Keep until llms hook is implemented. Cleanest B-to-deletion pipeline in the queue. DP-OPS-0102 implements the structural fix and retires the linter.
Leaf: archives/decisions/RoR-2026-03-01-011-cbc-0140.md

**`tools/lint/project.sh` — 120 lines**
Validates project directory structure and requires `README.md` in every project folder. README check: **B** — `ops/bin/scaffold` can guarantee `README.md` on creation, making the check redundant for new projects. Structural checks: **C** — hard to guarantee at creation time.
Registry: README check B — flag for scaffold redesign, low priority. Structural checks C — Keep.
Leaf (README check): archives/decisions/RoR-2026-03-01-012-cbc-0140.md
Leaf (structural checks): archives/decisions/RoR-2026-03-01-013-cbc-0140.md

**`tools/lint/results.sh` — 287 lines**
Validates RESULTS receipts: heading structure, template hash parity, narrative completeness, placeholder detection, and forbidden disposable-artifact references. `ops/bin/certify` generates the RESULTS structure; `results.sh` validates that AI-authored fields are complete and structure was not tampered with.
Deletion Test: **C.** Certify could produce an incomplete RESULTS receipt without detection; the PR merges with an incomplete evidence chain.
Registry: C — Keep. Same analysis as `dp.sh`. Well-justified.
Leaf: archives/decisions/RoR-2026-03-01-014-cbc-0140.md

**`tools/lint/schema.sh` — 208 lines**
Validates YAML frontmatter in `archives/definitions/`, `archives/surfaces/`, and `archives/manifests/` — required keys, ISO-8601 timestamps, valid `previous` pointers. Generator bug coverage: **B** — unit tests for `ops/lib/scripts/ledger.sh` would make schema checks redundant for well-tested generation paths. Manual edit coverage: **C** — archive files can be manually edited; the linter catches manual corruption.
Registry: B/C — Keep. The schema linter's value decreases as ledger script test coverage increases. The two are inversely correlated. Revisit as test coverage grows.
Leaf: archives/decisions/RoR-2026-03-01-015-cbc-0140.md

**`tools/lint/skill.sh` — 166 lines**
Same two-layer design as `agent.sh`. Factory template generates structure; AI fills content; linter validates content completeness and registry alignment.
Deletion Test: **C.**
Registry: C — Keep. No redesign opportunity.
Leaf: archives/decisions/RoR-2026-03-01-016-cbc-0140.md

**`tools/lint/style.sh` — 232 lines**
Four distinct checks: contraction prohibition, jargon blacklist, spec-surface section compliance, and closing sidecar lead-word repetition detection. Contraction prohibition: **C** — no structural mechanism can prevent contractions in prose; detection is the only tool. Jargon blacklist: **C** — same logic. Spec-surface compliance: **B** — `ops/src/docs/spec.md.tpl` updated to include all four required sections by default makes the compliance check redundant; a spec generated from the updated template cannot be missing them. Lead-word repetition: **C** — without it, AI-generated closing sidecars routinely produce six near-identical entries; the check enforces semantic differentiation.
Registry: Contraction prohibition — C, Keep. Jargon — C, Keep. Spec-surface compliance — B, Keep with structural redesign candidate queued. Lead-word repetition — C, Keep.
Leaf (contraction prohibition): archives/decisions/RoR-2026-03-01-017-cbc-0140.md
Leaf (jargon blacklist): archives/decisions/RoR-2026-03-01-018-cbc-0140.md
Leaf (spec-surface compliance): archives/decisions/RoR-2026-03-01-019-cbc-0140.md
Leaf (lead-word repetition): archives/decisions/RoR-2026-03-01-020-cbc-0140.md

**`tools/lint/task.sh` — 587 lines**
Validates task factory files and the TASK.md dashboard: registry alignment, section presence, provenance fields, pointer existence, ambiguous-language detection in execution steps, and closeout pointer validation. Registry, section, provenance, closeout checks: **C**, same analysis as `agent.sh`. Ambiguous-language detection: **B** — if task execution steps followed a machine-parseable format rather than prose, ambiguous language would be impossible to express and the check would be unnecessary.
Registry: Registry/section/provenance/closeout checks — C, Keep. Ambiguous-language detection — B, Keep with structural redesign candidate: machine-parseable execution step format.
Leaf (registry/section/provenance/closeout): archives/decisions/RoR-2026-03-01-021-cbc-0140.md
Leaf (ambiguous-language detection): archives/decisions/RoR-2026-03-01-022-cbc-0140.md

**`tools/lint/truth.sh` — 153 lines**
Scans all authored surfaces for forbidden spellings of "Stela", forbidden legacy phrase variants for mutable-canon wording, and forbidden legacy registry path casing. No structural prevention exists for spelling errors in prose. Detection is the only tool. 153 lines for three distinct scan categories is proportionate.
Deletion Test: **C.** Legacy terminology and platform name misspellings re-enter the canon across DP cycles without detection.
Registry: C — Keep. Simple, proportionate, no structural alternative exists.
Leaf: archives/decisions/RoR-2026-03-01-023-cbc-0140.md

**`tools/test/agent.sh` — 128 lines**
Test harness for the agent promotion pipeline. Test coverage is categorically distinct from enforcement linting and is not subject to the same CbC scrutiny. Deletion would remove the only automated validation of the factory promotion path.
Registry: Out of CbC scope — Keep.
Leaf: archives/decisions/RoR-2026-03-01-024-cbc-0140.md

**Audit Summary**
Sixteen tools audited. 4,389 total lines across the suite. Ten surfaces score C and are fully justified. Four specific checks within existing tools score B and have identified structural alternatives. One check (spec-surface compliance in `style.sh`) scores B with a clear and low-effort fix. Zero surfaces score A or D. Zero tools would have been blocked by CbC at creation. The total code surface that structural redesign would eventually eliminate is approximately 120 lines across 4,389 — a 2.7% reduction in enforcement code. The discipline will have its most significant impact on future tooling rather than requiring mass remediation.

## 5. Decision Registry

The Decision Registry has been relocated to its canonical home. See `docs/ops/registry/decisions.md`.

## 6. DP-OPS-0145 CbC Note (Bundle Routing + PLAN Gate)

DP-OPS-0145 introduces `ops/bin/bundle` auto-routing and a new PLAN route gate at `tools/lint/plan.sh`.
Structural prevention alone is not sufficient for this route decision because `storage/handoff/PLAN.md` is operator-provided runtime input. The system can enforce PLAN presence and minimal deterministic validity, but it cannot structurally guarantee plan quality before runtime intake.

CbC application for this case:
- Prevention first: auto route defaults to Analyst when PLAN is missing.
- Minimal detection: PLAN lint is PASS/FAIL only (existence, non-empty, heading presence, non-heading content, unresolved token guard).
- No style enforcement: subjective checks are intentionally excluded.
- Scope bound: PLAN lint is a routing safety floor for `ops/bin/bundle --profile=auto`; it is not added as a global closeout gate.
