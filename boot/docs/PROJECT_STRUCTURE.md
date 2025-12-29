# PROJECT_STRUCTURE — cleaned + split (public_html vs _meta)

This file summarizes the **intended layout** for:
- a web server pointed at `public_html/`
- NetBeans with two projects: `public_html/` (served) + `_meta/` (support)

## Top-level
- `public_html/` — web-served application root
- `_meta/` — non-served canon/reference/claims/transcripts/docs
- `boot_pack_v0/`, `boot_pack_v1/`, `boot_pack_v2/` — boot packs (use v2)
- `README_CONTEXT.md` — how to reboot and how to wire NetBeans

## public_html/ (webroot)
Key directories (not exhaustive):
- `admin/`
- `assets/`
- `blocks/`
- `config/`
- `includes/`
- `install/`
- `modules/`
- `data/` (runtime JSON; transcripts moved out)

## _meta/ (NOT webroot)
- `canon/`
  - `decisions/`
  - `indexes/`
- `reference/`
  - `nodes/`
  - `indexes/`
  - `status.json` (reviewed/needs-citation/stale)
- `claims/`
  - `claims/`
  - `indexes/` (`by_tag.json`, `by_status.json`)
- `data/transcripts/`
  - `conversations/<conversation_id>/meta.json`
  - `conversations/<conversation_id>/messages.ndjson`
- `docs/` (curated)
- `docs_support_raw/` (full, unfiltered)
