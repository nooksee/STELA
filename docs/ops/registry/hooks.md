<!-- CCD: ff_target="operator-technical" ff_band="25-35" -->
# Hook Registry

Authoritative registry for tracked pre-commit hooks under `.github/hooks/`.

| ID | Name | File Path | Notes |
| --- | --- | --- | --- |
| HOOK-01 | LLMS Bundle Refresh | .github/hooks/llms | Spec: `docs/ops/specs/hooks/llms.md`. Pre-commit hook. Runs `ops/bin/llms` and stages `llms.txt`, `llms-core.txt`, and `llms-full.txt`. Local opt-in: activate per clone with `git config core.hooksPath .github/hooks`. |
