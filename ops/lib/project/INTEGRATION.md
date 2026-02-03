# INTEGRATION (Projects Runtime Contract)

This file defines the integration contract implemented by the Projects binary (ops/lib/project):
how it composes Tasks + Agents + Skills into a single, auditable execution flow.

## 1. Purpose

Integration is a deterministic composition layer:
- Input: a workflow selection plus a task description
- Process: run a known agent sequence, passing structured handoffs
- Output: a single final report with aggregated evidence and a recommendation

The orchestrator does not define agent behavior. It only:
- selects agents
- enforces handoff structure
- enforces final report structure
- aggregates outputs

## 2. Inputs

### 2.1 Required
- workflow_type: one of { feature, bugfix, refactor, security, custom }
- task_description: freeform string

### 2.2 Optional
- custom_agents: comma-separated list (only when workflow_type=custom)
- arguments: opaque passthrough string for future extension

## 3. Workflow Registry

Default workflow mappings MUST match docs/library/tasks/B-TASK-03.md:

- feature:
  planner -> code-reviewer -> security-reviewer

- bugfix:
  explorer -> code-reviewer

- refactor:
  architect -> code-reviewer

- security:
  security-reviewer -> code-reviewer -> architect

- custom:
  user supplied list, executed in order

## 4. Agent Resolution

### 4.1 Agent identity
Agents are referenced by their canonical `name:` (for example: architect, code-reviewer).

### 4.2 Current storage location (source-of-truth for definitions)
- docs/library/agents/R-AGENT-XX.md

Each agent file contains:
- a YAML header (name, description, tools, model)
- a role body (what the agent does, how it responds)

The orchestrator resolves an agent name to a single agent definition.

### 4.3 Resolution rules
- Exact match on `name:` wins.
- If multiple matches exist, integration MUST fail fast and report ambiguity.
- If no match exists, integration MUST fail fast and report missing agent.

## 5. Execution Model

### 5.1 Sequential execution (default)
For each agent in the resolved chain:

1. Invoke agent_i with:
   - original task_description
   - the full set of prior handoffs (if any)
2. Capture agent output as a HANDOFF artifact (except final agent may emit Final Report)
3. Validate the HANDOFF structure (Section 6)
4. Pass the HANDOFF forward as context for agent_{i+1}

### 5.2 Parallel execution (optional phase)
Parallel execution is permitted only when the work is independent and the merge is deterministic.
If used, the orchestrator MUST:
- declare the parallel phase agents up front
- collect all parallel handoffs
- merge them into a single merged handoff before continuing

Parallel usage must follow the B-TASK-03 guidance for independent checks.

## 6. Required Handoff Artifact (between agents)

Between agents, the orchestrator MUST produce a handoff document with this structure:

## HANDOFF: [previous-agent] -> [next-agent]

### Context
[Summary of what was done]

### Findings
[Key discoveries or decisions]

### Files Modified
[List of files touched]

### Open Questions
[Unresolved items for next agent]

### Recommendations
[Suggested next steps]

Validation rules:
- All headings above MUST be present.
- Empty sections are permitted only if explicitly marked "None".

## 7. Final Report Artifact (end of run)

The orchestrator MUST emit a single final report matching this structure:

INTEGRATION REPORT
====================
Workflow: <workflow_type>
Task: <task_description>
Agents: <agent_1> -> <agent_2> -> ... -> <agent_n>

SUMMARY
-------
[One paragraph summary]

AGENT OUTPUTS
-------------
<agent_1>: [summary]
<agent_2>: [summary]
...

FILES CHANGED
-------------
[List all files modified]

TEST RESULTS
------------
[Test pass/fail summary, or "NOT RUN" if none]

SECURITY STATUS
---------------
[Security findings, or "NOT RUN" if none]

RECOMMENDATION
--------------
[SHIP / NEEDS WORK / BLOCKED]

## 8. Relationship to Tasks and Skills

- Tasks define operator-facing invocation and expected outputs (example: B-TASK-03).
- Agents define specialized analysis/execution behavior (R-AGENT-XX).
- Skills provide domain procedures and drift preventers (docs/library/skills/*).

Integration is the glue layer that:
- selects which agents to run
- enforces the handoff/report schemas
- ensures the output is auditable and merge-ready

## 9. Non-goals

- This file does not define how to write code, run tests, or change the repo.
- This file does not replace TRUTH.md, TASK.md, or AGENTS.md.
- This file does not redefine agent roles; it only sequences them.