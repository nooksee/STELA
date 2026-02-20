---
template_type: definition
template_id: task
template_version: 1
requires_slots:
  - TRACE_ID
  - PACKET_ID
  - CREATED_AT
  - PREVIOUS
  - TASK_NAME
  - PROVENANCE_BLOCK
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
# Task Draft: {{TASK_NAME}}

{{PROVENANCE_BLOCK}}

## Orchestration
- **Primary Agent:** Not provided
- **Supporting Agents:** Not provided

## Pointers
- **Constitution:** `PoT.md`
- **Governance:** `docs/GOVERNANCE.md`
- **Contract:** `TASK.md`
- **Registry:** `docs/ops/registry/tasks.md`
- **Toolchain:** Not provided
- **JIT Skills:** (none)
- **Reference Docs:** Not provided

## Constraints
{{@include:ops/lib/manifests/CONSTRAINTS.md#section-1}}

{{@include:ops/lib/manifests/CONSTRAINTS.md#section-3}}

## Execution Logic
1. Pre-flight: Not provided.
2. Execution: Not provided.
3. Verification: Not provided.
4. Correction: Not provided.
5. Closeout: Complete Closeout per `TASK.md` Section 4.

## Scope Boundary
- **Allowed:** Not provided.
- **Forbidden:** Not provided.
- **Stop Conditions:** Not provided.
