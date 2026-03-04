<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Prune Policy Manifest

## Parse Contract
`ops/bin/prune` reads this file before any candidate processing. Parse failure is fail-closed.

default_phase=report
apply_token=I_APPROVE_PRUNE
high_watermark=30
low_watermark=20
target_sop_tier=operational
target_pow_tier=historical
weight_operational=1
weight_historical=3
quarantine_path=var/tmp/prune-quarantine

## Tier Semantics
- `critical`: never auto-prune
- `operational`: rolling window retention under hysteresis limits
- `historical`: budget reclaim path under hysteresis limits

## Critical Patterns
pattern=storage/handoff/*-RESULTS.md
pattern=storage/handoff/CLOSING-DP-OPS-*.md
pattern=storage/dp/active/*
pattern=TASK.md
pattern=SoP.md
pattern=PoW.md

## Denylist
pattern=storage/handoff/*-RESULTS.md
pattern=storage/handoff/CLOSING-DP-OPS-*.md
pattern=storage/dp/active/*
pattern=TASK.md
pattern=SoP.md
pattern=PoW.md
