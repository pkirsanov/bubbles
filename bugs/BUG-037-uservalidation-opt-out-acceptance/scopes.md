# BUG-037 Scopes

Four sequential scopes. Scope 1 changes the single authority every later scope
reads, so it lands first. Each scope is independently testable and carries its
own adversarial bound.

Every DoD item ships **unchecked**. An item is checked only when the executed
evidence backing it exists in [report.md](report.md).

The four scope statuses and checked DoD items record execution against the
pre-remediation contract. They remain historical execution receipts. They do
not certify the amended requirements below. The packet stays `in_progress`.
Every scope stays uncertified. Capture focused and broad evidence again after
the planned source, registry, test, changelog, and generated changes.

## Execution Outline

### Phase Order

1. **Scope 1 — authority and reader contract.** Declare the three failure-code
      lifecycles. Fail closed when the authority cannot resolve. Validate every
      authored-record field.
2. **Scope 2 — template and migration contract.** Keep lint shape-only. Retain
      the checked current template. Classify all four provenance classes without
      bulk mutation.
3. **Scope 3 — terminal guard and persistent regressions.** Exercise the shared
      reader through Check 43. Preserve every named BUG-029 rejection. Prove that
      the guard cannot alter the acceptance artifact.
4. **Scope 4 — registry, release notes, and generated projections.** Publish
      the four-class migration contract. Align gate descriptions. Regenerate each
      derived artifact through its owning generator.

### New Types and Signatures

- `failureCodes`: closed registry set containing default-active codes,
      conditional-active `PD12-NO-RECORD`, and bootstrap-active
      `PD12-AUTHORITY-UNAVAILABLE`.
- `acceptance-record.requiredAtTerminal: true | false`: exact boolean contract.
      Absence, malformed input, and any other value are authority failures.
- Authored-record predicate: a record is present when any canonical field or
      method-conditional field contains non-default input. A present record must
      satisfy the complete base and method-specific schema.
- Migration classification: `current-opt-out`, `legacy-pre-pd12-checked`,
      `legacy-pd12-unchecked`, or `legacy-provenance-unknown`.

### Validation Checkpoints

- Scope 1 stops before Scope 2 unless default, conditional, bootstrap, and
      authored-record adversarial fixtures all have exact planned test identities.
- Scope 2 stops before Scope 3 unless all four migration classes are covered
      and a changed-path assertion proves that no foreign acceptance artifact was
      mutated.
- Scope 3 stops before Scope 4 unless the real Check 43 path names all five
      BUG-029 unchecked items and the before/after digest remains equal.
- Scope 4 closes execution only after all focused checks run against one
      contract revision. These checks cover generators, scenario links, references,
      and the permitted broad validation.

### Change Boundary

- **Allowed implementation families:** acceptance authority registry and shared
      reader, plus their focused selftests.
- **Allowed guard families:** Check 43 and its focused regression tests.
- **Allowed contract families:** packet-named templates, gate descriptions,
      `CHANGELOG.md`, and Scope 4 generated projections.
- **Allowed planning families in this remediation:** `spec.md`, `scopes.md`,
      `test-plan.json`, `scenario-manifest.json`, append-only `report.md`, and
      execution routing or finding ownership in `state.json`.
- **Excluded from this remediation:** `design.md`, `uservalidation.md`, every
      BUG-029 or BUG-032 packet, downstream repositories, product source, staging,
      commits, pushes, and broad framework validation.
- Collateral cleanup is prohibited. A discovered obligation remains in the
      finding chain with a named owner instead of being changed outside this
      boundary.

### Scenario Obligation Matrix

| Scenario | Behavior traits | Derived proof obligations | Implementation refs |
| --- | --- | --- | --- |
| SCN-B037-001 | pure calculation, runtime config | transformed verdict, shipped `false` registry path, persistent regression | `acceptance-authority-lib.sh`, `acceptance-authority.yaml` |
| SCN-B037-002 | pure calculation, degraded state | named negative result, exact one-item cardinality, persistent regression | `acceptance-authority-lib.sh` |
| SCN-B037-003 | pure calculation, degraded state, shared consumer | exact five-item library proof, exact five-item Check 43 proof, persistent regression | shared reader, Check 43 |
| SCN-B037-004 | pure calculation, degraded state | present-record validation and automation-acceptor refusal | shared reader, authority registry |
| SCN-B037-005 | pure calculation, degraded state | readiness cannot discharge checklist rejection | shared reader |
| SCN-B037-006 | shared consumer, runtime config | template-to-registry parity and terminal consumer result | feature template, authority registry, shared reader |
| SCN-B037-007 | pure calculation | shape-only lint accepts a valid all-unchecked checklist | `artifact-lint.sh` |
| SCN-B037-008 | pure calculation, degraded state | malformed checklist refusal | `artifact-lint.sh` |
| SCN-B037-009 | shared consumer | reader-to-Check 43 parity and real guard result | shared reader, Check 43 |
| SCN-B037-010 | degraded state, shared consumer | named guard refusal and opt-out explanation | shared reader, Check 43 |
| SCN-B037-011 | mutable state, shared consumer | refusing guard run plus unchanged persisted bytes | Check 43, acceptance artifact |
| SCN-B037-012 | shared consumer | non-`done` consumer path bypasses acceptance evaluation | Check 43 |
| SCN-B037-013 | static metadata | exact G136 prose-to-enforcer agreement | gate registry, authority registry, Check 43 |
| SCN-B037-014 | static metadata | section-local changelog contract assertions | `CHANGELOG.md` |
| SCN-B037-015 | pure calculation, static metadata | deterministic regeneration and committed freshness for all three projections | three generators and generated targets |
| SCN-B037-016 | degraded state, runtime config | one fail-closed code and non-zero result for each authority failure class | shared reader, authority registry |
| SCN-B037-017 | pure calculation, degraded state | union-field authorship detection and complete present-record validation | shared reader, authority registry |
| SCN-B037-018 | degraded state, runtime config | explicit `true` override activates declared conditional refusal | shared reader, authority registry |
| SCN-B037-019 | static metadata | four-class migration guidance and no bulk mutation mechanism | `CHANGELOG.md`, focused conformance test |

---

## Scope 1 — Invert the acceptance contract and the shared reader

**Status:** [x] Done
**Depends on:** nothing
**Delivers:** AC-1, AC-3, AC-4, AC-5, AC-7 through AC-13

### Gherkin Scenarios

```gherkin
Scenario: SCN-B037-001 A satisfied user who unchecks nothing reaches terminal
  Given a uservalidation.md whose "## Checklist" items are all checked
    And which carries no "## Human Acceptance Record" section
  When bubbles_acceptance_terminal_verdict is evaluated
  Then it returns 0
    And it emits no PD12-NO-RECORD finding

Scenario: SCN-B037-002 A user-reported regression still blocks terminal
  Given a uservalidation.md whose "## Checklist" has five checked items
    And one item the user has unchecked
  When bubbles_acceptance_terminal_verdict is evaluated
  Then it returns non-zero
    And the unchecked item is named in a PD12-UNCHECKED-ITEM finding

Scenario: SCN-B037-003 BUG-029 stays closed
  Given a uservalidation.md whose "## Checklist" has one checked item
    And five unchecked items
  When bubbles_acceptance_terminal_verdict is evaluated
  Then it returns non-zero
    And every one of the five unchecked items is named

Scenario: SCN-B037-004 An optional record is still validated when present
  Given a uservalidation.md whose "## Checklist" items are all checked
    And a "## Human Acceptance Record" whose acceptedBy is "bubbles.validate"
  When bubbles_acceptance_shape_verdict is evaluated
  Then it returns non-zero
    And it emits PD12-AUTOMATION-ACCEPTOR

Scenario: SCN-B037-005 Checked automation readiness grants no acceptance
  Given a uservalidation.md whose "## Automation Readiness" items are all checked
    And whose "## Checklist" carries one unchecked item
  When bubbles_acceptance_terminal_verdict is evaluated
  Then it returns non-zero on the unchecked checklist item

Scenario Outline: SCN-B037-016 Authority resolution failures refuse acceptance
      Given the acceptance authority is <authority-state>
      When either public acceptance verdict evaluates a valid checked checklist
      Then it returns non-zero
            And it emits exactly one PD12-AUTHORITY-UNAVAILABLE finding
            And it emits no acceptance success result

      Examples:
            | authority-state |
            | missing registry |
            | unreadable registry |
            | malformed registry |
            | registry missing a required contract field |
            | registry whose requiredAtTerminal is not the exact boolean true or false |

Scenario: SCN-B037-017 A method-conditional value authors the record
      Given a Human Acceptance Record whose base fields retain template defaults
            And whose record field contains a real external acceptance pointer
      When the acceptance shape verdict is evaluated
      Then the record is treated as authored
            And each missing base field emits PD12-RECORD-INCOMPLETE
            And the pointer is not ignored as an untouched template

Scenario: SCN-B037-018 A supported record requirement activates conditionally
      Given a valid authority whose requiredAtTerminal is the exact boolean true
            And a fully checked checklist with no authored Human Acceptance Record
      When the terminal acceptance verdict is evaluated
      Then it returns non-zero
            And it emits declared code PD12-NO-RECORD exactly once
```

### Implementation Plan

1. `bubbles/registry/acceptance-authority.yaml`
   - `acceptance-checklist.shippedState` → `checked`
   - `acceptance-record.requiredAtTerminal` → `false`
   - Rewrite the file-header rationale. It currently argues the opt-in position
     at length; leaving it in place would make the registry disagree with its
     own data.
       - Apply **D-5** concretely. Declare the six default-active codes,
             conditional-active `PD12-NO-RECORD`, and bootstrap-active
             `PD12-AUTHORITY-UNAVAILABLE` in one closed `failureCodes` set.
       - State that shipped `requiredAtTerminal: false` leaves
             `PD12-NO-RECORD` dormant. State that an explicit supported `true` value
             activates it.
       - State that authority failures activate
             `PD12-AUTHORITY-UNAVAILABLE` without relying on a successful registry read.
2. `bubbles/scripts/acceptance-authority-lib.sh`
       - Preserve `PD12-NO-RECORD` for an explicit supported `true` override.
             Emit nothing for this condition under the shipped `false` value.
       - Add one authority preflight used by both public verdicts. It must validate
             the registry before any acceptance result can succeed.
       - Treat a missing path, unreadable file, malformed contract, missing required
             field, or invalid boolean as one authority failure. Each public verdict
             prints exactly one `PD12-AUTHORITY-UNAVAILABLE: <reason>` line and returns
             `1`. It prints no other acceptance finding after this bootstrap failure.
       - Require `schemaVersion` and all three section IDs and headings.
       - Require checklist `shippedState` and record `requiredAtTerminal`.
       - Require non-empty base fields, methods, and method-specific requirements.
       - Require the forbidden acceptor pattern and closed `failureCodes` set.
       - Accept only lowercase scalar `true` or `false` for
             `requiredAtTerminal`. Missing, empty, quoted-string, numeric, and alternate
             YAML boolean spellings fail closed.
       - Define record authorship over the union of base required fields and every
             declared method-conditional field. Any real value in that union triggers
             complete present-record validation.
       - Treat only a trimmed empty value or one complete bracket-delimited template
             token as a default. Values such as `TBD`, `none`, partial brackets, and
             non-empty external pointers count as authored input.
       - For `human-interactive`, require all base fields. For `external-record`,
             require all base fields and a real `record` pointer.
3. `bubbles/scripts/acceptance-authority-selftest.sh`
       - Add the eight scenarios above plus the authority, authorship, and lifecycle
             adversarial bounds.

### Test Plan

| ID | Test | Type | Surface |
|----|------|------|---------|
| S1-T1 | Fully checked, no record → terminal verdict returns 0 | unit | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T2 | One unchecked among five checked → refused, item named | unit | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T3 | BUG-029 shape (1 checked, 5 unchecked) → refused, all five named | unit | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T4 | Present record with `bubbles.` acceptor → shape verdict refuses | unit | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T5 | Present record missing `acceptedAt` → `PD12-RECORD-INCOMPLETE` | unit | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T6 | Present record with `method: external-record` and no `record` → `PD12-METHOD-FIELD-MISSING` | unit | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T7 | Readiness all checked + one checklist unchecked → refused | unit | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T8 | `SCN-B037-018`: exact `requiredAtTerminal: true` activates one declared `PD12-NO-RECORD` refusal | unit (adversarial) | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T9 | `[ ]` under `## Notes` is still ignored | unit | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T10 | **D-5 code-set closure:** source emitters equal declarations in both directions, including default, conditional, and bootstrap lifecycle fixtures | unit (adversarial) | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T11 | `SCN-B037-016`: a missing registry emits exactly one `PD12-AUTHORITY-UNAVAILABLE` line and both public verdicts return `1` | unit (adversarial) | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T12 | `SCN-B037-016`: an unreadable registry emits the same closed code and both public verdicts return `1` | unit (adversarial) | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T13 | `SCN-B037-016`: malformed YAML or malformed registry structure emits the same closed code and returns `1` | unit (adversarial) | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T14 | `SCN-B037-016`: removal of each required contract field fails closed; at minimum, exercise one field from every contract group | unit (adversarial) | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T15 | `SCN-B037-016`: missing, empty, quoted, numeric, `yes`, and `no` values for `requiredAtTerminal` fail closed | unit (adversarial) | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T16 | `SCN-B037-017`: a real `record` pointer alone marks the record authored and exposes all missing base fields | unit (adversarial) | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T17 | An empty value or complete bracket placeholder in every recognized field remains an untouched record and emits no record-shape finding | unit | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T18 | `human-interactive` accepts only real base fields; `external-record` also requires a real `record` pointer | unit (adversarial) | `bubbles/scripts/acceptance-authority-selftest.sh` |

**S1-T8 is the load-bearing adversarial case.** Without it, the implementation
could satisfy every other test by deleting the record check outright while
claiming to read the registry.

**S1-T10 has no exception list.** It catches an undeclared source literal, an
unreachable declaration, and a lifecycle class without an executed fixture.

**S1-T11 through S1-T15 are fail-closed proofs.** A successful verdict, empty
output, a different code, duplicate bootstrap lines, or additional acceptance
findings fail each case.

**S1-T16 through S1-T18 define authorship.** They prevent a method-conditional
field from bypassing validation and prevent untouched template defaults from
becoming a false authored record.

### Definition of Done

- [x] Failing reproduction captured BEFORE the change, with its real exit code
      → Evidence: [report.md](report.md#red-scope-1)
- [x] `acceptance-authority.yaml` inverted, header rationale rewritten to match
      → Evidence: [report.md](report.md#scope-1)
- [x] `acceptance-authority-lib.sh` terminal verdict no longer requires a record
      → Evidence: [report.md](report.md#scope-1)
- [x] SCN-B037-001 passes with a real exit code
      → Evidence: [report.md](report.md#green-scope-1)
- [x] SCN-B037-002 and SCN-B037-003 still REFUSE — BUG-029 pin proven intact
      → Evidence: [report.md](report.md#bounds-scope-1)
- [x] SCN-B037-004 still REFUSES — record validation survives the optionality
      → Evidence: [report.md](report.md#bounds-scope-1)
- [x] SCN-B037-005 still REFUSES — readiness grants nothing
      → Evidence: [report.md](report.md#bounds-scope-1)
- [x] S1-T8 adversarial case fails when the registry value is reverted
      → Evidence: [report.md](report.md#bounds-scope-1)
- [x] Historical pre-remediation D-5 receipt: `PD12-NO-RECORD` was removed from
      `failureCodes`, six codes were retained, and retirement was recorded
      → Evidence: [report.md](report.md#scope-1)
      This receipt does not satisfy current D-5. The current contract declares
      conditional `PD12-NO-RECORD` and bootstrap
      `PD12-AUTHORITY-UNAVAILABLE`.
- [x] Historical pre-remediation S1-T10 code-set check executed
      → Evidence: [report.md](report.md#bounds-scope-1)
      The amended S1-T10 removes its exception and requires default,
      conditional, and bootstrap reachability before certification.
      → Independent TEST evidence: [revision-5 current-byte replacement](report.md#bug037-test-revision-5-current-byte-replacement)
      (**Phase:** test; tool-log row 495, S1-T10e exact lifecycle labels and
      S1-T10f mutation/non-vacuity under stock and Homebrew Bash)
- [x] `acceptance-authority-selftest.sh` passes end to end, zero skipped
      → Evidence: [report.md](report.md#green-scope-1)
      → Current TEST evidence: [revision-5 current-byte replacement](report.md#bug037-test-revision-5-current-byte-replacement)
      (**Phase:** test; tool-log row 495)
- [x] No regression test contains a conditional early-return that silently passes
      → Evidence: [report.md](report.md#scope-1)
- [x] SCN-B037-016 Authority resolution failures refuse acceptance with one
      `PD12-AUTHORITY-UNAVAILABLE` line and return code `1`.
      → Evidence: [implementation remediation](report.md#bug037-implementation-remediation)
      (**Phase:** implement; tool-log row 308, S1-T11 through S1-T15 under
      stock and Homebrew Bash)
      → Independent TEST evidence: [revision-5 current-byte replacement](report.md#bug037-test-revision-5-current-byte-replacement)
      (**Phase:** test; tool-log row 495, including contract-complete malformed
      YAML through both public verdicts under both Bash runtimes)
- [x] SCN-B037-017 A method-conditional value authors the record and exposes
      every missing base field.
      → Evidence: [implementation remediation](report.md#bug037-implementation-remediation)
      (**Phase:** implement; tool-log row 308, S1-T16 through S1-T18 under
      stock and Homebrew Bash)
- [x] SCN-B037-018 A supported record requirement activates conditionally and
      emits declared `PD12-NO-RECORD` exactly once.
      → Evidence: [implementation remediation](report.md#bug037-implementation-remediation)
      (**Phase:** implement; tool-log row 308, S1-T8 plus S1-T10 through
      S1-T10d under stock and Homebrew Bash)
      → Independent TEST evidence: [revision-5 current-byte replacement](report.md#bug037-test-revision-5-current-byte-replacement)
      (**Phase:** test; tool-log row 495, S1-T10e and S1-T10f)

---

## Scope 2 — Template, lint, and authoring agents

**Status:** [x] Done
**Depends on:** Scope 1
**Delivers:** AC-1, AC-6, AC-9, and design decisions D-1, D-2, D-3

### Gherkin Scenarios

```gherkin
Scenario: SCN-B037-006 A uservalidation.md authored from the template reaches terminal unaided
  Given a uservalidation.md materialized verbatim from the current
        feature-templates.md uservalidation template
    And the placeholder text has been replaced with real behavior descriptions
  When bubbles_acceptance_terminal_verdict is evaluated
  Then it returns 0

Scenario: SCN-B037-007 Lint accepts a fully unchecked checklist
  Given a uservalidation.md whose "## Checklist" items are all unchecked
  When artifact-lint.sh runs over the containing packet
  Then the uservalidation shape checks pass
    And no failure demands a checked entry

Scenario: SCN-B037-008 Lint still rejects a malformed checklist
  Given a uservalidation.md whose "## Checklist" carries a non-checkbox bullet
  When artifact-lint.sh runs over the containing packet
  Then it fails on the non-checkbox bullet
```

### Implementation Plan

1. `agents/bubbles_shared/feature-templates.md`
   - `## Checklist` ships `- [x]`.
   - Rewrite the rules block. Remove the "Acceptance entries ship UNCHECKED
     (IMP-047 PD-12)" rule and its rationale paragraph.
   - Replace the terminal rule with the opt-out contract.
   - Apply **D-3**: restate the `bubbles.journey` rule so it names the three-way
     split — automation MAY author the initial checked state, automation MUST
     NOT re-check a user's uncheck, automation MUST NOT toggle to mirror test
     outcomes — and record that only the first is mechanically checkable, since
     rows two and three produce a byte-identical `- [x]`. **Do NOT carve an
     auto-check exception into the journey rule.** The authoring permission
     belongs to `bubbles.plan`, which creates the artifact; `bubbles.journey`
     runs later against an existing file and never has a legitimate reason to
     write a `[x]`, so its prohibition stays absolute and unqualified.
2. `bubbles/scripts/artifact-lint.sh` — **D-2 ruled NO restoration.** The
   checklist rules are UNCHANGED: no `[x]` requirement is reintroduced. The only
   edit is the stale comment block at lines ~555-563, which explains a PD-12
   rationale that no longer holds; rewrite it to state that the checked shipped
   state now comes from `acceptance-authority.yaml`'s contract rather than from
   a lint refusal, and that lint deliberately keeps only the shape questions.
3. `bubbles/registry/bug-packet.yaml` — invert the `uservalidation.md` purpose
   text at line ~47, which currently says "shipped UNCHECKED".
4. Sweep `agents/bubbles.*.agent.md` and `agents/bubbles_shared/*.md` for
   acceptance-model claims. **Already performed by `bubbles.design`** — see
   [design.md](design.md) § 2.5. The sweep returned three hits outside the known
   stale surfaces, and **all three already agree with the new model**:
   `bubbles.plan.agent.md:230` ("Create with checked-by-default baseline
   template") and `bubbles.journey.agent.md:72,89` (the absolute no-auto-check
   rule D-3 keeps). **No agent file requires a change, and no `allowedPaths`
   expansion is needed.** Re-run the sweep at the delivering commit to confirm
   the result is unchanged.
5. Apply **D-1** without a migration script, bulk checkbox mutation, or foreign
       `uservalidation.md` change.
       - Current opt-out artifacts use checked template state. An uncheck is a user
             rejection.
       - Legacy pre-PD-12 checked artifacts require checklist re-authoring before
             review. Inherited checks do not prove a human act.
       - Legacy PD-12 unchecked artifacts require re-authoring before review only
             when history proves no user interaction. Inherited unchecks are not
             automatically user rejection.
       - Unknown provenance fails closed. Keep the packet `in_progress` and leave
             checkbox bytes unchanged until the owner resolves provenance with the user.
       - Scope 4 publishes these four classes in `CHANGELOG.md`.

### Test Plan

| ID | Test | Type | Surface |
|----|------|------|---------|
| S2-T1 | Template materialization reaches terminal with no human act | integration | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S2-T2 | **Template↔registry agreement:** the uservalidation template block in `feature-templates.md` agrees with `acceptance-authority.yaml` on both section headings AND `acceptance-checklist.shippedState` | unit | new or extended selftest |
| S2-T3 | Lint passes on a fully unchecked checklist | unit | `bubbles/scripts/artifact-lint.sh` over a fixture packet |
| S2-T4 | Lint still fails on a non-checkbox bullet | unit (adversarial) | `bubbles/scripts/artifact-lint.sh` over a fixture packet |
| S2-T5 | Lint still fails on a checklist with zero checkbox entries | unit (adversarial) | `bubbles/scripts/artifact-lint.sh` over a fixture packet |
| S2-T6 | No `agents/**` file asserts acceptance items ship unchecked | unit | grep-based conformance check |
| S2-T7 | `bug-packet.yaml` uservalidation purpose agrees with `acceptance-authority.yaml` | unit | `bubbles/scripts/bug-packet-selftest.sh` |
| S2-T8 | **D-1 bound:** compare an explicit delivery base and candidate revision; fail when any changed `*uservalidation.md` path lies outside this packet, regardless of changed content | unit (adversarial) | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S2-T9 | **S2-T2's adversarial partner:** a fixture template block shipping `- [ ]` FAILS the agreement check | unit (adversarial) | same surface as S2-T2 |

**S2-T4 and S2-T5 are the lint-relaxation bounds.** They prove the D-2 ruling
did not widen into "lint no longer reads the checklist at all".

**S2-T2 is load-bearing, not incidental.** D-2 declines to restore the
≥1-checked lint rule, which removes the only mechanical detector of a template
authored in the wrong shipped state. S2-T2 replaces exactly that assurance and
nothing more, and S2-T9 proves S2-T2 can actually fail.

**S2-T8 is an exact changed-path assertion.** A fixture that changes foreign
prose, headings, checked items, unchecked items, or record fields must fail it.
The test cannot satisfy this row by detecting only `[ ]` to `[x]` transitions.

**S4-T10 covers all migration classes.** Scope 2 establishes the no-mutation
boundary. Scope 4 validates the release guidance that applies each class.

### Definition of Done

- [x] Template `## Checklist` ships `- [x]`
      → Evidence: [report.md](report.md#scope-2-file-state-re-check--the-dod-items-that-are-not-selftest-cases) (T1: the block read off disk)
- [x] Template rules block rewritten; no rule asserts unchecked shipping
      → Evidence: [report.md](report.md#scope-2-file-state-re-check--the-dod-items-that-are-not-selftest-cases) (T2: zero hits across `agents/`; S2-T6 in command 1)
- [x] D-3 three-way split stated in the template; the `bubbles.journey`
      prohibition remains absolute with NO auto-check exception carved into it
      → Evidence: [design.md](design.md), [report.md](report.md#scope-2-file-state-re-check--the-dod-items-that-are-not-selftest-cases) (T3: lines 338-339)
- [x] D-2 applied: `artifact-lint.sh` checklist RULES unchanged; only the stale
      lines ~555-563 comment block rewritten
      → Evidence: [design.md](design.md), [report.md](report.md#d-2-proof--the-artifact-lintsh-diff-is-comment-and-message-only) — narrowed: three hunks, zero control-flow change; hunk 3 is a refusal-label string beyond the literal wording and is disclosed there
- [x] SCN-B037-006 passes: a template materialization reaches terminal unaided
      → Evidence: [report.md](report.md#scope-2-verification--commands-and-real-exit-codes) (S2-T1, exit 0)
- [x] S2-T4 and S2-T5 still FAIL as designed — lint did not go blind
      → Evidence: [report.md](report.md#bounds-scope-2)
- [x] S2-T2 passes and S2-T9 FAILS as designed — the template↔registry check
      replaces the backstop D-2 declined to restore, and can actually refuse
      → Evidence: [report.md](report.md#bounds-scope-2)
- [x] `bug-packet.yaml` purpose text inverted
      → Evidence: [report.md](report.md#scope-2-verification--commands-and-real-exit-codes) (S2-T7: purpose agrees with the registry, shipped checked)
- [x] `agents/**` sweep re-run at the delivering commit; result matches
      [design.md](design.md) § 2.5 — no agent file changed, no `allowedPaths`
      expansion taken
      → Evidence: [report.md](report.md#the-agents-sweep-re-run-at-this-commit)
- [x] D-1 applied: no migration script authored, no bulk auto-check performed,
      and S2-T8 proves no foreign `uservalidation.md` was modified
      → Evidence: [report.md](report.md#bounds-scope-2) — narrowed: S2-T8 proves no `[ ]`→`[x]` flip (the AC-6 invariant), not untouched-ness; the disclosure names the unrelated in-flight `BUG-033` edit
      This historical receipt does not satisfy amended S2-T8. The replacement
      must reject every foreign acceptance-file change, regardless of content.
- [x] `artifact-lint.sh` passes on this bug packet itself
      → Evidence: [report.md](report.md#scope-2-closeout-re-lint) (exit 0, re-run after the boxes were checked)
- [x] SCN-B037-007 Lint accepts a fully unchecked checklist without demanding a
      checked entry after the amended contract lands.
      → Evidence: [implementation remediation](report.md#bug037-implementation-remediation)
      (**Phase:** implement; tool-log row 308, S2-T3 under stock and
      Homebrew Bash)
- [x] SCN-B037-008 Lint still rejects malformed checklist content after the
      amended contract lands.
      → Evidence: [implementation remediation](report.md#bug037-implementation-remediation)
      (**Phase:** implement; tool-log row 308, S2-T4 and S2-T5 under stock
      and Homebrew Bash)

---

## Scope 3 — Guard Check 43 and the regression surfaces

**Status:** [x] Done
**Depends on:** Scope 1
**Delivers:** AC-4, AC-5

### Gherkin Scenarios

```gherkin
Scenario: SCN-B037-009 Check 43 passes a fully checked checklist with no record
  Given a spec packet whose resolved target status is "done"
    And whose uservalidation.md has every acceptance item checked
    And which carries no "## Human Acceptance Record"
  When the state transition guard runs Check 43
  Then Check 43 passes

Scenario: SCN-B037-010 Check 43 refuses an unchecked item and names it
  Given a spec packet whose resolved target status is "done"
    And whose uservalidation.md carries one unchecked acceptance item
  When the state transition guard runs Check 43
  Then Check 43 fails
    And the refusal names the unchecked item
    And the refusal text describes the opt-out contract, not an acceptance record

Scenario: SCN-B037-011 The guard never edits uservalidation.md
  Given a spec packet that Check 43 will refuse
  When the state transition guard runs Check 43
  Then the sha256 of uservalidation.md is unchanged

Scenario: SCN-B037-012 A ceiling-bound mode is still exempt
  Given a spec packet whose resolved target status is not "done"
    And whose uservalidation.md carries unchecked acceptance items
  When the state transition guard runs Check 43
  Then Check 43 passes without evaluating acceptance
```

### Implementation Plan

1. `bubbles/scripts/guards/tail-delegated-gates.sh` Check 43
   - The header comment block (lines ~496-522) explains the PD-12 rationale and
     must be rewritten to the opt-out contract.
   - The `fail` message and the `info` lines that follow it currently point the
     reader at the acceptance record and at
     `bubbles/registry/acceptance-authority.yaml`; the registry pointer stays,
     the record narrative changes.
   - The `pass` message asserts "and a human acceptance record is present" —
     that clause must go.
   - Check 43's scope rule (runs only when target status is `done`) is unchanged
     and must be proven still intact by SCN-B037-012.
2. `bubbles/scripts/state-transition-guard-selftest.sh` (Check 43 cases, ~line 5104)
   - Update the cases to the new terminal contract. **Keep the BUG-029 case.**
3. `tests/regression/test_35_human_acceptance_terminal.sh`
   - Keep fixtures 1, 2 and 3 and their BUG-029 assertions.
   - Invert the PD-12 assertion at line ~122: a fully checked list with no
     acceptance record now returns zero findings.
   - Add an adversarial case asserting an unchecked item still yields
     `PD12-UNCHECKED-ITEM`.
   - Update the file header comment, which narrates the PD-12 rationale.

### Test Plan

| ID | Test | Type | Surface |
|----|------|------|---------|
| S3-T1 | Check 43 passes a fully checked, record-less packet at `done` | functional | `bubbles/scripts/state-transition-guard-selftest.sh` |
| S3-T2 | Check 43 refuses one unchecked item and names it | functional (adversarial) | `bubbles/scripts/state-transition-guard-selftest.sh` |
| S3-T3 | BUG-029 shape still refused end to end through the real guard | functional (adversarial) | `bubbles/scripts/state-transition-guard-selftest.sh` |
| S3-T4 | `uservalidation.md` sha256 unchanged across a refusing guard run | functional (adversarial) | `bubbles/scripts/state-transition-guard-selftest.sh` |
| S3-T5 | Ceiling-bound target status still exempt | functional | `bubbles/scripts/state-transition-guard-selftest.sh` |
| S3-T6 | `test_35` BUG-029 fixtures still detect their unchecked items | unit | `tests/regression/test_35_human_acceptance_terminal.sh` |
| S3-T7 | `test_35` fully-checked record-less fixture now returns zero findings | unit | `tests/regression/test_35_human_acceptance_terminal.sh` |
| S3-T8 | `test_35` still sources the shared library rather than re-parsing | unit (adversarial) | `tests/regression/test_35_human_acceptance_terminal.sh` |
| S3-T9 | Check 43 refusal text contains no stale acceptance-record demand | unit | grep-based conformance check |

**S3-T4 is the AC-5 proof.** A guard that "helpfully" checked the box would pass
every other test in this table.

### Definition of Done

- [x] Check 43 header comment, `fail`, `info` and `pass` text all rewritten
      → Evidence: [report.md](report.md#scope-3) (S3-T9 grep conformance: 9 emitted
      lines, 0 stale acceptance-record demands; the `pass` clause "and a human
      acceptance record is present" is gone; registry pointer retained)
- [x] SCN-B037-009 passes through the REAL guard, not through the library alone
      → Evidence: [report.md](report.md#green-scope-3) (S3-T1 via
      `BUBBLES_STATE_TRANSITION_GUARD_SELFTEST_FAST=0`; S3-T0 refuses an empty
      Check 43 section so the pass cannot rest on absence)
- [x] SCN-B037-010 refuses and names the item
      → Evidence: [report.md](report.md#bounds-scope-3) (S3-T2 asserts
      `BLOCK:.*Gate G136` plus `PD12-UNCHECKED-ITEM: - [ ] Deleting an item…`;
      S3-T2b asserts the refusal names no acceptance record)
- [x] SCN-B037-011 proven by sha256 comparison before and after
      → Evidence: [report.md](report.md#bounds-scope-3) (S3-T4, the AC-5 proof:
      hash before, REFUSING guard run, hash after, compared)
- [x] SCN-B037-012 proven: ceiling-bound exemption intact
      → Evidence: [report.md](report.md#bounds-scope-3) (S3-T5 on the docs-only
      base fixture; guard fragment line 536 carries the scope rule)
- [x] BUG-029 pin proven intact end to end through the guard
      → Evidence: [report.md](report.md#bounds-scope-3) (S3-T3: refused through
      the real guard with all five items named)
- [x] `test_35` still sources the shared reader — no re-implemented parser
      → Evidence: [report.md](report.md#scope-3) (S3-T8 self-assertion passes;
      Check 43 likewise sources the library at fragment line 543 and defines zero
      local section parsers)
- [x] `state-transition-guard-selftest.sh` passes, zero skipped
      → Evidence: [report.md](report.md#green-scope-3) (exit 0, 527 lines,
      sha256 8e05bed1…f67b114; the harness has no skip channel — narrowing stated
      in the report)
- [x] `tests/regression/test_35_human_acceptance_terminal.sh` passes
      → Evidence: [report.md](report.md#green-scope-3) (exit 0, 13 passed,
      0 failed)

---

## Scope 4 — Governance documentation and generated artifacts

**Status:** [x] Done — all 13 DoD items are evidence-backed.
S4-T5 and S4-T6 have durable current-session receipts.

The earlier timeouts and repository-wide red run remain recorded in
[report.md](report.md). They remain historical facts. The current green runs
supersede them only as operative routing evidence. Scope completion is not
certification, and the packet remains `in_progress`.
**Depends on:** Scopes 1, 2, 3
**Delivers:** GC-1 through GC-5

### Gherkin Scenarios

```gherkin
Scenario: SCN-B037-013 No surface describes a lint rule that does not exist
  Given the repository at the delivering commit
  When every surface describing Gate G136 is compared to artifact-lint.sh
  Then no surface asserts a lint requirement that artifact-lint.sh does not carry

Scenario: SCN-B037-014 The changelog records the contract change
  Given the repository at the delivering commit
  When CHANGELOG.md is read
  Then it carries an entry for the PD-12 acceptance-model change
    And it carries an entry for the BUG-037 inversion
    And the BUG-029 entry no longer states the superseded lint contract as current

Scenario: SCN-B037-015 Generated artifacts were regenerated, not hand-edited
  Given the repository at the delivering commit
  When each generator is re-run
  Then its output is byte-identical to the committed artifact

Scenario Outline: SCN-B037-019 Legacy acceptance artifacts receive safe guidance
      Given a uservalidation.md has <provenance-class>
      When the BUG-037 upgrade contract is applied
      Then the documented handling is <required-handling>
            And no bulk migration script changes checkbox state

      Examples:
            | provenance-class | required-handling |
            | current opt-out provenance | apply the current contract without migration |
            | legacy pre-PD-12 checked provenance | re-author before review and do not treat inherited checks as a human act |
            | legacy PD-12 unchecked provenance with proven no interaction | re-author before review and do not treat inherited unchecks as rejection |
            | unknown provenance | keep in progress, preserve bytes, and obtain owner plus user resolution |
```

### Implementation Plan

1. `bubbles/registry/gates.yaml` `G136.description` — name all three authority
      sections. State that Check 43 evaluates acceptance only for target `done`.
      Describe every default, conditional, and bootstrap code the shared reader can
      emit. Remove both false assertions.
2. `bubbles/registry/gates.yaml` `G057.description` — **amend; D-3 ruled this
   REQUIRED, not conditional.** Replace the single clause "uservalidation.md
   remains a human acceptance surface and MUST NOT be toggled to mirror
   automation outcomes" with the three-way split: automation MAY author the
   initial checked state; automation MUST NOT re-check a user's uncheck;
   automation MUST NOT toggle either way to mirror a test outcome. State
   plainly that only the first is mechanically checkable and that the other two
   are agent-instruction obligations this gate's enforcer does not verify —
   `guards/control-plane-checks.sh` never reads `uservalidation.md` at all, so
   the current wording already overstates what G057 does.
3. `agents/bubbles_shared/quality-gates.md` (line ~272) — replace stale text.
4. `agents/bubbles_shared/test-core.md` (lines ~300-310, "Human Acceptance Is
   Terminal") — replace stale text.
5. `skills/bubbles-quality-gates-catalog/SKILL.md` (G136 row, line ~57) —
   replace stale text. **This surface is stale today and was not in the
   originally reported set.**
6. `CHANGELOG.md` — add the BUG-037 entry; add the missing PD-12 entry; correct
   the BUG-029 entry at line ~1320, which states the pre-PD-12 contract as
      current. The BUG-037 entry MUST carry the **D-1 upgrade note**. Name current
      opt-out, legacy pre-PD-12 checked, legacy PD-12 unchecked, and unknown
      provenance as four separate classes. State each class's handling from
      SCN-B037-019. State that current bytes and dates alone do not establish user
      intent. State that no bulk migration script exists.
7. `BUGS.md` — index entry for BUG-037.
8. `improvements/INDEX.md` — **D-4 ruled: correct the sentence, touch nothing
   under `bugs/BUG-032-*`.** In the IMP-047 row, replace the sentence beginning
   "BUG-032 stays `in_progress`: closing it needs a human G136 acceptance
   record…" with the verbatim replacement text recorded in
   [design.md](design.md) § 3 D-4 — which keeps BUG-032 `in_progress` on its own
   `bubbles.docs` work, records that the G136 record requirement was removed by
   BUG-037, and states that BUG-032's checked state is legacy-shaped and must
   not be read as a fresh human acceptance.
9. Regenerate, do not hand-edit:
   - `docs/generated/gate-coverage-map.md` via `generate-gate-coverage-map.sh`
   - `bubbles/registry/validation-checks.yaml` via `generate-validation-checks.sh`
   - `bubbles/release-manifest.json` via `generate-release-manifest.sh`
10. Re-run the [design.md](design.md) § 2.5 verification sweep at the delivering
    commit and confirm the result is unchanged. **The sweep itself is already
    complete** — `bubbles.design` read every entry and recorded each as affected
    or ruled out; 16 of 16 need no change. This step is the confirmation, not
    the sweep, and it is mechanized as S4-T1.

### Test Plan

| ID | Test | Type | Surface |
|----|------|------|---------|
| S4-T1 | No repository surface asserts the deleted lint requirement | unit | grep-based conformance check |
| S4-T2 | Parse only the `G136.description` block. Require the Automation Readiness, Checklist, and Human Acceptance Record sections, target-`done` scope, opt-out condition, and exact declared code set | unit (adversarial) | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S4-T3 | Each generator's committed-freshness selftest passes. Release-manifest coverage resolves to exact title `Committed release manifest is current` | unit (adversarial) | `generate-gate-coverage-map-selftest.sh`, `generate-validation-checks-selftest.sh`, `release-manifest-selftest.sh` |
| S4-T4 | Parse section-local changelog entries. Require BUG-037, PD-12, the corrected BUG-029 entry, and all four D-1 classes with distinct handling | unit (adversarial) | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S4-T5 | `framework-validate.sh` passes end to end | functional | `bubbles/scripts/cli.sh framework-validate` |
| S4-T6 | `release-check` passes | functional | `bubbles/scripts/cli.sh release-check` |
| S4-T7 | `agnosticity` lint passes | functional | `bubbles/scripts/cli.sh agnosticity` |
| S4-T8 | Parse only `G057.description`. Require all three D-3 rules, classify initial authoring as mechanical, classify re-check and outcome mirroring as advisory, and prove the enforcer does not read `uservalidation.md` | unit (adversarial) | `bubbles/scripts/acceptance-authority-selftest.sh` plus `guards/control-plane-checks.sh` |
| S4-T9 | **D-4 bound:** the delivering commit modifies no path under `bugs/BUG-032-` | unit (adversarial) | conformance check over the commit's changed-file set |
| S4-T10 | `SCN-B037-019`: the changelog distinguishes all four migration classes, preserves unknown-provenance bytes, and states that no bulk migration script ships | unit (adversarial) | `bubbles/scripts/acceptance-authority-selftest.sh` |

**S4-T3 is the GC-5 proof.** A hand-edited generated file passes a text grep and
fails a regeneration diff.

**S4-T9 is the D-4 bound.** It proves BUG-032 was not closed, advanced, or
otherwise touched as a side effect of removing its stated blocker.

**S4-T2, S4-T4, and S4-T8 require structural assertions.** Removing any named
section, condition, class, rule, or mechanical or advisory label must make the
focused test fail. A repository-wide keyword match cannot satisfy these rows.

**S4-T3 closes the generated-surface set.** It covers the gate map, validation
checks, and release manifest through resolvable test identities rather than a
raw generator command.

### Definition of Done

- [x] `G136.description` rewritten; both false assertions removed
      → Evidence: [report.md](report.md#scope-4) (**Phase:** implement — the
      G136 block scanned in isolation: `false assertion A (lint requires >=1
      checked): False`, `false assertion B (template ships unchecked): False`)
- [x] `quality-gates.md` stale text replaced
      → Evidence: [report.md](report.md#scope-4) (**Phase:** implement — line 272
      now carries the OPT-OUT contract, the honest "what it proves" clause, and
      the then-active retired wording for `PD12-NO-RECORD`). Current D-5 requires
      this surface to describe the code as conditional-active.
- [x] `test-core.md` stale text replaced
      → Evidence: [report.md](report.md#scope-4) (**Phase:** implement — the
      section is now "User Acceptance Is Terminal (… BUG-037, Gate G136)";
      acceptance is opt-out and the record is OPTIONAL and not required at
      terminal)
- [x] `skills/bubbles-quality-gates-catalog/SKILL.md` G136 row replaced
      → Evidence: [report.md](report.md#scope-4) (**Phase:** implement — line 57
      rewritten to the opt-out contract; rejection-channel framing retained)
- [x] `CHANGELOG.md` carries the BUG-037 entry AND the missing PD-12 entry
      → Evidence: [report.md](report.md#scope-4) (**Phase:** implement — line 34
      "User Acceptance Is Opt-Out Again (BUG-037)"; the backfilled entry "The
      Acceptance-Authority Change Had No Changelog Entry (IMP-047 PD-12)")
- [x] Historical pre-remediation BUG-037 changelog receipt: cutover commit,
      one-bucket legacy warning, re-author-before-review instruction, and the
      statement that no migration script ships
      → Evidence: [design.md](design.md), [report.md](report.md#scope-4)
      (**Phase:** implement — all four elements quoted from the UPGRADE NOTE,
      including "No migration script exists and none will be shipped" with its
      reason)
      This receipt does not satisfy current D-1. The amended entry must name
      all four provenance classes and each class's distinct handling.
- [x] `CHANGELOG.md` BUG-029 entry corrected; it no longer states a superseded contract as current
      → Evidence: [report.md](report.md#scope-4) (**Phase:** implement — line
      1396 now reads "Superseded in part by BUG-037" and states the lint rule as
      deleted-and-not-restored; one inverted "below"/"above" cross-reference was
      found and fixed during this closeout)
- [x] D-3 applied: `G057.description` carries the three-way split and declares
      rows 2 and 3 advisory; S4-T8 passes
      → Evidence: [design.md](design.md), [report.md](report.md#scope-4)
      (**Phase:** implement — S4-T8:
      `grep -c "uservalidation" bubbles/scripts/guards/control-plane-checks.sh`
      → `0`, so the advisory declaration is accurate)
- [x] D-4 applied: the `improvements/INDEX.md` IMP-047 sentence replaced with
      the verbatim design.md § 3 D-4 text, and S4-T9 proves nothing under
      `bugs/BUG-032-` was modified
      → Evidence: [report.md](report.md#bounds-scope-4) (**Phase:** implement —
      superseded sentence count `0`; S4-T9: `git status --porcelain` and
      `git diff HEAD --stat` over `bugs/BUG-032-*` both emitted zero lines)
- [x] Generated artifacts REGENERATED; regeneration diff is empty
      → Evidence: [report.md](report.md#bounds-scope-4) (**Phase:** implement —
      all three sha256 digests byte-identical across a second regeneration;
      `generate-validation-checks-selftest.sh` 10 checks / 0 failures;
      `generate-gate-coverage-map-selftest.sh` SKIPPED for absent PyYAML and
      declared as a skip, not counted as a pass)
- [x] `framework-validate` passes end to end with a real exit code
      → Evidence: [current canonical framework validation](report.md#s4-t5-current-canonical-framework-validation)
- [x] `release-check` passes with a real exit code
      → Evidence: [current canonical release check](report.md#s4-t6-current-canonical-release-check)
- [x] The design.md § 2.5 sweep re-run at the delivering commit returns the
      recorded result: 16 of 16 entries need no change
      → Evidence: [report.md](report.md#scope-4) (**Phase:** implement — 13
      ruled-out entries re-checked individually, all still `matches=0`; the 5
      claim-carrying/neutral entries quoted verbatim and unchanged; the
      repository-wide stale-text sweep returned grep exit 1, zero hits)
- [x] SCN-B037-013 No surface describes a lint rule that does not exist, and
      G136 states all sections, codes, and its target-`done` condition.
      → Evidence: [test assertion-fidelity remediation](report.md#bug037-test-assertion-fidelity-remediation)
      (**Phase:** test; tool-log row 316, description-only S4-T2 and S4-T8
      assertions with exact clause controls under stock and Homebrew Bash)
- [x] SCN-B037-014 The changelog records BUG-037, PD-12, corrected BUG-029 text,
      and all four D-1 migration classes.
      → Evidence: [test assertion-fidelity remediation](report.md#bug037-test-assertion-fidelity-remediation)
      (**Phase:** test; tool-log row 316, named section-local S4-T4 and S4-T10
      assertions with BUG-029 and per-class deletion controls under both Bash runtimes)
- [x] SCN-B037-015 Generated artifacts were regenerated and every committed
      target passes its exact freshness identity.
      → Evidence: [implementation remediation](report.md#bug037-implementation-remediation)
      (**Phase:** implement; tool-log rows 307 and 309, all three generators,
      freshness checks, and focused selftests)
- [x] SCN-B037-019 Legacy acceptance artifacts receive provenance-safe guidance
      for all four classes without bulk checkbox mutation.
      → Evidence: [implementation remediation](report.md#bug037-implementation-remediation)
      (**Phase:** implement; tool-log row 308, S4-T10 through S4-T10c under
      stock and Homebrew Bash)
