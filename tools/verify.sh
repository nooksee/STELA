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
Usage: bash tools/verify.sh [--mode=full|gates|certify-critical] [--paths-file=PATH]
EOF
}

VERIFY_MODE="full"
VERIFY_PATHS_FILE=""
for arg in "$@"; do
  case "$arg" in
    --mode=*)
      VERIFY_MODE="${arg#--mode=}"
      ;;
    --paths-file=*)
      VERIFY_PATHS_FILE="${arg#--paths-file=}"
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
  full|gates|certify-critical)
    ;;
  *)
    echo "ERROR: invalid --mode value: ${VERIFY_MODE}" >&2
    exit 1
    ;;
esac

VERIFY_POLICY_PATH="${REPO_ROOT}/ops/etc/verification.manifest"
declare -a VERIFY_POLICY_LANES=()
declare -a VERIFY_SELECTED_LANES=()
declare -a VERIFY_DEFERRED_LANES=()
declare -a VERIFY_CHANGED_PATHS=()
declare -A VERIFY_REGISTRY_FILES=(
  [binaries]="${REPO_ROOT}/docs/ops/registry/binaries.md"
  [lint]="${REPO_ROOT}/docs/ops/registry/lint.md"
  [test]="${REPO_ROOT}/docs/ops/registry/test.md"
)

echo "Stela Repo Hygiene Verification"
echo "Root: $REPO_ROOT"
echo "Verification Mode: $VERIFY_MODE"
if [[ -n "$VERIFY_PATHS_FILE" ]]; then
  VERIFY_PATHS_FILE="${VERIFY_PATHS_FILE#./}"
  if [[ "$VERIFY_PATHS_FILE" != /* ]]; then
    VERIFY_PATHS_FILE="${REPO_ROOT}/${VERIFY_PATHS_FILE}"
  fi
  if [[ ! -f "$VERIFY_PATHS_FILE" ]]; then
    echo "ERROR: --paths-file not found: ${VERIFY_PATHS_FILE}" >&2
    exit 1
  fi
  echo "Verification Paths File: ${VERIFY_PATHS_FILE#${REPO_ROOT}/}"
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

trim_verify_value() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

registry_importance_for_path() {
  local registry_table="$1"
  local registry_path="$2"
  local registry_file="${VERIFY_REGISTRY_FILES[$registry_table]:-}"
  local importance=""

  [[ -n "$registry_file" ]] || {
    fail "verify policy references unknown registry table: ${registry_table}"
    return 1
  }
  [[ -f "$registry_file" ]] || {
    fail "verify policy registry file missing: ${registry_file#${REPO_ROOT}/}"
    return 1
  }

  importance="$(
    awk -F'|' -v expected="$registry_path" '
      /^\|/ {
        file_path=$4
        infra=$5
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", file_path)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", infra)
        if (file_path == expected) {
          print infra
          exit
        }
      }
    ' "$registry_file"
  )"
  importance="$(trim_verify_value "$importance")"
  if [[ -z "$importance" ]]; then
    fail "verify policy registry lookup failed: ${registry_table}:${registry_path}"
    return 1
  fi
  printf '%s' "$importance"
}

load_verify_policy() {
  local line=""
  [[ -f "$VERIFY_POLICY_PATH" ]] || {
    fail "Missing required verify policy manifest: ${VERIFY_POLICY_PATH#${REPO_ROOT}/}"
    return 1
  }

  VERIFY_POLICY_LANES=()
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" == lane=* ]] || continue
    VERIFY_POLICY_LANES+=("$line")
  done < "$VERIFY_POLICY_PATH"

  if (( ${#VERIFY_POLICY_LANES[@]} == 0 )); then
    fail "Verify policy manifest contains no lane definitions"
    return 1
  fi
}

verify_lane_field() {
  local lane="$1"
  local field_name="$2"
  local part=""
  local stripped="${lane#lane=}"
  IFS='|' read -r -a parts <<< "$stripped"

  if [[ "$field_name" == "name" ]]; then
    printf '%s' "${parts[0]}"
    return 0
  fi

  for part in "${parts[@]:1}"; do
    if [[ "${part%%=*}" == "$field_name" ]]; then
      printf '%s' "${part#*=}"
      return 0
    fi
  done
  printf '%s' ""
}

lane_supports_mode() {
  local lane="$1"
  local mode="$2"
  local modes_csv
  local mode_value
  modes_csv="$(verify_lane_field "$lane" "modes")"
  IFS=',' read -r -a mode_values <<< "$modes_csv"
  for mode_value in "${mode_values[@]}"; do
    mode_value="$(trim_verify_value "$mode_value")"
    [[ "$mode_value" == "$mode" ]] && return 0
  done
  return 1
}

load_verify_changed_paths() {
  local line=""
  VERIFY_CHANGED_PATHS=()
  [[ -n "$VERIFY_PATHS_FILE" ]] || return 0

  while IFS= read -r line || [[ -n "$line" ]]; do
    line="$(trim_verify_value "$line")"
    line="${line#./}"
    [[ -n "$line" ]] || continue
    VERIFY_CHANGED_PATHS+=("$line")
  done < "$VERIFY_PATHS_FILE"
}

lane_matches_changed_paths() {
  local lane="$1"
  local match_csv
  local lane_pattern
  local changed_path

  match_csv="$(verify_lane_field "$lane" "match")"
  IFS=',' read -r -a lane_patterns <<< "$match_csv"
  for lane_pattern in "${lane_patterns[@]}"; do
    lane_pattern="$(trim_verify_value "$lane_pattern")"
    [[ -n "$lane_pattern" ]] || continue
    for changed_path in "${VERIFY_CHANGED_PATHS[@]}"; do
      case "$changed_path" in
        $lane_pattern)
          return 0
          ;;
      esac
    done
  done
  return 1
}

queue_verify_selection() {
  local lane="$1"
  VERIFY_SELECTED_LANES+=("$lane")
}

queue_verify_deferred() {
  local lane="$1"
  local reason="$2"
  VERIFY_DEFERRED_LANES+=("${lane}"$'\t'"${reason}")
}

select_verify_lanes() {
  local lane
  local reason_class

  VERIFY_SELECTED_LANES=()
  VERIFY_DEFERRED_LANES=()

  for lane in "${VERIFY_POLICY_LANES[@]}"; do
    reason_class="$(verify_lane_field "$lane" "reason_class")"

    if [[ "$VERIFY_MODE" == "certify-critical" && "$reason_class" == "standalone-full-only" ]]; then
      queue_verify_deferred "$lane" "standalone-full-only"
      continue
    fi

    if ! lane_supports_mode "$lane" "$VERIFY_MODE"; then
      [[ "$VERIFY_MODE" == "certify-critical" ]] && queue_verify_deferred "$lane" "not-in-mode"
      continue
    fi

    if [[ "$VERIFY_MODE" == "full" ]]; then
      queue_verify_selection "$lane"
      continue
    fi

    case "$reason_class" in
      closeout-critical)
        queue_verify_selection "$lane"
        ;;
      packet-local)
        if [[ -z "$VERIFY_PATHS_FILE" ]]; then
          queue_verify_deferred "$lane" "paths-file-missing"
        elif lane_matches_changed_paths "$lane"; then
          queue_verify_selection "$lane"
        else
          queue_verify_deferred "$lane" "no-path-match"
        fi
        ;;
      standalone-full-only)
        if [[ "$VERIFY_MODE" == "certify-critical" ]]; then
          queue_verify_deferred "$lane" "standalone-full-only"
        elif [[ -z "$VERIFY_PATHS_FILE" ]]; then
          queue_verify_deferred "$lane" "paths-file-missing"
        elif lane_matches_changed_paths "$lane"; then
          queue_verify_selection "$lane"
        else
          queue_verify_deferred "$lane" "no-path-match"
        fi
        ;;
      *)
        fail "verify policy lane has invalid reason_class: $(verify_lane_field "$lane" "name") -> ${reason_class}"
        ;;
    esac
  done
}

emit_verify_selection_output() {
  local lane
  local order_names=()
  local name scope owner registry_table registry_path infra_importance reason_class decision_leaf command
  local deferred_row deferred_reason

  for lane in "${VERIFY_SELECTED_LANES[@]}"; do
    name="$(verify_lane_field "$lane" "name")"
    scope="$(verify_lane_field "$lane" "scope")"
    owner="$(verify_lane_field "$lane" "owner")"
    registry_table="$(verify_lane_field "$lane" "registry_table")"
    registry_path="$(verify_lane_field "$lane" "registry_path")"
    reason_class="$(verify_lane_field "$lane" "reason_class")"
    decision_leaf="$(verify_lane_field "$lane" "decision_leaf")"
    command="$(verify_lane_field "$lane" "command")"
    infra_importance="$(registry_importance_for_path "$registry_table" "$registry_path")" || infra_importance="unknown"
    [[ -n "$decision_leaf" ]] || decision_leaf="none"
    order_names+=("$name")
    printf 'VERIFY-SELECTION: name=%s scope=%s reason_class=%s owner=%s infra_importance=%s decision_leaf=%s detail=%s\n' \
      "$name" "$scope" "$reason_class" "$owner" "$infra_importance" "$decision_leaf" "$command"
  done

  if (( ${#order_names[@]} == 0 )); then
    echo "VERIFY-LANE-ORDER: mode=${VERIFY_MODE} order=(none)"
  else
    local order_csv
    order_csv="$(IFS=,; printf '%s' "${order_names[*]}")"
    echo "VERIFY-LANE-ORDER: mode=${VERIFY_MODE} order=${order_csv}"
  fi

  for deferred_row in "${VERIFY_DEFERRED_LANES[@]}"; do
    IFS=$'\t' read -r lane deferred_reason <<< "$deferred_row"
    name="$(verify_lane_field "$lane" "name")"
    scope="$(verify_lane_field "$lane" "scope")"
    owner="$(verify_lane_field "$lane" "owner")"
    registry_table="$(verify_lane_field "$lane" "registry_table")"
    registry_path="$(verify_lane_field "$lane" "registry_path")"
    reason_class="$(verify_lane_field "$lane" "reason_class")"
    decision_leaf="$(verify_lane_field "$lane" "decision_leaf")"
    command="$(verify_lane_field "$lane" "command")"
    infra_importance="$(registry_importance_for_path "$registry_table" "$registry_path")" || infra_importance="unknown"
    [[ -n "$decision_leaf" ]] || decision_leaf="none"
    printf 'VERIFY-DEFERRED: name=%s scope=%s reason_class=%s owner=%s infra_importance=%s decision_leaf=%s reason=%s detail=%s\n' \
      "$name" "$scope" "$reason_class" "$owner" "$infra_importance" "$decision_leaf" "$deferred_reason" "$command"
  done
}

record_verify_lane() {
  local lane="$1"
  local scope="$2"
  local reason_class="$3"
  local owner="$4"
  local infra_importance="$5"
  local decision_leaf="$6"
  local status="$7"
  local duration_seconds="$8"
  local detail="$9"
  VERIFY_LANE_ROWS+=("${lane}"$'\t'"${scope}"$'\t'"${reason_class}"$'\t'"${owner}"$'\t'"${infra_importance}"$'\t'"${decision_leaf}"$'\t'"${status}"$'\t'"${duration_seconds}"$'\t'"${detail}")
  printf 'VERIFY-LANE: name=%s scope=%s reason_class=%s owner=%s infra_importance=%s decision_leaf=%s status=%s duration_seconds=%s detail=%s\n' \
    "$lane" "$scope" "$reason_class" "$owner" "$infra_importance" "$decision_leaf" "$status" "$duration_seconds" "$detail"
}

run_verify_lane_command() {
  local lane_def="$1"
  local lane scope reason_class owner registry_table registry_path infra_importance decision_leaf command detail required_path
  local start_epoch finish_epoch duration_seconds exit_code status exec_command

  lane="$(verify_lane_field "$lane_def" "name")"
  scope="$(verify_lane_field "$lane_def" "scope")"
  reason_class="$(verify_lane_field "$lane_def" "reason_class")"
  owner="$(verify_lane_field "$lane_def" "owner")"
  registry_table="$(verify_lane_field "$lane_def" "registry_table")"
  registry_path="$(verify_lane_field "$lane_def" "registry_path")"
  decision_leaf="$(verify_lane_field "$lane_def" "decision_leaf")"
  command="$(verify_lane_field "$lane_def" "command")"
  detail="$command"
  exec_command="$command"
  infra_importance="$(registry_importance_for_path "$registry_table" "$registry_path")" || infra_importance="unknown"
  [[ -n "$decision_leaf" ]] || decision_leaf="none"

  required_path=""
  read -r -a command_parts <<< "$command"
  if (( ${#command_parts[@]} > 0 )); then
    if [[ "${command_parts[0]}" == "bash" && ${#command_parts[@]} -gt 1 ]]; then
      required_path="${command_parts[1]}"
    else
      required_path="${command_parts[0]}"
    fi
  fi

  if [[ -n "$required_path" && "$required_path" == ./* ]]; then
    required_path="${required_path#./}"
  fi
  if [[ -n "$required_path" && ! -f "$required_path" ]]; then
    record_verify_lane "$lane" "$scope" "$reason_class" "$owner" "$infra_importance" "$decision_leaf" "missing" "0" "$detail"
    fail "Missing required lane command path: ${required_path}"
    return 1
  fi

  start_epoch="$(date +%s)"
  set +e
  bash -lc "cd \"$REPO_ROOT\" && ${exec_command}" </dev/null
  exit_code=$?
  set -e
  finish_epoch="$(date +%s)"
  duration_seconds=$((finish_epoch - start_epoch))
  if [[ "$exit_code" -eq 0 ]]; then
    status="pass"
  else
    status="fail"
  fi
  record_verify_lane "$lane" "$scope" "$reason_class" "$owner" "$infra_importance" "$decision_leaf" "$status" "$duration_seconds" "$detail"
  return "$exit_code"
}

emit_verify_lane_summary() {
  local row lane scope reason_class owner infra_importance decision_leaf status duration_seconds detail
  echo
  echo "Verify lane summary:"
  for row in "${VERIFY_LANE_ROWS[@]}"; do
    IFS=$'\t' read -r lane scope reason_class owner infra_importance decision_leaf status duration_seconds detail <<< "$row"
    printf 'VERIFY-LANE-SUMMARY: name=%s scope=%s reason_class=%s owner=%s infra_importance=%s decision_leaf=%s status=%s duration_seconds=%s detail=%s\n' \
      "$lane" "$scope" "$reason_class" "$owner" "$infra_importance" "$decision_leaf" "$status" "$duration_seconds" "$detail"
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

load_verify_policy
load_verify_changed_paths
select_verify_lanes
emit_verify_selection_output

for lane_def in "${VERIFY_SELECTED_LANES[@]}"; do
  lane_name="$(verify_lane_field "$lane_def" "name")"
  if ! run_verify_lane_command "$lane_def"; then
    fail "Verify lane failed: ${lane_name}"
  fi
done

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
