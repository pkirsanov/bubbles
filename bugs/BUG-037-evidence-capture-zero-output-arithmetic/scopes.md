# BUG-037 Scopes

## Execution Outline

### Phase Order

1. **Scope 1 — Canonical zero-output metadata:** make silent child commands produce deterministic metadata without changing existing non-empty behavior.

### New Types And Signatures

- No public API, schema, or persisted-data change.
- `evidence-capture.sh` retains its command-line and exit-status contract.
- Zero-output capture uses one canonical line-count producer and the standard empty-stream SHA-256.

### Validation Checkpoints

- Focused helper regressions verify all four scenarios before aggregate framework validation.
- Independent `bubbles.test` must re-verify the final planning metadata before release readiness or validate-owned certification.

## Scope 1 — Canonical Zero-Output Metadata

**Status:** In Progress

### Gherkin Scenarios

#### SCN-B037-001 — Successful zero-output child

```gherkin
Scenario: Successful zero-output child
Given a child command exits zero and writes no stdout or stderr
When evidence capture formats the result
Then it reports zero lines and the empty-stream hash
And it emits no arithmetic diagnostic
And the helper exits zero
```

#### SCN-B037-002 — Failing zero-output child

```gherkin
Scenario: Failing zero-output child
Given a child command exits nonzero and writes no stdout or stderr
When evidence capture formats the result
Then it reports zero lines and the empty-stream hash
And it emits no arithmetic diagnostic
And the helper exits with the child status
```

#### SCN-B037-003 — Empty-output verification

```gherkin
Scenario: Empty-output verification
Given the recorded digest is the empty-stream hash
When verify mode reruns a zero-output command
Then a matching run exits zero
And a changed-output run exits three
```

#### SCN-B037-004 — Non-empty behavior is unchanged

```gherkin
Scenario: Non-empty behavior is unchanged
Given existing non-empty capture fixtures
When the focused selftest runs after the fix
Then short and bounded output formatting remains unchanged
And child, signal, and verify exit contracts remain unchanged
```

### Implementation Files

- `bubbles/scripts/evidence-capture.sh`
- `bubbles/scripts/evidence-capture-selftest.sh`

### Implementation Plan

1. Add focused zero-output tests before changing the helper.
2. Capture the exact arithmetic diagnostic and failing assertions.
3. Replace the two-producer line-count expression with one canonical counter.
4. Re-run the same zero-output fixtures.
5. Run the existing non-empty helper selftest as an adversarial control.
6. Run aggregate framework and release validation.
7. Regenerate the release manifest from validated bytes.

### Change Boundary

- **Allowed implementation surfaces:** `bubbles/scripts/evidence-capture.sh` and `bubbles/scripts/evidence-capture-selftest.sh`.
- **Allowed planning surfaces:** this bug packet's `scopes.md`, `scenario-manifest.json`, `report.md`, and `state.json`.
- **Validate/release-owned surface:** `bubbles/release-manifest.json`, only after authorized aggregate validation.
- **Excluded surfaces:** unrelated helpers, product/runtime code, generated registries, session state, and other bug packets.
- Collateral cleanup outside this boundary requires a separately authorized packet.

## Test Plan

| ID | Scenario | Description | Type | File/Location |
| --- | --- | --- | --- | --- |
| TP-B037-001 | SCN-B037-001 | Successful zero-output child reports canonical metadata | unit | `bubbles/scripts/evidence-capture-selftest.sh` |
| TP-B037-002 | SCN-B037-002 | Failing zero-output child reports canonical metadata and propagates status | unit | `bubbles/scripts/evidence-capture-selftest.sh` |
| TP-B037-003 | SCN-B037-003 | Empty-output verify match and mismatch preserve exit contracts | unit | `bubbles/scripts/evidence-capture-selftest.sh` |
| TP-B037-004 | SCN-B037-004 | Focused helper regression preserves non-empty, bounded, signal, and cleanup behavior | unit | `bubbles/scripts/evidence-capture-selftest.sh` |
| TP-B037-005 | Aggregate validation | Framework aggregate validation preserves evidence-helper behavior across framework consumers | framework | `bubbles/scripts/cli.sh framework-validate` |
| TP-B037-006 | Aggregate validation | Release readiness validates generated manifest consistency | release | `bubbles/scripts/cli.sh release-check` |

### Definition of Done

- [x] Exact zero-output arithmetic diagnostic is captured before the fix.
  > **Phase:** implement
  > **Claim Source:** executed
  > **Evidence:** `report.md#red-stage` records both successful and failing silent children emitting `arithmetic syntax error in expression` before the production edit.
- [x] **TP-B037-001 / SCN-B037-001:** Successful zero-output capture reports zero lines, the empty hash, and exit zero without diagnostics.
  > **Phase:** implement
  > **Claim Source:** executed
  > **Evidence:** `report.md#green-stage` and `report.md#exact-post-fix-zero-output-metadata` record the exact metadata and focused assertion result.
- [x] **TP-B037-002 / SCN-B037-002:** Failing zero-output capture reports zero lines, the empty hash, and the child status without diagnostics.
  > **Phase:** implement
  > **Claim Source:** executed
  > **Evidence:** `report.md#green-stage` and `report.md#exact-post-fix-zero-output-metadata` record exit 7, exact metadata, and diagnostic absence.
- [x] **TP-B037-003 / SCN-B037-003:** Empty-output verify match and mismatch retain the existing exit contract.
  > **Phase:** implement
  > **Claim Source:** executed
  > **Evidence:** `report.md#green-stage` records the adversarial match and mismatch assertion with exits 0 and 3.
- [x] **TP-B037-004 / SCN-B037-004:** Non-empty capture behavior remains unchanged.
  > **Phase:** implement
  > **Claim Source:** executed
  > **Evidence:** `report.md#green-stage` records all existing short, bounded, failure-shaped, diagnostic, signal, cleanup, and capture-loss controls passing.
- [x] Persistent scenario-specific regression linkage covers every changed behavior.
  > **Phase:** implement
  > **Claim Source:** executed
  > **Evidence:** `report.md#green-stage` records the production-CLI selftest exercising SCN-B037-001 through SCN-B037-004; each scenario is linked to this persistent test by `scenario-manifest.json`.
- [ ] **TP-B037-005:** Framework aggregate validation passes.
  > **Uncertainty Declaration**
  > **What was attempted:** The test phase independently ran the complete focused selftest, both regression-quality guard modes, and explicit static scans.
  > **What was observed:** All 20 focused checks and all 11 explicit probes passed. Both guard modes reported zero violations and zero warnings.
  > **Why this is uncertain:** The exact operator packet prohibited full `framework-validate`, so no framework aggregate result exists for this test epoch.
  > **What would resolve this:** The validation owner must run only the aggregate command authorized by its packet before certification.
- [ ] **TP-B037-006:** Release manifest is regenerated from the validated source tree and release readiness passes.
  > **Uncertainty Declaration**
  > **What was attempted:** No generator or manifest command ran in the test phase.
  > **What was observed:** The test packet independently validated the helper and focused selftest without modifying release artifacts.
  > **Why this is uncertain:** The exact operator packet prohibited generators and manifests.
  > **What would resolve this:** The owning release or validation phase must regenerate only after its required checks establish validated bytes and permit manifest work.
- [ ] Code Diff Evidence records the reviewed implementation and focused-test changes without substituting for execution evidence.
  > **Phase:** validate
  > **Claim Source:** planned
  > **Evidence required:** `report.md#code-diff-evidence` must identify the reviewed diff command, its real exit status, and the implementation and focused-test paths covered. This item remains unchecked until that evidence exists.
- [ ] `bubbles.validate` certifies the packet transition.
  > **Uncertainty Declaration**
  > **What was attempted:** The test phase independently validated all focused scenarios and prepared the packet for validation routing.
  > **What was observed:** Focused behavior is clean while certification remains `in_progress`.
  > **Why this is uncertain:** This agent does not own certification.
  > **What would resolve this:** `bubbles.validate` must independently replay the required checks and own any certification transition.
