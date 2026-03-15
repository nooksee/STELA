<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# History Policy Manifest

## Parse Contract
`ops/bin/dump`, `ops/lib/scripts/bundle.sh`, and `ops/bin/prune` read this file for history-tier behavior. Parse failure is fail-closed.

history_manifest_version=1
default_history_profile_full=full-default
default_history_profile_platform=full-default
default_history_profile_core=core-default
default_history_profile_factory=factory-default
default_history_profile_project=project-default

## History Profiles
profile=full-default|recent_count=6|checkpoint_interval=12|cold_mode=metadata-only
profile=core-default|recent_count=2|checkpoint_interval=30|cold_mode=metadata-only
profile=factory-default|recent_count=4|checkpoint_interval=20|cold_mode=metadata-only
profile=project-default|recent_count=4|checkpoint_interval=20|cold_mode=metadata-only
profile=analyst|recent_count=3|checkpoint_interval=18|cold_mode=metadata-only
profile=architect|recent_count=5|checkpoint_interval=12|cold_mode=metadata-only
profile=audit|recent_count=2|checkpoint_interval=30|cold_mode=metadata-only
profile=project|recent_count=4|checkpoint_interval=20|cold_mode=metadata-only
profile=conform|recent_count=4|checkpoint_interval=16|cold_mode=metadata-only
profile=foreman|recent_count=2|checkpoint_interval=30|cold_mode=metadata-only

## Archive Serialization Classes
class=archive-pow|pattern=archives/surfaces/PoW-*.md|family=pow|kind=surface
class=archive-sop|pattern=archives/surfaces/SoP-*.md|family=sop|kind=surface
class=archive-task|pattern=archives/surfaces/TASK-*.md|family=task|kind=surface
class=archive-compile|pattern=archives/manifests/compile-*.md|family=compile|kind=manifest
class=archive-decision|pattern=archives/decisions/*.md|family=decision|kind=decision
class=archive-definition|pattern=archives/definitions/*.md|family=definition|kind=definition

## Dump Report Classes
class=archive-pow|pattern=archives/surfaces/PoW-*.md|tier=historical|weight=3|retention=canonical|apply=0
class=archive-sop|pattern=archives/surfaces/SoP-*.md|tier=historical|weight=3|retention=canonical|apply=0
class=archive-task|pattern=archives/surfaces/TASK-*.md|tier=historical|weight=3|retention=canonical|apply=0
class=archive-compile|pattern=archives/manifests/compile-*.md|tier=historical|weight=2|retention=canonical|apply=0
class=archive-decision|pattern=archives/decisions/*.md|tier=historical|weight=1|retention=canonical|apply=0
class=archive-definition|pattern=archives/definitions/*.md|tier=historical|weight=1|retention=canonical|apply=0
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
