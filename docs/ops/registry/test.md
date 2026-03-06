<!-- CCD: ff_target="operator-technical" ff_band="25-35" -->
# Test Registry

Authoritative registry for `tools/test/*` executables.

| ID | Name | File Path | Notes |
| --- | --- | --- | --- |
| TEST-01 | Agent Pointer Test | tools/test/agent.sh | Spec: `docs/ops/specs/tools/test/agent.md`. Verifies agent pointer and toolchain path integrity with drift-injection guard. |
| TEST-02 | Bundle Smoke Test | tools/test/bundle.sh | Spec: `docs/ops/specs/tools/test/bundle.md`. Verifies bundle profile routing, canonical profile-prefix artifact naming contract, compatibility legacy `BUNDLE-*` artifact metadata, manifest field assertions, foreman guard paths, compatibility alias routing metadata (`auditor` -> `foreman`, `hygiene` -> `conform`), alias deprecation metadata emission (`deprecation_status`, `remove_after_dp`), ATS triplet validation coverage (`agent_id`, `skill_id`, `task_id`), and ATS runtime pointer emission behavior (`assembly.pointer` metadata and artifact path parity). |
| TEST-03 | OPEN De-dup Test | tools/test/open.sh | Spec: `docs/ops/specs/tools/test/open.md`. Verifies OPEN pointer-first porcelain behavior: OPEN carries summary plus OPEN-PORCELAIN path and does not embed inline porcelain payload blocks. |
| TEST-04 | Editor Scaffold Test | tools/test/editor.sh | Spec: `docs/ops/specs/tools/test/editor.md`. Verifies `ops/bin/draft` scaffold assist modes for emit, untouched-line rejection, file-ingest success, and interactive-simulated success. |
