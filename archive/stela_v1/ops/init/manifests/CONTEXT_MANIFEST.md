# Context Manifest

## Purpose
List required artifacts for context loading.

## Scope
Used by operators when providing context to AI workers.
Optional pre-session check: run `ops/init/tools/context_lint.sh`.
Mandatory for long sessions: read `ops/init/protocols/CONTEXT_PRUNING_PROTOCOL.md`.

## Canonical ICL files
- `ops/init/icl/ICL_OVERVIEW.md`
- `ops/init/icl/INIT_CONTRACT.md`
- `ops/init/icl/INIT_CHECKLIST.md`
- `ops/init/icl/CONTEXT_LOAD_PROMPT.md`
- `ops/init/manifests/CONTEXT_MANIFEST.md`
- `ops/init/manifests/ROLE_MANIFEST.md`
- `ops/init/manifests/OUTPUT_MANIFEST.md`
- `ops/init/profiles/OPERATOR_PROFILE.md`
- `ops/init/profiles/INTEGRATOR_PROFILE.md`
- `ops/init/profiles/WORKER_PROFILE.md`
- `ops/init/profiles/PLATFORM_PROFILE.md`
- `ops/init/protocols/SAVE_THIS_PROTOCOL.md`
- `ops/init/protocols/SNAPSHOT_PROTOCOL.md`
- `ops/init/protocols/UI_MODE_PROTOCOL.md`
- `ops/init/protocols/HANDOFF_PROTOCOL.md`
- `ops/init/protocols/CONTEXT_PRUNING_PROTOCOL.md`
- `ops/init/tools/context_lint.sh`

## Verification
- Not run (operator): confirm manifest completeness.

## Risk+Rollback
- Risk: missing critical context.
- Rollback: add or restore required artifacts.

## Canon Links
- ops/init/icl/CONTEXT_LOAD_PROMPT.md
- ops/init/protocols/CONTEXT_PRUNING_PROTOCOL.md
