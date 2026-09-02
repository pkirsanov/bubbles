# User Validation: BUG-041

Items are checked because they were verified by execution in this session.
Uncheck any item that does not reproduce for you. An unchecked item is a
reported regression.

Every item below validates the DEFECT INVESTIGATION. None of them claims the fix
is delivered, because it is not. Fix-verification items are listed separately
under Pending Implementation and are deliberately absent from the checklist.

## Automation Readiness

- [x] The defect reproduces on a real, admitted packet with a real exit code.
- [x] The root cause is located at a named file and line.
- [x] The second affected enforcement surface is identified.
- [ ] The fix is implemented.
- [ ] Mutations M1 through M6 pass.
- [ ] Full framework validation and release readiness pass.

Automation readiness does not grant human acceptance.

## Checklist

### [Bug] [BUG-041] The declared default packet route cannot pass artifact lint

- [x] **What:** A legitimately admitted compact packet is rejected by `artifact-lint.sh`.
  - **Steps:**
    1. `bash bubbles/scripts/micro-fix-admission.sh bugs/BUG-038-progress-timeout-bsd-wc-padding`
    2. `bash bubbles/scripts/artifact-lint.sh bugs/BUG-038-progress-timeout-bsd-wc-padding`
  - **Expected:** step 1 prints `admitted` at exit 0. Step 2 exits 1 with 6 issues.
  - **Verify:** terminal exit codes and output
  - **Evidence:** [report.md](report.md) E-3, E-4

- [x] **What:** The rejected packet carries exactly the artifacts its contract requires.
  - **Steps:**
    1. `ls bugs/BUG-038-progress-timeout-bsd-wc-padding/`
    2. Compare against `form: compact` in `bubbles/registry/bug-packet.yaml`.
  - **Expected:** `bug.md`, `report.md`, `state.json`, matching the contract with nothing extra.
  - **Verify:** directory listing against the registry
  - **Evidence:** [report.md](report.md) E-5

- [x] **What:** The registry that owns the answer has no production reader.
  - **Steps:**
    1. `grep -rn "bug-packet.yaml" --include="*.sh" bubbles/scripts/`
  - **Expected:** every hit is a selftest. No enforcement surface consumes it.
  - **Verify:** inspect each hit
  - **Evidence:** [report.md](report.md) E-6

- [x] **What:** A second enforcement surface carries the same hard-coded list.
  - **Steps:**
    1. `sed -n '759p;799p;805p' bubbles/scripts/state-transition-guard.sh`
    2. Compare against `artifact-lint.sh` lines 401-406, 447, 453.
  - **Expected:** the two lists are byte-identical.
  - **Verify:** source comparison
  - **Evidence:** [report.md](report.md) E-7

- [x] **What:** A machine-readable declaration already exists and is undeclared by any registry.
  - **Steps:**
    1. `jq ".packet" bugs/BUG-038-progress-timeout-bsd-wc-padding/state.json`
    2. `grep -n '"packet"' bubbles/scripts/micro-fix-admission.sh`
    3. `grep -rn "^packet:" bubbles/registry/*.yaml`
  - **Expected:** step 1 prints `"micro"`. Step 2 shows it consumed at line 144. Step 3 prints nothing.
  - **Verify:** terminal output and exit codes
  - **Evidence:** [report.md](report.md) E-8
  - **Notes:** This corrects the dispatching brief, which reported no declaration.

- [x] **What:** Six of the seven bug packets carry no declaration, so a fail-closed fix cannot change their verdict.
  - **Steps:**
    1. `for f in bugs/*/state.json; do jq -r ".packet // \"<absent>\"" $f; done`
  - **Expected:** six `<absent>` and one `micro`.
  - **Verify:** terminal output
  - **Evidence:** [report.md](report.md) E-9

- [x] **What:** Two of the six lint failures are an authoring gap, not the linter defect.
  - **Steps:**
    1. `bash bubbles/scripts/report-sections-resolve.sh | grep "^always="`
    2. `grep -nE "^#{1,4} " bugs/BUG-038-progress-timeout-bsd-wc-padding/report.md`
  - **Expected:** the required sections carry no form dimension, and BUG-038's evidence sits under different headings.
  - **Verify:** compare the two outputs
  - **Evidence:** [report.md](report.md) E-10
  - **Notes:** This corrects the dispatching brief, which framed all six as one defect.

- [x] **What:** This packet took the full route because admission escalated mechanically.
  - **Steps:**
    1. `bash bubbles/scripts/micro-fix-admission.sh bugs/BUG-041-artifact-lint-ignores-compact-packet-form`
  - **Expected:** escalation on `no-new-behavior`, `no-schema-change`, `no-cross-product-effect`.
  - **Verify:** terminal output
  - **Evidence:** [report.md](report.md) E-11

## Pending Implementation

These items are NOT checked and MUST NOT be checked until the fix lands with its
own execution evidence.

- [ ] An admitted compact packet produces zero missing-artifact failures.
- [ ] A packet with no declaration produces a byte-identical verdict to today.
- [ ] A forged compact declaration that fails admission is linted as full.
- [ ] An absent registry exits non-zero rather than passing.
- [ ] BUG-038 fails with exactly two report-section issues, not zero.

## Human Acceptance Record

Not recorded. A human must complete the checklist and add the required record
before a terminal transition. No terminal transition is requested by this
packet.
