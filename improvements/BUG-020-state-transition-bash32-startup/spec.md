# Expected Behavior: BUG-020 State Transition Bash 3.2 Startup

## Problem Contract

A mandatory governance entrypoint must not depend on Bash features newer than
the repository's declared macOS system-Bash baseline merely to load an optional
presentation module.

## Outcome Contract

**Intent:** A macOS contributor can load the complete optional fun-mode API and
invoke mandatory transition governance with the repository's declared system
Bash without an optional presentation module aborting startup or obscuring a
mandatory resolver prerequisite.

**Success Signal:** Under Bash 3.2, parser-free fun-mode API proof completes;
the system-only real-guard lane reaches `E009-REGISTRY-MISSING` without claiming
Check 8; and parser-aware real-guard lanes reach Check 8 and preserve their
fixture-controlled structured outcomes. A prospective isolated run establishes
the final-test-before-patch chronology with identical test bytes.

**Hard Constraints:** Mandatory checks, parser requirements, nounset behavior,
structured results, exits, public fun-mode behavior, and canonical release
provenance remain authoritative. BUG-022 remains foreign-owned, and no newer
shell, parser shim, timeout tool, suppressed error, or retroactive RED claim may
stand in for the required lane-specific proof.

**Failure Condition:** The change fails even if a broad test command exits zero
when it weakens governance, silently disables requested fun behavior, labels a
parser-free resolver refusal as Check 8 proof, absorbs BUG-022, or treats test
bytes written after the candidate source as scenario-first evidence.

## Actors

- A macOS contributor running the canonical transition guard with `/bin/bash`.
- A framework test invoking the real guard in an isolated fixture.
- A downstream repository running installed Bubbles governance scripts.
- A release owner promoting one byte-identical portable framework unit.

## Requirements

### BR-020-001 Separate Parser-Free Startup From Parser-Aware Guard Proof

Under macOS Bash 3.2 with a strict system-only `PATH`, the canonical
`fun-mode.sh` module must source under nounset and preserve its complete
disabled and enabled public API without a Bash-4-only diagnostic. A real
`state-transition-guard.sh` invocation in that same parser-free environment
must pass the fun-mode startup boundary and stop fail-closed at
`E009-REGISTRY-MISSING`, because the canonical transition resolver requires
real `jq` and `yq`; that system-only lane is not Check 8 proof. Full Check 8,
structured-result, and genuine-finding proof must instead run under macOS
system Bash with system directories first and the declared real parser
directories appended fail-loud.

### BR-020-002 Preserve Mandatory Guard Semantics

The compatibility repair must not skip, reorder, weaken, or convert any
transition check into a silent pass. It must not weaken the registry-parser
precondition or absorb the empty-array nounset repair owned by BUG-022.

### BR-020-003 Keep Fun Mode Optional

With `BUBBLES_FUN_MODE` unset or false, optional fun-mode implementation details
must not be loaded in a way that can abort the guard. The design owner must also
define explicit Bash-3.2 behavior when fun mode is requested; silent partial
initialization is forbidden.

### BR-020-004 Fail On Real Guard Findings

After startup succeeds, genuine transition findings must retain their current
nonzero exit and structured-result behavior.

### BR-020-005 Scenario-First Production Regression

A persistent regression must execute the canonical fun-mode module and the real
state-transition guard through explicit sanitized `/bin/bash` consumer lanes.
The parser-free lane proves module/API startup and normal missing-parser
refusal; a parser-aware lane, with system directories first and only the real
`jq`/`yq` directories added, proves the complete guard path. A copied `declare`
snippet or syntax-only test is insufficient.

### BR-020-006 Adversarial Reintroduction And Prospective TDD Signal

The regression must keep parser-free fun-mode source/API cases and a
system-only real-guard resolver-precondition case with fun mode disabled and no
`timeout`, `gtimeout`, newer Bash, `jq`, or `yq` on `PATH`. Those cases must
fail if the unconditional Bash-4-only source path returns, require the real
guard to reach `E009-REGISTRY-MISSING`, and reject any claim that the
system-only lane reached Check 8. Separate parser-aware cases using the
declared real parser prerequisites must reach Check 8 and preserve the planned
pass and genuine-finding outcomes.

A valid scenario-first restart must record the final revised regression bytes,
run those bytes first in an isolated source projection against the known
pre-fix `fun-mode.sh` blob, observe the historical fun-mode startup
discriminator, apply the candidate portable source only afterward in that same
lineage, and rerun identical regression bytes. The earlier HEAD-restored
fixture and the current-source parser-blocked run remain diagnostic only; they
cannot be relabeled as the required RED. Any empty-array nounset failure after
the resolver precondition remains owned by BUG-022 and is neither repaired nor
claimed as BUG-020 proof.

### BR-020-007 No Silent Bailout

The regression must directly assert the observable contract of every lane: the
module/API behavior in the parser-free source lane, the exact
`E009-REGISTRY-MISSING` diagnostic and nonzero exit in the strict system-only
guard lane, and the Check 8 banner, structured result, and expected guard exit
in the parser-aware lane. It may not return early, treat missing-parser refusal
as Check 8 evidence, or pass when `gate_passed` appears.

### BR-020-008 Canonical-Only Delivery

The repair lands in canonical Bubbles and reaches downstream repositories only
through supported release/install/upgrade provenance.

### Single-Capability Justification

BUG-020 repairs one existing optional presentation/startup compatibility
boundary; it does not introduce a new reusable capability. The mandatory
behavioral authority remains
[`state-transition-guard.sh`](../../bubbles/scripts/state-transition-guard.sh),
including its checks, structured result, and exit semantics, while the existing
implementation remains the seven-function optional fun-mode API in
[`fun-mode.sh`](../../bubbles/scripts/fun-mode.sh). Bash 3.2 and newer Bash are
compatibility environments for that same API, not providers or variants that
need a foundation, adapter, registry, or second contract.

The working-tree `fun-mode.sh` is already dirty with the candidate portable
dispatcher and positional-pool rewrite because source was edited before the
mandatory final-byte RED. The later HEAD-restored fixture documented in
[report.md](report.md#final-byte-red-regression) does not repair that sequencing
breach, and the current-source matrix separates the cleared module/API boundary
from the resolver precondition and BUG-022-owned result-emission boundary
([report.md](report.md#bash-32-and-newer-bash-regression-matrix)). This
justification therefore closes only G094: it makes no RED, GREEN, delivery, or
completion claim. The packet remains blocked while `bubbles.plan` synchronizes
its active scenarios, Test Plan, DoD, and machine-readable manifests to these
reconciled requirements and while BUG-022 remains independently owned.

## Acceptance Scenarios

```gherkin
Feature: Start the state-transition guard on the declared macOS shell baseline

  Scenario: SCN-BUG-020-001 Parser-free Bash proves portable fun-mode startup
    Given stock macOS Bash 3.2 with a strict system-only PATH
    And jq, yq, timeout, gtimeout, and newer Bash are unavailable
    When the regression sources the canonical fun-mode module under nounset
    And exercises its public API with fun mode disabled and enabled
    Then sourcing succeeds without an associative-array or nameref diagnostic
    And disabled calls remain silent
    And enabled calls preserve the existing message, pool, banner, and summary contract

  Scenario: SCN-BUG-020-002 Missing parsers produce the normal resolver refusal
    Given stock macOS Bash 3.2 with a strict system-only PATH
    And jq and yq are unavailable
    When the regression invokes the real state-transition guard
    Then fun-mode initialization does not abort the guard
    And the guard reports E009-REGISTRY-MISSING with a nonzero exit
    And the run is not required or credited as reaching Check 8
    And empty-array result integrity remains governed by BUG-022

  Scenario: SCN-BUG-020-003 Parser-aware Bash proves the complete guard path
    Given stock macOS Bash 3.2 with system directories first on PATH
    And the real jq and yq directories are appended without a newer Bash or timeout provider
    And passing and genuine-finding fixtures exercise disabled and enabled fun mode
    When the real state-transition guard runs under macOS system Bash
    Then each fixture reaches Check 8 exactly once
    And each fixture produces one structured transition result
    And pass and genuine-finding exits preserve their existing semantics
    And no optional fun-mode initialization error masks the guard outcome
```

## Release Train

Target train: `framework-next`. This bug introduces no feature flag. Other
trains remain unchanged until the normal framework release and downstream
upgrade path consumes the repaired canonical bytes.

## Non-Goals

- Repairing BUG-019 Check 8 extraction.
- Repairing BUG-022 empty-array nounset or result-emission behavior.
- Requiring a strict no-parser PATH to reach Check 8 or prove a complete
  structured guard result.
- Rewriting every Bash-4-only optional utility in the repository.
- Requiring Homebrew Bash or GNU coreutils on macOS.
- Patching any downstream `.github/bubbles/**` file directly.
- Editing generated release metadata before implementation and tests settle.

## References

- [bug.md](bug.md)
- [design.md](design.md)
- [scopes.md](scopes.md)
- [report.md](report.md)
