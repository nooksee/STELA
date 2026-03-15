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

## Storage Report Classes
class=telemetry-leaves|pattern=logs/*.md|tier=historical|weight=1
class=telemetry-heads|pattern=logs/*.telemetry.head|tier=operational|weight=1
class=dump-payloads|pattern=storage/dumps/dump-*.txt|tier=historical|weight=3
class=dump-manifests|pattern=storage/dumps/dump-*.manifest.txt|tier=historical|weight=2
class=analyst-bundles|pattern=storage/handoff/ANALYST-*|tier=historical|weight=2
class=architect-bundles|pattern=storage/handoff/ARCHITECT-*|tier=historical|weight=2
class=audit-bundles|pattern=storage/handoff/AUDIT-*|tier=historical|weight=2
class=conform-bundles|pattern=storage/handoff/CONFORM-*|tier=historical|weight=2
class=foreman-bundles|pattern=storage/handoff/FOREMAN-*|tier=historical|weight=2
class=project-bundles|pattern=storage/handoff/PROJECT-*|tier=historical|weight=2
class=legacy-bundles|pattern=storage/handoff/BUNDLE-*|tier=historical|weight=2

## Dump Report Classes
class=archive-surfaces|pattern=archives/surfaces/*.md|tier=historical|weight=3|retention=canonical|apply=0
class=archive-manifests|pattern=archives/manifests/*.md|tier=historical|weight=2|retention=canonical|apply=0
class=docs-tree|pattern=docs/*|tier=operational|weight=1|retention=canonical|apply=0
class=ops-tree|pattern=ops/*|tier=operational|weight=1|retention=canonical|apply=0
class=tools-tree|pattern=tools/*|tier=operational|weight=1|retention=canonical|apply=0
class=opt-tree|pattern=opt/*|tier=operational|weight=1|retention=canonical|apply=0
class=analyst-topic-input|pattern=storage/handoff/TOPIC.md|tier=operational|weight=1|retention=disposable|apply=1
class=architect-plan-input|pattern=storage/handoff/PLAN.md|tier=operational|weight=1|retention=disposable|apply=1
class=audit-results-input|pattern=storage/handoff/*-RESULTS.md|tier=operational|weight=1|retention=disposable|apply=0
class=audit-closing-input|pattern=storage/handoff/CLOSING-DP-OPS-*.md|tier=operational|weight=1|retention=disposable|apply=0

## Repo Pressure Classes
class=archives-tree|pattern=archives/*|tier=historical|weight=2|retention=canonical
class=logs-tree|pattern=logs/*|tier=historical|weight=1|retention=disposable
class=storage-dumps|pattern=storage/dumps/*|tier=historical|weight=2|retention=disposable
class=storage-handoff|pattern=storage/handoff/*|tier=operational|weight=1|retention=disposable
