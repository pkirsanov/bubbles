# User Validation: BUG-042 Same-Revision Receipt Supersession

## Automation Readiness

- [ ] The smallest hermetic counterexample reproduces the current defect.
- [ ] The persistent substituted-test replacement scenario fails before the fix.
- [ ] The persistent substituted-control replacement scenario fails before the fix.
- [ ] The persistent exit-zero RED replacement scenario fails before the fix.
- [ ] The ordering and later-conflict adversarial scenarios exist.
- [ ] The focused and broader suites pass after implementation.

Automation readiness does not grant human acceptance.

## Checklist

### [Bug] [BUG-042] Historical receipts do not block a later coherent chain

- [ ] **What:** A later matching GREEN supersedes an older substituted-test GREEN.
  - **Steps:** Run the persistent `SCN-B042-001` fixture.
  - **Expected:** `GREEN_TARGETED` derives without a blocking historical substitution.
  - **Verify:** resolver output and exit code
  - **Evidence:** not recorded

- [ ] **What:** A later matching GREEN supersedes an older substituted-control GREEN.
  - **Steps:** Run the persistent `SCN-B042-002` fixture.
  - **Expected:** `GREEN_TARGETED` derives without a blocking historical substitution.
  - **Verify:** resolver output and exit code
  - **Evidence:** not recorded

- [ ] **What:** A later failing RED supersedes an older exit-zero RED.
  - **Steps:** Run the persistent `SCN-B042-003` fixture.
  - **Expected:** the failing RED anchors the selected coherent chain.
  - **Verify:** resolver output and exit code
  - **Evidence:** not recorded

- [ ] **What:** Equal timestamps use append order.
  - **Steps:** Run `SCN-B042-004` twice with fixed fixture bytes.
  - **Expected:** both runs select the same latest coherent chain.
  - **Verify:** byte comparison of resolver JSON
  - **Evidence:** not recorded

- [ ] **What:** A later unresolved invalid receipt cannot erase a prior valid chain silently.
  - **Steps:** Run the persistent `SCN-B042-005` fixture.
  - **Expected:** the valid chain remains visible and the later conflict blocks explicitly.
  - **Verify:** resolver output and exit code
  - **Evidence:** not recorded

## Human Acceptance Record

Not recorded. A human must execute and check the applicable items before any
terminal transition.