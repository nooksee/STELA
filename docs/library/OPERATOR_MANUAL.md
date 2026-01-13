# Operator Manual (Curated)

This manual is the operator-facing entrypoint for day-to-day commands and the curated docs library.
It is intentionally short and maintained; if it drifts, fix it.

## Top Commands (cheat sheet)
```
./ops/bin/open --intent="..." --dp="DP-XXXX / YYYY-MM-DD"
./ops/bin/close
./ops/bin/snapshot --scope=icl --format=chatgpt
./ops/bin/snapshot --scope=icl --format=chatgpt --out=auto
./ops/bin/snapshot --scope=icl --format=chatgpt --out=auto --compress=tar.xz
./ops/bin/snapshot --scope=icl --format=chatgpt --out=auto.tar.xz
./ops/bin/help
./ops/bin/help list
./ops/bin/help manual
```

## Docs library (curated surface)
The docs library is the approved, curated surface for operators.
`ops/bin/help` will only open documents listed in `docs/library/LIBRARY_INDEX.md`.
If a document is not in the manifest, help will refuse to open it.

Library location:
- Root: `docs/library/`
- Manifest: `docs/library/LIBRARY_INDEX.md` (format: `topic | title | path`)

Add a new entry by editing the manifest and keeping the list curated (not every .md).

## Open / Close
- `./ops/bin/open` prints the copy-safe Open Prompt with the freshness gate and canon pointers.
- `./ops/bin/close` prints a copy-safe session receipt.

## Snapshot
`./ops/bin/snapshot` emits a repo snapshot (stdout by default). Use `--out=auto` to write to `storage/snapshots/`.

Optional archive output (tar.xz):
- `./ops/bin/snapshot --scope=icl --format=chatgpt --out=auto --compress=tar.xz`
- `./ops/bin/snapshot --scope=icl --format=chatgpt --out=auto.tar.xz`

Archive behavior:
- Output is a `.tar.xz` archive in `storage/snapshots/`.
- The archive contains exactly one file: the generated snapshot text.

## Help
`./ops/bin/help` is the operator front door for curated docs.
- `./ops/bin/help list` shows approved topics from the library manifest.
- `./ops/bin/help <topic>` opens that doc in `less` (color via `bat` when available).
