# Release process

nukeCE uses a **batch-and-ship** release train to keep patch clutter minimal and keep provenance clear.

## Principles

- **Work happens on `work/*` branches.**
- **Merges happen by PR only.** No direct pushes to `main`.
- **Repo-gates must pass** (tree verification + truth lint).
- Releases are shipped as **bundles**, not a drip of tiny patches.

## What a "release bundle" means

A release bundle is the smallest practical snapshot that makes the system usable by others:

- `public_html/` — deployable webroot
- `ops/init/icl/launch_pack/` — launchpack / context pack needed to operate the repo safely
- `docs/` — current operating manual

## Operator checklist (high level)

1. Batch changes on `work/*` branches.
2. Open PR(s); wait for gates to go green.
3. Merge PR(s) into `main`.
4. Cut a release bundle (automation/manual depends on current tooling).
5. Announce what's changed and what operators should do next.

(Implementation details live in ops/runbooks and evolve over time.)
