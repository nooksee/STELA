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

bundle_usage() {
  cat <<'USAGE'
Usage: ops/bin/bundle [--profile=auto|analyst|architect|audit|project] [--out=auto|PATH] [--project=<name>]
USAGE
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

bundle_prompt_path_for_profile() {
  local profile="$1"
  case "$profile" in
    analyst)
      printf 'docs/ops/prompts/e-prompt-04.md'
      ;;
    architect)
      printf 'docs/ops/prompts/e-prompt-03.md'
      ;;
    audit)
      printf 'docs/ops/prompts/e-prompt-01.md'
      ;;
    project)
      # Project routing uses Analyst stance plus project-scoped dump capture.
      printf 'docs/ops/prompts/e-prompt-04.md'
      ;;
    *)
      die "unsupported resolved profile: ${profile}"
      ;;
  esac
}

bundle_extract_open_meta() {
  local open_abs="$1"
  local key="$2"

  case "$key" in
    branch)
      grep -m1 '^- Active branch:' "$open_abs" | sed -E 's/^- Active branch:[[:space:]]*//' || true
      ;;
    head)
      grep -m1 '^- HEAD short hash:' "$open_abs" | sed -E 's/^- HEAD short hash:[[:space:]]*//' || true
      ;;
    trace)
      grep -m1 '^- STELA_TRACE_ID:' "$open_abs" | sed -E 's/^- STELA_TRACE_ID:[[:space:]]*//' || true
      ;;
    *)
      printf ''
      ;;
  esac
}

bundle_run() {
  local requested_profile="auto"
  local out_token="auto"
  local project_name=""

  local arg
  for arg in "$@"; do
    case "$arg" in
      --profile=auto|--profile=analyst|--profile=architect|--profile=audit|--profile=project)
        requested_profile="${arg#--profile=}"
        ;;
      --out=*)
        out_token="${arg#--out=}"
        [[ -n "$out_token" ]] || die "--out requires a value"
        ;;
      --project=*)
        project_name="${arg#--project=}"
        [[ -n "$project_name" ]] || die "--project requires a value"
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

  if [[ "$requested_profile" == "project" && -z "$project_name" ]]; then
    die "--project is required when --profile=project"
  fi
  if [[ "$requested_profile" != "project" && -n "$project_name" ]]; then
    die "--project is only valid with --profile=project"
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
        resolved_profile="architect"
        route_reason="auto: PLAN.md present and plan lint passed"
        plan_lint_status="PASS"
      else
        resolved_profile="analyst"
        route_reason="auto: PLAN.md present but plan lint failed"
        plan_lint_status="FAIL"
      fi
    else
      resolved_profile="analyst"
      route_reason="auto: PLAN.md missing"
      plan_lint_status="SKIPPED_MISSING"
      plan_lint_output="(missing storage/handoff/PLAN.md)"
    fi
  fi

  local prompt_rel
  prompt_rel="$(bundle_prompt_path_for_profile "$resolved_profile")"
  local prompt_abs="${REPO_ROOT}/${prompt_rel}"
  [[ -f "$prompt_abs" ]] || die "prompt file missing: ${prompt_rel}"

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

  mkdir -p "$(dirname "$out_abs")"

  local open_tag="bundle-${resolved_profile}"
  if [[ -n "$project_name" ]]; then
    open_tag="bundle-${resolved_profile}-${project_name}"
  fi

  local open_intent="Bundle profile: ${resolved_profile}"
  if [[ "$requested_profile" == "auto" ]]; then
    open_intent="Bundle profile (auto -> ${resolved_profile})"
  fi

  local open_output
  open_output="$("${REPO_ROOT}/ops/bin/open" --intent="$open_intent" --tag="$open_tag" --out=auto)"
  local open_rel
  open_rel="$(printf '%s\n' "$open_output" | sed -n 's/^OPEN saved: //p' | tail -n 1)"
  [[ -n "$open_rel" ]] || die "failed to resolve OPEN artifact path from ops/bin/open output"
  open_rel="$(bundle_to_rel_path "$open_rel")"
  local open_abs="${REPO_ROOT}/${open_rel}"
  [[ -f "$open_abs" ]] || die "OPEN artifact missing: ${open_rel}"

  local dump_output
  local dump_scope="core"
  case "$resolved_profile" in
    project)
      dump_scope="project"
      dump_output="$("${REPO_ROOT}/ops/bin/dump" --scope=project --project="$project_name" --format=chatgpt --out=auto)"
      ;;
    analyst|architect)
      dump_scope="full"
      dump_output="$("${REPO_ROOT}/ops/bin/dump" --scope=full --format=chatgpt --out=auto)"
      ;;
    audit)
      dump_scope="core"
      dump_output="$("${REPO_ROOT}/ops/bin/dump" --scope=core --format=chatgpt --out=auto)"
      ;;
    *)
      die "unsupported resolved profile for dump scope: ${resolved_profile}"
      ;;
  esac

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

  local open_branch
  local open_head
  local open_trace_id
  open_branch="$(bundle_extract_open_meta "$open_abs" branch)"
  open_head="$(bundle_extract_open_meta "$open_abs" head)"
  open_trace_id="$(bundle_extract_open_meta "$open_abs" trace)"
  [[ -n "$open_branch" ]] || open_branch="$branch"
  [[ -n "$open_head" ]] || open_head="$head_short"
  [[ -n "$open_trace_id" ]] || open_trace_id="(missing)"

  {
    echo "===== STELA BUNDLE ====="
    echo "Generated at: ${generated_at}"
    echo "Requested profile: ${requested_profile}"
    echo "Resolved profile: ${resolved_profile}"
    echo "Route reason: ${route_reason}"
    if [[ -n "$project_name" ]]; then
      echo "Project: ${project_name}"
    fi
    echo
    echo "[OPEN]"
    echo "- Artifact path: ${open_rel}"
    echo "- Active branch: ${open_branch}"
    echo "- HEAD short hash: ${open_head}"
    echo "- STELA_TRACE_ID: ${open_trace_id}"
    echo
    echo "[DUMP]"
    echo "- Scope: ${dump_scope}"
    echo "- Payload path: ${dump_payload_rel}"
    echo "- Manifest path: ${dump_manifest_rel}"
    echo
    echo "[PROMPT]"
    echo "- Canonical prompt path: ${prompt_rel}"
    echo
    echo "[HANDOFF]"
    echo "- ${topic_rel}: $([[ "$topic_present" == "1" ]] && echo present || echo missing)"
    echo "- ${plan_rel}: $([[ "$plan_present" == "1" ]] && echo present || echo missing)"
    if [[ "$requested_profile" == "auto" ]]; then
      echo "- PLAN lint status: ${plan_lint_status}"
    fi
    echo
    if [[ "$requested_profile" == "auto" ]]; then
      echo "[PLAN LINT OUTPUT]"
      printf '%s\n' "$plan_lint_output"
      echo
    fi
    echo "===== PROMPT STANCE BEGIN ====="
    cat "$prompt_abs"
    echo "===== PROMPT STANCE END ====="
    echo "===== END STELA BUNDLE ====="
  } > "$out_abs"

  {
    echo "{"
    echo "  \"bundle_version\": \"1\"," 
    echo "  \"generated_at\": \"$(bundle_json_escape "$generated_at")\"," 
    echo "  \"requested_profile\": \"$(bundle_json_escape "$requested_profile")\"," 
    echo "  \"resolved_profile\": \"$(bundle_json_escape "$resolved_profile")\"," 
    echo "  \"route_reason\": \"$(bundle_json_escape "$route_reason")\"," 
    if [[ -n "$project_name" ]]; then
      echo "  \"project\": \"$(bundle_json_escape "$project_name")\"," 
    else
      echo "  \"project\": null," 
    fi
    echo "  \"bundle_path\": \"$(bundle_json_escape "$out_rel")\"," 
    echo "  \"open\": {"
    echo "    \"path\": \"$(bundle_json_escape "$open_rel")\"," 
    echo "    \"branch\": \"$(bundle_json_escape "$open_branch")\"," 
    echo "    \"head_short\": \"$(bundle_json_escape "$open_head")\"," 
    echo "    \"trace_id\": \"$(bundle_json_escape "$open_trace_id")\""
    echo "  },"
    echo "  \"dump\": {"
    echo "    \"scope\": \"$(bundle_json_escape "$dump_scope")\"," 
    echo "    \"payload_path\": \"$(bundle_json_escape "$dump_payload_rel")\"," 
    echo "    \"manifest_path\": \"$(bundle_json_escape "$dump_manifest_rel")\""
    echo "  },"
    echo "  \"prompt\": {"
    echo "    \"path\": \"$(bundle_json_escape "$prompt_rel")\""
    echo "  },"
    echo "  \"topic\": {"
    echo "    \"path\": \"$(bundle_json_escape "$topic_rel")\"," 
    echo "    \"present\": $(bundle_bool "$topic_present")"
    echo "  },"
    echo "  \"plan\": {"
    echo "    \"path\": \"$(bundle_json_escape "$plan_rel")\"," 
    echo "    \"present\": $(bundle_bool "$plan_present"),"
    echo "    \"lint_status\": \"$(bundle_json_escape "$plan_lint_status")\""
    echo "  }"
    echo "}"
  } > "$manifest_abs"

  echo "Bundle artifact: $(bundle_display_path "$out_rel")"
  echo "Bundle manifest: $(bundle_display_path "$manifest_rel")"
}
