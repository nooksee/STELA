# Track A presentation cleanup (v28 draft)

## What changed
- Moved `public_html/RELEASE_NOTES_v*.md` to `public_html/docs/releases/`
- Added `CANONICAL_TREE.md` at repo root
- Added/updated `.gitignore` to keep writable/runtime surfaces and artifacts out of Git
- Removed embedded release zip artifacts from `releases/` (they belong in external releases, not in-repo)
- Removed `_upstream` reference dumps from the repo bundle for cleanliness (keep externally if needed)
- Emptied `storage/` leaving `.keep`

## Removed paths
- public_html/_upstream/
- releases/v10/public_html_v10.zip
- releases/v11/public_html_v11.zip
- releases/v12/public_html_v12.zip
- releases/v13/public_html_v13.zip
- releases/v14/public_html_v14.zip
- releases/v15/public_html_v15.zip
- releases/v16/public_html_v16.zip
- releases/v17/public_html_v17.zip
- releases/v18/public_html_v18.zip
- releases/v19/public_html_v19.zip
- releases/v20/public_html_v20.zip
- releases/v23/public_html_v23.zip
- releases/v24/public_html_v24.zip
- releases/v26/public_html_v26.zip
- releases/v27/public_html_v27.zip
