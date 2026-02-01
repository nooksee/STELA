# S-LEARN-01: Verification Loop

## Scope
Production payload work only. Not platform maintenance.

## Invocation guidance
Use this skill when a DP explicitly requests a verification loop. Follow the six phases in order and paste the verification report into RESULTS.

## Drift preventers
- Stop if the DP scope is platform maintenance or if the DP does not explicitly request this skill.
- Stop on the first failure and report the exact failing command and its output.
- Anti-hallucination: use repository scripts and real command output only. Do not invent results.

## Verification loop (six phases)
1) Build
2) Type
3) Lint
4) Test (coverage gate)
5) Security
6) Diff

## Phase guidance
- Build: run the build command required by the DP or project conventions.
- Type: run the type check command required by the DP or project conventions.
- Lint: run the lint command required by the DP or project conventions.
- Test (coverage gate): run the test command with coverage gating if defined by the DP.
- Security: run the security or dependency audit command required by the DP.
- Diff: review `git diff --stat` and `git diff` for scope compliance.

## Output template (paste into RESULTS)
```text
Verification Report (S-LEARN-01)
Build: RUN; Command: ENTER_BUILD_CMD; Result: PASS; Output: ENTER_BUILD_OUTPUT
Type: RUN; Command: ENTER_TYPE_CMD; Result: PASS; Output: ENTER_TYPE_OUTPUT
Lint: RUN; Command: ENTER_LINT_CMD; Result: PASS; Output: ENTER_LINT_OUTPUT
Test (coverage gate): RUN; Command: ENTER_TEST_CMD; Result: PASS; Output: ENTER_TEST_OUTPUT
Security: RUN; Command: ENTER_SECURITY_CMD; Result: PASS; Output: ENTER_SECURITY_OUTPUT
Diff: RUN; Command: git diff --stat; Result: PASS; Output: ENTER_DIFF_OUTPUT
```
