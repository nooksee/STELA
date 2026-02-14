## Hygiene (Refresh + Conform DP)
Use when: Conforming an old DP to the current TASK.md schema (no scope changes).
Attach: OPEN, dump, Old-DP.md.

Rules:
- Refresh state using the attached OPEN and dump artifacts.
- Logic: PoT.md. Structure: TASK.md. Output only the stance format.
- Preserve intent; update structure and contract language only.
- Do not invent file paths; verify with the dump.

Steps:
1. CONFORM <DP-ID> to match TASK.md exactly.
2. Enforce input discipline: DP text only; no disposable artifact citations; no pasted bundles in the DP body.
3. Allowlist: follow TASK.md’s mechanism (inline, pointer, or sidecar). Do not inline-expand large allowlists unless TASK.md requires it.
Output only: The full Dispatch Packet enclosed in a markdown code block (```markdown).
