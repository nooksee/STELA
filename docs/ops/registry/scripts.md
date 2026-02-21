<!-- CCD: ff_target="operator-technical" ff_band="25-35" -->
# Script Registry

Authoritative registry for `ops/lib/scripts/*` helper scripts.

| ID | Name | File Path | Notes |
| --- | --- | --- | --- |
| SCRIPT-01 | Agent Lifecycle Script | ops/lib/scripts/agent.sh | Spec: `docs/ops/specs/scripts/agent.md`. Emits candidate and promotion leaves under `archives/definitions/`, advances `opt/_factory/AGENTS.md` heads, and manages agent promotion with registry updates. |
| SCRIPT-02 | Heuristics Library | ops/lib/scripts/heuristics.sh | Spec: `docs/ops/specs/scripts/heuristics.md`. Sourced function library for provenance, churn, and semantic-collision heuristics. |
| SCRIPT-03 | Project Helper Library | ops/lib/scripts/project.sh | Spec: `docs/ops/specs/scripts/project.md`. Shared repo-root and project-id validation helpers for project tooling and synthesis wrappers. |
| SCRIPT-04 | Synthesis Engine | ops/lib/scripts/synthesize.sh | Spec: `docs/ops/specs/scripts/synthesize.md`. Central One Truth engine for manifest parsing, inheritance resolution, context hazard enforcement, and deterministic stream/list emission. |
| SCRIPT-05 | Skill Lifecycle Script | ops/lib/scripts/skill.sh | Spec: `docs/ops/specs/scripts/skill.md`. Emits candidate and promotion leaves under `archives/definitions/`, advances `opt/_factory/SKILLS.md` heads, updates the skill registry, and enforces context hazard checks. |
| SCRIPT-06 | Task Lifecycle Script | ops/lib/scripts/task.sh | Spec: `docs/ops/specs/scripts/task.md`. Emits candidate and promotion leaves under `archives/definitions/`, advances `opt/_factory/TASKS.md` heads, updates task registry rows, and enforces task schema/context checks. |
| SCRIPT-07 | Traverse Engine | ops/lib/scripts/traverse.sh | Spec: `docs/ops/specs/scripts/traverse.md`. Filesystem traversal engine used by `ops/bin/dump`. Accepts scope and filter arguments, emits one repo-root-relative file path per line, and filters binary files from the stream. |
| SCRIPT-08 | Common Utility Library | ops/lib/scripts/common.sh | Spec: `docs/ops/specs/scripts/common.md`. Sourced shared-function library providing foundational utilities consumed by `ops/bin/factory` and `ops/bin/manifest`. |
| SCRIPT-09 | Factory Lifecycle Library | ops/lib/scripts/factory.sh | Spec: `docs/ops/specs/scripts/factory.md`. Sourced library providing agent, skill, and task definition lifecycle helpers consumed by `ops/bin/factory`. |
| SCRIPT-10 | Ledger Update Library | ops/lib/scripts/ledger.sh | Spec: `docs/ops/specs/scripts/ledger.md`. Sourced library providing SoP.md and PoW.md append helpers consumed by closeout tooling. |
