<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`.github/hooks/pre-commit` exists to stop invalid local commit attempts before they enter packet flow and to generate root `llms` bundle content from the proposed working state. It couples the branch guard and refresh/stage step in one tracked hook so the local commit path remains explainable without a second helper layer. The hook does not claim the identity of the future commit; content-derived identity and the independent LLMS gate prove freshness after commit and merge.

## Mechanics and Sequencing
The hook resolves repository root from git, changes into that root, and reads the current branch name. It fails immediately on `main` and on any branch not matching `work/*`. After the branch guard passes, it requires executable `ops/bin/llms`, runs `./ops/bin/llms`, and stages only `llms.txt`, `llms-core.txt`, and `llms-full.txt`. It does not auto-stage `OPS.md`; that file remains a refresh side effect unless staged explicitly by the operator.

## Bypass and Limits
`git commit --no-verify` bypasses this hook. That bypass exists because git permits it, not because the guard is optional. The hook enforces local branch and generation discipline only. It does not prove post-merge freshness and does not replace LLMS parity lint, certify, integrity lint, or push-time protections.
