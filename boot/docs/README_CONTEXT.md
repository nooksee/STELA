# README_CONTEXT — nukeCE Reboot Bundle (Boot Pack v3 layout-split)

This bundle is a **rebootable nukeCE workspace** assembled from:
- Project Core (web directory)
- Supporting Docs (AI-generated docs + manifests)
- Chat History (ChatGPT export)

## Top-level layout
- `public_html/` — **web-served application root** (what your web server points at)
- `_meta/` — **non-served project brain** (canon, reference, claims, transcripts, docs)
- `boot_pack_v2/` — the current Boot Pack to initialize a fresh Control Room session

## What’s inside `_meta/`
- `canon/` — ratified decisions + indexes (binding project authority)
- `reference/` — reference nodes (explanations) + indexes
- `claims/` — explicit claim objects (status + confidence) + indexes
- `data/transcripts/` — normalized chat transcripts (append-only NDJSON)
- `docs/` — curated docs staged near modules
- `docs_support_raw/` — full supporting docs as received (unfiltered)

## How to reboot into a fresh chat (copy/paste)
1) Start a new chat named: **nukeCE Control Room — Active Context Pack**

2) Upload either:
- `boot_pack_v2/` (minimum), or
- this whole ZIP (recommended)

3) Paste this:
> Load `boot_pack_v2` as the active context. Operate strictly within it.
> Constraints: assist-only, no auto-canon, provenance-first, surface uncertainty.
> Canon changes require explicit Decision objects.

## Current goals (near-term)
- Stand up Context Pack loading + retrieval contract in the custom nukeCE chat UI (Option B)
- Keep canon clean: ratify decisions explicitly; everything else stays in Reference/Claims
- Gradually extract high-signal Reference Nodes from transcripts with provenance

## User profile (assistant alignment)
- Prefers the assistant to act as a **biographer and personal analyst** when relevant.
- Values **direct, plainspoken** guidance (no platitudes).
- Wants **visible epistemic friction**: uncertainty and assumptions must be marked.
- nukeCE ethos: **explanation over invention**, provenance-first, and resistance to premature certainty.

## NetBeans layout (practical)
Recommended:
- Create/keep **one NetBeans project** pointed at `public_html/` (only web-served files).
- Add a **second “support” project** pointed at `_meta/` (non-served assets).

This keeps non-public materials out of the webroot while still visible/editable in the IDE.

## Collaboration profiles (non-clinical)
- _meta/profiles/user_kevin_thomas.md
- _meta/profiles/assistant_nukece_mode.md

These are operational working-style notes for continuity; they are not medical or clinical assessments.
