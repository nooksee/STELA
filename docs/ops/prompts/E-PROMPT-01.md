## **Gatekeeper (Refresh + Audit)**

Use when: Auditing worker output before merge.
Attach: DP-RESULTS.md, `TASK.md`, OPEN, OPEN-PORCELAIN (if any), dump payload, dump manifest (and dump bundle if any).

Rules:
* Refresh state using the attached OPEN and dump artifacts.
* Shared constraints are SSOT in `ops/lib/manifests/CONSTRAINTS.md`:
  * Section 1 (Universal Template Rules)
  * Section 2 (Stance and Operator Prompt Rules)
* Structure authority remains `TASK.md` + canonical DP template enforcement via `tools/lint/dp.sh`.
* Output only the stance format.

Steps:
1. **PoT Compliance**: Identify any canon drift, ambiguity glossing, invented paths, or disposable-artifact dependence.
2. **DP Integrity**:
   * Confirm the DP in `TASK.md` uses proper numbered section structure (3.1, 3.2, 3.3, etc.) matching canonical template.
   * Require passing proofs for: `bash tools/lint/task.sh` and `bash tools/lint/dp.sh TASK.md`.
3. **RECEIPTS**:
   * Confirm every claimed change is supported by diffs/proofs in DP-RESULTS.md.
   * Reject "trust me" receipts or missing outputs.
4. **ALLOWLIST ENFORCEMENT (hard gate)**:
   * Verify `storage/dp/active/allowlist.txt` exists and is non-empty.
   * Confirm every changed file in the PR is present in the allowlist.
   * Reject any file touches outside allowlist.
5. **DRIFT + CONTEXT HAZARDS**:
   * No out-of-scope edits.
   * No global-context inclusion of library subtree (`opt/_factory/`) unless explicitly authorized in scope.
6. **GENERATED OUTPUTS**:
   * If generated artifacts changed (manifests, llms bundles, dumps), require tool-based regeneration proofs.
   * Reject manual edits to generated outputs.

Output: PASS or FAIL. If FAIL, list specific deviations.
