# public_html (Deploy Root)

This directory is the deployable webroot (served by Apache/Nginx).

Policy:
- Treat this as build output / runtime layout.
- Primary development happens in /src and /packages.
- Upstreams live in /upstream and are read-only snapshots.

If you are making product changes, do NOT edit random files here long-term.
Instead: implement in /src and use scripts/ to produce a deployable public_html.
