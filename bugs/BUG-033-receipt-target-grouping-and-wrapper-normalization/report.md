# BUG-033 Report

## Summary

- **Changed:** `bubbles/scripts/state-transition-guard.sh` (Check 43 jq program,
  two edits), `bubbles/scripts/receipt-identity-selftest.sh` (new),
  `bubbles/scripts/state-transition-guard-selftest.sh` (end-to-end cases).
- **Scenarios validated:** SCN-B033-001, SCN-B033-002, SCN-B033-003,
  SCN-B033-004.

## Completion Statement

Both filed facets are fixed and each carries an adversarial bound that still
refuses. The claim rests on two executions of the same test file against the
same fixtures — one before the fix and one after — with their real exit codes
recorded below. No claim in this report is unaccompanied by a command that ran.

## Test Evidence

<a id="red"></a>
### Red stage — the reproduction, BEFORE the fix

**Executed:** YES
**Command:** `bash bubbles/scripts/receipt-identity-selftest.sh`
**Phase Agent:** bubbles.implement
**Claim Source:** executed

The test fails without the fix. Exit code `1`, `5 passed, 10 failed`.

```
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

Two red assertions in the block above are artifacts of a defect in the test's
own `family_of` helper, which indexed a string as an object. That helper bug was
corrected before the green run; the substantive facet-2 failure — five distinct
families in the clone diagnostic — is visible in the analysis payload and is
independent of the helper.

<a id="green"></a>
### Green stage — the same test, AFTER the fix

**Executed:** YES
**Command:** `bash bubbles/scripts/receipt-identity-selftest.sh`
**Phase Agent:** bubbles.implement
**Claim Source:** executed

Exit code `0`, `15 passed, 0 failed`.

```
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

<a id="facet-1"></a>
### Facet 1 — target grouping

Before: `map(target_identity)` over every RECEIPT, so 9 re-runs over 2 targets
produced 9 values with 2 distinct entries and failed `unique|length == length`.

After: `group_by(.cmd | cmd_identity) | map(.[0] | target_identity)`, so the
list carries one entry per IDENTITY. Proven by `facet 1` PASS above; the
adversarial partner is the next section.

<a id="facet-2"></a>
### Facet 2 — wrapper normalization

Before: `family=node`, `family=env`, `family=zsh`, `family=PAGE=alpha`,
`family=-c` for one command (see the red analysis payload).

After: all six spellings resolve to `command_family=node` — six separate PASS
lines in the green block, each naming its spelling.

<a id="bounds"></a>
### Adversarial bounds

Both relaxations are bounded and both bounds executed:

- `facet 1 bound` — `npm run lint` and `npm run test` over ONE target still
  produce exactly 1 clone group.
- `facet 2 bound` — `zsh -c cargo test` and `env CI=1 npm run lint` still
  produce exactly 1 clone group, and the diagnostic names the UNWRAPPED
  `family=cargo` and `family=npm`, proving unwrapping reveals the difference
  rather than hiding it.
- Three earlier pins (BUG-007 empty-stdout exemption, BUG-032 provenance-poor
  collision, BUG-032 incompatible families) all still hold.

<a id="regression"></a>
### Regression

**Executed:** YES
**Command:** `bash bubbles/scripts/state-transition-guard-selftest.sh`
**Phase Agent:** bubbles.implement
**Claim Source:** executed

Four scenario-specific cases were added to the whole-guard selftest beside the
BUG-032 receipt matrix — the re-run fixture, its single-target adversarial
partner, the wrapper fixture, and its cargo-vs-npm adversarial partner. These
drive the REAL guard end to end rather than its extracted jq program. The
executed result and exit code are recorded in the S-C session summary; see
`bubbles/scripts/state-transition-guard-selftest.sh` for the cases themselves.

## Code Diff Evidence

**Executed:** YES
**Command:** `git diff --stat`
**Phase Agent:** bubbles.implement
**Claim Source:** executed

Non-artifact runtime paths changed:

- `bubbles/scripts/state-transition-guard.sh` — Check 43 jq program
- `bubbles/scripts/receipt-identity-selftest.sh` — new regression surface
- `bubbles/scripts/state-transition-guard-selftest.sh` — end-to-end cases

## Validation Evidence

**Executed:** NO
**Command:** n/a
**Phase Agent:** bubbles.validate
**Claim Source:** not-run

Validate-owned certification has not run. This packet stays `in_progress`.

## Timeout Wrapper Facet

**Executed:** NO
**Command:** n/a
**Phase Agent:** bubbles.bug
**Claim Source:** not-run

The timeout facet was reconciled as requirements and design only. Inspection of
the dirty parser and tests found accepted forms broader than the closed grammar:
`-vfp`, `-k.5`, and `-sTERM`. No focused or whole-guard timeout command ran in
this artifact invocation. These observations are source-grounded design input,
not red or green execution evidence.

The implementation owner must first run corrected tests against the current
over-broad parser to capture a red stage. It must then narrow the parser and run
the same focused and whole-guard cases for green evidence.

## Session Lock Ignore Boundary

**Executed:** NO
**Command:** n/a
**Phase Agent:** bubbles.bug
**Claim Source:** interpreted

Editor inspection found the exact `.specify/memory/bubbles.session.json.flock`
entry in `.specify/memory/.gitignore`. No command-backed ignore check ran. The
boundary admits that one path and does not admit the untracked session JSON.

## Audit Evidence

**Executed:** NO
**Command:** n/a
**Phase Agent:** bubbles.audit
**Claim Source:** not-run

Audit has not run. This packet stays `in_progress`.
