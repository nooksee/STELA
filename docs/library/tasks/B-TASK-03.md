# Task: Integrate Command

## Provenance
- **Captured:** 2026-02-08 01:51:44 UTC
- **DP-ID:** DP-OPS-0036
- **Branch:** work/task-hardening-0036
- **HEAD:** eeafcc36cda18155944a5441eaebe7fba4856cf8
- **Objective:** Bring the Task subsystem to pointer-first parity with Agents and Skills by adding a Task promotion ledger, a harvest and promote workflow, and lint enforcement, while refactoring B-TASK-01 through B-TASK-10 to the strict schema and aligning the registry.

## Orchestration
- **Primary Agent:** R-AGENT-04 (integrator)
- **Supporting Agents:** R-AGENT-02 (code-reviewer), R-AGENT-06 (security-reviewer)

## Pointers
- **Constitution:** `PoT.md`
- **Governance:** `docs/GOVERNANCE.md`
- **Contract:** `TASK.md`
- **Registry:** `docs/ops/registry/TASKS.md`
- **Toolchain:** `ops/bin/open`, `ops/bin/dump`
- **JIT Skills:** `docs/library/skills/S-LEARN-06.md`
- **Reference Docs:** `docs/MANUAL.md`

## Execution Logic
1. Run `ops/bin/open --intent="Integration run" --out=auto` and capture the generated OPEN artifact.
2. Run `ops/bin/dump --scope=platform --format=chatgpt --out=auto` and capture the dump artifact.
3. Use `docs/library/agents/R-AGENT-04.md` to produce the integration plan and the first handoff.
4. Use `docs/library/agents/R-AGENT-02.md` to perform code review and append a second handoff.
5. If the scope includes security-sensitive changes, use `docs/library/agents/R-AGENT-06.md` to perform security review and append the final handoff.
6. Compile a final integration report that references each handoff artifact.

## Scope Boundary
- **Allowed:** Orchestrate the agent sequence for the active DP and record handoffs.
- **Forbidden:** Do not bypass required reviews or add new agents without DP approval.
- **Stop Conditions:** Stop if required artifacts are missing or if any mandated agent handoff is incomplete.
