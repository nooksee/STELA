<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`.github/hooks/llms` exists to enforce the PoT Section 1.2 SSOT axiom at the commit boundary by preventing stale llms bundle state from entering the repository. The hook runs the canonical generator before every commit and stages the refreshed output, so the committed bundles always reflect current manifest state. Without this hook, contributors who do not manually run `ops/bin/llms` before committing can silently introduce drift between committed discovery entry points and the platform state they are supposed to describe.

## Mechanics and Sequencing
1. Trigger: `pre-commit`. Activates only in clones where `git config core.hooksPath .github/hooks` has been run.
2. Resolve repository root via `git rev-parse --show-toplevel`; fail immediately if the command returns non-zero.
3. Confirm `ops/bin/llms` is executable; fail with an explicit error message if it is missing or not executable.
4. Run `./ops/bin/llms` from repository root; fail if the command returns non-zero.
5. Stage `llms.txt`, `llms-core.txt`, and `llms-full.txt` via `git add`; fail if staging returns non-zero.
6. Return zero; commit proceeds with freshly staged bundles.

Install (one time per clone): `git config core.hooksPath .github/hooks`
Disable: `git config --unset core.hooksPath`
Registry: `docs/ops/registry/hooks.md`

## Anecdotal Anchor
Before DP-OPS-0102, bundle freshness was enforced by `tools/lint/llms.sh`, which ran a diff between committed and freshly generated bundles and failed when they diverged. The lint ran at gate time, not at commit time, so stale bundles entered branches and required correction during DP closeout. Moving enforcement to a pre-commit hook eliminates that correction cycle: the bundles are always staged correctly before the commit lands rather than being rejected after it does. Think of the hook as a turnstile that only opens when the bundles are current, compared to the former model of a toll booth that charged a penalty after you drove through.

## Integrity Filter Warnings
The hook is local and opt-in. Clones without `git config core.hooksPath .github/hooks` active do not run the hook, and CI does not run `ops/bin/llms`. A contributor committing without the hook active can produce stale bundles; these surface when `tools/lint/integrity.sh` or a subsequent DP preflight detects the drift. The hook fails hard on any non-zero return from `ops/bin/llms` or `git add`, aborting the commit. If `ops/bin/llms` itself fails due to a missing dependency or a compile error, the commit is blocked until the underlying issue is resolved. Forced termination of the commit process (for example, SIGKILL) can leave the repository in a partially staged state; running `git reset HEAD llms.txt llms-core.txt llms-full.txt` unstages any partial output.
