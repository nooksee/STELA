<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/integrity.sh` is the runtime scope guard for DP execution. It enforces allowlist-bounded mutation so no staged, unstaged, or untracked path escapes the active packet contract. This directly protects the PoT Section 1.2 Drift axiom by stopping out-of-scope edits at the moment they appear in repository state. It also enforces the CbC Design Discipline Preflight linkage contract: when the TASK.md CbC preflight slot is applicable, a cbc decision leaf must be allowlisted before certification proceeds.

## Mechanics and Sequencing
1. Resolve repository root, emit telemetry, and resolve `TASK.md` to either the live dashboard or its archives pointer target.
2. Extract the Target Files allowlist pointer from Section 3.3, normalize it, and require a reachable allowlist file.
3. Load allowlist entries into exact-path and wildcard sets, reject forbidden runtime-prefix entries, and preserve the sanctioned closing-sidecar pattern exception.
4. Build observed path set from `git diff --name-only --cached`, `git diff --name-only`, and `git ls-files --others --exclude-standard`.
5. Normalize observed paths and compare each path against allowlisted exact entries plus wildcard patterns.
6. Emit hard failure with unauthorized path listing when any observed path is out of scope; otherwise emit pass count.
7. Extract the CbC Design Discipline Preflight slot content from the resolved TASK surface. Parse the first non-empty line after the two fixed boilerplate lines (`Required when...` and `For non-tooling DPs:`).
8. Treat preflight as applicable when the first non-empty slot line does not begin with `Not applicable`. When no slot content is found, treat as not applicable.
9. When preflight is applicable, check the allowlist for at least one exact entry or wildcard pattern matching `archives/decisions/*-cbc-*`. Emit hard failure when no such entry exists.

## CbC Preflight Enforcement Rule

**Trigger:** The CbC Design Discipline Preflight section in TASK.md (or its resolved pointer target) contains a first non-empty content line that does not begin with `Not applicable`.

**Required allowlist coverage:** The allowlist (`storage/dp/active/allowlist.txt`) must contain at least one entry or pattern matching `archives/decisions/*-cbc-*`.

**Failure message:**
~~~
FAIL: CbC preflight is applicable but no cbc decision leaf entry or pattern
  (archives/decisions/*-cbc-*) found in the allowlist.
  Run: ./ops/bin/decision create --dp=<DP-ID> --type=cbc --status=accepted --out=auto
  Then add the generated leaf path to storage/dp/active/allowlist.txt.
~~~

**Recovery:** Generate a cbc decision leaf using `ops/bin/decision create --type=cbc ...`,
then add the generated leaf path (or use the `archives/decisions/RoR-????-??-??-???-cbc-*.md`
pattern) in the allowlist, and re-run `tools/lint/integrity.sh`.

## Anecdotal Anchor
DP-OPS-0074 recorded a session where absent runtime scope enforcement allowed an out-of-scope RESULTS artifact to be staged and only detected during later review. The current observed-path set comparison closes that gap by enforcing scope continuously rather than after receipt generation.

DP-OPS-0139 added the CbC preflight linkage rule after observing that tooling DPs could pass integrity checks without evidence of CbC discipline review. The new rule structurally requires a cbc decision leaf when the preflight is applicable, making the documentation-to-artifact loop mandatory rather than advisory.

## Integrity Filter Warnings
Pointer extraction failures in TASK Section 3.3 are hard-stop conditions and terminate lint before path comparison starts. The script evaluates current local git state only; ignored files or external workspace mutations outside git visibility are not part of observed-path comparison. Broad wildcard entries reduce false alarms but can also mask accidental scope expansion if they are written too loosely. Absence of the CbC preflight section in TASK is treated as not applicable; the rule only fires when the section is present and the slot content does not begin with `Not applicable`.
