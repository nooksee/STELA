<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`.github/hooks/pre-commit` exists to stop invalid local commit attempts before they enter packet flow and to reject stale generated context without changing the candidate being committed. Branch protection and generated-context freshness remain one visible local boundary, while content generation remains an explicit operation whose complete output can be reviewed and staged deliberately.

## Mechanics and Sequencing
The hook resolves repository root from Git, changes into that root, and reads the current branch name. It fails immediately on `main` and on any branch not matching `work/*`. After the branch guard passes, it requires `tools/lint/llms.sh` and invokes that read-only parity gate. A fresh candidate proceeds without tracked, staged, or compile-archive mutations. A stale candidate fails with instructions to run `ops/bin/llms`, inspect every generated change, stage the intended files explicitly, and retry the commit.

## Bypass and Limits
`git commit --no-verify` bypasses this hook. That bypass exists because Git permits it, not because the guard is optional. The hook does not generate context, stage files, prove post-merge freshness, or replace certification, integrity lint, GitHub gates, or push-time protections. `ops/bin/hooks --test` exercises activation, branch rejection, a path-limited real commit, compile-evidence stability, and fail-closed stale-context behavior in an isolated repository.
