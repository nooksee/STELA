# nukeCE Meta Location

This project uses a split layout:
- `public_html/` is the web-served root (runtime PHP, modules, assets).
- `_meta/` contains non-webroot project assets (canon, reference, claims, transcripts, docs).

NetBeans recommendation:
- Project A: point Document Root / Sources to `public_html/`.
- Project B (support): open `_meta/` as a separate project for browsing/searching.
