#!/usr/bin/env bash
set -euo pipefail
WEB="public_html"
bad=0

for d in legacy _legacy old backups; do
  if [ -d "$WEB/$d" ]; then echo "Forbidden runtime dir: $WEB/$d"; bad=1; fi
  
done
if [ -d "$WEB/modules/_legacy" ]; then echo "Forbidden runtime dir: $WEB/modules/_legacy"; bad=1; fi

for f in README README.md README.htm README.html CREDITS.txt COPYRIGHT.txt NUKECE.gif; do
  if [ -f "$WEB/$f" ]; then echo "Forbidden runtime file: $WEB/$f"; bad=1; fi

done

if [ $bad -ne 0 ]; then
  echo "Fix: move artifacts to /docs or delete. Runtime stays clean." >&2
  exit 1
fi

echo "Runtime hygiene OK"
