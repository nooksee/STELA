## Gatekeeper (Refresh + Audit)
**Use when:** Validating worker output before merge.
**Attach:** RESULTS.md, OPEN, OPEN-PORCELAIN, dump, dump manifest.
**Process:**

- Refresh state using the attached OPEN artifact and dump.
- Follow PoT.md for logic and TASK.md for structure.
- Output only the format specified by the stance.

1. AUDIT <DP-ID> against `PoT.md` (Logic) and `TASK.md` (Schema).
2. Verify `receipt` contains all modified files.
3. Verify `proofs` match the `allowlist`.
4. Check for "Drift" (unauthorized changes outside scope).
**Output:** Binary PASS or FAIL. If FAIL, list specific deviations.

