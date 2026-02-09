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
1. Audit the DP identifier against PoT.md and TASK.md.
2. Verify the receipt lists all modified files.
3. Verify proofs match the allowlist.
4. Check for drift outside scope.
**Output:** Binary PASS or FAIL. If FAIL, list specific deviations.

## 2. Hygiene (Refresh + Conform DP)
**Use when:** Updating an old or broken DP to the current TASK.md standard.
**Attach:** OPEN, dump, Old-DP.md.
**Process:**
1. Conform the DP to the current TASK.md headings and order.
2. Preserve original intent and update format only.
3. Do not invent file paths. Use the dump for verification.
**Output:** The corrected Dispatch Packet only.

## 3. Architect (Refresh + Draft DP)
**Use when:** Creating a new DP from a plan or conversation.
**Attach:** OPEN, dump, plan.md.
**Process:**
1. Draft the DP using PoT.md and the TASK.md template.
2. Do not invent file paths. Use the dump for verification.
**Addendum:** If the DP plan includes an llms command invocation or a context bundle refresh objective, the DP allowlist must include the repository root outputs: llms.txt, llms-small.txt, llms-full.txt, llms-ops.txt, and llms-governance.txt. These are repository root files and must be allowlisted before running the llms command.
**Output:** The full Dispatch Packet only.

## 4. Analyst (Refresh + Discuss)
**Use when:** Analyzing the codebase without intent to edit.
**Attach:** OPEN, dump.
**Process:**
1. Operate in read-only mode.
2. Reference docs/MAP.md for architecture and SoP.md for history.
3. Await the operator query.
**Output:** Discussion only. No edits and no commands.
