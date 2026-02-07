# Technical Specification: ops/bin/context

## Technical Specifications
- Executes `ops/bin/open --out=auto` and captures the OPEN artifact (plus PORCELAIN if present).
- Executes `ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle`.
- Assembles a single archive under `storage/archives/context/`.
- Archive contents: OPEN artifact, optional OPEN-PORCELAIN artifact, dump payload, dump manifest, optional dump tarball, and a metadata file.
- Metadata file includes the DP id, HEAD hash, and included filenames.
- Prints the relative archive path for SoP linkage.

## Requirements
- Must run from the repository root.
- Requires `ops/bin/open` and `ops/bin/dump` to be executable.
- Requires write access to `storage/archives/context/`.

## Usage
- `./ops/bin/context --dp=DP-OPS-0035`

## Forensic Insight
`ops/bin/context` is the Context Archivist. It produces a single ingestion archive so audits can trace exactly what was provided to the session.
