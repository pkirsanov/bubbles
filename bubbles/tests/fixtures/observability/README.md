# Observability fixtures (IMP-001)

Reference fixtures for the `traceContracts.observability` contract defined in
SCOPE-1. They are **consumed by the SCOPE-2/3/4 guards and their selftests**:

| Fixture | Shape | Consumed by | Expectation |
|---------|-------|-------------|-------------|
| `payload-alerts.json` | JSON **array** | SCOPE-3 adapter-lint | valid `fetch-alerts` shape |
| `payload-slo-burn.json` | JSON **map** | SCOPE-3 adapter-lint | valid `fetch-slo-burn` shape |
| `payload-error-rate.json` | JSON **map** | SCOPE-3 adapter-lint | valid `fetch-error-rate` shape |
| `payload-deploy-impact.json` | JSON **map** | SCOPE-3 adapter-lint | valid `fetch-deploy-impact` shape |
| `payload-alerts-raw-envelope.invalid.json` | raw provider envelope | SCOPE-3 adapter-lint | **rejected** — not the normalized array |
| `slo-evidence.json` | normalized SLO evidence | SCOPE-4 SLO guard (G100) | valid observed/target shape accepted |
| `slo-evidence-malformed.invalid.json` | missing `observed` | SCOPE-4 SLO guard (G100) | **rejected** before numeric comparison |
| `posture-wired.yaml` | `posture: wired` (real signals) | SCOPE-2 posture guard (G098) | accepted |
| `posture-opted-out-fresh.yaml` | `opted-out`, `revisitAfter` future | SCOPE-2 opt-out guard (G099) | accepted (fresh) |
| `posture-opted-out-expired.yaml` | `opted-out`, `revisitAfter` past | SCOPE-2 opt-out guard (G099) | reminder escalates (expired) |
| `posture-malformed.yaml` | `opted-out` with NO `optOut` block | SCOPE-2 posture guard (G098) | **rejected** (malformed) |
| `posture-fake-wired.yaml` | `wired` but every signal `none` | SCOPE-2 posture guard (G098) | **rejected** (fake-wired) |
| `posture-unsupported-schema-version.yaml` | `schemaVersion: 999` | all observability guards | **fail loud** before semantics |

## Canonical normalized payloads (R2-D)

- `fetch-alerts` → JSON **array** `[]`
- `fetch-slo-burn` / `fetch-error-rate` / `fetch-deploy-impact` → JSON **map** `{}`

The `none` adapter returns the neutral empty value per verb (`[]` for alerts,
`{}` for the maps). SCOPE-1 only DEFINES these contracts and ships these
fixtures; aligning `none.sh` / `prometheus.sh` / `observability-adapter-lint.sh`
to the per-verb shapes is SCOPE-3.

## SLO evidence + two evidence stores (R2-F)

`slo-evidence.json` is the parsed metric artifact a wired repo deposits at
`.specify/runtime/observability/<workflow>.<signal>.json` — the numeric input
the SCOPE-4 SLO guard asserts against. Provenance that the capture command ran
lives separately in `.specify/runtime/tool-calls.jsonl` (MCP `record_evidence`).
`.specify/runtime/` is gitignored.
