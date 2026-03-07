<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/response.sh` enforces raw-model response envelopes before intake. The goal is to fail malformed or contaminated responses early, before non-canonical payloads reach downstream contract checks.

## Mechanics and Sequencing
Modes:
1. `bash tools/lint/response.sh --mode=dp [path|-]` (default mode, default input is stdin).
2. `bash tools/lint/response.sh --mode=audit [path|-]`.
3. `bash tools/lint/response.sh --test` (runs deterministic fixtures for both modes).

Deterministic checks:
1. In `dp` mode, input must contain exactly one fenced markdown code block.
2. In `dp` mode, non-whitespace text outside the fenced block is a hard failure.
3. In `dp` mode, extracted body must start with `### DP-` on the first non-empty line.
4. In `audit` mode, input must contain exactly one fenced markdown code block.
5. In `audit` mode, non-whitespace text outside the fenced block is a hard failure.
6. In `audit` mode, extracted body must start with `**AUDIT -` (or `**AUDIT —`) on the first non-empty line.
7. Extracted body must not contain drift tokens:
   - `:contentReference[`
   - `oaicite`
   - `Show more`
   - `[cite_start]`
   - `[cite:`
   - `[/cite]`
   - `user prompt is empty`
   - `reading documents`
   - `running command`
8. In `dp` mode, on envelope pass, delegate body validation to `bash tools/lint/dp.sh`.
9. In `audit` mode, envelope, marker, and drift checks are authoritative.

Exit behavior:
- Pass: prints `OK: response lint passed (mode=<dp|audit>)`.
- Fail: prints `FAIL: ...` and exits non-zero.

`--test` fixtures:
- PASS: `tools/lint/dp.sh --test` succeeds (delegate health check).
- PASS: single fenced block with valid DP envelope (`dp` mode; delegate skipped in self-test fixture for determinism).
- PASS: single fenced block with `**AUDIT -` marker (`audit` mode).
- FAIL: text outside fence.
- FAIL: multiple fenced blocks.
- FAIL: drift token present.
- FAIL: citation token drift markers (`[cite_start]`, `[cite:`, `[/cite]`).
- FAIL: non-DP body start (`dp` mode).
- FAIL: plain audit body without fenced block (`audit` mode).
- FAIL: audit preface text outside fence (`audit` mode).
- FAIL: missing audit marker (`audit` mode).
- FAIL: audit meta chatter token (`audit` mode).
- FAIL: audit citation token (`audit` mode).
- FAIL: trailing text outside fence.

## Anecdotal Anchor
DP drafting regressions showed repeated model output drift where correct content was wrapped with extra commentary or non-canonical fragments. Envelope gating isolates that class of failure at ingress.

## Integrity Filter Warnings
`response.sh` is an ingress contract gate. In `dp` mode, structural DP validation remains authoritative in `tools/lint/dp.sh`. In `audit` mode, strict single-fence envelope checks plus marker and drift checks are the hard floor.
UI-level "thinking" or progress text shown by model hosts is not part of the response payload contract; the payload contract applies to the emitted response body only.
