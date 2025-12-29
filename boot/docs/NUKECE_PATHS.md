# NUKECE_PATHS.md

This repo is intentionally split into a **web-served** tree and a **non-web-served** tree.

## Web server document root
- **public_html/**  
  Only files that must be publicly served belong here.

## Non-web support tree (never served)
- **_meta/**  
  Project governance + knowledge base + transcripts + tooling live here.

### Key subpaths (inside _meta/)
- canon/ — ratified decisions (binding)
- reference/ — published reference nodes (explanations)
- claims/ — explicit claim objects (confidence/status)
- data/transcripts/ — append-only conversation evidence
- docs/ — curated docs aligned to modules
- docs_support_raw/ — raw imported/supporting docs (unfiltered)

## Recommended NetBeans setup
- **Project 1:** point NetBeans project root at `public_html/`
- **Project 2 (“support”):** point NetBeans project root at `_meta/`

This keeps secrets/governance/evidence out of the webroot while still visible in the IDE.
