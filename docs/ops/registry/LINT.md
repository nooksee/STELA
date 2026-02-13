# Lint Registry

Authoritative registry for `tools/lint/*` executables.

| ID | Name | File Path | Notes |
| --- | --- | --- | --- |
| LINT-01 | Agent Lint | tools/lint/agent.sh | Spec: `docs/ops/specs/tools/lint/agent.md`. Enforces agent schema, pointer validity, and disposable-artifact hazard rules. |
| LINT-02 | Context Lint | tools/lint/context.sh | Spec: `docs/ops/specs/tools/lint/context.md`. Verifies context manifest completeness and context-hazard exclusions. |
| LINT-03 | DP Lint | tools/lint/dp.sh | Spec: `docs/ops/specs/tools/lint/dp.md`. Validates DP schema and receipt contract with TASK Section 3 extraction support. |
| LINT-04 | Library Lint | tools/lint/library.sh | Spec: `docs/ops/specs/tools/lint/library.md`. Verifies agent/skill/task registry synchronization and pointer integrity. |
| LINT-05 | LLMS Lint | tools/lint/llms.sh | Spec: `docs/ops/specs/tools/lint/llms.md`. Re-generates llms bundles in temp space and diffs against repo outputs. |
| LINT-06 | Project Lint | tools/lint/project.sh | Spec: `docs/ops/specs/tools/lint/project.md`. Validates project STELA references against registered agents, tasks, and skills. |
| LINT-07 | Style Lint | tools/lint/style.sh | Spec: `docs/ops/specs/tools/lint/style.md`. Rejects markdown contractions across tracked documentation surfaces. |
| LINT-08 | TASK Lint | tools/lint/task.sh | Spec: `docs/ops/specs/tools/lint/task.md`. Sole TASK dashboard and task-library schema enforcer. |
| LINT-09 | Truth Lint | tools/lint/truth.sh | Spec: `docs/ops/specs/tools/lint/truth.md`. Scans authored surfaces for forbidden canon spellings. |
