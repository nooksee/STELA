<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/records.sh` exists so that a records directory and its digest list cannot drift apart without the gates noticing. A record is binary and no lint reads its content; the digest list is the only statement of what the record is. Before this lint, the digest list was verified once, by the receipt of the packet that landed it, and a later corruption, deletion, or unlisted addition would have passed every gate.

## Mechanics and Sequencing
The linter takes one optional directory argument (default `opt/_research`) and the digest list `SHA256SUMS` inside it, in `sha256sum` format: 64 hexadecimal characters, two spaces, a bare file name.

Validation steps:
1. Fail when the directory or the digest list is missing.
2. Parse every digest line; reject a malformed line, a name that is not a `.pdf` record, and a duplicate name.
3. Fail for every listed record that does not exist in the directory.
4. Fail for every `.pdf` file in the directory that the digest list does not name.
5. When steps 2 to 4 found nothing, run `sha256sum -c --quiet` inside the directory and fail on any mismatch, printing the names that failed.

`--test` runs six deterministic fixtures in a temporary directory: a clean set (PASS), a tampered record, an unlisted record, a listed record that is missing, a malformed digest line, and a missing digest list (each FAIL).

The lint runs as the `records-digest` lane of `ops/etc/verification.manifest` (packet-local; `full`, `gates`, and `certify-critical` modes), so it runs in every full verify, in pull-request gates that touch the records directory or this lint, and inside certify for packets that change them. Class membership of the directory (which file names may exist there) is `tools/verify.sh` section 3, not this lint.

## Anecdotal Anchor
DP-OPS-0268 landed 156 research records and proved their digests in its receipt; the closing question of its pull request asked whether a corrupted record should fail the gates rather than only a packet receipt. DP-OPS-0270 answered yes with this lint and its lane.

## Integrity Filter Warnings
The lint reads only the top level of the directory; a record in a subdirectory is neither listed nor checked. A digest list that names a file with a path separator is rejected as malformed. The lint does not verify that a record is a well-formed PDF; it verifies that the bytes are the bytes the digest list declares.
