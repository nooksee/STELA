#!/usr/bin/env bash
set -euo pipefail

# Stela Repo Hygiene Verification
# Purpose: Ensure repo topology matches filing doctrine and payload surfaces remain bounded.

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  echo "ERROR: Must be run inside a git repository." >&2
  exit 1
fi

cd "$REPO_ROOT" || exit 1

echo "Stela Repo Hygiene Verification"
echo "Root: $REPO_ROOT"
echo

errors=0
warnings=0

fail() {
  echo "FAIL: $1" >&2
  errors=$((errors+1))
}

warn() {
  echo "WARN: $1" >&2
  warnings=$((warnings+1))
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

read_factory_head_value() {
  local head_path="$1"
  local key="$2"
  local value
  value="$(awk -F':' -v key="$key" '
    $1 == key {
      entry=$0
      sub(/^[^:]+:[[:space:]]*/, "", entry)
      print entry
      exit
    }
  ' "$head_path")"
  value="$(trim "$value")"
  if [[ -z "$value" ]]; then
    fail "Factory head missing '${key}:' pointer: ${head_path}"
    return 1
  fi
  printf '%s' "$value"
}

verify_factory_head_pointer() {
  local head_path="$1"
  local key="$2"
  local value
  value="$(read_factory_head_value "$head_path" "$key")" || return 1

  if [[ "$value" == *"-(origin)" ]]; then
    return 0
  fi

  if [[ "$value" != archives/definitions/* ]]; then
    fail "Factory head '${head_path}' ${key}: must point under archives/definitions or use origin sentinel"
    return 1
  fi

  if [[ ! -f "$value" ]]; then
    fail "Factory head '${head_path}' ${key}: unresolved pointer '${value}'"
    return 1
  fi
  return 0
}

# 1. Platform Skeleton Check (Must exist)
required_dirs=(
  "ops"
  "docs"
  "opt"
  "tools"
  "projects"
  ".github"
  "storage"
  "var"
  "logs"
  "archives"
)

for d in "${required_dirs[@]}"; do
  if [[ ! -d "$d" ]]; then
    fail "Missing platform directory: '$d/'"
  fi
done

# Factory head reachability checks (candidate and promotion entry points)
factory_heads=(
  "opt/_factory/AGENTS.md"
  "opt/_factory/TASKS.md"
  "opt/_factory/SKILLS.md"
)

for head_path in "${factory_heads[@]}"; do
  if [[ ! -f "$head_path" ]]; then
    fail "Missing required factory head file: '${head_path}'"
  fi
done

if [[ -f "opt/_factory/AGENTS.md" ]]; then
  verify_factory_head_pointer "opt/_factory/AGENTS.md" "candidate" || true
  verify_factory_head_pointer "opt/_factory/AGENTS.md" "promotion" || true
fi

if [[ -f "opt/_factory/TASKS.md" ]]; then
  verify_factory_head_pointer "opt/_factory/TASKS.md" "candidate" || true
  verify_factory_head_pointer "opt/_factory/TASKS.md" "promotion" || true
fi

if [[ -f "opt/_factory/SKILLS.md" ]]; then
  verify_factory_head_pointer "opt/_factory/SKILLS.md" "candidate" || true
  verify_factory_head_pointer "opt/_factory/SKILLS.md" "promotion" || true
fi

# 2. Payload and Runtime Hygiene Check
# Required storage payload subdirs
if [[ ! -d "storage/handoff" ]]; then
  fail "Missing required storage: 'storage/handoff/'"
fi
if [[ ! -d "storage/dumps" ]]; then
  fail "Missing required storage: 'storage/dumps/'"
fi
if [[ ! -d "storage/dp" ]]; then
  fail "Missing required storage: 'storage/dp/'"
fi

mapfile -t tracked_intake_packets < <(
  git ls-files storage/dp/intake \
    | awk '/^storage\/dp\/intake\/DP-[A-Z]+-[0-9]{4,}\.md$/ { print }'
)
if (( ${#tracked_intake_packets[@]} > 0 )); then
  fail "Tracked intake DP packets are forbidden; move packets to storage/dp/processed/: ${tracked_intake_packets[*]}"
fi

# Required resume and telemetry roots
if [[ ! -d "var/tmp" ]]; then
  fail "Missing required resume directory: 'var/tmp/'"
fi
if [[ ! -d "logs" ]]; then
  fail "Missing required telemetry directory: 'logs/'"
fi

# Required cold archive subdirs
archive_required=(
  "archives/surfaces"
  "archives/definitions"
  "archives/definitions"
  "archives/definitions"
  "archives/manifests"
)
for d in "${archive_required[@]}"; do
  if [[ ! -d "$d" ]]; then
    fail "Missing required archive directory: '${d}/'"
  fi
done

# Required skeleton placeholders for ignored runtime roots
placeholder_required=(
  "var/tmp/.gitkeep"
  "logs/.gitkeep"
  "archives/surfaces/.gitkeep"
  "archives/definitions/.gitkeep"
  "archives/definitions/.gitkeep"
  "archives/definitions/.gitkeep"
  "archives/manifests/.gitkeep"
)
for f in "${placeholder_required[@]}"; do
  if [[ ! -f "$f" ]]; then
    fail "Missing required placeholder file: '${f}'"
  fi
done

# Drift check: warn on unexpected clutter in storage/
# Allowed payload items: README.md, .gitignore, handoff, dumps, dp
for item in storage/*; do
  name="$(basename "$item")"
  case "$name" in
    README.md|.gitignore|handoff|dumps|dp)
      ;;
    *)
      warn "Storage drift: unexpected item 'storage/$name'. Keep storage/ clean."
      ;;
  esac
done

# 3. Filing Doctrine Checks
if ! command -v file >/dev/null 2>&1; then
  fail "Missing dependency: file (required for binary checks)"
else
  docs_opt_binaries=()
  while IFS= read -r -d '' doc_path; do
    encoding="$(file -b --mime-encoding "$doc_path")"
    if [[ "$encoding" == "binary" ]]; then
      docs_opt_binaries+=("$doc_path")
    fi
  done < <(find docs opt -type f -print0)

  if (( ${#docs_opt_binaries[@]} > 0 )); then
    for doc_path in "${docs_opt_binaries[@]}"; do
      case "$doc_path" in
        docs/*)
          fail "Filing Doctrine violation: binary file in docs/: $doc_path"
          ;;
        opt/*)
          fail "Filing Doctrine violation: binary file in opt/: $doc_path"
          ;;
      esac
    done
  fi
fi

doc_non_markdown=()
while IFS= read -r -d '' doc_path; do
  doc_non_markdown+=("$doc_path")
done < <(find docs -type f ! -name '*.md' -print0)

if (( ${#doc_non_markdown[@]} > 0 )); then
  for doc_path in "${doc_non_markdown[@]}"; do
    fail "Filing Doctrine violation: non-markdown file in docs/: $doc_path"
  done
fi

opt_non_markdown=()
while IFS= read -r -d '' opt_path; do
  opt_non_markdown+=("$opt_path")
done < <(find opt -type f ! -name '*.md' -print0)

if (( ${#opt_non_markdown[@]} > 0 )); then
  for opt_path in "${opt_non_markdown[@]}"; do
    fail "Filing Doctrine violation: non-markdown file in opt/: $opt_path"
  done
fi

ops_markdown=()
while IFS= read -r -d '' ops_path; do
  ops_markdown+=("$ops_path")
done < <(find ops -type f -name '*.md' -print0)

if (( ${#ops_markdown[@]} > 0 )); then
  for ops_path in "${ops_markdown[@]}"; do
    case "$ops_path" in
      ops/lib/manifests/*|ops/lib/project/*)
        ;;
      *)
        fail "Filing Doctrine violation: loose markdown in ops/: $ops_path"
        ;;
    esac
  done
fi

# 4. Project Structure Check
# Every project folder must have a README.md (minimal valid artifact)
if [[ -d "projects" ]]; then
  for proj in projects/*; do
    if [[ -d "$proj" ]]; then
      if [[ ! -f "$proj/README.md" ]]; then
        warn "Project invalid: '$proj' missing README.md."
      fi
    fi
  done
fi

echo
if [[ $errors -eq 0 ]]; then
  if [[ $warnings -eq 0 ]]; then
    echo "OK: Clean Platform State."
  else
    echo "PASS (with $warnings warnings)."
  fi
  exit 0
else
  echo "FAILED: $errors error(s) detected."
  exit 1
fi
