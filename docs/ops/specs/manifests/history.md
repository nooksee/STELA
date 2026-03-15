# History Policy Manifest Spec

## Purpose
`ops/lib/manifests/HISTORY.md` is the shared history-tier policy source for `ops/bin/dump`, `ops/lib/scripts/bundle.sh`, and `ops/bin/prune`.

## Required Scalars
- `history_manifest_version`
- `default_history_profile_full`
- `default_history_profile_platform`
- `default_history_profile_core`
- `default_history_profile_factory`
- `default_history_profile_project`

## History Profiles
Each row under `## History Profiles` uses:
- `profile=<name>`
- `recent_count=<int>`
- `checkpoint_interval=<int>`
- `cold_mode=metadata-only`

Rules:
- profile names must be unique.
- `recent_count` may be zero or greater.
- `checkpoint_interval` must be greater than zero.
- `cold_mode` is currently `metadata-only` only.

## Archive Serialization Classes
Each row under `## Archive Serialization Classes` uses:
- `class=<name>`
- `pattern=<glob>`
- `family=<name>`
- `kind=<surface|manifest|decision|definition>`

Rules:
- rows define the canonical archive classes eligible for tiered dump serialization.
- files outside these classes remain full-body by default unless a later packet expands coverage.

## Dump Report Classes
Each row under `## Dump Report Classes` uses:
- `class=<name>`
- `pattern=<glob>`
- `tier=<critical|operational|historical>`
- `weight=<int>`
- `retention=<canonical|disposable>`
- `apply=<0|1>`

Rules:
- `ops/bin/prune --target=dump` must read these rows directly from `HISTORY.md`.
- `retention=canonical` rows remain report-only in this slice.

## Repo Pressure Classes
Each row under `## Repo Pressure Classes` uses:
- `class=<name>`
- `pattern=<glob>`
- `tier=<critical|operational|historical>`
- `weight=<int>`
- `retention=<canonical|disposable>`

Rules:
- repo-context reporting may observe whole-repo pressure without implying auto-delete.

## Dump Contract
- `ops/bin/dump` must resolve a history profile before serialization.
- matching archive files may emit either:
  - full body
  - explicit metadata-only history block
- metadata-only blocks must disclose omission explicitly and preserve exact-file re-include instructions.
- explicit `--include-file` and `--include-file-list` entries override cold-body omission for matched files.

## Bundle Contract
- `ops/lib/scripts/bundle.sh` must route a profile-specific history profile into `ops/bin/dump`.
- analyst and architect remain `--scope=full`, but their dump history depth is profile-specific.
- audit remains proof-first and may use a narrower profile with `--scope=core`.

## Prune Contract
- `ops/bin/prune` must use `HISTORY.md` classes for dump-visible and repo-context reporting.
- prune apply remains bounded to disposable classes explicitly marked `apply=1`.

## Acceptance
- default full dump becomes materially smaller on the same HEAD.
- analyst full-dump bundle payload becomes materially smaller on the same HEAD.
- cold archive history remains visible through metadata-only entries.
- exact-file cold archive re-include remains available.
