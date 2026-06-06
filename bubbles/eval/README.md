# Bubbles Golden-Task Eval Harness (v6.1 / R11)

Bubbles selftests (`bubbles/scripts/*-selftest.sh`) validate framework
**process and structure**. This harness adds the missing axis: scoring the
**quality of produced output** against fixed golden-task rubrics, so framework
*and* model upgrades can be measured for quality regression — not just gate-pass.

## Why

A spec can pass every gate and still be low quality (thin evidence, drifted DoD,
deferral language slipped past the heuristics). Eval-driven development closes
that loop: run a fixed task → score the output against a rubric → track the score
over time. A drop in score after a framework or model change is a regression even
when all gates are green.

## Usage

```bash
# Score one task against a produced output directory (e.g. a spec folder):
bash bubbles/scripts/eval-harness.sh score \
  --task bubbles/eval/tasks/golden-bugfix-001.json \
  --output path/to/spec-folder

# Run the whole suite and aggregate:
bash bubbles/scripts/eval-harness.sh run \
  --suite bubbles/eval/tasks \
  --output path/to/spec-folder
```

Exit code: `0` when the task PASSES (`ratio >= passThreshold`), `1` when it FAILS.

## Rubric check types

| type | params | scores weight when |
|------|--------|--------------------|
| `file-exists` | `path` | `<output>/<path>` exists |
| `contains` | `path`, `pattern` | file matches `pattern` (regex, case-insensitive) |
| `not-contains` | `path`, `pattern` | file does NOT match `pattern` |
| `gate-pass` | `command` | `command` (run in `<output>`) exits 0 |

A task's `ratio` is `sum(weight of passed checks) / sum(all weights)`.

## Pluggable LLM-as-judge (optional)

Deterministic rubric checks are the default and are 100% reproducible. To blend
in an LLM-as-judge, set `judgeWeight` (0..1) in the task and export
`BUBBLES_EVAL_JUDGE` to a command that reads the output directory path as its
single argument and prints a `0..1` quality score on stdout:

```bash
BUBBLES_EVAL_JUDGE=./my-llm-judge.sh \
  bash bubbles/scripts/eval-harness.sh score --task <task> --output <dir>
```

The final ratio becomes `(1 - judgeWeight) * deterministicRatio + judgeWeight * judgeScore`.
With no judge configured, `judgeWeight` is ignored and scoring stays deterministic.

## Adding a golden task

Drop a new `bubbles/eval/tasks/<id>.json` with a `taskId`, `passThreshold`, and a
`checks[]` array. The harness discovers it automatically under `run --suite`. Keep
tasks deterministic so the score is reproducible across runs and machines.

## Validation

`bubbles/scripts/eval-harness-selftest.sh` proves the scorer DISCRIMINATES: a
known-good output scores above threshold (PASS), a known-bad output scores below
threshold (FAIL). Wired into `framework-validate`.
