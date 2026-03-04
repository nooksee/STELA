<!-- CCD: ff_target="operator-technical" ff_band="25-35" -->
# Test Registry

Authoritative registry for `tools/test/*` executables.

| ID | Name | File Path | Notes |
| --- | --- | --- | --- |
| TEST-01 | Agent Pointer Test | tools/test/agent.sh | Spec: `docs/ops/specs/tools/test/agent.md`. Verifies agent pointer and toolchain path integrity with drift-injection guard. |
| TEST-02 | Bundle Smoke Test | tools/test/bundle.sh | Spec: `docs/ops/specs/tools/test/bundle.md`. Verifies bundle profile routing, artifact naming contract, manifest field assertions, and auditor guard paths. |
