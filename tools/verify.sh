#!/usr/bin/env bash
set -euo pipefail
source "$(git rev-parse --show-toplevel)/ops/lib/scripts/common.sh"

# Stela Repo Hygiene Verification
# Purpose: Ensure repo topology matches filing doctrine and payload surfaces remain bounded.

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  echo "ERROR: Must be run inside a git repository." >&2
  exit 1
fi

cd "$REPO_ROOT" || exit 1
trap 'emit_binary_leaf "verify" "finish"' EXIT
emit_binary_leaf "verify" "start"

usage() {
  cat <<'EOF'
Usage: bash tools/verify.sh [--mode=full|certify-critical]
EOF
}

VERIFY_MODE="full"
for arg in "$@"; do
  case "$arg" in
    --mode=*)
      VERIFY_MODE="${arg#--mode=}"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown arg: ${arg}" >&2
      exit 1
      ;;
  esac
done

case "$VERIFY_MODE" in
  full|certify-critical)
    ;;
  *)
    echo "ERROR: invalid --mode value: ${VERIFY_MODE}" >&2
    exit 1
    ;;
esac

echo "Stela Repo Hygiene Verification"
echo "Root: $REPO_ROOT"
echo "Verification Mode: $VERIFY_MODE"
if [[ "$VERIFY_MODE" == "full" ]]; then
  echo "VERIFY-LANE-ORDER: mode=full order=open-dedup,editor-scaffold,guard-debt-lint,factory-smoke,response-self-test,bundle-smoke"
else
  echo "VERIFY-LANE-ORDER: mode=certify-critical order=open-dedup,bundle-smoke"
fi
echo

errors=0
warnings=0
declare -a VERIFY_LANE_ROWS=()

fail() {
  echo "FAIL: $1" >&2
  errors=$((errors+1))
}

warn() {
  echo "WARN: $1" >&2
  warnings=$((warnings+1))
}

record_verify_lane() {
  local lane="$1"
  local scope="$2"
  local status="$3"
  local duration_seconds="$4"
  local detail="$5"
  VERIFY_LANE_ROWS+=("${lane}"$'\t'"${scope}"$'\t'"${status}"$'\t'"${duration_seconds}"$'\t'"${detail}")
  printf 'VERIFY-LANE: name=%s scope=%s status=%s duration_seconds=%s detail=%s\n' \
    "$lane" "$scope" "$status" "$duration_seconds" "$detail"
}

run_verify_lane() {
  local lane="$1"
  local scope="$2"
  local detail="$3"
  shift 3

  local start_epoch finish_epoch duration_seconds exit_code status
  start_epoch="$(date +%s)"
  set +e
  "$@"
  exit_code=$?
  set -e
  finish_epoch="$(date +%s)"
  duration_seconds=$((finish_epoch - start_epoch))
  if [[ "$exit_code" -eq 0 ]]; then
    status="pass"
  else
    status="fail"
  fi
  record_verify_lane "$lane" "$scope" "$status" "$duration_seconds" "$detail"
  return "$exit_code"
}

emit_verify_lane_summary() {
  local row lane scope status duration_seconds detail
  echo
  echo "Verify lane summary:"
  for row in "${VERIFY_LANE_ROWS[@]}"; do
    IFS=$'\t' read -r lane scope status duration_seconds detail <<< "$row"
    printf 'VERIFY-LANE-SUMMARY: name=%s scope=%s status=%s duration_seconds=%s detail=%s\n' \
      "$lane" "$scope" "$status" "$duration_seconds" "$detail"
  done
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

# 5. Deterministic test suite checks
if [[ ! -f "ops/lib/manifests/BUNDLE.md" ]]; then
  fail "Missing required bundle policy manifest: ops/lib/manifests/BUNDLE.md"
else
  if ! grep -Fq "frontdoor_canonical_binary=ops/bin/bundle" "ops/lib/manifests/BUNDLE.md"; then
    fail "Bundle policy missing canonical front-door declaration"
  fi
  if ! grep -Fq "frontdoor_meta_mode=project_shim" "ops/lib/manifests/BUNDLE.md"; then
    fail "Bundle policy missing meta shim mode declaration"
  fi
fi

if [[ ! -f "tools/test/open.sh" ]]; then
  record_verify_lane "open-dedup" "certify-critical" "missing" "0" "tools/test/open.sh"
  fail "Missing required test script: tools/test/open.sh"
elif ! run_verify_lane "open-dedup" "certify-critical" "bash tools/test/open.sh" bash tools/test/open.sh; then
  fail "OPEN de-dup test failed: tools/test/open.sh"
fi

if [[ ! -f "tools/test/editor.sh" ]]; then
  record_verify_lane "editor-scaffold" "full-only" "missing" "0" "tools/test/editor.sh"
  fail "Missing required test script: tools/test/editor.sh"
elif [[ "$VERIFY_MODE" == "full" ]] && ! run_verify_lane "editor-scaffold" "full-only" "bash tools/test/editor.sh" bash tools/test/editor.sh; then
  fail "Editor scaffold test failed: tools/test/editor.sh"
fi

if [[ "$VERIFY_MODE" == "full" ]]; then
  if [[ ! -f "tools/lint/debt.sh" ]]; then
    record_verify_lane "guard-debt-lint" "full-only" "missing" "0" "tools/lint/debt.sh"
    fail "Missing required lint script: tools/lint/debt.sh"
  elif ! run_verify_lane "guard-debt-lint" "full-only" "bash tools/lint/debt.sh" bash tools/lint/debt.sh; then
    fail "Guard debt lint failed: tools/lint/debt.sh"
  fi

  if [[ ! -f "tools/test/factory.sh" ]]; then
    record_verify_lane "factory-smoke" "full-only" "missing" "0" "tools/test/factory.sh"
    fail "Missing required test script: tools/test/factory.sh"
  elif ! run_verify_lane "factory-smoke" "full-only" "bash tools/test/factory.sh" bash tools/test/factory.sh; then
    fail "Factory smoke test failed: tools/test/factory.sh"
  fi

  if [[ ! -f "tools/lint/response.sh" ]]; then
    record_verify_lane "response-self-test" "full-only" "missing" "0" "tools/lint/response.sh --test"
    fail "Missing required lint script: tools/lint/response.sh"
  elif ! run_verify_lane "response-self-test" "full-only" "bash tools/lint/response.sh --test" bash tools/lint/response.sh --test; then
    fail "Response envelope lint self-test failed: tools/lint/response.sh --test"
  fi
fi

if [[ ! -f "tools/test/bundle.sh" ]]; then
  record_verify_lane "bundle-smoke" "certify-critical" "missing" "0" "tools/test/bundle.sh"
  fail "Missing required test script: tools/test/bundle.sh"
elif [[ "$VERIFY_MODE" == "full" ]]; then
  if ! run_verify_lane "bundle-smoke" "certify-critical" "bash tools/test/bundle.sh" bash tools/test/bundle.sh; then
    fail "Bundle smoke test failed: tools/test/bundle.sh"
  fi
else
  if ! run_verify_lane "bundle-smoke" "certify-critical" "bash tools/test/bundle.sh --mode=certify-critical" bash tools/test/bundle.sh --mode=certify-critical; then
    fail "Bundle smoke test failed: tools/test/bundle.sh --mode=certify-critical"
  fi
fi

echo
emit_verify_lane_summary
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
