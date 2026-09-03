# User Validation: BUG-042

Items are checked because they were verified by execution in this session.
Uncheck any item that does not reproduce for you. An unchecked item is a
reported regression. Unchecking is your only required act.

The Human Acceptance Record is OPTIONAL and is deliberately absent. This agent
does not record human acceptance on your behalf.

## Automation Readiness

- [x] The defect is reproducible on demand from the current tree.
- [x] The fix is present in the working tree and was verified by execution.
- [x] The completion basis is proven registry-derived, not hard-coded.
- [x] The basis fails closed rather than certifying a form that proves nothing.
- [x] The full packet form is unaffected.
- [x] A behavioural pin exists, executes green, and goes red under mutation.
- [ ] Full framework validation and release readiness pass. **NOT RUN** — the
      validation lock is held by another terminal and both commands are out of
      scope for this session.

Automation readiness does not grant human acceptance.

## Checklist

### [Bug] [BUG-042] The compact packet form has no completion basis

- [x] **What:** The compact form's obligations are now machine-readable.
  - **Steps:**
    1. `bash bubbles/scripts/bug-packet-resolve.sh`
  - **Expected:** exit 0, and eight `obligation=` lines — four for `compact`,
    four for `single-file`. The `compact|root-cause-stated` line names `bug.md`
    as its discharge site while the other three name `report.md`.
  - **Verify:** terminal output and exit code
  - **Evidence:** [report.md](report.md) E-2

- [x] **What:** A compact packet reaches a completion basis it can satisfy.
  - **Steps:**
    1. `bash bubbles/scripts/state-transition-guard.sh bugs/BUG-038-progress-timeout-bsd-wc-padding`
    2. Read the Check 4 block.
  - **Expected:** exit 1 with 20 failures and 3 warnings. Check 4 prints
    `Completion basis: REGISTRY-DECLARED OBLIGATIONS (bug-packet.yaml 'compact'
    form declares 4; the required set is not author-chosen)` followed by one
    BLOCK per unattested obligation, each naming its discharge site. The packet
    is still refused — but for a reason its author can act on, which is the
    whole point.
  - **Verify:** terminal output and exit code
  - **Evidence:** [report.md](report.md) E-4

- [x] **What:** Check 5 substitutes an assertion rather than waiving one.
  - **Steps:**
    1. In the same output, read the Check 5 block.
  - **Expected:** `NOT_APPLICABLE` for the all-done cross-reference, and in its
    place `✅ PASS: completedScopes is EMPTY`. The form is not simply skipped.
  - **Verify:** terminal output
  - **Evidence:** [report.md](report.md) E-4

- [x] **What:** The required obligation set is registry-derived, not hard-coded.
  - **Steps:**
    1. Remove one entry from `obligationsRetained:` in
       `bubbles/registry/bug-packet.yaml`.
    2. Rerun the guard on `bugs/BUG-038-progress-timeout-bsd-wc-padding`.
    3. Restore the entry.
  - **Expected:** the declared count drops from 4 to 3, the BLOCK count drops
    from 4 to 3, and the failure total drops from 20 to 19. A hard-coded set
    could not track the registry.
  - **Verify:** the two guard outputs side by side
  - **Evidence:** [report.md](report.md) E-6

- [x] **What:** The basis is load-bearing — severing it restores the original bug.
  - **Steps:**
    1. Rename the emission key at `bubbles/scripts/bug-packet-resolve.sh:295`
       from `obligation=` to anything else.
    2. Rerun the guard on the same packet.
    3. Restore the key.
  - **Expected:** the `Completion basis` line disappears and Check 4 returns to
    `🔴 BLOCK: Resolved scope artifacts have ZERO DoD checkbox items — cannot
    verify completion`, which is verbatim the pre-fix defect.
  - **Verify:** terminal output
  - **Evidence:** [report.md](report.md) E-7

- [x] **What:** A reduced form that declares zero obligations is refused.
  - **Steps:**
    1. Rename the compact form's `obligationsRetained:` key so the form declares
       none.
    2. `bash bubbles/scripts/bug-packet-resolve.sh`
    3. Restore the key.
  - **Expected:** exit 2, naming the form, its artifact count against the full
    default's 7, and `ZERO obligationsRetained`. Fewer artifacts, never fewer
    obligations.
  - **Verify:** terminal output and exit code
  - **Evidence:** [report.md](report.md) E-8

- [x] **What:** The full packet form is unchanged by this repair.
  - **Steps:**
    1. `bash bubbles/scripts/state-transition-guard.sh bugs/BUG-037-uservalidation-opt-out-acceptance`
  - **Expected:** exit 1 with 38 failures and 4 warnings, identical to the
    pre-change baseline.
  - **Verify:** terminal output and exit code
  - **Evidence:** [report.md](report.md) E-5

- [x] **What:** The behavioural pin runs, and is not vacuous.
  - **Steps:**
    1. `bash bubbles/scripts/compact-obligation-basis-selftest.sh`
    2. Apply the mutation from the fifth item above and rerun it.
    3. Revert and rerun.
  - **Expected:** exit 0 with 13 checks and 0 failures; then exit 1 under
    mutation; then exit 0 again.
  - **Verify:** three exit codes
  - **Evidence:** [report.md](report.md) E-9, E-10

- [x] **What:** No forbidden packet was modified.
  - **Steps:**
    1. `find bugs/BUG-038-progress-timeout-bsd-wc-padding -type f | sort | xargs shasum -a 256 | shasum -a 256`
  - **Expected:** `a59a48b53e98494519ab969f4d278cf96457ed190242d57e66d526a4b3f00dda`,
    matching the hash taken before any guard run.
  - **Verify:** the composite hash
  - **Evidence:** [report.md](report.md) E-11

## Pending — not claimed, not checkable here

These are listed deliberately and are absent from the checklist above.

- Full framework validation (`framework-validate`) — not run; lock held elsewhere.
- Release readiness (`release-check`) — not run; out of scope.
- Certification by `bubbles.validate` — not this agent's to perform.
- `state-transition-guard-selftest.sh` still carries zero references to the
  form-resolution path. The behavioural pin lives elsewhere and was executed;
  see [report.md](report.md) § Disposition of F-041-04.
