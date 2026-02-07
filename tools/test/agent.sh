#!/usr/bin/env bash
set -euo pipefail

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  echo "ERROR: Must be run inside a git repository." >&2
  exit 1
fi

cd "$REPO_ROOT" || exit 1

AGENTS_DIR="docs/library/agents"
OPS_BIN_DIR="ops/bin"

failures=0

fail() {
  echo "FAIL: $1" >&2
  failures=$((failures + 1))
}

if ! compgen -G "${AGENTS_DIR}/*.md" > /dev/null; then
  echo "No agents found."
  exit 0
fi

for agent in "${AGENTS_DIR}"/*.md; do
  agent_name="$(basename "$agent")"

  if ! grep -q "^## Pointers" "$agent"; then
    fail "${agent_name} missing ## Pointers section"
  fi

  if ! grep -q "^## Scope Boundary" "$agent"; then
    fail "${agent_name} missing ## Scope Boundary section"
  fi

  toolchain_line="$(grep -n "^-[[:space:]]*Authorized toolchain:" "$agent" || true)"
  if [[ -z "$toolchain_line" ]]; then
    fail "${agent_name} missing Authorized toolchain entry"
    continue
  fi

  mapfile -t toolchain_tokens < <(printf '%s\n' "$toolchain_line" | grep -oE '`[^`]+`' | sed -e 's/`//g')
  if (( ${#toolchain_tokens[@]} == 0 )); then
    fail "${agent_name} Authorized toolchain entry has no tokens"
    continue
  fi

  for tool in "${toolchain_tokens[@]}"; do
    if [[ "$tool" == "${OPS_BIN_DIR}/"* ]]; then
      if [[ ! -f "$tool" ]]; then
        fail "${agent_name} references missing toolchain binary '${tool}'"
      fi
    fi
  done

done

if (( failures > 0 )); then
  echo "FAILED: ${failures} error(s) detected." >&2
  exit 1
fi

echo "OK: Agent pointer integrity verified."
