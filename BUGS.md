# Bubbles Framework — Known Bugs

> **Why this file exists:** the Bubbles source repo cannot keep `specs/` (G085 dogfood guard), so framework-internal defects are tracked here as the operator-visible bug log. Downstream consumer repos file their bugs in their own `specs/<feature>/bugs/BUG-NNN-*/` structure as usual.
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
- **Disposition:** open in-repo framework defect, DEFERRED (not fixed in the discovering session). Reconciling the drift changes G068 enforcement semantics for every downstream repo that has adopted `SCN-*` IDs, so the direction is an owner decision rather than a mid-session edit. Per Gate G095 this is a tracked OPEN defect with a recorded reason for deferral, not a silent omission.
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

---

## BUG-006 — the pre-push hook releases the `framework-validate` lock between its two phases, so a concurrent run can fail `release-check`

- **Filed:** 2026-08-02
- **Disposition:** open in-repo framework defect, DEFERRED. Diagnosed but not fixed: the candidate fixes (hold one lock across both phases, or let a nested run inherit the parent's lock) change the concurrency contract of the release gate, which is an owner decision rather than a mid-session edit. Per Gate G095 this is a tracked OPEN defect with a recorded reason.
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
- **Disposition:** open framework defect — reproduced deterministically at scale, fix identified, not yet applied.
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
- **Disposition:** open framework defect — root cause isolated and confirmed on both sides. NOT fixed here because the correct owner is ambiguous between the writer and the reader, and picking one silently would bake in whichever shape happened to be convenient. Per Gate G095 this is a tracked OPEN defect with a recorded reason and a recommended resolution.
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
- **Disposition:** open in-repo framework defect, DEFERRED with a concrete fix
  recommended below. NOT applied in the discovering session for one specific
  reason: `bubbles/scripts/state-transition-guard.sh` currently carries **+181
  uncommitted lines from a concurrent session** in this shared working copy, and
  adding a check to a file another agent is mid-edit in would risk clobbering
  unrelated in-flight work. Per Gate G095 this is a tracked OPEN defect with a
  recorded reason, not a silent omission.
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
- **Disposition:** open in-repo framework defect, fix is a one-line path
  addition. DEFERRED only because `cli.sh` sits beside the same concurrently
  modified guard files described in BUG-013; recorded here with the exact path
  so it can be applied cleanly. Per Gate G095 this is a tracked OPEN defect.
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

## BUG-015 — the guard runs `artifact-lint.sh` under a hardcoded 60s budget and discards its output, so a lint that PASSES in ~60s is reported as a blocking failure, non-deterministically

- **Filed:** 2026-08-11
- **Disposition:** open in-repo framework defect, DEFERRED with a fix recommended
  below. Not applied in the discovering session because
  `bubbles/scripts/state-transition-guard.sh` again carries uncommitted changes
  from a concurrent session in this shared working copy, and this repo has
  already had one incident this week where an edit made during a concurrent
  session's commit window shipped in a state nobody intended. Per Gate G095 this
  is a tracked OPEN defect with a recorded reason.
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





