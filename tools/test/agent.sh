#!/usr/bin/env bash
set -euo pipefail

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  echo "ERROR: Must be run inside a git repository." >&2
  exit 1
fi

cd "$REPO_ROOT" || exit 1

AGENTS_DIR="opt/_factory/agents"
OPS_BIN_DIR="ops/bin"

failures=0

fail() {
  echo "FAIL: $1" >&2
  failures=$((failures + 1))
}

validate_pointer() {
  local pointer="$1"
  if [[ -e "$pointer" ]]; then
    return 0
  fi
  return 1
}

validate_toolchain_path() {
  local tool="$1"
  if [[ "$tool" == "${OPS_BIN_DIR}/"* ]]; then
    if [[ -f "$tool" ]]; then
      return 0
    fi
    return 1
  fi
  if [[ -e "$tool" ]]; then
    return 0
  fi
  return 1
}

extract_pointer_tokens() {
  local agent_file="$1"
  awk '
    $0 ~ /^## Pointers/ {in_section=1; next}
    $0 ~ /^## / {in_section=0}
    in_section { print }
  ' "$agent_file" | { grep -oE '`[^`]+`' || true; } | sed -e 's/`//g'
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

  mapfile -t toolchain_tokens < <(printf '%s\n' "$toolchain_line" | { grep -oE '`[^`]+`' || true; } | sed -e 's/`//g')
  if (( ${#toolchain_tokens[@]} == 0 )); then
    fail "${agent_name} Authorized toolchain entry has no tokens"
    continue
  fi

  declare -A toolchain_map=()
  for tool in "${toolchain_tokens[@]}"; do
    toolchain_map["$tool"]=1
    if ! validate_toolchain_path "$tool"; then
      fail "${agent_name} references missing toolchain path '${tool}'"
    fi
  done

  mapfile -t pointer_tokens < <(extract_pointer_tokens "$agent")
  if (( ${#pointer_tokens[@]} == 0 )); then
    fail "${agent_name} Pointers section has no backticked paths"
    continue
  fi

  for pointer in "${pointer_tokens[@]}"; do
    if [[ -n "${toolchain_map[$pointer]+set}" ]]; then
      continue
    fi
    if ! validate_pointer "$pointer"; then
      fail "${agent_name} references missing pointer '${pointer}'"
    fi
  done
done

drift_tool="${OPS_BIN_DIR}/DRIFT-INJECTION"
if [[ -e "$drift_tool" ]]; then
  fail "Drift injection path exists: ${drift_tool}"
else
  if validate_toolchain_path "$drift_tool"; then
    fail "Drift injection failed: missing toolchain path was not detected"
  else
    echo "OK: Drift injection detected missing toolchain path."
  fi
fi

if (( failures > 0 )); then
  echo "FAILED: ${failures} error(s) detected." >&2
  exit 1
fi

echo "OK: Agent pointer integrity verified."
