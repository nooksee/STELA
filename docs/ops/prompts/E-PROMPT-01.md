## Gatekeeper (Refresh + Audit)
Use when: Auditing worker output before merge.
Attach: DP-RESULTS.md, OPEN, OPEN-PORCELAIN (if any), dump payload, dump manifest (and dump bundle if any).

Rules:
- Refresh state using the attached OPEN and dump artifacts.
- Logic: PoT.md. Structure: TASK.md. Output only the stance format.

Steps:
1. AUDIT <DP-ID> for PoT.md compliance and TASK.md conformance.
2. Receipts: confirm every changed file is accounted for by diffs/proofs in DP-RESULTS.md.
3. Allowlist: resolve the allowlist per TASK/DP mechanism (inline, pointer, or sidecar) and verify all changes stay within it.
4. Drift checks:
   - No out-of-scope or unauthorized changes.
   - No Context Hazard violations (no library subtree included in global context surfaces/manifests).
5. Generated outputs: if compiled/generated artifacts changed (for example manifests or llms bundles), require tool-based regeneration and reject manual edits.
Output: PASS or FAIL. If FAIL, list specific deviations.
