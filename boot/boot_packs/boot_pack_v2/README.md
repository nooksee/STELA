# nukeCE Boot Pack — v2

This folder is the minimal “instant alignment” package for a fresh session.

## Copy/paste load script (fresh chat)

1) Create a new chat named:
**nukeCE Control Room — Active Context Pack**

2) Upload this folder (or the full reboot bundle ZIP), then paste this:

```
Load boot_pack_v2 as the active context for nukeCE.

Operating rules:
- Follow principles.md (explanation > invention; provenance-first; visible uncertainty).
- Treat canon_snapshot.md as binding (canon changes require explicit Decision objects).
- active_loops.json is the current work queue; do not “solve” by rewriting history.
- When unsure, ask for evidence pointers or propose a Draft Decision/Claim instead of asserting.
```

## What’s inside
- principles.md
- canon_snapshot.md
- active_loops.json
- context_pack.json

## What this is NOT
- Not raw transcripts
- Not full project docs
- Not “everything ever said”
It’s the minimum structure that makes continuity real.

## Repo layout note (if you uploaded the full bundle)
- Web server / NetBeans web project: `public_html/`
- Support project (non-served): `_meta/` (canon, reference, claims, transcripts, docs)

If a task touches canon/reference/claims, prefer reading/writing under `_meta/`.


## Control Room reboot (copy/paste)
1) Create a new chat named:
   **nukeCE Control Room — Active Context Pack**

2) Upload this folder `boot_pack_v2/` (or paste these files):
   - README.md
   - principles.md
   - canon_snapshot.md
   - active_loops.json
   - context_pack.json
   - USER_PROFILE.md
   - ASSISTANT_PROFILE.md

3) Paste the following instruction:

> Load `boot_pack_v2` as the active context. Operate strictly within it.  
> Canon changes require explicit Decision objects under `_meta/canon/decisions/`.  
> Evidence lives in `_meta/data/transcripts/`.  
> Reference content lives in `_meta/reference/` and Claims in `_meta/claims/`.  
> Follow path split rules in `NUKECE_PATHS.md`.

