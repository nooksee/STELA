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
declare -a BUNDLE_SUPPORTED_PROFILES=()
declare -a BUNDLE_HANDOFF_OMIT_PROFILES=()
declare -A BUNDLE_DUMP_SCOPE_BY_PROFILE=()
declare -A BUNDLE_STANCE_TEMPLATE_BY_PROFILE=()
declare -A BUNDLE_PROFILE_ALIAS_BY_INPUT=()
declare -A BUNDLE_PROFILE_ALIAS_DEPRECATION_STATUS_BY_INPUT=()
declare -A BUNDLE_PROFILE_ALIAS_REMOVE_AFTER_DP_BY_INPUT=()

BUNDLE_AUTO_DEFAULT_PROFILE=""
BUNDLE_AUTO_PLAN_PROFILE=""
BUNDLE_PROJECT_PROFILE=""
BUNDLE_AUDIT_PROFILE=""
BUNDLE_FOREMAN_PROFILE=""
BUNDLE_FOREMAN_INTENT_FORM=""

bundle_usage() {
  cat <<'USAGE'
Usage: ops/bin/bundle [--profile=auto|analyst|architect|audit|project|conform|hygiene|foreman|auditor] [--out=auto|PATH] [--project=<name>] [--intent=<text>]
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
  local dump_scope
  local stance_key
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
  if [[ -z "$BUNDLE_FOREMAN_PROFILE" ]]; then
    BUNDLE_FOREMAN_PROFILE="$(bundle_policy_scalar auditor_profile)"
  fi
  BUNDLE_FOREMAN_INTENT_FORM="$(bundle_policy_scalar foreman_intent_form)"
  if [[ -z "$BUNDLE_FOREMAN_INTENT_FORM" ]]; then
    BUNDLE_FOREMAN_INTENT_FORM="$(bundle_policy_scalar auditor_intent_form)"
  fi
  [[ -n "$BUNDLE_FOREMAN_PROFILE" ]] || die "bundle policy missing required key: foreman_profile"
  [[ -n "$BUNDLE_FOREMAN_INTENT_FORM" ]] || die "bundle policy missing required key: foreman_intent_form"

  for profile in \
    "$BUNDLE_AUTO_DEFAULT_PROFILE" \
    "$BUNDLE_AUTO_PLAN_PROFILE" \
    "$BUNDLE_PROJECT_PROFILE" \
    "$BUNDLE_AUDIT_PROFILE" \
    "$BUNDLE_FOREMAN_PROFILE"; do
    bundle_profile_supported "$profile" || die "bundle policy references unsupported profile: ${profile}"
  done

  BUNDLE_PROFILE_ALIAS_BY_INPUT=()
  BUNDLE_PROFILE_ALIAS_BY_INPUT["auditor"]="$(bundle_policy_scalar profile_alias_legacy_auditor_to)"
  BUNDLE_PROFILE_ALIAS_BY_INPUT["hygiene"]="$(bundle_policy_scalar profile_alias_legacy_hygiene_to)"
  if [[ -z "${BUNDLE_PROFILE_ALIAS_BY_INPUT[auditor]}" ]]; then
    BUNDLE_PROFILE_ALIAS_BY_INPUT["auditor"]="$(bundle_policy_scalar profile_alias_auditor)"
  fi
  if [[ -z "${BUNDLE_PROFILE_ALIAS_BY_INPUT[hygiene]}" ]]; then
    BUNDLE_PROFILE_ALIAS_BY_INPUT["hygiene"]="$(bundle_policy_scalar profile_alias_hygiene)"
  fi
  [[ -n "${BUNDLE_PROFILE_ALIAS_BY_INPUT[auditor]}" ]] || die "bundle policy missing required key: profile_alias_legacy_auditor_to (or legacy profile_alias_auditor)"
  [[ -n "${BUNDLE_PROFILE_ALIAS_BY_INPUT[hygiene]}" ]] || die "bundle policy missing required key: profile_alias_legacy_hygiene_to (or legacy profile_alias_hygiene)"
  for profile in "${BUNDLE_PROFILE_ALIAS_BY_INPUT[@]}"; do
    bundle_profile_supported "$profile" || die "bundle policy alias target is unsupported: ${profile}"
  done

  BUNDLE_PROFILE_ALIAS_DEPRECATION_STATUS_BY_INPUT=()
  BUNDLE_PROFILE_ALIAS_REMOVE_AFTER_DP_BY_INPUT=()
  for alias_name in auditor hygiene; do
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
  for profile in "${BUNDLE_SUPPORTED_PROFILES[@]}"; do
    scope_key="dump_scope_${profile}"
    stance_key_name="stance_template_${profile}"
    dump_scope="$(bundle_policy_scalar "$scope_key")"
    stance_key="$(bundle_policy_scalar "$stance_key_name")"
    [[ -n "$dump_scope" ]] || die "bundle policy missing required key: ${scope_key}"
    [[ -n "$stance_key" ]] || die "bundle policy missing required key: ${stance_key_name}"
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
    BUNDLE_DUMP_SCOPE_BY_PROFILE["$profile"]="$dump_scope"
    BUNDLE_STANCE_TEMPLATE_BY_PROFILE["$profile"]="$stance_key"
  done

  omit_csv="$(bundle_policy_scalar handoff_omit_profiles)"
  BUNDLE_HANDOFF_OMIT_PROFILES=()
  mapfile -t BUNDLE_HANDOFF_OMIT_PROFILES < <(bundle_parse_csv_lines "$omit_csv")
  (( ${#BUNDLE_HANDOFF_OMIT_PROFILES[@]} > 0 )) || die "bundle policy handoff_omit_profiles is empty"
  for profile in "${BUNDLE_HANDOFF_OMIT_PROFILES[@]}"; do
    bundle_profile_supported "$profile" || die "bundle policy handoff_omit_profiles references unsupported profile: ${profile}"
  done

}

bundle_resolve_output_path() {
  local out_token="$1"
  local resolved_profile="$2"
  local branch_safe="$3"
  local head_short="$4"
  local project_name="$5"

  local out_rel=""
  if [[ "$out_token" == "auto" ]]; then
    local suffix=""
    if [[ -n "$project_name" ]]; then
      suffix="-${project_name}"
    fi
    out_rel="storage/handoff/BUNDLE-${resolved_profile}${suffix}-${branch_safe}-${head_short}.txt"
  else
    out_rel="$(bundle_to_rel_path "$out_token")"
  fi

  if [[ "$out_rel" != storage/handoff/* ]]; then
    die "bundle output must be under storage/handoff/: ${out_rel}"
  fi

  printf '%s' "${REPO_ROOT}/${out_rel}"
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

  local stance_template_key
  stance_template_key="$(bundle_stance_template_for_profile "$resolved_profile")"
  local rendered_stance_tmp
  rendered_stance_tmp="$(mktemp)"
  bundle_render_stance_contract_for_profile "$resolved_profile" > "$rendered_stance_tmp"

  local out_abs
  out_abs="$(bundle_resolve_output_path "$out_token" "$resolved_profile" "$branch_safe" "$head_short" "$project_name")"
  local out_rel
  out_rel="$(bundle_to_rel_path "$out_abs")"

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

  mkdir -p "$(dirname "$out_abs")"
  mkdir -p "${REPO_ROOT}/storage/dumps"

  local open_intent=""
  if [[ -n "$intent_token" ]]; then
    open_intent="$intent_token"
  elif [[ "$requested_profile" == "auto" ]]; then
    open_intent="Bundle profile (auto -> ${resolved_profile})"
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
  local dump_payload_target_rel="storage/dumps/dump-${dump_scope}-${branch_safe}-${head_short}.txt"

  local dump_output
  if [[ "$dump_scope" == "project" ]]; then
    dump_output="$(${REPO_ROOT}/ops/bin/dump --scope=project --project="$project_name" --format=chatgpt --out="$dump_payload_target_rel")"
  else
    dump_output="$(${REPO_ROOT}/ops/bin/dump --scope="$dump_scope" --format=chatgpt --out="$dump_payload_target_rel")"
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
    echo "[DUMP]"
    echo "- Scope: ${dump_scope}"
    echo "- Payload path: ${dump_payload_rel}"
    echo "- Manifest path: ${dump_manifest_rel}"
    echo
    echo "[STANCE]"
    echo "- Contract source: ops/src/stances/*.md.tpl"
    echo "- Stance template key: ${stance_template_key}"
    echo
    if ! bundle_profile_handoff_omitted "$resolved_profile"; then
      echo "[HANDOFF]"
      echo "- ${topic_rel}: $([[ "$topic_present" == "1" ]] && echo present || echo missing)"
      echo "- ${plan_rel}: $([[ "$plan_present" == "1" ]] && echo present || echo missing)"
      if [[ "$requested_profile" == "auto" ]]; then
        echo "- PLAN lint status: ${plan_lint_status}"
      fi
      echo
    fi
    if [[ "$resolved_profile" == "$BUNDLE_FOREMAN_PROFILE" ]]; then
      echo "- Addendum decision id: ${decision_id}"
      echo "- Decision leaf present in dump: $([[ "$decision_leaf_present" == "1" ]] && echo true || echo false)"
      echo
    fi
    if [[ "$requested_profile" == "auto" ]]; then
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

  local -a package_files=(
    "$out_rel"
    "$manifest_rel"
    "$dump_payload_rel"
    "$dump_manifest_rel"
  )
  if (( topic_present )); then
    package_files+=("$topic_rel")
  fi
  if (( plan_present )); then
    package_files+=("$plan_rel")
  fi

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
    echo "  \"open\": {"
    echo "    \"embedded\": true,"
    echo "    \"branch\": \"$(bundle_json_escape "$branch")\"," 
    echo "    \"head_short\": \"$(bundle_json_escape "$head_short")\"," 
    echo "    \"trace_id\": \"$(bundle_json_escape "$trace_id")\"," 
    echo "    \"intent\": \"$(bundle_json_escape "$open_intent")\""
    echo "  },"
    echo "  \"dump\": {"
    echo "    \"scope\": \"$(bundle_json_escape "$dump_scope")\"," 
    echo "    \"payload_path\": \"$(bundle_json_escape "$dump_payload_rel")\"," 
    echo "    \"manifest_path\": \"$(bundle_json_escape "$dump_manifest_rel")\""
    echo "  },"
    echo "  \"stance\": {"
    echo "    \"stance_template_key\": \"$(bundle_json_escape "$stance_template_key")\""
    echo "  },"
    echo "  \"topic\": {"
    echo "    \"path\": \"$(bundle_json_escape "$topic_rel")\"," 
    echo "    \"present\": $(bundle_bool "$topic_present")"
    echo "  },"
    echo "  \"plan\": {"
    echo "    \"path\": \"$(bundle_json_escape "$plan_rel")\"," 
    echo "    \"present\": $(bundle_bool "$plan_present"),"
    echo "    \"lint_status\": \"$(bundle_json_escape "$plan_lint_status")\""
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

  echo "Bundle artifact: $(bundle_display_path "$out_rel")"
  echo "Bundle manifest: $(bundle_display_path "$manifest_rel")"
  echo "Bundle package: $(bundle_display_path "$package_rel")"
}
