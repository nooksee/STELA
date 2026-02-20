#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/common.sh"

THRESHOLD="${THRESHOLD:-30}"
ARCHIVE_DIR="${ARCHIVE_DIR:-${REPO_ROOT}/archives/surfaces}"
RESUME_DIR="${RESUME_DIR:-${REPO_ROOT}/var/tmp}"

ledger_entry_count() {
  local ledger_file="$1"
  grep -cE '^## [0-9]{4}-[0-9]{2}-[0-9]{2} ' "$ledger_file" || true
}

ledger_archive_plan() {
  local ledger_file="$1"
  local archive_prefix="$2"

  awk -v threshold="$THRESHOLD" -v archive_dir="$ARCHIVE_DIR" -v prefix="$archive_prefix" '
    /^## [0-9]{4}-[0-9]{2}-[0-9]{2} / {
      entry++
      if (entry > threshold) {
        if (match($0, /^## ([0-9]{4})-([0-9]{2})-([0-9]{2})/, parts)) {
          archive_file = archive_dir "/" prefix "-archive-" parts[1] "-" parts[2] ".md"
          counts[archive_file]++
        }
      }
    }
    END {
      for (file in counts) {
        print file "\t" counts[file]
      }
    }
  ' "$ledger_file" | sort
}

validate_pow_prune_candidates() {
  local pow_file="$1"
  local pointers_tmp
  pointers_tmp="$(mktemp "${RESUME_DIR}/pow-prune-pointers.XXXXXX")"

  if ! awk -v threshold="$THRESHOLD" '
    function trim(s) {
      gsub(/^[[:space:]]+/, "", s)
      gsub(/[[:space:]]+$/, "", s)
      return s
    }
    function reset_fields() {
      packet=0; timestamp=0; work_branch=0; base_head=0; scope=0
      allowlist=0; receipts=0; verification=0; notes=0
      results=0; open=0; dump=0
      results_path=""; open_path=""; dump_path=""
    }
    function finalize_entry(missing) {
      if (entry <= threshold) {
        return
      }

      missing=""
      if (!packet)      missing=missing " Packet ID"
      if (!timestamp)   missing=missing " Timestamp"
      if (!work_branch) missing=missing " Work Branch"
      if (!base_head)   missing=missing " Base HEAD"
      if (!scope)       missing=missing " Scope"
      if (!allowlist)   missing=missing " Target Files allowlist"
      if (!receipts)    missing=missing " Receipt pointers"
      if (!verification) missing=missing " Verification commands"
      if (!notes)       missing=missing " Notes"
      if (!results)     missing=missing " RESULTS"
      if (!open)        missing=missing " OPEN"
      if (!dump)        missing=missing " DUMP"

      if (missing != "") {
        printf "ERROR: PoW prune blocked. Entry missing required fields: %s ::%s\n", header, missing > "/dev/stderr"
        exit 1
      }

      printf "%s\tRESULTS\t%s\n", header, trim(results_path)
      printf "%s\tOPEN\t%s\n", header, trim(open_path)
      printf "%s\tDUMP\t%s\n", header, trim(dump_path)
    }
    /^## [0-9]{4}-[0-9]{2}-[0-9]{2} / {
      if (in_entry) {
        finalize_entry()
      }
      entry++
      in_entry=1
      header=$0
      reset_fields()
      next
    }
    {
      if (!in_entry || entry <= threshold) {
        next
      }

      if ($0 ~ /^[[:space:]]*-[[:space:]]*Packet ID:[[:space:]]*.+$/) packet=1
      if ($0 ~ /^[[:space:]]*-[[:space:]]*Timestamp:[[:space:]]*.+$/) timestamp=1
      if ($0 ~ /^[[:space:]]*-[[:space:]]*Work Branch:[[:space:]]*.+$/) work_branch=1
      if ($0 ~ /^[[:space:]]*-[[:space:]]*Base HEAD:[[:space:]]*.+$/) base_head=1
      if ($0 ~ /^[[:space:]]*-[[:space:]]*Scope:[[:space:]]*.+$/) scope=1
      if ($0 ~ /^[[:space:]]*-[[:space:]]*Target Files allowlist:[[:space:]]*$/) allowlist=1
      if ($0 ~ /^[[:space:]]*-[[:space:]]*Receipt pointers:[[:space:]]*$/) receipts=1
      if ($0 ~ /^[[:space:]]*-[[:space:]]*Verification commands:[[:space:]]*$/) verification=1
      if ($0 ~ /^[[:space:]]*-[[:space:]]*Notes:[[:space:]]*.+$/) notes=1

      if (match($0, /^[[:space:]]*-[[:space:]]*RESULTS:[[:space:]]*(.+)$/, m)) {
        results=1
        results_path=m[1]
      }
      if (match($0, /^[[:space:]]*-[[:space:]]*OPEN:[[:space:]]*(.+)$/, m)) {
        open=1
        open_path=m[1]
      }
      if (match($0, /^[[:space:]]*-[[:space:]]*DUMP:[[:space:]]*(.+)$/, m)) {
        dump=1
        dump_path=m[1]
      }
    }
    END {
      if (in_entry) {
        finalize_entry()
      }
    }
  ' "$pow_file" > "$pointers_tmp"; then
    rm -f "$pointers_tmp"
    echo "${POW_GUARD_FATAL}" >&2
    exit 1
  fi

  local header
  local kind
  local pointer
  local normalized
  local rel_path
  while IFS=$'\t' read -r header kind pointer; do
    [[ -z "$header" ]] && continue

    normalized="$(normalize_path_token "$pointer")"
    if [[ -z "$normalized" ]]; then
      rm -f "$pointers_tmp"
      echo "${POW_GUARD_FATAL}" >&2
      die "PoW prune blocked: empty ${kind} pointer in entry '${header}'."
    fi

    case "$kind" in
      RESULTS)
        if [[ "$normalized" != storage/handoff/*-RESULTS.md ]]; then
          rm -f "$pointers_tmp"
          echo "${POW_GUARD_FATAL}" >&2
          die "PoW prune blocked: RESULTS pointer must target storage/handoff/*-RESULTS.md (${normalized})."
        fi
        ;;
      OPEN)
        if [[ "$normalized" != storage/handoff/OPEN-* ]]; then
          rm -f "$pointers_tmp"
          echo "${POW_GUARD_FATAL}" >&2
          die "PoW prune blocked: OPEN pointer must target storage/handoff/OPEN-* (${normalized})."
        fi
        ;;
      DUMP)
        if [[ "$normalized" != storage/dumps/dump-* ]]; then
          rm -f "$pointers_tmp"
          echo "${POW_GUARD_FATAL}" >&2
          die "PoW prune blocked: DUMP pointer must target storage/dumps/dump-* (${normalized})."
        fi
        ;;
      *)
        rm -f "$pointers_tmp"
        echo "${POW_GUARD_FATAL}" >&2
        die "PoW prune blocked: unknown receipt pointer type '${kind}'."
        ;;
    esac

    rel_path="$normalized"
    if [[ ! -f "${REPO_ROOT}/${rel_path}" ]]; then
      rm -f "$pointers_tmp"
      echo "${POW_GUARD_FATAL}" >&2
      die "PoW prune blocked: pointer target missing (${rel_path})."
    fi
    if ! git -C "${REPO_ROOT}" ls-files --error-unmatch -- "$rel_path" >/dev/null 2>&1; then
      rm -f "$pointers_tmp"
      echo "${POW_GUARD_FATAL}" >&2
      die "PoW prune blocked: pointer target is not committed (${rel_path})."
    fi
    if ! git -C "${REPO_ROOT}" diff --quiet -- "$rel_path"; then
      rm -f "$pointers_tmp"
      echo "${POW_GUARD_FATAL}" >&2
      die "PoW prune blocked: pointer target has unstaged changes (${rel_path})."
    fi
    if ! git -C "${REPO_ROOT}" diff --cached --quiet -- "$rel_path"; then
      rm -f "$pointers_tmp"
      echo "${POW_GUARD_FATAL}" >&2
      die "PoW prune blocked: pointer target has staged changes (${rel_path})."
    fi
  done < "$pointers_tmp"

  cat "$pointers_tmp"
  rm -f "$pointers_tmp"
}

ledger_extract_candidates() {
  local pow_file="$1"
  local sop_file="$2"

  [[ -f "$pow_file" ]] || die "PoW.md not found at ${pow_file}"
  [[ -f "$sop_file" ]] || die "SoP.md not found at ${sop_file}"

  local entry_count
  entry_count="$(ledger_entry_count "$pow_file")"
  [[ -z "$entry_count" ]] && entry_count=0
  if (( entry_count <= THRESHOLD )); then
    return 0
  fi

  local prune_count=$((entry_count - THRESHOLD))
  local cut_line
  cut_line="$(grep -nE '^## [0-9]{4}-[0-9]{2}-[0-9]{2} ' "$pow_file" | awk -F: -v threshold="$THRESHOLD" 'NR==threshold+1 { print $1; exit }')"
  [[ -n "$cut_line" ]] || die "Unable to determine prune cut line for PoW."
  [[ "$prune_count" -ge 1 ]] || return 0

  local index_tmp
  index_tmp="$(mktemp "${RESUME_DIR}/pow-prune-index.XXXXXX")"
  awk -v threshold="$THRESHOLD" '
    /^## [0-9]{4}-[0-9]{2}-[0-9]{2} / {
      entry++
      if (entry > threshold) {
        print entry "\t" $0
      }
    }
  ' "$pow_file" > "$index_tmp"

  declare -A index_by_header=()
  declare -A results_by_header=()
  declare -A open_by_header=()
  declare -A dump_by_header=()
  declare -a ordered_headers=()

  local entry_index
  local header
  while IFS=$'\t' read -r entry_index header; do
    [[ -z "$header" ]] && continue
    index_by_header["$header"]="$entry_index"
    ordered_headers+=("$header")
  done < "$index_tmp"

  local kind
  local pointer
  while IFS=$'\t' read -r header kind pointer; do
    [[ -z "$header" ]] && continue
    pointer="$(normalize_path_token "$pointer")"
    case "$kind" in
      RESULTS) results_by_header["$header"]="$pointer" ;;
      OPEN) open_by_header["$header"]="$pointer" ;;
      DUMP) dump_by_header["$header"]="$pointer" ;;
    esac
  done < <(validate_pow_prune_candidates "$pow_file")

  for header in "${ordered_headers[@]}"; do
    entry_index="${index_by_header[$header]}"
    if [[ -z "${results_by_header[$header]:-}" || -z "${open_by_header[$header]:-}" || -z "${dump_by_header[$header]:-}" ]]; then
      rm -f "$index_tmp"
      echo "${POW_GUARD_FATAL}" >&2
      die "PoW prune blocked: missing normalized pointer set for entry '${header}'."
    fi
    printf '%s\t%s\t%s\t%s\n' \
      "$entry_index" \
      "${results_by_header[$header]}" \
      "${open_by_header[$header]}" \
      "${dump_by_header[$header]}"
  done

  rm -f "$index_tmp"
}

ledger_prune_surface() {
  local ledger_name="$1"
  local ledger_file="$2"
  local archive_prefix="$3"
  [[ -f "$ledger_file" ]] || die "${ledger_name}.md not found at ${ledger_file}"

  local entry_count
  entry_count="$(ledger_entry_count "$ledger_file")"
  [[ -z "$entry_count" ]] && entry_count=0
  if (( entry_count <= THRESHOLD )); then
    return 0
  fi

  local prune_count=$((entry_count - THRESHOLD))
  local cut_line
  cut_line="$(grep -nE '^## [0-9]{4}-[0-9]{2}-[0-9]{2} ' "$ledger_file" | awk -F: -v threshold="$THRESHOLD" 'NR==threshold+1 { print $1; exit }')"
  [[ -n "$cut_line" ]] || die "Unable to determine prune cut line for ${ledger_name}."

  if [[ "$ledger_name" == "PoW" ]]; then
    validate_pow_prune_candidates "$ledger_file" >/dev/null
  fi

  local archive_plan
  archive_plan="$(ledger_archive_plan "$ledger_file" "$archive_prefix")"
  mkdir -p "${ARCHIVE_DIR}"
  local tmp_keep
  tmp_keep="$(mktemp "${RESUME_DIR}/${archive_prefix,,}-keep.XXXXXX")"

  awk -v threshold="$THRESHOLD" -v keep_file="$tmp_keep" -v archive_dir="$ARCHIVE_DIR" -v prefix="$archive_prefix" '
    BEGIN { entry=0; archive_file="" }
    /^## [0-9]{4}-[0-9]{2}-[0-9]{2} / {
      entry++
      if (entry > threshold) {
        match($0, /^## ([0-9]{4})-([0-9]{2})-([0-9]{2})/, parts)
        archive_file = archive_dir "/" prefix "-archive-" parts[1] "-" parts[2] ".md"
      }
    }
    {
      if (entry <= threshold) {
        print >> keep_file
      } else {
        print >> archive_file
      }
    }
  ' "$ledger_file"

  mv "$tmp_keep" "$ledger_file"
  while IFS=$'\t' read -r archive_path count; do
    [[ -z "$archive_path" ]] && continue
    echo "${ledger_name} archive wrote ${count} entries to ${archive_path#${REPO_ROOT}/}."
  done <<< "$archive_plan"
  echo "Archived ${prune_count} ${ledger_name} entries beyond ${THRESHOLD}."
}
