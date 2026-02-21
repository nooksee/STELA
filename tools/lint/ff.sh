#!/usr/bin/env bash
set -euo pipefail
source "$(git rev-parse --show-toplevel)/ops/lib/scripts/common.sh"

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  echo "ERROR: Must be run inside a git repository." >&2
  exit 1
fi
cd "$REPO_ROOT" || exit 1
trap 'emit_binary_leaf "lint-ff" "finish"' EXIT
emit_binary_leaf "lint-ff" "start"

declare -i SCORED_COUNT=0
declare -i WARNING_COUNT=0
declare -i FAILURE_COUNT=0

normalize_yaml_value() {
  local value
  value="$(trim "$1")"
  value="${value%%#*}"
  value="$(trim "$value")"

  if [[ -z "$value" ]]; then
    printf ''
    return 0
  fi

  if [[ "${value:0:1}" == "\"" && "${value: -1}" == "\"" && ${#value} -ge 2 ]]; then
    value="${value:1:${#value}-2}"
  elif [[ "${value:0:1}" == "'" && "${value: -1}" == "'" && ${#value} -ge 2 ]]; then
    value="${value:1:${#value}-2}"
  fi

  printf '%s' "$value"
}

extract_yaml_ccd_header() {
  local file="$1"
  local first_line=""
  local line=""
  local ff_target=""
  local ff_band=""

  IFS= read -r first_line < "$file" || return 1
  [[ "$first_line" == "---" ]] || return 1

  while IFS= read -r line; do
    if [[ "$line" == "---" ]]; then
      break
    fi

    if [[ "$line" =~ ^[[:space:]]*ff_target:[[:space:]]*(.+)[[:space:]]*$ ]]; then
      ff_target="$(normalize_yaml_value "${BASH_REMATCH[1]}")"
      continue
    fi
    if [[ "$line" =~ ^[[:space:]]*ff_band:[[:space:]]*(.+)[[:space:]]*$ ]]; then
      ff_band="$(normalize_yaml_value "${BASH_REMATCH[1]}")"
      continue
    fi
  done < <(tail -n +2 "$file")

  if [[ -n "$ff_target" && -n "$ff_band" ]]; then
    printf '%s\t%s\n' "$ff_target" "$ff_band"
    return 0
  fi
  return 1
}

extract_html_ccd_header() {
  local file="$1"
  local line=""
  local line_count=0

  while IFS= read -r line; do
    line_count=$((line_count + 1))
    if (( line_count > 10 )); then
      break
    fi

    if [[ "$line" =~ ^[[:space:]]*\<\!--[[:space:]]*CCD:[[:space:]]*ff_target=\"([^\"]*)\"[[:space:]]+ff_band=\"([^\"]*)\"[[:space:]]*--\>[[:space:]]*$ ]]; then
      printf '%s\t%s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
      return 0
    fi
  done < "$file"

  return 1
}

is_wave0_exempt() {
  local file="$1"
  case "$file" in
    PoW.md|SoP.md|TASK.md|llms.txt|llms-core.txt|llms-full.txt)
      return 0
      ;;
  esac

  if [[ "$file" == archives/* ]]; then
    return 0
  fi
  if [[ "$file" == storage/* ]]; then
    return 0
  fi
  if [[ "$file" == var/tmp/* ]]; then
    return 0
  fi
  if [[ "$file" == logs/* ]]; then
    return 0
  fi
  if [[ "$file" == .github/* ]]; then
    return 0
  fi
  if [[ "$file" == opt/_factory/* ]]; then
    return 0
  fi

  return 1
}

is_auto_generated_exempt() {
  local file="$1"
  if head -n 5 "$file" | grep -Eq '<!-- AUTO-GENERATED -->|<!-- GENERATED FILE'; then
    return 0
  fi
  return 1
}

parse_band_bounds() {
  local band="$1"
  band="$(trim "$band")"
  band="${band#[}"
  band="${band%]}"
  band="${band#(}"
  band="${band%)}"

  if [[ "$band" =~ ^([0-9]+([.][0-9]+)?)[[:space:]]*-[[:space:]]*([0-9]+([.][0-9]+)?)$ ]]; then
    printf '%s\t%s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[3]}"
    return 0
  fi
  return 1
}

compute_metrics() {
  local file="$1"

  awk '
    BEGIN {
      split("a an and are as at be been being but by can could did do does for from had has have if in into is it its may might more must no not of on or our should so than that the their there these they this to was were what when which who will with would you your", words, " ")
      for (i in words) {
        stopwords[words[i]] = 1
      }
      phrases[1] = "like a"
      phrases[2] = "similar to"
      phrases[3] = "think of"
      phrases[4] = "imagine"
      phrases[5] = "analogous to"
      phrases[6] = "just as"
      phrases[7] = "the same way"
      phrases[8] = "picture a"
      phrases[9] = "consider a"
      in_code = 0
      total_words = 0
      stopword_count = 0
      prose_words = 0
      sentence_count = 0
      analogy_count = 0
    }

    {
      line = $0
      lower_line = tolower(line)

      token_line = lower_line
      gsub(/[^a-z0-9]+/, " ", token_line)
      token_count = split(token_line, tokens, /[[:space:]]+/)
      for (i = 1; i <= token_count; i++) {
        token = tokens[i]
        if (token == "") {
          continue
        }
        total_words++
        if (token in stopwords) {
          stopword_count++
        }
      }

      if (line ~ /^[[:space:]]*```/ || line ~ /^[[:space:]]*~~~/) {
        in_code = !in_code
        next
      }
      if (in_code) {
        next
      }

      prose_line = lower_line
      gsub(/[^a-z0-9]+/, " ", prose_line)
      prose_token_count = split(prose_line, prose_tokens, /[[:space:]]+/)
      for (i = 1; i <= prose_token_count; i++) {
        if (prose_tokens[i] != "") {
          prose_words++
        }
      }

      sentence_line = line
      sentence_count += gsub(/[.!?]/, "", sentence_line)

      for (p = 1; p <= 9; p++) {
        phrase = phrases[p]
        if (phrase == "") {
          continue
        }
        start = 1
        while (start <= length(lower_line)) {
          chunk = substr(lower_line, start)
          index_pos = index(chunk, phrase)
          if (index_pos == 0) {
            break
          }
          analogy_count++
          start += index_pos + length(phrase) - 1
        }
      }
    }

    function abs(value) {
      return (value < 0 ? -value : value)
    }

    END {
      if (total_words > 0) {
        sw_percent = (stopword_count * 100.0) / total_words
      } else {
        sw_percent = 0
      }

      if (sentence_count == 0 && prose_words > 0) {
        sentence_count = 1
      }
      if (sentence_count > 0) {
        asl = prose_words / sentence_count
        aad = (analogy_count * 100.0) / sentence_count
      } else {
        asl = 0
        aad = 0
      }

      # Proxy 2 normalization: best near 14 words per sentence.
      asl_proxy = 100 - (abs(asl - 14) * 5)
      if (asl_proxy < 0) {
        asl_proxy = 0
      }
      if (asl_proxy > 100) {
        asl_proxy = 100
      }

      # Proxy 3 normalization: best near 8 analogy signals per 100 sentences.
      aad_proxy = 100 - (abs(aad - 8) * 8)
      if (aad_proxy < 0) {
        aad_proxy = 0
      }
      if (aad_proxy > 100) {
        aad_proxy = 100
      }

      ff_score = (0.5 * sw_percent) + (0.3 * asl_proxy) + (0.2 * aad_proxy)
      if (ff_score < 0) {
        ff_score = 0
      }
      if (ff_score > 100) {
        ff_score = 100
      }

      ff_score_int = int(ff_score + 0.5)
      printf "%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%d\n", sw_percent, asl, aad, asl_proxy, aad_proxy, ff_score, ff_score_int
    }
  ' "$file"
}

select_primary_driver() {
  local ff_target="$1"
  local band_lower="$2"
  local band_upper="$3"
  local sw_percent="$4"
  local asl_proxy="$5"
  local aad_proxy="$6"

  local reference="$ff_target"
  if [[ ! "$reference" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    reference="$(awk -v low="$band_lower" -v high="$band_upper" 'BEGIN { printf "%.2f", (low + high) / 2.0 }')"
  fi

  awk \
    -v ref="$reference" \
    -v sw="$sw_percent" \
    -v asl="$asl_proxy" \
    -v aad="$aad_proxy" '
      function abs(value) { return (value < 0 ? -value : value) }
      BEGIN {
        sw_delta = abs(sw - ref)
        asl_delta = abs(asl - ref)
        aad_delta = abs(aad - ref)

        driver = "SW%"
        max_delta = sw_delta
        if (asl_delta > max_delta) {
          max_delta = asl_delta
          driver = "ASL"
        }
        if (aad_delta > max_delta) {
          driver = "AAD"
        }
        print driver
      }
    '
}

band_is_outside_tolerance() {
  local ff_score="$1"
  local band_lower="$2"
  local band_upper="$3"

  awk \
    -v score="$ff_score" \
    -v low="$band_lower" \
    -v high="$band_upper" '
      BEGIN {
        if (score < (low - 10) || score > (high + 10)) {
          exit 0
        }
        exit 1
      }
    '
}

is_wave1_hardened() {
  local file="$1"
  case "$file" in
    PoT.md|\
    docs/MAP.md|\
    docs/MANUAL.md|\
    ops/lib/manifests/CONTEXT.md|\
    ops/lib/manifests/CONSTRAINTS.md|\
    ops/lib/manifests/CONTRACTOR.md|\
    ops/lib/manifests/CORE.md|\
    ops/lib/manifests/OPS.md|\
    ops/lib/manifests/DISCOVERY.md|\
    README.md)
      return 0
      ;;
  esac
  return 1
}

is_wave2_hardened() {
  local file="$1"
  case "$file" in
    docs/GOVERNANCE.md|\
    docs/INDEX.md|\
    docs/CONTEXT.md|\
    docs/ops/README.md|\
    docs/ops/registry/agents.md|\
    docs/ops/registry/binaries.md|\
    docs/ops/registry/lint.md|\
    docs/ops/registry/scripts.md|\
    docs/ops/registry/tasks.md|\
    docs/ops/registry/skills.md|\
    docs/ops/registry/tools.md|\
    docs/ops/registry/projects.md|\
    docs/ops/registry/prompts.md|\
    docs/ops/registry/test.md|\
    docs/ops/prompts/README.md)
      return 0
      ;;
  esac
  return 1
}

declare -a MARKDOWN_FILES=()
mapfile -t MARKDOWN_FILES < <(git ls-files '*.md')

for file in "${MARKDOWN_FILES[@]}"; do
  if is_wave0_exempt "$file"; then
    continue
  fi
  if is_auto_generated_exempt "$file"; then
    continue
  fi

  header_source="none"
  ff_target=""
  ff_band=""

  if yaml_values="$(extract_yaml_ccd_header "$file")"; then
    header_source="yaml"
    ff_target="${yaml_values%%$'\t'*}"
    ff_band="${yaml_values#*$'\t'}"
  fi

  if [[ "$header_source" == "none" ]]; then
    if html_values="$(extract_html_ccd_header "$file")"; then
      header_source="html"
      ff_target="${html_values%%$'\t'*}"
      ff_band="${html_values#*$'\t'}"
    fi
  fi

  if [[ "$header_source" == "none" ]]; then
    if is_wave1_hardened "$file"; then
      echo "FAIL: ${file}: Wave 1 file missing required CCD header" >&2
      FAILURE_COUNT=$((FAILURE_COUNT + 1))
    elif is_wave2_hardened "$file"; then
      echo "FAIL: ${file}: Wave 2 file missing required CCD header" >&2
      FAILURE_COUNT=$((FAILURE_COUNT + 1))
    else
      echo "FAIL: ${file}: missing required CCD header"
      FAILURE_COUNT=$((FAILURE_COUNT + 1))
    fi
    continue
  fi

  if ! band_values="$(parse_band_bounds "$ff_band")"; then
    echo "FAIL: ${file}: invalid ff_band value '${ff_band}'" >&2
    FAILURE_COUNT=$((FAILURE_COUNT + 1))
    continue
  fi
  band_lower="${band_values%%$'\t'*}"
  band_upper="${band_values#*$'\t'}"

  metrics="$(compute_metrics "$file")"
  IFS=$'\t' read -r sw_percent asl aad asl_proxy aad_proxy ff_score ff_score_int <<< "$metrics"

  SCORED_COUNT=$((SCORED_COUNT + 1))

  if band_is_outside_tolerance "$ff_score" "$band_lower" "$band_upper"; then
    primary_driver="$(select_primary_driver "$ff_target" "$band_lower" "$band_upper" "$sw_percent" "$asl_proxy" "$aad_proxy")"
    echo "FAIL: ${file}: FF_score=${ff_score_int} outside declared band ${ff_band}; primary driver=${primary_driver}" >&2
    FAILURE_COUNT=$((FAILURE_COUNT + 1))
  fi
done

echo "ff.sh: ${SCORED_COUNT} file(s) scored, ${WARNING_COUNT} warning(s), ${FAILURE_COUNT} failure(s)."

if (( FAILURE_COUNT > 0 )); then
  exit 1
fi
exit 0
