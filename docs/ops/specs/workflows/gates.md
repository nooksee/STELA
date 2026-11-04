<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`.github/workflows/gates.yml` is the outermost enforcement boundary of the repository. It runs the same gates on GitHub that the local hooks and `tools/verify.sh` run on a clone, so a branch that bypasses local hook activation still cannot merge stale generated context, a broken pointer head, or a schema violation into `main`. It exists because PoT.md Section 5.1 makes `main` verified state, and verification that depends on one operator's local setup is not verification.

## Mechanics and Sequencing
Trigger events: every `pull_request`, and every `push` to `main` (the merge commit itself is re-verified after merge).

The single job `gates` runs on `ubuntu-latest` with a full-history checkout (`fetch-depth: 0`) so diffs against the base branch resolve. Steps run in this order and the first failing step stops the job:

1. Compute changed paths (pull requests only): `git diff --name-only --diff-filter=ACMR origin/<base>...HEAD` into `var/tmp/gates-paths.txt`, and the added-only subset (`--diff-filter=A`) into `var/tmp/gates-added-paths.txt`. Later steps route on these files.
2. Surface HEAD pointer reachability: `PoW.md`, `SoP.md`, and `TASK.md` must each be one line, match `archives/surfaces/<name>.md`, and point at a file that exists.
3. Verify tree: `bash tools/verify.sh --mode=gates --paths-file=<changed paths>` on pull requests; `bash tools/verify.sh --mode=full` on pushes to `main`. Lane selection is governed by `ops/etc/verification.manifest`.
4. `bash tools/lint/truth.sh` (authored surfaces).
5. `bash tools/lint/schema.sh` on surface leaves, scoped by the changed and added path files on pull requests and unscoped on `main`.
6. `bash tools/lint/style.sh` (linguistic precision mandate).
7. `bash tools/lint/context.sh`.
8. `bash tools/lint/llms.sh` (read-only generated-context parity; the same gate the pre-commit hook runs).
9. `./ops/bin/hooks --test` (hook transaction contract).
10. `./ops/bin/help --test` (help doctrine contract).
11. `bash tools/lint/agent.sh`.
12. `bash tools/lint/factory.sh` (factory registry guard).
13. `bash tools/lint/dp.sh TASK.md` (TASK baseline packet lint).
14. `bash tools/lint/results.sh`.
15. `bash tools/lint/leaf.sh` (telemetry leaf coverage).

Failure behavior: the job fails on the first non-zero step and the pull request shows the failed check; there is no retry, skip, or partial-pass state. Steps 2 and 3 differ by event because a pull request is routed on its own diff while `main` is always verified in full.

## Anecdotal Anchor
The hook registry (`docs/ops/registry/hooks.md`) records that local hooks are opt-in per clone. The LLMS parity gate was reactivated as a content-parity gate after audit C-03 proved hook-only freshness incomplete; step 8 is the CI backstop that `docs/MANUAL.md` names for that gap.

## Integrity Filter Warnings
The workflow file is the only place the gate sequence is defined; this spec describes it and does not generate it. A change to the step list in `gates.yml` without a matching change here is docs drift under PoT.md Section 1.3. The workflow does not activate local hooks, does not write to the repository, and does not run `tools/lint/ff.sh`, `tools/lint/debt.sh`, or `tools/lint/project.sh`; those remain manual or `tools/verify.sh` lanes.
