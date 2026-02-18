---
template_type: definition
template_id: agent
template_version: 1
requires_slots:
  - TRACE_ID
  - PACKET_ID
  - CREATED_AT
  - PREVIOUS
  - AGENT_NAME
  - PROVENANCE_BLOCK
  - ROLE_SUMMARY
  - SPECIALIZATION
  - SKILL_LINES
  - OPEN_PATH
  - DUMP_PATH
  - MANIFEST_PATHS
includes:
  - ops/lib/manifests/CONSTRAINTS.md#section-1
  - ops/lib/manifests/CONSTRAINTS.md#section-3
---
---
trace_id: {{TRACE_ID}}
packet_id: {{PACKET_ID}}
created_at: {{CREATED_AT}}
previous: {{PREVIOUS}}
---
# Agent Draft: {{AGENT_NAME}}

{{PROVENANCE_BLOCK}}

## Role
{{ROLE_SUMMARY}}

## Specialization
{{SPECIALIZATION}}

## Pointers
- Constitution: `PoT.md`
- Governance/Jurisdiction: `docs/GOVERNANCE.md`
- Output contract: `TASK.md`
- Authorized toolchain: `ops/bin/open`, `ops/bin/dump`, `ops/bin/llms`, `tools/lint/context.sh`, `tools/lint/truth.sh`, `tools/lint/factory.sh`, `tools/verify.sh`
- JIT skills:
{{SKILL_LINES}}

## Constraints
{{@include:ops/lib/manifests/CONSTRAINTS.md#section-1}}

{{@include:ops/lib/manifests/CONSTRAINTS.md#section-3}}

## Scope Boundary
Operate only within the active DP and defer to canon surfaces for governance and behavioral rules.

## Context Sources
- OPEN prompt: {{OPEN_PATH}}
- Dump artifact: {{DUMP_PATH}}
- Context manifest: `ops/lib/manifests/CONTEXT.md`
- Loaded context (from manifest):
{{MANIFEST_PATHS}}
