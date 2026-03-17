# Retention Manifest Spec

## Purpose
`ops/etc/retention.manifest` is the runtime delete and reporting policy source for `ops/bin/prune`.

## Required Scalars
- `default_phase`
- `apply_token`
- `high_watermark`
- `low_watermark`
- `target_sop_tier`
- `target_pow_tier`
- `weight_operational`
- `weight_historical`
- `quarantine_path`

## Required Sections
- `## Tier Semantics`
- `## Critical Patterns`
- `## Denylist`
- `## Storage Report Classes`
- `## Shared Persistence Policy`

## Contract
- destructive paths are fail-closed on parse error
- critical and denylist matches must never be auto-pruned
- storage target is report-only in this slice
- dump-target apply remains bounded by persistence-policy `retention=disposable` and `apply=1`
