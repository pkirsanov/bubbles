# IMP-020 — Agentic Evaluation and Trust Hardening

**Status:** IN PROGRESS — S1 implemented and validated; S2-S7 pending. Repository owner approval recorded 2026-07-10.
**Surface:** framework-health (G125) — approved implementation program with independently landable scopes
**Motivation:** completed adversarial review of Bubbles evaluation validity, validator semantics, tool/content trust boundaries, effective instruction load, and outcome-level benchmarking
**Verified gaps addressed:** AF-001, AF-002, AF-003, AF-004, AF-005, AF-006, FIN-001
**Implementation authorization:** the repository owner approved systematic implementation and validation of S1 through S7 in dependency order. Approval does not waive scope acceptance criteria, focused tests, framework validation, release checks, or human review of generated release artifacts.

## Change Boundary

This IMP owns the implementation plan. It does not implement any framework source in the framework-health invocation that created it.

The implementation MUST remain product-agnostic. Core Bubbles may define generic evaluator, trust, benchmark, and downstream profile contracts; it MUST NOT encode a product's forecasting model, symbols, portfolios, data vendors, trading rules, or acceptance thresholds.

This IMP does not create a fixed agent committee. Repeated calls in one VS Code runtime are correlated samples from the same model/tool context, not independent validators. Runtime routing remains task-sensitive, and every benchmark compares the selected workflow with the simplest adequate baseline.

## Evidence Basis

Source paths below were re-checked against the canonical framework checkout. Executed adversarial outcomes are the verified evidence supplied with the owner review; they are recorded here as review inputs, not represented as commands re-run by this proposal-only invocation.

### Framework-Health Inputs Checked (G125)

- `.specify/runtime/framework-events.jsonl` contained 67 event rows when inspected. A targeted search for eval, judge, red-team/adversarial, instruction/prompt, trust/tool, cross-model, and framework-health terms returned no matches. The event log therefore neither proves nor disproves AF-001 through AF-006; those findings rest on the source paths and executed adversarial fixtures below.
- `.specify/runtime/workflow-runs.json` records command, result, and duration for framework CLI runs, including a successful `lint-budget` run on 2026-07-10 and both failed and successful `framework-validate` runs. Its records do not contain model/prompt/tool hashes, token counts, tool-call counts, cost, human interventions, task outcomes, or trace grades. It supports the claim that current command telemetry is insufficient for S5, not a claim about why any recorded validation run failed.
- `bubbles/capability-ledger.yaml` marks `framework-self-observation` as shipped and `repo-readiness-guidance` as partial; the latter explicitly says trust packaging and evaluation clarity are still improving. No shipped capability entry in the inspected ledger declares the end-to-end agent benchmark or trust contract proposed here.

| Finding | Current source | Executed or structural evidence |
| --- | --- | --- |
| **AF-001 — rubric-shaped output can pass without substance** | `bubbles/eval/tasks/golden-bugfix-001.json` and `golden-feature-001.json` award all weight through file existence and regular-expression presence/absence. `bubbles/scripts/eval-harness.sh` implements only `file-exists`, `contains`, `not-contains`, and `gate-pass`. | A hollow `report.md` containing only `PASS: adversarial regression.` and a one-line spec containing the rubric tokens `Outcome Contract`, `Success Signal`, `Given`, `When`, and `Then` each scored ratio `1.0` and passed. |
| **AF-002 — judge errors fail open** | `eval-harness.sh::score_task` catches every judge exception and executes `pass`; its result JSON has no judge status or error field. | A fixture with `judgeWeight=1.0` and `BUBBLES_EVAL_JUDGE=/usr/bin/printf` emitted invalid nonnumeric output but still passed at ratio `1.0`, with no judge status. |
| **AF-003 — unsupported voting and independence claims** | `agents/bubbles.redteam.agent.md` and `docs/recipes/adversarial-verification.md` claim N independent validators, consensus, and disagreement escalation. `bubbles/scripts/adversarial-resolve.sh` only resolves and prints `passes=N`; it does not launch validators or aggregate results. `bubbles/workflows.yaml::crossModelReview` describes phase actions and a command fallback, but no framework script implements an external review adapter. | A live `/bubbles.redteam` run with `passes: 3` executed zero child validators. `docs/guides/AGENT_MANUAL.md` states that VS Code subagents inherit the same model and tools as the main session. Same-runtime repetitions therefore cannot establish validator independence. |
| **AF-004 — no executable end-to-end agent outcome benchmark** | `bubbles/scripts/framework-validate.sh` invokes only `eval-harness-selftest.sh`; that selftest scores hand-written GOOD/BAD fixture directories. `bubbles/eval/` currently contains a README and two task JSON files, with no executable held-out runner or score history. | The completed repo-wide review found no held-out executable agent tasks, repeated-trial reliability metric, baseline comparison, trace grader, cost/token/tool-call accounting, human-intervention count, or model/prompt/tool provenance in the eval surface. |
| **AF-005 — untrusted content and ambient tools are outside the current risk gate** | No prompt-injection or untrusted-content policy was found in the repo-wide search. Most specialists omit `tools:` and therefore inherit all enabled tools; the five orchestrators declare `[read, search, edit, agent, todo, web, execute, bubbles, playwright]`. `pre-tool-risk-gate.sh` resolves Bubbles CLI command names from `action-risk-registry.yaml`, defaults unknown commands to `read_only`, and accepts `--confirm` or `BUBBLES_RISK_CONFIRM=1`. `bubbles/hooks.json` registers only that Bubbles action classifier as its pre-tool hook. | The current gate has no event schema for ambient editor, shell, browser, web, or arbitrary MCP arguments/results; no data-class or egress decision; and no trusted MCP allowlist. |
| **AF-006 — per-file instruction counts do not measure the loaded bundle** | `instruction-budget-lint.sh` scans each `bubbles.*.agent.md` and each shared module independently. It does not resolve imported/shared modules, workflow phase instructions, applicable instruction files, skills, or host tool descriptions into one effective bundle. `full-delivery` declares 18 phases in `bubbles/workflows/modes.yaml`. | The executed lint passed while reporting 113 directives for `bubbles.workflow` and 105 for `bubbles.validate`, before shared modules and tool descriptions. No current complexity/cost/outcome baseline demonstrates that the 18-phase mode outperforms focused modes or a simple three-stage workflow. |
| **FIN-001 — no reusable downstream forecast-evaluation profile** | `bubbles/eval/` has no profile schema or example for point-in-time forecast evaluation. | The owner recommendation requires a product-agnostic contract for vintage data, proper scores, calibration, transaction costs, regime analysis, and leakage controls without moving finance product logic into core gates. |

## Decisions

1. **Quality-critical evaluation is fail-closed.** Missing required evaluators, invalid schemas, judge timeouts/errors, malformed judge output, unknown required checks, or unavailable required dependencies produce an explicit evaluation error and a nonzero exit. They never preserve the deterministic score or silently pass.
2. **Regex checks are diagnostics, not semantic proof.** A quality-critical task must have at least one required executable end-state oracle or a required semantic evaluator. A weighted token-presence score alone cannot certify it.
3. **Same-runtime repetition is named `samples`.** Bubbles may deterministically aggregate correlated samples, but it will not call them independent votes or cross-model review.
4. **No current external-review path is treated as verified.** The current framework has no implementation that proves provider/model identity distinct from the active runtime. S2 therefore removes unsupported independence/cross-model execution claims. A future external adapter may restore that capability only with host- or provider-verifiable provenance.
5. **Trust enforcement states its boundary.** Bubbles can enforce calls routed through its CLI/MCP/hook contracts and can lint declared tool grants. It cannot promise interception of every ambient VS Code built-in tool or guarantee that a model will ignore malicious text. Unsupported host controls remain `unavailable`, not simulated.
6. **Prompt limits are empirical.** S4 first compiles and records the effective bundle. Numeric blocking thresholds are calibrated by S5 outcome data; they are not invented from a per-file directive count.
7. **Workflow complexity must earn its cost.** The simple three-stage baseline, the smallest task-appropriate focused mode, and `full-delivery` are evaluated on the same held-out task strata and provenance. More phases or agents are not assumed to be better.
8. **Forecast evaluation is a downstream contract.** Core validates schema and generic point-in-time/scoring invariants. Downstream products supply data adapters, predictions, decision policy, cost assumptions, and acceptance thresholds.

## Dependency And Landing Order

`S1 -> S2 -> S3 -> S4 -> S5 -> S6 -> S7`

- S1 establishes trustworthy evaluator failure semantics before any ensemble or benchmark consumes scores.
- S2 establishes honest sample/provenance semantics before S5 reports repeated trials.
- S3 establishes tool/content trust metadata before S4 hashes tool surfaces and S5 runs agents on held-out tasks.
- S4 produces prompt/tool provenance and complexity telemetry consumed by S5.
- S5 establishes outcome/cost evidence and regression thresholds.
- S6 reuses the S1/S5 profile and oracle contracts without coupling core to a product.
- S7 reconciles public claims, generated artifacts, and release evidence after all behavior is present.

Each scope is independently landable. Its commit must include its focused tests and any mechanically required checksum/release-manifest regeneration for files changed in that scope. S7 is the final cross-surface reconciliation, not permission for S1-S6 to leave validation red.

## S1 — Fail-Closed Evaluation And Substantive Rubrics (AF-001, AF-002)

**Depends on:** none.

### S1 Implementation

- Introduce a versioned task schema. Invalid task definitions fail before scoring.
- Add required-check semantics: a failed or unavailable required check makes the task fail regardless of weighted ratio.
- Add an executable oracle check using an argument array and an allowlisted oracle root. Do not execute task-provided shell strings with `shell=True`.
- Add a semantic check contract whose adapter returns schema-validated JSON containing at least `status`, `score`, `verdict`, `rubricFindings`, and evaluator provenance. Semantic checks are unavailable unless a configured adapter satisfies the contract.
- When `judgeWeight > 0`, require a configured, successful judge. Nonzero exit, timeout, empty output, nonnumeric/out-of-range score, malformed JSON, or missing provenance produces `evaluationStatus: error`, a machine-readable reason, and a nonzero harness exit.
- Emit per-check and per-judge status in every result. Distinguish `passed`, `failed`, `error`, and `unavailable`; never encode evaluator failure as a score of zero or as success.
- Retain file/regex checks for cheap structural diagnostics, but rewrite the two golden tasks so their quality-critical pass cannot be obtained from token presence alone.
- Commit adversarial negative fixtures for the exact hollow report, one-line token-stuffed spec, invalid judge output, judge nonzero exit, judge timeout, unknown required check, and missing required executable oracle.
- Treat a missing required runtime (including Python for the current implementation) as evaluation unavailable/nonzero, not `SKIP` with exit 0 on a quality claim.

### S1 Files And Owners

| Files | Owner | Responsibility |
| --- | --- | --- |
| `bubbles/scripts/eval-harness.sh` | `bubbles.implement` | fail-closed scorer, safe executable adapter, result statuses |
| `bubbles/eval/schemas/task-v2.schema.json`, `bubbles/eval/schemas/evaluator-result.schema.json` (new) | `bubbles.implement` | machine-readable task and evaluator contracts |
| `bubbles/eval/tasks/golden-bugfix-001.json`, `golden-feature-001.json` | `bubbles.test` | substantive required oracle/semantic rubric definitions |
| `bubbles/eval/fixtures/negative/**` (new), `bubbles/scripts/eval-harness-selftest.sh` | `bubbles.test` | adversarial false-positive and fail-open regressions |
| `bubbles/eval/README.md` | `bubbles.docs` | exact scoring/error contract and adapter authoring guidance |
| `bubbles/scripts/framework-validate.sh`, `bubbles/release-manifest.json` | `bubbles.devops` / `bubbles.releases` | focused selftest wiring and generated manifest freshness |

### S1 Tests

- Reproduce both AF-001 hollow fixtures and assert nonzero with a failed required substantive check.
- Reproduce AF-002 with `/usr/bin/printf` and assert `evaluationStatus: error`, a judge error code, and nonzero exit.
- Cover judge success, nonzero exit, timeout, malformed JSON, missing provenance, `NaN`, infinity, and scores outside `[0,1]`.
- Cover invalid task schema, unknown optional check, unknown required check, missing oracle, oracle nonzero exit, and attempted shell metacharacters in argv.
- Prove a real positive fixture passes and that every negative differs on behavior, not merely on a magic token.

### S1 Acceptance Criteria

- Neither supplied hollow fixture can pass any quality-critical golden task.
- A configured/weighted judge can never disappear from the result; every judge attempt has a status and provenance/error record.
- Every required evaluator failure exits nonzero and the aggregate suite cannot report all tasks passed.
- No task manifest can inject an arbitrary shell pipeline through executable checks.
- The focused selftest and full `framework-validate` pass with the new contract.

## S2 — Validator Provenance And Honest Sample Aggregation (AF-003)

**Depends on:** S1.

### S2 Implementation

- Rename same-runtime `passes` semantics to `samples`. Accept `passes` only as a time-bounded compatibility alias that emits a deprecation field/message and resolves to `samples`; new config, output, docs, and examples use `samples`.
- Emit `sampleSemantics: same-runtime-correlated` unless stronger provenance is actually verified. Never emit `independent`, `cross-model`, `ensemble vote`, or equivalent for inherited VS Code subagents.
- Implement a deterministic sample-result schema and aggregator. Normalize each finding to a stable fingerprint from category, target, evidence reference, and claim; preserve every unique finding.
- Aggregate without majority-silencing:
  - all samples clear with no findings -> `agreement-clear`;
  - all samples return the same finding fingerprints -> `agreement-findings` and route the full set;
  - verdicts or blocking finding sets differ -> `disagreement` and escalate the union plus the per-sample matrix;
  - any sample errors or lacks provenance -> `aggregation-error`, never consensus.
- Keep sample count task-sensitive. One sample remains the normal default; additional samples are justified by declared risk/uncertainty and bounded by configuration. Do not define a fixed committee or fixed provider roster.
- Remove the current unsupported external cross-model execution claims from `bubbles.redteam`, `workflows.yaml`, and public recipes. The current source provides no verifiable adapter, so this IMP deliberately takes the “otherwise remove unsupported claims” branch.
- Reserve a versioned external-review adapter interface, but do not advertise or enable it. A future implementation must verify provider/model identity from trusted host/provider metadata, prove it differs from the active model/runtime, hash the adapter/config, and retain invocation evidence. Operator-entered labels or command names alone are not verification.

### S2 Files And Owners

| Files | Owner | Responsibility |
| --- | --- | --- |
| `bubbles/scripts/adversarial-resolve.sh`, `adversarial-resolve-selftest.sh` | `bubbles.implement` / `bubbles.test` | `samples` resolution and compatibility alias |
| `bubbles/scripts/adversarial-aggregate.sh`, `adversarial-aggregate-selftest.sh` (new) | `bubbles.implement` / `bubbles.test` | deterministic union/agreement/disagreement behavior |
| `bubbles/eval/schemas/adversarial-sample.schema.json` (new) | `bubbles.implement` | per-sample provenance and finding contract |
| `agents/bubbles.redteam.agent.md`, `agents/bubbles_shared/agent-common.md` | `bubbles.redteam` / framework governance owner | truthful behavior and terminology |
| `bubbles/workflows.yaml`, relevant project-config examples | `bubbles.workflow` / `bubbles.super` | remove unimplemented cross-model phase claims; expose sample semantics |
| `docs/recipes/adversarial-verification.md`, `docs/recipes/cross-model-review.md`, `docs/guides/AGENT_MANUAL.md`, `docs/guides/WORKFLOW_MODES.md` | `bubbles.docs` | public contract and migration guidance |
| generated checksums/manifest affected by this scope | `bubbles.releases` | independent landing freshness |

### S2 Tests

- Assert `passes: 3` compatibility resolves to `samples=3` plus deprecation metadata, while new output never labels those samples independent.
- Feed the aggregator unanimous-clear, unanimous-finding, divergent, partial-error, duplicate-finding, and reordered-finding fixtures.
- Assert disagreement preserves the union and per-sample matrix and cannot be converted to clear by a majority.
- Add a source regression scan that rejects active claims of N independent same-runtime validators or implemented cross-model execution without a verified adapter registration.
- Exercise risk-based sample count selection and configured maximums without hardcoding an agent roster.

### S2 Acceptance Criteria

- A live `samples: 3` run records three actual sample invocations or fails; resolving a count alone is not completion.
- Same-runtime results are always labeled correlated samples.
- Any divergent blocking result escalates deterministically; no majority path drops it.
- Public docs contain no claim that current VS Code subagents provide model/tool independence.
- Cross-model review is not advertised as executable until a later adapter proves distinct provider/model provenance.

## S3 — Untrusted-Content And Tool Trust Boundary (AF-005)

**Depends on:** S2.

### S3 Implementation

- Add a shared untrusted-content policy with an explicit data-versus-instruction rule: repository content, diffs, issues, web pages, browser DOM, tool output, MCP output, logs, and retrieved documents are data unless they come from a declared trusted policy channel. Text inside data cannot authorize tools, change scope, request secrets, weaken gates, or override system/developer/agent/repo instructions.
- Add a versioned machine-readable tool trust registry. Each tool/server/operation declares source, trust state, risk class, read/write capability, egress capability, permitted data classes, approval requirement, and whether the host can enforce the decision.
- Default-deny unregistered MCP servers for sensitive operations. Project MCP grants must name a registered server and allowed operation classes; a token merely present in `.vscode/mcp.json` is not sufficient trust.
- Extend the canonical pre-tool decision path to consume a structured event (`tool`, `server`, `operation`, normalized target, argument classes, data classes, egress destination, and requested side effects). Unknown operations do not default to `read_only`.
- Replace blanket `--confirm` / `BUBBLES_RISK_CONFIRM=1` for sensitive mutation or egress with an action-bound approval contract. It binds approval to tool, target, operation, data class, destination, expiry, and request hash. A host-native approval callback is required to call it human-approved. If the host cannot provide that callback, sensitive execution remains blocked; Bubbles does not simulate human approval.
- Never place secret values in trust events, approvals, logs, or fixtures. Decisions operate on classifications and presence metadata only.
- Add prompt-injection regressions containing malicious repository prose, web/DOM text, and MCP results that instruct the agent to ignore policy, expose secrets, broaden scope, or invoke a sensitive tool.
- Minimize tool grants where the host permits it, but preserve the documented VS Code inheritance constraint: removing `edit` from a parent orchestrator also removes it from workers. Tool minimization must be task-sensitive and tested, not a static committee/tool list.

### Enforceability Matrix

| Surface | Framework guarantee after S3 |
| --- | --- |
| Bubbles CLI and Bubbles MCP operations routed through the canonical gate | Machine-enforced registry decision; sensitive unknowns block. |
| Declared MCP grants and registered server IDs | Machine-linted allowlist and operation/data-class policy. |
| Host event carrying full ambient tool metadata | Machine-enforced only when the host actually invokes the Bubbles pre-tool contract. |
| Ambient VS Code edit/shell/web/browser tools not passed through the hook | Not interceptable by Bubbles alone. Agent policy, least privilege, S5 behavior tests, and native host controls are the available defenses; documentation MUST say this. |
| Malicious instructions embedded in tool results | Marked untrusted and covered by policy/behavior regressions, but no claim of perfect prompt-injection prevention. |

### S3 Files And Owners

| Files | Owner | Responsibility |
| --- | --- | --- |
| `agents/bubbles_shared/untrusted-content.md` (new), `agent-common.md` | `bubbles.security` | authoritative data/instruction and egress policy |
| `bubbles/tool-trust-registry.yaml`, `bubbles/schemas/tool-trust-registry.schema.json` (new) | `bubbles.security` / `bubbles.implement` | machine-readable trust contract |
| `bubbles/scripts/pre-tool-risk-gate.sh`, `pre-tool-risk-gate-selftest.sh`, `bubbles/hooks.json` | `bubbles.implement` / `bubbles.test` | structured event decision and fail-closed compatibility path |
| `bubbles/scripts/mcp-grant-reconcile.sh`, `mcp-grant-sync.sh`, their selftests | `bubbles.devops` / `bubbles.test` | trusted MCP registration and grant reconciliation |
| orchestrator frontmatter lint and affected agent policy references | framework governance owner / `bubbles.test` | task-sensitive grants without breaking subagent inheritance |
| `docs/MCP.md`, `docs/guides/AGENT_MANUAL.md`, security/trust recipe | `bubbles.docs` / `bubbles.security` | operator setup, approval, and host-limit documentation |
| generated checksums/manifest affected by this scope | `bubbles.releases` | independent landing freshness |

### S3 Tests

- Registry schema: clean registry, unknown server, unknown operation, stray trust state, undeclared egress, and secret-like value rejection.
- Gate fixtures: read-only trusted call, owned mutation, sensitive egress, unknown ambient event, mismatched/expired/replayed approval, destination change, argument hash change, and legacy `--confirm`/env bypass rejection for sensitive classes.
- MCP fixtures: registered trusted server, unregistered server, grant outside allowed operation class, and materialized downstream server token round-trip.
- Injection fixtures: malicious README, issue text, web/DOM body, and MCP result must not become an authorization record or trusted instruction source.
- Host-limit tests assert `enforcement: unavailable` rather than pass when ambient metadata or native approval is absent.

### S3 Acceptance Criteria

- The trust registry is schema-valid, default-deny for sensitive unknowns, and consumed by a real guard path.
- Sensitive mutation/egress cannot be unlocked by a generic flag or environment variable.
- Trusted MCP use requires both registration and operation-level authorization.
- Injection fixtures produce no sensitive tool authorization or data-egress event.
- Documentation precisely separates machine-enforced, host-dependent, and policy-only protections.

## S4 — Effective Prompt Bundle Compiler And Complexity Telemetry (AF-006)

**Depends on:** S3.

### S4 Implementation

- Add a compiler that resolves the effective instruction bundle for an agent, mode, phase, and task. Inputs include the agent body, referenced shared modules, applicable instruction files, activated skills, resolved workflow/template constraints, project policy, tool allowlist, MCP grants, and tool descriptions supplied by the host inventory.
- Emit a deterministic manifest containing ordered sources, unresolved sources, duplicate directives, source hashes, aggregate bytes/lines/directive counts, optional tokenizer-specific token count, tool count, tool-description bytes/tokens, phase count, candidate specialist count, and a complete/incomplete status.
- Never guess unavailable tool descriptions or token counts. Missing host inventory or tokenizer data is `null`/`incomplete`, not zero. Strict lint mode fails closed when a claimed complete bundle lacks either.
- Extend instruction-budget lint to evaluate the compiled bundle. Keep per-file output for diagnosis, but do not use it as the effective-budget verdict.
- Detect load cycles, conflicting duplicate instructions, unreachable module references, repeated full-text policy loads where a pointer would suffice, and mode/phase expansion that exceeds configured empirical limits.
- Emit phase/task complexity telemetry into framework events: resolved mode, phase count, specialists actually invoked, retries, tool calls, compiled prompt hash, tool inventory hash, bundle size, and completion outcome.
- Land S4 numeric size thresholds in report-only mode. S5 calibrates regression thresholds against outcome/cost; only then may S7 activate blocking limits.

### S4 Files And Owners

| Files | Owner | Responsibility |
| --- | --- | --- |
| `bubbles/scripts/prompt-bundle-compile.sh`, `prompt-bundle-compile-selftest.sh` (new) | `bubbles.implement` / `bubbles.test` | deterministic load graph and manifest |
| `bubbles/schemas/effective-prompt-bundle.schema.json` (new) | `bubbles.implement` | compiler output contract |
| `bubbles/scripts/instruction-budget-lint.sh`, `instruction-budget-lint-selftest.sh` | `bubbles.implement` / `bubbles.test` | effective-bundle lint and legacy diagnostics |
| workflow/runtime event emitters and event schema | `bubbles.workflow` / `bubbles.devops` | phase/task complexity telemetry |
| `agents/bubbles_shared/agent-common.md`, prompt-loading docs | framework governance owner / `bubbles.docs` | canonical load semantics and interpretation |
| generated checksums/manifest affected by this scope | `bubbles.releases` | independent landing freshness |

### S4 Tests

- Compile `bubbles.workflow` and `bubbles.validate` with shared modules and assert aggregate counts exceed or equal their per-file counts; no source is silently omitted.
- Resolve `full-delivery` and assert the manifest records its actual resolved phase list rather than a hardcoded expected total.
- Cover module cycles, duplicate references, conflicting directives, missing tool inventory, missing tokenizer, unknown skill, mode inheritance, and stable hashes under stable input.
- Prove tool-description text contributes to bundle size when supplied.
- Prove incomplete telemetry remains null/incomplete and cannot be interpreted as a zero-cost run.

### S4 Acceptance Criteria

- One command produces a reproducible effective-bundle manifest for an agent/mode/phase/task tuple.
- The lint verdict is based on the aggregate loaded bundle, not isolated files.
- Tool descriptions and MCP grants are included when available and explicitly missing when unavailable.
- Every benchmarkable workflow run can carry prompt/tool hashes and phase/task complexity fields consumed by S5.
- S4 introduces no uncalibrated blocking numeric threshold.

## S5 — Held-Out Executable Agent Benchmark And Regression History (AF-004, AF-006)

**Depends on:** S1 through S4.

### S5 Implementation

- Add a benchmark runner that executes agent strategies against isolated temporary repositories/tasks and grades the resulting end state with an oracle unavailable to the acting agent.
- Separate public harness smoke fixtures from certification tasks. A certification task pack must be injected from outside the agent-readable workspace, identified by content hash, and executed in a runner isolation boundary that prevents reading the oracle. If the host cannot enforce that boundary, the run is `non-certifying`.
- For every applicable task stratum, compare the same three strategy classes under the same model, tool inventory, task input, time budget, and environment:
  1. **simple baseline:** inspect/plan -> implement/test -> verify outcome;
  2. **focused mode:** the smallest registered mode whose declared capabilities satisfy the task/risk contract;
  3. **full-delivery:** the resolved 18-phase maximum-assurance mode.
- Route by task characteristics and required capabilities, not by a fixed agent committee. Record why the focused mode was the simplest adequate choice.
- Run repeated trials as samples. Report `pass@1` and strict empirical `pass^k` (the proportion of tasks for which all `k` sampled trials pass). Do not infer statistical independence from repeated same-runtime calls.
- Grade primarily with executable end-state oracles and forbidden-side-effect checks. Trace grading is secondary and cannot turn a failed end state into a pass.
- Record the requested MAST failure taxonomy using a vendored, versioned mapping tied to its canonical source. Do not invent unlabeled local categories; store taxonomy version and category code with every classified failure.
- Capture, when the host supplies them: wall latency, model-reported input/output tokens, tool calls by class, estimated cost with rate-card/version, retries, sample count, and human interventions. Missing metrics are `null` with availability reasons, never zero.
- Record provenance: framework commit, task-pack hash, strategy/mode, model/provider identity and verification state, effective prompt hash, tool inventory/description hash, trust-registry hash, evaluator/oracle hash, environment fingerprint, and trial seed.
- Maintain append-only baseline history. Regression comparisons require compatible task-pack and provenance strata; latency/cost comparisons require compatible environment/rate-card metadata.
- Predeclare thresholds per task stratum. At minimum:
  - any forbidden side effect is blocking;
  - outcome `pass^k` may not regress beyond the recorded tolerance against the same strategy's compatible baseline;
  - a more complex strategy is not preferred unless it improves outcome/reliability or satisfies a required risk control that the simpler strategy lacks;
  - `full-delivery` does not become the default winner merely because it invokes more phases.

### S5 Files And Owners

| Files | Owner | Responsibility |
| --- | --- | --- |
| `bubbles/scripts/agent-benchmark.sh`, `agent-benchmark-selftest.sh` (new) | `bubbles.implement` / `bubbles.test` | isolated trial runner, aggregation, provenance, failure behavior |
| `bubbles/eval/schemas/benchmark-task.schema.json`, `benchmark-run.schema.json` (new) | `bubbles.implement` | task, oracle, metrics, and result contracts |
| `bubbles/eval/strategies/simple-three-stage.yaml`, `focused-mode.yaml`, `full-delivery.yaml` (new) | `bubbles.workflow` / `bubbles.test` | comparable strategy definitions without fixed committees |
| `bubbles/eval/mast-taxonomy.yaml` (new) | `bubbles.audit` / `bubbles.docs` | sourced, versioned failure taxonomy mapping |
| `bubbles/eval/baselines/history.jsonl`, current-baseline index (new) | `bubbles.validate` / `bubbles.releases` | append-only verified score history and promotion pointer |
| `bubbles/eval/README.md`, benchmark operator recipe | `bubbles.docs` | certifying vs smoke runs, metric limitations, interpretation |
| `bubbles/scripts/framework-validate.sh`, CLI benchmark command, release check integration | `bubbles.devops` / `bubbles.releases` | cheap hermetic selftest always; explicit certifying benchmark for behavioral release |

### S5 Tests

- Hermetic fake-agent adapters cover end-state pass/fail, forbidden side effect, oracle hidden/unhidden, timeout, crash, missing trace, missing cost/token metrics, and incompatible provenance comparison.
- Repeated-trial fixtures verify `pass@1`, strict empirical `pass^k`, sample error handling, and no independence label.
- Strategy fixtures prove simple/focused/full run against identical task input and budgets and that routing chooses the simplest capability-sufficient mode.
- Trace grader fixtures prove a cosmetically correct trace cannot override a failed end-state oracle.
- Baseline fixtures cover append-only history, task-pack/model/prompt/tool hash changes, threshold regression, environment mismatch, and rate-card mismatch.
- MAST fixtures require a known taxonomy version/category or explicit `unclassified`; no silent category invention.

### S5 Acceptance Criteria

- At least one held-out executable bug-fix task, feature task, and prompt-injection/tool-trust task run through all three strategy classes for the initial approved baseline.
- Every certifying run has an isolated oracle, end-state verdict, forbidden-side-effect verdict, repeated-trial metrics, failure taxonomy, and complete provenance or is rejected as non-certifying.
- Baseline history supports before/after regression comparison and cannot be rewritten by the normal runner.
- The initial report states which task strata justify focused/full orchestration and where the simple baseline is equal or better.
- Framework release policy blocks outcome regressions according to predeclared compatible-baseline thresholds, not raw phase count.

## S6 — Downstream Forecast-Evaluation Profile (FIN-001)

**Depends on:** S1 and S5 contracts.

### S6 Implementation

- Add an optional, product-agnostic `forecast-evaluation` profile schema and example. The core profile describes evaluation inputs and invariants; it does not select a vendor, security, model, portfolio, or trading policy.
- Require point-in-time data fields: forecast issue time, target horizon, observation/event time, availability/release time, vintage/revision identifier, evaluation `asOf`, and data-source provenance. Historical evaluation must use the value available as of the forecast decision, not the latest revised value.
- Support ALFRED-style vintage datasets through generic vintage/release fields and a documented adapter example. “ALFRED-style” describes revision-aware shape; the core does not call an external service.
- Require proper scoring configuration for probabilistic forecasts. Provide reference Brier and logarithmic score calculations with directionality and numerical clipping policy declared in the profile.
- Require calibration reporting with predeclared binning/method, sample counts, confidence/uncertainty treatment, and an aggregate calibration measure. Small or empty regime/bin results remain explicit, not silently dropped.
- Support optional decision simulation. When enabled, require predeclared fees, spread, slippage, market-impact assumption, turnover, execution timing, and no-cost comparator. Forecast quality and decision P&L remain separate reported dimensions.
- Require predeclared regime slices and minimum sample rules. Regimes may diagnose robustness but cannot replace the all-sample score or be selected after seeing results without being labeled exploratory.
- Require leakage controls: train/evaluation cutoff, feature availability as of issue time, label availability, embargo/purge where overlapping horizons apply, revision freeze, entity split policy, and explicit rejection of look-ahead/latest-vintage substitution.
- Provide a synthetic revision-aware fixture with known Brier/log/calibration results and adversarial future-vintage/leakage fixtures. No proprietary or product data enters the framework repo.

### S6 Files And Owners

| Files | Owner | Responsibility |
| --- | --- | --- |
| `bubbles/eval/profiles/forecast-evaluation.schema.json` (new) | `bubbles.analyst` / `bubbles.implement` | generic profile contract and executable validation shape |
| `bubbles/eval/profiles/forecast-evaluation.example.yaml` (new) | `bubbles.docs` / `bubbles.test` | ALFRED-style vintage example with synthetic data references |
| `bubbles/eval/profiles/forecast-score-reference.py`, profile validator/selftest (new) | `bubbles.implement` / `bubbles.test` | proper-score reference and invariant regressions |
| `bubbles/eval/fixtures/forecast/**` (new) | `bubbles.test` | known-score, revision, regime, cost, and leakage fixtures |
| `docs/recipes/downstream-forecast-evaluation.md` (new) | `bubbles.docs` | downstream adapter and interpretation guidance |
| generated checksums/manifest affected by this scope | `bubbles.releases` | independent landing freshness |

### S6 Tests

- Known-value Brier and log-score examples, including probability boundaries and declared clipping.
- Point-in-time positive fixture and negative latest-revision/future-vintage fixture.
- Calibration bins with empty/small bins, minimum samples, and aggregate count reconciliation.
- Decision simulation with and without declared transaction costs; cost-free results cannot be mislabeled net results.
- Regime totals reconcile to the declared population and post-hoc regimes are labeled exploratory.
- Leakage fixtures cover future feature availability, overlapping horizons without required embargo/purge, label leakage, and train/eval entity contamination.
- Agnosticity lint confirms no product identifier, symbol, proprietary path, or product acceptance threshold is embedded in core.

### S6 Acceptance Criteria

- A downstream repo can declare and validate a revision-aware forecast profile without changing a core gate.
- The future-vintage/leakage fixture fails while the point-in-time synthetic fixture yields the known proper scores.
- Forecast score, calibration, and optional net decision result are distinct outputs with declared assumptions.
- The example covers vintage data, Brier/log scores, calibration, transaction costs, regimes, and leakage controls.
- Core remains product-agnostic and network-independent.

## S7 — Documentation, Ledger, Generated Artifacts, Validation, And Release (all findings)

**Depends on:** S1 through S6.

### S7 Implementation

- Reconcile public claims with implemented behavior. Remove stale “independent validator”, cross-model execution, fail-open judge, regex-as-quality, and blanket pre-tool protection language.
- Document task-sensitive routing, simplest-adequate-baseline comparison, host enforcement limits, metric availability/null semantics, certifying benchmark isolation, and downstream forecast-profile boundaries.
- Add or update capability-ledger entries only for capabilities that have real executable consumers. Proposed/partial surfaces remain labeled accordingly; no capability is marked shipped from prose alone.
- Reconcile README, agent manual, workflow/evaluation/security recipes, catalog/cheatsheet sources, capability ledger, changelog, version/release notes, generated docs, framework stats, checksums, and release manifest.
- Add focused selftests to `framework-validate`; keep expensive repeated held-out trials in an explicit benchmark command whose current signed/hashed result is required by release policy for behavior-affecting evaluator/orchestration changes.
- Run canonical framework validation and release readiness after generated reconciliation. Record actual command evidence during implementation; this proposal contains no fabricated pass claim.

### S7 Files And Owners

| Files | Owner | Responsibility |
| --- | --- | --- |
| `README.md`, `docs/CATALOG.md`, `docs/guides/AGENT_MANUAL.md`, `docs/guides/WORKFLOW_MODES.md`, eval/adversarial/trust recipes | `bubbles.docs` | one truthful public contract |
| `bubbles/capability-ledger.yaml` | capability owner + `bubbles.audit` | state/consumer/provenance reconciliation |
| `CHANGELOG.md`, `VERSION`, release notes | `bubbles.releases` | release narrative and version decision |
| `bubbles/cheatsheet/*.json`, `docs/CHEATSHEET.md`, `docs/its-not-rocket-appliances.html`, `docs/generated/**`, framework stats/checksums | `bubbles.docs` / generators | generated parity |
| `bubbles/release-manifest.json`, `bubbles/scripts/framework-validate.sh`, `release-check.sh` | `bubbles.releases` / `bubbles.devops` | freshness and final release gates |

### S7 Tests And Validation

- Run every focused selftest introduced in S1-S6.
- Run source scans for stale independence/cross-model/fail-open/blanket-trust claims, allowing only historical or explicitly unsupported-context discussion.
- Run generated-artifact freshness checks through the canonical regeneration path.
- Execute `bash bubbles/scripts/cli.sh framework-validate`.
- Execute the explicit certifying benchmark command with the approved held-out task-pack hash and record its evidence.
- Execute `bash bubbles/scripts/cli.sh release-check` after all generated artifacts are current.

### S7 Acceptance Criteria

- Public docs, agent contracts, registries, schemas, executable behavior, and generated surfaces describe the same semantics.
- Every shipped ledger capability has a real consumer and current validation provenance.
- The approved held-out baseline/regression artifact is current for the release's framework, prompt, tool, evaluator, and task-pack hashes.
- `framework-validate` and `release-check` both complete successfully with current-session evidence before release status is claimed.
- No implementation scope remains deferred or represented only by documentation.

## Rollout

1. Land S1 with task-schema versioning and update the two bundled tasks atomically. Existing unversioned tasks may be read through a documented compatibility parser, but quality-critical use requires v2 semantics.
2. Land S2 with the `passes` -> `samples` compatibility alias and an announced removal release. Remove unsupported independence/cross-model execution claims immediately; compatibility does not preserve false terminology.
3. Land S3 in two enforcement tiers: first registry/schema/lint plus structured decisions, then blocking for Bubbles-routed sensitive operations once positive and negative fixtures pass. Unsupported ambient host surfaces stay visibly unavailable.
4. Land S4 telemetry-first. Collect effective bundles and complexity without activating guessed numeric limits.
5. Land S5 runner/selftests, then execute the first certifying held-out baseline. Activate regression thresholds only from the approved baseline and compatible provenance strata.
6. Land S6 as an optional downstream profile. It changes no default workflow or core product gate.
7. Land S7 reconciliation and release only after S1-S6 focused checks and the held-out benchmark are green.

## Rollback

- Every scope lands as a separate reversible commit with schema-version compatibility documented.
- Rollback never restores a known false-positive/fail-open path. If S1 must be reverted, quality-critical evaluation becomes explicitly unavailable/nonzero until repaired; it does not fall back to the old silent judge behavior.
- If S2 aggregation misbehaves, reduce to one labeled same-runtime sample and disable aggregation. Do not restore independent-vote claims.
- If S3 blocks valid work, revert the affected registry rule to report-only for non-sensitive operations. Sensitive unknown mutation/egress remains blocked; no generic env/flag bypass is reintroduced.
- If S4 compilation is incomplete on a host, retain per-file diagnostics and mark the effective verdict unavailable. Do not treat missing tool/module data as zero.
- Benchmark history is append-only. Roll back by moving the approved-baseline pointer to the prior compatible entry and appending a correction record, never by rewriting prior results.
- S6 is opt-in and can be removed without changing core task evaluation; downstream profiles pin their schema version until migrated.
- S7 release rollback is a normal version/artifact pointer rollback and must preserve the evidence/history records for the withdrawn release.

## Risks And Mitigations

- **R1 — semantic judges add nondeterminism and bias.** Keep executable end-state oracles primary, require judge provenance, run repeated samples, and never let a semantic score override a failed required oracle.
- **R2 — executable task manifests become a command-injection surface.** Use schema-validated argv, approved oracle roots, isolated workspaces, explicit timeouts, and no task-provided `shell=True`.
- **R3 — “human approval” is fabricated by an agent.** Require a host-native action-bound approval callback; without one, classify the control unavailable and keep sensitive work blocked.
- **R4 — prompt compiler overstates what the host loaded.** Emit ordered source provenance and `complete: false` for missing instruction/tool inventory; strict claims fail closed.
- **R5 — benchmark tasks leak into model context.** Separate public smoke fixtures from externally injected held-out packs and reject certifying status when oracle isolation cannot be proven.
- **R6 — cost/latency comparisons mix incompatible environments.** Compare only compatible provenance strata and preserve raw availability/environment metadata.
- **R7 — benchmark overfits one task family.** Stratify tasks by work/risk type, retain held-out rotation, and report per-stratum results rather than one flattering aggregate.
- **R8 — forecast profile becomes finance product logic.** Keep only generic temporal/scoring/leakage contracts in core; all data adapters, policies, costs, regimes, and thresholds are downstream declarations.
- **R9 — added controls increase prompt/tool complexity.** Measure the effective bundle and require S5 evidence that complexity improves outcomes or enforces a necessary risk control.

## Definition Of Implementation Complete

IMP-020 is implemented only when S1-S7 acceptance criteria are met, the supplied adversarial false positives have durable negative regressions, same-runtime samples are no longer called independent, trust limitations are explicit and machine-readable, effective bundle telemetry feeds a held-out baseline comparison, the generic forecast profile passes its synthetic point-in-time tests, public/generated surfaces are reconciled, and current-session `framework-validate` plus `release-check` evidence is recorded.

Approval authorizes implementation; it does not constitute implementation evidence.
