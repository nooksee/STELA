# ops/bin/hooks

## Purpose
One-time local configuration to wire the repo hooks directory into git. Sets `core.hooksPath = .github/hooks` so git invokes the tracked hook scripts on commit and push operations.

## Usage

~~~bash
ops/bin/hooks
~~~

No arguments. Run once after clone and on any additional checkout machine.

## Mechanics
Resolves `REPO_ROOT` via `BASH_SOURCE`, `cd`s to it, then runs:

~~~bash
git config core.hooksPath .github/hooks
~~~

This is a local `.git/config` change only. No tracked files are modified.

## Active Hooks

| Hook | Trigger | Guard |
|------|---------|-------|
| `pre-commit` | `git commit` | Refuses commit on `main` or non-`work/*` branch (PoT §6.2.3); runs llms refresh and stages bundles |
| `pre-push` | `git push` | Refuses direct push to `main` (PoT §6.1) |

## Bypass
`git commit --no-verify` and `git push --no-verify` bypass all hooks. This is by design; use only when the hook guard is inapplicable.

## See Also
- `docs/MANUAL.md` Local Hooks Setup section
- `.github/hooks/pre-commit`
- `.github/hooks/pre-push`
- `.github/hooks/llms`
