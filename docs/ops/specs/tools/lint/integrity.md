<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/integrity.sh` is the runtime scope guard for DP execution. It enforces allowlist-bounded mutation so no staged, unstaged, or untracked path escapes the active packet contract. This directly protects the PoT Section 1.2 Drift axiom by stopping out-of-scope edits at the moment they appear in repository state.

## Mechanics and Sequencing
1. Resolve repository root, emit telemetry, and resolve `TASK.md` to either the live dashboard or its archives pointer target.
2. Extract the Target Files allowlist pointer from Section 3.3, normalize it, and require a reachable allowlist file.
3. Load allowlist entries into exact-path and wildcard sets, reject forbidden runtime-prefix entries, and preserve the sanctioned closing-sidecar pattern exception.
4. Build observed path set from `git diff --name-only --cached`, `git diff --name-only`, and `git ls-files --others --exclude-standard`.
5. Normalize observed paths and compare each path against allowlisted exact entries plus wildcard patterns.
6. Emit hard failure with unauthorized path listing when any observed path is out of scope; otherwise emit pass count.

## Anecdotal Anchor
DP-OPS-0074 recorded a session where absent runtime scope enforcement allowed an out-of-scope RESULTS artifact to be staged and only detected during later review. The current observed-path set comparison closes that gap by enforcing scope continuously rather than after receipt generation.

## Integrity Filter Warnings
Pointer extraction failures in TASK Section 3.3 are hard-stop conditions and terminate lint before path comparison starts. The script evaluates current local git state only; ignored files or external workspace mutations outside git visibility are not part of observed-path comparison. Broad wildcard entries reduce false alarms but can also mask accidental scope expansion if they are written too loosely.
