#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

POW_POINTER_PATH="${REPO_ROOT}/PoW.md"
SOP_POINTER_PATH="${REPO_ROOT}/SoP.md"
TASK_LEAF_PATH="${REPO_ROOT}/archives/surfaces/TASK-DP-OPS-0071-05a1910f.md"
ALLOWLIST_PATH="${REPO_ROOT}/storage/dp/active/allowlist.txt"
LOG_TELEMETRY_REL="logs/trace-stela-20260218T043441Z-11d57a2b-retroleaf.md"
LOG_TELEMETRY_PATH="${REPO_ROOT}/${LOG_TELEMETRY_REL}"
POW_BACKUP_REL="archives/surfaces/PoW-2026-02-18-05a1910f-phase2dump.md"
SOP_BACKUP_REL="archives/surfaces/SoP-2026-02-18-05a1910f-phase2dump.md"
POW_BACKUP_PATH="${REPO_ROOT}/${POW_BACKUP_REL}"
SOP_BACKUP_PATH="${REPO_ROOT}/${SOP_BACKUP_REL}"

MODE=""

declare -a POW_EXPECTED_RETRO=(
  "archives/surfaces/PoW-2026-02-13-05cdbf5a.md"
  "archives/surfaces/PoW-2026-02-13-f3d6b2e4.md"
  "archives/surfaces/PoW-2026-02-14-7c3f5a8f.md"
  "archives/surfaces/PoW-2026-02-14-8a349bae.md"
  "archives/surfaces/PoW-2026-02-14-234e5a52.md"
  "archives/surfaces/PoW-2026-02-15-839a3bf0.md"
  "archives/surfaces/PoW-2026-02-15-6880cb87.md"
  "archives/surfaces/PoW-2026-02-16-124b6cc8.md"
  "archives/surfaces/PoW-2026-02-16-d5091802.md"
  "archives/surfaces/PoW-2026-02-17-b8221099.md"
)

declare -a SOP_EXPECTED_RETRO=(
  "archives/surfaces/SoP-2026-02-08-cdc6d7a0.md"
  "archives/surfaces/SoP-2026-02-08-cabfb792.md"
  "archives/surfaces/SoP-2026-02-09-19377a71.md"
  "archives/surfaces/SoP-2026-02-10-4e0939e7.md"
  "archives/surfaces/SoP-2026-02-10-89130021.md"
  "archives/surfaces/SoP-2026-02-10-c3611c97.md"
  "archives/surfaces/SoP-2026-02-10-30bd0e71.md"
  "archives/surfaces/SoP-2026-02-10-b8816c2e.md"
  "archives/surfaces/SoP-2026-02-10-b6e62ae1.md"
  "archives/surfaces/SoP-2026-02-11-12945de8.md"
  "archives/surfaces/SoP-2026-02-11-6508d1a6.md"
  "archives/surfaces/SoP-2026-02-11-dce9b9d4.md"
  "archives/surfaces/SoP-2026-02-11-0e2189c7.md"
  "archives/surfaces/SoP-2026-02-12-8d35a655.md"
  "archives/surfaces/SoP-2026-02-12-f8f5d039.md"
  "archives/surfaces/SoP-2026-02-12-34a5b88d.md"
  "archives/surfaces/SoP-2026-02-12-b46fbb9a.md"
  "archives/surfaces/SoP-2026-02-12-2d0e2557.md"
  "archives/surfaces/SoP-2026-02-12-4e88f9bd.md"
  "archives/surfaces/SoP-2026-02-13-7c3f5a8f.md"
  "archives/surfaces/SoP-2026-02-13-05cdbf5a.md"
  "archives/surfaces/SoP-2026-02-13-5b6e1adf.md"
  "archives/surfaces/SoP-2026-02-13-5c9d1b43.md"
  "archives/surfaces/SoP-2026-02-13-8a349bae.md"
  "archives/surfaces/SoP-2026-02-13-234e5a52.md"
  "archives/surfaces/SoP-2026-02-14-839a3bf0.md"
  "archives/surfaces/SoP-2026-02-14-50d98147.md"
  "archives/surfaces/SoP-2026-02-14-6880cb87.md"
  "archives/surfaces/SoP-2026-02-15-4b1d7d68.md"
  "archives/surfaces/SoP-2026-02-15-124b6cc8.md"
  "archives/surfaces/SoP-2026-02-15-57ada04f.md"
)

usage() {
  cat <<'USAGE'
Usage: ops/lib/scripts/retroleaf.sh --dry-run|--apply|--verify
USAGE
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

normalize_path() {
  local value
  value="$(trim "$1")"
  value="${value#\`}"
  value="${value%\`}"
  value="${value#./}"
  if [[ "$value" == "${REPO_ROOT}/"* ]]; then
    value="${value#${REPO_ROOT}/}"
  fi
  printf '%s' "$value"
}

sha8() {
  local value="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    printf '%s' "$value" | sha256sum | awk '{print substr($1, 1, 8)}'
    return 0
  fi
  if command -v shasum >/dev/null 2>&1; then
    printf '%s' "$value" | shasum -a 256 | awk '{print substr($1, 1, 8)}'
    return 0
  fi
  die "sha256 utility is required (sha256sum or shasum)."
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || die "missing required file: ${path#${REPO_ROOT}/}"
}

read_pointer_target() {
  local pointer_path="$1"
  require_file "$pointer_path"
  local line_count
  line_count="$(awk 'END { print NR }' "$pointer_path")"
  [[ "$line_count" == "1" ]] || die "${pointer_path#${REPO_ROOT}/} must be a single-line pointer"
  local rel
  rel="$(normalize_path "$(cat "$pointer_path")")"
  [[ "$rel" =~ ^archives/surfaces/[A-Za-z0-9._/-]+\.md$ ]] || die "invalid pointer target in ${pointer_path#${REPO_ROOT}/}: ${rel}"
  local abs="${REPO_ROOT}/${rel}"
  require_file "$abs"
  printf '%s' "$rel"
}

read_frontmatter_value() {
  local path="$1"
  local key="$2"
  awk -v key="$key" '
    BEGIN { in_fm=0; done=0 }
    NR == 1 {
      if ($0 == "---") { in_fm=1; next }
      done=1
    }
    in_fm {
      if ($0 == "---") { done=1; in_fm=0; next }
      if ($0 ~ ("^" key ":[[:space:]]*")) {
        value=$0
        sub("^[^:]+:[[:space:]]*", "", value)
        print value
        exit
      }
      next
    }
    done { exit }
  ' "$path"
}

init_parse_outputs() {
  POW_META="${TMP_DIR}/pow.meta"
  SOP_META="${TMP_DIR}/sop.meta"
  : > "$POW_META"
  : > "$SOP_META"
}

parse_leaf_entries() {
  local source_path="$1"
  local out_meta="$2"
  local body_dir="$3"
  local current_packet_id="$4"

  mkdir -p "$body_dir"
  awk -v out_meta="$out_meta" -v body_dir="$body_dir" -v current_packet_id="$current_packet_id" '
    BEGIN {
      in_fm=0
      saw_fm=0
      in_entry=0
      entry_idx=0
      header_re="^## [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} UTC .*DP-OPS-[0-9]{4}([^0-9A-Za-z-]|$)"
      body=""
      packet=""
      stamp=""
      created_at=""
      base_head=""
      head_flag=0
    }
    function flush_entry(    body_file, base_out) {
      if (!in_entry) {
        return
      }
      base_out=base_head
      if (base_out == "") {
        base_out="(none)"
      }
      body_file=sprintf("%s/%03d.body", body_dir, entry_idx)
      printf "%s", body > body_file
      close(body_file)
      printf "%03d\t%s\t%s\t%s\t%s\t%s\t%s\n", entry_idx, packet, stamp, created_at, base_out, head_flag, body_file >> out_meta
      body=""
      packet=""
      stamp=""
      created_at=""
      base_head=""
      head_flag=0
      in_entry=0
    }
    NR == 1 {
      if ($0 == "---") {
        in_fm=1
        saw_fm=1
        next
      }
    }
    in_fm {
      if ($0 == "---") {
        in_fm=0
        next
      }
      next
    }
    $0 ~ /^## Template$/ {
      flush_entry()
      next
    }
    $0 ~ header_re {
      flush_entry()
      if (match($0, /^## ([0-9]{4}-[0-9]{2}-[0-9]{2}) ([0-9]{2}:[0-9]{2}:[0-9]{2}) UTC .* (DP-OPS-[0-9]{4})/, m) == 0) {
        next
      }
      in_entry=1
      entry_idx += 1
      packet=m[3]
      stamp=m[1] " " m[2]
      created_at=m[1] "T" m[2] "Z"
      if (packet == current_packet_id) {
        head_flag=1
      } else {
        head_flag=0
      }
      body=$0 "\n"
      next
    }
    in_entry {
      body=body $0 "\n"
      if (match($0, /^- Base HEAD:[[:space:]]*([0-9a-fA-F]{7,})[[:space:]]*$/, h)) {
        base_head=tolower(h[1])
      }
      next
    }
    END {
      flush_entry()
    }
  ' "$source_path"
}

sort_meta_by_timestamp() {
  local in_meta="$1"
  local out_meta="$2"
  sort -t $'\t' -k3,3 "$in_meta" > "$out_meta"
}

load_allowlist() {
  require_file "$ALLOWLIST_PATH"
  declare -gA ALLOWLIST=()
  local line=""
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="$(normalize_path "$line")"
    [[ -n "$line" ]] || continue
    ALLOWLIST["$line"]=1
  done < "$ALLOWLIST_PATH"
}

allowlist_contains() {
  local path="$1"
  [[ -n "${ALLOWLIST[$path]+set}" ]]
}

check_apply_clean_worktree() {
  if ! git -C "$REPO_ROOT" diff --quiet --; then
    die "--apply requires a clean working tree (no unstaged tracked changes)"
  fi
}

require_allowlisted_paths() {
  local -a paths=("$@")
  local path=""
  for path in "${paths[@]}"; do
    if ! allowlist_contains "$path"; then
      die "--apply refused: path is not allowlisted: $path"
    fi
  done
}

declare -a POW_HIST_META=()
declare -a SOP_HIST_META=()

extract_meta_rows() {
  local sorted_meta="$1"
  local bucket="$2"
  local line=""
  local seen_head=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -n "$line" ]] || continue
    IFS=$'\t' read -r _idx packet stamp created base head_flag body_file <<< "$line"
    [[ -n "$packet" ]] || continue
    if [[ "$head_flag" == "1" ]]; then
      if [[ "$bucket" == "pow" ]]; then
        POW_HEAD_PACKET="$packet"
        POW_HEAD_CREATED="$created"
        POW_HEAD_BODY="$body_file"
      else
        SOP_HEAD_PACKET="$packet"
        SOP_HEAD_CREATED="$created"
        SOP_HEAD_BODY="$body_file"
      fi
      seen_head=1
      continue
    fi
    if [[ "$bucket" == "pow" ]]; then
      POW_HIST_META+=("${packet}"$'\t'"${stamp}"$'\t'"${created}"$'\t'"${base}"$'\t'"${body_file}")
    else
      SOP_HIST_META+=("${packet}"$'\t'"${stamp}"$'\t'"${created}"$'\t'"${base}"$'\t'"${body_file}")
    fi
  done < "$sorted_meta"

  if [[ "$seen_head" -eq 0 ]]; then
    die "failed to locate head entry in ${bucket} source leaf"
  fi
}

pow_target_for_index() {
  local idx="$1"
  printf '%s' "${POW_EXPECTED_RETRO[$idx]}"
}

sop_target_for_index() {
  local idx="$1"
  printf '%s' "${SOP_EXPECTED_RETRO[$idx]}"
}

declare -a POW_PLAN_TARGETS=()
declare -a SOP_PLAN_TARGETS=()
declare -a POW_PLAN_BODIES=()
declare -a SOP_PLAN_BODIES=()
declare -a POW_PLAN_CREATED=()
declare -a SOP_PLAN_CREATED=()
declare -a POW_PLAN_PACKET=()
declare -a SOP_PLAN_PACKET=()
declare -a POW_PLAN_BASE=()

build_plans() {
  local i=0
  local row=""

  if [[ "${#POW_HIST_META[@]}" -ne "${#POW_EXPECTED_RETRO[@]}" ]]; then
    die "PoW historical entry count mismatch: expected ${#POW_EXPECTED_RETRO[@]}, found ${#POW_HIST_META[@]}"
  fi
  if [[ "${#SOP_HIST_META[@]}" -ne "${#SOP_EXPECTED_RETRO[@]}" ]]; then
    die "SoP historical entry count mismatch: expected ${#SOP_EXPECTED_RETRO[@]}, found ${#SOP_HIST_META[@]}"
  fi

  declare -gA POW_PACKET_BASE=()
  for i in "${!POW_HIST_META[@]}"; do
    row="${POW_HIST_META[$i]}"
    IFS=$'\t' read -r packet _stamp created base body_file <<< "$row"
    [[ -n "$base" ]] || die "PoW entry missing Base HEAD for packet ${packet}"
    POW_PLAN_TARGETS+=("$(pow_target_for_index "$i")")
    POW_PLAN_BODIES+=("$body_file")
    POW_PLAN_CREATED+=("$created")
    POW_PLAN_PACKET+=("$packet")
    POW_PLAN_BASE+=("$base")
    POW_PACKET_BASE["$packet"]="$base"
  done

  for i in "${!SOP_HIST_META[@]}"; do
    row="${SOP_HIST_META[$i]}"
    IFS=$'\t' read -r packet stamp created _base body_file <<< "$row"
    SOP_PLAN_TARGETS+=("$(sop_target_for_index "$i")")
    SOP_PLAN_BODIES+=("$body_file")
    SOP_PLAN_CREATED+=("$created")
    SOP_PLAN_PACKET+=("$packet")

    # Contract computation retained for telemetry:
    # Prefer matching PoW packet base-hash, fallback to deterministic hash(packet,timestamp).
    if [[ -n "${POW_PACKET_BASE[$packet]+set}" ]]; then
      :
    else
      sha8 "${packet}|${stamp}" >/dev/null
    fi
  done

  POW_HEAD_PREVIOUS="${POW_PLAN_TARGETS[$(( ${#POW_PLAN_TARGETS[@]} - 1 ))]}"
  SOP_HEAD_PREVIOUS="${SOP_PLAN_TARGETS[$(( ${#SOP_PLAN_TARGETS[@]} - 1 ))]}"
}

write_leaf() {
  local rel_path="$1"
  local trace_id="$2"
  local packet_id="$3"
  local created_at="$4"
  local previous="$5"
  local body_file="$6"
  local abs_path="${REPO_ROOT}/${rel_path}"

  mkdir -p "$(dirname "$abs_path")"
  {
    printf -- '---\n'
    printf 'trace_id: %s\n' "$trace_id"
    printf 'packet_id: %s\n' "$packet_id"
    printf 'created_at: %s\n' "$created_at"
    printf 'previous: %s\n' "$previous"
    printf -- '---\n'
    cat "$body_file"
  } > "$abs_path"
}

rewrite_pointer() {
  local pointer_path="$1"
  local rel_target="$2"
  printf '%s\n' "$rel_target" > "$pointer_path"
}

fix_task_previous_cycle_if_needed() {
  local rel_task_leaf="${TASK_LEAF_PATH#${REPO_ROOT}/}"
  local current_previous
  current_previous="$(read_frontmatter_value "$TASK_LEAF_PATH" "previous")"
  current_previous="$(normalize_path "$current_previous")"
  if [[ "$current_previous" == "$rel_task_leaf" ]]; then
    awk '
      BEGIN { in_fm=0 }
      NR == 1 {
        if ($0 == "---") { in_fm=1; print; next }
      }
      in_fm && $0 ~ /^previous:[[:space:]]*/ {
        print "previous: (none)"
        next
      }
      in_fm && $0 == "---" { in_fm=0; print; next }
      { print }
    ' "$TASK_LEAF_PATH" > "${TASK_LEAF_PATH}.tmp"
    mv "${TASK_LEAF_PATH}.tmp" "$TASK_LEAF_PATH"
    TASK_PREVIOUS_FIXED="yes"
  else
    TASK_PREVIOUS_FIXED="no"
  fi
}

emit_plan_summary() {
  {
    echo "Retroleaf dry-run summary"
    echo "- PoW source leaf: ${POW_SOURCE_REL}"
    echo "- SoP source leaf: ${SOP_SOURCE_REL}"
    echo "- PoW entries parsed: $(( ${#POW_HIST_META[@]} + 1 ))"
    echo "- SoP entries parsed: $(( ${#SOP_HIST_META[@]} + 1 ))"
    echo "- PoW historical leaves planned: ${#POW_PLAN_TARGETS[@]}"
    echo "- SoP historical leaves planned: ${#SOP_PLAN_TARGETS[@]}"
    echo "- PoW head rewrite target: ${POW_SOURCE_REL}"
    echo "- SoP head rewrite target: ${SOP_SOURCE_REL}"
    echo "- PoW pointer rewrite: ${POW_SOURCE_REL}"
    echo "- SoP pointer rewrite: ${SOP_SOURCE_REL}"
    echo "- Planned backup copy: ${POW_BACKUP_REL}"
    echo "- Planned backup copy: ${SOP_BACKUP_REL}"
    echo "- Planned telemetry leaf: ${LOG_TELEMETRY_REL}"
  }
}

collect_apply_mutation_paths() {
  APPLY_MUTATION_PATHS=()
  APPLY_MUTATION_PATHS+=("$POW_SOURCE_REL")
  APPLY_MUTATION_PATHS+=("$SOP_SOURCE_REL")
  APPLY_MUTATION_PATHS+=("${POW_POINTER_PATH#${REPO_ROOT}/}")
  APPLY_MUTATION_PATHS+=("${SOP_POINTER_PATH#${REPO_ROOT}/}")
  APPLY_MUTATION_PATHS+=("${TASK_LEAF_PATH#${REPO_ROOT}/}")
  APPLY_MUTATION_PATHS+=("$POW_BACKUP_REL")
  APPLY_MUTATION_PATHS+=("$SOP_BACKUP_REL")
  APPLY_MUTATION_PATHS+=("$LOG_TELEMETRY_REL")
  APPLY_MUTATION_PATHS+=("${POW_PLAN_TARGETS[@]}")
  APPLY_MUTATION_PATHS+=("${SOP_PLAN_TARGETS[@]}")
}

write_telemetry_leaf() {
  mkdir -p "$(dirname "$LOG_TELEMETRY_PATH")"
  {
    echo "# Retroleaf Migration Telemetry"
    echo
    echo "## Dry-run Summary"
    emit_plan_summary
    echo
    echo "## Safety Gates"
    echo "- Apply clean-worktree gate: ${SAFETY_WORKTREE_GATE}"
    echo "- Apply allowlist gate: ${SAFETY_ALLOWLIST_GATE}"
    echo
    echo "## Apply Summary"
    echo "- Backups created: ${POW_BACKUP_REL}, ${SOP_BACKUP_REL}"
    echo "- PoW historical leaves written: ${#POW_PLAN_TARGETS[@]}"
    echo "- SoP historical leaves written: ${#SOP_PLAN_TARGETS[@]}"
    echo "- PoW head leaf rewritten: ${POW_SOURCE_REL}"
    echo "- SoP head leaf rewritten: ${SOP_SOURCE_REL}"
    echo "- PoW pointer rewritten: ${POW_SOURCE_REL}"
    echo "- SoP pointer rewritten: ${SOP_SOURCE_REL}"
    echo "- TASK self-reference previous fixed: ${TASK_PREVIOUS_FIXED}"
    echo "- Timestamp (UTC): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  } > "$LOG_TELEMETRY_PATH"
}

apply_migration() {
  local pow_trace_id="$1"
  local sop_trace_id="$2"
  local i=0
  local previous="(none)"

  cp "$POW_SOURCE_PATH" "$POW_BACKUP_PATH"
  cp "$SOP_SOURCE_PATH" "$SOP_BACKUP_PATH"

  previous="(none)"
  for i in "${!POW_PLAN_TARGETS[@]}"; do
    write_leaf \
      "${POW_PLAN_TARGETS[$i]}" \
      "$pow_trace_id" \
      "${POW_PLAN_PACKET[$i]}" \
      "${POW_PLAN_CREATED[$i]}" \
      "$previous" \
      "${POW_PLAN_BODIES[$i]}"
    previous="${POW_PLAN_TARGETS[$i]}"
  done

  previous="(none)"
  for i in "${!SOP_PLAN_TARGETS[@]}"; do
    write_leaf \
      "${SOP_PLAN_TARGETS[$i]}" \
      "$sop_trace_id" \
      "${SOP_PLAN_PACKET[$i]}" \
      "${SOP_PLAN_CREATED[$i]}" \
      "$previous" \
      "${SOP_PLAN_BODIES[$i]}"
    previous="${SOP_PLAN_TARGETS[$i]}"
  done

  write_leaf \
    "$POW_SOURCE_REL" \
    "$pow_trace_id" \
    "$POW_HEAD_PACKET" \
    "$POW_HEAD_CREATED" \
    "$POW_HEAD_PREVIOUS" \
    "$POW_HEAD_BODY"

  write_leaf \
    "$SOP_SOURCE_REL" \
    "$sop_trace_id" \
    "$SOP_HEAD_PACKET" \
    "$SOP_HEAD_CREATED" \
    "$SOP_HEAD_PREVIOUS" \
    "$SOP_HEAD_BODY"

  rewrite_pointer "$POW_POINTER_PATH" "$POW_SOURCE_REL"
  rewrite_pointer "$SOP_POINTER_PATH" "$SOP_SOURCE_REL"
  fix_task_previous_cycle_if_needed
  write_telemetry_leaf
}

verify_chain() {
  local -a chain_paths=("$@")
  local i=0
  local expected_previous="(none)"
  local current_previous=""
  for i in "${!chain_paths[@]}"; do
    local rel="${chain_paths[$i]}"
    local abs="${REPO_ROOT}/${rel}"
    require_file "$abs"
    current_previous="$(normalize_path "$(read_frontmatter_value "$abs" "previous")")"
    if [[ "$current_previous" != "$expected_previous" ]]; then
      die "chain verification failed for ${rel}: expected previous '${expected_previous}', found '${current_previous}'"
    fi
    expected_previous="$rel"
  done
}

verify_state() {
  local pow_migration_head_rel="archives/surfaces/PoW-2026-02-18-05a1910f.md"
  local sop_migration_head_rel="archives/surfaces/SoP-2026-02-18-05a1910f.md"
  local pow_migration_head_abs="${REPO_ROOT}/${pow_migration_head_rel}"
  local sop_migration_head_abs="${REPO_ROOT}/${sop_migration_head_rel}"

  require_file "$POW_BACKUP_PATH"
  require_file "$SOP_BACKUP_PATH"
  require_file "$LOG_TELEMETRY_PATH"
  verify_chain "${POW_PLAN_TARGETS[@]}"
  verify_chain "${SOP_PLAN_TARGETS[@]}"
  require_file "$pow_migration_head_abs"
  require_file "$sop_migration_head_abs"
  require_file "$TASK_LEAF_PATH"

  local pow_previous
  local sop_previous
  pow_previous="$(normalize_path "$(read_frontmatter_value "$pow_migration_head_abs" "previous")")"
  sop_previous="$(normalize_path "$(read_frontmatter_value "$sop_migration_head_abs" "previous")")"
  [[ "$pow_previous" == "$POW_HEAD_PREVIOUS" ]] || die "PoW head previous mismatch"
  [[ "$sop_previous" == "$SOP_HEAD_PREVIOUS" ]] || die "SoP head previous mismatch"

  local task_previous
  task_previous="$(normalize_path "$(read_frontmatter_value "$TASK_LEAF_PATH" "previous")")"
  [[ "$task_previous" == "(none)" ]] || die "TASK leaf previous is not fixed to (none)"

  local pow_pointer_now
  local sop_pointer_now
  pow_pointer_now="$(normalize_path "$(cat "$POW_POINTER_PATH")")"
  sop_pointer_now="$(normalize_path "$(cat "$SOP_POINTER_PATH")")"
  [[ "$pow_pointer_now" =~ ^archives/surfaces/PoW-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9a-f]{7,}\.md$ ]] || die "PoW pointer is not a valid PoW leaf path"
  [[ "$sop_pointer_now" =~ ^archives/surfaces/SoP-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9a-f]{7,}\.md$ ]] || die "SoP pointer is not a valid SoP leaf path"
  require_file "${REPO_ROOT}/${pow_pointer_now}"
  require_file "${REPO_ROOT}/${sop_pointer_now}"

  echo "OK: retroleaf verify passed."
}

for arg in "$@"; do
  case "$arg" in
    --dry-run|--apply|--verify)
      [[ -z "$MODE" ]] || die "specify exactly one mode"
      MODE="$arg"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $arg"
      ;;
  esac
done

[[ -n "$MODE" ]] || die "missing mode"

cd "$REPO_ROOT"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

POW_SOURCE_REL="$(read_pointer_target "$POW_POINTER_PATH")"
SOP_SOURCE_REL="$(read_pointer_target "$SOP_POINTER_PATH")"
POW_SOURCE_PATH="${REPO_ROOT}/${POW_SOURCE_REL}"
SOP_SOURCE_PATH="${REPO_ROOT}/${SOP_SOURCE_REL}"
require_file "$TASK_LEAF_PATH"

POW_TRACE_ID="$(trim "$(read_frontmatter_value "$POW_SOURCE_PATH" "trace_id")")"
SOP_TRACE_ID="$(trim "$(read_frontmatter_value "$SOP_SOURCE_PATH" "trace_id")")"
POW_CURRENT_PACKET="$(trim "$(read_frontmatter_value "$POW_SOURCE_PATH" "packet_id")")"
SOP_CURRENT_PACKET="$(trim "$(read_frontmatter_value "$SOP_SOURCE_PATH" "packet_id")")"
[[ -n "$POW_TRACE_ID" ]] || die "PoW source missing trace_id front-matter value"
[[ -n "$SOP_TRACE_ID" ]] || die "SoP source missing trace_id front-matter value"
[[ -n "$POW_CURRENT_PACKET" ]] || die "PoW source missing packet_id front-matter value"
[[ -n "$SOP_CURRENT_PACKET" ]] || die "SoP source missing packet_id front-matter value"

init_parse_outputs
PLAN_POW_SOURCE_PATH="$POW_SOURCE_PATH"
PLAN_SOP_SOURCE_PATH="$SOP_SOURCE_PATH"
PLAN_POW_CURRENT_PACKET="$POW_CURRENT_PACKET"
PLAN_SOP_CURRENT_PACKET="$SOP_CURRENT_PACKET"
if [[ "$MODE" == "--verify" || "$MODE" == "--dry-run" ]]; then
  if [[ -f "$POW_BACKUP_PATH" ]] && [[ -f "$SOP_BACKUP_PATH" ]]; then
    PLAN_POW_SOURCE_PATH="$POW_BACKUP_PATH"
    PLAN_SOP_SOURCE_PATH="$SOP_BACKUP_PATH"
    PLAN_POW_CURRENT_PACKET="$(trim "$(read_frontmatter_value "$POW_BACKUP_PATH" "packet_id")")"
    PLAN_SOP_CURRENT_PACKET="$(trim "$(read_frontmatter_value "$SOP_BACKUP_PATH" "packet_id")")"
  fi
fi
parse_leaf_entries "$PLAN_POW_SOURCE_PATH" "$POW_META" "${TMP_DIR}/pow-bodies" "$PLAN_POW_CURRENT_PACKET"
parse_leaf_entries "$PLAN_SOP_SOURCE_PATH" "$SOP_META" "${TMP_DIR}/sop-bodies" "$PLAN_SOP_CURRENT_PACKET"
sort_meta_by_timestamp "$POW_META" "${TMP_DIR}/pow.sorted.meta"
sort_meta_by_timestamp "$SOP_META" "${TMP_DIR}/sop.sorted.meta"
extract_meta_rows "${TMP_DIR}/pow.sorted.meta" "pow"
extract_meta_rows "${TMP_DIR}/sop.sorted.meta" "sop"
build_plans
collect_apply_mutation_paths

case "$MODE" in
  --dry-run)
    emit_plan_summary
    ;;
  --apply)
    SAFETY_WORKTREE_GATE="PASS"
    SAFETY_ALLOWLIST_GATE="PASS"
    check_apply_clean_worktree
    load_allowlist
    require_allowlisted_paths "${APPLY_MUTATION_PATHS[@]}"
    apply_migration "$POW_TRACE_ID" "$SOP_TRACE_ID"
    echo "OK: retroleaf apply completed."
    ;;
  --verify)
    verify_state
    ;;
esac
