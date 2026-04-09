<!-- CCD: ff_target="operator-technical" ff_band="25-35" -->
# Hook Registry

Authoritative registry for tracked git hooks under `.github/hooks/`.

| ID | Name | File Path | Notes |
| --- | --- | --- | --- |
| HOOK-01 | Pre-Commit Guard + LLMS Refresh | .github/hooks/pre-commit | Refuses commits on `main` and non-`work/*` branches, then runs `ops/bin/llms` and stages `llms.txt`, `llms-core.txt`, and `llms-full.txt`. Spec: `docs/ops/specs/hooks/pre-commit.md`. Local opt-in: activate per clone with `git config core.hooksPath .github/hooks`. |
| HOOK-02 | Main Push Guard | .github/hooks/pre-push | Refuses direct push to `main`. Spec: `docs/ops/specs/hooks/pre-push.md`. Local opt-in: activate per clone with `git config core.hooksPath .github/hooks`. |
