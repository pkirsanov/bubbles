# IMP-050 — A release phase packet can be silently incomplete, and no gate detects it

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of bubbles/* until approved
**Motivation:** A human-directed audit in a downstream consumer found a release phase directory holding 5 of the 8 canonical packet docs. Both mechanical checks that touch release packets — `release-packet-location-guard.sh` and Gate G101 — passed it. The three absent docs were `marketing.md`, `monetization.md`, and `ops-scalability.md`, so the phase could have reached "all required features delivered, all gates green" with no recorded monetization posture, no scaling thresholds, and no operational-readiness statement. Nothing in the framework announces an absence, so the packet reads complete to every automated check and to a casual reader.
**Verified gaps addressed:** COV-20 (no gate asserts that a release phase directory holds the complete canonical document set; the location guard knows all eight names but uses them only to recognise a misplaced file); DOC-9 (the published "exactly 8 docs per phase, no more and no fewer" contract has mechanical backing for "no more" and none whatsoever for "no fewer")

## Problem (verified against source)

Every line citation below was re-checked against this repository at HEAD
`f4225a2` during this session. Citations carried in from the reporting session
that proved exact are marked CONFIRMED; two required correction and are marked
CORRECTED. `bubbles/scripts/release-packet-location-guard.sh` is 111 lines,
its selftest 174 lines, and `bubbles/scripts/release-delivery-reconciliation-guard.sh`
496 lines.

- **DOC-9 — the contract says "no fewer" and nothing enforces it.**
  `agents/bubbles.releases.agent.md:54` reads "Exactly 8 docs per phase, no more
  and no fewer: `vision.md`, `features.md`, `actions.md`, `business-plan.md`,
  `deployment.md`, `marketing.md`, `monetization.md`, `ops-scalability.md`."
  (CONFIRMED at exactly line 54). The "no more" half is mechanically real: the
  location guard rejects a ninth doc placed inside a packet directory, and
  `agents/bubbles.releases.agent.md:63` records that the generated
  reconciliation audit note deliberately lives under `docs/generated/` so it
  does not become a ninth packet doc. The "no fewer" half has no enforcement
  anywhere. A published contract whose two halves have unequal backing is a
  documentation-truth defect, because a reader reasonably assumes a stated
  invariant is checked.

- **COV-20 — the location guard contains no completeness logic at all.**
  `grep -nE 'missing|complete|count|-f "' bubbles/scripts/release-packet-location-guard.sh`
  returns **zero matches** (exit 1) (CONFIRMED, re-run verbatim this session).
  This is not a threshold set too loosely; the concept is absent from the script.

- **COV-20 — the guard holds the canonical set but spends it only on
  recognition (CORRECTED).** The canonical eight are enumerated twice in the
  guard: in the header comment at **lines 5-6** (the reporting session said
  "around line 6"; the enumeration is a two-line wrapped comment spanning 5-6,
  CORRECTED), and in an array. The reporting session called that array
  `expected`; it is in fact named **`CANONICAL_DOCS`**, declared at line 35 with
  its eight elements at lines 36-43 (CORRECTED on the identifier; the cited
  locus "near line 42" falls inside the array, where line 42 is the
  `"monetization.md"` element). `CANONICAL_DOCS` is consumed in exactly two
  places: lines 47-56 build a `find -name a -o -name b …` expression, and lines
  99-101 print the allowed list inside the failure message. Neither is a
  membership test. There is no set difference and no `[[ -f ]]` existence check.

- **COV-20 — the guard has no concept of a phase as a unit that could be
  incomplete.** It walks the whole repository by basename via `find` (line 88)
  and evaluates each hit independently. The canonical regex at line 61 does
  capture the phase segment as `[^/]+`, but only to decide whether to ALLOW that
  one path; the guard never groups hits by phase and never enumerates
  `docs/releases/*/` as directories. Completeness is a property of a set, and the
  guard never forms the set. This is why the gap is architectural rather than a
  missing condition: adding a check means giving the script a phase-level pass it
  does not currently have.

- **COV-20 — the selftest reinforces the same blind spot.** The selftest
  iterates all eight names at line 149,
  `for doc in vision features actions business-plan deployment marketing monetization ops-scalability; do`
  (CONFIRMED at exactly line 149), and its documented scenario list at lines
  18-23 covers a misplaced `specs/releases/<phase>/vision.md`, a misplaced
  upper-case `docs/RELEASE-1/features.md`, and a false-positive control. Every
  scenario is about placement. No scenario constructs a packet that is missing a
  doc, so the selftest could not fail if completeness regressed — there is
  nothing to regress.

- **COV-20 — Gate G101 cannot see an absence, and this is now measured rather
  than argued.** `release-delivery-reconciliation-guard.sh` references
  `features.md` **10 times** and references **zero** of the other seven canonical
  doc names (CONFIRMED by count this session). It reads the machine-bound
  `delivery=required` annotations inside one document and reconciles them against
  spec certification truth, exactly as its registry entry at
  `bubbles/registry/gates.yaml:740-742` describes. A packet missing
  `monetization.md` entirely still reconciles green, because a missing document
  contributes no annotations to fail on. Absence is invisible to an
  annotation-driven gate, which is the same class of blind spot as a packet with
  no result block being indistinguishable from a packet with no failures.

- **COV-20 — the location guard is not a registered gate (NEW, adjacent).**
  `grep -nE 'release-packet-location' bubbles/registry/gates.yaml` returns no
  match (exit 1). The guard carries no `G` number, while the comparable G101
  guard is registered at `bubbles/registry/gates.yaml:1150`. Any completeness
  check bolted onto this script therefore inherits an unregistered enforcement
  surface, which matters when weighing remedy (a) against remedy (b) below.

- **COV-20 — only the selftest is wired into framework validation (NEW,
  adjacent).** `bubbles/scripts/framework-validate.sh:1055-1056` runs
  `release-packet-location-guard-selftest.sh`. No framework script invokes the
  live guard: grepping `release-packet-location-guard\.sh` across
  `bubbles/scripts/` matches only the selftest's own header comment (line 6) and
  its `GUARD_SCRIPT` assignment (line 32). The live guard is documented for
  downstream invocation at `docs/recipes/release-planning.md:39` and
  `skills/bubbles-release-packet-template/SKILL.md:80`, so a consumer that never
  wires it gets neither dimension checked. Whatever completeness check is chosen
  must be wired to actually run, or it repeats this pattern.

- **DOC-9 — the shipped agent interface can itself produce a partial packet
  (NEW, and decisive for the prior question below).**
  `agents/bubbles.releases.agent.md:113` declares the argument
  "`docs: vision|features|actions|business-plan|deployment|marketing|monetization|ops-scalability|all`
  — Restrict update scope (default: all)", and line 239 reads "For each doc in
  scope (`docs:` arg restricts; default all 8), write or refresh:". A partial
  packet is therefore a first-class output of the interface the framework ships,
  not only an accident of an interrupted run. The same agent asserts "no fewer"
  at line 54. Those two statements are not reconciled anywhere in the agent, and
  the owner cannot treat "partial is always wrong" as self-evident while the
  documented interface offers a supported way to produce one.

### Downstream evidence (measured in the `smackerel` consumer, not in this repository)

The figures below were measured this session in the downstream consumer repo
`smackerel`. **They were not reproduced in this repository, and cannot be**:
`docs/releases/` does not exist in the Bubbles framework source checkout
(verified this session), so there is no packet here to be complete or incomplete.
Running the live guard against this repository returns
`[release-packet-location-guard] OK (no misplaced release-packet docs)` at exit 0
— a vacuous pass, since it has nothing to inspect. The downstream figures are
reported as consumer observation and are the reason this proposal exists; they
are not framework-side execution evidence.

- At `smackerel` HEAD `60098b78`, `docs/releases/next/` contained 5 of the 8
  canonical docs. `marketing.md`, `monetization.md`, and `ops-scalability.md`
  were absent.
- The sibling phases `mvp` and `v1` each contained all 8, so the shortfall was
  specific to one phase rather than a repo-wide convention difference.
- `release-packet-location-guard.sh` exited 0 against that 5-doc packet.
- `release reconcile` (Gate G101) also passed against it.
- The gap survived until a human-directed audit enumerated the files by hand.
- It was closed in `smackerel` commit `7a24b83d`.

The consumer-side repair does not close the framework-side gap. Nothing in
Bubbles can detect the next occurrence of this in any consumer repository.

## Proposal

### SCOPE-1 — Settle the prior question: is a partially-authored packet legitimate? (DOC-9)

This scope produces a recorded owner decision, not code. It is sequenced first
because every option in SCOPE-2 depends on its answer, and choosing an
enforcement shape before settling it would encode an assumption.

The question: **is a partially-authored packet a legitimate transient state
during phase bring-up?** The evidence does not settle it either way, and this
proposal deliberately does not assume an answer.

- Evidence that partial may be legitimate: `agents/bubbles.releases.agent.md:113`
  ships a `docs:` argument whose entire purpose is to restrict which docs a run
  writes, and line 239 confirms the restriction is honoured. A consumer bringing
  up a phase incrementally is using the interface as documented.
- Evidence that partial is not legitimate: line 54 states "no more and no fewer"
  without qualification, without a bring-up exception, and without naming any
  state in which fewer than eight is acceptable.

Two outcomes, each with a consequence the owner should see before deciding:

- **If partial is NOT legitimate:** blocking enforcement is straightforwardly
  correct, and the `docs:` restriction argument should be re-described as a
  refresh-scope control for an already-complete packet rather than an authoring
  path — otherwise the interface keeps inviting the state the gate refuses.
- **If partial IS legitimate:** a blocking check requires a declared
  "packet under construction" state, and SCOPE-2 must then specify how that state
  is declared, who may declare it, when it expires, and what refuses a packet
  that has been "under construction" indefinitely. An undeclared, unbounded
  exemption would repeat the `requiresRevalidation` precedent recorded in
  IMP-049 EV-14, where an unvalidated boolean is the sole escape from a gate.

### SCOPE-2 — Decide where and how the completeness assertion lives (COV-20)

The decision is deliberately deferred to the owner. Four options were identified;
each is stated with the tradeoff that actually distinguishes it, and no
recommendation is made, because the discriminating input is the SCOPE-1 answer
rather than any property of the four scripts.

- **(a) Extend `release-packet-location-guard.sh` with a completeness
  assertion.** The script already carries `CANONICAL_DOCS` at lines 35-43, so the
  set is colocated and the change is small. *Tradeoff:* it widens a guard whose
  name says "location", so either the name or the scope becomes slightly
  dishonest. A reader who greps for why a completeness failure fired lands in a
  file that claims to be about placement. The guard also has no phase-level pass
  today (it walks by basename), so "small" understates it: the script must gain a
  `docs/releases/*/` directory enumeration it does not currently have.
- **(b) A separate `release-packet-completeness-guard.sh`.** Keeps each guard's
  name true to its job and lets the completeness check own a phase-level walk
  without reshaping the location walk. *Tradeoff:* one more script and one more
  wiring point, and the canonical eight-name list then exists in three places
  (guard, new guard, agent) unless it is sourced from one.
- **(c) Fold it into Gate G101.** The reconciliation guard already walks phase
  directories, so it is positioned to assert the set, and it is already a
  registered, blocking, wired gate — which options (a) and (b) are not.
  *Tradeoff:* G101's stated contract at `bubbles/registry/gates.yaml:740-742` is
  delivery reconciliation, not packet shape. Overloading it repeats the naming
  dishonesty of (a) on a gate with a much larger description to keep truthful.
  G101 is also grandfathered to WARN unless a packet opts in via the
  `bubbles:reconciled-packet` header, so completeness would inherit an opt-in
  posture and stay silent for exactly the un-migrated packets most likely to be
  incomplete.
- **(d) Report an incomplete packet without failing (advisory).** Weakest
  enforcement, but non-breaking for consumers that deliberately run partial
  packets during bring-up. *Tradeoff:* an advisory that is never escalated is a
  report nobody reads, and the observed downstream case shows a human audit was
  already required to notice the absence — an advisory line in a passing run is
  not obviously more visible than that. Option (d) is only coherent if SCOPE-1
  answers that partial packets are legitimate; if they are not, (d) knowingly
  leaves a blocking-worthy defect unblocked.

Whichever option is selected, two properties are required of it and are not
optional details:

1. The assertion must be **set-shaped**: for each `docs/releases/<phase>/`
   directory, compare the docs present against the canonical eight and name each
   absent doc individually. Reporting only a count would tell an operator that
   something is missing without telling them which commercial or operational
   surface is unrecorded, which is the specific harm observed downstream.
2. The canonical eight-name list must have **one authority**. It currently exists
   in `agents/bubbles.releases.agent.md:54`, the guard header at lines 5-6, the
   `CANONICAL_DOCS` array at lines 35-43, the guard regex at line 61, the
   selftest loop at line 149, and `skills/bubbles-release-packet-template/SKILL.md`.
   Adding a seventh copy would make a future rename a silent-divergence hazard.

### SCOPE-3 — Wire the chosen check so it actually executes (COV-20)

Whatever SCOPE-2 selects must run somewhere real. The adjacent findings above
show this is not automatic: the existing location guard is unregistered in
`bubbles/registry/gates.yaml`, and `framework-validate.sh:1055-1056` runs only
its selftest, never the live guard. A completeness check added to that script
without further wiring would be exercised solely against synthetic fixtures.

This scope covers registering the check (a gate ID if SCOPE-2 selects (a) or (b),
or reuse of G101's registration if it selects (c)), wiring it into the validation
chain, and adding hermetic selftest coverage. The selftest must include the
adversarial case the current suite lacks: a packet directory holding a strict
subset of the canonical eight must FAIL under a blocking option, or emit a named
per-doc report under advisory option (d). Without that case the new check is
untested in the only dimension it exists for. A replay of the observed downstream
shape — three specific docs absent from one phase while sibling phases are
complete — belongs in that coverage, expressed as a synthetic fixture rather than
as a reference to the consumer repository.

## Migration / rollout

- SCOPE-1 first and alone. It is a recorded decision with no code, and it selects
  between the enforcement postures in SCOPE-2. Landing SCOPE-2 first would encode
  an unexamined answer to the legitimacy question.
- SCOPE-2 and SCOPE-3 land together. A registered-but-unwired check, or a wired
  check with no selftest for the absence case, reproduces the exact condition this
  proposal documents.
- Rollout posture depends on the SCOPE-1 answer and is not pre-judged here. If
  enforcement lands blocking, it should ship advisory first for at least one
  release cycle so consumers can measure their own packets before a push is
  refused — every packet authored before this proposal predates the check, and
  the observed downstream case suggests incomplete packets already exist in the
  field. If SCOPE-1 answers that partial packets are legitimate, the declared
  bring-up state must land in the same change as the blocking check, never after.
- The framework source checkout has no `docs/releases/` directory and resolves
  vacuously clean, so this change is a no-op here. That also means it cannot be
  validated against real data in this repository; SCOPE-3's fixtures are the only
  in-repo proof available and must therefore carry the adversarial weight.

## Risks & mitigations

- **R1 A blocking check refuses a legitimate in-progress packet.** Directly
  realised if SCOPE-1 answers that bring-up partials are legitimate and SCOPE-2
  ships blocking without a declared state → gate SCOPE-2's posture on the SCOPE-1
  answer, and ship advisory-first regardless so the refusal rate is measured
  before it blocks anyone.
- **R2 A declared "under construction" state becomes a permanent bypass.** The
  framework already carries this failure shape: IMP-049 EV-14 records that
  `requiresRevalidation == "true"` short-circuits G088 to exit 0 with nothing
  validating that revalidation will ever occur → if such a state is introduced,
  bind it to an expiry and to a named owner, and make an expired declaration a
  finding rather than a silent pass.
- **R3 The canonical list drifts across its copies.** A future rename of one doc
  would leave the guard, the new check, the selftest, the agent, and the skill
  disagreeing, and a mismatched list makes a completeness check report false
  absences → satisfy the single-authority requirement in SCOPE-2, and add a
  cross-surface agreement assertion so the copies cannot drift independently.
- **R4 Advisory option (d) is chosen and then never revisited.** The gap stays
  open under the appearance of having been addressed, which is worse than an open
  finding because it stops being tracked → if (d) is selected, record it as an
  explicit interim posture with the condition that would escalate it, rather than
  as the resolution.
- **R5 A completeness check on the location guard makes its failures ambiguous.**
  Under option (a) one script exits 1 for two unrelated reasons, and an operator
  reading a non-zero exit cannot tell placement from absence without reading the
  message → require distinct, separately-named failure output per dimension, and
  keep the existing placement message text unchanged so current consumer runbooks
  stay accurate.
- **R6 The new check inherits G101's opt-in silence.** Under option (c),
  completeness would only fire for packets carrying the `bubbles:reconciled-packet`
  header, exempting the un-migrated packets most at risk → if (c) is selected,
  decide explicitly whether completeness follows the grandfathering posture or
  runs unconditionally, and record that choice in the G101 registry description
  rather than leaving it implied.

## Acceptance criteria (when implemented)

- A recorded owner decision exists answering whether a partially-authored packet
  is legitimate during phase bring-up, and the answer is reflected in
  `agents/bubbles.releases.agent.md` so lines 54 and 113 no longer read as
  unreconciled statements.
- For a repository containing a `docs/releases/<phase>/` directory holding a
  strict subset of the canonical eight, the selected check reports the absence and
  names each missing doc individually. Under a blocking option it exits non-zero;
  under advisory option (d) it exits 0 with the named per-doc report present in
  its output.
- A hermetic selftest constructs a packet missing at least one canonical doc and
  asserts the outcome above. The selftest fails if the completeness logic is
  removed — verified by removing it and observing a red run, not by inspection.
- A repository with a complete eight-doc packet, and a repository with no
  `docs/releases/` directory at all, both remain clean. The framework source
  checkout must still pass, since it has no packets.
- The canonical eight-name list resolves to a single authority, and an
  agreement assertion fails if any surface that restates it diverges.
- Grepping the script selected in SCOPE-2 for `missing|complete|count` returns at
  least one match — the direct inverse of the zero-match measurement that opened
  this proposal.
- The check is reachable from the validation chain a consumer actually runs, not
  only from a selftest. If the selected option leaves the live guard unwired, that
  is a failed acceptance rather than a deferred detail.

## Files to touch (on approval)

Exact file set depends on the SCOPE-2 selection; the surfaces below are named
with their owning agent or gate so implementation routes correctly.

`agents/bubbles.releases.agent.md` (reconcile the "no fewer" contract at line 54
with the `docs:` restriction argument at line 113 and its use at line 239, per the
SCOPE-1 decision; owner: **`bubbles.releases`**).
`bubbles/scripts/release-packet-location-guard.sh` (only under option (a) — add
the phase-directory enumeration and set comparison the script currently lacks,
reusing `CANONICAL_DOCS` at lines 35-43; owner: **`bubbles.releases`**).
`bubbles/scripts/release-packet-completeness-guard.sh` (new file, only under
option (b); owner: **`bubbles.releases`**).
`bubbles/scripts/release-delivery-reconciliation-guard.sh` (only under option (c)
— add the packet-shape assertion alongside the existing annotation
reconciliation; owning gate: **G101 release_delivery_reconciliation**).
`bubbles/scripts/release-packet-location-guard-selftest.sh` and/or a selftest for
the new script (the missing-doc adversarial case required by SCOPE-3; owner:
**`bubbles.releases`**).
`bubbles/scripts/framework-validate.sh` (wire the live check, addressing the
finding that only the selftest is currently wired at lines 1055-1056; owner:
**`bubbles.releases`**).
`bubbles/registry/gates.yaml` (register a new gate ID under options (a) or (b),
where the location guard currently has no entry; or amend the G101 description at
lines 740-742 under option (c), including the grandfathering decision from R6).
`skills/bubbles-release-packet-template/SKILL.md` (record the completeness rule
and the bring-up posture alongside the existing location rules at lines 46 and 80;
owner: **`bubbles.releases`**).
`docs/recipes/release-planning.md` (operator-facing note at line 39, where the
location guard is currently the only mechanical check named; owner:
**`bubbles.releases`**).

`bubbles/workflows.yaml` is **not** touched: this proposal adds an assertion about
packet shape and does not change any workflow mode, phase, or status ceiling.
