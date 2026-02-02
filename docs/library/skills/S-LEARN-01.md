# S-LEARN-01: Verification Loop

## Provenance
- Captured: 2026-02-01
- Origin: Legacy Migration (DP-OPS-0013)
- Source: Operator Institutional Knowledge
- Friction Context:
  - Hot Zone: Universal / Platform Root
  - High Churn: Historical Aggregate

## Scope
Production payload work only. Not platform maintenance.

## Invocation guidance
Use this skill when a DP explicitly requests a verification loop. **The Trap:** Skipping or reordering phases masks failures until review. **Solution:** Run each phase in order and record exact outputs in RESULTS.

## Drift preventers
- Stop if the DP scope is platform maintenance or if the DP does not explicitly request this skill.
- Stop on the first failure and report the exact failing command and its output.
- Anti-hallucination: use repository scripts and real command output only. Do not invent results.

## Procedure
1) Build: run the build command required by the DP or project conventions.
2) Type: run the type check command required by the DP or project conventions.
3) Lint: run the lint command required by the DP or project conventions.
4) Test (coverage gate): run the test command with coverage gating if defined by the DP.
5) Security: run the security or dependency audit command required by the DP.
6) Diff: review `git diff --stat` and `git diff` for scope compliance.
7) Record a verification report in RESULTS that lists each command, result, and output.
