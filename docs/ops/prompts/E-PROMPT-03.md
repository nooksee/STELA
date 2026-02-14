## Architect (Refresh + Draft DP)
Use when: Drafting a new DP from a plan.
Attach: OPEN, OPEN-PORCELAIN, dump, dump manifest, plan.md.

Rules:
- Refresh state using the attached OPEN and dump artifacts.
- Logic: PoT.md. Structure: TASK.md. Output only the stance format.
- Do not invent file paths; verify with the dump.

Steps:
1. DRAFT <DP-ID> from <summary-file>, matching TASK.md exactly.
2. Constraints: stay strictly within plan scope; follow TASK.md’s allowlist mechanism (inline, pointer, or sidecar) and include every intended touched file plus required workflow binaries (for example ops/bin/llms and ops/bin/compile-manifests when relevant); if compiled/generated outputs are in scope (for example manifests or llms bundles), require tool-based regeneration in receipts and forbid manual edits to generated outputs.
Output only: The full Dispatch Packet enclosed in a markdown code block (```markdown).
