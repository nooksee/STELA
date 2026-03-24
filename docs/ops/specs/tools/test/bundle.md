<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
# Technical Specification: tools/test/bundle.sh

## Purpose
Verify bundle transport-kernel truth: profile routing, OPEN-anchor reuse/refresh behavior, required/forbidden package membership, fail-closed behavior on missing inputs or invalid profiles, and audit rerun lineage identity. The test does not check stance wording, shipping-spine prose, or operator-facing narration; those belong to certify and audit, not bundle smoke.

## Invocation
- `bash tools/test/bundle.sh`
- `bash tools/test/bundle.sh --mode=certify-critical`
- `bash tools/test/bundle.sh --slice=route-contract|package-contract|fail-closed|rerun-lineage`

## Slice Contract
- `route-contract`: planning, draft, auto, and alias route behavior; asserts `resolved_profile`, artifact naming prefix, and OPEN-anchor metadata from structured JSON sources only. The first run must refresh a real OPEN artifact under the active handoff root when none exists; subsequent same-branch/head runs reuse that artifact instead of inventing a new transport-only trace id.
- `package-contract`: required/forbidden package membership per profile; planning includes `TOPIC.md` and excludes `PLAN.md`; draft includes `PLAN.md`; audit includes resolved `RESULTS.md` and `CLOSING.md`.
- `fail-closed`: missing `TOPIC.md` fails planning; missing `PLAN.md` fails draft; missing `RESULTS.md` or `CLOSING.md` fails audit; invalid profile fails closed.
- `rerun-lineage`: initial audit stays `AUDIT-*`; repeat without `--rerun` stays `AUDIT-*` even when prior artifact exists; explicit `--rerun` becomes `AUDIT-R1-*` whether or not a prior local artifact exists. If no prior local artifact exists, `submission.supersedes_bundle_path` remains null; otherwise it points to the superseded local bundle.

## Ephemeral Isolation Contract
Each test run generates a unique ephemeral input root at `var/tmp/_smoke/<pid>/`. The environment variable `BUNDLE_TEST_HANDOFF_ROOT` is exported to this root so bundle reads all handoff input surfaces (TOPIC.md, PLAN.md, RESULTS.md, CLOSING.md, TASK.md) from the ephemeral root instead of live `storage/handoff/` or live `TASK.md`. When bundle needs to refresh OPEN, it routes `ops/bin/open` into this same ephemeral handoff root through `OPEN_HANDOFF_BASE`, so smoke runs never touch live `storage/handoff/`. Output routing is unchanged; bundle artifacts go to `var/tmp/_smoke/handoff/` and dump outputs go to `var/tmp/_smoke/dumps/` as defined by BUNDLE.md policy. Before/after `git status --porcelain` is unchanged by the test run.

## Invariants and Failure Modes
- Valid profiles `planning`, `draft`, `audit`, `conform`, and `auto` must succeed when required inputs are present.
- Planning requires `TOPIC.md` in the ephemeral root; fails closed when absent.
- When no OPEN exists in the ephemeral root, the first successful bundle run refreshes one there and records `open.embedded=false`, an `open.artifact_path` under the ephemeral root, `open.source=refreshed`, and a non-empty `open.trace_id` in the manifest.
- When a current OPEN already exists for the active branch/head, later bundle runs reuse it and record `open.source=reused`.
- Draft requires `PLAN.md` in the ephemeral root; fails closed when absent.
- Audit requires `RESULTS.md` and `CLOSING.md` in the ephemeral root; fails closed when either is absent.
- Audit rerun identity contract:
  - first submission stays `AUDIT-*`
  - repeat without `--rerun` stays `AUDIT-*` even when prior artifact exists
  - explicit `--rerun` becomes `AUDIT-R1-*` even when no prior local artifact exists
  - rerun without prior local artifact records `submission.kind: audit_resubmission`, `submission.resubmission_index: 1`, `submission.supersedes_bundle_path: null`
  - rerun with a prior local artifact records `submission.kind: audit_resubmission`, `submission.resubmission_index: 1`, and a non-null `submission.supersedes_bundle_path`
- `--mode=certify-critical` inspects `git diff --name-only` and `git ls-files --others --exclude-standard` at test entry; if no watched path appears in the combined set, prints one skip line and exits 0; otherwise runs all four slices.
- Watched paths for `--mode=certify-critical`: `ops/bin/bundle`, `ops/lib/scripts/bundle.sh`, `ops/lib/manifests/BUNDLE.md`, `tools/test/bundle.sh`.
- Explicit `--slice=...` always forces execution regardless of mode.
- `--mode=certify-critical` must not run the full planning/draft/ATS/meta matrix.

## Cleanup Contract
The cleanup trap removes the active run's ephemeral input root (`var/tmp/_smoke/<pid>/`) and individually tracked bundle output artifacts from `var/tmp/_smoke/handoff/`. Cleanup is confined to `var/tmp/_smoke/`; no live `TASK.md`, `storage/handoff/*`, or `storage/dp/*` is written or restored by the test.

## Related Pointers
- Registry entry: `docs/ops/registry/test.md` (`TEST-02`)
- Runtime implementation: `ops/lib/scripts/bundle.sh`
- Isolation env var: `BUNDLE_TEST_HANDOFF_ROOT` (test-only; never set by operator workflows)
