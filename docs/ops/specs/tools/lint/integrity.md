<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/integrity.sh` is the runtime scope guard for DP execution. During an active packet it requires two independent approvals for every ordinary staged, unstaged, or untracked path: exact declaration in the packet or active addendum, and coverage by persistent path policy. This directly protects the PoT Section 1.2 Drift axiom by preventing accumulated policy from silently widening one packet. It also enforces the CbC Design Discipline Preflight linkage contract.

## Mechanics and Sequencing
1. Resolve repository root, emit telemetry, and resolve `TASK.md` to either the live dashboard or its archives pointer target.
2. Read TASK lifecycle. `ACTIVE/ACTIVE` selects packet-exact mode; `IDLE/COMPLETED` selects explicit maintenance mode. Every other pairing fails closed.
3. In packet-exact mode, parse `3.4.3 Changelog` into one exact mutation set. If `storage/dp/intake/ADDENDUM.md` exists, require matching base-packet identity and add its exact delta. An addendum during idle maintenance fails.
4. Extract the Target Files allowlist pointer from Section 3.3, normalize it, and require a reachable persistent policy file.
5. Load current policy and its committed `HEAD` version into exact-path and wildcard sets. Reject forbidden runtime-prefix entries.
6. Build the observed path set from staged, unstaged, and untracked Git state.
7. In packet-exact mode, require every ordinary observed path in the exact mutation set and persistent policy. In maintenance mode, require persistent policy and report that packet scope is not active.
8. Treat the live certify-owned generated surface set as structurally authorized when, and only when, the current head pointers are in canonical generated form:
   - `PoW.md` pointer head plus its pointed leaf
   - `SoP.md` pointer head plus its pointed leaf
   - `TASK.md` pointer head plus its pointed leaf
   This is an exact-current-head exception, not a wildcard allowance for arbitrary archive edits.
9. Emit separate failure lists for missing packet scope and missing persistent policy; otherwise report mode and path counts.
10. Extract the CbC Design Discipline Preflight slot content from the resolved TASK surface. Parse the first non-empty line after the two fixed boilerplate lines (`Required when...` and `For non-tooling DPs:`).
11. Treat preflight as applicable when the first non-empty slot line does not begin with `Not applicable`. When no slot content is found, treat as not applicable.
12. When preflight is applicable, check persistent policy for at least one exact entry or wildcard pattern matching `archives/decisions/*-cbc-*`.
13. When `PoT.md` is observed, require explicit governance authorization in the resolved TASK surface in addition to the two normal scope gates.

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

## Deletion Lifecycle Rule

- A tracked deletion must still appear in the packet exact mutation set.
- Persistent coverage may come from the current policy or the committed `HEAD` policy. This permits one packet to delete a path and retire its policy entry atomically.
- No unrestricted deletion bypass exists.
- Post-landing stale-entry cleanup remains `tools/lint/dp.sh` authority once the delete diff is gone.

## Anecdotal Anchor
DP-OPS-0074 recorded a session where absent runtime scope enforcement allowed an out-of-scope RESULTS artifact to be staged and only detected during later review. The current observed-path set comparison closes that gap by enforcing scope continuously rather than after receipt generation.

DP-OPS-0139 added the CbC preflight linkage rule after observing that tooling DPs could pass integrity checks without evidence of CbC discipline review. The new rule structurally requires a cbc decision leaf when the preflight is applicable, making the documentation-to-artifact loop mandatory rather than advisory.

DP-OPS-0155 follow-on hardening added a governance-surface edit guard for `PoT.md` after repeated operator-facing regressions where constitutional text changed outside explicit packet scope. The rule is deliberately narrow: it does not block governance edits categorically, it requires explicit authorization in active DP scope/changelog.

DP-OPS-0242 closed a deletion-lifecycle mismatch where `dp.sh` already tolerated deleted tracked files remaining in the allowlist during an active delete packet, but `integrity.sh` still required current allowlist coverage for those same deleted paths. The repair keeps in-flight delete packets coherent while leaving post-landing stale-entry cleanup to `dp.sh`.

## Integrity Filter Warnings
Pointer extraction failures in TASK Section 3.3 are hard-stop conditions. The script evaluates current local Git state only; ignored files and external mutations are outside its observed set. Persistent wildcards remain a ceiling, but they cannot enlarge packet scope. The certify-generated surface exception is intentionally narrow: only live generated head pointers and their current targets are structurally authorized. Absence of the CbC preflight section is treated as not applicable. `PoT.md` authorization checks rely on canonical headings; malformed packets are expected to fail packet lint.
