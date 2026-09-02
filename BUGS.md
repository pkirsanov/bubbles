# Bubbles Framework — Known Bugs

> **Why this file exists:** the Bubbles source repo cannot keep `specs/` (G085 dogfood guard), so framework-internal defects are tracked here as the operator-visible bug log. Downstream consumer repos file their bugs in their own `specs/<feature>/bugs/BUG-NNN-*/` structure as usual.
>
> **Artifact authority:** [`bubbles/registry/bug-packet.yaml`](bubbles/registry/bug-packet.yaml) is the single answer to "how many artifacts does a bug need". The one-entry form used in this file is its `single-file` form — a DELIBERATE declared case with a stated precondition (G085 forbids `specs/` here), not an exception to the packet contract. The obligations it retains — explicit disposition, reproduction before fix, root cause stated, evidence is execution — are recorded there.
>
> Every entry below has an explicit disposition per Gate G095 (Discovered-Issue Disposition).

---

## BUG-003 — runSubagent dispatch fails with Anthropic 400 — thinking blocks in the latest assistant message are mutated during sub-agent payload construction (extended-thinking + tool-use)

- **Filed:** 2026-06-11
- **Disposition:** external/upstream — NOT a Bubbles framework defect and not fixable in this repo; workaround documented; upstream fix recommended to `microsoft/vscode-copilot-chat` (filing pending a one-time SAML PAT authorization). Per Gate G095 this entry is a tracked EXTERNAL dependency, not an open framework defect.
- **Discovered by:** operator report during a `bubbles.goal` orchestrator session (4 consecutive dispatch failures in one turn)
- **Severity:** high for orchestrator/delegation modes (`bubbles.goal`, `bubbles.workflow`, `bubbles.sprint`) — these perform all implementation via `runSubagent`, so a failed dispatch halts progress for the rest of that turn. No impact on non-orchestrator agents.
- **Affects:** the VS Code Copilot Chat agent runtime's `runSubagent` dispatch payload serializer (`microsoft/vscode-copilot-chat`). NOT any file in this repo. The Bubbles agent definitions are correct.

> **Artifact convention:** the Bubbles source repo cannot keep `specs/` (Gate
> G085 dogfood guard), so this single entry is the full bug artifact. Because
> the defect is UPSTREAM (in the VS Code Copilot Chat agent runtime, not in this
> repo), the entry documents reproduction + root cause + recommended upstream fix
> + confirmed workaround IN LIEU OF an in-repo fix. No code changed in this repo
> for this bug, and none can — there is nothing here to fix.

### Reproduction

Extended-thinking model with interleaved thinking enabled; a long parent turn
with many tool calls and accumulated thinking blocks, including at least one
large (greater than ~8 KB) tool result that triggers the runtime's "large tool
result written to file" content-substitution rewrite; then a `runSubagent`
call. The dispatch fails with an Anthropic `400 invalid_request_error` at
`messages.N.content.M` where that block is a `thinking` / `redacted_thinking`
block (observed locus: `messages.1.content.4` — message index 1, content block
index 4).

### Root Cause (hypothesis)

The sub-agent dispatch harness rebuilds the outbound message array and mutates a
prior assistant message's `thinking` / `redacted_thinking` blocks
(re-serialization, whitespace/key-order normalization, content-block
re-ordering, signature drop, or splicing injected content such as the
large-result-to-file pointer or reminder text) instead of forwarding them
verbatim. Anthropic requires `thinking` blocks on extended-thinking + tool-use
round-trips to be returned byte-for-byte unchanged INCLUDING the signature and
in their original position relative to the `tool_use` block; any change yields a
400.

Tell-tale: a clean stateless sub-agent payload is `[system, user(dispatch
prompt)]` — content index 4 of message 1 (a user message) is never a thinking
block, so a thinking block there is direct evidence the harness is replaying a
parent assistant turn into the sub-agent request and then mutating it.

### Recommended Upstream Fix

Priority order:

1. **Start sub-agents with a clean message history** — build the payload from
   system prompt + dispatch prompt only; do not replay parent thinking-bearing
   assistant turns. If parent context is needed, forward a plain-text summary as
   user content, never replayed assistant thinking blocks. (Primary fix;
   directly explains the `messages.1.content.4` tell.)
2. **(Reframed) Preserve `thinking` / `redacted_thinking` blocks verbatim** —
   applies to the PARENT turn-continuation after the sub-agent returns (text +
   signature, original position). For sub-agent dispatch itself, fix 1
   supersedes (do not forward them at all).
3. **Decouple harness content-substitution from thinking blocks** — the
   large-tool-result-to-file rewrite and reminder injection must touch user-role
   messages ONLY (`tool_result` blocks live in user-role messages and carry no
   signature). Pass assistant messages through verbatim; if an assistant message
   must be edited, strip its thinking blocks entirely and consistently, never
   partially. (Primary fix for the parent-continuation manifestation.)
4. **Fail soft** — detect the modified-thinking-block condition pre-flight (or
   on the 400) and retry once with a thinking-stripped history instead of
   surfacing a raw 400; self-verify by diffing outbound thinking bytes against
   what the model originally returned. (Safety net.)

### Confirmed Workaround

A fresh user turn clears it — the mutated in-turn assistant message is no longer
the latest, so the next turn's dispatch succeeds; no data lost. Operationally
for orchestrator modes: dispatch sub-agents earlier in a turn (before
accumulating many large tool results + thinking blocks) to reduce trigger
probability.

### Triage Note

An earlier note linked the failure to a source file in a downstream product
(an internal agent file that was merely open in the editor at failure time).
That was a RED HERRING — that file uses a plain `Role`+`Content` string message
model over a Python sidecar and cannot emit Anthropic content-block errors.
Route the upstream issue to the sub-agent request serialization path in
`microsoft/vscode-copilot-chat`, NOT to any downstream product or the framework.

---

## BUG-004 — G068 scenario→DoD matching has drifted between its two implementations, contradicting the in-file "MUST stay aligned" contract

- **Filed:** 2026-07-30
- **Disposition:** **FIXED** 2026-08-17 in `276a81f`. Neither semantics was
  chosen over the other — the DUPLICATION was removed. One implementation now
  lives in `bubbles/scripts/scenario-match-lib.sh`, and the difference that had
  drifted is now a DECLARED policy argument: `structural-strict` (used by
  `state-transition-guard.sh`, behaviour unchanged) and `id-hint-lenient` (used
  by `traceability-guard.sh`, behaviour unchanged). Because the owner decision
  this entry was waiting on turned out to be unnecessary, downstream enforcement
  semantics moved in NEITHER direction: the 103 scenarios are **not** newly
  failed. `bubbles/scripts/scenario-match-lib-selftest.sh` (43 passed / 0
  failed) asserts that both call paths agree when given identical policy, so the
  pair cannot silently drift again, and it is registered in `framework-validate`.
  A golden-master corpus confirmed byte-identical verdicts before and after.
- **Discovered by:** a downstream (WanderAide) certification-debt census that measured G068 across 264 `done` packets, then traced the false-positive rate to the matcher.
- **Severity:** medium. The drift is currently in the SAFE direction (`traceability-guard.sh` is more lenient than `state-transition-guard.sh`), so it opens no enforcement hole. It does mean an artifact can pass the traceability guard and then fail the transition guard on the same G068 concern, which reads as a contradiction to an operator.
- **Affects:** `bubbles/scripts/traceability-guard.sh` (`scenario_matches_dod`) and `bubbles/scripts/state-transition-guard.sh` (`stg_scenario_matches_dod`).

### Evidence

`traceability-guard.sh` states the contract explicitly:

```
# (see stg_scenario_matches_dod in state-transition-guard.sh for the same
# logic — both implementations MUST stay aligned).
```

They are not aligned. Two divergences:

| Behavior | `traceability-guard.sh` | `state-transition-guard.sh` |
|---|---|---|
| ID families recognized | `SCN`, `AC`, `FR`, `UC` (via `extract_trace_ids`) | `SCN` only |
| Scenario carries an ID but no DoD item cites it | falls through to lexical word-overlap | hard `return 1` |

`state-transition-guard.sh` received the IMP-027 SCOPE-8 (EV-3) structural-ID
path — "structural linkage beats a lexical proxy", deliberately
no-op-unless-earned. `traceability-guard.sh` never received it and still treats
an ID as a hint that degrades to word overlap.

### Recommended Fix

Port the IMP-027 structural-ID path into `scenario_matches_dod`, OR relax
`stg_scenario_matches_dod` to the lenient form, and add a selftest assertion
that the two agree on a shared fixture so the pair cannot drift again. Choosing
between them is a policy call: the strict form is the IMP-027 intent, but
applying it to the traceability guard will newly fail artifacts in downstream
repos that cite scenarios by prose rather than by ID.

### Measured blast radius (why this was NOT reconciled in-session)

Measured against one downstream repo (WanderAide), over Gherkin scenarios in
`done` packets:

| | count |
|---|---|
| scenarios with no `SCN-*` id (strict path never engages) | 2635 |
| scenarios carrying an `SCN-*` id | 365 |
| …whose DoD cites that id (would still pass) | 262 |
| …whose DoD does NOT cite it (**would newly hard-fail**) | 103 |

So adopting the strict form in `traceability-guard.sh` newly fails 103 scenarios
in a single repo. The opposite direction — relaxing
`stg_scenario_matches_dod` to fall through — reverses a deliberate IMP-027
decision and is the "no-enforcement problem" its own comment warns against.
Neither direction is safe to apply unilaterally, which is why this entry is
DEFERRED with data rather than resolved by preference. A resolution needs either
a migration that adds the missing DoD id citations first, or an explicit owner
ruling that the lenient form is correct.

### Related work already landed

The same investigation found and FIXED three separate, non-drift defects in both
implementations. All three are the same shape: the lexical matcher compares
WHOLE normalized words, so any morphological difference between a scenario's
wording and a DoD item's wording costs an overlap point, and with a hard `>=3`
floor a single such difference can sink an otherwise identical claim.

| Class | Worked example | Effect |
|---|---|---|
| plural | scenario `request` vs DoD `requests` | `JSON request rejected` scored 2 against `JSON requests rejected with 415` |
| inflection | scenario `persisted` vs DoD `persist` | `Protobuf data persisted in PostgreSQL` scored 2 against `… protobuf decode + PostgreSQL persist` |
| derivation | scenario `stale` vs DoD `staleness` | `Stale data warning` scored 2 against `Staleness warning (amber) displayed …` |

Both implementations now share a tolerant matcher (`word_matches_text` /
`stg_word_matches_text`) covering `-s`/`-es` plus a shared-prefix rule floored at
5 characters so short roots cannot collide (`test` still does NOT match
`testament`). 10 selftest assertions, including that floor and three unrelated-word
negative controls.

Measured on a downstream repo (WanderAide). Repo-wide over 264 `done` packets,
unmapped scenarios fell 888 → 760 from the plural fix alone. The inflection and
derivation fixes were measured on the five largest specs rather than repo-wide,
because a full census costs hours (the guard takes ~64s on a single large spec,
and the fixes add only ~3% to that — the cost is pre-existing, not introduced):

| sample (5 largest specs) | unmapped |
|---|---|
| installed guard, no tolerance | 265 |
| + plural | 220 |
| + inflection + derivation | 199 |

That is −25% cumulative on the sample. Extrapolating gives roughly 690 repo-wide,
but that is an ESTIMATE from a 5-spec sample and was deliberately not promoted to
a measured fact — re-running the full census was judged not worth hours for a
number that must not be acted on as a defect count anyway. The count of FAILING
PACKETS held at 97 across every variant, so no packet was failing on morphology
alone.

**Caution for whoever picks this up:** the residual count is still NOT a defect
count. Each fix was root-caused from a worked example rather than tuned toward a
target, and the work was stopped at root-caused fixes deliberately — it is easy
to keep loosening the matcher until the number looks acceptable, which would be
tuning to a desired answer. A trustworthy defect count needs either per-scenario
adjudication or the structural `SCN-*` ID path (see the drift above), not further
lexical loosening.

---

## BUG-005 — selftests fail transiently inside a full `framework-validate` run but pass standalone; root cause unknown

- **Filed:** 2026-08-02
- **Disposition:** open in-repo framework defect, DEFERRED with no fix attempted. The failure did not reproduce, and shipping a speculative fix to a hermetic, currently-passing selftest would let everyone believe the flake was resolved when it was not. Per Gate G095 this is a tracked OPEN defect with a recorded reason, not a silent omission.
- **Discovered by:** two unrelated pre-push runs during a docs-only change; each failed on a *different* selftest, and each of those selftests passed when run directly afterwards.
- **Severity:** medium for throughput, none for enforcement. It produces a FALSE FAILURE that blocks a push — it never lets bad work through. Cost is wasted ~80-minute validate cycles and, worse, misattribution: the natural reading is "my change broke this", which is what happened here before the runs disproved it.
- **Affects:** `bubbles/scripts/framework-validate.sh` (as the harness). Observed victims so far: `bubbles/scripts/implementation-reality-scan-selftest.sh` and `bubbles/scripts/evidence-admission-hardening-selftest.sh`.

### Evidence

Instance 1 — `implementation-reality-scan-selftest`, failing assertion:

```
FAIL: Dynamic session provider is blocked unresolved (missing: reason=SENSITIVE_STORAGE_CLASSIFICATION_UNRESOLVED)
implementation-reality-scan selftest failed with 1 issue(s).
```

Instance 2 — `evidence-admission-hardening-selftest`, reported failing by the push
summary while a later direct run of the same selftest reported `17 passed / 0 failed`.

Reproduction attempts for instance 1, all clean:

| Attempt | Result |
|---|---|
| standalone, main checkout | 31/31 PASS, exit 0 |
| standalone, clean worktree | 31/31 PASS, exit 0 |
| 6× concurrent at load average 9.01 | 31/31 PASS, exit 0 (all six) |

Net: 9 clean runs, 0 reproductions.

### Ruled out

- **Not the shared-scratch class.** Both selftests are hermetic: `mktemp -d` roots with `EXIT INT TERM` cleanup traps, no fixed shared paths. This is *not* a fourth instance of the three scratch-path defects fixed at `94ce0c4`.
- **Not a PATH/environment difference.** `framework-validate.sh` prepends a macOS compat shim, but on Linux both probes short-circuit when unprefixed GNU tools are present, so PATH is unchanged between the passing and failing runs.
- **Not load-induced timeout — this hypothesis is backwards and should not be retried.** `SENSITIVE_STORAGE_CLASSIFICATION_UNRESOLVED` is the FAIL-CLOSED result in `implementation-reality-scan.sh`: it is emitted when python3/the helper is missing, or when the helper invocation fails. A load-induced helper failure would therefore SATISFY that assertion, not break it. The assertion failing means the helper *succeeded* and classified differently.

### What would actually diagnose it

Capture the classifier's output at failure time. For instance 1 that is
`sensitive_storage_output` in `implementation-reality-scan.sh`; a single captured
artifact distinguishes "helper misclassified" from "stream corrupted" and turns
this into a one-shot fix. Note that `8e00f6f` removed one latent corruption path
in that area (stderr was being merged into the parsed record stream) — that was a
real defect found while reading the code, but it is NOT known to be this bug's
cause and was not claimed as a fix for it.

### 2026-08-17 — SIGPIPE excluded for small-output guards (correction)

`bubbles/scripts/diff-evidence-guard.sh` emits roughly 43 bytes of output, far
below the 64 KiB pipe buffer, so the BUG-009 SIGPIPE mechanism CANNOT explain a
flake observed in that guard's selftest.

Recorded honestly: an intermittent failure of `diff-evidence-guard-selftest.sh`
case 3 was observed inside a saturated full validate on 2026-08-17 and was
initially attributed to SIGPIPE in commit `62ef790`. That attribution was WRONG
for this small-output case. The herestring change made there is still correct —
it removes a real latent class — but it is NOT proven to have fixed the observed
flake, and the flake's cause remains unknown.

---

## BUG-006 — the pre-push hook releases the `framework-validate` lock between its two phases, so a concurrent run can fail `release-check`

- **Filed:** 2026-08-02
- **Disposition:** **FIXED**, before 2026-08-17. `bubbles/scripts/hooks/pre-push.sh` now takes the lock once per push: the core tier runs `framework-validate.sh --tier=core` exactly once (line 70) and exits, and the full tier runs `release-check.sh` alone. The hook's own comment (lines 81-83) records that `release-check.sh` runs `framework-validate.sh` as its own first check, so the sequential validate-then-release-check pair that opened the lock gap is gone. The ledger was stale: the fix landed but this entry was never updated.
- **Discovered by:** repeated push failures on a multi-agent machine — bubbles needed six push attempts in one session, several lost to this.
- **Severity:** medium for throughput, none for enforcement. It only ever produces a false FAILURE; it cannot admit bad work.
- **Affects:** `bubbles/scripts/hooks/pre-push.sh`, `bubbles/scripts/release-check.sh`, `bubbles/scripts/framework-validate.sh` (the flock guard added at `1a49aba`).

### Mechanism

The hook runs two phases in sequence:

1. `framework-validate.sh` — takes the machine-wide flock, runs, **releases it**.
2. `release-check.sh` — which runs `framework-validate.sh` *again* internally, and so must take the lock a second time.

Between those two acquisitions the lock is free. On a machine with several agents
pushing, a peer's run acquires it in that window, and phase 2 then refuses:

```
==> Framework validation
ERROR: another framework-validate run is already in progress on this machine.
       Concurrent runs corrupt each other's shared scratch fixtures and produce
       false failures. Wait for the other run to finish, then re-run.
FAIL: Framework validation
Release check failed with 1 failing check(s).
```

The guard itself is behaving correctly — it is refusing rather than producing the
corrupt-fixture false failures it exists to prevent. The defect is that the
pre-push sequence hands the lock back mid-flight.

### Why waiting for the lock before pushing does not fix it

There are TWO exposure windows, and a pre-push wait closes neither from outside.

**Window A — before phase 1 acquires.** Blocking until the lock is free and
pushing immediately still loses, because the hook does not start
`framework-validate` first: it runs the changed-spec / agnosticity pass ahead of
it. A peer can take the lock inside that gap. Observed directly while filing this
entry — the wait loop reported the lock free, the push started, and phase 1 was
then refused with the error above.

**Window B — between phase 1 and phase 2.** Phase 1 releases the lock when it
finishes and `release-check` re-acquires it later, leaving a gap of roughly the
full validate duration.

Neither window is closable by the caller. The lock has to be held across both
phases, or the nested run has to inherit the parent's hold — which is the
contract change recorded in the disposition above.

---

## BUG-007 — Check 43 clone detection treats every empty-stdout receipt as a forgery, because all of them hash to the SHA-256 of the empty string

- **Filed:** 2026-08-07
- **Disposition:** **FIXED** 2026-08-08. The recommended one-predicate fix was applied to the Check 43 clone selector — `(.stdoutBytes // 0) > 0` — using a field the receipt schema already carries, so it needed no new capture and no hardcoded digest. Guarded by three selftest cases (`Check 43 empty-stdout receipt-clone exemption`): the predicate is extracted from the guard source so test and source cannot drift, three different commands with empty stdout must NOT be accused, and the adversarial twin requires that two different commands sharing REAL non-empty stdout still fire. Verified downstream: the reporting repo went from 1 clone finding to 0, and its whole guard run from 14 blocking findings to 12 with zero framework false positives remaining.
- **Original disposition (retained):** open in-repo framework defect, NOT fixed at filing time. Diagnosed with a reproduction and a proposed one-predicate fix, but `state-transition-guard.sh` ships to consumer repos as a framework-managed install artifact and the downstream repo that found it is forbidden from patching it locally.-managed install artifact and the downstream repo that found it is forbidden from patching it locally. Per Gate G095 this is a tracked OPEN defect with a recorded reason.
- **Discovered by:** a downstream consumer repo (research-lab) running the guard against `specs/_bugs/BUG-001-central-provider-credential-security`.
- **Severity:** high. It produces a **false BLOCK**, and it is a false accusation of *fabrication* specifically — the most serious finding class the framework issues. It also fires across spec boundaries, so an unrelated spec's receipts can block a transition.
- **Affects:** `bubbles/scripts/state-transition-guard.sh`, Check 43 (IMP-027 SCOPE-8, EV-3) — the clone-detection block, not the staleness block above it.

### Mechanism

Check 43 groups tool-call receipts by `stdoutHash` and fails when one hash is
cited by more than one distinct `cmd`:

```
| group_by(.stdoutHash)
| map(select((map(.cmd) | unique | length) > 1))
```

The in-file rationale is sound as far as it goes:

> What cannot happen honestly is identical stdout under DIFFERENT commands —
> `cargo test` and `npm run lint` do not produce byte-identical output.

That reasoning has one unhandled degenerate case: **empty stdout**. Every
command that writes nothing to stdout hashes to the same value —
`e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`, the SHA-256
of the empty string:

```
$ printf '' | sha256sum
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855  -
```

Producing no stdout is routine and honest: `grep` with no match, a command that
writes only to stderr, a failed invocation that never got as far as printing, a
quiet-mode run. Every such receipt collides with every other one, and the check
reads that collision as one result being reused to back an unrelated claim.

### Reproduction

```
$ bash .github/bubbles/scripts/state-transition-guard.sh \
    specs/_bugs/BUG-001-central-provider-credential-security
🔴 BLOCK: Evidence receipt CLONE — one captured stdout is cited by two different
commands, which cannot happen from honest execution: e3b0c44298fc… reused by:
--help AND bash .github/bubbles/scripts/traceability-guard.sh
specs/008-portfolio-survival-and-brief-lab --current-scope AND grep -n -E
MANDATE_CONSTRAINT_KINDS|... rlportfolio.js AND node --test
tests/feature-004-brief-eligibility.test.mjs AND node --test
tests/feature-004-journey-evidence-refresh.test
```

Note the cited commands: a `grep` (no match, no stdout), a `--help` that exited
127, and several `node --test` runs that exited 1 having written only to stderr.
None of them produced stdout; none of them is a forgery.

Note also that the finding cites `specs/008-portfolio-survival-and-brief-lab`
while the guard was invoked on `specs/_bugs/BUG-001-...`. The receipt log is
repo-global, so the clone check compares across every spec, and a transition can
be blocked by receipts belonging to an unrelated packet.

### Proof that empty stdout is the whole finding

The receipt schema already records `stdoutBytes`, so the hypothesis is directly
testable against the log:

```
$ jq -rs '[.[] | select((.stdoutHash // "") | startswith("e3b0c44298fc"))] | length' \
    .specify/runtime/tool-calls.jsonl
10
$ jq -rs 'length' .specify/runtime/tool-calls.jsonl
97
```

All 10 colliding receipts report `stdoutBytes=0`. Excluding that one digest
leaves **zero** clones in the entire log:

```
$ jq -rs 'map(select((.stdoutHash // "") != "" and (.cmd // "") != ""
      and ((.stdoutHash // "") | startswith("e3b0c44298fc") | not)))
    | group_by(.stdoutHash)
    | map(select((map(.cmd)|unique|length)>1)) | length' \
    .specify/runtime/tool-calls.jsonl
0
```

So on this repo the empty-stdout artifact is not merely the loudest clone
finding — it is the *only* one. Every BLOCK the check has ever issued here is
false.

### Recommended Fix

Add an emptiness predicate to the receipt selection. `stdoutBytes` is already in
the schema, so this needs no new capture and no hardcoded digest:

```
map(select((.stdoutHash // "") != "" and (.cmd // "") != "" and (.stdoutBytes // 0) > 0))
```

A receipt with no stdout carries no evidentiary content to clone, so excluding
it removes a false-positive class without weakening the check: a genuine forgery
reuses a *substantive* captured result, which by definition is non-empty.

Guard the fix with an adversarial case — a log containing two different commands
that both produced real, byte-identical stdout MUST still fail — so the fix
cannot silently disable the check it is repairing.

---

## BUG-008 — specialist subagent dispatch silently no-ops (returns no output, performs no work); NOT audit-specific and NOT packet-specific

- **Filed:** 2026-08-07
- **Scope widened:** 2026-08-08 — see "Second observation" below. The original title scoped this to `bubbles.audit` on one packet. A `bubbles.test` dispatch against an unrelated packet reproduced the identical signature, so both the agent-specific and the packet-specific framings are now **refuted**.
- **Reframed:** 2026-08-09 — see "Decisive observation" below. The fault is **intermittent, not deterministic**: the same agent, against the same packet, in the same session, succeeded twice and then no-opped four times. Every static-configuration hypothesis is eliminated by that alone. Practical consequence: **retrying a dropped dispatch is worthwhile**, which was not obvious while the bug read as absolute.
- **Disposition:** open, UNDIAGNOSED, recorded rather than worked around. Every hypothesis tested so far has been **refuted** (below), and no replacement hypothesis has evidence behind it. Deliberately NOT worked around by forging claims: a blocked transition needs real phase claims, and hand-writing one is precisely the fabrication Gates G022/G027 exist to detect. Per Gate G095 this is a tracked OPEN defect with a recorded reason.
- **Discovered by:** a downstream consumer repo (research-lab) attempting to certify `specs/_bugs/BUG-001-central-provider-credential-security`; widened while delivering `specs/017-decision-attention-and-developing-situations` in the same repo.
- **Severity:** high. A packet that needs a specialist phase claim cannot reach a terminal status through dispatch. The framework's sanctioned escape hatch is `provenanceMode: "parent-expanded"` (Check 6B Pass 2), which requires the parent to genuinely perform the work and cite real evidence — it is a legitimate path, not a bypass, but it means dispatch is effectively unavailable rather than merely flaky.
- **Affects:** specialist subagent dispatch generally. No specific script identified; the failure is that the dispatch produces no output whatsoever, so there is no error message to attribute.

### Symptom

Dispatching `bubbles.audit` against that packet returns nothing — not a
refusal, not a partial report, not an error. Eight attempts across separate
sessions, same result each time. Every other agent dispatches normally against
the same packet in the same sessions.

### Refuted hypothesis: packet size

The natural explanation is that the packet is too large for the audit agent to
read — its `report.md` is large. That explanation does not survive contact with
a sibling packet in the same repo:

| packet | `report.md` lines | bytes | terminal status |
|---|---|---|---|
| `specs/_bugs/BUG-001-central-provider-credential-security` | 6950 | 342,091 | **blocked at `in_progress`** |
| `specs/012-market-action-center-and-guided-tools/bugs/BUG-004-market-heatmap-control-surface` | 9907 | 469,230 | **`done`, certified** |

BUG-004's report is roughly 43% larger by lines and 37% larger by bytes, and it
audited and certified without incident. Size alone therefore does not explain
the failure, and any fix built on the size assumption would be built on a
falsified premise.

### Second observation (2026-08-08): a different agent, a different packet, same signature

Dispatching `bubbles.test` against
`specs/017-decision-attention-and-developing-situations` — a normal feature
packet, not a bug folder, in `full-delivery` mode — returned
`Agent completed with no output`, with **zero side effects**:

| probe | result |
|---|---|
| working tree after dispatch | no file attributable to the dispatch |
| `execution.completedPhaseClaims` | unchanged (still 4 × `implement`) |
| `execution.executionHistory` | still empty (`length == 0`) |
| commits during the window | all attributable to a concurrent session on other specs |

So the agent did not run, refuse, or partially execute. This kills two framings
at once: the failure is **not** specific to `bubbles.audit`, and it is **not**
specific to the BUG-001 packet or to `specs/_bugs/` placement.

### Refuted hypothesis: `disable-model-invocation` frontmatter

The documented VS Code runtime cause of a silently no-opping dispatch is a
target agent carrying `disable-model-invocation: true` (see the
`bubbles-vscode-agent-constraints` skill: a dispatch at a target with that flag
set is dropped by the host). That is **not** what is happening here. Reading the
frontmatter block of all twelve specialist agents in the downstream install:

```
agent        disable-model-invocation            user-invocable
test         <none>                              <none>
audit        <none>                              <none>
regression   <none>                              <none>
simplify     <none>                              <none>
gaps         <none>                              <none>
harden       <none>                              <none>
stabilize    <none>                              <none>
security     <none>                              <none>
chaos        <none>                              <none>
docs         <none>                              <none>
validate     <none>                              <none>
implement    <none>                              <none>
```

None of them sets either field, so none is a "pure top-level runner" the host
would refuse to dispatch. The frontmatter explanation is refuted.

### Decisive observation (2026-08-08/09): the SAME agent on the SAME packet both succeeded and no-opped, in one session

This is the datum that reframes the bug. Driving
`specs/017-decision-attention-and-developing-situations` to completion in a
single session, with the dispatching identity, the target packet, the agent
definitions and the loaded context all held constant:

| # | dispatch | outcome |
|---|---|---|
| 1 | `bubbles.test` | no output, zero side effects |
| 2 | `bubbles.audit` | **SUCCESS** — wrote `AUD-017-001`, a complete `AUDIT_RESULT_V1` transcript, and a `REWORK_REQUIRED` verdict |
| 3 | `bubbles.audit` | **SUCCESS** — wrote `AUD-017-002` |
| 4 | `bubbles.audit` | no output, zero side effects |
| 5 | `bubbles.audit` | no output, zero side effects |
| 6 | `bubbles.validate` | no output, zero side effects |
| 7 | `bubbles.validate`, deliberately short prompt | no output, zero side effects |

The failure is therefore **intermittent, not deterministic**, and it is
intermittent with every static input pinned.

### What this refutes

Because rows 2–5 are the same agent against the same packet in the same session,
any explanation that is a property of the *configuration* cannot be the cause:

| hypothesis | status |
|---|---|
| packet size | refuted earlier (BUG-004's larger packet certified fine) |
| packet identity / `specs/_bugs/` placement | **refuted** — one packet did both |
| agent identity (`bubbles.audit` specifically) | **refuted** — that agent did both |
| `disable-model-invocation` frontmatter | refuted — no agent sets it |
| subagent nesting depth | **refuted as sole cause** — depth was identical on rows 2 and 4; and see below, the depth-2 setting was ENABLED throughout |
| prompt / instruction size | **refuted** — row 7 was a deliberately short prompt |

The depth lead recorded above is therefore **downgraded**: depth may still gate
whether dispatch is possible at all, but it cannot explain a dispatch that works
and then stops working with depth unchanged.

### The depth hypothesis is now fully dead, and doctor was reporting the opposite

`chat.subagents.allowInvocationsFromSubagents` was **`true`** in
`~/.vscode-server/data/User/settings.json` for the whole of the session that
produced rows 2–7. Depth-2 dispatch was permitted, and dispatch still no-opped
intermittently. Nesting depth is not the cause.

This was obscured for a long time by a defect in `cli.sh doctor` itself (fixed in
the same change that records this): its probe scanned
`.vscode-server/data/Machine/settings.json` but **not**
`.vscode-server/data/User/settings.json`, which is where Remote, WSL and
Codespaces keep user settings. Doctor therefore printed

```text
✅ Subagent nesting: depth-1 default assumed (chat.subagents.allowInvocationsFromSubagents not enabled in scanned settings)
```

while the setting was in fact enabled in a file it never opened. A downstream
packet recorded "enable this setting" as a blocking **operator action** on that
false report — so the defect did not merely mislead, it manufactured a blocker
out of a condition that was already satisfied.

Two lessons worth keeping separate: the depth hypothesis is refuted, and a
diagnostic that cannot see the thing it reports on is worse than no diagnostic,
because its output gets cited as evidence.

### What Would Advance This

The failure produces no diagnostic surface, so the first need is still
observability rather than a fix: have the dispatch emit *something* on every
path — a start marker, and on abnormal termination a reason — so a silent
failure becomes an attributable one. That need is now sharper, because an
intermittent fault cannot be cornered by inspecting static inputs.

The remaining leads are all **transient runtime conditions**, which is the only
class the evidence has not eliminated: host-side rate limiting or quota
exhaustion on nested requests; a capacity or timeout condition in the subagent
runtime that surfaces as a dropped dispatch rather than an error; and machine
resource contention.

Contention deserves a specific note, because the successes and failures were not
evenly distributed across load. Rows 4–7 were issued while this machine was
running a 14-minute Playwright suite, a second repo's Docker-based Playwright
install, a framework selftest, and at least one other concurrent agent session.
That is a correlation observed once, not a finding — but it is testable, and it
is cheap to test: retry a known-good dispatch on an idle machine and see whether
the success rate changes.

Until the dispatch emits a reason, the practical mitigation is the framework's
own `provenanceMode: "parent-expanded"` path (Check 6B Pass 2), which lets the
orchestrator perform the work itself and record why, with evidence — and, for a
phase that must be independent such as `audit`, simply retrying, since the fault
is intermittent rather than absolute.

---

## BUG-009 — Check 9's command-output signature test is a SIGPIPE race under `pipefail`; an evidence block larger than the pipe buffer is intermittently misreported as "prose-only"

- **Filed:** 2026-08-07
- **Disposition:** **FIXED** 2026-08-17 in `9ffc483`. The entry's own recommended herestring fix was applied — at BOTH sites, including a second occurrence this entry did not record. Measured after the fix on a 200001-line block: the old pipe form false-blocked 20/20, the herestring 0/20. Verified by state-transition-guard selftest 310 passed / 0 failed.
- **Discovered by:** downstream `quantitativeFinance` delivery of spec 109 (FC.1), while diagnosing an intermittent `state-transition-guard` verdict flip on an otherwise-clean packet.
- **Severity:** medium. It cannot pass work that should fail — it does the opposite, producing a FALSE BLOCK on legitimate evidence. The cost is an unreproducible red verdict that invites an author to "fix" evidence that was already correct.
- **Affects:** `bubbles/scripts/state-transition-guard.sh`, `resolve_evidence_by_reference()`, the command-output signature test.

### The defect

```bash
if ! printf '%s\n' "$block_text" | grep -qE '```|Exit Code:|^[[:space:]]*\$ |Executed:|Command:'; then
```

`grep -q` exits the instant it matches. When `$block_text` exceeds the 64 KiB
pipe buffer, `printf` is still writing when the reader closes, so `printf` dies
of SIGPIPE (141). The script runs under `set -o pipefail`, so the pipeline's
status becomes 141 — non-zero — even though **the pattern was found**. The `!`
inverts that into "no command-output signature", and an execution-claiming DoD
item is blocked as prose-only.

The failure is size-dependent, which is why it presents as flakiness: the same
packet passes or fails depending on how much evidence a block happens to carry.

### Reproduction (measured, not asserted)

```
$ # exact semantics of the guard line, varying only block size
block=63 lines   -> false prose-only in  0/60 trials
block=200 lines  -> false prose-only in  0/60 trials
block=2000 lines -> false prose-only in 45/60 trials
block=200001 lines -> false prose-only in 40/40 trials
```

Under ~64 KiB the race never fires; above it, it fires most of the time. A
project pasting a full test-suite log into one anchor is comfortably over the
line.

### Recommended fix

Stop letting the reader close the pipe early, or stop letting `pipefail` see it:

```bash
if ! grep -qE '...' <<<"$block_text"; then
```

A herestring is a file, not a pipe, so there is no SIGPIPE and no pipefail
interaction. Equivalent alternatives: capture the status explicitly
(`printf ... | grep -cE ... || true` then compare), or drop `-q` so the reader
consumes its input. The herestring is preferred — it is the smallest change and
removes the failure mode rather than masking it.

### Note on a related, distinct symptom

The intermittency that led here was NOT this bug: the downstream block was 59
lines / 5085 bytes, far under the threshold, and its extraction was verified
deterministic (0 false negatives in 200 trials). That flakiness tracked
**concurrent guard invocations** instead, and is the same class already recorded
in BUG-005. The two are independent; this entry documents only the SIGPIPE race,
which was proven on its own terms.

---

## BUG-010 — `state-transition-guard` intermittently reports a G022 required phase as missing when it is demonstrably present (~4% of runs); root cause NOT isolated

- **Filed:** 2026-08-07
- **Disposition:** open framework defect — reproduced and quantified, but the mechanism is **unexplained**. The two obvious candidates were tested and BOTH ruled out. Recorded as an honest open lead rather than a closed diagnosis.
- **Discovered by:** downstream `quantitativeFinance` certification of spec 109 (FC.1), on a packet whose artifacts were independently proven correct.
- **Severity:** medium. Like BUG-009 it produces a FALSE BLOCK, never a false pass — but it is worse to diagnose, because the failure names a specific phase and so reads as a genuine, actionable artifact defect. An author who trusts it will "fix" a `state.json` that was already correct.
- **Affects:** `bubbles/scripts/state-transition-guard.sh` Check 6 / Gate G022 (the required-specialist-phase loop at the `Required phase '...' NOT in execution/certification phase records` failure).

### Symptom

```
🔴 BLOCK: Required phase 'stabilize' NOT in execution/certification phase records (Gate G022 violation)
🔴 BLOCK: 1 specialist phase(s) missing — work was NOT executed through the full pipeline
```

Exactly ONE phase is reported missing; the other twelve pass in the same run.

### Measured rate

```
25 sequential runs, same packet, no concurrent load, no file changes between runs:
  PASS = 24
  FAIL =  1     (the block above)
```

Earlier sweeps on the same packet: 11/12, then 10/10, then 8/8 — consistent with a
low-single-digit-percent intermittent false negative.

### What was ruled out

**1. The artifacts.** `stabilize` is present in BOTH `certification.certifiedCompletedPhases` and `executionHistory[].phasesExecuted`.

**2. The phase extractor.** Check 6 builds `state_completed_phases_block` from an inline Python heredoc. Running *that exact extractor* against the same `state.json`:

```
runs: 300 | empty output: 0 | "stabilize" missing: 0
```

It emits all thirteen phases, every time:

```
"spec-review" "implement" "test" "regression" "simplify" "gaps" "harden" "stabilize" "security" "validate" "audit" "chaos" "docs"
```

**3. A BUG-009-style SIGPIPE race at this call site.** The match is
`echo "$state_completed_phases_block" | grep -qE "\"$specialist_phase\""`, which is
the same `grep -q` shape as BUG-009 — but the block here is thirteen short lines,
far below the 64 KiB pipe buffer, so the race cannot arm. Confirmed on the real
data: 0 false negatives in 200 trials.

So the extractor is deterministic, the data is correct, and the comparison is too
small to race — yet the composed guard still fails ~4% of the time. **The
mechanism is genuinely not yet known.** Recording it as unexplained is the point:
a plausible-but-unverified root cause here would be worse than none, because it
would close the investigation on a guess.

### Untested leads (explicitly not findings)

`mode-resolver.sh` is invoked under `bubbles_run_with_timeout 30` in the IMP-105
fallback that derives `required_specialists`; a timeout or partial read there
would change the derived requirement set for that run. Whether the failing run
took the explicit-table path or the fallback path was not captured, and the
failure is too rare to bisect cheaply. Capturing which path produced
`required_specialists` on each run is the next diagnostic step.

### Interim guidance

Because it fails ~4% and cannot pass bad work, a single G022 failure on a packet
that otherwise passes should be **re-run before it is treated as real**. If the
phase is present in `state.json` and the extractor emits it, the failure is this
bug. Do not edit correct artifacts in response to it.

---

## BUG-011 — `bubbles.validate` writes `certification.completedScopes` as integers; the guard counts quoted strings, so six entries are read as zero

- **Filed:** 2026-08-08
- **Disposition:** **FIXED** 2026-08-17 in `dbc63c2`. Both sides were addressed rather than one picked silently. The READER now distinguishes "populated but not string scope IDs" from "empty" — previously both produced the identical EMPTY message, which is precisely what made the type mismatch expensive to diagnose. The WRITER contract was added as `bubbles.validate` rule 4. Mutation-proven: reverting the guard change fails the new assertions.
- **Discovered by:** downstream `research-lab` certification of spec `017-decision-attention-and-developing-situations`, when the guard reported `completedScopes` EMPTY on a `state.json` that visibly contained six entries.
- **Severity:** medium. It produces a FALSE BLOCK, never a false pass. Its real cost is that it looks like two framework components contradicting each other — the validate agent reports six completed scopes, the guard reports zero — which invites an author to distrust the guard or to hand-edit `certification.*`, and hand-editing `certification.*` is exactly the fabrication Gates G022/G027 exist to catch.
- **Affects:** the `bubbles.validate` agent (writer) and `bubbles/scripts/state-transition-guard.sh` (reader, the `state_completed_scopes_count` extractor).

### The mismatch

`bubbles.validate` wrote:

```json
"completedScopes": [1, 2, 3, 4, 5, 6]
```

The guard counts entries by matching **quoted strings**:

```bash
state_completed_scopes_count="$({
  ...
  | sed -E '1s/.*"completedScopes"[[:space:]]*:[[:space:]]*\[//' \
  | grep -cE '"[^"]+"' || true
```

`grep -cE '"[^"]+"'` matches nothing in `[1, 2, 3, 4, 5, 6]`, so the count is 0
and Check 4 fails with:

```
🔴 BLOCK: Resolved scope artifacts report 6 Done scope(s) but state.json
   completedScopes is EMPTY — state.json integrity failure
```

Gate G027 then fails on the same zero, reporting FABRICATION.

### Which shape is canonical

Every certified spec in the reporting repo uses **string scope IDs**, so the
reader is right and the writer is wrong:

| spec | `certification.completedScopes` |
|---|---|
| `002-distributed-tool-briefs-and-history` (done) | `["01-market-session-evidence-foundation", …]` |
| `010-company-fundamentals-and-brief-lab` (done) | `["scope-1-…", …]` |
| `011-volatility-regime-and-sizing-lab` (done) | `["SCOPE-01","SCOPE-02","SCOPE-03","SCOPE-04"]` |
| `_bugs/BUG-004-proxy-route-local-key-fallback` (done) | `["SCOPE-01"]` |

The guard also has a second check — "All completedScopes entries map to real
scope artifacts" — which is only meaningful for string IDs. Integers cannot map
to a scope directory, so the integer shape silently disables that check too.

### Recommended fix

Both halves, because either alone leaves the failure mode reachable:

1. **Writer.** `bubbles.validate` must emit scope IDs, not ordinals. In
   per-scope-directory layout the IDs are already present in the same file at
   `execution.scopeProgress[].scopeId`, so the writer can copy them rather than
   invent a numbering.
2. **Reader.** The extractor should FAIL LOUD on a present-but-unparseable
   `completedScopes` instead of silently counting zero. "Six integers" and
   "genuinely empty" are different states and currently produce the identical
   message, which is what made this take a schema comparison across four other
   specs to diagnose. A distinct message — *completedScopes is present but its
   entries are not string scope IDs* — would have made it self-evident.

Guard the fix with an adversarial case: a `state.json` carrying integer entries
must still BLOCK (it is genuinely malformed), but with the new, specific
message rather than the misleading EMPTY one.

### Workaround applied downstream

The reporting repo re-encoded the six entries to the scope directory IDs already
in `execution.scopeProgress`. That is an ENCODING correction only — the
certification claim itself was made by `bubbles.validate`, and re-typing its
output is not the same as asserting it.

---

## BUG-012 — Check 7A (executionHistory timestamp plausibility) has never evaluated a single entry; it reads a container and field names that do not exist

- **Filed:** 2026-08-08
- **Disposition:** FIXED at source in the same change that files this. The fix is
  behaviour-visible and will newly block packets that were passing vacuously —
  see "Blast radius" below, which is the point rather than a side effect.
- **Discovered by:** an independent audit (`AUD-017-001`) of downstream
  research-lab `specs/017-decision-attention-and-developing-situations`. The
  audit caught a set of fabricated-looking timestamps *by reading them*, then
  noted that the guard check whose entire job is to catch exactly that had
  reported itself skipped.
- **Severity:** high. This is a silently-inert anti-fabrication control. It does
  not produce a wrong answer; it produces a reassuring one.
- **Affects:** `bubbles/scripts/state-transition-guard.sh`, Check 7A, and a
  second site sharing the same container-selection bug.

### The defect — two independent bugs, either sufficient to disable the check

**1. Container selection has no fallback.**

```python
container = data.get("execution", {}) if isinstance(data.get("execution"), dict) else data
raw = container.get("executionHistory", [])
```

`executionHistory` is written at the TOP level by most agents. Because
`data["execution"]` is always a dict, the ternary always chooses it, and the
top-level array is never consulted — `raw` is `[]`. Check 6B, reading the *same*
array, already falls back correctly (`execution.get(...) or data.get(...)`), so
the two checks disagreed about whether the packet had any history at all.

**2. Entry timestamp field names do not exist on entries.**

```python
started = parse_ts(entry.get("runStartedAt"))
completed = parse_ts(entry.get("runCompletedAt"))
if started is None or completed is None:
    continue
```

Entries carry `startedAt` plus `completedAt`/`finishedAt`. `runStartedAt` is an
**execution-level** field (`execution.runStartedAt`), not an entry field.
Measured across every `specs/*/state.json` in the discovering repo:

| entry key | occurrences on executionHistory entries |
|---|---|
| `startedAt` | 252 |
| `finishedAt` | 222 |
| `runStartedAt` | **0** |

So even with the container fixed, every entry would hit the `continue`. The two
bugs are independent, and each alone is fatal.

### Observed symptom

```text
--- Check 7A: executionHistory Timestamp Plausibility ---
ℹ️  INFO: executionHistory has fewer than 3 entries — plausibility check skipped
```

on a packet whose `executionHistory` holds **fourteen** entries.

### Second site, same container bug

The implement-run counter behind the `lockdownState` consistency check shares the
identical container expression. It reported:

```text
✅ PASS: lockdownState round=0 is consistent with 0 implement-phase run(s) in executionHistory
```

on a packet recording one implement run. It passed by agreeing with its own empty
read — a check that cannot fail is not a check.

### The fix

Give both sites the top-level fallback Check 6B already has, and read the entry
field names that entries actually use (preferring the real ones, still accepting
the legacy names so no existing packet regresses).

### Blast radius — deliberately not softened

With the fix applied, Check 7A immediately blocks on the discovering packet:

```text
ℹ️  INFO: executionHistory entries analyzed: 14
🔴 BLOCK: executionHistory contains zero-duration entries for non-trivial phases: bubbles.plan:bootstrap|bubbles.implement:implement|bubbles.plan:bootstrap
🔴 BLOCK: executionHistory contains 4 overlapping entries — sequential agent execution is impossible if runs overlap
```

Note *which* entries are flagged: the pre-existing **specialist** records written
by `bubbles.plan` and `bubbles.implement`, not the parent-expanded ones the audit
had challenged. Those specialist records have carried zero-duration timestamps
all along and nothing has ever looked at them, because nothing could.

This will newly block packets across every consumer repo. That is the correct
outcome — they were never passing this check, they were skipping it — but it
should land with the expectation that real remediation follows, not a baseline.
Agents writing `executionHistory` should record measured start/finish times;
zero-duration on a non-trivial phase is now a blocking claim rather than an
unread one.

---

## BUG-013 — the uniform-interval fabrication detector runs on `executionHistory` only; `completedPhaseClaims[].claimedAt` is read by no check at all

- **Filed:** 2026-08-09
- **Disposition:** **FIXED** 2026-08-17 in `dbc63c2`.
  `execution.completedPhaseClaims[].claimedAt` is now analysed by the SAME
  `uniform_interval` / `first_backwards_step` helpers that already analyse
  `executionHistory` — one implementation reused, not a second copy; BUG-004 in
  this same ledger is why that distinction was treated as load-bearing. Absence
  of `claimedAt` ABSTAINS rather than accuses, and excluding the surface
  requires an explicit `claimedAtUnreconciled` carrying a reason of at least 20
  characters. Mutation-proven: with the fix reverted, a fabricated 10-point
  600-second grid returned exit 0.
- **Discovered by:** delivery of downstream research-lab
  `specs/017-decision-attention-and-developing-situations`, immediately after
  BUG-012's fix landed. BUG-012 made Check 7A *work*; this entry is about where
  it still does not *look*.
- **Severity:** high, and specifically high **after** BUG-012. BUG-012's fix
  repaired the `executionHistory` surface, which makes it easy to believe
  timestamp fabrication is now covered. It is covered on one surface of two.
- **Affects:** `bubbles/scripts/state-transition-guard.sh`, Check 7A.

### The gap

Check 7A already contains precisely the right detector:

```text
fail "executionHistory has $exec_count entries with identical ${uniform_interval}s intervals — FABRICATION INDICATOR"
```

That detector is pointed at exactly one array. Measured against the guard source:

| field | occurrences in `state-transition-guard.sh` |
|---|---|
| `executionHistory` | read by Check 7A and Check 6B |
| `claimedAt` | **0** |

`claimedAt` does not appear in the guard even once. No check parses it, so no
check can find a pattern in it.

### Why that surface is the one that matters

`completedPhaseClaims[].claimedAt` is the timestamp on the **phase claim** —
the record Gates G022 and G027 rely on to decide whether a phase was genuinely
performed. `executionHistory` is a narrative log; `completedPhaseClaims` is the
load-bearing assertion. The guard validates the log and takes the assertion at
face value.

### Observed instance

The discovering packet carried **ten** `claimedAt` values lying on an exact
600-second grid. When each claim was reconciled against its corresponding
`executionHistory.completedAt`, **thirteen distinct gaps** appeared — for example
`stabilize` claimed at `15:52:35Z` against a real completion of `04060d09`, and
`gaps` claimed at `16:02:49Z` against `53223f1c`.

A ten-entry 600-second grid is the *exact* signature the Check 7A detector
already recognises. It went unreported solely because the detector never reads
that array. The pattern was found by a human-directed reconciliation, not by the
control built to find it.

### Recommended fix

Run the existing uniform-interval and ordering analysis over
`execution.completedPhaseClaims[].claimedAt` as a second input set, reusing the
Check 7A helpers rather than duplicating them. Two properties are worth keeping:

1. Preserve the existing `durationUnmeasured` / declared-gap escape so honest
   packets that *declare* an unmeasured span stay passable. The equivalent
   marker on the claim side is `claimedAtUnreconciled` with a substantive
   reason, which the discovering packet used for three orphaned `implement`
   claims.
2. Guard it with an adversarial case — a set of `claimedAt` values on a uniform
   grid MUST fail — so the new check cannot regress to the vacuous state
   BUG-012 documented.

### Blast radius

Same shape as BUG-012 and equally deliberate: packets whose phase claims were
written on a round grid will begin to block. They were never passing this
analysis, because it was never applied to them.

---

## BUG-014 — the `doctor` subagent-nesting probe never reads remote VS Code user settings, so every WSL / Remote-SSH install reports "not enabled" regardless of the real value

- **Filed:** 2026-08-09
- **Disposition:** **FIXED**, before 2026-08-17. `bubbles/scripts/cli.sh` now
  scans `$HOME/.vscode-server/data/User/settings.json` (line 3214) alongside the
  `Machine` entry, together with the two `-insiders` equivalents, so a remote
  install's real user-scoped value is read. The ledger was stale: the fix landed
  but this entry was never updated.
- **Discovered by:** enabling `chat.subagents.allowInvocationsFromSubagents` on
  a WSL host and observing `doctor` continue to report it unset.
- **Severity:** low-to-moderate. The probe is explicitly advisory and never
  changes `doctor`'s exit code, so nothing breaks. It does, however, give a
  confidently wrong reading, and an advisory that is wrong is worse than absent
  because it invites the operator to "fix" an already-correct configuration.
- **Affects:** `bubbles/scripts/cli.sh`, the subagent-nesting probe (the scanned
  path list near the `allowInvocationsFromSubagents` lookup).

### The defect

The probe scans five candidate settings paths:

```text
$HOME/.config/Code/User/settings.json
$HOME/.config/Code - Insiders/User/settings.json
$HOME/Library/Application Support/Code/User/settings.json
$HOME/.vscode-server/data/Machine/settings.json
$REPO_ROOT/.vscode/settings.json
```

In a Remote / WSL session the **user-scope** settings that the agent runtime
actually honours live at:

```text
$HOME/.vscode-server/data/User/settings.json
```

That path is absent from the list. The list does include
`.vscode-server/data/**Machine**/settings.json`, so the `.vscode-server` tree is
clearly in scope conceptually — the *User* sibling was simply missed, which is
why the omission is easy to overlook.

### Evidence that the missed path is the live one

The directory carries the rest of the active user profile, including the
`prompts` folder the running session was handed:

```text
~/.vscode-server/data/User/
  History  copilot  globalStorage  memories  prompts  settings.json  workspaceStorage
```

Meanwhile `$HOME/.config/Code/User/settings.json` does exist on this host, but it
belongs to a *local desktop* VS Code install, not the remote server backing the
session — so scanning it reads the wrong profile entirely.

With `"chat.subagents.allowInvocationsFromSubagents": true` written to the real
user-scope file, `doctor` still reported:

```text
✅ Subagent nesting: depth-1 default assumed (chat.subagents.allowInvocationsFromSubagents not enabled in scanned settings)
```

### Recommended fix

Add `$HOME/.vscode-server/data/User/settings.json` to the candidate list, next to
the existing `Machine` entry. Consider also `$HOME/.vscode-server-insiders/data/User/settings.json`
for symmetry with the Insiders desktop path already present.

### Note on what this does NOT explain

This probe's inaccuracy is **not** a candidate cause of BUG-008. BUG-008's
decisive observation — the same agent, on the same packet, in one session,
succeeding twice and then no-opping four times — rules out every static
configuration input, this setting included. The two entries are unrelated beyond
both touching subagent dispatch.

---

## BUG-015 — `state-snapshot.sh` drops the compiled goal-node declaration before `mirror-session`, so valid goal-node convergence snapshots always refuse

- **Filed:** 2026-08-10
- **Disposition:** **CLOSED** 2026-08-10 at stable source revision
  `264505f535c70c79d194fc8d1561688dcdb0a025`. The test-first source repair and
  follow-up case-collision correction passed focused, repeated managed, and
  canonical stable release certification. The original analysis-phase routing
  remains documented below; closure relies only on inherited validate/test
  evidence from the pinned, unchanged revision.
- **Discovered by:** the cross-product
  `fix-goal-node-state-snapshot-binding` scenario after a valid scoped goal-node
  packet passed `validate-packet` and the immediately required convergence
  snapshot rejected the same packet.
- **Severity:** high. The defect is fail-closed, so it does not authorize the
  wrong repository. It makes the required Gate G082 progress record impossible
  for every goal-scenario node and prevents the same call from appending its
  `turnSnapshots[]` audit record.
- **Affects:** `bubbles/scripts/state-snapshot.sh`,
  `bubbles/scripts/repository-binding.sh`, their selftests, and the invocation
  contracts in `agents/bubbles.goal.agent.md` and
  `agents/bubbles_shared/operating-baseline.md`. Installed downstream copies
  have the same defect, but they are framework-managed and MUST NOT be edited
  directly; the source fix must propagate through the normal framework install
  path.

### Exact reproduction

The persisted command rendering below replaces host-private absolute roots with
`<control>`, `<scenario>`, and `<packet>`. Both commands used session
`vscode-4911317a16be7826959f98f665c79cd0` and the same packet bytes.

**Claim Source:** operator-provided reproduction, independently observed before
this bug-analysis node; retained as inherited evidence rather than represented
as execution by this agent.

1. Validate the goal-node packet against its compiled declaration:

```text
repository-binding.sh validate-packet \
  --session-id vscode-4911317a16be7826959f98f665c79cd0 \
  --session-control-file <control> \
  --packet-file <packet> \
  --scenario-file <scenario> \
  --node-id certify-ops009-scope02
```

Observed exit `0`:

```text
REPOSITORY PACKET SCOPED actionable=true ... scopeKind=goal-node scopeId=certify-ops009-scope02
```

2. Run the mandatory convergence snapshot with the same packet:

```text
BUBBLES_AGENT_NAME=bubbles.goal bash .github/bubbles/scripts/state-snapshot.sh \
  --phase phase_5_remediate \
  --scope-id 02-immutable-candidate-runtime-qualification \
  --note 'Scope 02 certification blockers VAL-001 through VAL-007 routed as one finding set' \
  --mode start \
  --convergence-iteration 1 \
  --spec-dir specs/_ops/OPS-009-online-inference-resource-admission \
  --session-id vscode-4911317a16be7826959f98f665c79cd0 \
  --session-control-file <control> \
  --binding-packet-file <packet>
```

Observed exit `1`:

```text
REPOSITORY PACKET REFUSED reason=GOAL_NODE_DECLARATION_REQUIRED actionable=false
```

**Claim Source:** executed in this bug-analysis node against the canonical source
copy and the independently bound packet for
`fix-goal-node-state-snapshot-binding`.

The current packet first validated with its declaration:

```text
REPOSITORY PACKET SCOPED actionable=true repository=bubbles root=<bubbles-root> decision=rb:vscode-4911317a16be7826959f98f665c79cd0:3:node:fix-goal-node-state-snapshot-binding revision=3 scopeKind=goal-node scopeId=fix-goal-node-state-snapshot-binding
```

The source `state-snapshot.sh` call then reproduced the defect:

```text
REPOSITORY PACKET REFUSED reason=GOAL_NODE_DECLARATION_REQUIRED actionable=false scopeId=fix-goal-node-state-snapshot-binding
STATE_SNAPSHOT_EXIT=1
```

No implementation or test command was run in this phase.

### Expected vs actual

**Expected:** a goal-node caller supplies the compiled scenario and node ID as a
required pair. `state-snapshot.sh` carries that pair into `mirror-session`, which
validates the packet against the exact compiled declaration before writing the
binding mirror, appending one `turnSnapshots[]` record, and updating the matching
`convergenceLoops[]` entry when convergence arguments are present.

**Actual:** `state-snapshot.sh` has no scenario/node arguments to carry. It calls
`mirror-session` with only session ID, control file, and packet file.
`mirror-session` therefore reaches the goal-node validator without the compiled
declaration and correctly refuses before any of the snapshot or convergence
updates can run.

### Grounded root cause

The defect is an authorization-context transport gap, not a defect in the
fail-closed validator:

1. `state-snapshot.sh` parses `--session-id`, `--session-control-file`, and
   `--binding-packet-file`, but no `--scenario-file` or `--node-id`.
2. Its `mirror-session` invocation forwards only those three values.
3. `repository-binding.sh` routes `mirror-session` through
   `parse_packet_command_args`, whose accepted options likewise contain no
   scenario or node pair.
4. `mirror_session()` calls `validate_packet_internal` without an expected
   goal-node declaration.
5. `validate_packet_internal` deliberately returns
   `GOAL_NODE_DECLARATION_REQUIRED` whenever `scopeKind == "goal-node"` and the
   declaration is absent. The public `validate-packet` front door already shows
   the correct pattern: it accepts the pair, resolves the node declaration from
   the compiled scenario, and passes that declaration into the same internal
   validator.

The local hypothesis is therefore falsifiable: if the declaration pair is
accepted and forwarded through both missing front doors while the internal
equality check remains unchanged, the valid positive path should reach the
mirror/snapshot writes; any mismatched declaration should continue to refuse.

### Gate G082 and convergence impact

`bubbles.goal.agent.md` mandates a `state-snapshot.sh` call on every convergence
iteration so Gate G082 can enforce `maxConvergenceIterations`. The refusal occurs
before `state-snapshot.sh` writes either session-state surface:

- `convergenceLoops[]` is not advanced, so the durable iteration count can
  under-report the goal runner's actual work.
- `turnSnapshots[]` receives no start/end record, so crash-resume and per-turn
  audit history lose the same iteration.
- A compliant goal runner must choose between a required call that always fails
  and omitting the call in violation of its convergence contract. Neither is an
  acceptable steady state.

This is a liveness and audit-integrity defect with a safe refusal, not an
authorization bypass.

### Security boundary that the fix MUST preserve

- Ordinary non-goal actionable packets MUST continue to validate, mirror, and
  snapshot without a scenario/node declaration.
- A goal-node packet MUST still require a matching compiled scenario
  declaration. The packet alone is not authority for its repository.
- `--scenario-file` and `--node-id` MUST be accepted only as a complete pair.
  Supplying either half alone must fail before repository-local writes.
- The scenario-declared repository root, alias, node ID, and complete
  `repositoryResolution` MUST continue to match the packet exactly. Forged or
  substituted root, alias, node, or resolution values must refuse with zero
  repository-local side effects.
- `state-snapshot.sh` MUST carry the caller's scenario and node through to
  `mirror-session`; it must not infer a declaration from packet fields, downgrade
  `scopeKind`, or call the ordinary-packet path for a goal node.
- No bypass, skip flag, permissive fallback, or optional weakening may be added.
  The correct fix transports the missing proof to the existing validator.

### Test-first fix contract

The implementation owner MUST add the positive regression first and show it
failing against the current source before changing production scripts. The
security-negative cases are part of the same finding set and cannot be
cherry-picked away.

| Regression case | Required assertion |
|---|---|
| Valid goal-node direct mirror | `mirror-session` accepts the matching scenario/node pair, writes the exact scoped binding mirror, and leaves command-level control unchanged. |
| Valid goal-node snapshot plus convergence | `state-snapshot.sh` forwards the pair; mirror succeeds; exactly one new turn snapshot and the requested convergence entry are durable. This is the positive case that MUST fail before the fix. |
| Wrong node | A scenario paired with a different or absent node refuses and writes no mirror, turn snapshot, or convergence entry. |
| Changed repository alias, root, or resolution | Same-root forged alias, alternate eligible root, and mutated `repositoryResolution` each refuse; none may fall through to ordinary packet validation. |
| Missing half of the pair | Scenario-only and node-only invocations of both `mirror-session` and `state-snapshot.sh` return usage failure and create no repository-local state. |
| Ordinary packet | Existing non-goal mirror and snapshot calls with no scenario/node pair continue to succeed unchanged. |
| `convergenceLoops[]` update | The goal-node snapshot updates only the matching `(specDir, agent)` entry, preserves unrelated entries, and records the requested iteration count. |
| No lost `turnSnapshots[]` update | Pre-existing snapshots remain byte-for-byte equivalent, one new record is appended, and the mirror plus convergence update do not overwrite that append. |

Likely regression ownership:

- `bubbles/scripts/repository-binding-selftest.sh`: direct mirror pair parsing,
  valid goal-node mirror, wrong-node and forged root/alias/resolution refusals,
  missing-half refusals, and the ordinary-packet compatibility case.
- `bubbles/scripts/state-snapshot-selftest.sh`: end-to-end forwarding, the
  valid goal-node convergence write, and preservation of both
  `turnSnapshots[]` and unrelated `convergenceLoops[]` records.

After the focused selftests are red then green, the implementation must run the
canonical `framework-validate` and `release-check` surfaces. This entry records
the required commands; it does not claim either has run or passed.

### Likely owned source and conformance surfaces

The next owner should inspect and change only what the regression proves is
needed:

- `bubbles/scripts/state-snapshot.sh`
- `bubbles/scripts/repository-binding.sh`
- `bubbles/scripts/state-snapshot-selftest.sh`
- `bubbles/scripts/repository-binding-selftest.sh`
- `agents/bubbles_shared/operating-baseline.md`
- `agents/bubbles.goal.agent.md`

Other orchestrator instructions that publish the same state-snapshot syntax
should be updated only if the shared invocation contract changes. Gate G082's
cap semantics and `validate_packet_internal`'s goal-node refusal do not need to
be weakened. Downstream `.github/bubbles/**` copies are propagation targets
after the source fix, never direct edit targets for this bug.

### Next owner (analysis-phase record)

`bubbles.implement` owned the test-first source fix under canonical mode
`fix action:fastlane target:bug` / persisted alias `bugfix-fastlane`. It was
required to begin with the failing positive regressions above and return the
complete finding set to `bubbles.test` and `bubbles.validate`; BUG-015 was to
remain OPEN until that separate delivery and certification work completed. The
closure evidence below records the later completion of that condition without
rewriting the original fix contract.

### Closure evidence

**Claim Source:** inherited validate/test execution evidence from the
validate-owned stable release certification supplied to this bookkeeping node.
This `bubbles.bug` invocation did not execute the focused suites or
`release-check`.

- Closure was certified at exact revision
  `264505f535c70c79d194fc8d1561688dcdb0a025`. Pre/post `HEAD`, `origin/main`,
  clean status, and controlling file hashes were byte-identical throughout the
  final release gate.
- The focused BUG-015 repository-binding suite passed 61/61 assertions. The
  state-snapshot suite passed 73/73 assertions across 13 cases.
- The repaired source state-snapshot processed the real revision-4 knb
  `fix-goal-node-state-snapshot-binding` packet and recorded turn 87 at
  convergence iteration 2.
- A follow-up case-collision false positive was fixed test-first and
  independently verified: exact duplicate Git index stages deduplicate, while
  real `Foo.md`/`foo.md` path variants still fail.
- The independent focused slice passed all 17 required checks with 343
  assertions and zero failures. It reported two optional schema skips before
  managed Python activation.
- The managed goal-contract selftest then passed 10 consecutive serial runs at
  the pinned revision, each with 103 assertions and zero skips or failures.
- The final canonical `bash bubbles/scripts/cli.sh release-check` passed at the
  pinned unchanged revision. Its embedded framework validation passed 280
  checks in 2073 seconds with no failed checks, and the release-manifest check
  passed with 825 managed files. Explicit skips were limited to the two
  denylisted repository-binding selftests, no configured live code-index
  repository, and no reachable live judge URL.
- Earlier broad validation attempts remain part of the history, not closure
  proof: some failed, and others were invalidated by concurrent revision
  movement. Closure rests on the separate stable certification above.
- Installed downstream copies remain propagation targets through normal
  framework installation. This entry does not claim that propagation occurred;
  the inherited evidence proves source closure only.

---

## BUG-016 — the guard runs `artifact-lint.sh` under a hardcoded 60s budget and discards its output, so a lint that PASSES in ~60s is reported as a blocking failure, non-deterministically

- **Filed:** 2026-08-11
- **Renumbered:** filed as BUG-015, renumbered to BUG-016 during rebase. An
  unrelated BUG-015 (the `state-snapshot.sh` goal-node drop, directly above)
  reached `origin/main` first and owns that number. Two sessions filing against
  one shared working copy collide on the next free id; the entry that landed
  first keeps it.
- **Disposition:** FIXED in `7e71f02`. The fix was written in a concurrent
  session that hit the same defect from the other end — certifying the same
  downstream packet — and arrived at all three recommended parts below
  independently, which is corroboration of the diagnosis rather than a
  coincidence. The DEFERRAL reason recorded at filing (unwilling to edit
  `state-transition-guard.sh` while a concurrent session held uncommitted
  changes to it) was sound; that session committed its change from an isolated
  worktree for exactly that reason.
- **Discovered by:** certifying downstream research-lab
  `specs/017-decision-attention-and-developing-situations`. Two guard runs
  minutes apart over the SAME tree disagreed: one reported
  `🔴 BLOCK: Artifact lint FAILED`, the other `verdict: PASS` with
  `failureCount: 0`.
- **Severity:** high, because of what the false failure LOOKS like. It does not
  present as flakiness — it presents as a specific, named, blocking artifact
  defect, and the remedy it prints sends the reader to a command that exits 0.
- **Affects:** `bubbles/scripts/state-transition-guard.sh`, the Check 13
  artifact-lint invocation.

### The defect

```bash
if BUBBLES_WORKFLOWS_FILE="$workflow_registry_file" bubbles_run_with_timeout 60 bash "$lint_script" "$feature_dir" > /dev/null 2>&1; then
```

Two properties combine, and neither is a problem alone:

1. The budget is the **literal 60**, not derived from packet size and not
   configurable.
2. Output is discarded, so `timeout`'s exit 124 is indistinguishable from a
   genuine non-zero lint exit. Every non-zero outcome takes the same branch.

Measured on the discovering packet:

```text
$ bash artifact-lint.sh specs/017-...      →  exit 0   elapsed 60s
$ timeout 60 bash artifact-lint.sh ...     →  exit 124
```

A 60-second lint under a 60-second budget is a coin flip. The packet is a
six-scope feature with per-scope reports — large, but not pathological — and
lint cost grows with scope count and evidence-block count, so **this gets more
likely as packets grow, not less**.

### Why the reported message makes it worse

```text
🔴 BLOCK: Artifact lint FAILED — run 'bash bubbles/scripts/artifact-lint.sh <dir>' for details
```

Following that instruction runs the lint WITHOUT the timeout, so it prints
`Artifact lint PASSED.` and exits 0. The guard and its own suggested diagnostic
contradict each other, and the contradiction points away from the real cause. In
the discovering session this consumed a full investigation cycle — including
building a pinned scratch worktree to prove the lint genuinely passes at
`status: done` — before the timing was measured.

### Recommended fix

Three parts, smallest first:

1. **Stop discarding the outcome.** Capture the exit code and distinguish 124
   from every other non-zero value. A timeout is an infrastructure condition and
   MUST NOT be reported as an artifact defect.
2. **Make the budget adequate and configurable.** Raise the default well clear
   of observed cost and honour an env override, so a large packet is not
   silently penalised for being large.
3. **Report a timeout honestly.** Say the lint exceeded its budget, print the
   budget, and either fail with that distinct reason or surface it as advisory —
   but never under a message that names artifact quality.

Guard the fix with a case that stubs a lint script sleeping past the budget and
asserts the guard does NOT emit "Artifact lint FAILED" for it, so the two
outcomes cannot be re-conflated.

### Scope note

Any guard check wrapped in `bubbles_run_with_timeout ... > /dev/null 2>&1` has
the same shape. This entry documents the instance that was measured; a sweep for
the pattern is worth doing while fixing it.

### What the fix actually did (`7e71f02`)

All three parts, in the order recommended:

1. The exit code is captured and `124` takes its own branch, so a lint that did
  not COMPLETE is never reported as a lint that completed and rejected.
2. The budget moved `60` → `300` and honours `BUBBLES_ARTIFACT_LINT_TIMEOUT`.
3. The timeout message names the cap and points at both remedies. Both outcomes
  still BLOCK — a lint that cannot finish is *unknown*, not *fine* — but they
  are no longer the same message.

The suggested guard case was written as three, two of them adversarial in
opposite directions: the timeout path must not borrow the failure wording (or
the distinction is cosmetic), and the SAME fixture at the default cap must NOT
take the timeout path (or the case is tautological and would pass even if the
branch never fired). Suite: 255 passed, 0 failed.

The measurement in this entry was also refined by the fixing session. The cost
is not "~60s"; it is load-dependent. The same lint over byte-identical content
measured 32s, 73s, 90s and 103s on one machine. That is why the failure looked
non-deterministic: the budget sits inside the spread, so the verdict tracked
machine load rather than the packet.

## BUG-017 — 29 of 32 workflow modes with a below-`done` ceiling declare no `transitionAudit`, so the transition contract refuses to resolve and the ceiling they advertise is mechanically unreachable

- **Filed:** 2026-08-11
- **Disposition:** open. Re-measured 2026-08-17 against `bubbles/workflows/modes.yaml`:
  **29 of 32** modes with a below-`done` ceiling declare no `transitionAudit`, and
  three declare one — `spec-scope-hardening`, `product-to-planning` and
  `framework-health`. The filed 31-of-33 and "two" figures repeated in the body
  below are superseded by that measurement. The fix is still a design decision (a
  fourth audit profile, or an explicit "no audit contract applies" declaration),
  not a one-line change, so it remains filed rather than patched. See the dated
  sub-note at the end of this entry for the measured ceiling breakdown and for a
  separate, narrower applicability finding that WAS fixed on 2026-08-17.
- **Discovered by:** certifying downstream research-lab packets. `BUG-005`,
  `015` and `016` all certified cleanly at `specs_hardened` because
  `product-to-planning` is one of the **two** below-`done` modes that declare a
  `transitionAudit`. Auditing why those two worked surfaced that the other 31 do
  not.
- **Severity:** high. It is the same defect class as G087 before `81cac4e`: a
  terminal state the registry advertises with no truthful path to it. A packet
  run under any of the 31 modes cannot be promoted to its own declared ceiling
  through the guard, so it either sits below its ceiling forever or gets pushed
  to a status it did not earn.
- **Affects:** `bubbles/workflows/modes.yaml` (the 31 mode definitions),
  `bubbles/scripts/transition-contract-resolver.sh` (the refusal point).

### The defect

`transition-contract-resolver.sh` refuses any mode without a supported
`transitionAudit` contract. `state-transition-guard.sh` already states this as
settled behaviour at the Check 6 fallback comment:

> (Modes with no transitionAudit profile never reach Check 6 —
> transition-contract-resolver.sh blocks them first with
> E009-AUDIT-PROFILE-MISSING/UNSUPPORTED.)

What is NOT recorded anywhere is how many modes that sentence disqualifies.

### Evidence

Counted against the mode registry:

```
total modes        : 62
ceiling below done : 33
NO transitionAudit : 31
```

The two that resolve are `spec-scope-hardening` and `product-to-planning`, both
bound to `planning-maturity-v1`. The 31 that cannot include `validate-only`,
`audit-only`, `validate-to-doc`, `docs-only`, `spec-review-to-doc`,
`retro-to-review`, `release-planning-to-doc`, `journey-refinement`,
`readiness-review`, `production-adversarial-probe`, `resume-only`, the three
`delivered_pending_activation` modes, all five `release-train-*` modes, all six
`upkeep-*` modes, all three `propagate-*` modes, `incident-fastlane`, and
`framework-health`.

Controlled A/B — two fixtures identical except for `workflowMode`:

```
$ bash bubbles/scripts/transition-contract-resolver.sh /tmp/.../with-audit/specs/900-probe
{"schemaVersion":"transition-contract/v1", ... "workflowMode":"product-to-planning",
 "auditProfile":"planning-maturity-v1","statusCeiling":"specs_hardened",
 "targetStatus":"specs_hardened","requiredGates":["G001",...,"G073"], ...}
  RESOLVER_EXIT=0

$ bash bubbles/scripts/transition-contract-resolver.sh /tmp/.../no-audit/specs/900-probe
E009-AUDIT-PROFILE-UNSUPPORTED: resolved mode has no supported transition audit contract
```

Same fixture, same fields, one word different. The first resolves a full
contract; the second cannot resolve one at all.

### Why this is not merely cosmetic

A missing `transitionAudit` is not "no extra audit required" — it is a hard
refusal before any gate runs. So the affected modes advertise a `statusCeiling`
in the registry that the mechanical path cannot deliver. `is-terminal-for-mode.sh`
will happily report `validated` as terminal-for-mode for `validate-to-doc`, and
the portfolio sweeps that call it will treat such a packet as closed, while the
guard can never certify it there.

### Recommendation

Decide per mode, do not blanket-assign:

1. Modes that genuinely complete work at a below-`done` ceiling
   (`validate-to-doc`, `docs-only`, the `upkeep-*` and `release-train-*`
   families) need an audit profile expressing what completeness means for them —
   a fourth profile alongside `delivery-completion-v1`,
   `delivery-completion-fast-v1` and `planning-maturity-v1`.
2. Modes whose ceiling is a *report* rather than a delivery
   (`release-train-status-all`, `propagate-audit`) may legitimately need no
   contract, but that should be an explicit declaration the resolver honours,
   not an omission it refuses.

The distinction matters: today both cases look identical to the resolver, which
is exactly why the gap went unnoticed.

### 2026-08-17 — measured shape and the applicability finding

Measured against `bubbles/workflows/modes.yaml`. **32** modes declare a
below-`done` `statusCeiling`. **3** of them declare a `transitionAudit`:
`spec-scope-hardening` and `product-to-planning` (both `planning-maturity-v1`,
ceiling `specs_hardened`) and `framework-health` (`framework-proposal-v1`,
ceiling `framework_proposal_written`). The remaining **29** declare none, and
those are the unreachable ceilings.

The 29 unreachable ceilings break down as: `validated` (5), `docs_updated` (5),
`delivered_pending_activation` (3), and one each of `backup_verified`,
`bcdr_verified`, `compliance_swept`, `flags_audited`, `incident_mitigated`,
`patched`, `propagated_backward`, `propagated_forward`, `propagation_audited`,
`restore_verified`, `secrets_rotated`, `train_cut`, `train_promoted`,
`train_retired`, `train_rolled_back`, `train_status_reported`. Note that
`specs_hardened` and `framework_proposal_written` are NOT in this list: those are
exactly the ceilings of the three modes that DO declare a contract, so they are
reachable.

Every one of the 29 is an OPERATIONAL outcome, not a spec-completion claim, and
neither existing profile fits: `delivery-completion-v1` asserts scope/DoD
completion these modes have no scopes for, and `planning-maturity-v1` asserts a
planning maturity they are not producing. That confirms this entry's own
suggested direction — a further audit profile expressing completeness for
operational outcomes — as the shape of the fix, and it remains a design decision
rather than a patch.

**Separate finding, fixed in this session.** `state-transition-guard.sh` mapped
only 2 of the 4 supported audit profiles to check classes, so
`delivery-completion-fast-v1` and `framework-proposal-v1` reported
`applicableCheckClasses: []` — an empty, false declaration inside a
machine-readable contract. Branches were added for both. This list is **REPORTED
ONLY**: it is consumed at exactly one place, the `applicableCheckClasses` line of
the `TRANSITION_GUARD_RESULT_V1` block, and it gates no check execution.

A second, larger defect was discovered while verifying that fix and is NOT fixed
here: the guard's own contract validator accepts only `planning-maturity-v1` and
`delivery-completion-v1`, so a contract on either of the other two supported
profiles is rejected as malformed (`E009-AUDIT-PROFILE-CONTRADICTION`, exit 2)
before the mapping is reached. `rapid-tool-delivery` and `framework-health`
therefore cannot pass the transition guard at all today, and the two new branches
are unreachable until that validator is reconciled with the resolver. Widening it
is a design decision, not a patch: it would newly admit those modes into the full
check suite, and an audit-only mode measurably fails the delivery-completion
checks when admitted.

---

## BUG-018 — `artifact-lint.sh`'s evidence-signal check counts Gherkin `Scenario:` blocks as execution evidence, and its file-path signal accepts `.js` but not `.mjs`

- **Filed:** 2026-08-11
- **Disposition:** FIXED, same day, in the framework rather than worked around
  downstream. See "### Fix" below.
- **Severity:** medium — it does not corrupt state, but it makes a fully-verified
  packet unpromotable, and the only way to satisfy it is to fabricate.
- **Found by:** closing `specs/_bugs/BUG-007-decision-attention-contract-drift`
  in the `research-lab` downstream install. Every substantive gate passed
  (G022, G057, G060, G068, G070, G094, traceability, transition guard at
  `failureCount: 0`), tests were green, yet artifact-lint refused promotion with
  11 findings.

### Defect 1 — every fenced block is treated as an evidence block

`artifact-lint.sh` (the anti-fabrication section, around the
`Evidence block lacks terminal output signals (N/2 required)` failure) walks
**every** fenced code block in `report.md` and `scopes.md` and requires each to
carry at least 2 of its 7 "terminal output signals".

It does not discriminate by fence language or by section. So a Gherkin block:

````markdown
```gherkin
  Scenario: An empty attention tier with no recorded exclusions is refused
    Given a committed brief payload whose attention tier is empty
     When the publication gate runs
     Then publication is refused by name
```
````

…is counted as execution evidence and refused for having no exit code. A
specification block **can never** carry a test count or an exit code — that is
what makes it a specification. The same applies to file excerpts and diff hunks,
which legitimately carry no runner output.

The perverse incentive is the problem: the only way to clear the check on such a
block is to write an exit code above output that never came from a command,
which is precisely the fabrication this gate exists to detect.

**Suggested fix:** skip blocks whose fence language is a known non-transcript
language (`gherkin`, `diff`, `json`, `yaml`, `markdown`), or only apply the
check to blocks inside evidence-bearing sections / under a checked DoD item.

### Defect 2 — the file-path signal regex omits `.mjs`

Signal (ii) is:

```
([a-zA-Z0-9_-]+/[a-zA-Z0-9_.-]+\.(rs|py|ts|tsx|js|go|sh|sql|toml|yaml|json|proto|md)|\./)
```

`mjs` is absent, and `.mjs` does not match the `js` alternative because the
literal `\.` must immediately precede `js`. In a build-free ESM repository —
exactly what the framework's own downstream `research-lab` install is — a
genuine, executed command line such as:

```
$ node scripts/selftest.mjs
```

scores only ONE signal (the `^\$ ` shell-prompt signal), so real terminal
evidence is refused for not looking like terminal evidence. `cjs` is missing for
the same reason.

**Suggested fix:** add `mjs|cjs` to the alternation. Note the transition guard's
own copy of this regex (`_c11_sig_iii_re` in `state-transition-guard.sh`) has
the same omission, so both should move together — and they are already duplicated
rather than shared, which is a third, smaller finding.

### Why this was not worked around downstream

The packet was set to `blocked` with the blocker named in `blockedReason`,
rather than promoted to `done` by inventing signals. Recording the refusal
honestly is the behaviour the gate is meant to produce; the defect is that it
fires on artifacts that cannot possibly satisfy it.

### Fix

`artifact-lint.sh` now captures the fence language when a block opens and
exempts a block whose language is `gherkin`, `diff` or `mermaid` from both the
`>=3 line` and `>=2 signal` heuristics, reporting the exemption on stdout rather
than skipping silently. The exemption requires an **explicitly declared**
language — a bare ``` fence stays fully enforced, so it cannot be used to
silence a real evidence block. `mjs|cjs` were added to the file-path signal
alternation in `artifact-lint.sh` and to `_c11_sig_iii_re` in
`state-transition-guard.sh`.

Four selftest cases were added to `artifact-lint-selftest.sh`, two of which are
adversarial controls that fail if the fix is written as a blanket disable:

- **T12** a `gherkin` block is exempt, and the exemption is reported.
- **T13** the *identical content* in a **bare** fence is still refused. Without
  this, T12 would also pass had the whole check been disabled.
- **T14** `$ node scripts/selftest.mjs` now supplies a second signal.
- **T15** `$ node scripts/selftest.zzq` is **still** refused, proving T14 passes
  because `mjs` is recognised and not because the path check matches anything.

The remaining sub-finding — that the signal regex is duplicated between
`artifact-lint.sh` and `state-transition-guard.sh` rather than shared — is left
open deliberately. Extracting it into `guard-lib.sh` touches two hot guards and
belongs in its own change, not folded into a fix that must stay auditable.

## BUG-019 — Check 43 clone detection compares raw argv, so an honest re-run spelled two ways is accused of forgery

- **Filed:** 2026-08-11
- **Disposition:** FIXED, same day, in the framework. See "### Fix" below.
- **Severity:** high — it alleges forgery, the most serious thing this guard
  says, against work that did nothing wrong, and it blocks promotion of a spec
  that is otherwise clean.
- **Found by:** certifying `specs/112-macro-regime-evidence-stack` in the
  `QuantitativeFinance` downstream install. Every other gate passed —
  artifact-lint 0, traceability 0, G094 0 — and the transition guard reported a
  single failure, this one.

### Defect

Check 43's own comment states the boundary correctly:

> The rule is deliberately narrow, because the naive one is wrong: identical
> output from a RE-RUN of the SAME command is normal and must never fire.

The implementation did not honour it. It grouped receipts by `stdoutHash` and
fired whenever `map(.cmd) | unique | length > 1` — comparing the **raw argv
string**. An honest re-run is routinely spelled two ways inside one session, and
both spellings produce byte-identical stdout precisely because they are the same
command:

```text
933f9ae10795… reused by:
  bash bubbles/scripts/release-delivery-reconciliation-guard.sh --repo-root . --phase mvp --require-coverage
  AND
  bash bubbles/scripts/release-delivery-reconciliation-guard.sh --repo-root <abs-path> --phase mvp --require-coverage

d4069abf44b4… reused by:
  bash bubbles/scripts/artifact-lint.sh specs/095-research-plane-v1
  bash bubbles/scripts/artifact-lint.sh specs/095-research-plane-v1 SCN-095-CI01
```

The first pair differs only in whether one directory is named relatively or
absolutely. The second differs only by an optional trailing scenario-regex that
narrows a run without making it a different claim.

Two aggravating properties:

1. **The check is repo-global while the transition it gates is spec-scoped.**
   Neither cited group mentioned spec 112 at all — receipts from spec 095 work
   blocked spec 112's promotion.
2. **There is no honest exit.** The receipts are truthful, so the only ways to
   clear it are to delete evidence or to stop re-running commands. Deleting
   receipts to pass a gate is the structural fabrication the framework forbids.

This is distinct from BUG-007, which fixed the *empty-stdout* collision in the
same predicate. BUG-007's exemption is intact and still tested.

### Fix

Command identity is now `(executable basename, first positional subject)` —
the tool, and the subject it ran against — instead of the raw argv string.
Option flags and their values are dropped, so a re-spelled invocation collapses
to one identity, while `cargo test` versus `npm run lint` stay distinct and
still BLOCK.

The trade is recorded deliberately in-source: dropping option *values* means two
runs of one tool over one subject under different flags no longer collide. That
is intended. A false CLONE accuses honest work of the most serious allegation
this guard makes, and the surviving rule still catches what G021 exists for —
one captured result reused for an UNRELATED claim.

Evidence: against the real receipt log that triggered this, the old predicate
reports 2 clones and the new one reports 0.
`evidence-admission-hardening-selftest` is 16 passed / 0 failed, with the
genuine two-different-commands case still blocking. Two regression fixtures were
added for the shapes above (`963-c43-clone-same-command-respelled`,
`964-c43-clone-same-command-optional-arg`). The
`map(select((.stdoutHash` line is preserved verbatim so BUG-007's
predicate-extraction test keeps resolving.

## BUG-020 — Check 6B requires an `executionHistory` agent named literally `bubbles.<phase>`, so `analyze` and `bootstrap` can never be certified

- **Filed:** 2026-08-11
- **Disposition:** **FIXED** 2026-08-17 in `9ffc483`. The filed scope understated
  it. `phase_owner_agent()` hardcoded `bubbles.<phase>`; `bubbles/workflows.yaml`
  declares owners for 30 phases and 8 of them disagree, not the two named below:
  `analyze`, `bootstrap`, `discover` and `finalize` (owner `activeWorkflowRunner`),
  `bug-discovery` (`bubbles.bug`), `certify-state` (`bubbles.validate`),
  `interrogate` (`bubbles.grill`) and `select` (`bubbles.iterate`). For all 8 the
  guard demanded an agent that does not exist — `bubbles.bootstrap` was deleted
  upstream in `8a4f32d`. The owner is now READ from the registry;
  `activeWorkflowRunner` phases accept any agent in `agent-capabilities.yaml`
  `workflowModeGrants.agents`, the list Gate G064 already lints, so there is no
  second copy. The legacy name-derived value is retained, so the 22 already-correct
  phases are behaviourally identical.
- **Severity:** medium — it does not corrupt state and it fails safe (it refuses
  a claim rather than admitting a false one), but it makes a complete phase list
  unreachable, so `certifiedCompletedPhases` cannot be read as "what ran".
- **Found by:** certifying `specs/112-macro-regime-evidence-stack` in the
  `QuantitativeFinance` downstream install under `product-to-planning`.

### Defect

Gate G022 Check 6B accepts a phase claim only when `executionHistory` carries an
entry whose agent is named literally `bubbles.<phase>`. For several phases no
such agent exists, because the phase is executed by differently-named
specialists:

| Phase | Executed by | `bubbles.<phase>` exists? |
|---|---|---|
| `analyze` | `bubbles.analyst`, `bubbles.ux` | no |
| `bootstrap` | `bubbles.design`, `bubbles.plan` | no |
| `audit` | `bubbles.audit` | yes, but it records `execution.audit`, not an `executionHistory` entry |

So `analyze` and `bootstrap` are **structurally uncertifiable** — no honest
execution can ever satisfy the check — and `audit` is excluded unless the
auditor also writes a provenance entry.

`bubbles.validate` hit this while certifying spec 112. Claiming `audit` tripped
phase-impersonation; authoring an `executionHistory` entry on `bubbles.audit`'s
behalf to satisfy it would be exactly the impersonation G022 exists to detect.
It correctly declined, and certified `["harden","validate"]` with the reasoning
recorded in `certification.note`.

The result is safe but lossy: a reader of `certifiedCompletedPhases` sees two
phases where six ran, and `execution.audit` is the only record that audit
happened at all.

### Recommended fix

Map phase to its *owning agents* rather than to a name-derived agent id, or
accept any agent the mode's phase-owner registry names for that phase. The
registry already knows which agent owns which phase; Check 6B is re-deriving it
from a string convention that the agent roster does not follow.

## BUG-021 — `state-transition-guard.sh` rewrites `report.md` on first run, so `targetRevision` cannot discriminate staleness

- **Filed:** 2026-08-11
- **Disposition:** open in-repo framework defect, ANALYZED not fixed.
- **Severity:** low — no state is corrupted and no false claim is admitted, but
  it silently disarms a staleness signal that readers are invited to trust.
- **Found by:** certifying `specs/112-macro-regime-evidence-stack` in the
  `QuantitativeFinance` downstream install, when an audit attempt's recorded
  `targetRevision` did not match a freshly-resolved contract.

### Defect

Running `state-transition-guard.sh` against a spec mutates that spec's
`report.md` by one byte on the first run, and is byte-stable on re-run. Because
`report.md` is inside the revision-covered artifact set, the act of *measuring*
the packet changes the revision being measured.

Consequently a recorded `targetRevision` will differ from a later re-resolution
even when nothing substantive changed, and the difference is indistinguishable
from genuine drift by digest alone.

`bubbles.validate` isolated this while investigating an apparent mismatch on
spec 112: a byte-level projection showed the canonical `state.json` projection
identical to the committed revision, and every other revision-covered artifact
carried an mtime earlier than the audit attempt's instant. The whole delta was
`report.md` prose. It then found the guard itself as the writer.

### Why it matters

`targetRevision` reads as a staleness discriminator — that is its evident
purpose — but any consumer comparing it across a guard run will see a mismatch
that means nothing. A reviewer who trusts it will chase a phantom; one who
learns to ignore it loses the real signal too.

### Recommended fix

Either exclude `report.md` from the revision-covered set for this purpose, or
make the guard's own write happen before the revision is computed, so that
measuring a packet does not change it.

---

## BUG-022 — `state-consistency-scan.sh` counts an UNCHECKED scope-status picker as a Done scope, so every freshly-scaffolded `not_started` packet is reported as hiding finished work

- **Filed:** 2026-08-12
- **Disposition:** FIXED, same day, in the framework. See "### Fix" below.
- **Severity:** medium — advisory-only (the scan always exits 0), so it blocks
  nothing. The harm is trust: the finding fires on the canonical scaffold, so the
  operator learns to ignore a scan whose whole job is to surface real drift.
- **Found by:** reviewing the one remaining finding in the `research-lab`
  downstream install after clearing two genuine mirror-divergences. The finding
  named `012/bugs/BUG-002` with `doneScopes=2`, but that packet declares itself a
  "DISCOVERY + ROUTING packet, `status: not_started`" and **nothing in it is
  checked**.

### Defect

The done-scope counter matched the bare word `Done` anywhere on a `**Status:**`
line:

```
grep -hE '^\*\*Status:\*\*.*Done'
```

The canonical scope scaffold renders all three options on one line, unchecked:

```
**Status:** [ ] Not started | [ ] In progress | [ ] Done
```

That line starts with `**Status:**` and contains `Done`, so an untouched template
counted as a completed scope. Two such lines produced `doneScopes=2` for a packet
with zero completed scopes.

A second, quieter false positive shared the same root: `[x] In progress | [ ] Done`
also matched, so a scope explicitly marked *in progress* counted as Done.

### Fix

Require `Done` to be **selected**, not merely present — either a plain
`**Status:** Done` (the legacy form) or a checked `[x] Done`:

```
grep -hE '^\*\*Status:\*\*([[:space:]]*Done|.*\[[xX]\][[:space:]]*Done)'
```

Verified by running both regexes against the exact fixture lines:

| fixture | old | new |
|---|---|---|
| `[ ] Not started \| [ ] In progress \| [ ] Done` (the bug) | 1 | **0** |
| `[x] In progress \| [ ] Done` | 1 | **0** |
| `[ ] Not started \| [ ] In progress \| [x] Done` | 1 | **1** |
| `Done` (legacy plain form) | 1 | **1** |
| `Not Started` | 0 | 0 |

End-to-end on the `research-lab` downstream install: the installed scan reported
1 status-behind-evidence finding; the fixed scan reports `OK — zero findings
across 36 spec(s)`.

Three selftest cases were added (11, 12, 13). Two are adversarial controls that
fail if the fix were written as a blanket disable: a checked `[x] Done` picker
must still be reported, and the pre-existing plain-`Done` case (4) must keep
passing. `state-consistency-scan-selftest.sh` is 13/13.

The regex uses only POSIX ERE classes, so it behaves identically under BSD grep;
`macos-portability-guard.sh` passes on the changed surface.

---

## BUG-028 — Check 43 treats identical deterministic output as cloned evidence and lets unrelated specs block each other

- **Filed:** 2026-08-12
- **Disposition:** **FIXED** 2026-08-17 in `3c03201` — for the false-accusation defect; recommendations 1-2 remain **OPEN** (see below). Check 43 no longer treats a differing `evidence_category` as grounds for a forgery allegation: category comes from operator-supplied tags and describes a run, not the program that ran. Identity is now judged by the PROGRAM (`program_identity`); a dispatch verb (`run`/`exec`) keeps the script name, so `npm run lint` and `npm run test` stay distinct; and `target_identity` now carries the positional subject, so two files handled in one scope are distinct. Live effect on this repo's tool log: **5 clone groups → 0**, with 3 of them correctly accepted as deterministic siblings. All adversarial bounds retained (cargo-vs-npm, facet-1 single-target, facet-2 wrappers, IV-F4).
  - **Rejected approach, recorded so it is not retried blind:** spec-scoping the clone groups (restricting a group to the certifying spec) was implemented and MEASURED — it silenced **all 14** adversarial assertions, because receipts rarely carry the certifying spec's name. It was REVERTED as a false-PASS regression.
  - **Still open:** correct scoping depends on this entry's own recommendations 1-2 (receipt identifiers recorded on admitted claims), which remain unimplemented. That part of BUG-028 stays explicitly OPEN as a follow-up; the false-accusation defect is closed.
- **Severity:** high. The check blocks certification and falsely accuses honest executions of evidence reuse.
- **Found by:** current-policy revalidation of downstream `research-lab/specs/011-volatility-regime-and-sizing-lab`.
- **Distinct from:** BUG-007 excluded empty stdout. BUG-019 normalized equivalent command spellings. This defect concerns substantive deterministic output from separate commands.

### Reproduction

The downstream transition guard reported:

```text
BLOCK: Evidence receipt CLONE — one captured stdout is cited by two different commands
205233224dd1… reused by:
bash .github/bubbles/scripts/artifact-lint.sh specs/_bugs/BUG-001-central-provider-credential-security
AND
bash .github/bubbles/scripts/artifact-lint.sh specs/_bugs/BUG-003-bond-regime-simple-power-model-digest-divergence
```

The tool log contains separate successful executions with different durations. Both commands produce the same deterministic summary, such as `Artifact lint PASSED.` Their matching output bytes do not prove receipt reuse.

Check 43 reads the repository-wide `.specify/runtime/tool-calls.jsonl`. It groups every non-empty `stdoutHash` across every spec. It then blocks when one hash has more than one normalized command identity.

### Root cause

`state-transition-guard.sh` assumes different commands cannot honestly produce identical substantive stdout. Deterministic validators disprove that premise. The check also ignores the target spec and certifying window, so receipts from unrelated packets block the active transition.

### Expected behavior

Evidence reuse detection must prove that one receipt backed multiple unrelated claims. Equal output content is only similarity evidence. It is not proof that one execution was reused.

### Recommended fix

1. Give each tool-log receipt a stable receipt identifier.
2. Record receipt references on admitted evidence claims.
3. Block only when one receipt identifier backs incompatible claims.
4. Scope the check to the active spec and certifying window.
5. Keep equal output hashes as advisory diagnostics when receipt identity is unavailable.

Add adversarial selftests for two different spec-scoped artifact-lint runs with equal stdout. They must pass. Reusing one receipt identifier across two incompatible claims must still fail.

---

## BUG-029 — G010 declares unchecked user validation blocking, but terminal transitions do not enforce it

- **Filed:** 2026-08-12
- **Disposition:** **FIXED**, before 2026-08-17. Gate `G136` is registered in `bubbles/registry/gates.yaml` (line 1037, with its `enforcedBy` entry at line 1177), and `bash tests/regression/test_35_human_acceptance_terminal.sh` reports 9 passed, 0 failed, exit 0. The ledger was stale: the fix landed but this entry was never updated.
- **Severity:** high. A spec can be certified `done` while its human acceptance artifact reports a regression.
- **Found by:** downstream spec 011 retained an unchecked acceptance item while both status mirrors said `done`.

### Reproduction

The downstream artifact contained:

```markdown
- [ ] Final `done` certification is confirmed by a green full-suite regression.
```

The spec was nevertheless certified `done`. The current `state-transition-guard.sh` still does not report this unchecked item.

The framework policy is explicit:

- `artifact-lifecycle.md` says unchecked `uservalidation.md` items represent user-reported regressions and block forward progress.
- `bubbles.validate.agent.md` says validation fails when any unchecked item exists.
- G010 is a required `user_validation_gate` for full delivery.

`artifact-lint.sh` checks only that the checklist contains at least one checked-by-default item. It does not reject remaining unchecked items. No state-transition check implements the missing terminal assertion.

### Root cause

G010 is registered as `mode-required` without a script-backed enforcer. The agent policy exists, but the terminal guard does not verify its required state.

### Expected behavior

A terminal completion transition must fail when the checklist contains any unchecked item. Agents must not toggle human acceptance to clear the failure. They must route the reported regression to its owner.

### Recommended fix

Add a dedicated user-validation guard. Wire it into terminal transitions and G010 metadata. The guard should:

1. Parse only the `## Checklist` section.
2. Reject every unchecked item for a terminal completion target.
3. Print the item text without changing it.
4. No-op for planning targets that only create the checked-by-default template.
5. Include a red fixture with one checked and one unchecked item. This defeats the current `at least one checked` false pass.

---

## BUG-030 — G057 accepts linked test titles that do not exist

- **Filed:** 2026-08-12
- **Disposition:** open — reclassified 2026-08-17 as **mechanism delivered, enforcement opt-in**. The resolver exists and is wired: `bubbles/scripts/scenario-test-resolve.sh` is invoked by `bubbles/scripts/guards/control-plane-checks.sh` (line 166) and by `bubbles/scripts/verify-changed-specs.sh` (line 178). Its default posture is ADVISORY: `control-plane-checks.sh` sets `scenario_resolution_mode="advisory"` and, when a linked test fails to resolve, warns "linked tests do not resolve — ADVISORY until scenarioResolution: block is set" (line 194). It blocks only when a repository opts in with `scenarioResolution: block` in `.github/bubbles-project.yaml` or `bubbles-project.yaml` (line 182). G057 therefore still ACCEPTS linked test titles that do not exist in the default configuration, so the original defect persists there.
- **Severity:** high. Scenario certification can claim live coverage that no executable test carries.
- **Found by:** exact-link audit of downstream spec 011.

### Reproduction

The scenario manifest referenced three absent Playwright titles:

```text
SCN-011-001 -> Regression BS-001: high-persistence forecast stays elevated and typed forecast
SCN-011-003 -> Regression BS-003: sizing multiplier throttles to about half in a storm with a worked example
SCN-011-012 -> Regression BS-012: EWMA-vs-GARCH persistence divergence is shown not averaged
```

The test file had no tests with those titles. Artifact lint and traceability still passed.

### Root cause

`guards/control-plane-checks.sh` counts `linkedTests` fields but does not parse their values. `traceability-guard.sh` searches for structured `"file"` fields. It does not parse the repository's string form, `path/to/test#exact title`.

G057 promises that each scenario maps to real live-system BDD coverage. Field presence and file existence do not satisfy that contract.

### Expected behavior

Every active linked-test reference must resolve to a real file and a real test declaration. Certification must fail on a missing file, missing title, duplicate ambiguous title, or incompatible test category.

### Recommended fix

1. Parse `scenario-manifest.json` with a structured JSON parser.
2. Support the documented string form and any structured reference form.
3. Resolve each path against the repository root.
4. Resolve each exact test title through a project test adapter or a conservative source declaration scan.
5. Compare `requiredTestType` with the resolved runner category.
6. Add red fixtures for a real file with an absent title and for a unit test linked as required E2E coverage.

---

## BUG-031 — downstream repositories receive completion guards but no automatic changed-spec enforcement path

- **Filed:** 2026-08-12
- **Disposition:** narrowed 2026-08-17. The integration defect is RESOLVED except for one residual item. `bubbles/scripts/verify-changed-specs.sh` and the CI workflow template `templates/bubbles-verify-changed-specs.yml.tmpl` now ship downstream — both are listed in `bubbles/release-manifest.json` — so an adopting repository receives the changed-spec command and the CI integration path it lacked. The residual open item is recommendation 5 below: `doctor` still does not report blocking posture when a repository declares certification-required validation but has no local or CI invocation of that command. That item stays open; the rest of this entry is closed.
- **Severity:** high. Certified planning truth can change and deploy without G088 running.
- **Found by:** the July 30 post-certification edit to downstream spec 011.

### Reproduction

G088 existed in the downstream installation before the edit. The edit changed `spec.md` after `certifiedAt` without setting `requiresRevalidation:true`. The normal Pages workflow still accepted later commits.

The downstream repository has:

- no `pre-commit` hook;
- no `pre-push` hook;
- no `core.hooksPath`;
- no workflow invoking `state-transition-guard.sh`, `done-spec-audit.sh`, or `post-cert-spec-edit-guard.sh`.

The Bubbles CLI rejects hook installation in consumer repositories:

```text
Bubbles git hooks may only be installed in the Bubbles framework repo.
Consumer repos should use Bubbles but must not install Bubbles-managed pre-commit/pre-push hooks.
```

The status-transition skill still states that pre-push runs `done-spec-audit.sh --profile changed` and that the mechanical guard runs in pre-push and CI.

### Root cause

The installer ships guard scripts but no downstream execution surface. Source-repo hook generation cannot satisfy downstream enforcement because the CLI explicitly forbids those hooks there.

### Expected behavior

Every adopted downstream repository needs one supported, generic changed-spec command and one supported CI integration path. A certified planning edit must fail before merge or deployment.

### Recommended fix

1. Add a downstream command that accepts base and head revisions.
2. Discover every changed spec, including planning files when `state.json` is untouched.
3. Run G088 and the current changed-spec audit for each target.
4. Ship a reusable CI workflow or generated workflow template that invokes this command.
5. Make `doctor` report blocking posture when a repo declares certification-required validation but has no local or CI invocation.
6. Correct the status-transition documentation so it names the actual supported downstream enforcement path.

Add an integration fixture where only `spec.md` changes after certification. The downstream command and workflow must both reject it.

---

## BUG-032 — planning-maturity guards confuse prose, output equality, and terminality with stronger contract facts

- **Filed:** 2026-08-15
- **Disposition:** open. All four guard repairs (D1-D4) are IMPLEMENTED and
  landed on `main` in commit `0531189`; the contract documentation for G043 and
  G101 is now reconciled to them. The packet is NOT closed: it is not
  validate-certified, and its Scope 4 obligations still require full
  `framework-validate` and `release-check` evidence that no session has captured
  against the current tree. Per Gate G095 this is a tracked OPEN defect with a
  recorded reason.
- **Severity:** high. Valid planning can be blocked, honest evidence can be
  accused of cloning, and planning maturity can be counted as release delivery.
- **Canonical packet:**
  [`bugs/BUG-032-planning-maturity-guard-false-positives/`](bugs/BUG-032-planning-maturity-guard-false-positives/bug.md)
- **Affects:** Check 8B consumer-impact classification, Check 5A SLA/SLO
  classification, Check 43 receipt clone identity, and G101 release-delivery
  reconciliation.
- **Related:** BUG-028 is the standalone predecessor for the deterministic
  validator receipt-hash defect. BUG-032 subsumes its implementation planning;
  BUG-028 remains open until BUG-032 D3 is validate-certified. BUG-033 refines
  the same Check 43 surface for repeated honest re-runs.

The packet defines four ordered scopes, exact negative and adversarial fixtures,
persistent selftest surfaces, mode-aware delivery semantics, documentation
reconciliation, and exact validation commands.

### Delivered so far

- Check 8B now fires only on an explicit mutation verb (`renames`/`removes`/
  `moves`/`deprecates`) co-occurring with a consumer-interface noun, so generic
  replacement and migration prose no longer demands a Consumer Impact Sweep.
- Check 5A distinguishes explicit no-SLA/no-SLO/not-applicable posture from a
  quantitative performance promise.
- Check 43 derives receipt identity from command family, evidence category,
  target closure, exit status, and execution provenance instead of stdout bytes
  alone; BUG-007 empty-stdout and BUG-019 spelling behavior are preserved.
- G101 separates terminal-for-mode from delivery-capable terminality, so a
  planning, docs, or review ceiling can no longer satisfy `delivery=required`.
- The G043 and G101 contract text in `bubbles/registry/gates.yaml`,
  `agents/bubbles_shared/quality-gates.md`,
  `agents/bubbles_shared/scenario-compile.md`, `agents/bubbles.goal.agent.md`,
  `agents/bubbles.super.agent.md`, `docs/recipes/release-planning.md`, and
  `bubbles/cheatsheet/vocabulary.json` (with `docs/CHEATSHEET.md` and
  `docs/its-not-rocket-appliances.html` regenerated by
  `generate-cheatsheet.sh`) now states delivery-capable terminality and the
  narrowed Check 8B trigger.

### Still open

- `skills/bubbles-quality-gates-catalog/SKILL.md` still publishes the superseded
  "TERMINAL + VALIDATE-certified" G101 shorthand. It is outside the packet's
  approved `workBoundary.allowedPaths`, so correcting it needs a Goal Contract
  revision first rather than an out-of-boundary edit.
- Scope 4 requires captured `framework-validate` and `release-check` evidence.
- `bubbles.validate` has not certified the packet, so no terminal status may be
  written and BUG-028 may not yet be reconciled.

---

## BUG-033 — Check 43 measures receipt-sibling target distinctness per receipt, so repeated honest re-runs are reported as cloned evidence

- **Filed:** 2026-08-16
- **Disposition:** **FIXED**, before 2026-08-17. The fix described below is
  present in `bubbles/scripts/state-transition-guard.sh`: Check 43 binds
  `$targets` with `group_by(.cmd | cmd_identity) | map(.[0] | target_identity)`
  (line 4457), together with the facet-2 wrapper normalisation.
  `bash bubbles/scripts/receipt-identity-selftest.sh` reports 15 passed, 0 failed.
  The packet's own `state.json` remains `in_progress`: on 2026-08-17
  `state-transition-guard.sh` refused the `done` transition for
  `bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization` with 28
  failures (`blockingCode: DELIVERY_COMPLETION_FAILED`), so the status was left
  exactly as the guard found it.
- **Severity:** high. It blocks promotion of a downstream feature whose own
  evidence is sound, and it does so by alleging forgery — the most serious thing
  this guard can say about honest work.
- **Affects:** `bubbles/scripts/state-transition-guard.sh`, Check 43
  (`deterministic_siblings`), introduced with the BUG-032 D3 sibling work.

### Symptom

A downstream transition is refused with `Evidence receipt CLONE — one substantive
stdout is cited across incompatible command/category identities or receipts that
cannot prove independent target/execution provenance`, naming
`family=artifact-lint.sh category=lint`.

### Root cause

`deterministic_siblings` binds `$targets` with `($rows | map(target_identity))`
— one entry per RECEIPT — and then requires `all_distinct_nonempty`. A validator
is routinely re-run over one subject, so an honest log repeats that subject and
the distinctness test fails on shape alone.

This is the case the check's own comments promise it will never fire on: "an
honest re-run is routinely spelled differently ... a false CLONE accuses honest
work of the most serious thing this guard can allege."

### Evidence (real downstream log, `.specify/runtime/tool-calls.jsonl`)

Nine receipts share one stdout hash. Every sibling condition passes except
target distinctness:

| Condition | Observed |
| --- | --- |
| `command_family` distinct | 1 (`artifact-lint.sh`) |
| `evidence_category` distinct | 1 (`lint`) |
| `exitCode` distinct | 1 (`0`) |
| `provenance_identity` distinct | 9 of 9 |
| `target_identity` distinct | **2 of 9** (5 runs on one spec, 4 on another) |

The 9 receipts carry 9 distinct `sessionId`/`ts` pairs, which is exactly the
proof of independent execution the rule asks for. `artifact-lint.sh` never
prints its subject, so two structurally identical packets legitimately produce
byte-identical stdout.

### Fix that was verified

Take one target per command IDENTITY rather than per receipt:

```jq
| ($rows | group_by(.cmd | cmd_identity) | map(.[0] | target_identity)) as $targets
```

Provenance distinctness is unchanged, so each receipt must still prove
independent execution, and two identities sharing a single target remain a
refusal.

### Regression coverage that was verified

Three cases added to `state-transition-guard-selftest.sh` beside the existing
BUG-032 receipt matrix — a re-run fixture (5 receipts on one spec, 4 on another,
one shared hash) that must be ACCEPTED, an assertion that no clone is reported
for it, and an adversarial case (`npm run lint` vs `npm run test` over ONE
target) that must still be REFUSED so the relaxation is not a hole.

With the managed Python environment active, the guard selftest is
`302 passed, 0 failed`, all three new assertions passing.

### Note for whoever picks this up

Running `state-transition-guard-selftest.sh` with a bare `python3` that lacks
PyYAML/jsonschema produces ~19 unrelated `G061` failures and aborts the suite
before Check 43 is reached. Activate the managed environment first
(`bubbles/scripts/python-env.sh`), or the sibling cases are never exercised.

### Second facet — `cmd_parts` unwraps only a bare leading `bash`/`sh`

Fixing the distinctness rule above exposed a second identity-normalization
defect in the same check. `cmd_parts` strips only a single leading `bash` or
`sh` token, so one command spelled three ordinary ways resolves to three
different families:

| Recorded command | `command_family` |
| --- | --- |
| `node -e <script>` | `node` |
| `env PAGE=p node -e <script>` | `env` |
| `zsh -c 'PAGE=p node -e <script>'` | `zsh` |

All three ran the same script over the same page, in one scope, with distinct
session and timestamp provenance. Because the families differ they are treated
as unrelated commands sharing one stdout, and the group is refused — again the
re-spelling case the check promises to tolerate. `bash -c <script>` is affected
too: today it strips `bash` and leaves `-c` as the family.

Generalizing the strip to shell wrappers, `env`, and leading `VAR=value`
assignments collapses all three spellings to `family=node` with one identity, so
the group stops being a multi-identity collision at all:

```jq
def strip_wrappers:
  if ((.[0] // "") | test("^(bash|sh|zsh|ksh|dash)$"))
    then (if ((.[1] // "") == "-c") then .[2:] else .[1:] end | strip_wrappers)
  elif ((.[0] // "") == "env") then (.[1:] | strip_wrappers)
  elif ((.[0] // "") | test("^[A-Za-z_][A-Za-z0-9_]*=")) then (.[1:] | strip_wrappers)
  else . end;
def cmd_parts:
  ( . / " " | map(select(length > 0)) ) | strip_wrappers;
```

Both facets are required to clear the downstream feature; the distinctness fix
alone leaves the wrapper case blocking. With both applied, the downstream
transition guard reports `failureCount: 0, verdict: PASS`, and the guard still
discriminates across sibling specs in that repository (observed 67, 4, 1, 0, 30,
0 failures), so it is not passing by going quiet.

Note `category=other` is also reported for these receipts: an inline `node -e`
script matches no category heuristic. That is conservative and was left alone —
once the wrappers normalize, the receipts share one identity and the category
never has to carry the decision.

### Disposition — FIXED, packet opened (2026-08-17)

Both facets are fixed in `bubbles/scripts/state-transition-guard.sh`. This entry
is retained as the filing record; the working artifacts live in the full packet
at `bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization/`.

The packet form was resolved mechanically rather than chosen. The compact
micro-fix packet is the DEFAULT route since IMP-047 S-D, and
`bubbles/scripts/micro-fix-admission.sh` refused it here:

```
[micro-fix-admission] bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization fails admission (no-new-behavior no-cross-product-effect) - it escalates automatically to the full bug packet.
[micro-fix-admission] Escalation is mechanical. There is no reviewer discretion and no override flag.
```

`no-new-behavior` fails because a refused transition becomes an accepted one,
and `no-cross-product-effect` fails because the guard ships into every consuming
repository.

Regression surface: `bubbles/scripts/receipt-identity-selftest.sh` extracts the
Check 43 jq program FROM THE GUARD SOURCE and drives it against six fixtures —
one acceptance and one adversarial bound per facet, plus the BUG-007 and BUG-032
pins. End-to-end cases run the whole guard in
`bubbles/scripts/state-transition-guard-selftest.sh`.

### Third facet — timeout wrapper grammar (2026-09-02)

The packet was reopened for a distinct normalization case. Repository commands
are routinely wrapped by exact-basename `timeout` or `gtimeout`. Those wrappers
are transparent only when their complete prefix matches the packet's closed
grammar. Unknown, malformed, attached short-option, unsupported clustered,
missing-duration, missing-child, and near-miss forms remain opaque.

The concurrent dirty implementation accepts broader forms, including `-vfp`,
`-k.5`, and `-sTERM`. That source is not certified by this entry. Scope 2 in the
BUG-033 packet owns narrowing the parser and its fixtures. No timeout red or
green execution is claimed here.

The packet boundary also admits the exact
`.specify/memory/bubbles.session.json.flock` ignore entry. The session JSON and
all other memory-state paths remain outside that ignore rule.

---

## BUG-034 — a superseded receipt blocks certification forever, so any spec that records receipts and then commits can never certify

- **Filed:** 2026-08-18
- **Disposition:** **FIXED** in `bubbles/scripts/scenario-state-resolve.sh` on
  2026-08-18. `certifiable` and the exit code now consider only
  `blocking_refusals` — every refusal code EXCEPT `SCS-REVISION-DRIFT`. Drift is
  still reported, and the receipt is still excluded from derivation; it simply no
  longer votes on certifiability. `bash bubbles/scripts/scenario-state-resolve-selftest.sh`
  reports 38 passed, 0 failed.
- **Severity:** high. It makes receipt-derived certification unreachable for
  every spec in the long run, and it does so silently — the operator sees
  `certifiable: no` beside a full set of green scenarios and no unsatisfied
  state, with nothing named as the cause.
- **Affects:** `bubbles/scripts/scenario-state-resolve.sh` (certifiability
  computation and exit code), and therefore Check 4 of
  `bubbles/scripts/state-transition-guard.sh`, which invokes the resolver with
  `--certifiable`.
- **Discovered by:** a downstream `bubbles.goal` session driving
  guestHost `specs/160-booking-status-vocabulary` to certification.

### Symptom

All 13 scenarios resolve `REGRESSION_GREEN`, `unsatisfied` is empty, and
certification is still refused:

```
{ "certifiable": false,
  "requiredStates": ["RED_VERIFIED","IMPLEMENTED","GREEN_TARGETED","GREEN_LIVE","REGRESSION_GREEN","OBSERVED"],
  "unsatisfied": [],
  "refusalCodes": ["SCS-REVISION-DRIFT"] }
```

The guard reports `failedChecks: [Check-4-scenario-states]` with the message
`Required scenario states are NOT receipt-derived — certification refused`,
which is the opposite of what the resolver just computed: every required state
IS receipt-derived.

### Root cause

`certifiable = (not refusals) and (not unsatisfied)`, and `if refusals: sys.exit(1)`.
Both counted `SCS-REVISION-DRIFT`.

`receipt_binding_ok()` already returns False for a stale receipt, so a drift
receipt contributes no state — it can only WITHHOLD evidence, never contradict
it. A scenario left without fresh evidence therefore already lands in
`unsatisfied`, which is the condition that genuinely blocks. Counting drift a
second time adds no detection power.

It does add a false block, and a permanent one. `tool-calls.jsonl` is
append-only and receipts are pinned to a source revision, so the first commit
after a receipt campaign converts that whole campaign into drift. Every later
campaign inherits it. The failure is therefore not specific to spec 160 — 160 is
just the first packet to have recorded receipts, committed, and recorded again.

### Evidence (execution)

Observed downstream at guestHost HEAD `65c52e72`: 65 refusals, all
`SCS-REVISION-DRIFT`, against 13 scenarios each holding every required state.

Adversarial proof that the new regression case is load-bearing — the fix was
reverted in place (`blocking_refusals = list(refusals)`) and the suite was
re-run:

```
FAIL: source-revision drift should report and not block (exit 1)
scenario-state-resolve-selftest: 37 passed, 1 failed
```

then restored: `38 passed, 0 failed`.

### Regression surface

Three cases in `bubbles/scripts/scenario-state-resolve-selftest.sh`:

- drift is reported and `blockingRefusalCount` is 0, exit 0 — the fix itself;
- drift-only evidence still fails `--certifiable` via `unsatisfied` — proves the
  exclusion still denies certification, so the change did not make drift
  cosmetic;
- a `SCS-NO-NEGATIVE-CONTROL` receipt alongside drift still blocks — proves the
  exemption is scoped to one code and did not neutralise the others.

`--ignore-drift` remains rejected by name, so this is a correction to what drift
MEANS, not a bypass of it.

### Micro-fix admission

Escalates, on the same two answers as BUG-033: `no-new-behavior` fails because a
refused transition becomes an accepted one, and `no-cross-product-effect` fails
because the resolver ships into every consuming repository.

---

## BUG-037 — evidence capture can duplicate the zero line count and feed a non-canonical scalar into arithmetic

- **Filed:** 2026-09-02
- **Disposition:** open framework defect; artifact and root-cause packet created
  at `bugs/BUG-037-evidence-capture-zero-output-arithmetic/`. No implementation,
  red-stage execution, or certification is claimed.
- **Severity:** high. Evidence formatting can emit an arithmetic diagnostic
  while the child and helper still return success.
- **Affects:** `bubbles/scripts/evidence-capture.sh` zero-output metadata.

### Root cause

The helper derives its line count with `grep -c` followed by a fallback printer.
For an empty file, `grep -c ''` prints `0` and returns a no-match status. The
fallback prints another `0`, so command substitution produces `00`. Later
conditions consume that value arithmetically.

The duplicated-zero source defect is confirmed by inspection. The operator's
exact arithmetic diagnostic was not durably captured in this session and is not
restated as execution evidence.

### Required fix

Use one canonical line-count producer for every readable capture file. Add
focused successful and failing zero-output regressions that assert `lines: 0`,
the empty-stream hash, no arithmetic diagnostic, and the existing child exit
contract. Preserve non-empty, bounded, signal, cleanup, and verify behavior.

The packet routes implementation to `bubbles.implement`. Full framework and
release validation remain mandatory before validate-owned certification.

