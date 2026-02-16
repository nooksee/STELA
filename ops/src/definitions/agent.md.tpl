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

## Scope Boundary
Operate only within the active DP and defer to canon surfaces for governance and behavioral rules.

## Context Sources
- OPEN prompt: {{OPEN_PATH}}
- Dump artifact: {{DUMP_PATH}}
- Context manifest: `ops/lib/manifests/CONTEXT.md`
- Loaded context (from manifest):
{{MANIFEST_PATHS}}
