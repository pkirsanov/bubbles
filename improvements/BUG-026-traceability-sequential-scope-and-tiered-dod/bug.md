# Bug: BUG-026 Traceability Sequential Scope And Tiered DoD

## Summary

`bubbles/scripts/traceability-guard.sh` has two independent false-blocking
defects. First, a per-scope-directory packet is always analyzed as one
all-scope universe, even when validated v3 state identifies one current
sequential scope and only exact `not_started` transitive descendants should be
omitted from the current-scope check. Second, its G068 DoD extractor terminates
at any subsequent heading at depths 1-4, so accepted tier headings such as
`#### Core Delivery Items` and `#### Build Quality Gate` make a valid DoD
appear rowless.

Research Lab Feature 007 Scope 01 records the combined consumer result as 37
findings and 0 warnings: 28 findings from exact `not_started` transitive
descendants Scopes 02-09 and nine false `no DoD items` findings, one for each
scope.

## Severity

- [ ] Critical - Framework cannot run
- [x] High - A valid sequential scope cannot close and no bypass is permitted
- [ ] Medium - Major workflow degradation with a valid workaround
- [ ] Low - Cosmetic or advisory only

## Status

- [x] Reported
- [x] Confirmed by current source and consumer-artifact inspection
- [x] In Progress
- [ ] Fixed
- [ ] Verified
- [ ] Closed

## Identity Collision Provenance

The defect is filed canonically as BUG-026. Identity history and defect
reproduction are separate records:

1. Commit `e9e1de266eb8f6a3abd26ee3e40f1b733017521e` already assigned
   `BUG-024-create-skill-placeholder-stubs` and
   `BUG-025-skills-first-map-merged-rows` before this intake.
2. A transient directory named
   `BUG-024-traceability-sequential-scope-and-tiered-dod` was created and
   reconciled during concurrent work, then disappeared from the canonical
   checkout when `main` advanced and was reconciled.
3. That transient name was never a valid canonical BUG-024 identity and must
   not be recreated.
4. The prior transient packet bytes are unavailable. This packet does not
   claim byte recovery. It is a substantive reconstruction under BUG-026 from
   current framework source, the current consumer evidence named below, and
   the parent-provided architecture and planning observations.
5. At the intake baseline, canonical `HEAD`, branch, and remote were
   `a11b2e84e33ec6dc02f8d913908d124c613e5919`, `main`, and the same
   `origin/main`; the BUG-026 directory was absent.

## Reproduction Steps

1. In Research Lab Feature 007 state, identify
   `execution.currentScope = 01-capability-foundation`, status `blocked`, and
   Scopes 02-09 as exact `not_started` transitive descendants.
2. Observe that Scope 01 product checks and its four traceability
   scenario-to-row/file/report edges pass.
3. Run the current guard from the owning Research Lab root with its existing
   one-argument form.
4. Observe 28 findings from reports/Test Plan rows belonging only to the
   unstarted descendant scopes.
5. Inspect any Feature 007 scope DoD. The accepted start is at depth 3 and its
   checkboxes live below depth-4 tier headings.
6. Observe one G068 `has Gherkin scenarios but no DoD items` finding for each
   of the nine scopes.
7. Observe the final consumer verdict: 37 findings, 0 warnings.

## Expected Behavior

- The one-argument guard and explicit `--all-scopes` retain all-scope
  behavior.
- Explicit valueless `--current-scope` derives context only from fail-closed
  validated v3 state.
- A single immutable applicable scope universe is built before every
  traceability pass.
- Only exact `not_started` transitive descendants of the current scope may be
  omitted. The current scope, completed prerequisites, independent scopes,
  active/blocked/done descendants, and every final-context gap remain visible.
- Accepted DoD starts at depths 1-4 retain nested tier headings through depth
  6 and stop only at a same-depth or shallower real heading.
- DoD headings in fenced code or HTML comments are inert; depths 5 and 6 do
  not start a DoD section.
- Missing, rowless, ambiguous, and read/parser failures remain distinct.
- Existing checkbox grammar and G068 matching thresholds remain unchanged.
- Malformed or contradictory state fails closed; no caller-supplied scope ID,
  environment override, fallback, bypass, force, ignore, or allow-once path
  exists.

## Actual Behavior

The guard discovers every `scopes/*/scope.md`, appends each file to
`scope_analysis_files`, and sends that unfiltered universe through manifest,
scenario/Test Plan, physical-path, report-evidence, and G068 checks. It has no
active sequential-scope context. Its `extract_dod_items()` starts at a DoD
heading and exits on the next heading matching `^#{1,4}[[:space:]]`, including
valid depth-4 tier headings.

`state-transition-guard.sh` remains intentionally all-scope, but Check 4A
(G041) and Check 22 (G068) repeat the same incorrect DoD boundary semantics.

## Current-Source Root Cause

### BUG026-F001 Sequential Scope Universe

`traceability-guard.sh` builds `scope_files` from every physical scope and
immediately projects all entries into `scope_analysis_files`. No strict state
loader, current-scope resolver, dependency graph validation, or applicable-
universe projection runs before G057/G059 and the traceability passes.

### BUG026-F002 Tiered DoD Boundary

`extract_dod_items()` treats every depth-1-through-depth-4 heading after a DoD
start as the end of that section. A valid depth-3 DoD therefore ends at its
first depth-4 tier. Check 4A and Check 22 in `state-transition-guard.sh` use the
same boundary shape and require explicit parity design.

## Impact

- A sole current sequential scope can remain blocked by exact unstarted work
  that is not eligible to execute.
- Plan-owned tiered DoD structure accepted by artifact lint can be rejected by
  traceability and state-transition checks.
- Operators cannot distinguish a real delivery gap from a context-selection
  or parser false positive.
- Rewriting valid planning artifacts or bypassing a nonzero guard would violate
  framework policy, so there is no valid local workaround.

## BUG-018 Boundary

`improvements/BUG-018-traceability-test-plan-heading-depth` repaired exact
level-2/level-3 Test Plan heading extraction. It explicitly preserved Feature
007's then-current 37 findings as separately owned delivery data. BUG-026 does
not reopen or edit BUG-018, and it does not modify
`tests/regression/test_25_traceability_test_plan_heading_depth.sh`. Delivery
must prove BUG-018 byte and behavior compatibility while correcting the two
newly isolated causes.

## Change Boundary And Exact Owners

| Surface | Owner | Authorized responsibility |
| --- | --- | --- |
| `design.md` | `bubbles.design` | Reconcile the intake-provisional state model, applicable-universe contract, parser ownership, and state-transition parity. |
| `scopes.md`, `scenario-manifest.json`, `test-plan.json`, `uservalidation.md` | `bubbles.plan` | Reconcile the two-scope executable plan and all scenario/Test Plan/DoD mappings. |
| `tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | `bubbles.test` | Create final regression bytes and causal RED before implementation. |
| Traceability runtime source | `bubbles.implement` | Implement only the design-approved current-scope and DoD semantics. |
| State-transition Check 4A/22 parity | `bubbles.implement` after design reconciliation | Preserve all-scope behavior while repairing shared DoD boundaries. |
| Focused selftests and registration/provenance | `bubbles.test` | Add and execute complete adversarial coverage after causal RED. |
| Managed behavior documentation | `bubbles.docs` | Reconcile only behavior surfaces authorized by the final design. |
| Generated release identity | `bubbles.releases` | Reconcile stable final source/test/doc bytes. |
| Certification and terminal status | `bubbles.validate` | Independently certify only after complete evidence. |

This intake creates only this nine-file BUG-026 packet. It does not authorize
edits to production scripts, tests, release metadata, shared documentation,
sibling packets, Research Lab, or `improvements/INDEX.md`.

## Consumer Evidence Paths

- `/Users/pkirsanov/Projects/research-lab/specs/007-technical-analysis-decision-lab/state.json`
- `/Users/pkirsanov/Projects/research-lab/specs/007-technical-analysis-decision-lab/scopes/01-capability-foundation/report.md`
- `/Users/pkirsanov/Projects/research-lab/specs/007-technical-analysis-decision-lab/scopes/01-capability-foundation/scope.md`

## Related Framework Files

- `bubbles/scripts/traceability-guard.sh`
- `bubbles/scripts/state-transition-guard.sh`
- `bubbles/scripts/traceability-guard-selftest.sh`
- `bubbles/scripts/state-transition-guard-selftest.sh`
- `improvements/BUG-018-traceability-test-plan-heading-depth/`
- `tests/regression/test_25_traceability_test_plan_heading_depth.sh`
