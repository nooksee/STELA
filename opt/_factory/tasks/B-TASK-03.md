# Task: Integrate Command

## Provenance
- **Captured:** 2026-02-10 01:27:17 UTC
- **DP-ID:** DP-OPS-0039
- **Branch:** work/task-serviceability-0038
- **HEAD:** 03f47297e
- **Objective:** Certify the B-TASK definitions for serviceable execution by enforcing explicit Closeout pointers, strengthening quantitative reporting expectations, and hardening task lint to prevent drift.

## Orchestration
- **Primary Agent:** R-AGENT-04 (integrator)
- **Supporting Agents:** R-AGENT-02 (code-reviewer), R-AGENT-06 (security-reviewer)

## Pointers
- **Constitution:** `PoT.md`
- **Governance:** `docs/GOVERNANCE.md`
- **Contract:** `TASK.md`
- **Registry:** `docs/ops/registry/TASKS.md`
- **Toolchain:** `ops/bin/open`, `ops/bin/dump`
- **JIT Skills:** ``
- **Reference Docs:** `docs/MANUAL.md`

## Execution Logic
1. Run `ops/bin/open --intent="Integration run" --out=auto` and capture the generated OPEN artifact.
2. Run `ops/bin/dump --scope=platform --format=chatgpt --out=auto` and capture the dump artifact.
3. Use `opt/_factory/agents/R-AGENT-04.md` to produce the integration plan and the first handoff.
4. Use `opt/_factory/agents/R-AGENT-02.md` to perform code review and append a second handoff.
5. If the scope includes security-sensitive changes, use `opt/_factory/agents/R-AGENT-06.md` to perform security review and append the final handoff.
6. Compile a final integration report that references each handoff artifact.
7. Complete Closeout per `TASK.md` Section 3.5.

## Scope Boundary
- **Allowed:** Orchestrate the agent sequence for the active DP, record handoffs, and perform Closeout duties per `TASK.md` Section 3.5.
- **Forbidden:** Do not bypass required reviews or add new agents without DP approval.
- **Stop Conditions:** Stop if required artifacts are missing or if any mandated agent handoff is incomplete.
