# Script Registry

Authoritative registry for `ops/lib/scripts/*` helper scripts.

| ID | Name | File Path | Notes |
| --- | --- | --- | --- |
| SCRIPT-01 | Agent Lifecycle Script | ops/lib/scripts/agent.sh | Spec: `docs/ops/specs/scripts/agent.md`. Harvest, promote, check, and pattern-density reporting for agent candidates. |
| SCRIPT-02 | Heuristics Library | ops/lib/scripts/heuristics.sh | Spec: `docs/ops/specs/scripts/heuristics.md`. Sourced function library for provenance, churn, and semantic-collision heuristics. |
| SCRIPT-03 | Project Helper Library | ops/lib/scripts/project.sh | Spec: `docs/ops/specs/scripts/project.md`. Shared repo-root and project-id validation helpers for project tooling and synthesis wrappers. |
| SCRIPT-04 | Synthesis Engine | ops/lib/scripts/synthesize.sh | Spec: `docs/ops/specs/scripts/project.md`. Central One Truth implementation for manifest parsing, hazard enforcement, and stream emission. |
| SCRIPT-05 | Skill Lifecycle Script | ops/lib/scripts/skill.sh | Spec: `docs/ops/specs/scripts/skill.md`. Harvest, promote, and context-hazard checks for skill drafts and promotions. |
| SCRIPT-06 | Task Lifecycle Script | ops/lib/scripts/task.sh | Spec: `docs/ops/specs/scripts/task.md`. Harvest, promote, and schema/context checks for task drafts and promotions. |
