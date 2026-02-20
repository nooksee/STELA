# Contractor Brief

**1. Temporary file paths.** Use `var/tmp/` for all temporary files within this repository.
The path `/tmp` is not valid within the Stela repo. `PoT.md §1.1` defines Resume storage;
all temporary writes must target that repository-defined location.

**2. RESULTS receipt generation.** `ops/bin/certify` is the only permitted generator of
RESULTS receipts. Manual assembly of receipt content is prohibited. `PoT.md §4.2` governs.

**3. Receipt commands are mandatory.** When the DP lists mandatory receipt commands (whether
in a `RECEIPT_COMMANDS` slot or in the hardened mandatory stub block), every command in that
block must be executed. No listed command is optional. Skipping any listed command is a STOP
condition.

**4. Disposable artifact prohibition.** OPEN files, dump bundles, and manifest files are
session artifacts. They must not be cited in DP content, committed to the repository, or
referenced in RESULTS as canonical sources.

**5. No invented paths.** All file paths referenced in execution steps must either exist in
the repo dump or be explicitly marked `NEW` in the DP changelog. Pattern paths, globs, and
brace expansions are prohibited.
