# BUG-050 Scopes

Links: [spec.md](spec.md) | [design.md](design.md) | [report.md](report.md) | [uservalidation.md](uservalidation.md)

## Scope 1 - Transition-Local Receipt Admission

**Status:** Not Started
**Priority:** P1
**Depends On:** None
**Consumer Surface:** Transition guard CLI command `bash bubbles/scripts/state-transition-guard.sh <feature-dir>`

### Gherkin Scenarios

```gherkin
Scenario: SCN-B050-001 Unrelated stale history is inert
  Given the active transition admits only fresh receipts
    And unrelated stale rows remain in the append-only tool log
  When Check 43 evaluates staleness
  Then the transition is not blocked by unrelated history

Scenario: SCN-B050-002 Admitted stale receipt blocks
  Given an admitted receipt has a changed input closure
  When Check 43 evaluates staleness
  Then the transition is blocked and the receipt is named

Scenario: SCN-B050-003 Unrelated clone groups are inert
  Given the active transition admits no incompatible clone group
    And unrelated history contains one
  When Check 43 evaluates clone reuse
  Then the unrelated group does not block

Scenario: SCN-B050-004 Admitted incompatible clone blocks
  Given active evidence reuses substantive stdout across incompatible identities
  When Check 43 evaluates clone reuse
  Then the transition is blocked with identity detail

Scenario: SCN-B050-005 Historical RED remains ordered proof
  Given RED failed on the planned discriminator before implementation
    And GREEN passes on the current candidate with the same discriminator
  When scenario states are derived
  Then RED_VERIFIED and GREEN_TARGETED are both derived in order
    And stale post-fix proof remains inadmissible

Scenario: SCN-B050-006 Historical mutation proof remains earned
  Given a killed mutant receipt restored its captured source bytes
    And production source later changes
  When mutation proof is checked
  Then the earned kill remains valid
    And a non-restored mutant remains refused
```

### Implementation Plan

1. Add all four transition-admission RED fixtures before production changes.
2. Capture unrelated-history false blocks and active-evidence controls.
3. Define one explicit admitted-evidence projection.
4. Feed that projection to freshness and clone consumers.
5. Add phase-aware RED and post-fix revision rules.
6. Preserve historical mutation proof and restoration integrity.
7. Re-run BUG-033 identity regressions without weakening them.
8. Run full canonical framework validation and release readiness.
9. Regenerate the release manifest after validated source changes.

### Implementation Files

- `bubbles/scripts/evidence-receipt-check.sh`
- `bubbles/scripts/evidence-receipt-check-selftest.sh`
- `bubbles/scripts/evidence-tool-log-bridge.sh`
- `bubbles/scripts/evidence-tool-log-bridge-selftest.sh`
- `bubbles/scripts/scenario-state-resolve.sh`
- `bubbles/scripts/scenario-state-resolve-selftest.sh`
- `bubbles/scripts/mutation-receipt.sh`
- `bubbles/scripts/mutation-receipt-selftest.sh`
- `bubbles/scripts/state-transition-guard.sh`
- `bubbles/scripts/state-transition-guard-selftest.sh`
- `bubbles/scripts/receipt-identity-selftest.sh`

### Shared Infrastructure Impact Sweep

The tool log and transition guard are shared evidence infrastructure. Inspect
every consumer below.

- Inspect Check 9 semantic DoD admission.
- Inspect scenario state derivation.
- Inspect receipt freshness diagnostics.
- Inspect Check 43 clone identity.
- Inspect mutation receipt checks.
- Inspect installed downstream transition behavior.

Run focused canaries before the broad suite. Preserve a rollback path by keeping
the projection additive until every consumer uses the same admitted set.

### Change Boundary

**Allowed file families:**

- `bubbles/scripts/evidence-receipt-check.sh`
- `bubbles/scripts/evidence-receipt-check-selftest.sh`
- `bubbles/scripts/evidence-tool-log-bridge.sh`
- `bubbles/scripts/evidence-tool-log-bridge-selftest.sh`
- `bubbles/scripts/scenario-state-resolve.sh`
- `bubbles/scripts/scenario-state-resolve-selftest.sh`
- `bubbles/scripts/mutation-receipt.sh`
- `bubbles/scripts/mutation-receipt-selftest.sh`
- `bubbles/scripts/state-transition-guard.sh`
- `bubbles/scripts/state-transition-guard-selftest.sh`
- `bubbles/scripts/receipt-identity-selftest.sh`
- `bubbles/schemas/tool-call.schema.json` only if projection provenance needs a schema field
- `bubbles/registry/scenario-states.yaml` only if phase revision semantics need registry expression
- `bubbles/release-manifest.json`
- this bug packet and `BUGS.md`

**Excluded surfaces:** raw tool logs, downstream repositories, unrelated evidence stores, and other bug packets.

### Test Plan

| ID | Scenario | Test | Type | File/Location | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- |
| T1 | SCN-B050-001 | Regression E2E: unrelated stale receipts remain present but inert | functional | `bubbles/scripts/state-transition-guard-selftest.sh` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | No |
| T2 | SCN-B050-002 | Adversarial actively admitted stale receipt still blocks | functional | `bubbles/scripts/evidence-receipt-check-selftest.sh` | `bash bubbles/scripts/evidence-receipt-check-selftest.sh` | No |
| T3 | SCN-B050-003 | Unrelated incompatible clone group remains inert | functional | `bubbles/scripts/receipt-identity-selftest.sh` | `bash bubbles/scripts/receipt-identity-selftest.sh` | No |
| T4 | SCN-B050-004 | Adversarial admitted incompatible clone preserves BUG-033 refusal | functional | `bubbles/scripts/receipt-identity-selftest.sh` | `bash bubbles/scripts/receipt-identity-selftest.sh` | No |
| T5 | SCN-B050-005 | Historical RED plus current GREEN derive the ordered scenario states | functional | `bubbles/scripts/scenario-state-resolve-selftest.sh` | `bash bubbles/scripts/scenario-state-resolve-selftest.sh` | No |
| T6 | SCN-B050-006 | Historical killed mutant remains valid while failed restoration blocks | functional | `bubbles/scripts/mutation-receipt-selftest.sh` | `bash bubbles/scripts/mutation-receipt-selftest.sh` | No |
| T7 | Aggregate | Canary: semantic DoD admission selects the same active receipts | functional | `bubbles/scripts/evidence-tool-log-bridge-selftest.sh` | `bash bubbles/scripts/evidence-tool-log-bridge-selftest.sh` | No |
| T8 | Aggregate | BUG-007, BUG-028, BUG-032, and BUG-033 receipt identity protections remain green | regression | `bubbles/scripts/receipt-identity-selftest.sh` | `bash bubbles/scripts/receipt-identity-selftest.sh` | No |
| T9 | Aggregate | Full source framework regression | Regression E2E | `bubbles/scripts/cli.sh` | `bash bubbles/scripts/cli.sh framework-validate` | No |

### Definition of Done

- [ ] SCN-B050-001 and SCN-B050-003 pre-fix regressions reproduce unrelated-history blocking.
- [ ] SCN-B050-001 one transition-local admitted evidence projection feeds Check 43.
- [ ] SCN-B050-001 and SCN-B050-003 immutable unrelated history remains present and non-blocking.
- [ ] SCN-B050-002 actively admitted stale receipts still block with exact detail.
- [ ] SCN-B050-004 admitted incompatible clones still block with BUG-033 identity detail.
- [ ] SCN-B050-005 historical RED remains valid without satisfying current GREEN proof.
- [ ] SCN-B050-006 historical killed-mutant proof remains valid and restoration stays strict.
- [ ] Independent canary suite for shared fixture/bootstrap contracts passes before broad suite reruns
- [ ] Rollback or restore path for shared infrastructure changes is documented and verified
- [ ] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior
- [ ] Broader E2E regression suite passes
- [ ] Change Boundary is respected and zero excluded file families were changed
- [ ] No tool-log row was deleted, rewritten, or bypassed.
- [ ] Release manifest is regenerated from the validated source tree.
- [ ] `bubbles.validate` certifies the packet transition.
