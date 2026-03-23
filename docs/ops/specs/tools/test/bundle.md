<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
# Technical Specification: tools/test/bundle.sh

## Purpose
Verify bundle transport-kernel truth: profile routing, required/forbidden package membership, fail-closed behavior on missing inputs or invalid profiles, and audit rerun lineage identity. The test does not check stance wording, shipping-spine prose, or operator-facing narration; those belong to certify and audit, not bundle smoke.

## Invocation
- `bash tools/test/bundle.sh`
- `bash tools/test/bundle.sh --mode=certify-critical`
- `bash tools/test/bundle.sh --slice=route-contract|package-contract|fail-closed|rerun-lineage`

## Slice Contract
- `route-contract`: planning, draft, auto, and alias route behavior; asserts `resolved_profile`, artifact naming prefix, and basic dump manifest fields from structured JSON sources only.
- `package-contract`: required/forbidden package membership per profile; planning includes `TOPIC.md` and excludes `PLAN.md`; draft includes `PLAN.md`; audit includes resolved `RESULTS.md` and `CLOSING.md`.
- `fail-closed`: missing `TOPIC.md` fails planning; missing `PLAN.md` fails draft; missing `RESULTS.md` or `CLOSING.md` fails audit; invalid profile fails closed.
- `rerun-lineage`: initial audit stays `AUDIT-*`; repeat without `--rerun` stays `AUDIT-*` even when prior artifact exists; explicit `--rerun` becomes `AUDIT-R1-*`; rerun manifest records `submission.kind: audit_resubmission`, `submission.resubmission_index: 1`, and `submission.supersedes_bundle_path`.

## Ephemeral Isolation Contract
Each test run generates a unique ephemeral input root at `var/tmp/_smoke/<pid>/`. The environment variable `BUNDLE_TEST_HANDOFF_ROOT` is exported to this root so bundle reads all handoff input surfaces (TOPIC.md, PLAN.md, RESULTS.md, CLOSING.md, TASK.md) from the ephemeral root instead of live `storage/handoff/` or live `TASK.md`. Output routing is unchanged; bundle artifacts go to `var/tmp/_smoke/handoff/` and dump outputs go to `var/tmp/_smoke/dumps/` as defined by BUNDLE.md policy. Before/after `git status --porcelain` is unchanged by the test run.

## Invariants and Failure Modes
- Valid profiles `planning`, `draft`, `audit`, `conform`, and `auto` must succeed when required inputs are present.
- Planning requires `TOPIC.md` in the ephemeral root; fails closed when absent.
- Draft requires `PLAN.md` in the ephemeral root; fails closed when absent.
- Audit requires `RESULTS.md` and `CLOSING.md` in the ephemeral root; fails closed when either is absent.
- Audit rerun identity contract:
  - first submission stays `AUDIT-*`
  - repeat without `--rerun` stays `AUDIT-*` even when prior artifact exists
  - explicit `--rerun` becomes `AUDIT-R1-*`
  - rerun manifest records `submission.kind: audit_resubmission`, `submission.resubmission_index: 1`, `submission.supersedes_bundle_path`
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
