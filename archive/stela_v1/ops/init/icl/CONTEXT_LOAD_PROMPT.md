# Context Load Prompt

## Purpose
Define the canonical prompt for loading context during initialization.

## Scope
Used by operators when briefing AI workers on context load.

## Verification
- Not run (operator): validate prompt matches current policies.

## Risk+Rollback
- Risk: prompt drifts from ops expectations.
- Rollback: replace with the last known-good prompt.

## Canon Links
- ops/init/icl/ICL_OVERVIEW.md
- ops/init/manifests/CONTEXT_MANIFEST.md
