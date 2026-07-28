# IMP-027 — Enforcement Integrity, Ungoverned Surfaces, and Context-Cost Audit

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of `bubbles/*` until approved
**Motivation:** Full-repository audit of v7.21.0 @ `f58fd5dd`. Every claim below was verified against a real file/line or a command executed against the tree.
**Verified gaps addressed:** EV-3, COST-1

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

---

## Proposal

Scopes are ordered by (severity × cheapness).

### SCOPE-8 — Replace lexical proxies with structural facts (EV-3) — **LINKAGE DELIVERED; REMAINDER NARROWED**

**Delivered:** DoD ↔ scenario linkage no longer relies solely on word overlap. When a
scenario carries a stable `SCN-*` ID, that ID is the authoritative linkage — deterministic,
no threshold to tune, zero false positives. Engages only when an ID is present, so specs
that have not adopted IDs keep today's behavior exactly and no enforcement is lost.

**Corrections to this proposal, recorded so they are decisions rather than gaps:**

- **"Demote the lexical scan to advisory" is REJECTED.** Today effectively no project
  carries `SCN-*` IDs in DoD text. Demoting the lexical path would therefore switch G068
  off almost everywhere, trading a tuning-accuracy problem for a no-enforcement problem.
  The lexical path stays authoritative exactly where no structural fact exists to replace
  it, and is superseded per-scenario as IDs get adopted.
- **"Evidence sufficiency: a receipt either exists or it does not" is REJECTED in that
  form.** Requiring a receipt per DoD item is the same blanket rule rejected in SCOPE-3:
  documentation and attestation items legitimately carry prose. Sufficiency is instead
  enforced by claim type (SCOPE-3 EV-1) and freshness (SCOPE-3 EV-2, guard Check 43).

**Remaining:**

- **Clone detection by receipt hash.** Not delivered. Note that Check 12 (duplicate
  evidence, G021) already hashes evidence blocks and was repaired under IMP-102, and
  Check 20 covers similarity — so this is an incremental third path whose value is low
  until receipts are actually adopted by a project. Sequence it after receipt adoption,
  not before.

### SCOPE-6 — Reduce context cost (COST-1) — **MEASUREMENT DELIVERED; REDUCTION BLOCKED**

**Delivered:** `bundle-cost-report.sh` (+ 16-case selftest) reports distance-to-target
per role class and the `bundle_bytes × dispatches` cost proxy; wired into `doctor`,
`framework-validate`, `bubbles.retro` (`## Context Cost`), and
`activityTracking.measuredDimensions` as `bundleCostProxy`.

**Correction to this proposal — the reduction is NOT unblocked.** This scope
claimed the SCOPE-5 corpus would validate the phase-local module move. It does
not. R3 in `operating-baseline.md` requires a held-out eval proving the
orchestrator still **detects and routes** every gate. The corpus scores static
artifacts with deterministic check types (`contains`, `not-contains`,
`file-exists`, `executable-oracle`) and never invokes a model, so it cannot
observe routing behaviour at all. Performing the move on corpus-green would be
exactly the substitution R3 forbids. This correction is now recorded in
`operating-baseline.md` so the next reader cannot repeat the mistake.

Remaining, each still blocked or independently large:

- **Blocked on a routing eval (R3):** move `project-config-contract.md`,
  `scope-workflow.md`, `feature-templates.md` out of the orchestrator's
  always-loaded closure. Measured gap: `bubbles.workflow` is 505,021 B against a
  160,000 B target, and the 3-module split is only ~123 KB — so even once
  unblocked this alone does not reach target. Build the routing eval first.
- **Not blocked, but a large independent refactor:** deduplicate the
  anti-fabrication doctrine restated across `critical-requirements.md`,
  `agent-common.md`, `evidence-rules.md`, and `quality-gates.md` into one
  normative source plus role deltas. **Preserve the Honesty Incentive verbatim.**
- **Not blocked, but a large independent refactor:** serve
  `project-config-contract.md` and `feature-templates.md` as on-demand lookups
  through the existing MCP surface rather than pinning them into prompts.


---

## Migration / rollout

Ordering matters; several scopes unblock others.

| Wave | Scopes | Character |
|---|---|---|
| 5 | SCOPE-6 | **Must not** land before the golden-task corpus shows a zero-regression eval — the explicit R3 condition in `operating-baseline.md`. |
| 6 | SCOPE-3, SCOPE-8 | Behavior-changing for evidence acceptance. Ship `receipt-preferred` default first (no-op), let downstream repos adopt `tool-log.sh` wrapping, then flip done-ceiling modes to `receipt-required` a version later. SCOPE-8's `SCN-*` requirement needs a planning-artifact migration window. |

Every scope is additive or advisory-until-configured except SCOPE-3 wave 6 and SCOPE-8, which are the only two requiring a downstream migration window.

---

## Risks & mitigations

- **R1 — removed (delivered).**
- **R2 — SCOPE-6 bundle reduction degrades gate detection.** Moving load-bearing modules out of the router closure may cause missed routing. → This is exactly what the `operating-baseline.md` R3 condition anticipates. Hard-block SCOPE-6 on a passing corpus eval; keep the reduction opt-in until the eval is green two consecutive runs.
- **R3 — SCOPE-3 `receipt-required` breaks existing downstream repos.** Repos with markdown-only evidence would fail promotion. → Default `receipt-preferred` (no-op). Announce, ship the CLI-wrapping recipe, and only bind `receipt-required` to done-ceiling modes one minor version later. Provide a `bubbles evidence migrate --dry-run` report showing which DoD items would fail.
- **R4 — removed (delivered).**
- **R6 — removed (delivered).**
- **R7 — removed (delivered).**
- **R8 — Scope creep.** → The remaining waves can be re-proposed separately if the owner prefers smaller units.

---

## Acceptance criteria (when implemented)

- **SCOPE-3:** under `evidenceMode: receipt-required`, a DoD item backed only by a 10-line prose block causes `state-transition-guard.sh` to exit **1**; under `receipt-preferred` it still passes with an advisory. `evidence-receipt-check.sh --strict` runs in the transition path. `README.md:46` matches observed behavior.
- **SCOPE-6:** `effective-bundle-measure.sh agents/bubbles.workflow.agent.md` reports ≤ 160,000 bytes (~40 K tokens); the corpus eval shows zero gate-detection regression across two consecutive runs; `doctor` reports distance-to-target per role class; `bubbles.retro` reports a `bundle_bytes × dispatches` cost proxy.
- **SCOPE-8:** every DoD item in the reference examples carries an `SCN-*` reference; G068's word-overlap matcher is removed from the verdict path; the `docs/issues/G068-*` false-positive case now passes.

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
- **`eval-harness.sh` fails closed** on missing `python3`. The shared dependency-posture helper generalizes this posture; it must not invert it.
- **`metrics` refusing to track `dollarCost`** because *"Derived from unknown tokens = fabricated"*. SCOPE-6 adds only exactly-computable proxies.
- **Artifact ownership + the closed result-envelope vocabulary** (`completed_owned` / `completed_diagnostic` / `route_required` / `blocked`).
- **`gateClassification`'s `modelCompensation` / `businessInvariant` split** — the only principled path to shedding scaffolding as models improve. The delivered `retireWhen` criteria (`bubbles/scripts/gate-retirement.sh`) hang off it; nothing may collapse it. Nor may a `retireWhen` criterion be moved onto a `businessInvariant` or `hybrid` gate — those hold regardless of executor and never retire, and the lint refuses it.
- **The repository-binding subsystem** (session-bound, control-revision, digest-verified work boundary) and its ~6,000 lines of selftest, fully wired via `framework-validate.sh:363`. The selftest discovery sweep must keep the `cli.sh repository-binding-selftest --suite=all` aggregate invocation intact.
- **`install.sh` payload integrity verification** against `release-manifest.json` checksums, with its explicit *"INTEGRITY only, not authenticity"* disclosure. The delivered fail-closed branch must not disturb this design.
