# Bubbles Golden-Task Eval Harness (Task Contract v2)

Bubbles selftests validate framework process and structure. The eval harness
adds a separate output-quality check: it scores a produced output directory
against a versioned task rubric and reports whether that result is eligible to
certify substantive quality.

Task contract v2 is fail-closed. Structural file and regular-expression checks
remain useful diagnostics, but they cannot certify a v2 task without a required
executable oracle or semantic evaluator.

## Usage

```bash
# Score one task against a produced output directory.
bash bubbles/scripts/eval-harness.sh score \
  --task path/to/task-pack/task.json \
  --output path/to/produced-output

# Score every top-level JSON task in a task-pack directory.
bash bubbles/scripts/eval-harness.sh run \
  --suite path/to/task-pack \
  --output path/to/produced-output
```

An executable task pack keeps its oracle under the task directory because
`allowedRoot` is resolved relative to the task JSON file:

```text
task-pack/
  task.json
  oracles/
    verify-output.py
```

The harness emits JSON to stdout. `score` returns one task result. `run` returns
an aggregate plus every task result.

## Contract Versions

| Task form | Behavior | Certification |
| --- | --- | --- |
| `schemaVersion` absent or `1` | Runs the migration-compatible structural contract. Legacy `gate-pass` command strings are reported `unavailable` and are never executed. | Always non-certifying, even when `evaluationStatus` is `passed`. |
| `schemaVersion: 2` | Validated against the closed v2 task shape and evaluated with fail-closed substantive checks. | Eligible only when the complete v2 evaluation passes. |

The machine-readable contracts are:

- `bubbles/eval/schemas/task-v2.schema.json`
- `bubbles/eval/schemas/evaluator-result.schema.json`

A passing v1 task can still exit `0` for compatibility, but its result has
`legacy: true`, `certified: false`, and
`certification.status: legacy-non-certifying`. A suite containing passing v1
tasks is likewise not certified.

## Exit Codes

| Exit | Meaning |
| --- | --- |
| `0` | The task, or every task in the suite, has `evaluationStatus: passed`. This does not make a v1 result certifying. |
| `1` | A valid evaluation finished `failed`, `error`, or `unavailable`; the suite was empty; or a required runtime such as Python was unavailable. |
| `2` | Usage or input failure, including an invalid task schema. A suite returns `2` when any task is input-invalid. |

Do not infer success from a numeric ratio alone. Use `evaluationStatus`,
`inputValid`, and `certified` together.

## Version 2 Task Shape

A v2 task requires `schemaVersion`, `taskId`, `passThreshold`, and a non-empty
`checks` array. It must contain at least one check whose type is
`executable-oracle` or `semantic-evaluator` and whose `required` value is
explicitly `true`.

```json
{
  "schemaVersion": 2,
  "taskId": "example-output-quality",
  "passThreshold": 0.8,
  "judgeWeight": 0,
  "checks": [
    {
      "id": "report-exists",
      "type": "file-exists",
      "required": true,
      "weight": 1,
      "path": "report.md"
    },
    {
      "id": "end-state",
      "type": "executable-oracle",
      "required": true,
      "weight": 4,
      "allowedRoot": "oracles",
      "argv": ["verify-output.py", "expected-mode"],
      "timeoutSeconds": 5
    }
  ]
}
```

Check IDs must be unique. Paths must be relative and cannot traverse outside
their declared root. Weights are finite numbers greater than or equal to zero,
at least one check must have positive weight, and timeouts must be in
`(0, 300]` seconds.

## Check Types

| Type | Parameters | Result |
| --- | --- | --- |
| `file-exists` | `path` | `passed` when `<output>/<path>` exists. |
| `contains` | `path`, `pattern` | `passed` when the file matches the case-insensitive, multiline regular expression. |
| `not-contains` | `path`, `pattern` | `passed` when the file exists and does not match the expression. |
| `executable-oracle` | `argv`, `allowedRoot`, optional `timeoutSeconds` | Runs the allowlisted executable without a shell; exit `0` is `passed`, nonzero is `failed`, and execution faults are `error` or `unavailable`. |
| `semantic-evaluator` | optional `rubric`, optional `timeoutSeconds` | Calls the operator-configured semantic adapter and validates its JSON result. |

Unknown required check types invalidate the task. An unknown optional check is
retained as `unavailable` for forward compatibility. If its weight is greater
than zero, evaluation fails closed because no valid weighted score exists.

## Required And Weighted Failure Semantics

Every check and judge uses one of four statuses:

- `passed`: the check or evaluator produced a valid passing result.
- `failed`: evaluation ran and the required behavior or quality bar did not
  pass.
- `error`: evaluation could not produce a trustworthy result because execution
  or result validation failed.
- `unavailable`: the required executable, adapter, or runtime was not available.

The task result preserves each status and its machine-readable error. The
scoring rules are:

1. Any required check whose status is not `passed` fails the task regardless of
   its weight or the weighted ratio.
2. Any positive-weight check with status `error` or `unavailable` makes
   `score`, `deterministicRatio`, and the final `ratio` unavailable. It cannot
   silently contribute zero and allow another check to carry the task.
3. A non-required check with status `failed` contributes zero. Other valid
   check scores are multiplied by their weights.
4. When every weighted check produced a score,
   `deterministicRatio = sum(earnedScore) / sum(weight)`.
5. A ratio below `passThreshold` fails. A required failure still fails even if
   the ratio meets the threshold.

The aggregate `evaluationStatus` gives precedence to `error`, then
`unavailable`, then `failed`, then `passed`. Results also expose
`evaluationErrors`, per-check `status`, `score`, `earnedScore`, and `error`, and
the complete `judge` record.

## Executable Oracles

Task manifests do not contain shell command strings. An executable oracle uses
a JSON `argv` array and a relative `allowedRoot`:

- `allowedRoot` resolves under the directory containing the task JSON.
- `argv[0]` must resolve to an executable regular file inside that root.
- The harness invokes the array directly with `shell: false`; spaces, pipes,
  semicolons, substitutions, and other shell metacharacters remain literal
  arguments.
- The oracle working directory is the produced output directory.
- `BUBBLES_EVAL_OUTPUT` contains the absolute output directory and
  `BUBBLES_EVAL_TASK` contains the absolute task path.
- Oracle stdout and stderr are not evaluator results. Exit `0` passes and a
  nonzero exit fails with `oracle-nonzero`.

Legacy `gate-pass` is recognized only for v1 compatibility and is always
`unavailable` with `legacy-gate-pass-disabled`; its task-provided command is
never executed.

## Semantic And Judge Adapters

Adapters are operator configuration, not task-provided commands:

- `BUBBLES_EVAL_SEMANTIC` configures `semantic-evaluator` checks.
- `BUBBLES_EVAL_JUDGE` configures the weighted task judge.

Each value may be one executable path or a JSON array of fixed argv elements.
The harness never sends either form through a shell. JSON argv is useful when
an interpreter or fixed adapter options are required:

```bash
export BUBBLES_EVAL_SEMANTIC='["python3","/absolute/path/semantic-adapter.py"]'
export BUBBLES_EVAL_JUDGE='["python3","/absolute/path/judge-adapter.py"]'
```

The harness appends these positional arguments:

```text
semantic adapter: <configured-argv> <absolute-output-dir> <absolute-task-path> <check-id>
judge adapter:    <configured-argv> <absolute-output-dir> <absolute-task-path>
```

The adapter must exit `0` and write exactly one JSON value to stdout matching
`evaluator-result.schema.json`. Its top-level fields are closed:

```json
{
  "status": "passed",
  "score": 1.0,
  "verdict": "end-state behavior passed",
  "rubricFindings": [],
  "provenance": {
    "adapter": "example-evaluator",
    "version": "1.0.0",
    "provider": "local-executable"
  }
}
```

`status` is one of `passed`, `failed`, `error`, or `unavailable`. `passed` and
`failed` require a finite `score` in `[0, 1]`. `error` and `unavailable` require
`score: null` plus an `error` object with non-empty `code` and `message`.
`provenance.adapter` and `provenance.version` are always required; `provider`,
`model`, and `invocationId` are optional.

Adapter configuration errors, missing executables, nonzero exits, timeouts,
empty output, malformed or non-finite JSON, out-of-range scores, missing
provenance, and schema-invalid output remain visible as `error` or
`unavailable` records with machine-readable codes.

## Weighted Judge Contract

`judgeWeight: 0` means no judge was requested. The result still contains a
judge record with `required: false`, `status: unavailable`, and
`judge-not-requested`; that record does not fail the task.

When `judgeWeight > 0`, the judge is required. A passing task requires a
configured adapter, valid evaluator-result JSON, and `judge.status: passed`.
The final ratio is:

```text
(1 - judgeWeight) * deterministicRatio + judgeWeight * judge.score
```

A missing, failed, unavailable, or invalid weighted judge fails the task and
remains present in both `judge` and `evaluationErrors`. Judge failure is never
discarded in favor of the deterministic score.

## Golden Tasks And Fixtures

The bundled task manifests are v2 quality-critical tasks:

- `bubbles/eval/tasks/golden-bugfix-001.json` combines structural report checks
  with the required `bugfix-end-state` executable oracle.
- `bubbles/eval/tasks/golden-feature-001.json` combines structural spec checks
  with the required `feature-contract-end-state` executable oracle.

Their public hermetic fixtures live under `bubbles/eval/fixtures/`:

- Positive outputs exercise real bugfix and feature end states under
  `positive/bugfix-output/` and `positive/feature-output/`.
- `positive/oracles/fixture-oracle.py` supplies the executable behavior oracle.
- `positive/adapters/evaluator-fixture.py` supplies valid semantic and judge
  results and controlled adapter failure modes.
- `negative/hollow-report/` and `negative/token-stuffed-spec/` preserve the
  exact AF-001 false-positive regressions.
- `negative/tasks/` covers invalid and malformed tasks, missing substantive
  evaluators, unknown checks, missing/nonzero/timed-out/out-of-root oracles,
  literal shell metacharacters, missing semantic adapters, and weighted judge
  failure and timeout behavior.

These are harness contract fixtures, not held-out certification tasks.

## Focused Validation

Run the S1 harness regression directly:

```bash
bash bubbles/scripts/eval-harness-selftest.sh
```

The selftest stages the golden task manifests with the positive oracle in a
temporary task pack. It proves positive behavioral outputs certify, the hollow
and token-stuffed outputs fail, schema/input errors return `2`, oracle
containment and literal argv are enforced, semantic adapter availability and
provenance are visible, weighted-judge malformed-output and runtime failures
fail closed, the two-task positive suite certifies, and a missing Python runtime
is unavailable/non-certifying.

This focused selftest is the validation scope described here; it is not, by
itself, a claim that full framework validation ran or passed.

## Related Eval Tooling (IMP-020 S4–S6)

Beyond the golden-task harness, these generic eval tools compose with it:

- **Held-out isolation (AF-004)** — `bubbles/scripts/eval-heldout-guard.sh`
  enforces that a held-out benchmark (`bubbles/eval/held-out/`) is disjoint from
  this development corpus and substantive. See `held-out/README.md`.
- **Effective prompt bundle (AF-006)** — `bubbles/scripts/effective-bundle-measure.sh`
  measures an agent's transitively-loaded `bubbles_shared` closure (bytes / lines /
  files + skill pointers).
- **Forecast eval (FIN-001)** — `bubbles/scripts/forecast-eval-check.sh` is the
  generic, product-agnostic forecast core: temporal-integrity / leakage detection
  (`predictedAt` < `resolvedAt`) plus Brier scoring over probabilistic predictions
  vs binary outcomes. It carries no product data; a product's forecast task uses it
  as an executable-oracle.
