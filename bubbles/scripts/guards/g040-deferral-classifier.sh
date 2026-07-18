#!/usr/bin/env bash

[[ -n "${_BUBBLES_G040_CLASSIFIER_SOURCED:-}" ]] && return 0
_BUBBLES_G040_CLASSIFIER_SOURCED=1

g040_classify_statement() {
  local raw_line="$1"
  local classification=""

  classification="$(printf '%s\n' "$raw_line" | LC_ALL=C awk '
    function trim(value) {
      sub(/^[[:space:]]+/, "", value)
      sub(/[[:space:]]+$/, "", value)
      return value
    }

    function normalize(value) {
      value = tolower(value)
      gsub(/follow-up/, "followup", value)
      gsub(/follow[[:space:]]+up/, "followup", value)
      gsub(/[^a-z0-9]+/, " ", value)
      return trim(value)
    }

    function is_work_object(token) {
      return token == "work" || token == "item" || token == "task" ||
        token == "requirement" || token == "implementation" ||
        token == "fix" || token == "change" || token == "issue" ||
        token == "scope"
    }

    function is_schedule_target(token) {
      return token == "phase" || token == "sprint" || token == "iteration" ||
        token == "cycle" || token == "release" || token == "ticket" ||
        token == "issue" || token == "pr"
    }

    function blocking_reason(count, tokens, i, j, k, limit, target_limit) {
      for (i = 1; i <= count; i++) {
        if (tokens[i] == "future" && (tokens[i + 1] == "work" || tokens[i + 1] == "scope"))
          return "FUTURE_WORK_OR_SCOPE"
        if (tokens[i] == "next" && (tokens[i + 1] == "sprint" || tokens[i + 1] == "iteration"))
          return "NEXT_SPRINT_OR_ITERATION"
      }

      for (i = 1; i <= count; i++) {
        if (tokens[i] == "fix" || tokens[i] == "address") {
          limit = i + 8
          if (limit > count) limit = count
          for (j = i + 1; j <= limit; j++) {
            if (tokens[j] == "later") return "FIX_OR_ADDRESS_LATER"
            if (tokens[j] == "in") {
              target_limit = j + 6
              if (target_limit > count) target_limit = count
              for (k = j + 1; k <= target_limit; k++) {
                if (tokens[k] == "followup") return "FIX_OR_ADDRESS_IN_FOLLOW_UP"
              }
            }
          }
        }
      }

      for (i = 1; i <= count; i++) {
        if (tokens[i] == "defer" || tokens[i] == "postpone" ||
            tokens[i] == "skip" || tokens[i] == "punt") {
          limit = i + 6
          if (limit > count) limit = count
          for (j = i + 1; j <= limit; j++) {
            if (is_work_object(tokens[j])) return "WORK_DISPOSITION"
          }
        }
        if (tokens[i] == "deferred" || tokens[i] == "postponed" ||
            tokens[i] == "skipped" || tokens[i] == "punted") {
          for (j = i - 8; j < i; j++) {
            if (j > 0 && is_work_object(tokens[j])) return "WORK_DISPOSITION"
          }
        }
        if (tokens[i] == "skip" && tokens[i + 1] == "for" && tokens[i + 2] == "now")
          return "WORK_DISPOSITION"
        if (tokens[i] == "skipped" && tokens[i + 1] == "for" && tokens[i + 2] == "now")
          return "WORK_DISPOSITION"
        if (tokens[i] == "defer" || tokens[i] == "deferred" ||
            tokens[i] == "postpone" || tokens[i] == "postponed" ||
            tokens[i] == "skip" || tokens[i] == "skipped" ||
            tokens[i] == "punt" || tokens[i] == "punted") {
          limit = i + 6
          if (limit > count) limit = count
          for (j = i + 1; j <= limit; j++) {
            if (tokens[j] == "to" || tokens[j] == "until") {
              target_limit = j + 6
              if (target_limit > count) target_limit = count
              for (k = j + 1; k <= target_limit; k++) {
                if (is_schedule_target(tokens[k])) return "WORK_DISPOSITION"
              }
            }
          }
        }
      }

      for (i = 1; i <= count; i++) {
        if (tokens[i] == "out" && tokens[i + 1] == "of" && tokens[i + 2] == "scope")
          return "EXISTING_TRUE_DEFERRAL"
        if (tokens[i] == "not" && tokens[i + 1] == "in" && tokens[i + 2] == "scope")
          return "EXISTING_TRUE_DEFERRAL"
        if (tokens[i] == "beyond" && tokens[i + 1] == "scope")
          return "EXISTING_TRUE_DEFERRAL"
        if (tokens[i] == "revisit" && tokens[i + 1] == "later")
          return "EXISTING_TRUE_DEFERRAL"
        if ((tokens[i] == "tracked" || tokens[i] == "handled") && tokens[i + 1] == "separately")
          return "EXISTING_TRUE_DEFERRAL"
        if (tokens[i] == "not" && tokens[i + 1] == "implemented" && tokens[i + 2] == "yet")
          return "EXISTING_TRUE_DEFERRAL"
        if (tokens[i] == "not" && tokens[i + 1] == "yet" && tokens[i + 2] == "implemented")
          return "EXISTING_TRUE_DEFERRAL"
        if (tokens[i] == "placeholder") return "EXISTING_TRUE_DEFERRAL"
        if (tokens[i] == "temporary" && tokens[i + 1] == "workaround")
          return "EXISTING_TRUE_DEFERRAL"
        if (tokens[i] == "separate") {
          j = i + 1
          if (tokens[j] == "a" || tokens[j] == "an" || tokens[j] == "the") j++
          if (tokens[j] == "ticket" || tokens[j] == "issue" || tokens[j] == "pr")
            return "EXISTING_TRUE_DEFERRAL"
        }
      }
      return ""
    }

    function is_structural(raw_segment, normalized, lowered) {
      lowered = tolower(trim(raw_segment))
      if (lowered ~ /^followup(owner|action|target|s)[[:space:]]*:/)
        return 1
      if (normalized == "followup narrative" || normalized == "followup section")
        return 1
      if (normalized == "no deferred items" || normalized == "no deferred work" ||
          normalized == "no deferrals" || normalized == "without deferred work" ||
          normalized == "zero deferred items" || normalized == "zero deferrals" ||
          normalized == "no issues deferred" || normalized == "no issues deferred or skipped")
        return 1
      if (lowered ~ /^\[lockdown-deferred-fr-[0-9]+\]$/ ||
          lowered ~ /^\[lockdown-deferred-[a-z0-9-]+-fr-[0-9]+\]$/ ||
          lowered == "[awaiting-operator-commit]" ||
          lowered == "[awaiting-third-party-approval]" ||
          lowered == "[awaiting-cutover-window]" ||
          lowered == "[awaiting-regulator-review]")
        return 1
      return 0
    }

    function is_present_surface(count, tokens, start, verb_pos, i, limit) {
      start = 1
      if (tokens[start] == "the") start++
      if (!((tokens[start] == "active" && tokens[start + 1] == "mvp" && tokens[start + 2] == "surface") ||
            (tokens[start] == "current" && tokens[start + 1] == "planning" && tokens[start + 2] == "surface")))
        return 0
      verb_pos = start + 3
      if (!(tokens[verb_pos] == "includes" || tokens[verb_pos] == "implements" ||
            tokens[verb_pos] == "contains" || tokens[verb_pos] == "defines" ||
            tokens[verb_pos] == "provides" || tokens[verb_pos] == "delivers" ||
            tokens[verb_pos] == "supports"))
        return 0
      limit = verb_pos + 12
      if (limit > count) limit = count
      for (i = verb_pos + 1; i <= limit; i++) {
        if (tokens[i] == "authorized" && tokens[i + 1] == "outcome" && tokens[i + 2] == "followup")
          return 1
        if (tokens[i] == "followup" && tokens[i + 1] == "projection")
          return 1
      }
      return 0
    }

    {
      raw = $0
      segment_count = split(raw, segments, /[.?!;|]/)
      structural = 0
      accepted = ""
      blocked = ""

      for (segment_index = 1; segment_index <= segment_count; segment_index++) {
        raw_segment = trim(segments[segment_index])
        normalized = normalize(raw_segment)
        if (normalized == "") continue
        token_count = split(normalized, tokens, /[[:space:]]+/)

        reason = blocking_reason(token_count, tokens)
        if (reason != "") {
          blocked = reason
          break
        }

        if (is_structural(raw_segment, normalized)) {
          structural = 1
          continue
        }

        if (accepted == "" && normalized == "authorized outcome followup")
          accepted = "TITLE_OR_DOMAIN_LABEL"
        if (accepted == "" && normalized == "followup" &&
            (raw ~ /^[[:space:]]*#+/ || raw ~ /\|/ || raw_segment ~ /:[[:space:]]*$/))
          accepted = "STRUCTURED_LABEL"
        if (accepted == "" && is_present_surface(token_count, tokens))
          accepted = "PRESENT_SURFACE"
        if (accepted == "") {
          for (token_index = 1; token_index < token_count; token_index++) {
            if (tokens[token_index] == "followup" && tokens[token_index + 1] == "projection") {
              accepted = "NOUN_COMPOUND"
              break
            }
          }
        }
      }

      if (blocked != "")
        print "CLASSIFIED\tBLOCKING\t" blocked
      else if (structural)
        print "EXCLUDED_STRUCTURAL\tNONE\tCANONICAL_STRUCTURAL_EXCLUSION"
      else if (accepted != "")
        print "CLASSIFIED\tACCEPTED\t" accepted
      else
        print "NO_MATCH\tNONE\tNO_CONTRACT_MATCH"
    }
  ')"

  IFS=$'\t' read -r G040_SCAN_DISPOSITION G040_PHRASE_DISPOSITION G040_REASON_CODE <<< "$classification"
  [[ -n "$G040_SCAN_DISPOSITION" && -n "$G040_PHRASE_DISPOSITION" && -n "$G040_REASON_CODE" ]]
}
