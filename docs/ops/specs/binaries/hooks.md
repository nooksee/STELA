<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# ops/bin/hooks

## Purpose
One-time local configuration to wire the repo hooks directory into git. Sets `core.hooksPath = .github/hooks` so git invokes the tracked hook scripts on commit and push operations.

## Usage

~~~bash
ops/bin/hooks
ops/bin/hooks --test
~~~

Run without arguments once after clone and on any additional checkout machine. Use `--test` to exercise the tracked hook contract without changing the active clone configuration or tracked files.

## Mechanics
Resolves `REPO_ROOT` via `BASH_SOURCE`, `cd`s to it, then runs:

~~~bash
git config core.hooksPath .github/hooks
~~~

This is a local `.git/config` change only. No tracked files are modified.

Test mode creates an isolated temporary repository from current `HEAD`, copies the candidate pre-commit hook into that repository, and verifies five behaviors: activation, rejection on `main`, rejection on a non-`work/*` branch, a residue-free path-limited commit, and stale-context rejection without candidate mutation. Temporary storage is removed at exit.

## Active Hooks

| Hook | Trigger | Guard |
|------|---------|-------|
| `pre-commit` | `git commit` | Refuses commit on `main` or non-`work/*` branch (PoT §6.2.1); then runs the read-only LLMS parity gate and rejects stale generated context |
| `pre-push` | `git push` | Refuses direct push to `main` (PoT §6.1) |

## Bypass
`git commit --no-verify` and `git push --no-verify` bypass all hooks. This is by design; use only when the hook guard is inapplicable.

## See Also
- `docs/MANUAL.md` Local Hooks Setup section
- `.github/hooks/pre-commit`
- `.github/hooks/pre-push`
- `docs/ops/specs/hooks/pre-commit.md`
- `docs/ops/specs/hooks/pre-push.md`
