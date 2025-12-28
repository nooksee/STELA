# Provenance Repair

Goal: restore missing *upstream* attribution headers **without guessing** and **without misattributing**.

## How it works

`tools/provenance/repair.php` performs a targeted pass:

- Identify PHP files that contain a modern **PHP-Nuke CE / nukeCE** header but **lack explicit legacy attribution**.
- Try to match each file to an upstream distro by:
  1. Relative path (common layouts like `html/`), then
  2. High-similarity comparison of file bodies (header stripped).
- Only if similarity is very high (>= 0.92) and the upstream file has a recognizable attribution header,
  the tool prepends that upstream header and records it in `docs/PROVENANCE_REPAIR_REPORT.md`.

## Provide upstream sources

Place unpacked upstream sources under:

- `tools/provenance/upstream/ravennuke/`
- `tools/provenance/upstream/evolution/`
- `tools/provenance/upstream/phpnuke/`

Tip: keep each upstream as a clean checkout/unzip. Do not mix multiple distros in one folder.

## Run

Dry-run:

```bash
php tools/provenance/repair.php --dry-run=1
```

Write changes:

```bash
php tools/provenance/repair.php
```

## Safety rules

- Never overwrite existing attribution in current files.
- Never “invent” authorship.
- Only restore when there is a strong match.
