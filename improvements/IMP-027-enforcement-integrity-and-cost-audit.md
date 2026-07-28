# IMP-027 — Enforcement Integrity, Ungoverned Surfaces, and Context-Cost Audit

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of `bubbles/*` until approved
**Motivation:** Full-repository audit of v7.21.0 @ `f58fd5dd`. Every claim below was verified against a real file/line or a command executed against the tree.
**Verified gaps addressed:** EV-1, EV-2, EV-3, SEC-1, SEC-2, SEC-3, COST-1, COST-2, PERF-1

---

## Root cause

Every structural defect below reduces to one pattern:

> **Bubbles enforces the surfaces it remembers to enumerate, and enumeration is manual everywhere.**

Coverage was **asserted from hand-written lists** rather than **derived from the file surface** — the same epistemic failure the framework forbids in agents. The delivered coverage work removed that cause; the remaining scopes close what it already let through.

---

## Problem (verified against source)

### Evidence integrity

- **EV-1 — prose-only evidence is accepted, contradicting the README's headline claim.** [`README.md:46`](../README.md) states: *"every Definition-of-Done item must carry raw, captured command output (real exit codes, real test counts). A narrative 'all tests pass' with no terminal output is rejected as fabrication, not accepted as proof."* The guard does not do this. Two independent code paths accept a ≥10-non-blank-line block with **no** command-output signature and increment `checked_with_evidence`:
  - `bubbles/scripts/state-transition-guard.sh:2440-2445` — anchor-resolved path (`report.md#anchor`)
  - `bubbles/scripts/state-transition-guard.sh:2555-2562` — inline-block path

  `check9_advisory_count` appears at lines 2288, 2444, 2559, 2586 and is **only ever incremented and reported** — no conditional converts it to a failure, and no env var or `.github/bubbles-project.yaml` key flips it. The permissive behavior is additionally **pinned by test**: `bubbles/scripts/evidence-admission-hardening-selftest.sh:19` asserts *"#3 (ADVISORY, non-blocking) resolved >=10-line block with no command-output signature -> ACCEPTED + advisory"*. The in-code comment concedes the gap ("would-fail count under a future blocking command-output policy; IMP-102 SCOPE-1 R1 advisory"); the README does not.

- **EV-2 — the sound receipt rail exists but is the fallback, not the enforced path.** `bubbles/scripts/tool-log.sh` wraps a command, streams output through, and appends a JSONL receipt carrying a sha256 `inputClosure`; `bubbles/scripts/evidence-receipt-check.sh` performs targeted VALID/STALE/UNKNOWN invalidation over those receipts. This is provenance-grade evidence and is the correct mechanism. However it is **case 4** in the acceptance chain (`state-transition-guard.sh:2563-2571`), reached only after three markdown paths, and `evidence-receipt-check.sh` is wired into `framework-validate.sh:406` **only via its selftest** — the live check never runs against a real log in the transition path. Nothing requires an agent to call `tool-log.sh` at all.

- **EV-3 — anti-fabrication verdicts rest on lexical proxies.** `≥10 non-blank lines` = evidence (padding satisfies it); `≥80% similarity` = clone detection (79% passes); G068 matches DoD↔Gherkin by ≥3-word overlap after stripping words <4 chars plus a hardcoded stopword list. The maintainer's own [`docs/issues/G068-word-overlap-threshold.md`](../docs/issues/G068-word-overlap-threshold.md) documents that this strips domain-critical short tokens (`API`, `UI`, `DB`, `key`, `log`) and scenario-defining words (`user`, `system`, `should`), producing **false-positive failures on legitimate DoD items**. False positives are corrosive: they train operators to distrust gates, which is the exact erosion the framework exists to prevent.

### Security / supply chain

- **SEC-1 — installer payload verification fails open when the verifier file is absent.** `install.sh` guards the integrity check with `if [[ -f "$PAYLOAD_VERIFIER" ]]; then ... fi` and **no `else` branch** (verified: the block's only `else` belongs to the inner `if bash "$PAYLOAD_VERIFIER" ...` invocation). The stated rationale is backward compatibility ("guard on its presence so an older payload lacking it never breaks the install"). Consequence: **omitting one file (`bubbles/scripts/verify-payload-integrity.sh`) from the downloaded tarball silently disables integrity verification for the entire install**, and the install proceeds and reports success. The verifier is itself listed in `bubbles/release-manifest.json`, but only the verifier can check that — a circular bootstrap dependency.

- **SEC-2 — ten non-selftest guards `exit 0` on undeclared dependencies.** [`README.md`](../README.md) states *"No dependencies beyond `curl` and `bash` 4.0+."* In practice these silently pass when a dependency is missing: `result-envelope-validate.sh:149,171` (python3, **jsonschema**), `yaml-schema-validate.sh:20,25` (python3, PyYAML, jsonschema), `diff-evidence-guard.sh:57,65` (git, python3), `evidence-tool-log-bridge.sh:85` (python3 — this is the receipt bridge itself), plus `generate-gate-coverage-map.sh`, `generate-gates-block.sh`, `generate-modes-block.sh`, `mode-family-inventory.sh`, `model-tier-advisory.sh`, `parallel-fanout.sh`. `jsonschema` and `PyYAML` are **not** stdlib and are not declared install requirements. A guard that skips is a guard that lies. `bubbles/scripts/eval-harness.sh` already implements the correct fail-closed posture and should be the model.

- **SEC-3 — G034 `security_gate` is a phantom.** Classified as one of only six `businessInvariant` gates in `bubbles/workflows.yaml::gateClassification`. Verified references: it appears in `bubbles/registry/gates.yaml` (definition), `bubbles/workflows.yaml` (4 occurrences: definition + `requiredGates`), and `docs/CHEATSHEET.md:404` (a doc table). It has **no enforcer script, and is not referenced by any agent — including `bubbles.security.agent.md`**. Its entire enforcement is "appears in a mode's `requiredGates` list", i.e. an LLM reading YAML.

### Cost and performance

- **COST-1 — the most-invoked agent carries the largest context bundle, cost is untracked, and the budget mechanism institutionalizes the bloat.** Measured with `bubbles/scripts/effective-bundle-measure.sh` (transitive `agents/bubbles_shared/*.md` closure):

  | Agent | Bytes | Files | ≈ Tokens |
  |---|---|---|---|
  | **bubbles.workflow** (orchestrator) | **501,643** | 42 | **~125,400** |
  | bubbles.security | 381,714 | 36 | ~95,400 |
  | bubbles.setup | 386,877 | — | ~96,700 |
  | bubbles.simplify | 382,563 | — | ~95,600 |
  | bubbles.iterate | 257,424 | — | ~64,400 |
  | Median agent | 132,912 | — | ~33,200 |
  | **All 41 summed** | **5,712,084** | — | **~1,428,000** |

  Heaviest shared modules inside the orchestrator closure: `project-config-contract.md` (59,685 B), `scope-workflow.md` (48,886 B), `operating-baseline.md` (30,869 B), `feature-templates.md` (22,401 B).

  Meanwhile `bubbles/workflows.yaml::metrics.enabled` is `false` by default, and `tokenCount` / `dollarCost` are explicitly excluded with the (correct, honest) reasoning *"Not exposed by VS Code Copilot API"* / *"Derived from unknown tokens = fabricated"*. The framework is therefore structurally blind to its dominant cost.

  `bubbles/scripts/agent-bundle-size-budget.sh` is self-described as a *"ratcheting PER-AGENT effective-bundle size budget"* whose `--seed` sets ceilings from **current** size. It prevents regression but cannot drive reduction: today's bloat becomes tomorrow's floor. Current check output: `OK — all 41 agent bundle(s) within their recorded ceilings`.

- **COST-2 — the fix for COST-1 is already designed but permanently blocked by a missing eval corpus.** [`agents/bubbles_shared/operating-baseline.md:88-110`](../agents/bubbles_shared/operating-baseline.md) identifies the exact remedy (move the three heavy authoring modules out of the router's always-loaded closure into phase `*-bootstrap.md` profiles — *"≈ 123 KB / ~25% of the closure"*) and then gates it: *"A repo MUST validate, via a held-out evaluation showing **zero gate-detection regression**... `framework-validate` cannot substitute for that eval — it exercises scripts and selftests, not LLM routing behavior."* That is methodologically correct. But `bubbles/eval/fixtures/` contains **only negative fixtures that test the harness itself** (`oracle-timeout.json`, `malformed-task.json`, `invalid-schema.json`, `missing-oracle.json`, …). There are no golden delivery tasks. The reduction is opt-in, default-off, and gated on a capability that was never built, so it will never activate.

- **PERF-1 — validation is O(everything), sequential, and uncached.** Measured: `framework-validate.sh --tier=core` took **260 seconds** to run **16 of 209** checks. The full tier is what pre-push and `release-check` run (no flag). `grep` for `--since`, changed-files filtering, or result caching in `framework-validate.sh` returns nothing. `bubbles/scripts/parallel-fanout.sh` exists — and is referenced only by its own determinism selftest and one doc. The framework built a parallelism primitive and never applied it to its own largest cost centre. A ~25-minute serial pre-push is the single strongest incentive toward the bypass behavior the framework exists to prevent.

---

## Proposal

Scopes are ordered by (severity × cheapness).

### SCOPE-3 — Make receipt-backed evidence the primary rail (EV-1, EV-2)

- Introduce `evidenceMode: receipt-required | receipt-preferred | markdown-ok` in `.github/bubbles-project.yaml`, defaulting to `receipt-preferred` (behavior-preserving). Done-ceiling modes (`full-delivery` and any mode whose `statusCeiling` is `done`) bind `receipt-required`.
- Under `receipt-required`, invert the `state-transition-guard.sh` Check-9 chain so the tool-log path is evaluated **first** and markdown-only evidence fails rather than advises. Update `evidence-admission-hardening-selftest.sh:19`, which currently pins the permissive behavior, and add a red fixture proving prose-only fails under `receipt-required`.
- Wire `evidence-receipt-check.sh --strict` into the transition path (today it is reachable only through its selftest at `framework-validate.sh:406`).
- **Cheapest high-yield step:** because project terminal-discipline already funnels all commands through a single project CLI, wrapping that one entrypoint in `tool-log.sh` makes every gate-relevant command receipted at near-zero authoring cost. Document this as the recommended adoption path.
- **Immediate, independent of the above:** reconcile `README.md:46` with the code. Either ship the blocking mode or amend the sentence. The gap between the advertised guarantee and `state-transition-guard.sh:2440-2445`/`:2555-2562` is the framework's single largest credibility risk.

### SCOPE-4 — Fail closed on missing dependencies (SEC-1, SEC-2)

- **SEC-1:** add an `else` branch to the `if [[ -f "$PAYLOAD_VERIFIER" ]]` block in `install.sh` that **fails the install** when the verifier is absent, gated on the release manifest declaring a `payloadVerifierRequired: true` capability (so genuinely older payloads still install, but any manifest from this version forward cannot silently skip verification). A missing verifier in a manifest that declares it is a tampering signal, not a compatibility case.
- **SEC-2:** declare the real dependency set (`bash>=4`, `git`, `jq`, `python3`, `PyYAML`, `jsonschema`) in `README.md` and surface it in `cli.sh doctor`. Convert the 10 non-selftest `SKIP → exit 0` paths to exit non-zero when the check is required, with a single logged `BUBBLES_ALLOW_DEGRADED=1` opt-out that `doctor` reports as a degraded posture. Selftests may retain SKIP; guards may not. Model the change on `bubbles/scripts/eval-harness.sh`, which already fails closed correctly.
- **SEC-3:** either implement a real enforcer for G034 `security_gate` (dependency-audit + severity-threshold script invoked from the validate phase), or reclassify it out of `businessInvariant` and mark it `behavioral:bubbles.security` under the `enforcedBy` vocabulary — and add the corresponding reference to `agents/bubbles.security.agent.md`, which today does not mention it. **Recommendation: implement the enforcer**; a `businessInvariant` security gate with no mechanical surface is the weakest link in the six-gate invariant set.

### SCOPE-5 — Build the golden-task eval corpus (COST-2)

The keystone: the harness is built and already fails closed; only the corpus is missing.

- Author 10–20 versioned golden tasks under `bubbles/eval/tasks/` using the existing `task-v2.schema.json`, with `executable-oracle` checks so scoring is deterministic. Minimum coverage:
  - a bug fix requiring an **adversarial** regression test,
  - a vertical-slice feature (frontend + backend + E2E),
  - a stale-spec reconcile,
  - a **fabrication-bait** task where the correct outcome is an honest gap (`[ ]` + Uncertainty Declaration) — this directly tests the Honesty Incentive, which is currently unmeasured,
  - a task whose correct outcome is `blocked`.
- Add `bubbles eval run --suite bubbles/eval/tasks` to `cli.sh` and report the aggregate in `doctor`.
- This unblocks SCOPE-6, enables model-upgrade regression detection, and — most importantly — makes it possible to **measure whether each 20 KB of governance prose actually buys compliance**, which is currently an article of faith.

### SCOPE-6 — Reduce and measure context cost (COST-1)

- Execute the already-designed phase-local split from `operating-baseline.md:88-110`: move `project-config-contract.md`, `scope-workflow.md`, and `feature-templates.md` out of the orchestrator's always-loaded closure into the `*-bootstrap.md` phase profiles. Validate with the SCOPE-5 corpus showing zero gate-detection regression. Target: orchestrator effective bundle **≤ 40 K tokens** (from ~125 K).
- Change `agent-bundle-size-budget.sh` from pure ratchet to **ratchet + target**: add `effectiveBundleTargetBytes` per role class (router / owner / diagnostic) and report distance-to-target in `doctor`. A ceiling seeded from current size can only preserve bloat.
- Deduplicate the shared layer. `cli.sh doctor` reports `agent-common.md` with **in-degree 55**. `critical-requirements.md` (22,883 B), `agent-common.md` (20,274 B), `evidence-rules.md` (13,046 B), and `quality-gates.md` (19,932 B) substantially restate the same anti-fabrication doctrine. Collapse to one normative source plus short role-specific deltas.
- Move **reference data out of prompts into tools.** `project-config-contract.md` (59,685 B) and `feature-templates.md` (22,401 B) are lookup material, not reasoning context. The MCP surface already exists (`docs/MCP.md`, `mcp_bubbles_read_spec`); serve templates on demand. This is the single largest available structural saving.
- **Track cost honestly.** Do not fabricate token counts — but `bundle_bytes × dispatch_count` is exactly computable from `effective-bundle-measure.sh` plus the existing dispatch counters, and is a truthful, non-fabricated cost proxy. Add it to `bubbles.retro` and to `activityTracking.measuredDimensions`. This respects the existing (correct) refusal to invent `dollarCost` while ending the total blindness.

### SCOPE-7 — Make validation fast and incremental (PERF-1)

- Add `--changed-only` to `framework-validate.sh`, mapping `git diff --name-only` output to affected checks via a `check → owned paths` manifest. Most commits touch one subsystem.
- Parallelize `run_check` using the existing `bubbles/scripts/parallel-fanout.sh` with bounded `-P` and deterministic ordered output (its determinism selftest already exists). The measured 260 s for 16 checks is dominated by process startup; this workload is embarrassingly parallel.
- Cache selftest results keyed by sha256 of the script plus its fixtures — this is precisely the `inputClosure` mechanism already implemented for evidence receipts, reused.
- **Target: pre-push under 3 minutes.** This removes the strongest practical incentive to bypass the hook.

### SCOPE-8 — Replace lexical proxies with structural facts (EV-3)

- **DoD ↔ scenario linkage:** stop inferring with word overlap. Require the stable `SCN-*` ID (already present in `scenario-manifest.json`) inside the DoD item text. Deterministic, zero false positives, and it closes the documented G068 defect at its root rather than by threshold tuning.
- **Evidence sufficiency:** stop counting lines; a receipt either exists for the DoD item or it does not (depends on SCOPE-3).
- **Clone detection:** hash-compare receipts instead of 80 %-similarity over text.
- Retain lexical scans strictly as **smell detectors feeding advisories**, never as the primary verdict.

### SCOPE-11 — Strategic: plan the framework's own obsolescence curve (COV-3 follow-on)

- For each `modelCompensation` gate, record a **retirement criterion** in the registry (e.g. `retireWhen: golden-task fabrication rate < 2% over 20 runs at model tier >= N`).
- Connect the existing `bubbles/scripts/model-tier-advisory.sh`: on a stronger declared model tier, downgrade or skip specific `modelCompensation` gates and use the SCOPE-5 corpus to **measure** whether quality holds.
- This converts Bubbles from a fixed 112-gate tax into an adaptive assurance system that gets cheaper as models improve. Without it, cost stays permanently pinned to the weakest model the framework ever had to survive.

---

## Migration / rollout

Ordering matters; several scopes unblock others.

| Wave | Scopes | Character |
|---|---|---|
| 3 | SCOPE-4 | SEC-1 is gated on a new manifest capability flag, so it is non-breaking for existing payloads. SEC-2 ships advisory-first (`BUBBLES_ALLOW_DEGRADED` logged), then blocking one minor version later. |
| 4 | SCOPE-5 | Pure addition. No existing behavior changes. Prerequisite for waves 5–6. |
| 5 | SCOPE-6, SCOPE-7 | SCOPE-6 **must not** land before SCOPE-5 produces a passing zero-regression eval — this is the explicit R3 condition in `operating-baseline.md`. SCOPE-7 is independent and can land in parallel. |
| 6 | SCOPE-3, SCOPE-8 | Behavior-changing for evidence acceptance. Ship `receipt-preferred` default first (no-op), let downstream repos adopt `tool-log.sh` wrapping, then flip done-ceiling modes to `receipt-required` a version later. SCOPE-8's `SCN-*` requirement needs a planning-artifact migration window. |
| 7 | SCOPE-11 | Requires the delivered gate classification and SCOPE-5 (corpus). |

Every scope is additive or advisory-until-configured except SCOPE-3 wave 6 and SCOPE-8, which are the only two requiring a downstream migration window.

---

## Risks & mitigations

- **R1 — removed (delivered).**
- **R2 — SCOPE-6 bundle reduction degrades gate detection.** Moving load-bearing modules out of the router closure may cause missed routing. → This is exactly what the `operating-baseline.md` R3 condition anticipates. Hard-block SCOPE-6 on a passing SCOPE-5 held-out eval; keep the reduction opt-in until the eval is green two consecutive runs.
- **R3 — SCOPE-3 `receipt-required` breaks existing downstream repos.** Repos with markdown-only evidence would fail promotion. → Default `receipt-preferred` (no-op). Announce, ship the CLI-wrapping recipe, and only bind `receipt-required` to done-ceiling modes one minor version later. Provide a `bubbles evidence migrate --dry-run` report showing which DoD items would fail.
- **R4 — SCOPE-4 SEC-2 blocking breaks CI on machines lacking `jsonschema`.** → Advisory-first with a loud `doctor` degraded-posture line; blocking one version later; document `pip install --user pyyaml jsonschema` in `INSTALLATION.md`.
- **R6 — removed (delivered).**
- **R7 — SCOPE-7 parallelization introduces nondeterministic output ordering,** making failures hard to read. → `parallel-fanout.sh` already has a determinism selftest; require ordered result buffering and keep `--tier=core` serial as a debugging fallback.
- **R8 — Scope creep.** → The remaining waves can be re-proposed separately if the owner prefers smaller units.

---

## Acceptance criteria (when implemented)

- **SCOPE-3:** under `evidenceMode: receipt-required`, a DoD item backed only by a 10-line prose block causes `state-transition-guard.sh` to exit **1**; under `receipt-preferred` it still passes with an advisory. `evidence-receipt-check.sh --strict` runs in the transition path. `README.md:46` matches observed behavior.
- **SCOPE-4:** `install.sh` fails when the manifest declares `payloadVerifierRequired: true` and the verifier is absent; `doctor` lists the full dependency set and reports degraded posture when `BUBBLES_ALLOW_DEGRADED=1`; each of the 10 SEC-2 scripts exits non-zero on a missing required dep unless the opt-out is set; G034 either has a resolvable enforcer or is reclassified with an agent reference.
- **SCOPE-5:** `bubbles eval run --suite bubbles/eval/tasks` scores ≥10 golden tasks and returns a deterministic aggregate; the fabrication-bait task **fails** a run that marks the item `[x]` and **passes** one that leaves it `[ ]` with an Uncertainty Declaration.
- **SCOPE-6:** `effective-bundle-measure.sh agents/bubbles.workflow.agent.md` reports ≤ 160,000 bytes (~40 K tokens); the SCOPE-5 eval shows zero gate-detection regression across two consecutive runs; `doctor` reports distance-to-target per role class; `bubbles.retro` reports a `bundle_bytes × dispatches` cost proxy.
- **SCOPE-7:** `framework-validate.sh --changed-only` runs a strict subset for a single-subsystem diff; full-tier wall clock drops below 5 minutes on the reference machine; repeated runs with no changes are cache-served; output ordering is deterministic.
- **SCOPE-8:** every DoD item in the reference examples carries an `SCN-*` reference; G068's word-overlap matcher is removed from the verdict path; the `docs/issues/G068-*` false-positive case now passes.
- **SCOPE-11:** every `modelCompensation` gate carries a `retireWhen` criterion; `model-tier-advisory.sh` can produce a report of which gates would be skipped at a given tier.

---

## Files to touch (on approval)

Owning agent/gate named per surface so implementation routes correctly.

| Path | Change | Owner |
|---|---|---|
| `bubbles/registry/gates.yaml` | add `enforcedBy` to 112 entries | `bubbles.devops` / G124 |
| `bubbles/scripts/generate-gate-coverage-map.sh` | derive from `enforcedBy` | `bubbles.devops` |
| `bubbles/scripts/framework-validate.sh` | glob discovery + deny-list; `--changed-only`; parallel fan-out | `bubbles.devops` |
| `bubbles/workflows.yaml` | `gateClassification` completion; fix `customGatesDiscovery.idRange`; band comment | `bubbles.devops` (regenerate via `generate-gates-block.sh`) |
| `docs/recipes/custom-gates.md` | generated band string | `bubbles.docs` |
| `bubbles/scripts/state-transition-guard.sh` | Check-9 chain inversion under `evidenceMode` | `bubbles.validate` / G021, G025 |
| `bubbles/scripts/evidence-admission-hardening-selftest.sh` | update pinned advisory expectation; add red fixture | `bubbles.test` |
| `bubbles/scripts/evidence-receipt-check.sh` | wire `--strict` into transition path | `bubbles.validate` |
| `.github/bubbles-project.yaml` (template) + `templates/` | `evidenceMode`, `effectiveBundleTargetBytes` keys | `bubbles.setup` |
| `install.sh` | fail-closed verifier branch; dependency preflight | `bubbles.devops` / G074 |
| `bubbles/release-manifest.json` | `payloadVerifierRequired` capability | `bubbles.releases` |
| `bubbles/scripts/{result-envelope-validate,yaml-schema-validate,diff-evidence-guard,evidence-tool-log-bridge,generate-gate-coverage-map,generate-gates-block,generate-modes-block,mode-family-inventory,model-tier-advisory,parallel-fanout}.sh` | fail-closed on required deps | `bubbles.devops` / G028 |
| `bubbles/eval/tasks/*.json` (new) | golden-task corpus | `bubbles.test` / G125 |
| `bubbles/scripts/cli.sh` | `eval run` subcommand; doctor dependency + cost reporting | `bubbles.devops` |
| `agents/bubbles_shared/{operating-baseline,plan-bootstrap,implement-bootstrap,design-bootstrap,analysis-bootstrap}.md` | phase-local authoring-module split | `bubbles.docs` / G042 |
| `agents/bubbles_shared/{critical-requirements,agent-common,evidence-rules,quality-gates}.md` | de-duplicate anti-fabrication doctrine | `bubbles.simplify` / G042 |
| `bubbles/scripts/agent-bundle-size-budget.sh` | ratchet → ratchet+target | `bubbles.devops` |
| `README.md` | reconcile line 46 evidence claim; declare dependencies | `bubbles.docs` |
| `agents/bubbles.security.agent.md` | reference G034 (or its replacement) | `bubbles.security` |

---

## Must not regress

Remediation must not weaken these verified-working controls:

- **The Honesty Incentive** (`critical-requirements.md:12-29`) — Executed+Observed > Honest Gap > Fabricated Completion, *"a wrong answer is 3x worse than a blank answer"*. **Preserve verbatim** through SCOPE-6 de-duplication; it is the framework's most effective single control.
- **`state-transition-guard.sh` integrity** — 108 `fail` vs 15 `warn`, one selftest-only env var, zero grandfather clauses. SCOPE-3 adds a mode; it must not add an override.
- **`batch-promotion-lint.sh` override design** — `<actor>:<expiryEpoch>:<sha>`, sha-bound, expiring, non-replayable, append-only ledger. The reference pattern any future override must follow.
- **`generate-gates-block.sh`** byte-identical registry→`workflows.yaml` splice with `--check` drift mode. It must preserve round-trip parity.
- **`eval-harness.sh` fails closed** on missing `python3`. SCOPE-4 generalizes this posture; it must not invert it.
- **`metrics` refusing to track `dollarCost`** because *"Derived from unknown tokens = fabricated"*. SCOPE-6 adds only exactly-computable proxies.
- **Artifact ownership + the closed result-envelope vocabulary** (`completed_owned` / `completed_diagnostic` / `route_required` / `blocked`).
- **`gateClassification`'s `modelCompensation` / `businessInvariant` split** — the only principled path to shedding scaffolding as models improve. SCOPE-11 extends it; nothing may collapse it.
- **The repository-binding subsystem** (session-bound, control-revision, digest-verified work boundary) and its ~6,000 lines of selftest, fully wired via `framework-validate.sh:363`. The selftest discovery sweep must keep the `cli.sh repository-binding-selftest --suite=all` aggregate invocation intact.
- **`install.sh` payload integrity verification** against `release-manifest.json` checksums, with its explicit *"INTEGRITY only, not authenticity"* disclosure. SCOPE-4 closes the fail-open branch without disturbing this design.
