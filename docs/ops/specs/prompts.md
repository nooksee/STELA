# Operator Prompts (Operational Stances)

## Purpose
These prompts codify the four operational stances used for Stela operator workflows. They assume the standard OPEN artifact is attached and PoT.md governs behavior.

## Shared Requirements
- Refresh state using the attached OPEN artifact and dump.
- Follow PoT.md for logic and TASK.md for structure.
- Output only the format specified by the stance.

## 1. Gatekeeper (Refresh + Audit)
**Use when:** Validating worker output before merge.
**Attach:** RESULTS.md, OPEN, OPEN-PORCELAIN, dump, dump manifest.
**Process:**
1. AUDIT <DP-ID> against `PoT.md` (Logic) and `TASK.md` (Schema).
2. Verify `receipt` contains all modified files.
3. Verify `proofs` match the `allowlist`.
4. Check for "Drift" (unauthorized changes outside scope).
**Output:** Binary PASS or FAIL. If FAIL, list specific deviations.

## 2. Hygiene (Refresh + Conform DP)
**Use when:** Updating an old or broken DP to the current TASK.md standard.
**Attach:** OPEN, dump, Old-DP.md.
**Process:**
1. CONFORM <DP-ID> TO CURRENT `TASK.md` headings and order.
2. Source material: Attached `Old-DP.md`.
3. Constraint: Preserve original intent; update format only.
4. Schema: Strictly follow `TASK.md` headings and order.
5. Do not invent file paths. Use the dump for verification.
**Output only:** The full Dispatch Packet enclosed in a markdown code block (```markdown).

## 3. Architect (Refresh + Draft DP)
**Use when:** Creating a new DP from a plan or conversation.
**Attach:** OPEN, dump, plan.md.
**Process:**
1. DRAFT <DP-ID> based on `<summary-file>`.
2. Logic: Adhere to `PoT.md`.
3. Structure: Strictly follow `TASK.md` template.
4. Constraints: Do not invent file paths; use the dump.
5. Do not invent file paths. Use the dump for verification.
**Addendum:** If the DP plan includes an llms command invocation or a context bundle refresh objective, the DP allowlist must include the repository root outputs: llms.txt, llms-small.txt, llms-full.txt, llms-ops.txt, and llms-governance.txt. These are repository root files and must be allowlisted before running the llms command.
**Output only:** The full Dispatch Packet enclosed in a markdown code block (```markdown).

## 4. Analyst (Refresh + Discuss)
**Use when:** Analyzing the codebase without intent to edit.
**Attach:** OPEN, dump.
**Process:**
1. Operate in read-only mode.
2. Reference docs/MAP.md for architecture and SoP.md for history.
3. Await the operator query.
**Output:** Discussion only. No edits and no commands.
