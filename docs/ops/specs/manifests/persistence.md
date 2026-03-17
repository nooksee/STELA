# Persistence Manifest Spec

## Purpose
`ops/etc/persistence.manifest` is the shared persistence-policy source for `ops/bin/dump`, `ops/lib/scripts/bundle.sh`, and `ops/bin/prune` report paths.

## Required Scalars
- `persistence_manifest_version`
- `default_persistence_profile_full`
- `default_persistence_profile_platform`
- `default_persistence_profile_core`
- `default_persistence_profile_factory`
- `default_persistence_profile_project`

## Persistence Profiles
Each row under `## Persistence Profiles` uses:
- `profile=<name>`
- `recent_count=<int>`
- `checkpoint_interval=<int>`
- `cold_mode=metadata-only`

## Archive Serialization Classes
Each row under `## Archive Serialization Classes` uses:
- `class=<name>`
- `pattern=<glob>`
- `family=<name>`
- `kind=<surface|manifest|decision|definition>`

## Dump Report Classes
Each row under `## Dump Report Classes` uses:
- `class=<name>`
- `pattern=<glob>`
- `tier=<critical|operational|historical>`
- `weight=<int>`
- `retention=<canonical|disposable>`
- `apply=<0|1>`

## Repo Pressure Classes
Each row under `## Repo Pressure Classes` uses:
- `class=<name>`
- `pattern=<glob>`
- `tier=<critical|operational|historical>`
- `weight=<int>`
- `retention=<canonical|disposable>`

## Contract
- `ops/bin/dump` must resolve a persistence profile before serialization.
- `ops/lib/scripts/bundle.sh` must route profile-specific persistence into dump.
- `ops/bin/prune` must read dump-visible and repo-context classes from this file for reporting and bounded dump apply.
