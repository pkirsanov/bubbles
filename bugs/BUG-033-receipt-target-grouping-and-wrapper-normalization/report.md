# BUG-033 Report

Related planning: [scopes.md](scopes.md). Human acceptance:
[uservalidation.md](uservalidation.md).

## Scenario-First TDD Evidence Order

This index records chronology by reference. The raw evidence remains
byte-preserved at its original anchors.

### RED Stage

- Facets 1 and 2: [Historical Red](#red) records the pre-repair focused
  selftest failure.
- Facet 3: [Bug reproduction](bug.md#reproduction) records the pre-repair
  production-definition probe with exit `1` and `0 passed, 3 failed`.

### GREEN Stage

- Facets 1 and 2: [Historical Green](#green) records the corresponding
  post-repair focused selftest result.
- Facet 3: [Focused green](#facet-3-focused-green-evidence) and
  [whole-guard green](#facet-3-whole-guard-evidence) record the corresponding
  post-repair production-definition and real-process results.

## Active Planning Status

- Scope 1 is `In Progress` for the active three-facet contract.
- SCN-B033-001 through SCN-B033-004 retain the historical facet-1 and facet-2
  evidence below.
- SCN-B033-005 through SCN-B033-011 have current independently executed test
  evidence in the facet-3 sections below.
- Validate-owned certification remains unchanged.

## Historical Facet 1/2 Evidence (Preserved)

The raw evidence in this section predates the facet-3 planning reconciliation.
It supports only the checked facet-1 and facet-2 items in [scopes.md](scopes.md).

### Summary

- **Changed:** `bubbles/scripts/state-transition-guard.sh` (Check 43 jq program,
  two edits), `bubbles/scripts/receipt-identity-selftest.sh` (new),
  `bubbles/scripts/state-transition-guard-selftest.sh` (end-to-end cases).
- **Scenarios validated:** SCN-B033-001, SCN-B033-002, SCN-B033-003,
  SCN-B033-004.

### Completion Statement

Both filed facets are fixed and each carries an adversarial bound that still
refuses. Two executions used the same test file and fixtures. One ran before
the fix and one ran after it. Their real exit codes appear below. Every claim
in this historical section names a command that ran.

### Test Evidence

#### Red

The reproduction, before the fix.

**Executed:** YES
**Command:** `bash bubbles/scripts/receipt-identity-selftest.sh`
**Phase Agent:** bubbles.implement
**Claim Source:** executed

The test fails without the fix. Exit code `1`, `5 passed, 10 failed`.

```text
FAIL: facet 1: honest re-runs reported as clones (1 group(s)) — target distinctness is measured per receipt
  analysis: {
  "siblings": [],
  "clones": [
    {
      "hash": "9f2c1a77b3e45d6081ca2be7f4d0913ac5e8b26df1074a3c9e5b0d8f6a271c43",
      "identities": [
        "family=artifact-lint.sh category=lint target=spec:specs/alpha|scope: provenance=session:rr-a1|ts:2026-08-16T09:00:01Z|duration:101 cmd=bash bubbles/scripts/artifact-lint.sh specs/alpha",
        ... 8 further receipts, 9 distinct session/ts pairs ...
      ]
    }
  ]
}
FAIL: facet 1: expected exactly 1 accepted sibling group, observed 0
PASS: facet 1 bound: two identities sharing ONE target and one stdout are still refused
FAIL: facet 2: 'node scripts/check-page.mjs alpha' normalizes to command_family='...' (expected node)
FAIL: facet 2: wrapper spellings reported as clones (1 group(s))
  analysis: {
  "siblings": [],
  "clones": [
    {
      "identities": [
        "family=node  ... cmd=node scripts/check-page.mjs alpha",
        "family=env   ... cmd=env PAGE=alpha node scripts/check-page.mjs alpha",
        "family=zsh   ... cmd=zsh -c node scripts/check-page.mjs alpha",
        "family=PAGE=alpha ... cmd=PAGE=alpha node scripts/check-page.mjs alpha",
        "family=-c    ... cmd=bash -c node scripts/check-page.mjs alpha"
      ]
    }
  ]
}
PASS: facet 2 bound: two different programs behind identical wrappers are still refused
FAIL: facet 2 bound: the diagnostic did not name both unwrapped identities
PASS: BUG-007 pin: empty stdout stays exempt after the BUG-033 relaxation
PASS: BUG-032 pin: a collision with no independent execution provenance is still refused
PASS: BUG-032 pin: incompatible command families sharing one stdout are still refused

receipt-identity-selftest: 5 passed, 10 failed
RECEIPT_IDENTITY_RED_EXIT=1
```

The red output IS the bug report: five different families for one command, and
nine honest re-runs classified as a single forged-evidence group.

Two red assertions above came from a defect in the test's own `family_of`
helper, which indexed a string as an object. The helper was corrected before
the green run. The analysis payload still shows the substantive facet-2
failure: five distinct families in the clone diagnostic.

#### Green

The same test, after the fix.

**Executed:** YES
**Command:** `bash bubbles/scripts/receipt-identity-selftest.sh`
**Phase Agent:** bubbles.implement
**Claim Source:** executed

Exit code `0`, `15 passed, 0 failed`.

```text
PASS: facet 1: 9 honest re-runs of one validator over 2 targets are not reported as cloned evidence
PASS: facet 1: the re-run group is accepted through the deterministic-sibling path, not by an empty analysis
PASS: facet 1 bound: two identities sharing ONE target and one stdout are still refused
PASS: facet 2: 'node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: 'env PAGE=alpha node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: 'zsh -c node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: 'PAGE=alpha node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: 'bash -c node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: 'sh -c node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: five wrapper spellings of one command over one target are not reported as cloned evidence
PASS: facet 2 bound: two different programs behind identical wrappers are still refused
PASS: facet 2 bound: the diagnostic names the unwrapped cargo and npm identities
PASS: BUG-007 pin: empty stdout stays exempt after the BUG-033 relaxation
PASS: BUG-032 pin: a collision with no independent execution provenance is still refused
PASS: BUG-032 pin: incompatible command families sharing one stdout are still refused

receipt-identity-selftest: 15 passed, 0 failed
RECEIPT_IDENTITY_GREEN_EXIT=0
```

#### Facet 1

Target grouping.

Before: `map(target_identity)` over every RECEIPT, so 9 re-runs over 2 targets
produced 9 values with 2 distinct entries and failed `unique|length == length`.

After: `group_by(.cmd | cmd_identity) | map(.[0] | target_identity)`, so the
list carries one entry per IDENTITY. The `facet 1` PASS above proves this
behavior. The next section records the adversarial partner.

#### Facet 2

Wrapper normalization.

Before: `family=node`, `family=env`, `family=zsh`, `family=PAGE=alpha`,
`family=-c` for one command (see the red analysis payload).

After: all six spellings resolve to `command_family=node` — six separate PASS
lines in the green block, each naming its spelling.

#### Bounds

Adversarial bounds.

Both relaxations are bounded and both bounds executed:

- `facet 1 bound` — `npm run lint` and `npm run test` over ONE target still
  produce exactly 1 clone group.
- `facet 2 bound` — `zsh -c cargo test` and `env CI=1 npm run lint` still
  produce exactly 1 clone group, and the diagnostic names the UNWRAPPED
  `family=cargo` and `family=npm`, proving unwrapping reveals the difference
  rather than hiding it.
- Three earlier pins (BUG-007 empty-stdout exemption, BUG-032 provenance-poor
  collision, BUG-032 incompatible families) all still hold.

#### Regression

**Executed:** YES
**Command:** `bash bubbles/scripts/state-transition-guard-selftest.sh`
**Phase Agent:** bubbles.implement
**Claim Source:** executed

Four scenario-specific cases were added to the whole-guard selftest beside the
BUG-032 receipt matrix — the re-run fixture, its single-target adversarial
partner, the wrapper fixture, and its cargo-vs-npm adversarial partner. These
drive the REAL guard end to end rather than its extracted jq program. The
executed result and exit code are recorded in the S-C session summary. See
`bubbles/scripts/state-transition-guard-selftest.sh` for the cases themselves.

### Code Diff Evidence

**Executed:** YES
**Command:** `git diff --stat`
**Phase Agent:** bubbles.implement
**Claim Source:** executed

Non-artifact runtime paths changed:

- `bubbles/scripts/state-transition-guard.sh` — Check 43 jq program
- `bubbles/scripts/receipt-identity-selftest.sh` — new regression surface
- `bubbles/scripts/state-transition-guard-selftest.sh` — end-to-end cases

### Validation Evidence

**Executed:** NO
**Command:** n/a
**Phase Agent:** bubbles.validate
**Claim Source:** not-run

Validate-owned certification has not run. This packet stays `in_progress`.

### Audit Evidence

**Executed:** NO
**Command:** n/a
**Phase Agent:** bubbles.audit
**Claim Source:** not-run

Audit has not run. This packet stays `in_progress`.

## Facet 3 Evidence Contract

This section defines where execution agents record facet-3 evidence. It does
not assert that any listed command has run.

### Facet 3 Red Evidence

**Phase:** test
**Command:** `bash bubbles/scripts/evidence-capture.sh --label "BUG-033 facet 3 red" -- /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 300 bash bubbles/scripts/receipt-identity-selftest.sh`
**Exit Code:** not run
**Claim Source:** not-run
**Required observation:** SCN-B033-005 through SCN-B033-011 fail for the
specified missing facet-3 behavior before the source repair.

### Facet 3 Focused Green Evidence

**Executed:** YES
**Phase:** test
**Command:** `bash bubbles/scripts/evidence-capture.sh --label "BUG-033 focused receipt identity" -- /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 300 bash bubbles/scripts/receipt-identity-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
# BUG-033 focused receipt identity
$ /usr/bin/perl -e alarm shift @ARGV; exec @ARGV 300 bash bubbles/scripts/receipt-identity-selftest.sh
exit: 0
lines: 41
sha256: 2dba3ef9ff49ca24db0584b78e60f2d8a89d1ccc7fc4717af6a13bf8f365cb9f
--- first 20 ---
PASS: facet 1: 9 honest re-runs of one validator over 2 targets are not reported as cloned evidence
PASS: facet 1: the re-run group is accepted through the deterministic-sibling path, not by an empty analysis
PASS: facet 1 bound: two identities sharing ONE target and one stdout are still refused
PASS: facet 2: 'node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: 'env PAGE=alpha node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: 'zsh -c node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: 'PAGE=alpha node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: 'bash -c node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: 'sh -c node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: five wrapper spellings of one command over one target are not reported as cloned evidence
PASS: facet 2 bound: two different programs behind identical wrappers are still refused
PASS: facet 2 bound: the diagnostic names the unwrapped cargo and npm identities
PASS: SCN-B033-005: timeout exposes the direct artifact-lint identity
PASS: SCN-B033-005: gtimeout exposes the direct artifact-lint identity
PASS: SCN-B033-006: the exact portable Perl alarm launcher exposes the direct artifact-lint identity
PASS: SCN-B033-007: composed spelling 'timeout 120 env PAGE=alpha zsh -c node scripts/check-page.mjs alpha' exposes node scripts/check-page.mjs
PASS: SCN-B033-007: composed spelling 'env PAGE=alpha gtimeout 120 bash -c node scripts/check-page.mjs alpha' exposes node scripts/check-page.mjs
PASS: SCN-B033-007: composed spelling 'zsh -c /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 120 env PAGE=alpha node scripts/check-page.mjs alpha' exposes node scripts/check-page.mjs
PASS: SCN-B033-007: composed spelling 'PAGE=alpha timeout 120 sh -c node scripts/check-page.mjs alpha' exposes node scripts/check-page.mjs
PASS: SCN-B033-008: arbitrary Perl remains unchanged and distinct from the direct command
--- omitted 1 line(s); sha256 above covers the full output ---
--- last 20 ---
PASS: SCN-B033-009: malformed spelling 'timeout 120' remains unchanged
PASS: SCN-B033-009: malformed spelling 'gtimeout 120' remains unchanged
PASS: SCN-B033-009: malformed spelling 'timeout --preserve-status 120 artifact-lint.sh TARGET' remains unchanged
PASS: SCN-B033-009: malformed spelling '/usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 120' remains unchanged
PASS: SCN-B033-009: malformed spelling '/usr/bin/perl -e 'alarm shift @ARGV; print @ARGV' 120 artifact-lint.sh TARGET' remains unchanged
PASS: SCN-B033-010: timeout preserves both distinct underlying command identities
PASS: SCN-B033-010: gtimeout preserves both distinct underlying command identities
PASS: SCN-B033-010: portable-perl-alarm preserves both distinct underlying command identities
PASS: SCN-B033-011: normalized commands with different exits remain incompatible
PASS: SCN-B033-011 negative control: equal exits remove the exit-result incompatibility
PASS: BUG-007 pin: empty stdout stays exempt after the BUG-033 relaxation
PASS: BUG-032 pin: a collision with no independent execution provenance is still refused
PASS: BUG-032 pin: incompatible command families sharing one stdout are still refused
PASS: BUG-028 defect 1: one command tagged test and validate is not reported as cloned evidence
PASS: BUG-028 defect 1 bound: two identities sharing ONE target and one stdout are still refused
PASS: BUG-028 bound: a group mixing two specs on one stdout is still refused
PASS: BUG-028 canonical: one validator over three subjects with differing tags is not reported as cloned evidence
PASS: BUG-028 canonical: the three-subject group is accepted through the deterministic-sibling path

receipt-identity-selftest: 39 passed, 0 failed
```

**Result:** PASS

### Facet 3 Whole-Guard Evidence

**Executed:** YES
**Phase:** test
**Command:** `bash bubbles/scripts/evidence-capture.sh --label "BUG-033 targeted whole guard" -- env BUBBLES_STATE_TRANSITION_GUARD_BUG033_ONLY=1 /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 600 bash bubbles/scripts/state-transition-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
# BUG-033 targeted whole guard
$ env BUBBLES_STATE_TRANSITION_GUARD_BUG033_ONLY=1 /usr/bin/perl -e alarm shift @ARGV; exec @ARGV 600 bash bubbles/scripts/state-transition-guard-selftest.sh
exit: 0
lines: 120
sha256: deb4f0c7f9b3443e81c04d41a2d4224f3894f6846c562c6e57dc921cd0aa0f7f
--- first 20 ---
PASS: G061 same-repo case reaches Check 3F
PASS: G061 allows bubbles.validate routing to the currently guarded spec
PASS: G061 does not classify a same-spec specialist route as external
PASS: G061 blocks an external/upstream route without crossRepoFollowUp
PASS: G061 does not admit the incomplete external route
PASS: G061 allows a complete external route with crossRepoFollowUp
PASS: G061 keeps the complete external route non-blocking
PASS: G061 requires crossRepoFollowUp for a commit route
PASS: G061 requires crossRepoFollowUp for a ticket route
PASS: G061 requires crossRepoFollowUp for an explicit external routing class
PASS: G061 requires crossRepoFollowUp for an explicit upstream routing class
PASS: G061 rejects a string crossRepoFollowUp value with a type-specific reason
PASS: G061 does not treat a string crossRepoFollowUp value as true
PASS: G061 rejects an ambiguous traversal alias of the guarded spec
PASS: G061 rejects a duplicate-separator alias of the guarded spec
PASS: G061 rejects a backslash alias of the guarded spec
PASS: G061 rejects a surrounding-whitespace alias of the guarded spec
PASS: G061 rejects a parent-traversal alias of the guarded spec
PASS: G061 rejects an absolute alias of the guarded spec
PASS: G061 does not resolve a symlink alias as the guarded spec
--- omitted 80 line(s); sha256 above covers the full output ---
--- last 20 ---
PASS: SCN-B033-010: gtimeout diagnostic names artifact-lint
PASS: SCN-B033-010: gtimeout diagnostic names state-transition-guard
PASS: SCN-B033-010: portable-perl-alarm exposes and refuses different underlying commands
PASS: SCN-B033-010: portable-perl-alarm diagnostic names artifact-lint
PASS: SCN-B033-010: portable-perl-alarm diagnostic names state-transition-guard
PASS: SCN-B033-011: the real guard refuses normalized commands with different exits
PASS: SCN-B033-011: refusal identifies the exit-result reason
PASS: SCN-B033-011: refusal names the first normalized identity
PASS: SCN-B033-011: refusal preserves exit 0
PASS: SCN-B033-011: refusal names the second normalized identity
PASS: SCN-B033-011: refusal preserves exit 1
PASS: SCN-B033-008 terminal contract: refusal fields remain in stable order
PASS: SCN-B033-008 terminal contract: control-bearing recorded identity remains blocking
PASS: SCN-B033-008 terminal contract: backslash, tab, newline, and escape bytes are escaped
PASS: SCN-B033-008 terminal contract: recorded controls cannot inject diagnostic fields
PASS: SCN-B033-010 terminal contract: a long identity remains complete without truncation
PASS: SCN-B033-010 terminal contract: narrow output uses two-space continuation lines
PASS: SCN-B033-010 terminal contract: Check 43 semantic output is ANSI-free

state-transition-guard BUG-033 selftest: 0 failure(s)
```

**Result:** PASS

### Facet 3 Scenario And Protected-Pin Accounting

| Test rows | Executed proof |
| --- | --- |
| T08, T10, T12, T14, T16, T18, T20 | Focused production-definition assertions emitted PASS for SCN-B033-005 through SCN-B033-011. |
| T09, T11, T13, T15, T17, T19, T21 | The targeted real-guard replay emitted PASS for every corresponding accepted or refused consumer-surface case. |
| T22 | The real-guard replay emitted PASS for field order, blocking effect, complete identities, control-character escaping, narrow wrapping, and ANSI-free semantic output. |
| Protected behavior | Facets 1 and 2 plus BUG-007, BUG-028, and BUG-032 pins emitted PASS in the focused suite; facets 1 and 2 plus BUG-007 and BUG-032 also emitted PASS through the real guard. |

### Facet 3 Shell And Marker Checks

**Phase:** test
**Claim Source:** interpreted
**Interpretation:** Full-severity ShellCheck reported only existing `info` and
`style` diagnostics outside the BUG-033 additions. Warning/error severity was
clean across all three scripts, and the focused test was clean at full
severity.

- `bash -n bubbles/scripts/state-transition-guard.sh bubbles/scripts/receipt-identity-selftest.sh bubbles/scripts/state-transition-guard-selftest.sh` exited `0`.
- `shellcheck -x bubbles/scripts/state-transition-guard.sh bubbles/scripts/receipt-identity-selftest.sh bubbles/scripts/state-transition-guard-selftest.sh` exited `1` on existing `info` and `style` findings.
- `shellcheck -S warning -x bubbles/scripts/state-transition-guard.sh bubbles/scripts/receipt-identity-selftest.sh bubbles/scripts/state-transition-guard-selftest.sh` exited `0`.
- `shellcheck -x bubbles/scripts/receipt-identity-selftest.sh` exited `0`.
- The token-bounded skip-marker scan exited `0` with `zero-matches`.

### Facet 3 Framework Closure Evidence

**Phase:** validate
**Command:** `bash bubbles/scripts/evidence-capture.sh --label "BUG-033 framework validate" -- /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 1200 bash bubbles/scripts/cli.sh framework-validate`
**Exit Code:** not run
**Claim Source:** not-run
**Required observation:** The complete canonical source-repository validation
suite exits zero after the focused and whole-guard checks pass.

## Regression Phase Evidence

**Phase:** regression
**Agent:** bubbles.regression

### Regression Finding RG-001: A Retired Check 43 Diagnostic Left One Stale Consumer

**Claim Source:** executed

Facet 3 replaced the free-text Check 43 refusal line with a structured reason
vocabulary. One first-party consumer still asserted the retired free text and
was never migrated, so the framework could not reach a green verdict.

The five diagnostic points below were each re-verified by command in this
session rather than accepted as given. Four are confirmed as stated. One is
corrected.

| # | Asserted | Verified result |
| --- | --- | --- |
| 1 | The selftest asserts `Evidence receipt CLONE` at `evidence-admission-hardening-selftest.sh:731` | CONFIRMED. `grep -n` returned exactly `731:  "Evidence receipt CLONE" \`. |
| 2 | `state-transition-guard.sh:4741` emitted that string at HEAD | CONFIRMED. `git show HEAD:...` returned line 4741 beginning `fail "Evidence receipt CLONE — one substantive stdout is cited across incompatible command/category identities...`. |
| 3 | The free text was replaced by a structured reason vocabulary | CONFIRMED WITH ONE CORRECTION. The literal is absent from the working-tree guard (`grep` exit 1). The emitted reason is `reason=command-identity-mismatch`, not `reason=identity-mismatch`. The full closed reason set is `command-identity-mismatch`, `target-conflict`, `provenance-conflict`, `category-invalid`, `exit-result-mismatch`, `classification-error`. |
| 4 | The fixture guard log still contains `effect=TRANSITION_BLOCKED` | CONFIRMED. The clone fixture log emits `check=43 verdict=REFUSED`, `reason=command-identity-mismatch`, the paired identity fields, and `effect=TRANSITION_BLOCKED`, and the guard reports `TRANSITION BLOCKED: 1 failure(s)`. Detection and blocking are preserved; only the reason vocabulary changed. |
| 5 | `evidence-admission-hardening-selftest.sh` is clean at HEAD | CONFIRMED. `git status --short` and `git diff --stat HEAD` both returned empty for that path. |

Baseline red, reproduced in this session:

```text
$ bash bubbles/scripts/evidence-admission-hardening-selftest.sh
exit: 1
lines: 256
sha256: 305b180b9255d8d9a479db16332dd10059171d3facab7f3ae8a0c49c48643fa6
evidence-admission-hardening-selftest: 15 passed / 1 failed
FAIL: CHECK 43 (clone): one stdout hash cited by TWO DIFFERENT commands BLOCKS —
 blocked but WITHOUT the expected Check-9 reason: 'Evidence receipt CLONE'
```

The captured stdout carries a per-run timestamp and a per-run temporary
workspace path, so its sha256 is not stable across runs and does not match a
sha256 captured in an earlier session. The failing assertion, the exit code and
the 256-line count reproduce exactly.

### Repair Decision And Rationale

The repair migrates the downstream assertion to the structured vocabulary. It
does not restore the retired string in the guard.

**Chosen:** update `evidence-admission-hardening-selftest.sh` to assert
`reason=command-identity-mismatch`.

**Rejected:** preserve `Evidence receipt CLONE` in the guard for backward
compatibility. [design.md](design.md) records this as considered alternative 7,
"Keep the legacy prose diagnostic and append more prose", and rejects it because
it "leaves reason selection unstable, keeps truncation, and cannot satisfy the
plain-text field contract". Restoring the string would also contradict the
ratified renderer rule that "Accepted output contains no clone, forgery,
warning, or refusal wording", and would reinstate the accusatory language whose
misapplication to honest re-runs is the defect BUG-033 exists to fix.

The migrated assertion is strictly tighter than the one it replaces. The retired
needle matched any refusal that mentioned a clone. The new needle excludes the
`classification-error` fallback that a broken classifier emits, so a classifier
regression can no longer satisfy it.

### Non-Vacuity Proof Of The Migrated Assertion

**Claim Source:** executed

Two independent mutations of the real guard were applied and reverted. Each had
to turn the assertion red for a different reason.

| Step | Guard state | Selftest exit | Tally | Observed line |
| --- | --- | --- | --- | --- |
| Repair | unmutated | 0 | 16 passed / 0 failed | `PASS: CHECK 43 (clone) ... (blocks; names Check-9 reason)` |
| Mutation A | clone-block escalation neutralized (`if [[ "$c43_clone_count" -gt 0 ]]` → `if false`) | 1 | 15 passed / 1 failed | `FAIL: ... guard PASSED but must BLOCK` |
| Mutation B | still blocks, emits `reason=MUTATED-non-vacuity-probe` | 1 | 15 passed / 1 failed | `FAIL: ... blocked but WITHOUT the expected Check-9 reason: 'reason=command-identity-mismatch'` |
| Revert | unmutated | 0 | 16 passed / 0 failed | `PASS: CHECK 43 (clone) ...` |

Mutation A proves the assertion requires a real blocking verdict. The refusal
panel including `reason=command-identity-mismatch` was still rendered into the
guard log under Mutation A, and the assertion still failed, so the assertion
cannot be satisfied by log text alone.

Mutation B proves the assertion discriminates the reason rather than merely the
block. The guard still exited nonzero and still emitted
`effect=TRANSITION_BLOCKED`, and only the reason differed.

Residue check: `bubbles/scripts/state-transition-guard.sh` hashed
`06e1ecb3b0147b2d226627b846dc2e04b3eec55ce09865486bcacb0fb76dca7a` before the
first mutation, after the Mutation A revert, and after the Mutation B revert. A
scan for `MUTATED-non-vacuity-probe` and `if false; then` returned no matches.
The post-revert selftest capture reproduced the repair capture's sha256
`cc8efcf63c2bdf26c654c8098834faa2488820a590dc2728eb4bc20f62853763` exactly.

### Consumer Impact Sweep

**Claim Source:** executed

A repository-wide sweep for the retired vocabulary found six files. Exactly one
is an executable consumer.

| Path | Kind | Disposition |
| --- | --- | --- |
| `bubbles/scripts/evidence-admission-hardening-selftest.sh` | executable assertion | STALE. Migrated by this phase. |
| `BUGS.md` | filed-defect narrative | Safe. Quotes the originally observed refusal text as the reported symptom. Rewriting it would falsify the defect record. |
| `bugs/BUG-032-planning-maturity-guard-false-positives/report.md` | historical evidence | Safe. Records output observed at the time of that packet. |
| `bugs/BUG-033-.../bug.md` | symptom quotation | Safe. The Symptom section quotes the downstream refusal that motivated this bug. |
| `bugs/BUG-037-.../report.md` and `state.json` | blocker narrative | Safe. Records the cross-packet blocker as observed, and is a foreign packet this phase must not edit. |

Two further checks bound the sweep.

- No `bubbles/registry`, `docs`, `skills`, or `agents` file references the
  retired wording. The file list returned empty.
- `bubbles/scripts/state-transition-guard-selftest.sh` is already migrated and
  carries 18 assertions on `check=43 verdict=` and the structured reasons.
  `bubbles/scripts/receipt-identity-selftest.sh` asserts no panel text at all
  and needs no migration.

The sweep also surfaced a naming hazard that a text-only search would
misclassify. Two unrelated checks share the number 43. Check 43 in
`state-transition-guard.sh` is Evidence Receipt Staleness, the surface this bug
changes. Check 43 in `guards/tail-delegated-gates.sh` is the Human Acceptance
Terminal Gate G136, consumed by `acceptance-authority-selftest.sh` and
`tests/regression/test_35_human_acceptance_terminal.sh`. Those two files are not
consumers of the receipt vocabulary and were correctly left unchanged.

### Regression Finding RG-002: The Declared Consumer Enumeration Was Incomplete

**Claim Source:** executed
**Severity:** P1, and it is the direct cause of RG-001.

[scopes.md](scopes.md) "Consumer And Shared-Infrastructure Impact Sweep"
enumerates the direct consumer, the focused parity consumer
(`receipt-identity-selftest.sh`), the current surface canary
(`state-transition-guard-selftest.sh`), and framework closure.
`evidence-admission-hardening-selftest.sh` appears in none of those categories,
and [design.md](design.md) "Change Boundary" likewise permits assertion changes
only in "the two named selftests". A first-party consumer that asserts Check 43
refusal text was therefore outside the enumeration that the sweep walks, which
is precisely why the field change shipped without migrating it.

The enumeration should name every first-party asserter of Check 43 diagnostic
text, not only the two selftests authored alongside the check.

### Regression Finding RG-003: The Repair Lands Outside The Declared Work Boundary

**Claim Source:** executed
**Severity:** P1, requires an owning-agent decision. Not resolvable by this
diagnostic phase.

The authoritative resolver was consulted before recording this phase:

```text
$ bash bubbles/scripts/work-boundary-resolve.sh \
    --feature-dir bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization \
    --candidate-repo bubbles \
    --candidate-path bubbles/scripts/evidence-admission-hardening-selftest.sh \
    --require-allowed-paths
disposition=route-same-repo
repoMatch=true
reason=candidate path 'bubbles/scripts/evidence-admission-hardening-selftest.sh'
 is in-repo but outside the declared allowedPaths — file/route a finding rather
than inline-fixing unrelated work
exit: 0
```

`state.json` `workBoundary.allowedPaths` names four scripts and does not name
this one. The repair is semantically owned by this packet, because the packet's
own DoD requires that "The consumer impact sweep confirms no stale first-party
diagnostic consumer after any field change", and because the staleness was
created by this packet's field change. The declared boundary was simply never
widened to match.

Consequence recorded honestly: the DoD item "The final diff stays inside the
declared change boundary" is NOT checked by this phase, because the diff
provably now exceeds the declared boundary. `bubbles.plan` must widen
`workBoundary.allowedPaths` and the design Change Boundary to include
`bubbles/scripts/evidence-admission-hardening-selftest.sh`, after which that
item can be evaluated.

### Regression Surface Results

**Claim Source:** executed

| Surface | Command | Exit | Result |
| --- | --- | --- | --- |
| Evidence-admission hardening | `bash bubbles/scripts/evidence-admission-hardening-selftest.sh` | 0 | 16 passed / 0 failed |
| Receipt identity (focused parity consumer) | `bash bubbles/scripts/receipt-identity-selftest.sh` | 0 | 39 passed, 0 failed |
| Human acceptance terminal (G136) | `bash tests/regression/test_35_human_acceptance_terminal.sh` | 0 | 13 passed, 0 failed |

The `receipt-identity-selftest` run emitted PASS for SCN-B033-005 through
SCN-B033-011 and for the BUG-007, BUG-028 and BUG-032 protected pins, so the
facet-3 contract and the compatibility pins are both intact alongside the
repair.

## Active Delivery Append-Only Evidence

### Code Diff Evidence - Current Delivery

This plan-owned heading is the append-only destination for current
implementation and regression proof. It contains no execution claim. The
execution owner records the command, exit status, raw output, and classified
non-artifact paths here after running the version-control inspection. The
historical Code Diff Evidence above remains preserved and is not reused as
proof of the active delivery state.

#### Current Code-Only Snapshot

**Executed:** YES
**Phase:** implement
**Command:** `git diff --stat -- bubbles/scripts/state-transition-guard.sh bubbles/scripts/receipt-identity-selftest.sh bubbles/scripts/state-transition-guard-selftest.sh bubbles/scripts/evidence-admission-hardening-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

```text
 .../evidence-admission-hardening-selftest.sh       |   6 +-
 bubbles/scripts/receipt-identity-selftest.sh       | 118 +++++
 bubbles/scripts/state-transition-guard-selftest.sh | 518 +++++++++++++++++++--
 bubbles/scripts/state-transition-guard.sh          | 298 +++++++++++-
 4 files changed, 867 insertions(+), 73 deletions(-)
```

**Executed:** YES
**Phase:** implement
**Command:** `git diff --name-only -- bubbles/scripts/state-transition-guard.sh bubbles/scripts/receipt-identity-selftest.sh bubbles/scripts/state-transition-guard-selftest.sh bubbles/scripts/evidence-admission-hardening-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

```text
bubbles/scripts/evidence-admission-hardening-selftest.sh
bubbles/scripts/receipt-identity-selftest.sh
bubbles/scripts/state-transition-guard-selftest.sh
bubbles/scripts/state-transition-guard.sh
```

```text
# BUG-033 current authorized behavior path stat
$ git diff --stat -- bubbles/scripts/state-transition-guard.sh bubbles/scripts/receipt-identity-selftest.sh bubbles/scripts/state-transition-guard-selftest.sh bubbles/scripts/evidence-admission-hardening-selftest.sh
exit: 0
lines: 5
sha256: e1ed2ee31853b235a2521427d953ddf7a2abf825830ed6eded2d1e7dc21f52bc
--- output ---
 .../evidence-admission-hardening-selftest.sh       |   6 +-
 bubbles/scripts/receipt-identity-selftest.sh       | 118 +++++
 bubbles/scripts/state-transition-guard-selftest.sh | 518 +++++++++++++++++++--
 bubbles/scripts/state-transition-guard.sh          | 298 +++++++++++-
 4 files changed, 867 insertions(+), 73 deletions(-)

# BUG-033 current authorized behavior path status
$ git status --short -- bubbles/scripts/state-transition-guard.sh bubbles/scripts/receipt-identity-selftest.sh bubbles/scripts/state-transition-guard-selftest.sh bubbles/scripts/evidence-admission-hardening-selftest.sh
exit: 0
lines: 4
sha256: 3ba102547bb4283fffa452e8fb54fdb30e0da00d288d040ef89c19c54deb0490
--- output ---
 M bubbles/scripts/evidence-admission-hardening-selftest.sh
 M bubbles/scripts/receipt-identity-selftest.sh
 M bubbles/scripts/state-transition-guard-selftest.sh
 M bubbles/scripts/state-transition-guard.sh

# BUG-033 shared selftest complete patch inspection
$ git diff --color=never --unified=0 -- bubbles/scripts/state-transition-guard-selftest.sh
exit: 0
lines: 554
sha256: 4636d04bdac5265a697f5f312f205329806fb7e56606f4cab6212600429aea0b
--- first 20 ---
diff --git a/bubbles/scripts/state-transition-guard-selftest.sh b/bubbles/scripts/state-transition-guard-selftest.sh
index f48041e..2d80b16 100755
--- a/bubbles/scripts/state-transition-guard-selftest.sh
+++ b/bubbles/scripts/state-transition-guard-selftest.sh
@@ -246,0 +247,48 @@ assert_log_not_contains() {
+check43_panel_text() {
+  local log_file="$1"
+  awk '
+    /^check=43 verdict=/ { active=1 }
+    active { print }
+    active && /^effect=(COLLISION_ACCEPTED|TRANSITION_BLOCKED)$/ { active=0 }
+  ' "$log_file"
+}
+
+assert_check43_contains() {
+  local log_file="$1"
+  local needle="$2"
+  local label="$3"
+  local panel
+  panel="$(check43_panel_text "$log_file")"
--- omitted 514 line(s); sha256 above covers the full output ---
--- last 20 ---
+  fail "S3-T4 the guard modified uservalidation.md: before=$c43_sha_before after=$c43_sha_after"
+fi
+
+# S3-T5: SCN-B037-012 — a ceiling-bound target is still exempt. The base fixture
+# ships docs-only, so this reuses it WITHOUT the delivery-contract mutation.
+c43_ceiling_dir="$tmp_root/specs/954-c43-ceiling"
+emit_base_fixture "$c43_ceiling_dir"
+cp "$c43_dir/bug029.md" "$c43_ceiling_dir/uservalidation.md"
+run_capture "$tmp_root/c43-ceiling-guard.log" \
+  env BUBBLES_STATE_TRANSITION_GUARD_SELFTEST_FAST=0 \
+  bash "$GUARD_SCRIPT" "$c43_ceiling_dir" > /dev/null
+c43_ceiling_block="$(c43_gate_block "$c43_gate_header" "$tmp_root/c43-ceiling-guard.log")"
+if ! c43_assert_block_present "S3-T5" "$c43_ceiling_block" "$tmp_root/c43-ceiling-guard.log"; then
+  :
+elif printf '%s' "$c43_ceiling_block" | grep -q "is not 'done'" &&
+  ! printf '%s' "$c43_ceiling_block" | grep -q 'PD12-UNCHECKED-ITEM'; then
+  pass "S3-T5 SCN-B037-012: a ceiling-bound target status is still exempt and acceptance is not evaluated"
@@ -5206 +5626 @@ else
-  fail "Check 43 (PD-12): a valid human acceptance record was refused: $(bubbles_acceptance_terminal_verdict "$c43_dir/human_accepted.md" 2>&1 || true)"
+  fail "S3-T5 ceiling-bound exemption intact: $c43_ceiling_block"
```

**Interpretation:** The inventory is deliberately scoped to the four
non-artifact behavior paths authorized by `state.json`. Exact hunk inspection
attributes the Check 43 classifier and renderer to
`state-transition-guard.sh`, the production-definition scenario matrix to
`receipt-identity-selftest.sh`, and the one retired-vocabulary assertion to
`evidence-admission-hardening-selftest.sh`. The aggregate
`state-transition-guard-selftest.sh` stat is not wholly attributable to
BUG-033: its Check 43 receipt helpers, BUG-033-only selector, and
SCN-B033-001 through SCN-B033-011 fixtures belong to this packet, while later
human-acceptance hunks belong to concurrent BUG-037 work and remain untouched.
The full worktree also contains other dirty paths outside this four-path
inventory. They are concurrent work, are not evidence for BUG-033, and are not
attributed or modified by this implementation reconciliation.

#### Current Implement Focused Proof

**Executed:** YES
**Phase:** implement
**Command:** `bash bubbles/scripts/evidence-capture.sh --label "BUG-033 implement focused receipt identity" -- /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 300 bash bubbles/scripts/receipt-identity-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

The current execution produced `41` lines, `39 passed, 0 failed`, and sha256
`2dba3ef9ff49ca24db0584b78e60f2d8a89d1ccc7fc4717af6a13bf8f365cb9f`.
That digest exactly re-derives the compact raw block under
[Facet 3 Focused Green Evidence](#facet-3-focused-green-evidence). The current
run therefore proves the same production definitions still cover exact
`timeout`, `gtimeout`, and portable-Perl normalization, recursive composition,
unsupported grammar retention, distinct underlying commands, independent exit
comparison, and the protected facet-1, facet-2, BUG-007, BUG-028, and BUG-032
pins.

#### Current Implement Real-Guard Canary

**Executed:** YES
**Phase:** implement
**Command:** `bash bubbles/scripts/evidence-capture.sh --label "BUG-033 implement targeted whole guard" -- env BUBBLES_STATE_TRANSITION_GUARD_BUG033_ONLY=1 /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 600 bash bubbles/scripts/state-transition-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

The current execution produced `120` lines, zero BUG-033 failures, and sha256
`deb4f0c7f9b3443e81c04d41a2d4224f3894f6846c562c6e57dc921cd0aa0f7f`.
That digest exactly re-derives the compact raw block under
[Facet 3 Whole-Guard Evidence](#facet-3-whole-guard-evidence). This is the
shared-infrastructure canary: it invokes the real guard process over isolated
receipt logs and proves accepted and refused verdicts, stable reason and effect
fields, complete identities, control escaping, narrow wrapping, and ANSI-free
semantics independently of the focused jq extraction.

#### Current Migrated Consumer Proof

**Executed:** YES
**Phase:** implement
**Command:** `bash bubbles/scripts/evidence-capture.sh --label "BUG-033 implement evidence-admission consumer" -- /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 600 bash bubbles/scripts/evidence-admission-hardening-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
# BUG-033 implement evidence-admission consumer
$ /usr/bin/perl -e alarm shift @ARGV; exec @ARGV 600 bash bubbles/scripts/evidence-admission-hardening-selftest.sh
exit: 0
lines: 33
sha256: cc8efcf63c2bdf26c654c8098834faa2488820a590dc2728eb4bc20f62853763
--- output ---
=== CONTROL PASS cases ===
PASS: CONTROL (a): inline fenced command block (cmd + exit 0 + >=10 lines) passes with no advisory (passes; no advisory)
PASS: CONTROL (b): resolver link to a real >=10-line fenced command block passes with no advisory (passes; no advisory)

=== ADVISORY PASS case (fix #3) ===
PASS: ADVISORY (#3): resolved 12-line prose block accepted AND emits Check-9 ADVISORY (passes; emits Check-9 ADVISORY)

=== CHECK 43 receipt staleness (IMP-027 SCOPE-3, EV-2) ===
PASS: CHECK 43 (fresh): receipt whose inputClosure still matches the tree passes (passes)
PASS: CHECK 43 (stale): receipt whose input changed after capture BLOCKS (blocks; names Check-9 reason)
PASS: CHECK 43 (clone): one stdout hash cited by TWO DIFFERENT commands BLOCKS (blocks; names Check-9 reason)
PASS: CHECK 43 (re-run): same stdout hash from the SAME command is honest, passes (passes)
PASS: CHECK 43 (re-spelled): same command with an equivalent --repo-root value passes (passes)
PASS: CHECK 43 (optional arg): same command and subject with an extra filter argument passes (passes)

=== BLOCKING FAIL cases ===
PASS: BLOCK (IMP-027 SCOPE-3): prose-only block backing an EXECUTION claim (blocks; names Check-9 reason)
PASS: BLOCK (#1): truly-bare '-> Evidence: done' marker (blocks; names Check-9 reason)
PASS: BLOCK (#2): plain link to a report with <10 non-blank lines (blocks; names Check-9 reason)
PASS: BLOCK (#5): uppercase '- [X]' item with no evidence (blocks; names Check-9 reason)
PASS: BLOCK (#7): duplicated identical '- [x]' lines, only the first evidenced (blocks; names Check-9 reason)
PASS: BLOCK (#6): tool-log entry with spec:"" is non-matching (blocks; names Check-9 reason)
SKIP: BLOCK (#4) schema-invalid tool-log line - python 'jsonschema' not importable

=== Tool-log POSITIVE control (proves #4/#6 are non-tautological) ===
PASS: CONTROL (tool-log): a VALID spec-scoped entry makes Check 9 COVER the bare item (Check 9 tool-log path COVERS the bare item)

=== NON-TAUTOLOGY: #1 and #5 must PASS on the OLD guard (86fc700) ===
SKIP: NON-TAUTOLOGY (#1/#5) - old-guard commit 86fc700 is absent from this clone (shallow checkout); fetch full history to run the teeth-proof

==============================================================
evidence-admission-hardening-selftest: 16 passed / 0 failed
==============================================================
```

The two printed skips are pre-existing optional checks outside the migrated
Check 43 assertion. The Check 43 clone case itself executed and passed against
`reason=command-identity-mismatch`.

#### Current Derived Consumer Closure

**Executed:** YES
**Phase:** implement
**Command:** The `c43_literals` pre-change-versus-working-tree scan recorded in [scopes.md](scopes.md#derived-consumer-scan-rg-002-mandatory-before-any-check-43-field-change), bounded by the portable Perl alarm launcher.
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
# BUG-033 derived Check 43 consumer scan
$ /usr/bin/perl -e alarm shift @ARGV; exec @ARGV 120 bash -c <c43_literals derived scan>
exit: 0
lines: 6
sha256: d92d9edd5dfcd3ab87ac1a65a9a7ae860c78f8197ac07e600979d94e9d2bdeeb
--- output ---
--- retired literal: Evidence receipt CLONE ---
HEAD:BUGS.md
HEAD:bubbles/scripts/evidence-admission-hardening-selftest.sh
HEAD:bubbles/scripts/state-transition-guard-selftest.sh
HEAD:bugs/BUG-032-planning-maturity-guard-false-positives/report.md
HEAD:bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization/bug.md
```

The two executable consumers now assert the structured replacement. A
non-comment scan over those two scripts returned zero executable references to
the retired literal. Exact current locations were
`evidence-admission-hardening-selftest.sh:735` and
`state-transition-guard-selftest.sh:4415,4505,4618,4700` for
`reason=command-identity-mismatch`. The remaining three paths are historical
records and remain unchanged by this reconciliation.

#### Isolated Rollback And Restore Proof

**Executed:** YES
**Phase:** implement
**Command:** Create `/tmp/bubbles-bug033-rollback-r42` as a shared detached clone at `ce2c5ed509dc59c984c65a48dad80a7684a98b85`; overlay the four current behavior files; check out those four files from the pinned revision; verify their blob IDs and retained source facets; run the focused baseline; restore the four current blobs; rerun focused and targeted canaries; compare live blobs; remove the temporary clone.
**Exit Code:** 0
**Claim Source:** executed

The rollback itself was exact and retained facets 1 and 2:

```text
rollback path=bubbles/scripts/state-transition-guard.sh baseline=2665c6e34ec9a9876e0c48d96897988500a8a742 isolated=2665c6e34ec9a9876e0c48d96897988500a8a742
rollback path=bubbles/scripts/receipt-identity-selftest.sh baseline=5f852e27c96f8df5749e5fb845c27db880f04d4f isolated=5f852e27c96f8df5749e5fb845c27db880f04d4f
rollback path=bubbles/scripts/state-transition-guard-selftest.sh baseline=f48041e8df9c7c544f5b4f40d7c359cd1fa1db52 isolated=f48041e8df9c7c544f5b4f40d7c359cd1fa1db52
rollback path=bubbles/scripts/evidence-admission-hardening-selftest.sh baseline=9dd9864c24f966f706a3ae91d80c3863374b5a48 isolated=9dd9864c24f966f706a3ae91d80c3863374b5a48
=== retained facet 1 source ===
4698:        | ($rows | group_by(.cmd | cmd_identity) | map(.[0] | target_identity)) as $targets
=== retained facet 2 source ===
4602:      def strip_wrappers:
facet3_normalizer_absent_after_rollback=true
structured_renderer_absent_after_rollback=true
```

The HEAD-pinned focused baseline then executed with exit `0`, `20 passed, 0
failed`, and sha256
`c7695858da80bbe336b7bd5504f35675768410178e59d883c1b1a9c2c7ed823a`.
Its raw output names both retained facets and their adversarial bounds. After
the exact current blobs were restored inside the clone, the focused canary
again produced `39 passed, 0 failed` with sha256
`2dba3ef9ff49ca24db0584b78e60f2d8a89d1ccc7fc4717af6a13bf8f365cb9f`, and the
targeted real-guard canary again produced zero failures with sha256
`deb4f0c7f9b3443e81c04d41a2d4224f3894f6846c562c6e57dc921cd0aa0f7f`.

Finally, all four live blob IDs still matched their pre-experiment values and
`rollback_temp_removed=true`. The experiment never checked out, restored, or
rewrote any live worktree path.

#### Current Work-Boundary Proof

**Executed:** YES
**Phase:** implement
**Command:** `bash bubbles/scripts/work-boundary-resolve.sh --feature-dir bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization --candidate-repo bubbles --candidate-path <each candidate> --require-allowed-paths`
**Exit Code:** 0 for every candidate
**Claim Source:** executed

```text
path=bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization/report.md disposition=in-boundary repoMatch=true
path=bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization/scopes.md disposition=in-boundary repoMatch=true
path=bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization/state.json disposition=in-boundary repoMatch=true
path=bubbles/scripts/state-transition-guard.sh disposition=in-boundary repoMatch=true
path=bubbles/scripts/receipt-identity-selftest.sh disposition=in-boundary repoMatch=true
path=bubbles/scripts/state-transition-guard-selftest.sh disposition=in-boundary repoMatch=true
path=bubbles/scripts/evidence-admission-hardening-selftest.sh disposition=in-boundary repoMatch=true
```

Together with [Current Code-Only Snapshot](#current-code-only-snapshot), this
proves the BUG-033 implementation inventory is restricted to declared behavior
paths. Other dirty paths and the BUG-037 hunks inside the shared selftest are
concurrent work and are excluded from this packet's evidence and edits.

The canonical implementation-reality scan also executed with exit `0` and
sha256 `201282a9fadf78fa1fec3651fec7677698ec685aad26e39ebcb705c8a9685e68`.
It scanned one design-resolved implementation file, reported zero violations,
and emitted one discovery warning because it fell back from `scopes.md` to
`design.md`. This report preserves that warning and does not present the scan
as warning-free.

#### Portability Observation And Uncertainty

**Executed:** YES
**Phase:** implement
**Command:** `uname -s; uname -m; sw_vers; executable presence checks`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
=== BUG-033 portability host observation ===
kernel=Darwin
machine=arm64
--- operating system ---
ProductName:            macOS
ProductVersion:         26.5.2
BuildVersion:           25F84
--- required local executables ---
present=/bin/bash
present=/usr/bin/perl
present=/usr/bin/awk
present=/usr/bin/grep
present=/usr/bin/sed
present=/opt/local/bin/gtimeout
present=/usr/bin/jq
```

> **Uncertainty Declaration**
> **What was attempted:** The focused and real-guard BUG-033 matrices executed
> on the macOS host identified above.
> **What was observed:** Recorded `timeout`, `gtimeout`, and portable-Perl
> spellings classified successfully on Darwin arm64 without invoking those
> recorded spellings during identity derivation.
> **Why this is uncertain:** No Linux host or Linux container was executed in
> this implementation phase.
> **What would resolve this:** Run the same focused and targeted commands in an
> actual supported Linux environment and compare their classification results.

## Current Test Phase T24-T26 Evidence

**Executed:** YES
**Phase:** test
**Agent:** bubbles.test
**Claim Source:** executed

### Missing-Assertion RED

The planned T24 and T25 behaviors already had real-guard fixtures, but the
fixtures did not assert every planned result. These current-session scans were
the test-owned RED before the assertion repair:

```text
$ /usr/bin/grep -nF "SCN-B033-002: refusal names identity_a=npm run lint" bubbles/scripts/state-transition-guard-selftest.sh
T24_REQUIRED_ASSERTION_SCAN_EXIT=1
$ /usr/bin/grep -nF "SCN-B033-003: accepted panel proves all six spellings resolve to family node" bubbles/scripts/state-transition-guard-selftest.sh
T25_REQUIRED_ASSERTION_SCAN_EXIT=1
Observed gap: T24 asserted the reason but not both identities and the blocking effect.
Observed gap: T25 omitted the sh -c spelling and exposed no real-process identity=node assertion.
Repair surface: bubbles/scripts/state-transition-guard-selftest.sh
Production source changed by this repair: no
Human acceptance changed by this repair: no
Certification fields changed by this repair: no
```

The behavior-level RED remains the pre-repair Check 43 reproduction in
[bug.md](bug.md#reproduction). This RED records the narrower test deficiency
found during T24/T25 execution.

### T24-T26 Real-Process GREEN

**Command:** `bash bubbles/scripts/evidence-capture.sh --label "BUG-033 T24-T26 targeted whole guard" -- env BUBBLES_STATE_TRANSITION_GUARD_BUG033_ONLY=1 /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 600 bash bubbles/scripts/state-transition-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-033 T24-T26 targeted whole guard
$ env BUBBLES_STATE_TRANSITION_GUARD_BUG033_ONLY=1 /usr/bin/perl -e alarm shift @ARGV; exec @ARGV 600 bash bubbles/scripts/state-transition-guard-selftest.sh
exit: 0
lines: 145
sha256: 91bd984ea483f7bb4b0cb2ac818e13c05504145141db38e22d5382d3d0a29efc
--- first 20 ---
PASS: G061 same-repo case reaches Check 3F
PASS: G061 allows bubbles.validate routing to the currently guarded spec
PASS: G061 does not classify a same-spec specialist route as external
PASS: G061 blocks an external/upstream route without crossRepoFollowUp
PASS: G061 does not admit the incomplete external route
PASS: G061 allows a complete external route with crossRepoFollowUp
PASS: G061 keeps the complete external route non-blocking
PASS: G061 requires crossRepoFollowUp for a commit route
PASS: G061 requires crossRepoFollowUp for a ticket route
PASS: G061 requires crossRepoFollowUp for an explicit external routing class
PASS: G061 requires crossRepoFollowUp for an explicit upstream routing class
PASS: G061 rejects a string crossRepoFollowUp value with a type-specific reason
PASS: G061 does not treat a string crossRepoFollowUp value as true
PASS: G061 rejects an ambiguous traversal alias of the guarded spec
PASS: G061 rejects a duplicate-separator alias of the guarded spec
PASS: G061 rejects a backslash alias of the guarded spec
PASS: G061 rejects a surrounding-whitespace alias of the guarded spec
PASS: G061 rejects a parent-traversal alias of the guarded spec
PASS: G061 rejects an absolute alias of the guarded spec
PASS: G061 does not resolve a symlink alias as the guarded spec
--- omitted 105 line(s); sha256 above covers the full output ---
--- last 20 ---
PASS: SCN-B033-010: gtimeout diagnostic names artifact-lint
PASS: SCN-B033-010: gtimeout diagnostic names state-transition-guard
PASS: SCN-B033-010: portable-perl-alarm exposes and refuses different underlying commands
PASS: SCN-B033-010: portable-perl-alarm diagnostic names artifact-lint
PASS: SCN-B033-010: portable-perl-alarm diagnostic names state-transition-guard
PASS: SCN-B033-011: the real guard refuses normalized commands with different exits
PASS: SCN-B033-011: refusal identifies the exit-result reason
PASS: SCN-B033-011: refusal names the first normalized identity
PASS: SCN-B033-011: refusal preserves exit 0
PASS: SCN-B033-011: refusal names the second normalized identity
PASS: SCN-B033-011: refusal preserves exit 1
PASS: SCN-B033-008 terminal contract: refusal fields remain in stable order
PASS: SCN-B033-008 terminal contract: control-bearing recorded identity remains blocking
PASS: SCN-B033-008 terminal contract: backslash, tab, newline, and escape bytes are escaped
PASS: SCN-B033-008 terminal contract: recorded controls cannot inject diagnostic fields
PASS: SCN-B033-010 terminal contract: a long identity remains complete without truncation
PASS: SCN-B033-010 terminal contract: narrow output uses two-space continuation lines
PASS: SCN-B033-010 terminal contract: Check 43 semantic output is ANSI-free

state-transition-guard BUG-033 selftest: 0 failure(s)
```

The same command also ran unfiltered. These named lines are the direct T24 and
T25 proof and the one-line scenario inventory for T26:

```text
PASS: SCN-B033-001: the real guard accepts repeated honest re-runs of one validator over two targets
PASS: SCN-B033-002: refusal reports reason=command-identity-mismatch
PASS: SCN-B033-002: refusal names identity_a=npm run lint
PASS: SCN-B033-002: refusal names identity_b=npm run test
PASS: SCN-B033-002: refusal ends with effect=TRANSITION_BLOCKED
PASS: SCN-B033-003: accepted panel proves direct spelling resolves to family node
PASS: SCN-B033-003: accepted panel proves env spelling resolves to family node
PASS: SCN-B033-003: accepted panel proves zsh spelling resolves to family node
PASS: SCN-B033-003: accepted panel proves assignment spelling resolves to family node
PASS: SCN-B033-003: accepted panel proves bash spelling resolves to family node
PASS: SCN-B033-003: accepted panel proves sh spelling resolves to family node
PASS: SCN-B033-003: sh spelling produces no wrapper-only clone allegation
PASS: SCN-B033-004: the real guard refuses two different programs behind transparent wrappers
PASS: SCN-B033-005: the real guard accepts direct, timeout, and gtimeout deterministic siblings
PASS: SCN-B033-006: the real guard accepts the exact portable alarm launcher
PASS: SCN-B033-007: the real guard accepts every supported launcher composition
PASS: SCN-B033-008: the real guard refuses arbitrary Perl versus the direct command
PASS: SCN-B033-009: timeout-option remains incompatible with the direct command
PASS: SCN-B033-010: timeout exposes and refuses different underlying commands
PASS: SCN-B033-011: the real guard refuses normalized commands with different exits
state-transition-guard BUG-033 selftest: 0 failure(s)
```

`evidence-capture.sh --verify` re-executed the selector and returned:

```text
[evidence-capture] VERIFIED - output still hashes to 91bd984ea483f7bb4b0cb2ac818e13c05504145141db38e22d5382d3d0a29efc
```

### Supporting Test Matrix

| Surface | Current command | Exit | Current result |
| --- | --- | --- | --- |
| Focused production definitions | `bash bubbles/scripts/evidence-capture.sh --label "BUG-033 test-phase focused receipt identity" -- /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 300 bash bubbles/scripts/receipt-identity-selftest.sh` | 0 | 41 lines, 39 passed, 0 failed, sha256 `2dba3ef9ff49ca24db0584b78e60f2d8a89d1ccc7fc4717af6a13bf8f365cb9f` |
| Migrated evidence consumer | `bash bubbles/scripts/evidence-capture.sh --label "BUG-033 test-phase evidence-admission consumer" -- /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 600 bash bubbles/scripts/evidence-admission-hardening-selftest.sh` | 0 | 33 lines, 16 passed, 0 failed, sha256 `cc8efcf63c2bdf26c654c8098834faa2488820a590dc2728eb4bc20f62853763` |
| Shell parse | `bash -n` over the four BUG-033 behavior/consumer scripts | 0 | `BASH_N_EXIT=0` |
| ShellCheck | `shellcheck -S warning -x` over the same four scripts | 0 | `SHELLCHECK_WARNING_EXIT=0` |
| Regression quality | `bash bubbles/scripts/regression-quality-guard.sh --bugfix bubbles/scripts/state-transition-guard-selftest.sh` | 0 | 0 violations, 0 warnings, adversarial signal present |
| Scenario obligations | `bash bubbles/scripts/scenario-obligation-lint.sh bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization` | 0 | 11 coherent scenario matrices |
| Test mechanisms | `bash bubbles/scripts/test-mechanism-lint.sh bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization` | 0 | 11 coherent mechanisms; mutation adapter `none` is inert |
| Linked-test resolution | `bash bubbles/scripts/scenario-test-resolve.sh bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization --repo-root .` | 0 | 22 references resolved by literal scan |
| Test-file diff check | `git diff --check -- bubbles/scripts/state-transition-guard-selftest.sh` | 0 | `TEST_FILE_DIFF_CHECK_EXIT=0` |

The focused and consumer outputs exactly reproduce the current raw compact
blocks at [Facet 3 Focused Green Evidence](#facet-3-focused-green-evidence) and
[Current Migrated Consumer Proof](#current-migrated-consumer-proof). They are
cited rather than pasted a second time.

### Test Integrity Audits

**Claim Source:** interpreted
**Interpretation:** The BUG-033 fixtures write isolated JSONL receipt logs and
invoke the real `state-transition-guard.sh` process. Their assertions read the
real guard exit and Check 43 terminal panel. The BUG-033 block contains no
request interception, mock API, silent return, skip, only, todo, pending, or
disabled-test marker. The sole repository-wide mock-pattern match in the large
shared selftest is fixture prose at line 1385, outside the BUG-033 block. T24 is
adversarial because removing the command mismatch or blocking effect makes its
required fields disappear. T25 is adversarial because leaving any wrapper in
front of `node` turns that case into a refused family mismatch. T26 asserts all
eleven named scenarios and the terminal-contract bounds through the real guard.

The asserted values are produced by Check 43. The tests do not assert a canned
guard response or a value returned unchanged by a mock.

### Test-Phase Portability Disposition

**Claim Source:** executed

- The full focused and real-process matrices executed on the current macOS host.
- The approved portability capture exited `0` with 37 lines and sha256
  `b33d27363072b9c3b2f9cc24d2f2839a1204eb6a2dc30a9376893df8359856ed`.
  `evidence-capture.sh --verify` re-derived that digest successfully.
- `bash bubbles/scripts/bsd-userland-sim-selftest.sh` emitted its defined SKIP on
  macOS because that simulator is a GNU/Linux-host tool.
- The portability guard's own header forbids pointing it at framework
  `bubbles/scripts/`; doing so reports recorded `timeout` command strings as raw
  launcher invocations and is not an admissible portability verdict.
- The committed Linux lane is `.github/workflows/agnosticity.yml` job
  `release-hygiene`, which runs `bash bubbles/scripts/cli.sh release-check` on
  `ubuntu-latest`. This uncommitted working tree cannot execute that remote lane.
- A targeted search found no committed local Docker, Podman, or other container
  runner for this BUG-033 matrix. No image was invented or pulled.

> **Uncertainty Declaration**
> **What was attempted:** The approved portability selftests and the full
> BUG-033 focused and real-guard matrices ran on macOS. Existing CI and
> container surfaces were inspected.
> **What was observed:** macOS execution is green. The Linux-only BSD simulator
> correctly skipped, and no repository-approved local Linux runner exists.
> **Why this is uncertain:** No Linux kernel/userland executed the current dirty
> working tree.
> **What would resolve this:** Execute the same focused and BUG-033-only
> real-guard commands through the committed `ubuntu-latest` release-hygiene
> lane, or another repository-approved Linux runner that records the current
> source bytes.

The portability DoD item remains unchecked.

### T23 Disposition

**Executed:** NO
**Phase:** test
**Command:** `bash bubbles/scripts/evidence-capture.sh --label "BUG-033 framework validate" -- /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 1200 bash bubbles/scripts/cli.sh framework-validate`
**Exit Code:** not run
**Claim Source:** not-run

The complete canonical framework validation was not launched in this phase.
T23 remains unchecked. No timeout or partial run is presented as a pass.

## Current Tree Test Verification 2026-08-26

**Phase:** test
**Agent:** bubbles.test
**Claim Source:** executed

The authoritative repository packet validated at control revision `72` before
local reads. The persisted `bugfix-fastlane` mode resolved through the
registry's explicit grandfather path. The phase registry resolves `test` to
`bubbles.test`.

### Ordered Verification Results

| Order | Surface | Exit | Result |
| --- | --- | --- | --- |
| 1 | Focused receipt identity | 0 | 39 passed, 0 failed; 41 lines; sha256 `2dba3ef9ff49ca24db0584b78e60f2d8a89d1ccc7fc4717af6a13bf8f365cb9f` |
| 2 | BUG-033-only real guard | 0 | 0 failures; 145 lines; sha256 `91bd984ea483f7bb4b0cb2ac818e13c05504145141db38e22d5382d3d0a29efc` |
| 3 | Evidence-admission consumer | 0 | 16 passed, 0 failed; 33 lines; sha256 `cc8efcf63c2bdf26c654c8098834faa2488820a590dc2728eb4bc20f62853763` |
| 4 | Parse, ShellCheck, regression, scenario, mechanism, linked-test, diff, skip, mock, and bailout checks | 0 | All selected checks passed |
| 5 | Canonical full framework validation | 1 | Lock refusal before suite execution; 3 lines; sha256 `834bf07c409eeee44dc60759737179c2f8a0c45e3b40067de43ac7f3e304b993` |
| 6 | Canonical release check | not run | Ineligible because order 5 did not exit 0 |

### Focused Receipt Identity Evidence

**Command:** `bash bubbles/scripts/evidence-capture.sh --label "BUG-033 current-tree focused receipt identity" -- /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 300 bash bubbles/scripts/receipt-identity-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-033 current-tree focused receipt identity
$ /usr/bin/perl -e alarm shift @ARGV; exec @ARGV 300 bash bubbles/scripts/receipt-identity-selftest.sh
exit: 0
lines: 41
sha256: 2dba3ef9ff49ca24db0584b78e60f2d8a89d1ccc7fc4717af6a13bf8f365cb9f
--- first 20 ---
PASS: facet 1: 9 honest re-runs of one validator over 2 targets are not reported as cloned evidence
PASS: facet 1: the re-run group is accepted through the deterministic-sibling path, not by an empty analysis
PASS: facet 1 bound: two identities sharing ONE target and one stdout are still refused
PASS: facet 2: 'node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: 'env PAGE=alpha node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: 'zsh -c node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: 'PAGE=alpha node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: 'bash -c node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: 'sh -c node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: five wrapper spellings of one command over one target are not reported as cloned evidence
PASS: facet 2 bound: two different programs behind identical wrappers are still refused
PASS: facet 2 bound: the diagnostic names the unwrapped cargo and npm identities
PASS: SCN-B033-005: timeout exposes the direct artifact-lint identity
PASS: SCN-B033-005: gtimeout exposes the direct artifact-lint identity
PASS: SCN-B033-006: the exact portable Perl alarm launcher exposes the direct artifact-lint identity
PASS: SCN-B033-007: composed spelling 'timeout 120 env PAGE=alpha zsh -c node scripts/check-page.mjs alpha' exposes node scripts/check-page.mjs
PASS: SCN-B033-007: composed spelling 'env PAGE=alpha gtimeout 120 bash -c node scripts/check-page.mjs alpha' exposes node scripts/check-page.mjs
PASS: SCN-B033-007: composed spelling 'zsh -c /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 120 env PAGE=alpha node scripts/check-page.mjs alpha' exposes node scripts/check-page.mjs
PASS: SCN-B033-007: composed spelling 'PAGE=alpha timeout 120 sh -c node scripts/check-page.mjs alpha' exposes node scripts/check-page.mjs
PASS: SCN-B033-008: arbitrary Perl remains unchanged and distinct from the direct command
--- omitted 1 line(s); sha256 above covers the full output ---
--- last 20 ---
PASS: SCN-B033-009: malformed spelling 'timeout 120' remains unchanged
PASS: SCN-B033-009: malformed spelling 'gtimeout 120' remains unchanged
PASS: SCN-B033-009: malformed spelling 'timeout --preserve-status 120 artifact-lint.sh TARGET' remains unchanged
PASS: SCN-B033-009: malformed spelling '/usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 120' remains unchanged
PASS: SCN-B033-009: malformed spelling '/usr/bin/perl -e 'alarm shift @ARGV; print @ARGV' 120 artifact-lint.sh TARGET' remains unchanged
PASS: SCN-B033-010: timeout preserves both distinct underlying command identities
PASS: SCN-B033-010: gtimeout preserves both distinct underlying command identities
PASS: SCN-B033-010: portable-perl-alarm preserves both distinct underlying command identities
PASS: SCN-B033-011: normalized commands with different exits remain incompatible
PASS: SCN-B033-011 negative control: equal exits remove the exit-result incompatibility
PASS: BUG-007 pin: empty stdout stays exempt after the BUG-033 relaxation
PASS: BUG-032 pin: a collision with no independent execution provenance is still refused
PASS: BUG-032 pin: incompatible command families sharing one stdout are still refused
PASS: BUG-028 defect 1: one command tagged test and validate is not reported as cloned evidence
PASS: BUG-028 defect 1 bound: two identities sharing ONE target and one stdout are still refused
PASS: BUG-028 bound: a group mixing two specs on one stdout is still refused
PASS: BUG-028 canonical: one validator over three subjects with differing tags is not reported as cloned evidence
PASS: BUG-028 canonical: the three-subject group is accepted through the deterministic-sibling path

receipt-identity-selftest: 39 passed, 0 failed
```

### BUG-033-Only Real-Guard Evidence

**Command:** `bash bubbles/scripts/evidence-capture.sh --label "BUG-033 current-tree targeted whole guard" -- env BUBBLES_STATE_TRANSITION_GUARD_BUG033_ONLY=1 /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 600 bash bubbles/scripts/state-transition-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-033 current-tree targeted whole guard
$ env BUBBLES_STATE_TRANSITION_GUARD_BUG033_ONLY=1 /usr/bin/perl -e alarm shift @ARGV; exec @ARGV 600 bash bubbles/scripts/state-transition-guard-selftest.sh
exit: 0
lines: 145
sha256: 91bd984ea483f7bb4b0cb2ac818e13c05504145141db38e22d5382d3d0a29efc
--- first 20 ---
PASS: G061 same-repo case reaches Check 3F
PASS: G061 allows bubbles.validate routing to the currently guarded spec
PASS: G061 does not classify a same-spec specialist route as external
PASS: G061 blocks an external/upstream route without crossRepoFollowUp
PASS: G061 does not admit the incomplete external route
PASS: G061 allows a complete external route with crossRepoFollowUp
PASS: G061 keeps the complete external route non-blocking
PASS: G061 requires crossRepoFollowUp for a commit route
PASS: G061 requires crossRepoFollowUp for a ticket route
PASS: G061 requires crossRepoFollowUp for an explicit external routing class
PASS: G061 requires crossRepoFollowUp for an explicit upstream routing class
PASS: G061 rejects a string crossRepoFollowUp value with a type-specific reason
PASS: G061 does not treat a string crossRepoFollowUp value as true
PASS: G061 rejects an ambiguous traversal alias of the guarded spec
PASS: G061 rejects a duplicate-separator alias of the guarded spec
PASS: G061 rejects a backslash alias of the guarded spec
PASS: G061 rejects a surrounding-whitespace alias of the guarded spec
PASS: G061 rejects a parent-traversal alias of the guarded spec
PASS: G061 rejects an absolute alias of the guarded spec
PASS: G061 does not resolve a symlink alias as the guarded spec
--- omitted 105 line(s); sha256 above covers the full output ---
--- last 20 ---
PASS: SCN-B033-010: gtimeout diagnostic names artifact-lint
PASS: SCN-B033-010: gtimeout diagnostic names state-transition-guard
PASS: SCN-B033-010: portable-perl-alarm exposes and refuses different underlying commands
PASS: SCN-B033-010: portable-perl-alarm diagnostic names artifact-lint
PASS: SCN-B033-010: portable-perl-alarm diagnostic names state-transition-guard
PASS: SCN-B033-011: the real guard refuses normalized commands with different exits
PASS: SCN-B033-011: refusal identifies the exit-result reason
PASS: SCN-B033-011: refusal names the first normalized identity
PASS: SCN-B033-011: refusal preserves exit 0
PASS: SCN-B033-011: refusal names the second normalized identity
PASS: SCN-B033-011: refusal preserves exit 1
PASS: SCN-B033-008 terminal contract: refusal fields remain in stable order
PASS: SCN-B033-008 terminal contract: control-bearing recorded identity remains blocking
PASS: SCN-B033-008 terminal contract: backslash, tab, newline, and escape bytes are escaped
PASS: SCN-B033-008 terminal contract: recorded controls cannot inject diagnostic fields
PASS: SCN-B033-010 terminal contract: a long identity remains complete without truncation
PASS: SCN-B033-010 terminal contract: narrow output uses two-space continuation lines
PASS: SCN-B033-010 terminal contract: Check 43 semantic output is ANSI-free

state-transition-guard BUG-033 selftest: 0 failure(s)
```

### Evidence-Admission Consumer Evidence

**Command:** `bash bubbles/scripts/evidence-capture.sh --label "BUG-033 current-tree evidence-admission hardening" -- /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 600 bash bubbles/scripts/evidence-admission-hardening-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-033 current-tree evidence-admission hardening
$ /usr/bin/perl -e alarm shift @ARGV; exec @ARGV 600 bash bubbles/scripts/evidence-admission-hardening-selftest.sh
exit: 0
lines: 33
sha256: cc8efcf63c2bdf26c654c8098834faa2488820a590dc2728eb4bc20f62853763
--- output ---
=== CONTROL PASS cases ===
PASS: CONTROL (a): inline fenced command block (cmd + exit 0 + >=10 lines) passes with no advisory (passes; no advisory)
PASS: CONTROL (b): resolver link to a real >=10-line fenced command block passes with no advisory (passes; no advisory)

=== ADVISORY PASS case (fix #3) ===
PASS: ADVISORY (#3): resolved 12-line prose block accepted AND emits Check-9 ADVISORY (passes; emits Check-9 ADVISORY)

=== CHECK 43 receipt staleness (IMP-027 SCOPE-3, EV-2) ===
PASS: CHECK 43 (fresh): receipt whose inputClosure still matches the tree passes (passes)
PASS: CHECK 43 (stale): receipt whose input changed after capture BLOCKS (blocks; names Check-9 reason)
PASS: CHECK 43 (clone): one stdout hash cited by TWO DIFFERENT commands BLOCKS (blocks; names Check-9 reason)
PASS: CHECK 43 (re-run): same stdout hash from the SAME command is honest, passes (passes)
PASS: CHECK 43 (re-spelled): same command with an equivalent --repo-root value passes (passes)
PASS: CHECK 43 (optional arg): same command and subject with an extra filter argument passes (passes)

=== BLOCKING FAIL cases ===
PASS: BLOCK (IMP-027 SCOPE-3): prose-only block backing an EXECUTION claim (blocks; names Check-9 reason)
PASS: BLOCK (#1): truly-bare '-> Evidence: done' marker (blocks; names Check-9 reason)
PASS: BLOCK (#2): plain link to a report with <10 non-blank lines (blocks; names Check-9 reason)
PASS: BLOCK (#5): uppercase '- [X]' item with no evidence (blocks; names Check-9 reason)
PASS: BLOCK (#7): duplicated identical '- [x]' lines, only the first evidenced (blocks; names Check-9 reason)
PASS: BLOCK (#6): tool-log entry with spec:"" is non-matching (blocks; names Check-9 reason)
SKIP: BLOCK (#4) schema-invalid tool-log line - python 'jsonschema' not importable

=== Tool-log POSITIVE control (proves #4/#6 are non-tautological) ===
PASS: CONTROL (tool-log): a VALID spec-scoped entry makes Check 9 COVER the bare item (Check 9 tool-log path COVERS the bare item)

=== NON-TAUTOLOGY: #1 and #5 must PASS on the OLD guard (86fc700) ===
SKIP: NON-TAUTOLOGY (#1/#5) - old-guard commit 86fc700 is absent from this clone (shallow checkout); fetch full history to run the teeth-proof

==============================================================
evidence-admission-hardening-selftest: 16 passed / 0 failed
==============================================================
```

The two printed skips are pre-existing optional probes outside the migrated
BUG-033 Check 43 assertion. They are not counted as BUG-033 scenario coverage.

### Packet Integrity Evidence

**Claim Source:** executed

| Command | Exit | Raw result |
| --- | --- | --- |
| `/usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 120 bash bubbles/scripts/scenario-test-resolve.sh bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization --repo-root .` | 0 | `[scenario-test-resolve] OK - 22 reference(s) resolved via literal-scan` |
| `/usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 120 bash -n bubbles/scripts/state-transition-guard.sh bubbles/scripts/receipt-identity-selftest.sh bubbles/scripts/state-transition-guard-selftest.sh bubbles/scripts/evidence-admission-hardening-selftest.sh` | 0 | `BUG033_BASH_PARSE_EXIT=0` |
| `/usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 300 shellcheck -S warning -x bubbles/scripts/state-transition-guard.sh bubbles/scripts/receipt-identity-selftest.sh bubbles/scripts/state-transition-guard-selftest.sh bubbles/scripts/evidence-admission-hardening-selftest.sh` | 0 | `BUG033_SHELLCHECK_WARNING_EXIT=0` |
| `/usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 300 bash bubbles/scripts/regression-quality-guard.sh --bugfix bubbles/scripts/state-transition-guard-selftest.sh` | 0 | `0 violation(s), 0 warning(s); adversarial signal detected` |
| `/usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 300 bash bubbles/scripts/scenario-obligation-lint.sh bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization` | 0 | `OK - 11 scenario(s) with a coherent derived obligation matrix` |
| `/usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 300 bash bubbles/scripts/test-mechanism-lint.sh bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization` | 0 | `OK - 11 declared mechanism(s); mutation adapter none is inert` |
| `/usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 120 git diff --check -- <BUG-033 authorized source, test, report, scope, and execution-state paths>` | 0 | `BUG033_DIFF_CHECK_EXIT=0` |
| Token-bounded skip-marker scan over the three selected test files | 0 | `BUG033_SKIP_MARKER_SCAN=zero-matches` |
| Region-scoped mock/interception scan over the executed BUG-033 real-process block | 0 | `BUG033_REAL_PROCESS_MOCK_AUDIT=zero-matches` |
| Scenario-labeled bailout scan over the focused and real-process tests | 0 | `BUG033_SCENARIO_BAILOUT_SCAN=zero-matches` |

**Claim Source:** interpreted
**Interpretation:** The focused test extracts the production Check 43 jq
program and asserts transformed classifier output. The real-process suite
writes isolated receipt logs, invokes the actual state-transition guard, and
asserts its exit and terminal panel. Replacing the production classifier with
an identity pass-through would fail the launcher, malformed grammar, command
distinction, and exit-result assertions. No selected assertion merely returns
its own fixture unchanged.

### Canonical Framework Validation Attempt

**Command:** `bash bubbles/scripts/evidence-capture.sh --label "BUG-033 current-tree framework validate" -- /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 7200 bash bubbles/scripts/cli.sh framework-validate`
**Exit Code:** 1
**Claim Source:** executed

```text
# BUG-033 current-tree framework validate
$ /usr/bin/perl -e alarm shift @ARGV; exec @ARGV 7200 bash bubbles/scripts/cli.sh framework-validate
exit: 1
lines: 3
sha256: 834bf07c409eeee44dc60759737179c2f8a0c45e3b40067de43ac7f3e304b993
--- output ---
ERROR: another framework-validate run is already in progress on this machine.
  Concurrent runs corrupt each other's shared scratch fixtures and produce
  false failures. Wait for the other run to finish, then re-run.
```

This is a lock refusal before suite execution. It is not recorded as a current
framework test failure and not recorded as a framework pass. No second full
validation was started.

### Conditional Release Check

**Command:** `bash bubbles/scripts/evidence-capture.sh --label "BUG-033 current-tree release check" -- /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 3600 bash bubbles/scripts/cli.sh release-check`
**Exit Code:** not run
**Claim Source:** not-run

The required precondition was not met because the canonical framework
validation attempt did not exit `0`. No release verdict exists for this tree.

### Current Test Verdict

T23 remains unchecked. Scope 1, BUG-033 status, and validate-owned
certification remain `in_progress`. Linux portability and human acceptance
remain truthful external obligations because this invocation executed neither.

## Resumed T23 Framework-Stats Ownership Route 2026-08-30

### Prior Canonical Run Records

**Phase:** test
**Claim Source:** interpreted
**Interpretation:** This invocation read the current tool log. It did not
execute either prior canonical command.

- Tool-log row 162 records `framework-validate` exit `0` at source revision
  `aafca4398e2b4a4490cdfffba35387c4fdb44d37`.
- Tool-log row 163 records the subsequent `release-check` exit `1` at the same
  source revision.

### Current Framework-Stats Freshness Check

**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 120 /bin/sh bubbles/scripts/generate-framework-stats.sh --check`
**Exit Code:** 1
**Claim Source:** executed

```text
# BUG-033 resumed framework-stats freshness diagnostic
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=10s 120 /bin/sh bubbles/scripts/generate-framework-stats.sh --check
exit: 1
lines: 1
sha256: e2a8448c144ff6f5ed04203323e37c82a09eeb27d4fb6c4d48dbfd6bd572a03c
--- output ---
Generated framework stats JSON is stale. Run bubbles/scripts/generate-framework-stats.sh
```

The structured command record is tool-log row 165. The check did not modify a
generated output.

### Exact Count And Output-Set Diagnosis

**Phase:** test
**Claim Source:** executed

The bounded count diagnostic is tool-log row 166. It produced exit `0` and
evidence-capture digest
`57047ee0414115041f2647e496cda9868d1418fe35bfc823922061c935cd364b`.

```text
FRAMEWORK_STATS_COUNT_DIAGNOSTIC_BEGIN
EXPECTED agents=41 prompts=41 gates=121 workflowModes=61 primitives=15 phases=32 guardChecks=45 version=7.28.0
CURRENT_JSON agents=41 gates=121 workflowModes=61 phases=30
MISMATCH agents=no gates=no workflowModes=no phases=yes
FRAMEWORK_STATS_COUNT_DIAGNOSTIC_END
```

The source-to-output boundary diagnostic is tool-log row 167. It produced exit
`0`, 87 lines, and evidence-capture digest
`02b093118364018a9fd7d6db67f31dce586ee094ee40792ba16511d19baad252`.
It established this exact generator write set:

1. `docs/generated/framework-stats.json`
2. `docs/generated/framework-stats.md`
3. `docs/guides/FRAMEWORK_CONCEPTS.md`
4. `README.md`
5. `docs/CHEATSHEET.md`
6. `docs/its-not-rocket-appliances.html`

All six paths were tracked and clean before diagnosis. Every path resolved to
`route-same-repo` under the current BUG-033 work boundary.

The phase-count change from `30` to `32` changes bytes in exactly four paths:

1. `docs/generated/framework-stats.json`
2. `docs/generated/framework-stats.md`
3. `docs/CHEATSHEET.md`
4. `docs/its-not-rocket-appliances.html`

The current inputs leave these two generator write targets byte-stable:

1. `docs/guides/FRAMEWORK_CONCEPTS.md`
2. `README.md`

### Isolated-Candidate Decision

**Phase:** test
**Claim Source:** executed

The bounded HEAD comparison is tool-log row 168. It produced exit `1`, 16
lines, and evidence-capture digest
`e617eb448f0341717e8bac1787405193c1068fbf2735099c7b0a286bc0cafce6`.
The nonzero result rejected the candidate-avoidance hypothesis.

```text
HEAD=aafca4398e2b4a4490cdfffba35387c4fdb44d37
HEAD_PHASE_COUNT=32
WORKTREE_PHASE_COUNT=32
HEAD_STATS_JSON_PHASES=30
WORKTREE_STATS_JSON_PHASES=30
HEAD_STATS_ALIGNMENT=fail
PRIMARY_TREE_STATS_ALIGNMENT=fail
ISOLATED_HEAD_BASE_CAN_AVOID_THIS_DRIFT=no
```

An isolated candidate at the same source revision would retain the stale
`32`-versus-`30` mismatch. This invocation created no temporary repository and
claimed no authority outside the validated `bubbles` root.

### Finding F-B033-T23-STATS-FRESHNESS

| Field | Value |
| --- | --- |
| Severity | blocker |
| Goal impact | blocking-external |
| Owner | `bubbles.docs` |
| Blocking result | T23 cannot reach a clean release-check on this source epoch. |
| Required boundary | A new actionable packet must authorize all six generator write targets listed above. |
| Bounded owner action | Run `sh bubbles/scripts/generate-framework-stats.sh`, verify the four-path byte-change set, and run the same command with `--check`. |

This test invocation did not run the mutating generator. It did not run another
full framework validation or release check. T23 and portability remain
unchecked. Scope status, certification, and human acceptance remain unchanged.

## Planning-Owner Framework-Stats Boundary Authorization 2026-08-30

**Phase:** planning
**Claim Source:** interpreted
**Interpretation:** This note records the boundary decision from current T23
evidence and generator ownership. It records no new execution evidence.

The recorded T23 diagnostics establish that `HEAD` and the worktree declare 32
phases. The checked-in generated statistics declare 30 phases in both trees.
The mismatch therefore exists at `HEAD`, independent of unrelated dirty work.

The canonical generator has six derived documentation targets.

1. `docs/generated/framework-stats.json`
2. `docs/generated/framework-stats.md`
3. `docs/guides/FRAMEWORK_CONCEPTS.md`
4. `README.md`
5. `docs/CHEATSHEET.md`
6. `docs/its-not-rocket-appliances.html`

The recorded byte-change diagnostic predicts changes in the two generated
statistics files, `docs/CHEATSHEET.md`, and the HTML document. The concepts
guide and `README.md` remain required write targets but should stay byte-stable.

The planning boundary now authorizes all six exact paths for `bubbles.docs`.
It authorizes no broader generated surface and no generator source change.
This planning action regenerated no documentation and claimed no test result.
Status, certification, human acceptance, and the next owner remain unchanged.

## Canonical Framework-Stats Refresh 2026-08-30

**Phase:** docs
**Agent:** bubbles.docs
**Finding:** F-B033-T23-STATS-FRESHNESS
**Claim Source:** executed

### Drift Detected And Corrected

| Documentation target | Before | After | Action |
| --- | --- | --- | --- |
| `docs/generated/framework-stats.json` | 30 phases | 32 phases | Regenerated |
| `docs/generated/framework-stats.md` | 30 phases | 32 phases | Regenerated |
| `docs/CHEATSHEET.md` | 30 phases | 32 phases | Regenerated |
| `docs/its-not-rocket-appliances.html` | 30 phases | 32 phases | Regenerated |
| `docs/guides/FRAMEWORK_CONCEPTS.md` | Current | Current | Verified byte-stable |
| `README.md` | Current | Current | Verified byte-stable |

The committed generator remained byte-identical. The refresh changed only the
four predicted documentation paths. The other 62 dirty paths retained their
pre-run status, byte count, and SHA-256.

### Pre-Mutation Six-Target Baseline

The exact command and its 76-line output are preserved in structured tool-log
row 175. Capture digest
`946914489935b077a99c79c0e75011fbd850763f00b200bd5b6f9b0fde313d0e`
covers every output line. This window contains lines 3 through 9 and 72 through
76 of that output.

**Exit Code:** 0
**Claim Source:** executed

```text
HEAD=aafca4398e2b4a4490cdfffba35387c4fdb44d37
TARGET_BASELINE tracked=true clean=true sha256=25d364e84cf3f4a76dba90551c4601b1c1881fec5671c3ed160ff8048d39c954 gitObject=9949e3ed31ae570dea1dd05e9f15f01635e2f746 bytes=115 path=docs/generated/framework-stats.json
TARGET_BASELINE tracked=true clean=true sha256=8550617fa4a4219717c07a34b799ac8e022759fcf5fb79e23f13017e1b779b4a gitObject=df96f6c999c413c9b10290449c854543258adb58 bytes=116 path=docs/generated/framework-stats.md
TARGET_BASELINE tracked=true clean=true sha256=c34f9f1c99d0c7793b66f9da6275d9e513e50d504645cce6ac6e08f308a82ed6 gitObject=e9976e8b0a52de7aa1244d886914b03489086d54 bytes=39712 path=docs/guides/FRAMEWORK_CONCEPTS.md
TARGET_BASELINE tracked=true clean=true sha256=a08b4b645b38ffe6c4ef8acf5d78ba460b0d510fbcf253826cb426e15578e665 gitObject=9a99cc92a5a1de529e9ebb4b8ea8bb20666bcba2 bytes=48449 path=README.md
TARGET_BASELINE tracked=true clean=true sha256=6b09a61f09fc18411651e1ad266773cef42a80c63e8522905e9c48a9b67a1e07 gitObject=680b3049297d988bc2d80390b0e4d8f1568249f4 bytes=95696 path=docs/CHEATSHEET.md
TARGET_BASELINE tracked=true clean=true sha256=98f8f437620f9ef778727b0a221d8522a8103474cf5940d01d0621601694c042 gitObject=784157799a889760ba8ee924c21a0e6db3189fba bytes=156009 path=docs/its-not-rocket-appliances.html
TARGET_COUNT=6
UNRELATED_DIRTY_COUNT=62
PREMUTATION_FAILURES=0
FRAMEWORK_STATS_PREMUTATION_RESULT=PASS
FRAMEWORK_STATS_PREMUTATION_END
```

### Canonical Generator And Boundary Evidence

Structured tool-log row 176 records the bounded command that invoked
`sh bubbles/scripts/generate-framework-stats.sh` exactly once. The command
exited `0`. Its 152 output lines have capture digest
`8f0da3146e55b829c6720c6f435f500ffc017948a54d005a7225f0b7f89d3772`.

**Exit Code:** 0
**Claim Source:** executed

```text
GENERATOR_SOURCE_UNCHANGED=true sha256=a1fd2a4b5e0e2022f229038394e8f57c7bc53802d51bb96649e791aa96649420
EXPECTED_CHANGED_COUNT=4
ACTUAL_CHANGED_COUNT=4
UNRELATED_BEFORE_COUNT=62
UNRELATED_AFTER_COUNT=62
BOUNDARY_FAILURES=0
FRAMEWORK_STATS_GENERATION_BOUNDARY_RESULT=PASS
FRAMEWORK_STATS_GENERATION_BOUNDARY_END
```

Structured tool-log row 179 records the corrected exact target attestation.
Its capture digest is
`0c86470180c665fbc3234c0e18bc6649dba2e39c1bfd10839e484cb0e3e504e8`.

**Exit Code:** 0
**Claim Source:** executed

```text
POST_GENERATION_TARGET_ATTESTATION_BEGIN
TARGET expected=changed sha256=2d030123ae92a7331c0be3116863f6f9ee494bf8345dcc8ede06f7e8048db299 bytes=115 status= M docs/generated/framework-stats.json path=docs/generated/framework-stats.json
TARGET expected=changed sha256=1222393e2fc38b473cb3e656c000ca0a677b5e079be1bde89a98a34027bad261 bytes=116 status= M docs/generated/framework-stats.md path=docs/generated/framework-stats.md
TARGET expected=stable sha256=c34f9f1c99d0c7793b66f9da6275d9e513e50d504645cce6ac6e08f308a82ed6 bytes=39712 status=clean path=docs/guides/FRAMEWORK_CONCEPTS.md
TARGET expected=stable sha256=a08b4b645b38ffe6c4ef8acf5d78ba460b0d510fbcf253826cb426e15578e665 bytes=48449 status=clean path=README.md
TARGET expected=changed sha256=f96c99fd394801d46918e01cdc486a961fc16f7af61ead676464b7319fed0544 bytes=95696 status= M docs/CHEATSHEET.md path=docs/CHEATSHEET.md
TARGET expected=changed sha256=e9d1b5b9d44a0c56a687e26cdd87d55ab25611932378abf2e1eacc210bb18ca3 bytes=156009 status= M docs/its-not-rocket-appliances.html path=docs/its-not-rocket-appliances.html
EXPECTED_CHANGED_COUNT=4
ACTUAL_CHANGED_COUNT=4
GENERATOR_SOURCE_UNCHANGED=true sha256=a1fd2a4b5e0e2022f229038394e8f57c7bc53802d51bb96649e791aa96649420
POST_ATTESTATION_FAILURES=0
POST_GENERATION_TARGET_ATTESTATION_RESULT=PASS
POST_GENERATION_TARGET_ATTESTATION_END
```

### Canonical Freshness Check

Structured tool-log row 177 records the only `--check` invocation in this
docs phase.

**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 120 sh bubbles/scripts/generate-framework-stats.sh --check`
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-033 canonical framework-stats freshness check
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=10s 120 sh bubbles/scripts/generate-framework-stats.sh --check
exit: 0
lines: 1
sha256: c87afc42604c0e8cf86cc6aa7727692f66e2fef5c7f5c787d3b24cb87bb72df2
--- output ---
Framework stats are current: 41 Agents · 121 Gates · 61 Workflow Modes · 32 Phases (v7.28.0)
```

The first unrelated-path inventory attempt exited `124` before generator
execution. The successful row 175 replaced that attempt. Row 178 emitted a
shell expansion diagnostic in an optional source-hash print. The corrected row
179 replaced that diagnostic. Neither superseded result supports this finding.

F-B033-T23-STATS-FRESHNESS is resolved for the docs phase. T23 remains
unchecked because `bubbles.test` still owns canonical framework validation and
the conditional release check. Bug status, scope status, certification, and
human acceptance remain unchanged.

## Completed Canonical Validation Failure Diagnostic 2026-08-30

**Phase:** test
**Agent:** bubbles.test
**Claim Source:** interpreted
**Interpretation:** This section combines current repository reads with the
focused commands recorded below. It does not treat the missing original
failure-label block as recovered evidence.

### Binding And Completed-Run Records

The repository packet validated before any repository read. It selected the
`bubbles` root with decision
`rb:vscode-890b012efcd4029f1bbec9142330177b:1`, control revision `1`, and
control-path digest
`sha256:4352ca9a8ff6b9b3dd529f4d875dbe0344a77d2c366d080a75c86a99b399593f`.

Tool-log row 187 is the completed post-stats canonical validation record.

| Field | Recorded value |
| --- | --- |
| Exit | `1` |
| Duration | `6,478,437` ms |
| Standard-output hash | `853cf8e2f9826548df95f40cb5b919c017fd207257d06ac227f9f615101de98d` |
| Standard-output bytes | `2,902` |
| Source revision | `aafca4398e2b4a4490cdfffba35387c4fdb44d37` |

The current validation receipt records `verdict=fail`, `checksExecuted=348`,
and `durationSeconds=6477`. It records the same source revision and
`recordedAt=2026-08-30T09:06:29Z`.

Row 187 ended the pre-diagnostic tool log. No canonical release-check record
followed it. Rows 188 onward belong only to this focused diagnostic.

The current validator source registers `Release manifest freshness` as its
last check. Its failure footer writes a fail receipt, prints the failure count,
and prints every collected label. Row 187 retained only hashes and byte counts.
It did not retain that rendered footer or the complete label array.

### Validator Process Check

**Command:** process-table scan for `[f]ramework-validate`
**Exit Code:** 0
**Claim Source:** executed
**Structured evidence:** tool-log row 188, capture digest
`b723b1b07eac69605e0a75c19100317bc55f8b30f0646a670575f55650a99c5c`

```text
VALIDATOR_PROCESS_SCAN_BEGIN
VALIDATOR_ACTIVE=no
VALIDATOR_PROCESS_SCAN_END
```

No validator remained active. This diagnostic sent no signal to any process.

### Focused Checks

**Claim Source:** executed

| Tool-log row | Framework-validation command form | Exit | Direct result |
| --- | --- | --- | --- |
| 190 | `sh bubbles/scripts/generate-framework-stats.sh --check` | 0 | Current at 41 agents, 121 gates, 61 workflow modes, and 32 phases |
| 191 | `bash bubbles/scripts/generate-cheatsheet-selftest.sh` | 0 | 20 output lines ended with `generate-cheatsheet-selftest: PASS` |
| 196 | `bash bubbles/scripts/workflow-registry-consistency.sh --quiet` | 0 | Zero standard-output and standard-error bytes |
| 193 | `bash bubbles/scripts/generate-release-manifest.sh --check` | 1 | `Release manifest is stale. Run bubbles/scripts/generate-release-manifest.sh` |

The framework-stats capture digest is
`c87afc42604c0e8cf86cc6aa7727692f66e2fef5c7f5c787d3b24cb87bb72df2`.
The cheatsheet capture digest is
`1ccd05fc1265e390654e2a363bd9e9104cf1886cf1be4d03a195c3d4c62d8ed4`.
The release-manifest capture digest is
`52f27aa0b967c3135d4550f4c8f46fd2fc97318332ea133fe49986f62dc34f9b`.

Tool-log row 195 re-derived the current managed-tree digest. It matched the
receipt digest exactly.

```text
VALIDATION_RECEIPT_TREE_EQUIVALENCE_BEGIN
RECORDED_TREE_DIGEST=2c85a8ea31ae996133b3303e919111502530c4ab5423e834894c36dd39d313f4
OBSERVED_TREE_DIGEST=2c85a8ea31ae996133b3303e919111502530c4ab5423e834894c36dd39d313f4
TREE_DIGEST_MATCH=yes
VALIDATION_RECEIPT_TREE_EQUIVALENCE_END
```

Tool-log row 194 compared the four stats-refresh outputs with their manifest
entries. All four current file hashes differ from the recorded hashes.

```text
RELEASE_MANIFEST_STATS_OUTPUT_COMPARISON_BEGIN
MANIFEST_ENTRY path=docs/generated/framework-stats.json recorded=25d364e84cf3f4a76dba90551c4601b1c1881fec5671c3ed160ff8048d39c954 actual=2d030123ae92a7331c0be3116863f6f9ee494bf8345dcc8ede06f7e8048db299 result=mismatch
MANIFEST_ENTRY path=docs/generated/framework-stats.md recorded=8550617fa4a4219717c07a34b799ac8e022759fcf5fb79e23f13017e1b779b4a actual=1222393e2fc38b473cb3e656c000ca0a677b5e079be1bde89a98a34027bad261 result=mismatch
MANIFEST_ENTRY path=docs/CHEATSHEET.md recorded=6b09a61f09fc18411651e1ad266773cef42a80c63e8522905e9c48a9b67a1e07 actual=f96c99fd394801d46918e01cdc486a961fc16f7af61ead676464b7319fed0544 result=mismatch
MANIFEST_ENTRY path=docs/its-not-rocket-appliances.html recorded=98f8f437620f9ef778727b0a221d8522a8103474cf5940d01d0621601694c042 actual=e9d1b5b9d44a0c56a687e26cdd87d55ab25611932378abf2e1eacc210bb18ca3 result=mismatch
MISMATCH_COUNT=4
RELEASE_MANIFEST_STATS_OUTPUT_COMPARISON_END
```

### Finding F-B033-T23-RELEASE-MANIFEST-FRESHNESS

| Field | Value |
| --- | --- |
| Severity | blocker |
| Goal impact | blocking-external |
| Immediate owner | `bubbles.plan` |
| Generated-artifact owner after authorization | `bubbles.docs` |
| Reproduced check | Source-registered `Release manifest freshness` |
| Current result | Exit `1` against the exact receipt managed-tree digest |
| Concrete mismatch | Four stats-refresh output hashes differ from their manifest entries |
| T23 effect | T23 remains unchecked |

The focused evidence reproduces the manifest freshness failure on the receipt's
managed tree. The source places this check last, immediately before the
failure footer. This establishes the failure condition for that ending tree.
It does not establish that this was the full run's only failed check.

The current BUG-033 boundary omits `bubbles/release-manifest.json`. Tool-log row
197 classified that path as `route-same-repo`. The same check classified this
report and `state.json` as `in-boundary`.

This invocation did not edit or regenerate the release manifest. Planning must
decide the one-path boundary change. After authorization, the generated-artifact
owner must run the canonical generator and its freshness check.

### Finding F-B033-DIAG-EMPTY-OUTPUT-CAPTURE

**Claim Source:** interpreted
**Interpretation:** Tool-log row 192 exposed a separate evidence-rendering
defect while wrapping the quiet registry check. Row 196 isolates the underlying
check from the wrapper.

The quiet registry check exited `0` with empty standard output and standard
error. The wrapper printed a second `0`, then two arithmetic-syntax errors,
while still returning exit `0`. The current wrapper assigns `total` from
`grep -c` plus a fallback `printf`. Empty input makes both commands print `0`.

This finding did not cause the completed canonical validation failure. It is
outside BUG-033 because `bubbles/scripts/evidence-capture.sh` is not allowed.
Its owner is `bubbles.bug` for a separately classified repair packet.

## Planning-Owner Boundary Correction 2026-08-30

**Phase:** bootstrap.

**Agent:** bubbles.plan.

**Claim Source:** interpreted.

**Interpretation:** This is a planning authorization based on the completed
canonical validation diagnostic above and the current release-manifest
generator contract. It is not generator or validation execution evidence.

Planning authorizes only `bubbles/release-manifest.json` as the additional
BUG-033 path. The correction is required solely because the authorized
framework-stats refresh changed the managed checksums of
`docs/generated/framework-stats.json`, `docs/generated/framework-stats.md`,
`docs/CHEATSHEET.md`, and `docs/its-not-rocket-appliances.html`.

`Release manifest freshness` is the validator's final registered check. The
generator source at `bubbles/scripts/generate-release-manifest.sh` is not
authorized. No unrelated source path or generated output is added.

The next owner is `bubbles.docs`. It must run the canonical generator and prove
that the resulting `bubbles/release-manifest.json` diff is bounded to the
required checksum reconciliation. This planning action did not run the
generator, edit the manifest, or change T23, status, certification, or human
acceptance.

`F-B033-DIAG-EMPTY-OUTPUT-CAPTURE` remains independent and routed to
`bubbles.bug`. Its implementation path,
`bubbles/scripts/evidence-capture.sh`, remains excluded from BUG-033.

### Original Failure-Label Uncertainty

> **Uncertainty Declaration**
> **What was attempted:** Row 187, the current receipt, the validator footer,
> the stats-refresh evidence, and the directly affected checks were inspected.
> **What was observed:** The same receipt tree reproduces release-manifest
> freshness failure. The stats and cheatsheet checks pass.
> **Why this is uncertain:** Tool-log row 187 stores only output hashes and byte
> counts. It does not preserve the original footer or complete failed-label set.
> **What would resolve this:** Nothing can reconstruct the original label set
> from the retained row. A new full run would create a new result, not recover
> the original output.

No full framework validation or release check ran during this diagnostic.
T23, scope status, bug status, certification, and human acceptance remain
unchanged.

### Diagnostic Artifact Integrity

**Claim Source:** executed

Tool-log row 201 exited `1` because it treated any dirty human-acceptance file
as a session edit. That clean-worktree proxy was invalid for this shared dirty
tree. It did not show that this invocation changed human acceptance.

Rows 189 and 202 ran the same unrelated-byte fingerprint. Both captured 64
paths, 67 output lines, and digest
`819a6ca273a21deaabec3a0abc6de38525a6497709492e77292cfee55083e089`.
The matching fingerprints include the pre-existing human-acceptance bytes.

Row 203 replaced the invalid proxy. It exited `0` and emitted these signals.

```text
CHECK name=execution-substate-guard exit=0
CHECK name=status-certification-routing exit=0
T23_STATE=unchecked
UNRELATED_BYTES_PRESERVED=yes
CHECK name=owned-diff-check exit=0
CORRECTED_DIAGNOSTIC_FAILURES=0
```

## Canonical Release-Manifest Reconciliation 2026-08-30

**Phase:** docs.

**Agent:** bubbles.docs.

**Claim Source:** executed.

This invocation handled only
`F-B033-T23-RELEASE-MANIFEST-FRESHNESS`. It did not run a workflow, the full
framework validator, or the release check. It did not change T23, status,
certification, scope state, or human acceptance.

### Drift Detected

| Artifact | Drift before repair | Generator contract | Action |
| --- | --- | --- | --- |
| `bubbles/release-manifest.json` | Four managed checksums differed from current files | The current generator records every managed file checksum | Reconciled only the four authorized checksum values |

No other current-tree checksum mismatch remained. API documentation checks do
not apply because this repair changes no endpoint or contract documentation.

### Pre-Write Identity And Relationship To HEAD

Tool-log row 213 captured the complete pre-write manifest diff. The bounded
capture digest is
`544ab8348703a3a04cb77ab6b3754c6b8d9d3b41f37a8380ca5d347ae0fde8e9`.

| Fact | Observed value |
| --- | --- |
| HEAD | `aafca4398e2b4a4490cdfffba35387c4fdb44d37` |
| HEAD manifest blob | `429bb7ab75c636ccd94923264f2b5daa84d2f081` |
| HEAD manifest bytes | `144109` |
| Pre-write worktree manifest blob | `ff1eedd7279523c8b91a199281172cdc9f26a95a` |
| Pre-write worktree manifest bytes | `144537` |
| Relationship to HEAD | Modified, with 43 added and 40 removed lines |

Tool-log row 214 captured the complete primary worktree inventory. Its digest
is `502ec739685f4d003a79318bec04e1672666fac5fc5280f65b7f24ccd518feab`.
The inventory confirmed substantial concurrent changes outside this repair.

### Complete Pre-Write Mismatch Set

Tool-log row 215 audited every checksum entry and all structural counts. The
capture digest is
`981574da2b7f24a8680d606fd180df7585e710b5ae71e04435c938e8b62844aa`.

```text
SECTION_STRUCTURE section=managed declared=930 actual=930 unique=yes duplicates=0 malformed=0
SECTION_STRUCTURE section=sourceOnly declared=111 actual=111 unique=yes duplicates=0 malformed=0
CROSS_SECTION_DUPLICATE_COUNT=0
TREE_MANIFEST_MISMATCH section=managed path=docs/CHEATSHEET.md classification=BUG033_AUTHORIZED_STATS_OUTPUT
TREE_MANIFEST_MISMATCH section=managed path=docs/generated/framework-stats.json classification=BUG033_AUTHORIZED_STATS_OUTPUT
TREE_MANIFEST_MISMATCH section=managed path=docs/generated/framework-stats.md classification=BUG033_AUTHORIZED_STATS_OUTPUT
TREE_MANIFEST_MISMATCH section=managed path=docs/its-not-rocket-appliances.html classification=BUG033_AUTHORIZED_STATS_OUTPUT
TREE_MANIFEST_MISMATCH_COUNT=4
TREE_MANIFEST_MISSING_COUNT=0
STRUCTURAL_FAILURE_COUNT=0
DOCS_DIGEST_MATCH=yes
VERSION_MATCH=yes
```

| Path | Manifest checksum before repair | Current file checksum | Classification |
| --- | --- | --- | --- |
| `docs/CHEATSHEET.md` | `6b09a61f09fc18411651e1ad266773cef42a80c63e8522905e9c48a9b67a1e07` | `f96c99fd394801d46918e01cdc486a961fc16f7af61ead676464b7319fed0544` | BUG-033 authorized stats output |
| `docs/generated/framework-stats.json` | `25d364e84cf3f4a76dba90551c4601b1c1881fec5671c3ed160ff8048d39c954` | `2d030123ae92a7331c0be3116863f6f9ee494bf8345dcc8ede06f7e8048db299` | BUG-033 authorized stats output |
| `docs/generated/framework-stats.md` | `8550617fa4a4219717c07a34b799ac8e022759fcf5fb79e23f13017e1b779b4a` | `1222393e2fc38b473cb3e656c000ca0a677b5e079be1bde89a98a34027bad261` | BUG-033 authorized stats output |
| `docs/its-not-rocket-appliances.html` | `98f8f437620f9ef778727b0a221d8522a8103474cf5940d01d0621601694c042` | `e9d1b5b9d44a0c56a687e26cdd87d55ab25611932378abf2e1eacc210bb18ca3` | BUG-033 authorized stats output |

The same audit found 39 manifest-entry differences from HEAD. Every recorded
checksum matched its current file before this repair. Their authorship is not
proved by worktree presence, so this invocation preserved all 39 entries as
pre-existing and unattributed.

**Claim Source:** interpreted.

**Interpretation:** The pre-write manifest was not a partial write. Its lists,
counts, metadata, and every checksum except the four listed values matched the
canonical candidate. This proves complete generator equivalence for that
earlier file snapshot. It does not prove who produced the pre-existing bytes.

### Isolated Candidate Construction

Tool-log row 216 created a diagnostic-only clone. It proved the candidate and
primary checkout shared HEAD `aafca4398e2b4a4490cdfffba35387c4fdb44d37`.
The initial clone was clean. Its capture digest is
`8345eac371694a33c4df22df79540ccc05d949ff36a4afbb6441e4f5a53f535e`.

The first mirror comparison in row 217 exited `1`. It found three primary-index
additions missing from the candidate index. Row 218 identified those paths and
their staged state. Row 219 also exited `1` because the first patch had already
created their candidate filesystem bytes. Neither failed attempt wrote the
primary checkout.

No staging operation followed. Row 220 compared all 1,348 primary-index paths
against candidate filesystem bytes. It used the primary index read-only for
path authority. Its capture digest is
`6394fd4c8a817f3eaaee07f3aa04997e83a04a336fbb8e07a9a8dd549b0d03cb`.

```text
TRACKED_TREE_COMPARISON_BEGIN
PRIMARY_HEAD=aafca4398e2b4a4490cdfffba35387c4fdb44d37
CANDIDATE_HEAD=aafca4398e2b4a4490cdfffba35387c4fdb44d37
CANDIDATE_INDEX_OMISSION_COUNT=3
CANDIDATE_INDEX_EXTRA_COUNT=0
PATH_AUTHORITY=primary-index-read-only
PRIMARY_TRACKED_PATH_COUNT=1348
CANDIDATE_TRACKED_PATH_COUNT=1345
PRIMARY_TRACKED_TREE_DIGEST=f6c876564efd027a41d3e6a38af2cebce16dc5005bf76bbbb768f1165230720e
CANDIDATE_TRACKED_TREE_DIGEST=f6c876564efd027a41d3e6a38af2cebce16dc5005bf76bbbb768f1165230720e
TRACKED_TREE_MISMATCH_COUNT=0
TRACKED_TREE_EXACT=yes
TRACKED_TREE_COMPARISON_END
```

The three candidate-index omissions were
`bubbles/scripts/bug-packet-resolve-selftest.sh`,
`bubbles/scripts/bug-packet-resolve.sh`, and
`bubbles/scripts/compact-obligation-basis-selftest.sh`. The generator used the
primary index with `GIT_OPTIONAL_LOCKS=0` and read candidate filesystem bytes.
This preserved the primary index and included all three paths.

### Canonical Candidate And Bounded Difference

Tool-log row 221 ran the canonical generator once in the exact isolated
candidate. It then ran the candidate freshness check. The capture digest is
`e5a7d3afe90f634908636f8f59dc2e0db6d01bd390e720fc52e163d0c5e6700f`.

```text
Updated release manifest: 7.28.0 (930 managed files)
CANONICAL_GENERATOR_EXIT=0
Release manifest is current: 7.28.0 (930 managed files)
EXACT_CANDIDATE_FRESHNESS_EXIT=0
CANDIDATE_ENTRY_DIFF section=managed kind=checksum_changed path=docs/CHEATSHEET.md classification=BUG033_AUTHORIZED_STATS_OUTPUT
CANDIDATE_ENTRY_DIFF section=managed kind=checksum_changed path=docs/generated/framework-stats.json classification=BUG033_AUTHORIZED_STATS_OUTPUT
CANDIDATE_ENTRY_DIFF section=managed kind=checksum_changed path=docs/generated/framework-stats.md classification=BUG033_AUTHORIZED_STATS_OUTPUT
CANDIDATE_ENTRY_DIFF section=managed kind=checksum_changed path=docs/its-not-rocket-appliances.html classification=BUG033_AUTHORIZED_STATS_OUTPUT
CANDIDATE_TOTAL_DIFF_COUNT=4
CANDIDATE_NON_AUTHORIZED_DIFF_COUNT=0
CANDIDATE_BOUNDED=yes
POST_GENERATION_NON_MANIFEST_PARITY_EXIT=0
```

The isolated output changed no scalar, inventory, count, path, or unrelated
checksum. The generated file remained 144,537 bytes. Its SHA-256 is
`f4dce3071ab6179940b97d7d1cf0d83a06a87c82dd774da9f57fb8ab75e4eac1`.

### Primary Reconciliation And Freshness Proof

The primary checkout did not run the generator in write mode. An IDE edit
replaced only the four checksums listed above. Tool-log row 222 then proved
byte equality with the isolated canonical output. The same command ran the
primary freshness check. Its capture digest is
`1886c7de9e95f6ed7e6b06541bd41088d7d01ecd7b401b20549936089c48829f`.

```text
PRIMARY_MANIFEST_POSTWRITE_BEGIN
PRIMARY_HEAD=aafca4398e2b4a4490cdfffba35387c4fdb44d37
PRIMARY_MANIFEST_SHA256=f4dce3071ab6179940b97d7d1cf0d83a06a87c82dd774da9f57fb8ab75e4eac1
CANDIDATE_MANIFEST_SHA256=f4dce3071ab6179940b97d7d1cf0d83a06a87c82dd774da9f57fb8ab75e4eac1
PRIMARY_MANIFEST_BYTES=144537
CANDIDATE_MANIFEST_BYTES=144537
PRIMARY_EQUALS_EXACT_CANDIDATE=yes
CANDIDATE_EQUALITY_EXIT=0
Release manifest is current: 7.28.0 (930 managed files)
PRIMARY_MANIFEST_FRESHNESS_EXIT=0
PRIMARY_MANIFEST_DIFF_CHECK_EXIT=0
PRIMARY_MANIFEST_POSTWRITE_END
```

Tool-log row 223 repeated the complete entry audit. It reported zero current
checksum mismatches, zero missing files, and zero structural failures. It
classified four of 43 manifest-entry differences from HEAD as this repair.
The other 39 entries remain pre-existing and unattributed.

Tool-log row 224 captured the complete final manifest diff. The final worktree
blob is `cd8e29bd57f5e3b301db028501156f9665eb2777`. The bounded capture digest is
`b3e394b1ec565819bafa9752d4f24219b801a378681be74f4b1fa52ffa135f91`.

### Command Accounting

| Tool-log row | Purpose | Exit | Disposition |
| --- | --- | --- | --- |
| 213 | Pre-write manifest identity and full diff | 0 | Evidence retained |
| 214 | Complete primary worktree inventory | 0 | Concurrent dirty work confirmed |
| 215 | Complete pre-write mismatch audit | 0 | Four authorized mismatches found |
| 216 | Isolated clone relationship proof | 0 | Same committed HEAD confirmed |
| 217 | First exact mirror comparison | 1 | Three staged additions were absent from the candidate index |
| 218 | Three-path mirror-gap diagnosis | 0 | Staged additions identified |
| 219 | Candidate staged-addition patch attempt | 1 | Existing candidate files prevented duplicate creation |
| 220 | Primary-index filesystem parity proof | 0 | All 1,348 primary-index paths matched |
| 221 | Isolated canonical generation and check | 0 | Four-change candidate proved |
| 222 | Primary equality and freshness check | 0 | Primary equals candidate and is current |
| 223 | Complete post-write mismatch audit | 0 | Zero current mismatches |
| 224 | Final manifest identity and full diff | 0 | Final diff retained |

### Finding Accounting And Routing

`F-B033-T23-RELEASE-MANIFEST-FRESHNESS` is addressed by the four-checksum
reconciliation and row 222 freshness result. T23 remains unchecked because no
full framework validation ran in this invocation. The next owner is
`bubbles.test` for T23 execution.

`F-B033-DIAG-EMPTY-OUTPUT-CAPTURE` remains independent and routed to
`bubbles.bug`. This invocation did not edit
`bubbles/scripts/evidence-capture.sh` or add it to BUG-033.

## Focused TEST-Phase Diagnostic Retry 2026-08-31

**Phase:** test

**Agent:** bubbles.test

**Claim Source:** interpreted

**Interpretation:** Both requested focused checks ran against the current
checkout. Their failures require repairs outside the BUG-033 boundary. This
run changed no repair candidate, T23 checkbox, certification field, terminal
status, scope planning, or user acceptance.

### Repository Binding

The supplied packet validated before any repository-local read. Validation
reported `REPOSITORY PACKET VALID` for decision
`rb:vscode-890b012efcd4029f1bbec9142330177b:10`, control revision `10`, and
control-path digest
`sha256:4352ca9a8ff6b9b3dd529f4d875dbe0344a77d2c366d080a75c86a99b399593f`.
No packet byte was normalized or replaced.

### Validation-Checks Generator Diagnostic

**Command:** `/opt/homebrew/bin/bash bubbles/scripts/generate-validation-checks.sh --check`

**Exit Code:** 1

**Claim Source:** executed

Tool-log row 243 recorded the bounded invocation. The command produced 1,099
lines. The full-output capture digest is
`38ac9d21b94e26a38a9e89d647cddb6633844437e47466e383c7364f1e2a337a`.
The bounded capture retained these exact opening lines.

```text
generate-validation-checks: DRIFT — bubbles/registry/validation-checks.yaml does not match the derivation.
generate-validation-checks: this file is GENERATED. A hand edit is refused; regenerate it instead:
generate-validation-checks:   bash bubbles/scripts/generate-validation-checks.sh
193a194
>     - bubbles/scripts/bug-packet-resolve.sh
194a196,197
>     - bubbles/scripts/micro-fix-admission.sh
>     - bubbles/scripts/micro-fix-outcome-log.sh
198a202,203
>     - bubbles/registry/bug-packet.yaml
>     - bubbles/registry/micro-fix-packet.yaml
294a300
>     - bubbles/scripts/bug-packet-resolve.sh
317a324
>     - bubbles/scripts/compact-obligation-basis-selftest.sh
```

The current generator source declares the registry generated and refuses hand
edits. Its check compares the current derivation with the registry while
excluding only `derivedAt`. Tool-log row 246 found zero registry references to
`bug-packet-resolve.sh` and `compact-obligation-basis-selftest.sh`. The current
validator schedules the compact-obligation selftest. The generator also
discovers otherwise unregistered selftests and traces their dependencies.

### Framework-Health Evidence Diagnostic

**Command:** `/opt/homebrew/bin/bash bubbles/scripts/framework-health-evidence-lint.sh --repo-root /Users/pkirsanov/Projects/bubbles`

**Exit Code:** 1

**Claim Source:** executed

Tool-log row 244 recorded three output lines. The full-output capture digest is
`0d76a0f1100890e9bd916c6a2371cab48414bf5f0ec3c62e4be9d345b30cc8bb`.

```text
FINDING: index-row-missing: improvements/IMP-054-hybrid-evidence-research-runtime.md has no row in improvements/INDEX.md
FINDING: index-row-missing: improvements/IMP-055-measured-budget-and-session-epoch-runtime.md has no row in improvements/INDEX.md
[framework-health-evidence-lint] FAIL — G125 findings: 2
```

The lint source derives each proposal ID from its filename. It reports
`index-row-missing` when the current index contains no matching ID. Tool-log row
246 found zero current and HEAD index references for both IDs. Both proposal
files are clean, declare `PROPOSED`, contain a Provenance heading, and name the
index publication obligation.

### Work Boundary And Ownership

**Claim Source:** executed

Tool-log row 245 recorded six strict boundary decisions. The registry, index,
and both proposal paths resolved `route-same-repo`. This report and
`state.json` resolved `in-boundary`. Tool-log row 247 separately classified
`bubbles/scripts/evidence-capture.sh` as `route-same-repo`.

The ownership registry permits `bubbles.test` to append report evidence and
write execution claims in `state.json`. It does not grant this phase ownership
of the three repair surfaces. The workflow registry assigns `implement` to
`bubbles.implement`, `test` to `bubbles.test`, `retro` to `bubbles.retro`, and
`bug-discovery` to `bubbles.bug`.

### Finding Accounting

| Finding | Goal impact | Repair candidate | Boundary | Owner | Disposition |
| --- | --- | --- | --- | --- | --- |
| `F-B033-DIAG-VALIDATION-CHECKS-DRIFT` | Blocking for this focused TEST pass | `bubbles/registry/validation-checks.yaml` | `route-same-repo` | `bubbles.implement` | Unresolved. Regenerate the derived registry only in its owning work packet after concurrent source changes stabilize. |
| `F-B033-DIAG-IMP054-INDEX-ROW-MISSING` | Blocks the source validator's live G125 check | `improvements/INDEX.md` and the clean IMP-054 proposal | `route-same-repo` | `bubbles.retro` | Unresolved. Publish the required index row without changing BUG-033. |
| `F-B033-DIAG-IMP055-INDEX-ROW-MISSING` | Blocks the source validator's live G125 check | `improvements/INDEX.md` and the clean IMP-055 proposal | `route-same-repo` | `bubbles.retro` | Unresolved. Publish the required index row without changing BUG-033. |
| `F-B033-DIAG-EMPTY-OUTPUT-CAPTURE` | Independent of both reproduced failures | `bubbles/scripts/evidence-capture.sh` | `route-same-repo` | `bubbles.bug` | Retained unresolved. The separately classified repair packet remains required. |

No finding disappeared. The next active repair owner is `bubbles.implement` for
the generated closure map. The two G125 index findings remain assigned to
`bubbles.retro`. After those repairs, `bubbles.test` must rerun only the two
focused commands before any broader TEST-phase decision.

No full `framework-validate` or `release-check` ran in this retry.
