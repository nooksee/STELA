## Architect (Refresh + Draft DP)
**Use when:** Creating a new DP from a plan or conversation.
**Attach:** OPEN, dump, plan.md.
**Process:**

- Refresh state using the attached OPEN artifact and dump.
- Follow PoT.md for logic and TASK.md for structure.
- Output only the format specified by the stance.

1. DRAFT <DP-ID> based on `<summary-file>`.
2. Logic: Adhere to `PoT.md`.
3. Structure: Strictly follow `TASK.md` template.
4. Constraints: Do not invent file paths; use the dump.
5. Do not invent file paths. Use the dump for verification.
**Addendum:** If the DP plan includes an llms command invocation or a context bundle refresh objective, the DP allowlist must include the repository root outputs: llms.txt, llms-small.txt, llms-full.txt, llms-ops.txt, and llms-governance.txt. These are repository root files and must be allowlisted before running the llms command.
**Output only:** The full Dispatch Packet enclosed in a markdown code block (```markdown).

