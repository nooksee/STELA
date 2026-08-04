<!-- CCD: ff_target="operator-technical" ff_band="25-35" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Allowlist Dry-Run Specification

## Purpose

`ops/bin/allowlist` gives the Operator the same mutation-scope answer that certification will use. It delegates to `tools/lint/integrity.sh`; it does not maintain an independent interpretation of scope.

## Contract

1. Accept only `-h` or `--help`; all other arguments fail.
2. Require execution inside a Git worktree.
3. Run the authoritative integrity lint against staged, unstaged, and untracked paths.
4. Preserve the integrity output and exit nonzero when integrity fails.
5. Emit `OK: pre-certification scope dry run passed` only after integrity succeeds.

## Scope Meaning

During an active packet, an ordinary changed path must satisfy both the packet exact mutation scope and the persistent path policy. During `IDLE/COMPLETED` maintenance, the command reports that maintenance mode is active and applies persistent policy only. Certifier-owned current surface paths retain their narrow structural exception.

## Failure Boundary

This helper reports scope state only. It does not edit the persistent policy, change packet scope, invoke certification, or generate closeout surfaces.
