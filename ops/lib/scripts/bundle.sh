#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${REPO_ROOT:-}" ]]; then
  if ! REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    echo "ERROR: git repo not found. Run from repo root." >&2
    exit 1
  fi
fi

if ! declare -F die >/dev/null 2>&1; then
  # shellcheck source=/dev/null
  source "${REPO_ROOT}/ops/lib/scripts/common.sh"
fi

BUNDLE_POLICY_PATH="${REPO_ROOT}/ops/lib/manifests/BUNDLE.md"
ASSEMBLY_POLICY_PATH=""
declare -a BUNDLE_SUPPORTED_PROFILES=()
declare -a BUNDLE_HANDOFF_OMIT_PROFILES=()
declare -A BUNDLE_DUMP_SCOPE_BY_PROFILE=()
declare -A BUNDLE_STANCE_TEMPLATE_BY_PROFILE=()
declare -A BUNDLE_ARTIFACT_PREFIX_BY_PROFILE=()
declare -A BUNDLE_PROFILE_ALIAS_BY_INPUT=()
declare -A BUNDLE_PROFILE_ALIAS_DEPRECATION_STATUS_BY_INPUT=()
declare -A BUNDLE_PROFILE_ALIAS_REMOVE_AFTER_DP_BY_INPUT=()

BUNDLE_AUTO_DEFAULT_PROFILE=""
BUNDLE_AUTO_PLAN_PROFILE=""
BUNDLE_PROJECT_PROFILE=""
BUNDLE_AUDIT_PROFILE=""
BUNDLE_FOREMAN_PROFILE=""
BUNDLE_FOREMAN_INTENT_FORM=""
BUNDLE_ARCHITECT_PACKET_ID_SEED=""
BUNDLE_ARCHITECT_PACKET_ID_SEED_SLICE=""
BUNDLE_COMPAT_LEGACY_PREFIX=""
BUNDLE_COMPAT_EMIT_LEGACY=""
BUNDLE_ASSEMBLY_POLICY_MANIFEST=""
BUNDLE_SMOKE_HANDOFF_ROOT=""
BUNDLE_SMOKE_DUMP_ROOT=""
BUNDLE_AUDIT_RESUBMISSION_PREFIX=""
BUNDLE_AUDIT_SUBMISSION_KIND_INITIAL=""
BUNDLE_AUDIT_SUBMISSION_KIND_RERUN=""
BUNDLE_AUDIT_REFRESH_REASON_INITIAL=""
BUNDLE_AUDIT_REFRESH_REASON_RERUN=""
ASSEMBLY_SCHEMA_VERSION=""
ASSEMBLY_REQUIRED_FIELDS=""
ASSEMBLY_REGISTRY_AGENTS_PATH=""
ASSEMBLY_REGISTRY_SKILLS_PATH=""
ASSEMBLY_REGISTRY_TASKS_PATH=""
ASSEMBLY_AGENT_ID_PATTERN=""
ASSEMBLY_SKILL_ID_PATTERN=""
ASSEMBLY_TASK_ID_PATTERN=""
ASSEMBLY_ADVISORY_STELA_PATH=""
ASSEMBLY_ADVISORY_SCAFFOLD_PATH=""
ASSEMBLY_ADVISORY_MODE=""
ASSEMBLY_ADVISORY_MINIMUM_CLEAN_CYCLES=""
ASSEMBLY_RUNTIME_POINTER_EMIT_MODE=""
ASSEMBLY_RUNTIME_POINTER_FORMAT=""
ASSEMBLY_RUNTIME_POINTER_SUFFIX=""
BUNDLE_SUBMISSION_KIND="standard"
BUNDLE_RESUBMISSION_INDEX="0"
BUNDLE_SUPERSEDES_BUNDLE_REL=""
BUNDLE_REFRESH_REASON=""
BUNDLE_RESOLVED_OUTPUT_ABS=""
BUNDLE_RESOLVED_OUTPUT_REL=""
BUNDLE_AUDIT_RESOLVED_OUTPUT_REL=""

bundle_usage() {
  cat <<'USAGE'
Usage: ops/bin/bundle [--profile=auto|analyst|architect|audit|project|conform|hygiene|foreman] [--out=auto|PATH] [--project=<name>] [--intent=<text>] [--slice=<ID>] [--rerun] [--agent-id=<R-AGENT-..> --skill-id=<S-LEARN-..> --task-id=<B-TASK-..>]
USAGE
}

bundle_generate_trace_id() {
  local stamp
  local suffix
  stamp="$(date -u '+%Y%m%dT%H%M%SZ')"
  suffix="$(printf '%04x%04x' "$RANDOM" "$RANDOM")"
  printf 'stela-%s-%s' "$stamp" "$suffix"
}

bundle_to_rel_path() {
  local raw_path="$1"
  raw_path="${raw_path#./}"
  if [[ "$raw_path" == "${REPO_ROOT}/"* ]]; then
    raw_path="${raw_path#${REPO_ROOT}/}"
  fi
  printf '%s' "$raw_path"
}

bundle_display_path() {
  local rel_path
  rel_path="$(bundle_to_rel_path "$1")"
  if [[ "$rel_path" == "$1" && "$rel_path" == /* ]]; then
    printf '%s' "$rel_path"
  else
    printf './%s' "$rel_path"
  fi
}

bundle_json_escape() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  value="${value//$'\r'/\\r}"
  value="${value//$'\t'/\\t}"
  printf '%s' "$value"
}

bundle_bool() {
  if [[ "$1" == "1" ]]; then
    printf 'true'
  else
    printf 'false'
  fi
}

bundle_policy_scalar() {
  local key="$1"
  local value
  value="$(awk -F'=' -v key="$key" '$1==key { print substr($0, index($0, "=") + 1); exit }' "$BUNDLE_POLICY_PATH")"
  trim "$value"
}

bundle_manifest_scalar() {
  local manifest_path="$1"
  local key="$2"
  local value
  value="$(awk -F'=' -v key="$key" '$1==key { print substr($0, index($0, "=") + 1); exit }' "$manifest_path")"
  trim "$value"
}

bundle_parse_csv_lines() {
  local csv="$1"
  local IFS=','
  local item
  for item in $csv; do
    item="$(trim "$item")"
    [[ -n "$item" ]] && printf '%s\n' "$item"
  done
}

bundle_array_contains() {
  local needle="$1"
  shift
  local value
  for value in "$@"; do
    if [[ "$needle" == "$value" ]]; then
      return 0
    fi
  done
  return 1
}

bundle_profile_supported() {
  local profile="$1"
  bundle_array_contains "$profile" "${BUNDLE_SUPPORTED_PROFILES[@]}"
}

bundle_profile_handoff_omitted() {
  local profile="$1"
  bundle_array_contains "$profile" "${BUNDLE_HANDOFF_OMIT_PROFILES[@]}"
}

bundle_load_policy() {
  local required_key
  local profile
  local scope_key
  local stance_key_name
  local prefix_key
  local dump_scope
  local stance_key
  local artifact_prefix
  local omit_csv
  local alias_name
  local alias_status_key
  local alias_remove_after_key
  local alias_status
  local alias_remove_after_dp

  [[ -f "$BUNDLE_POLICY_PATH" ]] || die "bundle policy missing: ${BUNDLE_POLICY_PATH#${REPO_ROOT}/}"

  for required_key in \
    bundle_manifest_version \
    supported_profiles \
    auto_default_profile \
    auto_plan_profile \
    project_profile \
    audit_profile \
    architect_packet_id_seed \
    architect_packet_id_seed_slice \
    compatibility_legacy_bundle_prefix \
    compatibility_emit_legacy_bundle_artifacts \
    smoke_handoff_root \
    smoke_dump_root \
    audit_resubmission_prefix \
    audit_submission_kind_initial \
    audit_submission_kind_rerun \
    audit_refresh_reason_initial \
    audit_refresh_reason_rerun \
    assembly_policy_manifest \
    handoff_omit_profiles; do
    if [[ -z "$(bundle_policy_scalar "$required_key")" ]]; then
      die "bundle policy missing required key: ${required_key}"
    fi
  done

  BUNDLE_SUPPORTED_PROFILES=()
  mapfile -t BUNDLE_SUPPORTED_PROFILES < <(bundle_parse_csv_lines "$(bundle_policy_scalar supported_profiles)")
  (( ${#BUNDLE_SUPPORTED_PROFILES[@]} > 0 )) || die "bundle policy supported_profiles is empty"

  BUNDLE_AUTO_DEFAULT_PROFILE="$(bundle_policy_scalar auto_default_profile)"
  BUNDLE_AUTO_PLAN_PROFILE="$(bundle_policy_scalar auto_plan_profile)"
  BUNDLE_PROJECT_PROFILE="$(bundle_policy_scalar project_profile)"
  BUNDLE_AUDIT_PROFILE="$(bundle_policy_scalar audit_profile)"
  BUNDLE_FOREMAN_PROFILE="$(bundle_policy_scalar foreman_profile)"
  BUNDLE_FOREMAN_INTENT_FORM="$(bundle_policy_scalar foreman_intent_form)"
  BUNDLE_ARCHITECT_PACKET_ID_SEED="$(bundle_policy_scalar architect_packet_id_seed)"
  BUNDLE_ARCHITECT_PACKET_ID_SEED_SLICE="$(bundle_policy_scalar architect_packet_id_seed_slice)"
  [[ -n "$BUNDLE_FOREMAN_PROFILE" ]] || die "bundle policy missing required key: foreman_profile"
  [[ -n "$BUNDLE_FOREMAN_INTENT_FORM" ]] || die "bundle policy missing required key: foreman_intent_form"
  [[ "$BUNDLE_ARCHITECT_PACKET_ID_SEED" =~ ^DP-OPS-[0-9]{4}$ ]] || die "bundle policy has invalid architect_packet_id_seed: ${BUNDLE_ARCHITECT_PACKET_ID_SEED}"
  [[ -n "$BUNDLE_ARCHITECT_PACKET_ID_SEED_SLICE" ]] || die "bundle policy missing required key: architect_packet_id_seed_slice"

  for profile in \
    "$BUNDLE_AUTO_DEFAULT_PROFILE" \
    "$BUNDLE_AUTO_PLAN_PROFILE" \
    "$BUNDLE_PROJECT_PROFILE" \
    "$BUNDLE_AUDIT_PROFILE" \
    "$BUNDLE_FOREMAN_PROFILE"; do
    bundle_profile_supported "$profile" || die "bundle policy references unsupported profile: ${profile}"
  done

  BUNDLE_PROFILE_ALIAS_BY_INPUT=()
  BUNDLE_PROFILE_ALIAS_BY_INPUT["hygiene"]="$(bundle_policy_scalar profile_alias_legacy_hygiene_to)"
  [[ -n "${BUNDLE_PROFILE_ALIAS_BY_INPUT[hygiene]}" ]] || die "bundle policy missing required key: profile_alias_legacy_hygiene_to"
  for profile in "${BUNDLE_PROFILE_ALIAS_BY_INPUT[@]}"; do
    bundle_profile_supported "$profile" || die "bundle policy alias target is unsupported: ${profile}"
  done

  BUNDLE_PROFILE_ALIAS_DEPRECATION_STATUS_BY_INPUT=()
  BUNDLE_PROFILE_ALIAS_REMOVE_AFTER_DP_BY_INPUT=()
  for alias_name in hygiene; do
    alias_status_key="profile_alias_legacy_${alias_name}_deprecation_status"
    alias_remove_after_key="profile_alias_legacy_${alias_name}_remove_after_dp"
    alias_status="$(bundle_policy_scalar "$alias_status_key")"
    alias_remove_after_dp="$(bundle_policy_scalar "$alias_remove_after_key")"
    [[ -n "$alias_status" ]] || die "bundle policy missing required key: ${alias_status_key}"
    [[ -n "$alias_remove_after_dp" ]] || die "bundle policy missing required key: ${alias_remove_after_key}"
    case "$alias_status" in
      active|sunset)
        ;;
      *)
        die "bundle policy has invalid alias deprecation status for ${alias_name}: ${alias_status}"
        ;;
    esac
    if [[ ! "$alias_remove_after_dp" =~ ^DP-OPS-[0-9]{4}$ ]]; then
      die "bundle policy has invalid alias removal target for ${alias_name}: ${alias_remove_after_dp}"
    fi
    BUNDLE_PROFILE_ALIAS_DEPRECATION_STATUS_BY_INPUT["$alias_name"]="$alias_status"
    BUNDLE_PROFILE_ALIAS_REMOVE_AFTER_DP_BY_INPUT["$alias_name"]="$alias_remove_after_dp"
  done

  BUNDLE_DUMP_SCOPE_BY_PROFILE=()
  BUNDLE_STANCE_TEMPLATE_BY_PROFILE=()
  BUNDLE_ARTIFACT_PREFIX_BY_PROFILE=()
  for profile in "${BUNDLE_SUPPORTED_PROFILES[@]}"; do
    scope_key="dump_scope_${profile}"
    stance_key_name="stance_template_${profile}"
    prefix_key="artifact_prefix_${profile}"
    dump_scope="$(bundle_policy_scalar "$scope_key")"
    stance_key="$(bundle_policy_scalar "$stance_key_name")"
    artifact_prefix="$(bundle_policy_scalar "$prefix_key")"
    [[ -n "$dump_scope" ]] || die "bundle policy missing required key: ${scope_key}"
    [[ -n "$stance_key" ]] || die "bundle policy missing required key: ${stance_key_name}"
    [[ -n "$artifact_prefix" ]] || die "bundle policy missing required key: ${prefix_key}"
    case "$dump_scope" in
      full|core|platform|project)
        ;;
      *)
        die "bundle policy has invalid dump scope for ${profile}: ${dump_scope}"
        ;;
    esac
    case "$stance_key" in
      stance-*)
        ;;
      *)
        die "bundle policy has invalid stance template key for ${profile}: ${stance_key}"
        ;;
    esac
    if [[ ! "$artifact_prefix" =~ ^[A-Z][A-Z0-9-]*$ ]]; then
      die "bundle policy has invalid artifact prefix for ${profile}: ${artifact_prefix}"
    fi
    BUNDLE_DUMP_SCOPE_BY_PROFILE["$profile"]="$dump_scope"
    BUNDLE_STANCE_TEMPLATE_BY_PROFILE["$profile"]="$stance_key"
    BUNDLE_ARTIFACT_PREFIX_BY_PROFILE["$profile"]="$artifact_prefix"
  done

  BUNDLE_COMPAT_LEGACY_PREFIX="$(bundle_policy_scalar compatibility_legacy_bundle_prefix)"
  BUNDLE_COMPAT_EMIT_LEGACY="$(bundle_policy_scalar compatibility_emit_legacy_bundle_artifacts)"
  BUNDLE_SMOKE_HANDOFF_ROOT="$(bundle_policy_scalar smoke_handoff_root)"
  BUNDLE_SMOKE_DUMP_ROOT="$(bundle_policy_scalar smoke_dump_root)"
  BUNDLE_AUDIT_RESUBMISSION_PREFIX="$(bundle_policy_scalar audit_resubmission_prefix)"
  BUNDLE_AUDIT_SUBMISSION_KIND_INITIAL="$(bundle_policy_scalar audit_submission_kind_initial)"
  BUNDLE_AUDIT_SUBMISSION_KIND_RERUN="$(bundle_policy_scalar audit_submission_kind_rerun)"
  BUNDLE_AUDIT_REFRESH_REASON_INITIAL="$(bundle_policy_scalar audit_refresh_reason_initial)"
  BUNDLE_AUDIT_REFRESH_REASON_RERUN="$(bundle_policy_scalar audit_refresh_reason_rerun)"
  BUNDLE_ASSEMBLY_POLICY_MANIFEST="$(bundle_policy_scalar assembly_policy_manifest)"
  [[ -n "$BUNDLE_ASSEMBLY_POLICY_MANIFEST" ]] || die "bundle policy missing required key: assembly_policy_manifest"
  ASSEMBLY_POLICY_PATH="${REPO_ROOT}/$(bundle_to_rel_path "$BUNDLE_ASSEMBLY_POLICY_MANIFEST")"
  [[ -f "$ASSEMBLY_POLICY_PATH" ]] || die "assembly policy missing: ${ASSEMBLY_POLICY_PATH#${REPO_ROOT}/}"
  if [[ ! "$BUNDLE_COMPAT_LEGACY_PREFIX" =~ ^[A-Z][A-Z0-9-]*$ ]]; then
    die "bundle policy has invalid compatibility legacy prefix: ${BUNDLE_COMPAT_LEGACY_PREFIX}"
  fi
  case "$BUNDLE_COMPAT_EMIT_LEGACY" in
    true|false)
      ;;
    *)
      die "bundle policy has invalid compatibility flag compatibility_emit_legacy_bundle_artifacts: ${BUNDLE_COMPAT_EMIT_LEGACY}"
      ;;
  esac
  [[ "$BUNDLE_SMOKE_HANDOFF_ROOT" == var/tmp/* ]] || die "bundle policy smoke_handoff_root must be under var/tmp/: ${BUNDLE_SMOKE_HANDOFF_ROOT}"
  [[ "$BUNDLE_SMOKE_DUMP_ROOT" == var/tmp/* ]] || die "bundle policy smoke_dump_root must be under var/tmp/: ${BUNDLE_SMOKE_DUMP_ROOT}"
  [[ -n "$BUNDLE_AUDIT_RESUBMISSION_PREFIX" ]] || die "bundle policy missing required key: audit_resubmission_prefix"
  [[ -n "$BUNDLE_AUDIT_SUBMISSION_KIND_INITIAL" ]] || die "bundle policy missing required key: audit_submission_kind_initial"
  [[ -n "$BUNDLE_AUDIT_SUBMISSION_KIND_RERUN" ]] || die "bundle policy missing required key: audit_submission_kind_rerun"
  [[ -n "$BUNDLE_AUDIT_REFRESH_REASON_INITIAL" ]] || die "bundle policy missing required key: audit_refresh_reason_initial"
  [[ -n "$BUNDLE_AUDIT_REFRESH_REASON_RERUN" ]] || die "bundle policy missing required key: audit_refresh_reason_rerun"

  omit_csv="$(bundle_policy_scalar handoff_omit_profiles)"
  BUNDLE_HANDOFF_OMIT_PROFILES=()
  mapfile -t BUNDLE_HANDOFF_OMIT_PROFILES < <(bundle_parse_csv_lines "$omit_csv")
  (( ${#BUNDLE_HANDOFF_OMIT_PROFILES[@]} > 0 )) || die "bundle policy handoff_omit_profiles is empty"
  for profile in "${BUNDLE_HANDOFF_OMIT_PROFILES[@]}"; do
    bundle_profile_supported "$profile" || die "bundle policy handoff_omit_profiles references unsupported profile: ${profile}"
  done

  bundle_load_assembly_policy
}

bundle_load_assembly_policy() {
  local required_key
  local advisory_cycles

  [[ -f "$ASSEMBLY_POLICY_PATH" ]] || die "assembly policy missing: ${ASSEMBLY_POLICY_PATH#${REPO_ROOT}/}"

  for required_key in \
    assembly_schema_version \
    required_fields \
    registry_agents_path \
    registry_skills_path \
    registry_tasks_path \
    agent_id_pattern \
    skill_id_pattern \
    task_id_pattern \
    advisory_input_stela_path \
    advisory_input_scaffold_path \
    advisory_inputs_mode \
    advisory_minimum_clean_cycles \
    runtime_pointer_emit_mode \
    runtime_pointer_format \
    runtime_pointer_suffix; do
    if [[ -z "$(bundle_manifest_scalar "$ASSEMBLY_POLICY_PATH" "$required_key")" ]]; then
      die "assembly policy missing required key: ${required_key}"
    fi
  done

  ASSEMBLY_SCHEMA_VERSION="$(bundle_manifest_scalar "$ASSEMBLY_POLICY_PATH" assembly_schema_version)"
  ASSEMBLY_REQUIRED_FIELDS="$(bundle_manifest_scalar "$ASSEMBLY_POLICY_PATH" required_fields)"
  ASSEMBLY_REGISTRY_AGENTS_PATH="$(bundle_manifest_scalar "$ASSEMBLY_POLICY_PATH" registry_agents_path)"
  ASSEMBLY_REGISTRY_SKILLS_PATH="$(bundle_manifest_scalar "$ASSEMBLY_POLICY_PATH" registry_skills_path)"
  ASSEMBLY_REGISTRY_TASKS_PATH="$(bundle_manifest_scalar "$ASSEMBLY_POLICY_PATH" registry_tasks_path)"
  ASSEMBLY_AGENT_ID_PATTERN="$(bundle_manifest_scalar "$ASSEMBLY_POLICY_PATH" agent_id_pattern)"
  ASSEMBLY_SKILL_ID_PATTERN="$(bundle_manifest_scalar "$ASSEMBLY_POLICY_PATH" skill_id_pattern)"
  ASSEMBLY_TASK_ID_PATTERN="$(bundle_manifest_scalar "$ASSEMBLY_POLICY_PATH" task_id_pattern)"
  ASSEMBLY_ADVISORY_STELA_PATH="$(bundle_manifest_scalar "$ASSEMBLY_POLICY_PATH" advisory_input_stela_path)"
  ASSEMBLY_ADVISORY_SCAFFOLD_PATH="$(bundle_manifest_scalar "$ASSEMBLY_POLICY_PATH" advisory_input_scaffold_path)"
  ASSEMBLY_ADVISORY_MODE="$(bundle_manifest_scalar "$ASSEMBLY_POLICY_PATH" advisory_inputs_mode)"
  ASSEMBLY_ADVISORY_MINIMUM_CLEAN_CYCLES="$(bundle_manifest_scalar "$ASSEMBLY_POLICY_PATH" advisory_minimum_clean_cycles)"
  ASSEMBLY_RUNTIME_POINTER_EMIT_MODE="$(bundle_manifest_scalar "$ASSEMBLY_POLICY_PATH" runtime_pointer_emit_mode)"
  ASSEMBLY_RUNTIME_POINTER_FORMAT="$(bundle_manifest_scalar "$ASSEMBLY_POLICY_PATH" runtime_pointer_format)"
  ASSEMBLY_RUNTIME_POINTER_SUFFIX="$(bundle_manifest_scalar "$ASSEMBLY_POLICY_PATH" runtime_pointer_suffix)"

  [[ "$ASSEMBLY_SCHEMA_VERSION" =~ ^[0-9]+$ ]] || die "assembly policy has invalid assembly_schema_version: ${ASSEMBLY_SCHEMA_VERSION}"
  [[ -n "$ASSEMBLY_REQUIRED_FIELDS" ]] || die "assembly policy required_fields is empty"

  ASSEMBLY_REGISTRY_AGENTS_PATH="$(bundle_to_rel_path "$ASSEMBLY_REGISTRY_AGENTS_PATH")"
  ASSEMBLY_REGISTRY_SKILLS_PATH="$(bundle_to_rel_path "$ASSEMBLY_REGISTRY_SKILLS_PATH")"
  ASSEMBLY_REGISTRY_TASKS_PATH="$(bundle_to_rel_path "$ASSEMBLY_REGISTRY_TASKS_PATH")"
  [[ -f "${REPO_ROOT}/${ASSEMBLY_REGISTRY_AGENTS_PATH}" ]] || die "assembly registry missing: ${ASSEMBLY_REGISTRY_AGENTS_PATH}"
  [[ -f "${REPO_ROOT}/${ASSEMBLY_REGISTRY_SKILLS_PATH}" ]] || die "assembly registry missing: ${ASSEMBLY_REGISTRY_SKILLS_PATH}"
  [[ -f "${REPO_ROOT}/${ASSEMBLY_REGISTRY_TASKS_PATH}" ]] || die "assembly registry missing: ${ASSEMBLY_REGISTRY_TASKS_PATH}"

  [[ -n "$ASSEMBLY_AGENT_ID_PATTERN" ]] || die "assembly policy agent_id_pattern is empty"
  [[ -n "$ASSEMBLY_SKILL_ID_PATTERN" ]] || die "assembly policy skill_id_pattern is empty"
  [[ -n "$ASSEMBLY_TASK_ID_PATTERN" ]] || die "assembly policy task_id_pattern is empty"

  ASSEMBLY_ADVISORY_STELA_PATH="$(bundle_to_rel_path "$ASSEMBLY_ADVISORY_STELA_PATH")"
  ASSEMBLY_ADVISORY_SCAFFOLD_PATH="$(bundle_to_rel_path "$ASSEMBLY_ADVISORY_SCAFFOLD_PATH")"
  case "$ASSEMBLY_ADVISORY_MODE" in
    optional_non_gating)
      ;;
    *)
      die "assembly policy has unsupported advisory_inputs_mode: ${ASSEMBLY_ADVISORY_MODE}"
      ;;
  esac
  advisory_cycles="$ASSEMBLY_ADVISORY_MINIMUM_CLEAN_CYCLES"
  [[ "$advisory_cycles" =~ ^[0-9]+$ ]] || die "assembly policy has invalid advisory_minimum_clean_cycles: ${ASSEMBLY_ADVISORY_MINIMUM_CLEAN_CYCLES}"

  case "$ASSEMBLY_RUNTIME_POINTER_EMIT_MODE" in
    emit_when_applied|disabled)
      ;;
    *)
      die "assembly policy has unsupported runtime_pointer_emit_mode: ${ASSEMBLY_RUNTIME_POINTER_EMIT_MODE}"
      ;;
  esac

  case "$ASSEMBLY_RUNTIME_POINTER_FORMAT" in
    json)
      ;;
    *)
      die "assembly policy has unsupported runtime_pointer_format: ${ASSEMBLY_RUNTIME_POINTER_FORMAT}"
      ;;
  esac

  if [[ ! "$ASSEMBLY_RUNTIME_POINTER_SUFFIX" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
    die "assembly policy has invalid runtime_pointer_suffix: ${ASSEMBLY_RUNTIME_POINTER_SUFFIX}"
  fi
}

bundle_registry_has_id() {
  local registry_rel="$1"
  local expected_id="$2"
  awk -F'|' -v expected_id="$expected_id" '
    BEGIN { found=0 }
    /^\|[[:space:]]*[^|]+[[:space:]]*\|/ {
      id=$2
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", id)
      if (id == expected_id) {
        found=1
        exit
      }
    }
    END {
      if (found == 1) {
        exit 0
      }
      exit 1
    }
  ' "${REPO_ROOT}/${registry_rel}"
}

bundle_runtime_pointer_rel_for_artifact() {
  local artifact_rel="$1"
  local suffix="$2"
  local format="$3"
  local pointer_rel=""

  if [[ "$artifact_rel" == *.* ]]; then
    pointer_rel="${artifact_rel%.*}.${suffix}.${format}"
  else
    pointer_rel="${artifact_rel}.${suffix}.${format}"
  fi
  printf '%s' "$pointer_rel"
}

bundle_reset_submission_metadata() {
  local resolved_profile="$1"

  if [[ "$resolved_profile" == "$BUNDLE_AUDIT_PROFILE" ]]; then
    BUNDLE_SUBMISSION_KIND="$BUNDLE_AUDIT_SUBMISSION_KIND_INITIAL"
    BUNDLE_RESUBMISSION_INDEX="0"
    BUNDLE_SUPERSEDES_BUNDLE_REL=""
    BUNDLE_REFRESH_REASON="$BUNDLE_AUDIT_REFRESH_REASON_INITIAL"
  else
    BUNDLE_SUBMISSION_KIND="standard"
    BUNDLE_RESUBMISSION_INDEX="0"
    BUNDLE_SUPERSEDES_BUNDLE_REL=""
    BUNDLE_REFRESH_REASON=""
  fi
}

bundle_parse_audit_submission_stem() {
  local stem="$1"
  local audit_prefix=""
  local suffix=""
  local remainder=""
  local index=""

  audit_prefix="$(bundle_artifact_prefix_for_profile "$BUNDLE_AUDIT_PROFILE")"
  case "$stem" in
    "${BUNDLE_AUDIT_RESUBMISSION_PREFIX}"[0-9]*-*)
      remainder="${stem#${BUNDLE_AUDIT_RESUBMISSION_PREFIX}}"
      index="${remainder%%-*}"
      suffix="${remainder#${index}-}"
      [[ "$index" =~ ^[0-9]+$ && -n "$suffix" ]] || return 1
      printf '%s\t%s' "$index" "$suffix"
      ;;
    "${audit_prefix}"-*)
      suffix="${stem#${audit_prefix}-}"
      [[ -n "$suffix" ]] || return 1
      printf '0\t%s' "$suffix"
      ;;
    *)
      return 1
      ;;
  esac
}

bundle_resolve_audit_submission_path() {
  local requested_rel="$1"
  local rerun_intent="${2:-0}"
  local requested_name=""
  local requested_dir=""
  local requested_stem=""
  local requested_ext=""
  local parsed=""
  local requested_suffix=""
  local dir_abs=""
  local existing_path=""
  local existing_name=""
  local existing_stem=""
  local existing_parsed=""
  local existing_index=""
  local existing_suffix=""
  local found_existing=0
  local highest_index=-1
  local next_index=0
  local supersedes_rel=""
  local audit_prefix=""

  audit_prefix="$(bundle_artifact_prefix_for_profile "$BUNDLE_AUDIT_PROFILE")"
  requested_name="$(basename "$requested_rel")"
  requested_dir="$(dirname "$requested_rel")"
  requested_stem="$requested_name"
  requested_ext=""
  if [[ "$requested_name" == *.* ]]; then
    requested_stem="${requested_name%.*}"
    requested_ext=".${requested_name##*.}"
  fi

  parsed="$(bundle_parse_audit_submission_stem "$requested_stem" 2>/dev/null || true)"
  if [[ -z "$parsed" ]]; then
    bundle_reset_submission_metadata "$BUNDLE_AUDIT_PROFILE"
    BUNDLE_AUDIT_RESOLVED_OUTPUT_REL="$requested_rel"
    return 0
  fi
  requested_suffix="${parsed#*$'\t'}"
  # Without explicit rerun intent, deliver as initial identity; prior artifact presence is irrelevant.
  if (( rerun_intent == 0 )); then
    BUNDLE_SUBMISSION_KIND="$BUNDLE_AUDIT_SUBMISSION_KIND_INITIAL"
    BUNDLE_RESUBMISSION_INDEX="0"
    BUNDLE_SUPERSEDES_BUNDLE_REL=""
    BUNDLE_REFRESH_REASON="$BUNDLE_AUDIT_REFRESH_REASON_INITIAL"
    BUNDLE_AUDIT_RESOLVED_OUTPUT_REL="$(printf '%s/%s-%s%s' "$requested_dir" "$audit_prefix" "$requested_suffix" "$requested_ext")"
    return 0
  fi
  dir_abs="${REPO_ROOT}/${requested_dir}"
  mkdir -p "$dir_abs"
  shopt -s nullglob
  for existing_path in "$dir_abs"/"${audit_prefix}"-*"$requested_ext" "$dir_abs"/"${BUNDLE_AUDIT_RESUBMISSION_PREFIX}"*"$requested_ext"; do
    [[ -f "$existing_path" ]] || continue
    existing_name="$(basename "$existing_path")"
    existing_stem="$existing_name"
    if [[ -n "$requested_ext" ]]; then
      existing_stem="${existing_name%.*}"
    fi
    existing_parsed="$(bundle_parse_audit_submission_stem "$existing_stem" 2>/dev/null || true)"
    [[ -n "$existing_parsed" ]] || continue
    existing_index="${existing_parsed%%$'\t'*}"
    existing_suffix="${existing_parsed#*$'\t'}"
    [[ "$existing_suffix" == "$requested_suffix" ]] || continue
    found_existing=1
    if (( existing_index > highest_index )); then
      highest_index="$existing_index"
      supersedes_rel="$(bundle_to_rel_path "$existing_path")"
    fi
  done
  shopt -u nullglob

  if (( found_existing == 0 )); then
    BUNDLE_SUBMISSION_KIND="$BUNDLE_AUDIT_SUBMISSION_KIND_INITIAL"
    BUNDLE_RESUBMISSION_INDEX="0"
    BUNDLE_SUPERSEDES_BUNDLE_REL=""
    BUNDLE_REFRESH_REASON="$BUNDLE_AUDIT_REFRESH_REASON_INITIAL"
    BUNDLE_AUDIT_RESOLVED_OUTPUT_REL="$(printf '%s/%s-%s%s' "$requested_dir" "$audit_prefix" "$requested_suffix" "$requested_ext")"
    return 0
  fi

  next_index=$((highest_index + 1))
  BUNDLE_SUBMISSION_KIND="$BUNDLE_AUDIT_SUBMISSION_KIND_RERUN"
  BUNDLE_RESUBMISSION_INDEX="$next_index"
  BUNDLE_SUPERSEDES_BUNDLE_REL="$supersedes_rel"
  BUNDLE_REFRESH_REASON="$BUNDLE_AUDIT_REFRESH_REASON_RERUN"
  BUNDLE_AUDIT_RESOLVED_OUTPUT_REL="$(printf '%s/%s%d-%s%s' "$requested_dir" "$BUNDLE_AUDIT_RESUBMISSION_PREFIX" "$next_index" "$requested_suffix" "$requested_ext")"
}

bundle_resolve_output_path() {
  local out_token="$1"
  local resolved_profile="$2"
  local branch_safe="$3"
  local head_short="$4"
  local project_name="$5"
  local rerun_intent="${6:-0}"

  local out_rel=""
  bundle_reset_submission_metadata "$resolved_profile"
  if [[ "$out_token" == "auto" ]]; then
    local prefix
    prefix="$(bundle_artifact_prefix_for_profile "$resolved_profile")"
    local suffix=""
    if [[ -n "$project_name" ]]; then
      suffix="-${project_name}"
    fi
    out_rel="storage/handoff/${prefix}${suffix}-${branch_safe}-${head_short}.txt"
  else
    out_rel="$(bundle_to_rel_path "$out_token")"
  fi

  if [[ "$resolved_profile" == "$BUNDLE_AUDIT_PROFILE" ]]; then
    bundle_resolve_audit_submission_path "$out_rel" "$rerun_intent"
    out_rel="$BUNDLE_AUDIT_RESOLVED_OUTPUT_REL"
  fi

  case "$out_rel" in
    storage/handoff/*|${BUNDLE_SMOKE_HANDOFF_ROOT}/*)
      ;;
    *)
      die "bundle output must be under storage/handoff/ or ${BUNDLE_SMOKE_HANDOFF_ROOT}/: ${out_rel}"
      ;;
  esac

  if [[ "$out_rel" == ${BUNDLE_SMOKE_HANDOFF_ROOT}/* ]]; then
    mkdir -p "${REPO_ROOT}/${BUNDLE_SMOKE_HANDOFF_ROOT}" "${REPO_ROOT}/${BUNDLE_SMOKE_DUMP_ROOT}"
  fi

  BUNDLE_RESOLVED_OUTPUT_REL="$out_rel"
  BUNDLE_RESOLVED_OUTPUT_ABS="${REPO_ROOT}/${out_rel}"
}

bundle_resolve_dump_output_path() {
  local out_token="$1"
  local artifact_rel="$2"
  local dump_scope="$3"
  local branch_safe="$4"
  local head_short="$5"
  local resolved_profile="$6"
  local artifact_name=""
  local artifact_stem=""
  local dump_root="storage/dumps"

  artifact_name="$(basename "$artifact_rel")"
  artifact_stem="$artifact_name"
  if [[ "$artifact_stem" == *.* ]]; then
    artifact_stem="${artifact_stem%.*}"
  fi

  if [[ "$artifact_rel" == ${BUNDLE_SMOKE_HANDOFF_ROOT}/* ]]; then
    dump_root="$BUNDLE_SMOKE_DUMP_ROOT"
  fi

  if [[ "$out_token" == "auto" && "$resolved_profile" != "$BUNDLE_AUDIT_PROFILE" ]]; then
    printf '%s/dump-%s-%s-%s.txt' "$dump_root" "$dump_scope" "$branch_safe" "$head_short"
  else
    printf '%s/dump-%s-%s.txt' "$dump_root" "$dump_scope" "$artifact_stem"
  fi
}

bundle_dump_scope_for_profile() {
  local profile="$1"
  local mapped_scope="${BUNDLE_DUMP_SCOPE_BY_PROFILE[$profile]:-}"
  [[ -n "$mapped_scope" ]] || die "bundle policy missing dump scope for profile: ${profile}"
  printf '%s' "$mapped_scope"
}

bundle_stance_template_for_profile() {
  local profile="$1"
  local mapped_key="${BUNDLE_STANCE_TEMPLATE_BY_PROFILE[$profile]:-}"
  [[ -n "$mapped_key" ]] || die "bundle policy missing stance template key for profile: ${profile}"
  printf '%s' "$mapped_key"
}

bundle_artifact_prefix_for_profile() {
  local profile="$1"
  local mapped_prefix="${BUNDLE_ARTIFACT_PREFIX_BY_PROFILE[$profile]:-}"
  [[ -n "$mapped_prefix" ]] || die "bundle policy missing artifact prefix for profile: ${profile}"
  printf '%s' "$mapped_prefix"
}

bundle_render_stance_contract_for_profile() {
  local profile="$1"
  local stance_key
  stance_key="$(bundle_stance_template_for_profile "$profile")"

  "${REPO_ROOT}/ops/bin/manifest" render "$stance_key" --out=-
}

bundle_emit_stance_contract() {
  local rendered_abs="$1"
  local normalized_tmp
  normalized_tmp="$(mktemp)"

  awk '
    BEGIN {
      mode=0
      comments_seen=0
    }
    {
      if (mode == 0) {
        if ($0 ~ /^[[:space:]]*<!--.*-->[[:space:]]*$/) {
          comments_seen=1
          next
        }
        if (comments_seen == 1 && $0 ~ /^[[:space:]]*$/) {
          mode=1
          next
        }
        mode=2
        print
        next
      }
      if (mode == 1) {
        if ($0 ~ /^[[:space:]]*$/) {
          next
        }
        mode=2
        print
        next
      }
      print
    }
  ' "$rendered_abs" > "$normalized_tmp"

  if grep -Eq '^Rules:[[:space:]]*$' "$normalized_tmp"; then
    awk '
      /^Rules:[[:space:]]*$/ { emit=1 }
      emit { print }
    ' "$normalized_tmp"
  else
    cat "$normalized_tmp"
  fi

  rm -f "$normalized_tmp"
}

bundle_parse_foreman_intent() {
  local intent_text="$1"
  if [[ "$intent_text" =~ ^ADDENDUM[[:space:]]+REQUIRED:[[:space:]]+([^[:space:]]+)[[:space:]]+-[[:space:]]+(.+)$ ]]; then
    BUNDLE_FOREMAN_DECISION_ID="${BASH_REMATCH[1]}"
    BUNDLE_FOREMAN_BLOCKER="${BASH_REMATCH[2]}"
    return 0
  fi
  return 1
}

bundle_extract_architect_selected_slices() {
  local plan_path="$1"
  awk '
    BEGIN { in_handoff=0 }
    /^##[[:space:]]+Architect Handoff([[:space:]]*)$/ { in_handoff=1; next }
    in_handoff && /^##[[:space:]]+/ { exit }
    in_handoff && /^Selected Slices:[[:space:]]*/ {
      line=$0
      sub(/^Selected Slices:[[:space:]]*/, "", line)
      print line
      exit
    }
  ' "$plan_path"
}

bundle_extract_architect_handoff_scalar() {
  local plan_path="$1"
  local label="$2"
  awk -v label="$label" '
    BEGIN { in_handoff=0 }
    /^##[[:space:]]+Architect Handoff([[:space:]]*)$/ { in_handoff=1; next }
    in_handoff && /^##[[:space:]]+/ { exit }
    in_handoff && index($0, label ":") == 1 {
      line=$0
      sub("^" label ":[[:space:]]*", "", line)
      print line
      exit
    }
  ' "$plan_path"
}

bundle_extract_architect_handoff_block() {
  local plan_path="$1"
  local label="$2"
  awk -v label="$label" '
    BEGIN { in_handoff=0; capture=0 }
    /^##[[:space:]]+Architect Handoff([[:space:]]*)$/ { in_handoff=1; next }
    in_handoff && /^##[[:space:]]+/ { exit }
    in_handoff && $0 == label ":" { capture=1; next }
    capture && /^[A-Za-z][A-Za-z0-9 .()\/-]*:$/ { exit }
    capture { print }
  ' "$plan_path"
}

bundle_extract_architect_slice_title() {
  local plan_path="$1"
  local slice_id="$2"
  awk -v prefix="### " -v slice="$slice_id" '
    index($0, prefix slice " - ") == 1 {
      print substr($0, length(prefix slice " - ") + 1)
      exit
    }
  ' "$plan_path"
}

bundle_extract_architect_slice_field() {
  local plan_path="$1"
  local slice_id="$2"
  local field="$3"
  awk -v prefix="### " -v slice="$slice_id" -v field="$field" '
    BEGIN { in_slice=0; capture=0 }
    index($0, prefix slice " - ") == 1 { in_slice=1; capture=0; next }
    in_slice && /^### / { exit }
    in_slice && /^## / { exit }
    in_slice && $0 == field ":" { capture=1; next }
    capture && /^[A-Za-z][A-Za-z0-9 .()\/-]*:$/ { exit }
    capture { print }
  ' "$plan_path"
}

bundle_extract_architect_execution_order() {
  local plan_path="$1"
  bundle_extract_architect_handoff_scalar "$plan_path" "Execution Order"
}

bundle_packet_id_increment() {
  local seed="$1"
  local offset="$2"
  local prefix=""
  local numeric=""
  local next_value=0

  [[ "$offset" =~ ^-?[0-9]+$ ]] || die "invalid packet offset: ${offset}"
  if [[ "$seed" =~ ^(.+)([0-9]{4})$ ]]; then
    prefix="${BASH_REMATCH[1]}"
    numeric="${BASH_REMATCH[2]}"
  else
    die "invalid architect packet id seed: ${seed}"
  fi

  next_value=$((10#${numeric} + offset))
  (( next_value >= 0 )) || die "architect packet id underflow from seed ${seed} offset ${offset}"
  printf '%s%04d' "$prefix" "$next_value"
}

bundle_resolve_architect_packet_id() {
  local slice_id="$1"
  local plan_path="$2"
  local execution_order=""
  local order_csv=""
  local candidate=""
  local seed_index=-1
  local slice_index=-1
  local index=0

  execution_order="$(bundle_extract_architect_execution_order "$plan_path")"
  [[ -n "$execution_order" ]] || die "architect packet id resolution failed: Execution Order not found in storage/handoff/PLAN.md"
  order_csv="$(printf '%s' "$execution_order" | sed 's/[[:space:]]*->[[:space:]]*/,/g')"

  while IFS= read -r candidate; do
    [[ -n "$candidate" ]] || continue
    if [[ "$candidate" == "$BUNDLE_ARCHITECT_PACKET_ID_SEED_SLICE" ]]; then
      seed_index="$index"
    fi
    if [[ "$candidate" == "$slice_id" ]]; then
      slice_index="$index"
    fi
    index=$((index + 1))
  done < <(bundle_parse_csv_lines "$order_csv")

  (( seed_index >= 0 )) || die "architect packet id seed slice '${BUNDLE_ARCHITECT_PACKET_ID_SEED_SLICE}' missing from Execution Order"
  (( slice_index >= 0 )) || die "architect packet id resolution failed: slice '${slice_id}' missing from Execution Order"
  (( slice_index >= seed_index )) || die "architect packet id resolution failed: slice '${slice_id}' precedes seed slice '${BUNDLE_ARCHITECT_PACKET_ID_SEED_SLICE}'"

  bundle_packet_id_increment "$BUNDLE_ARCHITECT_PACKET_ID_SEED" "$((slice_index - seed_index))"
}

bundle_resolve_architect_implicit_slice() {
  local plan_path="$1"
  local omitted_mode=""
  local selected_slices=""
  local candidate=""
  local selected_count=0
  local selected_slice=""

  omitted_mode="$(bundle_extract_architect_handoff_scalar "$plan_path" "Omitted Slice Mode")"
  [[ "$omitted_mode" == "auto-bind" ]] || return 1

  selected_slices="$(bundle_extract_architect_selected_slices "$plan_path")"
  [[ -n "$selected_slices" ]] || die "architect omitted-slice auto-bind failed: Selected Slices not found in storage/handoff/PLAN.md"

  while IFS= read -r candidate; do
    [[ -n "$candidate" ]] || continue
    selected_slice="$candidate"
    selected_count=$((selected_count + 1))
  done < <(bundle_parse_csv_lines "$selected_slices")

  (( selected_count == 1 )) || die "architect omitted-slice auto-bind failed: Selected Slices must contain exactly one slice"
  printf '%s' "$selected_slice"
}

bundle_emit_prefixed_block() {
  local prefix="$1"
  local content="$2"
  local line=""
  while IFS= read -r line; do
    printf '%s%s\n' "$prefix" "$line"
  done <<< "$content"
}

bundle_emit_architect_slice_projection() {
  local plan_path="$1"
  local slice_id="$2"
  local packet_id="$3"
  local closing_sidecar="$4"
  local title_suffix="$5"
  local selected_option=""
  local execution_order=""
  local objective=""
  local scope=""
  local acceptance_gate=""
  local receipt_contract=""
  local architect_constraints=""

  selected_option="$(bundle_extract_architect_handoff_scalar "$plan_path" "Selected Option")"
  execution_order="$(bundle_extract_architect_execution_order "$plan_path")"
  objective="$(bundle_extract_architect_slice_field "$plan_path" "$slice_id" "Objective")"
  scope="$(bundle_extract_architect_slice_field "$plan_path" "$slice_id" "Scope")"
  acceptance_gate="$(bundle_extract_architect_slice_field "$plan_path" "$slice_id" "Acceptance gate")"
  receipt_contract="$(bundle_extract_architect_slice_field "$plan_path" "$slice_id" "Receipt contract")"
  architect_constraints="$(bundle_extract_architect_handoff_block "$plan_path" "Architect Constraints")"

  echo "[ACTIVE SLICE PROJECTION]"
  echo "- selected_option: ${selected_option:-"(none)"}"
  echo "- selected_slice: ${slice_id}"
  echo "- execution_order: ${execution_order:-"(none)"}"
  echo "- packet_id: ${packet_id}"
  echo "- closing_sidecar: ${closing_sidecar}"
  if [[ -n "$title_suffix" ]]; then
    echo "- title_suffix: ${title_suffix}"
  else
    echo "- title_suffix: (none)"
  fi
  if [[ -n "$objective" ]]; then
    echo "- objective:"
    bundle_emit_prefixed_block "  " "$objective"
  fi
  if [[ -n "$scope" ]]; then
    echo "- scope:"
    bundle_emit_prefixed_block "  " "$scope"
  fi
  if [[ -n "$acceptance_gate" ]]; then
    echo "- acceptance_gate:"
    bundle_emit_prefixed_block "  " "$acceptance_gate"
  fi
  if [[ -n "$receipt_contract" ]]; then
    echo "- receipt_contract:"
    bundle_emit_prefixed_block "  " "$receipt_contract"
  fi
  if [[ -n "$architect_constraints" ]]; then
    echo "- architect_constraints:"
    bundle_emit_prefixed_block "  " "$architect_constraints"
  fi
  echo
}

bundle_validate_architect_slice() {
  local slice_id="$1"
  local plan_path="$2"
  local selected_slices=""
  local slice_found=0
  local candidate=""
  local IFS="," 

  [[ -f "$plan_path" ]] || die "--slice requires storage/handoff/PLAN.md (not present)"

  selected_slices="$(bundle_extract_architect_selected_slices "$plan_path")"
  [[ -n "$selected_slices" ]] || die "slice validation failed: Architect Handoff 'Selected Slices:' not found in storage/handoff/PLAN.md"

  for candidate in $selected_slices; do
    candidate="$(trim "$candidate")"
    if [[ "$candidate" == "$slice_id" ]]; then
      slice_found=1
      break
    fi
  done

  (( slice_found )) || die "unknown slice '${slice_id}' not in Architect Handoff Selected Slices (${selected_slices})"
}

bundle_resolve_task_surface_rel() {
  local task_rel="TASK.md"
  local task_abs="${REPO_ROOT}/${task_rel}"
  local first_line=""

  [[ -f "$task_abs" ]] || die "TASK.md missing"

  first_line="$(sed -n '1p' "$task_abs")"
  first_line="$(trim "$first_line")"
  if [[ -n "$first_line" && -f "${REPO_ROOT}/${first_line}" ]]; then
    printf '%s' "$first_line"
    return 0
  fi

  printf '%s' "$task_rel"
}

bundle_extract_task_packet_id() {
  local task_path="$1"
  awk '
    /^packet_id:[[:space:]]*/ {
      line=$0
      sub(/^packet_id:[[:space:]]*/, "", line)
      print line
      exit
    }
    /^###[[:space:]]*DP-[^:]+:/ {
      line=$0
      sub(/^###[[:space:]]*/, "", line)
      sub(/:.*/, "", line)
      print line
      exit
    }
  ' "$task_path"
}

bundle_resolve_audit_packet_id() {
  local task_surface_rel=""
  local packet_id=""

  task_surface_rel="$(bundle_resolve_task_surface_rel)"
  packet_id="$(bundle_extract_task_packet_id "${REPO_ROOT}/${task_surface_rel}")"
  [[ "$packet_id" =~ ^DP-[A-Z]+-[0-9]{4,}$ ]] || die "audit requires TASK current surface to resolve a certified packet id"
  printf '%s' "$packet_id"
}

bundle_resolve_audit_packet_source_rel() {
  local packet_id="$1"
  local intake_rel="storage/dp/intake/${packet_id}.md"
  local processed_rel="storage/dp/processed/${packet_id}.md"
  local intake_present=0
  local processed_present=0

  [[ -f "${REPO_ROOT}/${intake_rel}" ]] && intake_present=1
  [[ -f "${REPO_ROOT}/${processed_rel}" ]] && processed_present=1

  if (( intake_present && processed_present )); then
    die "audit packet source is ambiguous for ${packet_id}: both ${intake_rel} and ${processed_rel} exist"
  fi
  if (( processed_present )); then
    printf '%s' "$processed_rel"
    return 0
  fi
  if (( intake_present )); then
    printf '%s' "$intake_rel"
    return 0
  fi

  die "audit requires current packet source at ${processed_rel} or ${intake_rel}"
}

bundle_extract_dp_scoped_load_order_paths() {
  local source_path="$1"
  awk '
    function emit_candidate(line, path) {
      path=""
      if (match(line, /^[[:space:]]*([0-9]+[.]|-)[[:space:]]*`([^`]+)`/, m)) {
        path=m[2]
      } else if (match(line, /^[[:space:]]*([0-9]+[.]|-)[[:space:]]*([A-Za-z0-9._\/-]+)/, m)) {
        path=m[1]
        path=m[2]
      }
      if (path != "") {
        print path
      }
    }
    BEGIN {
      in_load_order=0
      saw_load_order=0
    }
    /^### 3[.]2[.]2([.]|[[:space:]])/ {
      in_load_order=1
      saw_load_order=1
      next
    }
    in_load_order && /^##[[:space:]]*3[.]3([.]|[[:space:]])/ { exit }
    in_load_order && /^### 3[.]3([.]|[[:space:]])/ { exit }
    in_load_order { emit_candidate($0) }
    END {
      if (saw_load_order == 0) {
        exit 3
      }
    }
  ' "$source_path"
}

bundle_collect_audit_dump_explicit_inputs() {
  local packet_source_rel="$1"
  local packet_source_abs="${REPO_ROOT}/${packet_source_rel}"
  local candidate=""
  declare -A seen=()

  [[ -f "$packet_source_abs" ]] || die "audit packet source missing while resolving scoped audit evidence: ${packet_source_rel}"

  while IFS= read -r candidate || [[ -n "$candidate" ]]; do
    candidate="$(bundle_to_rel_path "$candidate")"
    [[ -n "$candidate" ]] || continue
    if [[ -n "${seen[$candidate]+set}" ]]; then
      continue
    fi
    if [[ ! -f "${REPO_ROOT}/${candidate}" ]]; then
      continue
    fi
    seen["$candidate"]=1
    printf '%s\n' "$candidate"
  done < <(bundle_extract_dp_scoped_load_order_paths "$packet_source_abs")
}

bundle_collect_profile_disposable_inputs() {
  local profile="$1"
  local topic_rel="$2"
  local plan_rel="$3"
  local audit_packet_id=""
  local results_rel=""
  local closing_rel=""
  local packet_source_rel=""

  case "$profile" in
    analyst)
      [[ -f "${REPO_ROOT}/${topic_rel}" ]] || die "analyst requires ${topic_rel}"
      printf '%s\n' "$topic_rel"
      ;;
    architect)
      if [[ -f "${REPO_ROOT}/${plan_rel}" ]]; then
        printf '%s\n' "$plan_rel"
      fi
      ;;
    audit)
      audit_packet_id="$(bundle_resolve_audit_packet_id)"
      results_rel="storage/handoff/${audit_packet_id}-RESULTS.md"
      closing_rel="storage/handoff/CLOSING-${audit_packet_id}.md"
      packet_source_rel="$(bundle_resolve_audit_packet_source_rel "$audit_packet_id")"
      [[ -f "${REPO_ROOT}/${results_rel}" ]] || die "audit requires ${results_rel}"
      [[ -f "${REPO_ROOT}/${closing_rel}" ]] || die "audit requires ${closing_rel}"
      printf '%s\n%s\n%s\n' "$results_rel" "$closing_rel" "$packet_source_rel"
      ;;
  esac
}

bundle_run() {
  local requested_profile="auto"
  local requested_profile_input="auto"
  local out_token="auto"
  local project_name=""
  local intent_token=""
  local alias_profile_source=""
  local alias_profile_target=""
  local alias_deprecation_status=""
  local alias_remove_after_dp=""
  local alias_applied=0
  local assembly_agent_id=""
  local assembly_skill_id=""
  local assembly_task_id=""
  local assembly_applied=0
  local assembly_stela_present=0
  local assembly_scaffold_present=0
  local assembly_pointer_emitted=0
  local assembly_pointer_rel=""
  local assembly_pointer_abs=""
  local request_slice_id=""
  local request_slice_validated=0
  local request_plan_source=""
  local request_packet_id=""
  local request_closing_sidecar=""
  local request_title_suffix=""
  local rerun_intent=0

  local arg
  for arg in "$@"; do
    case "$arg" in
      --profile=*)
        requested_profile="${arg#--profile=}"
        [[ -n "$requested_profile" ]] || die "--profile requires a value"
        ;;
      --out=*)
        out_token="${arg#--out=}"
        [[ -n "$out_token" ]] || die "--out requires a value"
        ;;
      --project=*)
        project_name="${arg#--project=}"
        [[ -n "$project_name" ]] || die "--project requires a value"
        ;;
      --intent=*)
        intent_token="${arg#--intent=}"
        [[ -n "$intent_token" ]] || die "--intent requires a value"
        ;;
      --slice=*)
        request_slice_id="${arg#--slice=}"
        [[ -n "$request_slice_id" ]] || die "--slice requires a non-empty value"
        ;;
      --agent-id=*)
        assembly_agent_id="${arg#--agent-id=}"
        [[ -n "$assembly_agent_id" ]] || die "--agent-id requires a value"
        ;;
      --skill-id=*)
        assembly_skill_id="${arg#--skill-id=}"
        [[ -n "$assembly_skill_id" ]] || die "--skill-id requires a value"
        ;;
      --task-id=*)
        assembly_task_id="${arg#--task-id=}"
        [[ -n "$assembly_task_id" ]] || die "--task-id requires a value"
        ;;
      --rerun)
        rerun_intent=1
        ;;
      -h|--help)
        bundle_usage
        return 0
        ;;
      *)
        die "Unknown argument: ${arg}"
        ;;
    esac
  done

  bundle_load_policy
  requested_profile_input="$requested_profile"

  alias_profile_target="${BUNDLE_PROFILE_ALIAS_BY_INPUT[$requested_profile]:-}"
  if [[ -n "$alias_profile_target" ]]; then
    alias_profile_source="$requested_profile"
    requested_profile="$alias_profile_target"
    alias_deprecation_status="${BUNDLE_PROFILE_ALIAS_DEPRECATION_STATUS_BY_INPUT[$alias_profile_source]:-}"
    alias_remove_after_dp="${BUNDLE_PROFILE_ALIAS_REMOVE_AFTER_DP_BY_INPUT[$alias_profile_source]:-}"
    [[ -n "$alias_deprecation_status" ]] || die "bundle policy missing alias deprecation status for: ${alias_profile_source}"
    [[ -n "$alias_remove_after_dp" ]] || die "bundle policy missing alias removal target for: ${alias_profile_source}"
    alias_applied=1
  fi

  if [[ "$requested_profile" != "auto" ]] && ! bundle_profile_supported "$requested_profile"; then
    die "unsupported profile: ${requested_profile_input}"
  fi

  if [[ "$requested_profile" == "$BUNDLE_PROJECT_PROFILE" && -z "$project_name" ]]; then
    die "--project is required when --profile=project"
  fi
  if [[ "$requested_profile" != "$BUNDLE_PROJECT_PROFILE" && -n "$project_name" ]]; then
    die "--project is only valid with --profile=project"
  fi
  if [[ "$requested_profile" == "$BUNDLE_FOREMAN_PROFILE" && -z "$intent_token" ]]; then
    die "--intent is required when --profile=${BUNDLE_FOREMAN_PROFILE}"
  fi

  if [[ -n "$project_name" && ! "$project_name" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]; then
    die "project name must match ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$"
  fi

  if [[ -n "$assembly_agent_id" || -n "$assembly_skill_id" || -n "$assembly_task_id" ]]; then
    if [[ -z "$assembly_agent_id" || -z "$assembly_skill_id" || -z "$assembly_task_id" ]]; then
      die "assembly validation requires all ATS flags together: --agent-id, --skill-id, --task-id"
    fi
    assembly_applied=1
  fi

  if (( assembly_applied )); then
    if [[ ! "$assembly_agent_id" =~ $ASSEMBLY_AGENT_ID_PATTERN ]]; then
      die "assembly validation failed: agent_id '${assembly_agent_id}' does not match pattern '${ASSEMBLY_AGENT_ID_PATTERN}'"
    fi
    if [[ ! "$assembly_skill_id" =~ $ASSEMBLY_SKILL_ID_PATTERN ]]; then
      die "assembly validation failed: skill_id '${assembly_skill_id}' does not match pattern '${ASSEMBLY_SKILL_ID_PATTERN}'"
    fi
    if [[ ! "$assembly_task_id" =~ $ASSEMBLY_TASK_ID_PATTERN ]]; then
      die "assembly validation failed: task_id '${assembly_task_id}' does not match pattern '${ASSEMBLY_TASK_ID_PATTERN}'"
    fi

    if ! bundle_registry_has_id "$ASSEMBLY_REGISTRY_AGENTS_PATH" "$assembly_agent_id"; then
      die "assembly validation failed: unknown agent_id '${assembly_agent_id}' in ${ASSEMBLY_REGISTRY_AGENTS_PATH}"
    fi
    if ! bundle_registry_has_id "$ASSEMBLY_REGISTRY_SKILLS_PATH" "$assembly_skill_id"; then
      die "assembly validation failed: unknown skill_id '${assembly_skill_id}' in ${ASSEMBLY_REGISTRY_SKILLS_PATH}"
    fi
    if ! bundle_registry_has_id "$ASSEMBLY_REGISTRY_TASKS_PATH" "$assembly_task_id"; then
      die "assembly validation failed: unknown task_id '${assembly_task_id}' in ${ASSEMBLY_REGISTRY_TASKS_PATH}"
    fi
  fi

  [[ -f "${REPO_ROOT}/${ASSEMBLY_ADVISORY_STELA_PATH}" ]] && assembly_stela_present=1
  [[ -f "${REPO_ROOT}/${ASSEMBLY_ADVISORY_SCAFFOLD_PATH}" ]] && assembly_scaffold_present=1

  local branch
  local head_short
  branch="$(git rev-parse --abbrev-ref HEAD)"
  head_short="$(git rev-parse --short HEAD)"
  local branch_safe="${branch//\//-}"
  local generated_at
  generated_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local trace_id="${STELA_TRACE_ID:-$(bundle_generate_trace_id)}"

  local topic_rel="storage/handoff/TOPIC.md"
  local plan_rel="storage/handoff/PLAN.md"
  local topic_present=0
  local plan_present=0
  local -a profile_disposable_files=()

  [[ -f "${REPO_ROOT}/${topic_rel}" ]] && topic_present=1
  [[ -f "${REPO_ROOT}/${plan_rel}" ]] && plan_present=1

  local resolved_profile="$requested_profile"
  local route_reason="explicit profile"
  local plan_lint_status="NOT_RUN"
  local plan_lint_output="(not run)"

  if [[ "$requested_profile" == "auto" ]]; then
    if (( plan_present )); then
      if plan_lint_output="$(bash "${REPO_ROOT}/tools/lint/plan.sh" "$plan_rel" 2>&1)"; then
        resolved_profile="$BUNDLE_AUTO_PLAN_PROFILE"
        route_reason="auto: PLAN.md present and plan lint passed"
        plan_lint_status="PASS"
      else
        resolved_profile="$BUNDLE_AUTO_DEFAULT_PROFILE"
        route_reason="auto: PLAN.md present but plan lint failed"
        plan_lint_status="FAIL"
      fi
    else
      resolved_profile="$BUNDLE_AUTO_DEFAULT_PROFILE"
      route_reason="auto: PLAN.md missing"
      plan_lint_status="SKIPPED_MISSING"
      plan_lint_output="(missing storage/handoff/PLAN.md)"
    fi
  fi
  if (( alias_applied )); then
    route_reason="explicit profile alias: ${alias_profile_source} -> ${alias_profile_target}"
  fi

  if (( rerun_intent )) && [[ "$resolved_profile" != "$BUNDLE_AUDIT_PROFILE" ]]; then
    die "--rerun is only valid with --profile=${BUNDLE_AUDIT_PROFILE}"
  fi

  if [[ -n "$request_slice_id" && "$resolved_profile" != "architect" ]]; then
    die "--slice is only valid with --profile=architect"
  fi

  if [[ "$resolved_profile" == "architect" && -z "$request_slice_id" ]] && (( plan_present )); then
    local implicit_slice=""
    if implicit_slice="$(bundle_resolve_architect_implicit_slice "${REPO_ROOT}/${plan_rel}")"; then
      request_slice_id="$implicit_slice"
    fi
  fi

  if [[ "$resolved_profile" == "architect" && -n "$request_slice_id" ]]; then
    bundle_validate_architect_slice "$request_slice_id" "${REPO_ROOT}/${plan_rel}"
    request_slice_validated=1
    request_plan_source="$plan_rel"
    request_packet_id="$(bundle_resolve_architect_packet_id "$request_slice_id" "${REPO_ROOT}/${plan_rel}")"
    request_closing_sidecar="storage/handoff/CLOSING-${request_packet_id}.md"
    request_title_suffix="$(bundle_extract_architect_slice_title "${REPO_ROOT}/${plan_rel}" "$request_slice_id")"
  fi

  local stance_template_key
  stance_template_key="$(bundle_stance_template_for_profile "$resolved_profile")"
  local rendered_stance_tmp
  rendered_stance_tmp="$(mktemp)"
  bundle_render_stance_contract_for_profile "$resolved_profile" > "$rendered_stance_tmp"

  bundle_resolve_output_path "$out_token" "$resolved_profile" "$branch_safe" "$head_short" "$project_name" "$rerun_intent"
  local out_abs="$BUNDLE_RESOLVED_OUTPUT_ABS"
  local out_rel="$BUNDLE_RESOLVED_OUTPUT_REL"
  local artifact_prefix
  artifact_prefix="$(bundle_artifact_prefix_for_profile "$resolved_profile")"

  local manifest_abs=""
  if [[ "$out_abs" == *.* ]]; then
    manifest_abs="${out_abs%.*}.manifest.json"
  else
    manifest_abs="${out_abs}.manifest.json"
  fi
  local manifest_rel
  manifest_rel="$(bundle_to_rel_path "$manifest_abs")"

  local package_abs=""
  if [[ "$out_abs" == *.* ]]; then
    package_abs="${out_abs%.*}.tar"
  else
    package_abs="${out_abs}.tar"
  fi
  local package_rel
  package_rel="$(bundle_to_rel_path "$package_abs")"

  if (( assembly_applied )) && [[ "$ASSEMBLY_RUNTIME_POINTER_EMIT_MODE" == "emit_when_applied" ]]; then
    assembly_pointer_emitted=1
    assembly_pointer_rel="$(bundle_runtime_pointer_rel_for_artifact "$out_rel" "$ASSEMBLY_RUNTIME_POINTER_SUFFIX" "$ASSEMBLY_RUNTIME_POINTER_FORMAT")"
    assembly_pointer_abs="${REPO_ROOT}/${assembly_pointer_rel}"
  fi

  local compatibility_legacy_emitted=0
  local compatibility_legacy_out_rel=""
  local compatibility_legacy_manifest_rel=""
  local compatibility_legacy_package_rel=""
  if [[ "$out_token" == "auto" && "$BUNDLE_COMPAT_EMIT_LEGACY" == "true" ]]; then
    local legacy_suffix=""
    if [[ -n "$project_name" ]]; then
      legacy_suffix="-${project_name}"
    fi
    compatibility_legacy_out_rel="storage/handoff/${BUNDLE_COMPAT_LEGACY_PREFIX}-${resolved_profile}${legacy_suffix}-${branch_safe}-${head_short}.txt"
    compatibility_legacy_manifest_rel="${compatibility_legacy_out_rel%.*}.manifest.json"
    compatibility_legacy_package_rel="${compatibility_legacy_out_rel%.*}.tar"
    if [[ "$compatibility_legacy_out_rel" != "$out_rel" ]]; then
      compatibility_legacy_emitted=1
    fi
  fi

  mkdir -p "$(dirname "$out_abs")"
  mkdir -p "${REPO_ROOT}/storage/dumps"

  local open_intent=""
  if [[ -n "$intent_token" ]]; then
    open_intent="$intent_token"
  elif [[ "$requested_profile" == "auto" ]]; then
    open_intent="Bundle profile (auto -> ${resolved_profile})"
  elif [[ "$requested_profile_input" == "architect" ]]; then
    if (( request_slice_validated )); then
      open_intent="Architect profile: ${request_slice_id}"
    else
      open_intent="Architect profile: ad hoc"
    fi
  else
    open_intent="Bundle profile: ${resolved_profile}"
  fi

  local addendum_required=0
  local decision_id=""
  local decision_leaf_present=0
  if [[ "$resolved_profile" == "$BUNDLE_FOREMAN_PROFILE" ]]; then
    addendum_required=1
    if ! bundle_parse_foreman_intent "$open_intent"; then
      die "${BUNDLE_FOREMAN_PROFILE} intent must match: ${BUNDLE_FOREMAN_INTENT_FORM}"
    fi
    decision_id="$BUNDLE_FOREMAN_DECISION_ID"
  fi

  local dump_scope
  dump_scope="$(bundle_dump_scope_for_profile "$resolved_profile")"
  local dump_persistence_profile="$resolved_profile"
  local dump_payload_target_rel
  dump_payload_target_rel="$(bundle_resolve_dump_output_path "$out_token" "$out_rel" "$dump_scope" "$branch_safe" "$head_short" "$resolved_profile")"
  local -a dump_args=("${REPO_ROOT}/ops/bin/dump" "--scope=${dump_scope}" "--persistence-profile=${dump_persistence_profile}" "--format=chatgpt" "--out=${dump_payload_target_rel}")

  local profile_disposable_output=""
  profile_disposable_output="$(bundle_collect_profile_disposable_inputs "$resolved_profile" "$topic_rel" "$plan_rel")"
  if [[ -n "$profile_disposable_output" ]]; then
    mapfile -t profile_disposable_files < <(printf '%s\n' "$profile_disposable_output")
  fi
  local -a profile_dump_explicit_files=()
  if [[ "$resolved_profile" == "audit" ]]; then
    local audit_packet_source_rel=""
    audit_packet_source_rel="$(bundle_resolve_audit_packet_source_rel "$(bundle_resolve_audit_packet_id)")"
    mapfile -t profile_dump_explicit_files < <(bundle_collect_audit_dump_explicit_inputs "$audit_packet_source_rel")
  fi
  local disposable_rel=""
  for disposable_rel in "${profile_disposable_files[@]}"; do
    [[ -n "$disposable_rel" ]] || continue
    dump_args+=("--include-file=${disposable_rel}")
  done
  for disposable_rel in "${profile_dump_explicit_files[@]}"; do
    [[ -n "$disposable_rel" ]] || continue
    dump_args+=("--include-file=${disposable_rel}")
  done

  local dump_output
  if [[ "$dump_scope" == "project" ]]; then
    dump_args+=("--project=${project_name}")
    dump_output="$("${dump_args[@]}")"
  else
    dump_output="$("${dump_args[@]}")"
  fi

  local dump_payload_rel
  local dump_manifest_rel
  dump_payload_rel="$(printf '%s\n' "$dump_output" | sed -n 's/^Dump payload: //p' | tail -n 1)"
  dump_manifest_rel="$(printf '%s\n' "$dump_output" | sed -n 's/^Dump manifest: //p' | tail -n 1)"
  [[ -n "$dump_payload_rel" ]] || die "failed to resolve dump payload path from ops/bin/dump output"
  [[ -n "$dump_manifest_rel" ]] || die "failed to resolve dump manifest path from ops/bin/dump output"
  dump_payload_rel="$(bundle_to_rel_path "$dump_payload_rel")"
  dump_manifest_rel="$(bundle_to_rel_path "$dump_manifest_rel")"

  [[ -f "${REPO_ROOT}/${dump_payload_rel}" ]] || die "dump payload missing: ${dump_payload_rel}"
  [[ -f "${REPO_ROOT}/${dump_manifest_rel}" ]] || die "dump manifest missing: ${dump_manifest_rel}"

  if [[ "$resolved_profile" == "$BUNDLE_FOREMAN_PROFILE" ]]; then
    if grep -Fq "$decision_id" "${REPO_ROOT}/${dump_payload_rel}"; then
      decision_leaf_present=1
    else
      die "${BUNDLE_FOREMAN_PROFILE} decision leaf not present in dump payload: ${decision_id}"
    fi
  fi

  if [[ "$resolved_profile" == "analyst" ]] && [[ -f "${REPO_ROOT}/storage/handoff/PLAN.md" ]]; then
    mkdir -p "${REPO_ROOT}/var/tmp"
    cp "${REPO_ROOT}/storage/handoff/PLAN.md" "${REPO_ROOT}/var/tmp/PLAN.md.prev"
  fi

  {
    echo "===== STELA BUNDLE ====="
    echo "Generated at: ${generated_at}"
    echo "Requested profile: ${requested_profile_input}"
    echo "Resolved profile: ${resolved_profile}"
    echo "Route reason: ${route_reason}"
    if (( alias_applied )); then
      echo "Profile alias: ${alias_profile_source} -> ${alias_profile_target}"
    fi
    if [[ -n "$project_name" ]]; then
      echo "Project: ${project_name}"
    fi
    echo
    echo "[OPEN]"
    echo "- Embedded: true"
    echo "- Active branch: ${branch}"
    echo "- HEAD short hash: ${head_short}"
    echo "- STELA_TRACE_ID: ${trace_id}"
    echo "- Intent for today: ${open_intent}"
    echo
    echo "[SUBMISSION]"
    echo "- kind: ${BUNDLE_SUBMISSION_KIND}"
    echo "- resubmission_index: ${BUNDLE_RESUBMISSION_INDEX}"
    if [[ -n "$BUNDLE_SUPERSEDES_BUNDLE_REL" ]]; then
      echo "- supersedes: ${BUNDLE_SUPERSEDES_BUNDLE_REL}"
    else
      echo "- supersedes: (none)"
    fi
    if [[ -n "$BUNDLE_REFRESH_REASON" ]]; then
      echo "- refresh_reason: ${BUNDLE_REFRESH_REASON}"
    else
      echo "- refresh_reason: (none)"
    fi
    echo
    echo "[DUMP]"
    echo "- Scope: ${dump_scope}"
    echo "- Persistence profile: ${dump_persistence_profile}"
    echo "- Payload path: ${dump_payload_rel}"
    echo "- Manifest path: ${dump_manifest_rel}"
    echo
    echo "[STANCE]"
    echo "- Contract source: ops/src/stances/*.md.tpl"
    echo "- Stance template key: ${stance_template_key}"
    echo
    echo "[ASSEMBLY]"
    echo "- Applied: $([[ "$assembly_applied" == "1" ]] && echo true || echo false)"
    echo "- Schema version: ${ASSEMBLY_SCHEMA_VERSION}"
    if (( assembly_applied )); then
      echo "- agent_id: ${assembly_agent_id}"
      echo "- skill_id: ${assembly_skill_id}"
      echo "- task_id: ${assembly_task_id}"
      echo "- validated against: ${ASSEMBLY_REGISTRY_AGENTS_PATH}, ${ASSEMBLY_REGISTRY_SKILLS_PATH}, ${ASSEMBLY_REGISTRY_TASKS_PATH}"
      if (( assembly_pointer_emitted )); then
        echo "- pointer path: ${assembly_pointer_rel}"
      fi
    fi
    echo "- advisory mode: ${ASSEMBLY_ADVISORY_MODE}"
    echo "- advisory input stela present: $([[ "$assembly_stela_present" == "1" ]] && echo true || echo false)"
    echo "- advisory input scaffold present: $([[ "$assembly_scaffold_present" == "1" ]] && echo true || echo false)"
    echo
    if [[ "$resolved_profile" == "architect" ]]; then
      echo "[REQUEST]"
    if [[ -n "$request_slice_id" ]]; then
      echo "- slice_id: ${request_slice_id}"
    else
      echo "- slice_id: (ad hoc)"
    fi
    echo "- slice_validated: $(bundle_bool "$request_slice_validated")"
    if [[ -n "$request_plan_source" ]]; then
      echo "- plan_source: ${request_plan_source}"
    else
      echo "- plan_source: (none)"
    fi
    if [[ -n "$request_packet_id" ]]; then
      echo "- packet_id: ${request_packet_id}"
      echo "- dp_draft_path: storage/dp/intake/${request_packet_id}.md"
    else
      echo "- packet_id: (none)"
      echo "- dp_draft_path: (none)"
    fi
    if [[ -n "$request_closing_sidecar" ]]; then
      echo "- closing_sidecar: ${request_closing_sidecar}"
    else
      echo "- closing_sidecar: (none)"
    fi
    if [[ -n "$request_title_suffix" ]]; then
      echo "- title_suffix: ${request_title_suffix}"
    else
      echo "- title_suffix: (none)"
    fi
    echo
    if (( request_slice_validated )); then
      bundle_emit_architect_slice_projection "${REPO_ROOT}/${plan_rel}" "$request_slice_id" "$request_packet_id" "$request_closing_sidecar" "$request_title_suffix"
    fi
    echo
  elif [[ "$resolved_profile" == "analyst" ]]; then
      echo "[REQUEST]"
      echo "- topic_source: ${topic_rel}"
      echo "- output_surface: ${plan_rel}"
      echo
  fi
    if ! bundle_profile_handoff_omitted "$resolved_profile" && { (( ${#profile_disposable_files[@]} > 0 )) || [[ "$requested_profile" == "auto" && "$resolved_profile" != "analyst" ]]; }; then
      echo "[HANDOFF]"
      for disposable_rel in "${profile_disposable_files[@]}"; do
        echo "- ${disposable_rel}: present"
      done
      if [[ "$requested_profile" == "auto" && "$resolved_profile" != "analyst" ]]; then
        echo "- PLAN lint status: ${plan_lint_status}"
      fi
      echo
    fi
    if [[ "$resolved_profile" == "$BUNDLE_FOREMAN_PROFILE" ]]; then
      echo "- Addendum decision id: ${decision_id}"
      echo "- Decision leaf present in dump: $([[ "$decision_leaf_present" == "1" ]] && echo true || echo false)"
      echo
    fi
    if [[ "$requested_profile" == "auto" && "$resolved_profile" != "analyst" ]]; then
      echo "[PLAN LINT OUTPUT]"
      printf '%s\n' "$plan_lint_output"
      echo
    fi
    echo "===== STANCE CONTRACT BEGIN ====="
    bundle_emit_stance_contract "$rendered_stance_tmp"
    echo "===== STANCE CONTRACT END ====="
    echo "===== END STELA BUNDLE ====="
  } > "$out_abs"

  rm -f "$rendered_stance_tmp"

  if (( assembly_pointer_emitted )); then
    {
      echo "{"
      echo "  \"pointer_version\": \"1\","
      echo "  \"generated_at\": \"$(bundle_json_escape "$generated_at")\","
      echo "  \"schema_version\": \"$(bundle_json_escape "$ASSEMBLY_SCHEMA_VERSION")\","
      echo "  \"agent_id\": \"$(bundle_json_escape "$assembly_agent_id")\","
      echo "  \"skill_id\": \"$(bundle_json_escape "$assembly_skill_id")\","
      echo "  \"task_id\": \"$(bundle_json_escape "$assembly_task_id")\","
      echo "  \"validated_against\": {"
      echo "    \"agents\": \"$(bundle_json_escape "$ASSEMBLY_REGISTRY_AGENTS_PATH")\","
      echo "    \"skills\": \"$(bundle_json_escape "$ASSEMBLY_REGISTRY_SKILLS_PATH")\","
      echo "    \"tasks\": \"$(bundle_json_escape "$ASSEMBLY_REGISTRY_TASKS_PATH")\""
      echo "  },"
      echo "  \"advisory_inputs\": {"
      echo "    \"mode\": \"$(bundle_json_escape "$ASSEMBLY_ADVISORY_MODE")\","
      echo "    \"minimum_clean_cycles\": \"$(bundle_json_escape "$ASSEMBLY_ADVISORY_MINIMUM_CLEAN_CYCLES")\","
      echo "    \"stela\": {"
      echo "      \"path\": \"$(bundle_json_escape "$ASSEMBLY_ADVISORY_STELA_PATH")\","
      echo "      \"present\": $(bundle_bool "$assembly_stela_present")"
      echo "    },"
      echo "    \"scaffold\": {"
      echo "      \"path\": \"$(bundle_json_escape "$ASSEMBLY_ADVISORY_SCAFFOLD_PATH")\","
      echo "      \"present\": $(bundle_bool "$assembly_scaffold_present")"
      echo "    }"
      echo "  }"
      echo "}"
    } > "$assembly_pointer_abs"
  fi

  local -a package_files=(
    "$out_rel"
    "$manifest_rel"
    "$dump_payload_rel"
    "$dump_manifest_rel"
  )
  if (( assembly_pointer_emitted )); then
    package_files+=("$assembly_pointer_rel")
  fi
  for disposable_rel in "${profile_disposable_files[@]}"; do
    [[ -n "$disposable_rel" ]] || continue
    package_files+=("$disposable_rel")
  done

  {
    echo "{"
    echo "  \"bundle_version\": \"2\"," 
    echo "  \"generated_at\": \"$(bundle_json_escape "$generated_at")\"," 
    echo "  \"requested_profile\": \"$(bundle_json_escape "$requested_profile_input")\"," 
    echo "  \"resolved_profile\": \"$(bundle_json_escape "$resolved_profile")\"," 
    echo "  \"route_reason\": \"$(bundle_json_escape "$route_reason")\"," 
    echo "  \"profile_alias\": {"
    echo "    \"applied\": $(bundle_bool "$alias_applied"),"
    if (( alias_applied )); then
      echo "    \"from\": \"$(bundle_json_escape "$alias_profile_source")\","
      echo "    \"to\": \"$(bundle_json_escape "$alias_profile_target")\","
      echo "    \"deprecation_status\": \"$(bundle_json_escape "$alias_deprecation_status")\","
      echo "    \"remove_after_dp\": \"$(bundle_json_escape "$alias_remove_after_dp")\""
    else
      echo "    \"from\": null,"
      echo "    \"to\": null,"
      echo "    \"deprecation_status\": null,"
      echo "    \"remove_after_dp\": null"
    fi
    echo "  },"
    if [[ -n "$project_name" ]]; then
      echo "  \"project\": \"$(bundle_json_escape "$project_name")\"," 
    else
      echo "  \"project\": null," 
    fi
    echo "  \"bundle_path\": \"$(bundle_json_escape "$out_rel")\"," 
    echo "  \"submission\": {"
    echo "    \"kind\": \"$(bundle_json_escape "$BUNDLE_SUBMISSION_KIND")\","
    echo "    \"resubmission_index\": ${BUNDLE_RESUBMISSION_INDEX},"
    if [[ -n "$BUNDLE_SUPERSEDES_BUNDLE_REL" ]]; then
      echo "    \"supersedes_bundle_path\": \"$(bundle_json_escape "$BUNDLE_SUPERSEDES_BUNDLE_REL")\","
    else
      echo "    \"supersedes_bundle_path\": null,"
    fi
    if [[ -n "$BUNDLE_REFRESH_REASON" ]]; then
      echo "    \"refresh_reason\": \"$(bundle_json_escape "$BUNDLE_REFRESH_REASON")\""
    else
      echo "    \"refresh_reason\": null"
    fi
    echo "  },"
    echo "  \"artifact_naming\": {"
    echo "    \"canonical_prefix\": \"$(bundle_json_escape "$artifact_prefix")\","
    echo "    \"canonical_bundle_path\": \"$(bundle_json_escape "$out_rel")\","
    echo "    \"canonical_manifest_path\": \"$(bundle_json_escape "$manifest_rel")\","
    echo "    \"canonical_package_path\": \"$(bundle_json_escape "$package_rel")\","
    echo "    \"legacy_prefix\": \"$(bundle_json_escape "$BUNDLE_COMPAT_LEGACY_PREFIX")\","
    if (( compatibility_legacy_emitted )); then
      echo "    \"legacy_bundle_path\": \"$(bundle_json_escape "$compatibility_legacy_out_rel")\","
      echo "    \"legacy_manifest_path\": \"$(bundle_json_escape "$compatibility_legacy_manifest_rel")\","
      echo "    \"legacy_package_path\": \"$(bundle_json_escape "$compatibility_legacy_package_rel")\","
    else
      echo "    \"legacy_bundle_path\": null,"
      echo "    \"legacy_manifest_path\": null,"
      echo "    \"legacy_package_path\": null,"
    fi
    echo "    \"legacy_emitted\": $(bundle_bool "$compatibility_legacy_emitted")"
    echo "  },"
    echo "  \"open\": {"
    echo "    \"embedded\": true,"
    echo "    \"branch\": \"$(bundle_json_escape "$branch")\"," 
    echo "    \"head_short\": \"$(bundle_json_escape "$head_short")\"," 
    echo "    \"trace_id\": \"$(bundle_json_escape "$trace_id")\"," 
    echo "    \"intent\": \"$(bundle_json_escape "$open_intent")\""
    echo "  },"
    echo "  \"dump\": {"
    echo "    \"scope\": \"$(bundle_json_escape "$dump_scope")\"," 
    echo "    \"persistence_profile\": \"$(bundle_json_escape "$dump_persistence_profile")\"," 
    echo "    \"payload_path\": \"$(bundle_json_escape "$dump_payload_rel")\"," 
    echo "    \"manifest_path\": \"$(bundle_json_escape "$dump_manifest_rel")\""
    echo "  },"
    echo "  \"stance\": {"
    echo "    \"stance_template_key\": \"$(bundle_json_escape "$stance_template_key")\""
    echo "  },"
    echo "  \"assembly\": {"
    echo "    \"applied\": $(bundle_bool "$assembly_applied"),"
    echo "    \"schema_version\": \"$(bundle_json_escape "$ASSEMBLY_SCHEMA_VERSION")\","
    echo "    \"policy_manifest\": \"$(bundle_json_escape "$BUNDLE_ASSEMBLY_POLICY_MANIFEST")\","
    if (( assembly_applied )); then
      echo "    \"agent_id\": \"$(bundle_json_escape "$assembly_agent_id")\","
      echo "    \"skill_id\": \"$(bundle_json_escape "$assembly_skill_id")\","
      echo "    \"task_id\": \"$(bundle_json_escape "$assembly_task_id")\","
    else
      echo "    \"agent_id\": null,"
      echo "    \"skill_id\": null,"
      echo "    \"task_id\": null,"
    fi
    echo "    \"validated_against\": {"
    echo "      \"agents\": \"$(bundle_json_escape "$ASSEMBLY_REGISTRY_AGENTS_PATH")\","
    echo "      \"skills\": \"$(bundle_json_escape "$ASSEMBLY_REGISTRY_SKILLS_PATH")\","
    echo "      \"tasks\": \"$(bundle_json_escape "$ASSEMBLY_REGISTRY_TASKS_PATH")\""
    echo "    },"
    echo "    \"pointer\": {"
    echo "      \"emitted\": $(bundle_bool "$assembly_pointer_emitted"),"
    if (( assembly_pointer_emitted )); then
      echo "      \"path\": \"$(bundle_json_escape "$assembly_pointer_rel")\","
    else
      echo "      \"path\": null,"
    fi
    echo "      \"format\": \"$(bundle_json_escape "$ASSEMBLY_RUNTIME_POINTER_FORMAT")\""
    echo "    },"
    echo "    \"advisory_inputs\": {"
    echo "      \"mode\": \"$(bundle_json_escape "$ASSEMBLY_ADVISORY_MODE")\","
    echo "      \"minimum_clean_cycles\": \"$(bundle_json_escape "$ASSEMBLY_ADVISORY_MINIMUM_CLEAN_CYCLES")\","
    echo "      \"stela\": {"
    echo "        \"path\": \"$(bundle_json_escape "$ASSEMBLY_ADVISORY_STELA_PATH")\","
    echo "        \"present\": $(bundle_bool "$assembly_stela_present")"
    echo "      },"
    echo "      \"scaffold\": {"
    echo "        \"path\": \"$(bundle_json_escape "$ASSEMBLY_ADVISORY_SCAFFOLD_PATH")\","
    echo "        \"present\": $(bundle_bool "$assembly_scaffold_present")"
    echo "      }"
    echo "    }"
    echo "  },"
    echo "  \"topic\": {"
    echo "    \"path\": \"$(bundle_json_escape "$topic_rel")\"," 
    echo "    \"present\": $(bundle_bool "$topic_present")"
    echo "  },"
    if [[ "$resolved_profile" != "analyst" ]]; then
      echo "  \"plan\": {"
      echo "    \"path\": \"$(bundle_json_escape "$plan_rel")\"," 
      echo "    \"present\": $(bundle_bool "$plan_present"),"
      echo "    \"lint_status\": \"$(bundle_json_escape "$plan_lint_status")\""
      echo "  },"
    fi
    echo "  \"request\": {"
    if [[ "$resolved_profile" == "architect" && -n "$request_slice_id" ]]; then
      echo "    \"slice_id\": \"$(bundle_json_escape "$request_slice_id")\"," 
      echo "    \"slice_validated\": true,"
      echo "    \"plan_source\": \"$(bundle_json_escape "$request_plan_source")\","
      echo "    \"packet_id\": \"$(bundle_json_escape "$request_packet_id")\","
      echo "    \"dp_draft_path\": \"storage/dp/intake/$(bundle_json_escape "$request_packet_id").md\","
      echo "    \"closing_sidecar\": \"$(bundle_json_escape "$request_closing_sidecar")\","
      if [[ -n "$request_title_suffix" ]]; then
        echo "    \"title_suffix\": \"$(bundle_json_escape "$request_title_suffix")\","
      else
        echo "    \"title_suffix\": null,"
      fi
      echo "    \"topic_source\": null,"
      echo "    \"output_surface\": null"
    elif [[ "$resolved_profile" == "analyst" ]]; then
      echo "    \"slice_id\": null,"
      echo "    \"slice_validated\": false,"
      echo "    \"plan_source\": null,"
      echo "    \"packet_id\": null,"
      echo "    \"dp_draft_path\": null,"
      echo "    \"closing_sidecar\": null,"
      echo "    \"title_suffix\": null,"
      echo "    \"topic_source\": \"$(bundle_json_escape "$topic_rel")\","
      echo "    \"output_surface\": \"$(bundle_json_escape "$plan_rel")\""
    else
      echo "    \"slice_id\": null,"
      echo "    \"slice_validated\": false,"
      echo "    \"plan_source\": null,"
      echo "    \"packet_id\": null,"
      echo "    \"dp_draft_path\": null,"
      echo "    \"closing_sidecar\": null,"
      echo "    \"title_suffix\": null,"
      echo "    \"topic_source\": null,"
      echo "    \"output_surface\": null"
    fi
    echo "  },"
    echo "  \"addendum\": {"
    echo "    \"required\": $(bundle_bool "$addendum_required"),"
    if [[ -n "$decision_id" ]]; then
      echo "    \"decision_id\": \"$(bundle_json_escape "$decision_id")\"," 
    else
      echo "    \"decision_id\": null," 
    fi
    echo "    \"decision_leaf_present\": $(bundle_bool "$decision_leaf_present")"
    echo "  },"
    echo "  \"package\": {"
    echo "    \"path\": \"$(bundle_json_escape "$package_rel")\"," 
    echo "    \"files\": ["
    local i
    for (( i=0; i<${#package_files[@]}; i++ )); do
      local comma=""
      if (( i + 1 < ${#package_files[@]} )); then
        comma=","
      fi
      echo "      \"$(bundle_json_escape "${package_files[$i]}")\"${comma}"
    done
    echo "    ]"
    echo "  }"
    echo "}"
  } > "$manifest_abs"

  tar -cf "$package_abs" -C "$REPO_ROOT" "${package_files[@]}"

  if (( compatibility_legacy_emitted )); then
    cp "$out_abs" "${REPO_ROOT}/${compatibility_legacy_out_rel}"
    cp "$manifest_abs" "${REPO_ROOT}/${compatibility_legacy_manifest_rel}"
    cp "$package_abs" "${REPO_ROOT}/${compatibility_legacy_package_rel}"
  fi

  echo "Bundle artifact: $(bundle_display_path "$out_rel")"
  echo "Bundle manifest: $(bundle_display_path "$manifest_rel")"
  echo "Bundle package: $(bundle_display_path "$package_rel")"
  if (( compatibility_legacy_emitted )); then
    echo "Legacy bundle artifact: $(bundle_display_path "$compatibility_legacy_out_rel")"
    echo "Legacy bundle manifest: $(bundle_display_path "$compatibility_legacy_manifest_rel")"
    echo "Legacy bundle package: $(bundle_display_path "$compatibility_legacy_package_rel")"
  fi
}
