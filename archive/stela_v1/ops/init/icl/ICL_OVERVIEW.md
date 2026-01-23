# ICL Overview

## Purpose
Provide a top-level map of the Initialization & Context Load (ICL) flow.

AI knowledge of the repo is opt-in, never assumed. If an AI must reason about repo structure, operator must provide filesystem access (IDE context) or explicit artifacts (files/diffs/manifests). No exceptions.

ICL Continuity Core is the minimal continuity/rehydration surface for stateless AI operation (see `ops/init/icl/ICL_CONTINUITY_CORE.md`).

## Scope
Defines the entry point and required artifacts for ICL.

## Verification
- Not run (operator): validate links and sequence alignment.

## Risk+Rollback
- Risk: incomplete or stale ICL map.
- Rollback: update this overview to match current ops init flow.

## Canon Links
- ops/init/icl/INIT_CONTRACT.md
- ops/init/icl/INIT_CHECKLIST.md
- ops/init/icl/CONTEXT_LOAD_PROMPT.md
- ops/init/icl/ICL_CONTINUITY_CORE.md
