<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/truth.sh` enforces canon spelling integrity by rejecting forbidden platform-name variants and legacy phrase tokens before they propagate into authoritative surfaces. This supports PoT Section 4.2 Linguistic Precision and Absolute Literalism by keeping terminology deterministic for both operators and automated parsers.

## Mechanics and Sequencing
1. Resolve repository root, emit telemetry, and build scan list from tracked files under `docs/`, `opt/`, `tools/`, `.github/`, and `ops/`, plus selected root canon files when present.
2. Exclude `tools/lint/truth.sh` from the scan set.
3. Scan all collected files for embedded forbidden spelling tokens.
4. Scan for forbidden legacy phrases and forbidden legacy registry path-casing tokens.
5. Emit file-and-line diagnostics for each match and return non-zero on any match.

## Anecdotal Anchor
This gate has repeatedly caught forbidden spelling variants during packet preflight, including draft-state slips that would otherwise have reached operator review and required later correction. The early failure path prevented those variants from entering committed canon surfaces.

## Integrity Filter Warnings
The forbidden token sets are embedded directly in the script and are not loaded from a registry file. Self-exclusion means the script can contain legacy tokens in its own source without self-failing. The scanner evaluates tracked and existing files only; untracked drafts are not part of the scan until they are tracked.
