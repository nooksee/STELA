<!-- CCD: ff_target="operator-technical" ff_band="25-35" -->
# Decision Registry

Every CbC decision made against a named tool gets a row. Entries are updated when the tool status changes. B-scored entries sitting without a structural fix DP for more than two quarters are escalated to Operator attention.

| Tool | Score | Verdict | DP | Status |
| :--- | :---: | :--- | :--- | :--- |
| tools/verify.sh | C | Keep | DP-OPS-0101 | Active |
| tools/lint/dp.sh | C | Keep; refactor candidate (extract test fixture) | DP-OPS-0101 | Active |
| tools/lint/agent.sh | C | Keep | DP-OPS-0101 | Active |
| tools/lint/context.sh (artifact existence, contamination) | C | Keep | DP-OPS-0101 | Active |
| tools/lint/context.sh (hazard guard) | A | Hazard guard removed; structural prevention confirmed via generated CONTEXT.md (template: ops/src/manifests/context.md.tpl excludes opt/_factory/ paths) | DP-OPS-0108 | Deprecated; CbC structural elimination complete |
| tools/lint/factory.sh | C | Keep | DP-OPS-0101 | Active |
| tools/lint/integrity.sh | C | Keep | DP-OPS-0101 | Active |
| tools/lint/leaf.sh | C | Keep; structural redesign evaluated and rejected in DP-OPS-0109. Common.sh auto-invoke cannot replicate the EXIT trap in the caller execution context. Scaffold injection not applicable: ops/bin/scaffold does not generate shell scripts. Linter retained as permanent safety net for pre-scaffold and manually authored scripts. | DP-OPS-0101, DP-OPS-0109 | Active |
| tools/lint/llms.sh | A (closed) | Deprecated — llms hook + generator absorption | DP-OPS-0102 | Deprecated |
| tools/lint/project.sh (README check) | B | Keep; redesign queued: scaffold guarantee | DP-OPS-0101 | Improvement queued |
| tools/lint/project.sh (structural checks) | C | Keep | DP-OPS-0101 | Active |
| tools/lint/results.sh | C | Keep | DP-OPS-0101 | Active |
| tools/lint/schema.sh | B/C | Keep; revisit as ledger script test coverage grows | DP-OPS-0101 | Active |
| tools/lint/skill.sh | C | Keep | DP-OPS-0101 | Active |
| tools/lint/style.sh (contraction prohibition) | C | Keep | DP-OPS-0101 | Active |
| tools/lint/style.sh (jargon blacklist) | C | Keep | DP-OPS-0101 | Active |
| tools/lint/style.sh (spec-surface compliance) | A (closed) | Compliance check removed; ops/src/docs/spec.md.tpl confirmed to include all four required sections by construction; check is structurally redundant | DP-OPS-0101, DP-OPS-0110 | Deprecated; CbC structural elimination complete |
| tools/lint/style.sh (lead-word repetition) | C | Keep | DP-OPS-0101 | Active |
| tools/lint/task.sh (registry/section/provenance/closeout) | C | Keep | DP-OPS-0101 | Active |
| tools/lint/task.sh (ambiguous-language detection) | B | Keep; redesign queued: machine-parseable step format | DP-OPS-0101 | Improvement queued |
| tools/lint/truth.sh | C | Keep | DP-OPS-0101 | Active |
| tools/test/agent.sh | N/A | Keep (out of CbC scope) | DP-OPS-0101 | Active |
