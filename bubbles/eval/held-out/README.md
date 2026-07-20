# Held-Out Eval Benchmark (IMP-020 S4 / AF-004)

Held-out benchmark tasks measure the framework's real output quality on tasks it
has **not** seen during development. They live here, disjoint from the
development corpus (`bubbles/eval/tasks/` + `bubbles/eval/fixtures/`), and are
validated by `bubbles/scripts/eval-heldout-guard.sh`:

- **Isolation** — no held-out `taskId` may also appear in the development corpus.
  A leaked task overfits the score, so it is a hard failure.
- **Substantive** — every held-out task MUST be a `schemaVersion: 2` task with at
  least one **required** `executable-oracle` / `semantic-evaluator` check (never
  structure alone — the AF-001 false-positive class).
- **Stratified** — a task MAY declare a `stratum` string so the benchmark reports
  per-stratum results.

The tasks are **operator-supplied** and typically kept private / rotated (like
the semantic and judge adapters, which are operator configuration) so they stay
genuinely held-out. This directory ships only the convention + the guard; drop
v2 task packs here (each with its oracle under its own `oracles/`) to run the
benchmark. An empty held-out directory is a clean no-op.

## Running the benchmark (with cost + provenance)

Wrap the run in the evidence recorder so the receipt carries cost (`durationMs`)
and provenance (framework version / sha):

```bash
BUBBLES_TOOL_LOG_TAGS=eval,held-out \
bash bubbles/scripts/tool-log.sh -- \
  bash bubbles/scripts/eval-harness.sh run \
    --suite bubbles/eval/held-out --output <produced-output>
```

The harness emits the per-task outcome; the tool-log receipt records the cost and
provenance. Do not infer success from a numeric ratio alone — use
`evaluationStatus`, `inputValid`, and `certified` together (see the harness
README).
