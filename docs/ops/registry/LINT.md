# Lint Registry

Authoritative registry for `tools/lint/*` executables.

| ID | Name | File Path | Notes |
| --- | --- | --- | --- |
| LINT-01 | Agent Lint | tools/lint/agent.sh | Spec: `docs/ops/specs/tools/lint/agent.md`. Enforces agent schema, pointer validity, and disposable-artifact hazard rules. |
| LINT-02 | Context Lint | tools/lint/context.sh | Spec: `docs/ops/specs/tools/lint/context.md`. Verifies context manifest completeness and context-hazard exclusions. |
| LINT-03 | DP Lint | tools/lint/dp.sh | Spec: `docs/ops/specs/tools/lint/dp.md`. Validates DP schema and One Truth context-load rules (`llms-full.txt` prohibited, `llms-core.txt` lightweight-only). |
| LINT-04 | Factory Lint | tools/lint/factory.sh | Spec: `docs/ops/specs/tools/lint/.md`. Verifies agent/skill/task registry synchronization and pointer integrity. |
| LINT-05 | LLMS Lint | tools/lint/llms.sh | Spec: `docs/ops/specs/tools/lint/llms.md`. Re-generates llms bundles in temp space; enforces only `llms.txt`, `llms-core.txt`, and `llms-full.txt`; fails on deprecated slices. |
| LINT-06 | Project Lint | tools/lint/project.sh | Spec: `docs/ops/specs/tools/lint/project.md`. Validates project STELA references against registered agents, tasks, and skills. |
| LINT-07 | Style Lint | tools/lint/style.sh | Spec: `docs/ops/specs/tools/lint/style.md`. Rejects markdown contractions across tracked documentation surfaces. |
| LINT-08 | TASK Lint | tools/lint/task.sh | Spec: `docs/ops/specs/tools/lint/task.md`. Sole TASK dashboard and task-definitions schema enforcer. |
| LINT-09 | Truth Lint | tools/lint/truth.sh | Spec: `docs/ops/specs/tools/lint/truth.md`. Scans authored surfaces for forbidden canon spellings. |
| LINT-10 | Integrity Lint | tools/lint/integrity.sh | Spec: `docs/ops/specs/tools/lint/integrity.md`. Fails when changed or untracked paths are outside the active Target Files allowlist. |
| LINT-11 | RESULTS Lint | tools/lint/results.sh | Spec: `docs/ops/specs/tools/lint/results.md`. Verifies certification RESULTS schema, template hash parity, git hash parity, and Closing Block completeness. |
| LINT-12 | Schema Lint | tools/lint/schema.sh | Spec: `docs/ops/specs/tools/lint/schema.md`. Validates unified schema front-matter keys for `archives/definitions` leaves and enforces `created_at` and `previous` format rules. |
