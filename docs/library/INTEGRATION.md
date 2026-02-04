# INTEGRATION (Operator Guide)

This document explains when and how to use integration as an operator.
The canonical runtime contract lives in:
- ops/lib/project/INTEGRATION.md

## 1. What integration is for

Use integration when a single agent stance is insufficient and you need:
- multiple perspectives (plan, quality review, security review)
- structured handoffs between those perspectives
- a single final report with a clear recommendation

Integration is a sequencing tool. It does not change governance rules.

## 2. Default workflows

These workflows are standardized:

- feature:
  integrator -> code-reviewer -> security-reviewer

- bugfix:
  explorer -> code-reviewer

- refactor:
  architect -> code-reviewer

- security:
  security-reviewer -> code-reviewer -> architect

If you need a bespoke chain, use the custom workflow described in B-TASK-03.

## 3. What you should expect as output

Integration produces two artifact types:

1) HANDOFF artifacts between agents:
- Context
- Findings
- Files Modified
- Open Questions
- Recommendations

2) A single INTEGRATION REPORT at the end:
- Workflow, Task, Agents
- Summary
- Agent Outputs
- Files Changed
- Test Results
- Security Status
- Recommendation (SHIP / NEEDS WORK / BLOCKED)

## 4. How this relates to Agents and AGENTS.md

- AGENTS.md defines jurisdiction and human-vs-AI operating rules.
- docs/library/agents/R-AGENT-XX define the available roles (architect, code-reviewer, security-reviewer, etc.).
- Integration selects from those role definitions and sequences them.
It is a coordination layer, not a new role.

## 5. Parallel phases (when allowed)

Parallel phases are allowed only for independent checks.
Typical parallel trio:
- code-reviewer (quality)
- security-reviewer (security)
- architect (design)

The orchestrator must merge parallel outputs into one merged handoff before continuing.

## 6. Canon placement rule (why this file is short)

docs/ is the manual and should point into ops/ for operational canon.
That is why detailed mechanics live in ops/lib/project/INTEGRATION.md and this file stays operator-focused.