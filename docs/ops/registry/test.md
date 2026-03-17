<!-- CCD: ff_target="operator-technical" ff_band="25-35" -->
# Test Registry

Authoritative registry for `tools/test/*` executables.

| ID | Name | File Path | Infra Importance | Notes |
| --- | --- | --- | --- | --- |
| TEST-01 | Agent Pointer Test | tools/test/agent.sh | supporting | Spec: `docs/ops/specs/tools/test/agent.md`. Verifies agent pointer and toolchain path integrity with drift-injection guard. |
| TEST-02 | Bundle Smoke Test | tools/test/bundle.sh | critical | Spec: `docs/ops/specs/tools/test/bundle.md`. Verifies split bundle slices for closeout sanity, audit coherence, route contract, and rerun lineage; also covers profile routing, artifact naming, architect slice request metadata, compatibility alias routing, ATS pointer emission, and project-shim delegation behavior. |
| TEST-03 | OPEN De-dup Test | tools/test/open.sh | critical | Spec: `docs/ops/specs/tools/test/open.md`. Verifies OPEN pointer-first porcelain behavior: OPEN carries summary plus OPEN-PORCELAIN path and does not embed inline porcelain payload blocks. |
| TEST-04 | Editor Scaffold Test | tools/test/editor.sh | supporting | Spec: `docs/ops/specs/tools/test/editor.md`. Verifies `ops/bin/draft` scaffold assist modes for emit, untouched-line rejection, file-ingest success, and interactive-simulated success. |
| TEST-05 | Factory Smoke Test | tools/test/factory.sh | important | Spec: `docs/ops/specs/tools/test/factory.md`. Verifies ATS triplet smoke execution for `R-AGENT-09`, `S-LEARN-09`, and `B-TASK-09` through `ops/bin/bundle`, including assembly metadata and artifact assertions. |
