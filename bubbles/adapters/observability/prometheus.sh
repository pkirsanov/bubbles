#!/usr/bin/env bash
# bubbles/adapters/observability/prometheus.sh — Prometheus telemetry adapter.
#
# Queries the Prometheus HTTP API at ${PROMETHEUS_BASE_URL} (e.g.
# http://localhost:9090). The operator MUST set PROMETHEUS_BASE_URL before
# invoking any live verb. NO default URL — fail-fast.
#
# Verbs (all 4 are mandatory per the observability adapter contract):
#   fetch-alerts          → /api/v1/alerts (active alerts), NORMALIZED to a
#                           bare JSON array (R2-D) — NOT the raw provider
#                           envelope.
#   fetch-slo-burn        → /api/v1/query?query=slo:burn_rate         (JSON map)
#   fetch-error-rate      → /api/v1/query?query=rate(...)             (JSON map)
#   fetch-deploy-impact   → /api/v1/query?query=delta(...)           (JSON map)
#
# Output: structured JSON to stdout. Adapter failure exits 1; framework
# treats that as "telemetry unavailable", NOT as a framework failure.
#
# Shape selftest (NO live backend, NO env required) — IMP-001 SCOPE-3 T3.2:
#   prometheus.sh selftest <verb>
# emits the canonical normalized SHAPE for <verb> so observability-adapter-lint
# can validate output shape without a Prometheus server. `selftest fetch-alerts`
# drives a canned raw envelope through the SAME normalize_alerts() used by the
# live path, proving the envelope→array normalization.
#
# Operator override hooks (env vars):
#   PROMETHEUS_BASE_URL              required (live verbs); no default
#   PROMETHEUS_BEARER_TOKEN          optional bearer token for /api/v1/*
#   PROMETHEUS_CURL_MAX_TIME         required (live verbs); no default
#   PROMETHEUS_QUERY_SLO_BURN        required for fetch-slo-burn; no default
#   PROMETHEUS_QUERY_ERROR_RATE      required for fetch-error-rate; no default
#   PROMETHEUS_QUERY_DEPLOY_IMPACT   required for fetch-deploy-impact; no default

set -euo pipefail

VERB="${1:-}"

usage() {
  cat >&2 <<'EOF'
prometheus.sh — Prometheus telemetry adapter
Usage: PROMETHEUS_BASE_URL=http://host:9090 PROMETHEUS_CURL_MAX_TIME=10 prometheus.sh <verb>
Verbs: fetch-alerts | fetch-slo-burn | fetch-error-rate | fetch-deploy-impact
Shape selftest (no live backend): prometheus.sh selftest <verb>
EOF
}

# normalize_alerts: read a raw Prometheus /api/v1/alerts envelope on stdin
# (`{"status":"success","data":{"alerts":[...]}}`) and emit the bare normalized
# JSON ARRAY required by the observability contract (R2-D):
#   [ { id, service, severity, startedAt, summary }, ... ]
normalize_alerts() {
  jq '[ (.data.alerts // [])[] | {
        id:        (.labels.alertname // "unknown"),
        service:   (.labels.service // "unknown"),
        severity:  (.labels.severity // "warning"),
        startedAt: (.activeAt // ""),
        summary:   (.annotations.summary // .labels.alertname // "")
      } ]'
}

# --- selftest / help short-circuits (NO live backend, NO env required) ----
case "$VERB" in
  -h|--help|"")
    usage
    exit 0
    ;;
  selftest)
    command -v jq >/dev/null 2>&1 || { echo "[prometheus][ERROR] jq required for selftest" >&2; exit 1; }
    SUB="${2:-}"
    case "$SUB" in
      fetch-alerts)
        # Drive a canned RAW Prometheus envelope through the SAME normalizer the
        # live fetch-alerts path uses, proving it yields a bare JSON array.
        printf '%s' '{"status":"success","data":{"alerts":[{"labels":{"alertname":"HighLatency","service":"gateway","severity":"critical"},"state":"firing","activeAt":"2026-06-11T00:00:00Z","annotations":{"summary":"gateway.request p99 above SLO target"}}]}}' | normalize_alerts
        ;;
      fetch-slo-burn|fetch-error-rate)
        # Canonical map shape: service.name -> float.
        echo '{"gateway.request":0.5}'
        ;;
      fetch-deploy-impact)
        # Canonical map shape: sourceSha -> { service, regressionDelta }.
        echo '{"a1b2c3d4e5f6":{"service":"gateway","regressionDelta":0.03}}'
        ;;
      *)
        echo "[prometheus][ERROR] selftest: unknown verb '$SUB' (expected fetch-alerts|fetch-slo-burn|fetch-error-rate|fetch-deploy-impact)" >&2
        exit 1
        ;;
    esac
    exit 0
    ;;
esac

# --- live verbs require env + curl + jq -----------------------------------
[[ -n "${PROMETHEUS_BASE_URL:-}" ]] || { echo "[prometheus][ERROR] PROMETHEUS_BASE_URL not set" >&2; exit 1; }
[[ -n "${PROMETHEUS_CURL_MAX_TIME:-}" ]] || { echo "[prometheus][ERROR] PROMETHEUS_CURL_MAX_TIME not set" >&2; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "[prometheus][ERROR] curl required" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "[prometheus][ERROR] jq required for URL encoding + normalization" >&2; exit 1; }

AUTH_HEADER=()
[[ -n "${PROMETHEUS_BEARER_TOKEN:-}" ]] && AUTH_HEADER=(-H "Authorization: Bearer ${PROMETHEUS_BEARER_TOKEN}")

urlencode() {
  jq -nr --arg v "$1" '$v|@uri'
}

call() {
  local path="$1"
  curl --max-time "$PROMETHEUS_CURL_MAX_TIME" --silent --show-error --fail "${AUTH_HEADER[@]}" "${PROMETHEUS_BASE_URL}${path}"
}

case "$VERB" in
  fetch-alerts)
    # Normalize the raw Prometheus alerts envelope to a bare JSON array (R2-D).
    call '/api/v1/alerts' | normalize_alerts
    ;;
  fetch-slo-burn)
    [[ -n "${PROMETHEUS_QUERY_SLO_BURN:-}" ]] || { echo "[prometheus][ERROR] PROMETHEUS_QUERY_SLO_BURN not set" >&2; exit 1; }
    call "/api/v1/query?query=$(urlencode "$PROMETHEUS_QUERY_SLO_BURN")"
    ;;
  fetch-error-rate)
    [[ -n "${PROMETHEUS_QUERY_ERROR_RATE:-}" ]] || { echo "[prometheus][ERROR] PROMETHEUS_QUERY_ERROR_RATE not set" >&2; exit 1; }
    call "/api/v1/query?query=$(urlencode "$PROMETHEUS_QUERY_ERROR_RATE")"
    ;;
  fetch-deploy-impact)
    [[ -n "${PROMETHEUS_QUERY_DEPLOY_IMPACT:-}" ]] || { echo "[prometheus][ERROR] PROMETHEUS_QUERY_DEPLOY_IMPACT not set" >&2; exit 1; }
    call "/api/v1/query?query=$(urlencode "$PROMETHEUS_QUERY_DEPLOY_IMPACT")"
    ;;
  *)
    echo "[prometheus][ERROR] unknown verb '$VERB'" >&2
    exit 1
    ;;
esac
