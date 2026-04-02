<!-- CCD: ff_target="operator-technical" ff_band="25-35" -->
# Lint Registry

Authoritative registry for `tools/lint/*` executables.

| ID | Name | File Path | Infra Importance | Notes |
| --- | --- | --- | --- | --- |
| LINT-01 | Agent Lint | tools/lint/agent.sh | supporting | Spec: `docs/ops/specs/tools/lint/agent.md`. Enforces agent schema, pointer validity, and disposable-artifact hazard rules. |
| LINT-02 | Context Lint | tools/lint/context.sh | supporting | Spec: `docs/ops/specs/tools/lint/context.md`. Verifies context manifest completeness and context-hazard exclusions. |
| LINT-03 | DP Lint | tools/lint/dp.sh | important | Spec: `docs/ops/specs/tools/lint/dp.md`. Validates DP schema and One Truth context-load rules (`llms-full.txt` prohibited, `llms-core.txt` lightweight-only), resolves pointer-first `TASK.md` to its surface leaf before DP payload parsing, and rejects foreign citation contamination tokens in DP body text. |
| LINT-04 | Factory Lint | tools/lint/factory.sh | important | Spec: `docs/ops/specs/tools/lint/factory.md`. Verifies agent/skill/task registry synchronization, pointer integrity, and census coverage against `docs/ops/registry/factory.md`. |
| LINT-05 | LLMS Lint | tools/lint/llms.sh | supporting | Retired by DP-OPS-0102. Deprecated-filename check absorbed into ops/bin/llms. Staleness protection replaced by .github/hooks/llms. |
| LINT-06 | Project Lint | tools/lint/project.sh | supporting | Spec: `docs/ops/specs/tools/lint/project.md`. Deprecated: project registry is unpopulated, so this linter has no live targets. Reactivate when the project registry is populated and project scaffolding implementation is complete. |
| LINT-07 | Style Lint | tools/lint/style.sh | supporting | Spec: `docs/ops/specs/tools/lint/style.md`. Rejects markdown contractions across tracked documentation surfaces and enforces audit-versus-addenda mode split guard lines, audit output marker/no-citations lines, live compatibility alias deprecation key lines in the bundle policy manifest, and canonical OPEN marker contract lines in `ops/bin/open` (with legacy marker regression blocked). |
| LINT-08 | TASK Lint | tools/lint/task.sh | important | Spec: `docs/ops/specs/tools/lint/task.md`. Sole TASK dashboard and task-definitions schema enforcer; resolves pointer-first `TASK.md` heads to archives/surfaces leaves before linting dashboard content. |
| LINT-09 | Truth Lint | tools/lint/truth.sh | supporting | Spec: `docs/ops/specs/tools/lint/truth.md`. Scans authored surfaces for forbidden canon spellings. |
| LINT-10 | Integrity Lint | tools/lint/integrity.sh | critical | Spec: `docs/ops/specs/tools/lint/integrity.md`. Fails when changed or untracked paths are outside the active Target Files allowlist; resolves pointer-first `TASK.md` to extract allowlist pointers from the leaf payload; enforces explicit `PoT.md` authorization in DP `In scope` or `3.4.3 Changelog UPDATE` when constitutional text is edited. |
| LINT-11 | RESULTS Lint | tools/lint/results.sh | critical | Spec: `docs/ops/specs/tools/lint/results.md`. Verifies certification RESULTS schema, template hash parity, Worker Execution Narrative requirements, and Decision Required/Decision Leaf coherence. Hash parity and decision coherence are strict for explicit or inferred-active targets; `--all` runs remain historical structure scans with non-blocking skip notes. |
| LINT-12 | Schema Lint | tools/lint/schema.sh | supporting | Spec: `docs/ops/specs/tools/lint/schema.md`. Validates unified schema front-matter keys for `archives/definitions` leaves and Phase 2 surface leaves in `archives/surfaces` (PoW/SoP/TASK snapshots), enforcing `created_at` and `previous` format rules. |
| LINT-13 | Leaf Lint | tools/lint/leaf.sh | supporting | Spec: `docs/ops/specs/tools/lint/leaf.md`. Validates archive surface leaf schema and pointer integrity for `archives/surfaces/` entries. |
| LINT-14 | Skill Lint | tools/lint/skill.sh | supporting | Spec: `docs/ops/specs/tools/lint/skill.md`. Enforces skill registry synchronization and pointer integrity for skill definition leaves. |
| LINT-15 | Feynman Frequency Lint | tools/lint/ff.sh | supporting | Spec: `docs/ops/specs/tools/lint/ff.md`. Scores tracked markdown files against declared CCD density headers (`<!-- CCD: ... -->` or YAML `ff_target`/`ff_band` fields). Fails when declared files score outside band tolerance, and fails when Wave 1 or Wave 2 hardened paths miss a CCD header. Non-hardened undeclared files emit WARNING; Wave 0 paths remain exempt. |
| LINT-16 | PLAN Lint | tools/lint/plan.sh | supporting | Spec: `docs/ops/specs/tools/lint/plan.md`. Deterministic safety-floor check for `storage/handoff/PLAN.md` used by bundle route gating; enforces the required core heading floor and allows additional peer sections. |
| LINT-17 | Response Lint | tools/lint/response.sh | important | Spec: `docs/ops/specs/tools/lint/response.md`. Enforces strict fenced-envelope intake for machine markdown ingress in `--mode=dp|audit|draft|planning|addenda|execution-decision`, aligns cross-stance freeze keys in `ops/src/shared/stances.json`, applies marker and contamination-token rejection, rejects draft/planning/addenda role-drift markers, enforces addenda addendum-structure checks plus decision-field coherence when present, delegates structural DP validation in `dp` and `draft` modes, and validates execution-decision step-block structure. |
| LINT-18 | Debt Lint | tools/lint/debt.sh | supporting | Spec: `docs/ops/specs/tools/lint/debt.md`. Validates `ops/lib/manifests/DEBT.md` row schema, enforces required lifecycle fields (`added_in`, `owner`, `remove_by_dp`, `reason`), and fails on stale active debt past removal packet threshold. |

## Gate Status Decisions (2026-02-19)
- `tools/lint/project.sh` is formally deprecated.
  - Reason: project registry is unpopulated, and the linter is dead logic with no live targets.
  - Reactivation condition: populate the project registry and ship the project scaffolding system.
- Shadow-enforcement evaluation against `tools/test/agent.sh` is not complete for deferred-gate use.
  - `tools/lint/context.sh` gap: `tools/test/agent.sh` does not validate context-manifest completeness, context-hazard exclusions, or contamination scanning.
  - `tools/lint/agent.sh` gap: `tools/test/agent.sh` covers pointer/toolchain reachability only and does not enforce full registry duplicate checks, provenance field requirements, hazard-pattern bans, and strict section-content checks.
  - Decision: do not defer these gates; include `tools/lint/context.sh` and `tools/lint/agent.sh` in `.github/workflows/gates.yml` for this DP.
