<!-- CCD: ff_target="operator-technical" ff_band="25-35" -->
# Hook Registry

Authoritative registry for tracked git hooks under `.github/hooks/`.

| ID | Name | File Path | Notes |
| --- | --- | --- | --- |
| HOOK-01 | Pre-Commit Branch + LLMS Freshness Guard | .github/hooks/pre-commit | Refuses commits on `main` and non-`work/*` branches, then runs the read-only LLMS parity gate. It fails on stale generated context and stages files `0` times. Spec: `docs/ops/specs/hooks/pre-commit.md`. Local opt-in: activate per clone with `git config core.hooksPath .github/hooks`. |
| HOOK-02 | Main Push Guard | .github/hooks/pre-push | Refuses direct push to `main`. Spec: `docs/ops/specs/hooks/pre-push.md`. Local opt-in: activate per clone with `git config core.hooksPath .github/hooks`. |
