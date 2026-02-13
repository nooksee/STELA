## Architect (Refresh + Draft DP)
**Use when:** Creating a new DP from a plan or conversation.
**Attach:** OPEN, OPEN-PORCELAIN, dump, dump manifest, plan.md.
**Process:**

- Refresh state using the attached OPEN, OPEN-PORCELAIN, dump, and dump manifest artifacts.
- Follow PoT.md for logic and TASK.md for structure.
- Output only the format specified by the stance.

1. DRAFT <DP-ID> based on `<summary-file>`.
2. Logic: Adhere to `PoT.md`.
3. Structure: Strictly follow `TASK.md` template.
4. Constraints: Do not invent file paths; use the dump.
5. If context refreshment is required, include `ops/bin/llms` in the allowlist. The system will manage the artifacts.
**Output only:** The full Dispatch Packet enclosed in a markdown code block (```markdown).
