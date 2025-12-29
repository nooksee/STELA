#!/usr/bin/env bash
set -euo pipefail
WEB="public_html"

# Remove graveyard dirs from deployable webroot
rm -rf "$WEB/legacy" "$WEB/_legacy" "$WEB/old" "$WEB/backups" 2>/dev/null || true
rm -rf "$WEB/modules/_legacy" 2>/dev/null || true

# Remove high-risk / non-prod modules if present
rm -rf "$WEB/modules/phpinfo" 2>/dev/null || true

# Run hygiene check
if [ -x tools/truth/project_truth_check.sh ]; then
  tools/truth/project_truth_check.sh
fi

echo "Cleanup complete."
