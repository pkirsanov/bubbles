#!/usr/bin/env bash
# bubbles/adapters/observability/prometheus.sh — Prometheus telemetry adapter.
#
# Queries the Prometheus HTTP API at ${PROMETHEUS_BASE_URL} (e.g.
# http://localhost:9090). The operator MUST set PROMETHEUS_BASE_URL before
# invoking any verb. NO default URL — fail-fast.
#
# Verbs (all 4 are mandatory per the observability adapter contract):
#   fetch-alerts          → /api/v1/alerts (active alerts)
#   fetch-slo-burn        → /api/v1/query?query=slo:burn_rate
#   fetch-error-rate      → /api/v1/query?query=rate(http_requests_errors_total[5m])
#   fetch-deploy-impact   → /api/v1/query?query=delta(deploy_regression_score[1h])
#
# Output: structured JSON to stdout. Adapter failure exits 1; framework
# treats that as "telemetry unavailable", NOT as a framework failure.
#
# Operator override hooks (env vars, all optional):
#   PROMETHEUS_BASE_URL              required; no default
#   PROMETHEUS_BEARER_TOKEN          optional bearer token for /api/v1/*
#   PROMETHEUS_CURL_MAX_TIME         default 10 (seconds)
#   PROMETHEUS_QUERY_SLO_BURN        override SLO burn promql
#   PROMETHEUS_QUERY_ERROR_RATE      override error-rate promql
#   PROMETHEUS_QUERY_DEPLOY_IMPACT   override deploy-impact promql

set -euo pipefail

VERB="${1:-}"

[[ -n "${PROMETHEUS_BASE_URL:-}" ]] || { echo "[prometheus][ERROR] PROMETHEUS_BASE_URL not set" >&2; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "[prometheus][ERROR] curl required" >&2; exit 1; }

MAX_TIME="${PROMETHEUS_CURL_MAX_TIME:-10}"
AUTH_HEADER=()
[[ -n "${PROMETHEUS_BEARER_TOKEN:-}" ]] && AUTH_HEADER=(-H "Authorization: Bearer ${PROMETHEUS_BEARER_TOKEN}")

call() {
  local path="$1"
  curl --max-time "$MAX_TIME" --silent --show-error --fail "${AUTH_HEADER[@]}" "${PROMETHEUS_BASE_URL}${path}"
}

case "$VERB" in
  fetch-alerts)
    call '/api/v1/alerts'
    ;;
  fetch-slo-burn)
    Q="${PROMETHEUS_QUERY_SLO_BURN:-slo:burn_rate}"
    call "/api/v1/query?query=$(printf '%s' "$Q" | sed 's/ /%20/g')"
    ;;
  fetch-error-rate)
    Q="${PROMETHEUS_QUERY_ERROR_RATE:-rate(http_requests_errors_total[5m])}"
    call "/api/v1/query?query=$(printf '%s' "$Q" | sed 's/ /%20/g')"
    ;;
  fetch-deploy-impact)
    Q="${PROMETHEUS_QUERY_DEPLOY_IMPACT:-delta(deploy_regression_score[1h])}"
    call "/api/v1/query?query=$(printf '%s' "$Q" | sed 's/ /%20/g')"
    ;;
  -h|--help|"")
    cat >&2 <<'EOF'
prometheus.sh — Prometheus telemetry adapter
Usage: PROMETHEUS_BASE_URL=http://host:9090 prometheus.sh <verb>
Verbs: fetch-alerts | fetch-slo-burn | fetch-error-rate | fetch-deploy-impact
EOF
    exit 0
    ;;
  *)
    echo "[prometheus][ERROR] unknown verb '$VERB'" >&2
    exit 1
    ;;
esac
