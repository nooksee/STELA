<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/dump` exists to produce deterministic repository evidence from tracked state so governance decisions cannot rely on hidden local artifacts. It protects PoT truth and anti-drift axioms by serializing selected tracked content, selection logic, and output metadata into auditable dump payloads and manifests.

## Mechanics and Sequencing
The binary parses scope, output, compression, bundling, and traversal refiner arguments, validates scope and target combinations, enforces repo-root execution, validates required canon files and top-level directories, and builds the file list by invoking `ops/lib/scripts/traverse.sh`. It emits a dump header with branch and hash metadata, writes index entries for selected files, and emits per-file content blocks from `HEAD` state through `git show`. Optional truncation limits are applied per file when `--max-lines` is set. It writes payload and manifest artifacts under `storage/dumps`, optionally packs payload and manifest into a tarball, and prints artifact paths when `--out` is used.

## Anecdotal Anchor
During immutable workflow adoption, one identified risk was that untracked local artifacts could reshape the narrative of what governed a packet execution. `ops/bin/dump` reduces that risk by grounding dump payloads in tracked repository state and explicit traversal rules.

## Integrity Filter Warnings
`ops/bin/dump` fails on invalid argument combinations, missing project target for project scope, non-root invocation, missing required canon surfaces, missing traversal output, and missing `tar` when archive output is requested. By design, untracked local files are not serialized into payload content, so local-only artifacts remain outside the dump unless they are committed.
