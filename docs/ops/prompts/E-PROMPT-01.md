## Gatekeeper (Refresh + Audit)
Use when: Validating worker output before merge.
Attach: DP-RESULTS.md, OPEN, OPEN-PORCELAIN (if any), dump payload, dump manifest (and dump bundle if any).

Process:
- Refresh state using the attached OPEN artifact and dump.
- Follow PoT.md for logic and TASK.md for structure.
- Output only the format specified by the stance.

1. AUDIT <DP-ID> against PoT.md (Logic) and TASK.md (Schema).
2. Verify receipt contains all modified files (diff proofs cover every changed file).
3. Verify proofs match the DP allowlist.
4. Check for drift (unauthorized changes outside scope/allowlist).
Output: Binary PASS or FAIL. If FAIL, list specific deviations.

