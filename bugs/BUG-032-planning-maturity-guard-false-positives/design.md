# Bug Fix Design: BUG-032 Planning-Maturity Guard False Positives

## Design Status

Planning complete for implementation handoff. No production code or persistent
selftest was changed in this invocation.

## Root Cause Analysis

### Investigation Summary

Current-session source reads traced each reported behavior to its controlling
predicate:

| Defect | Controlling source | Current decision proxy | Why the proxy is invalid |
| --- | --- | --- | --- |
| D1 | `bubbles/scripts/guards/planning-checks.sh`, Check 8B | Any mutation verb and interface-shaped noun co-occurring in a scope line | `path` can describe generation or storage, while `replace` can describe providers, lifecycle states, or artifacts. Co-occurrence does not prove a consumer identity changed. |
| D2 | `bubbles/scripts/state-transition-guard.sh`, Check 5A | Presence of `latency`, `throughput`, `p95`, `p99`, `response time`, `sla`, or `slo` anywhere in a scope | Mentioning the absence of an SLO is not declaring one. The current grep has no polarity or opt-out concept. |
| D3 | `bubbles/scripts/state-transition-guard.sh`, Check 43 | Equal non-empty `stdoutHash` plus differing normalized command identity | Deterministic validators can emit stable summaries for independent runs. Output equality is content equality, not execution identity. |
| D4 | `bubbles/scripts/release-delivery-reconciliation-guard.sh`, G101 | Terminal-for-mode plus validate certification, with a broad terminal fallback list | A planning, docs, or validation-only mode can be terminal without delivering implementation. Terminality answers whether the mode finished, not what the mode delivered. |

### Shared Root Cause

All four checks collapse a richer contract into one convenient proxy:

- word proximity for interface mutation;
- token presence for affirmative promises;
- byte equality for receipt identity;
- lifecycle terminality for release delivery.

The fix must replace each proxy with the smallest available semantic identity.
It must not solve false positives by globally disabling a guard.

## Fix Design

### D1 - Consumer-interface mutation classifier

#### Consumer Classifier Decision

Replace the current generic verb/noun co-occurrence predicate with a narrow
line-oriented classifier for explicit consumer identity mutation.

A line is positive only when it contains:

1. an unambiguous mutation verb from `rename`, `renamed`, `remove`, `removed`,
   `move`, `moved`, `deprecate`, or `deprecated`; and
2. a consumer surface noun from the current interface vocabulary; and
3. a syntactic ordering that describes the surface as the mutation object or
   subject, with a bounded token window.

`replace`, `replaced`, and generic `migration` are not independently sufficient.
When a replacement really retires an old interface, the scope must state the
actual removal, rename, move, or deprecation. That wording is both machine
classifiable and more useful to a reviewer.

The classifier remains line-oriented. It does not scan unrelated paragraphs as
one token bag, and it does not use a list of downstream product names or special
Ozhiva phrases.

#### Negative fixtures

- `The stale generation path is replaced by the current generated artifact.`
- `The provider implementation is replaced without changing its contract.`
- `The lifecycle state is replaced by the successor state.`
- `The stale artifact path is replaced; route and endpoint identities are unchanged.`

#### Positive fixtures

Use a scenario table covering actual route, path, endpoint, contract, and
identifier rename/removal. Each positive fixture must fail if the classifier is
reduced to always-false.

#### Why this is not a broad exemption

The positive trigger vocabulary remains. Only ambiguous replacement/migration
words stop proving an interface mutation by themselves. Actual replacement work
that removes an interface still triggers when its removal is stated.

### D2 - Affirmative performance-contract classifier

#### Performance Classifier Decision

Classify performance promises per line using two stages:

1. Detect a genuine performance signal: SLA, SLO, latency, throughput,
   response-time, p95, or p99.
2. Determine polarity. Explicit opt-out/absence wording suppresses the line only
   when no target, budget, threshold, objective, guarantee, percentile value, or
   quantitative comparator is present.

Positive contract markers override a broad negation. For example, `no more than
200 ms p95 latency` is affirmative despite containing `no`, while `no SLO is
declared` is negative. This prevents a simplistic `no` exclusion from weakening
real enforcement.

The negative posture vocabulary is closed and documented: `no SLA`, `no SLO`,
`SLA/SLO not applicable`, `observability opted out`, `does not declare`, and
`no ... evidence is injected`. The implementation should normalize case and
punctuation but must not infer a missing target.

#### Required controls

- Negative: the exact opted-out sentence from the operator report.
- Negative: no-SLA and not-applicable forms.
- Positive: SLO availability target.
- Positive: p95 latency budget.
- Positive: throughput target and p99 response-time threshold.
- Adversarial polarity: `no more than 200 ms p95 latency` remains positive.

### D3 - Receipt clone identity

#### Existing receipt fields

`bubbles/scripts/tool-log.sh` records `cmd`, `ts`, `sessionId`, `spec`, `scope`,
`exitCode`, `durationMs`, `stdoutHash`, `stdoutBytes`, `tags`, and optional
`inputClosure`. The fix can use current schema fields and does not need a blanket
hash exemption.

#### Receipt Identity Decision

For each non-empty `stdoutHash` collision, derive this identity:

- **command family:** unwrap a leading shell and take the executable basename;
- **evidence category:** use closed receipt tags when present, otherwise derive a
  conservative category from the executable/subcommand (`test`, `lint`,
  `build`, `validate`, or `other`);
- **target identity:** prefer the sorted `inputClosure`; otherwise use receipt
  `spec` and `scope`; otherwise use the normalized positional target;
- **execution provenance:** `sessionId`, timestamp, duration, and exit code.

Decision order:

1. Preserve the current empty-stdout digest exemption, including receipts with
   no `stdoutBytes` field.
2. Preserve the current same-command rerun allowance.
3. Treat rows as deterministic sibling executions only when command family,
   evidence category, and exit status agree, while target/input closure and
   execution provenance establish independent runs.
4. Block when one substantive hash crosses incompatible command families or
   evidence categories, such as `cargo test` and `npm lint`.
5. Do not create an exemption when the metadata cannot establish independence.
   Ambiguous collisions retain a conservative finding until better receipt
   provenance exists.

Diagnostics should print the derived family, category, target identity, and
provenance distinction so an operator can understand why a collision was
accepted or blocked.

#### Why executable-only exemption is rejected

Exempting every collision from `artifact-lint.sh`, every lint, or every
validator would hide receipt reuse within that family. The exemption is earned
only by compatible semantic category plus independent target and execution
provenance.

#### Relationship to BUG-028

BUG-028 correctly identified equal deterministic stdout as insufficient proof.
BUG-032 narrows the implementation to current receipt fields and includes the
operator-required incompatible-command and empty-stdout controls. When D3 is
validate-certified, BUG-028 should be marked subsumed/fixed with a pointer to
BUG-032 evidence rather than left as a second open implementation track.

### D4 - G101 delivery-capable terminality

#### Delivery Semantics Decision

Split two questions that the current helper conflates:

1. Is the state terminal for its workflow mode?
2. Does that terminal mode represent delivered implementation?

Resolve the effective mode through the framework mode resolver. Use the expanded
mode contract, including `statusCeiling`, `terminalAliases`, transition audit
profile, and mode constraints. Do not duplicate YAML parsing in G101.

Apply this decision table:

| State | Mode contract | Decision |
| --- | --- | --- |
| `done` | delivery-capable, validate-certified | Delivered |
| `done` | explicitly planning/docs/validate/prototype mode | Refuse as incoherent |
| `specs_hardened` | planning maturity | Not delivered |
| `validated` | validation/readiness-only | Not delivered |
| `docs_updated` | docs-only | Not delivered |
| `delivered_fast` | rapid-tool-delivery terminal alias, validate-certified | Delivered |
| `delivered_pending_activation` | resolved pending-activation delivery mode, validate-certified | Delivered |
| `delivered_prototype` | any mode | Not delivered |

For backward compatibility, a legacy state with no resolvable mode may retain
`done` plus validate certification as delivered. No other alias receives a
legacy fallback. This preserves the required done behavior without letting an
unknown planning alias pass.

#### Selftest changes

Extend the existing `mk_spec` helper to accept a mode without changing existing
scenario meaning. Add cases for:

- `product-to-planning` plus `specs_hardened` plus validate: exit 1;
- `validate-only` plus `validated` plus validate: exit 1;
- `docs-only` plus `docs_updated` plus validate: exit 1;
- `full-delivery` plus `done` plus validate: exit 0 (existing S1 retained);
- `dark-launch-shipped` plus `delivered_pending_activation` plus validate: exit 0;
- `rapid-tool-delivery` plus `delivered_fast` plus validate: exit 0;
- `delivered_prototype` plus validate: exit 1 (existing S12 retained).

## Persistent Regression Surfaces

| Contract | Persistent selftest | Production surface |
| --- | --- | --- |
| D1 consumer mutation polarity | `bubbles/scripts/state-transition-guard-selftest.sh` | `bubbles/scripts/guards/planning-checks.sh` |
| D2 SLA/SLO polarity | `bubbles/scripts/state-transition-guard-selftest.sh` | `bubbles/scripts/state-transition-guard.sh` |
| D3 receipt identity | `bubbles/scripts/state-transition-guard-selftest.sh` | `bubbles/scripts/state-transition-guard.sh` |
| D4 delivery semantics | `bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | `bubbles/scripts/release-delivery-reconciliation-guard.sh` |

## Documentation And Registry Reconciliation

Implementation must inspect and update every source contract whose wording would
be false after the change. At minimum, review:

- source comments adjacent to Checks 8B, 5A, and 43;
- source comments and usage text in the G101 guard;
- `bubbles/registry/gates.yaml` records for G026, G043, and G101;
- `agents/bubbles_shared/consumer-trace.md` for the mutation trigger contract;
- `agents/bubbles_shared/evidence-rules.md` for receipt clone identity;
- release-delivery guidance that states `validate-certified + terminal` without
  qualifying delivery-capable mode semantics;
- `BUGS.md` BUG-028 disposition after D3 is verified;
- `CHANGELOG.md` when the behavior change is released.

Generated downstream assets must be updated only through the repository's
existing generation/release process. Do not hand-edit downstream copies.

## Alternatives Considered

1. **Exclude Ozhiva phrases by name.** Rejected because it creates a
   product-specific allowlist and leaves the semantic defect intact.
2. **Require Consumer Impact Sweep whenever `path` appears near any change
   word.** Rejected because filesystem and generation paths are not necessarily
   consumer interfaces.
3. **Suppress every line containing `no`.** Rejected because `no more than 200
   ms p95 latency` is a real performance contract.
4. **Exempt all output collisions from one executable.** Rejected because a
   reused receipt inside that family would become invisible.
5. **Make equal hashes advisory-only.** Rejected because the required
   unrelated-command clone case must remain blocking.
6. **Use terminal-for-mode as delivery with one `specs_hardened` exception.**
   Rejected because `validated` and `docs_updated` have the same semantic
   problem, and future planning aliases would reopen the hole.
7. **Accept only literal `done`.** Rejected because
   `delivered_pending_activation` and `delivered_fast` are genuine delivery
   states under their owning modes.
8. **Add a new receipt schema before fixing D3.** Rejected unless red fixtures
   prove current fields insufficient. Current receipts already carry the
   requested family, category, target, timing, exit, and closure signals.

## Risks And Mitigations

| Risk | Mitigation |
| --- | --- |
| D1 becomes too narrow and misses a real replacement | Require authors to state the concrete rename/removal/deprecation; keep positive noun coverage and adversarial fixtures. |
| D2 negation hides a real target | Positive target/budget/threshold/quantitative markers override opt-out suppression. |
| D3 exemption hides same-family reuse | Require independent target/input closure and execution provenance; missing metadata does not earn exemption. |
| D3 blocks old receipts lacking tags | Use a conservative executable/subcommand category fallback and retain diagnostics. |
| G101 breaks legacy done packets | Preserve validate-certified legacy `done`; reject non-done aliases without a resolved delivery mode. |
| G101 loses pending-activation delivery | Add explicit positive fixtures for all current pending-activation mode families. |
| Shell behavior diverges on macOS | Keep POSIX ERE/Bash 3.2-compatible forms and run framework portability validation. |
| Selftest additions only test copied regexes | Drive production helper/predicate where practical, or extract the production classifier into a sourceable function with a stable test surface. |

## Change Boundary

### Allowed future implementation files

- `bubbles/scripts/guards/planning-checks.sh`
- `bubbles/scripts/state-transition-guard.sh`
- `bubbles/scripts/state-transition-guard-selftest.sh`
- `bubbles/scripts/release-delivery-reconciliation-guard.sh`
- `bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh`
- mode-resolution helper only if the existing resolver cannot expose the needed
  expanded fields without duplication
- contract docs and gate metadata identified above
- generated manifests produced by the canonical generation command
- this bug packet and its `BUGS.md` registry entry

### Excluded future implementation files

- downstream installed `.github/bubbles/**` copies
- Ozhiva specs or planning prose
- unrelated framework guards
- workflow mode semantics not needed for delivery classification
- receipt capture schema unless the red tests prove current fields insufficient

## Complexity Tracking

| Decision | Simpler fix considered | Why rejected |
| --- | --- | --- |
| Polarity-aware SLA classifier | Add `grep -v no` | It would suppress affirmative `no more than` targets. |
| Multi-field receipt identity | Exempt same executable | It would broadly hide same-family receipt reuse. |
| Mode-semantic G101 resolution | Remove only `specs_hardened` from the fallback list | It would leave `validated` and `docs_updated` misclassified and would not constrain future aliases. |

No abstraction beyond these narrow classifiers is planned.
