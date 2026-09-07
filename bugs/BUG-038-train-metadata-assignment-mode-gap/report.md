# BUG-038 Report - Train Metadata Assignment Mode Gap

## Summary

Scope 1 planning is reconciled to direct-only mutation. Existing exact, wildcard, default-deny, and exclusion-aware grants govern mode admission. Apply requires the authenticated active top-level runner to be exactly `bubbles.train`, plus matching `release-train-state` ownership and mode-owned-field authority. Historical focused evidence below predates this contract and does not satisfy the new authorization scenarios. No implementation-completion claim is current.

## Decision Record

- One contract-only scope carries the complete metadata-only vertical slice.
- Wildcard admission is distinct from mutation authority. The current runtime cannot dispatch `bubbles.train` from a wildcard top-level runner, so wildcard mutation is refused.
- `BUBBLES_AGENT_NAME` is policy context only. It is not runner authentication or ownership proof.
- The ownership authority must continue to name `bubbles.train` as the sole `release-train-state` owner, and the mode must own every requested field.
- Canonical fields remain `releaseTrain` and optional `flagsIntroduced`; `releaseTrainRef` is not introduced.
- The source packet remains under `bugs/`; no persistent root `specs/` tree is permitted.
- Assignment owns no cut, promotion, rollback, retirement, build, pointer-swap, manifest mutation, or deployment semantics.
- BUG-037 and receipt-identity edits are excluded from this packet's change boundary.

## Completion Statement

Planning reconciliation is complete. Implementation and test completion are not claimed because the historical helper and grant checks encode the superseded sole-effective-grantee model and do not prove wildcard admission with direct-only mutation refusal, exclusion precedence, active-runner authentication, ownership mismatch refusal, or owned-field mismatch refusal. The scope and bug remain `in_progress`.

## Planning Reconciliation Status

The active plan requires 13 scenario contracts and 14 focused Test Plan rows. Prior evidence remains verbatim for audit integrity, but it is historical input only. In particular, lines asserting a sole direct runner grant or registry-derived denial of every non-train agent do not prove the reconciled architecture. They must not be used to mark any current DoD item complete.

Implementation handoff must add failing regressions for the direct-only matrix before changing source. No source test, framework validation, release readiness, manifest generation, staging, commit, or control-plane advancement occurred during this planning pass.

## Code Diff Evidence

**Claim Source:** interpreted from preserved executed evidence

The preserved implementation-phase `git status --short` and path-bounded `git diff` evidence classified BUG-038 changes within the approved registry, helper, test, agent, documentation, and packet families. Existing unrelated BUG-033, BUG-037, receipt-identity, execution-control, evidence-capture, state-snapshot, and state-transition changes remained present and were not attributed to BUG-038. This planning reconciliation changed only BUG-038 packet-owned planning, report, scenario, test-plan, and execution-state structure. It did not add a root `specs/` directory or change deployment, adapter, train-config, bundle, pointer, release-manifest, source, or test files.

## Bug Reproduction - Before Fix

**Claim Source:** executed

**Repository authority:** `rb:vscode-9031c5cf542a36002cef5e096a8d536f:82`

**Command:** bounded canonical mode-resolution checks from the Bubbles source root.

**Overall command exit:** 0. The harness expected the missing assignment lookup to exit 1 and printed `reproduction=confirmed` only for that result.

```text
existing train mode resolution:
release-train-cut
cut_exit=0
release-train-promote
promote_exit=0
release-train-rollback
rollback_exit=0
release-train-retire
retire_exit=0
release-train-status-all
status_exit=0
missing train metadata assignment resolution:
ERROR: no v5 alias matches v6 form 'ship action:assign target:train-metadata'
assignment_exit=1
reproduction=confirmed
```

## Interpretation

**Claim Source:** interpreted

The output proves that the canonical v7 resolver has routes for all five current train operations and no route for the narrowly named metadata assignment action.

Separate source inspection grounds the dead end:

- `bubbles/agent-ownership.yaml` reserves both state fields for `bubbles.train`.
- `bubbles/agent-capabilities.yaml` grants only cut, promote, rollback, retire, and all-train status.
- `bubbles/workflows/modes.yaml` defines no assignment mode.
- `bubbles/workflows/aliases.yaml` defines no assignment tuple.
- `agents/bubbles.train.agent.md` exposes no assignment action.
- `release-train-backfill-planner.sh` is advisory and cannot close the ownership gap.

## Downstream Context Boundary

**Claim Source:** interpreted

The operator supplied a QuantitativeFinance example where grounded release classification could not be persisted. That input motivated the investigation. It is not execution evidence for this source-repository packet.

## Packet Files

- `bugs/BUG-038-train-metadata-assignment-mode-gap/bug.md`
- `bugs/BUG-038-train-metadata-assignment-mode-gap/spec.md`
- `bugs/BUG-038-train-metadata-assignment-mode-gap/design.md`
- `bugs/BUG-038-train-metadata-assignment-mode-gap/scopes.md`
- `bugs/BUG-038-train-metadata-assignment-mode-gap/report.md`
- `bugs/BUG-038-train-metadata-assignment-mode-gap/uservalidation.md`
- `bugs/BUG-038-train-metadata-assignment-mode-gap/scenario-manifest.json`
- `bugs/BUG-038-train-metadata-assignment-mode-gap/test-plan.json`
- `bugs/BUG-038-train-metadata-assignment-mode-gap/state.json`

## Test Evidence

### Focused Reproduction

The before-fix resolver reproduction above executed in the current session and confirmed the missing route.

### Fix Tests

**Claim Source:** executed

Focused helper, sole-owner grant, alias compatibility, and Bash syntax tests ran after implementation. Detailed output appears in the scenario and lint sections below.

### Framework Validation

**Claim Source:** not-run

Framework validation did not run. The packet now includes workflow, grant, alias, agent, documentation, helper, and selftest changes. It makes no framework health claim.

### Release Readiness

**Claim Source:** not-run

Release readiness did not run. No release claim is made.

## Red-Before-Green Evidence

**Claim Source:** executed

**Phase:** implement

**Command:** `timeout 120 bash bubbles/scripts/release-train-metadata-assign-selftest.sh`

**Exit Code:** 1

```text
FAIL: exact v7 tuple did not resolve (got '')
FAIL: mode terminal contract is absent or incorrect
PASS: mode has no lifecycle, build, or deployment phase
FAIL: assignment grants are not owner-exact (got '')
FAIL: production helper is absent or not executable: /home/philipk/bubbles/bubbles/scripts/release-train-metadata-assign.sh
release-train-metadata-assign-selftest: FAIL (4 assertion(s))
```

The focused test existed and failed before any production or registry file changed. The failure names the missing tuple, mode contract, sole-owner grant, and helper.

## Scenario Contract Evidence

**Claim Source:** executed

**Phase:** implement

**Command:** direct sentinel-delimited execution of `timeout 120 bash bubbles/scripts/release-train-metadata-assign-selftest.sh`

**Exit Code:** 0

```text
BUG038_DIRECT_BEGIN
PASS: exact v7 tuple resolves to release-train-assign-metadata
PASS: mode has the bounded train_metadata_assigned terminal token
PASS: mode has no lifecycle, build, or deployment phase
PASS: bubbles.train is the sole direct runner grant
PASS: default dry-run changes train candidate and preserves omitted flags
PASS: default dry-run preserves destination bytes
PASS: apply without owner declaration refuses
PASS: apply without owner declaration names 'bubbles.train'
PASS: apply with wrong owner declaration refuses
PASS: apply with wrong owner declaration names 'bubbles.train'
PASS: exact owner applies existing train and explicit flags
PASS: apply preserves every non-owned state value semantically
PASS: atomic replacement preserves the destination file mode
PASS: assignment preserves config, bundles, generated output, manifest, and invokes no lifecycle tool
PASS: identical assignment is a byte-and-mtime preserving no-op
PASS: omitted flags preserve flagsIntroduced during apply
PASS: explicit empty flags array clears flagsIntroduced
PASS: invalid flags {"flag":true} refuses
PASS: invalid flags {"flag":true} names 'flags-json'
PASS: invalid flags {"flag":true} preserve destination bytes
PASS: invalid flags ["duplicate","duplicate"] refuses
PASS: invalid flags ["duplicate","duplicate"] names 'flags-json'
PASS: invalid flags ["duplicate","duplicate"] preserve destination bytes
PASS: invalid flags [""] refuses
PASS: invalid flags [""] names 'flags-json'
PASS: invalid flags [""] preserve destination bytes
PASS: invalid flags [1] refuses
PASS: invalid flags [1] names 'flags-json'
PASS: invalid flags [1] preserve destination bytes
PASS: unknown train refuses
PASS: unknown train names 'missing-train'
PASS: unknown train preserves bytes and leaves no candidate residue
PASS: duplicate train option refuses
PASS: duplicate train option names 'exactly once'
PASS: duplicate flags option refuses
PASS: duplicate flags option names 'at most once'
PASS: conflicting mode options refuses
PASS: conflicting mode options names 'mutually exclusive'
PASS: caller-controlled agent option refuses
PASS: caller-controlled agent option names 'unknown option'
PASS: extra positional target refuses
PASS: extra positional target names 'one target'
release-train-metadata-assign-selftest: PASS
BUG038_DIRECT_EXIT=0
```

This direct output covers TP-B038-01, TP-B038-02, TP-B038-03, TP-B038-04, TP-B038-06, and TP-B038-07. The prior evidence-capture attempt returned unrelated concurrent output and is intentionally not cited.

## Coverage Report

**Claim Source:** interpreted

Focused execution covers SCN-B038-001 through SCN-B038-006 and TP-B038-01 through TP-B038-09. TP-B038-10 and TP-B038-11 remain intentionally unrun, so no aggregate or release coverage claim is made.

## Lint/Quality

**Claim Source:** executed

**Authorization command:** process-group-isolated sentinel execution of `timeout 120 bash bubbles/scripts/workflow-runner-grants-lint-selftest.sh`

**Exit Code:** 0

```text
BUG038_GRANTS_ISOLATED_BEGIN
PASS: clean exit=0
PASS: clean emitted marker 'workflow-runner-grants-lint: PASS'
PASS: train metadata assignment has the sole bubbles.train grant
PASS: all non-train agents are denied metadata assignment by the registry-derived default-deny matrix
PASS: unknown-mode exit=1
PASS: unknown-mode emitted marker 'references unknown mode 'not-a-real-mode''
PASS: missing-grant exit=1
PASS: missing-grant emitted marker 'enables workflow execution without a grant'
PASS: non-orchestrator exit=1
PASS: non-orchestrator emitted marker 'must have class orchestrator'
PASS: ungranted-intent-route exit=1
PASS: ungranted-intent-route emitted marker 'intent route targets 'bubbles.validate' for ungranted mode'
PASS: nested-runner exit=1
PASS: nested-runner emitted marker 'nested workflow-runner dispatch found'
PASS: dual-role-invocation-blocked exit=1
PASS: dual-role-invocation-blocked emitted marker 'dual-role phase owner and MUST NOT set disable-model-invocation'
PASS: pure-runner-missing-flag exit=1
PASS: pure-runner-missing-flag emitted marker 'MUST set disable-model-invocation: true'
PASS: allowlist-names-pure-runner exit=1
PASS: allowlist-names-pure-runner emitted marker 'names a pure top-level runner'
PASS: auto-submitting-handoff exit=1
PASS: auto-submitting-handoff emitted marker 'auto-submitting handoff'
PASS: unknown-frontmatter-agent exit=1
PASS: unknown-frontmatter-agent emitted marker 'references unknown agent'
workflow-runner-grants-lint-selftest: PASS
BUG038_GRANTS_ISOLATED_EXIT=0
```

Two earlier authorization attempts exited 130 after concurrent terminal interference removed their temporary `unknown-mode.log`. They are invalidated runs, not implementation failures. Only the isolated exit-0 execution above supports the authorization claim.

**Alias command:** `timeout 120 bash bubbles/scripts/mode-alias-selftest.sh`

**Exit Code:** 0

```text
PASS: aliases.yaml parses and v5Aliases is non-empty
PASS: every v5 mode in workflows.yaml has an alias entry (62)
PASS: no alias entry refers to an unknown v5 mode
PASS: every primitive used by v5Aliases is one of the 15 canonical v6 primitives
PASS: every (primitive, tag-set) tuple is unique
PASS: every v6 form (primitive + tags) resolves back to its v5 mode (62 round-trips)
PASS: resolved-mode definitions match byte-for-byte between v5 and v6 invocation (14 (one per primitive; full set under BUBBLES_MODE_ALIAS_FULL_PARITY=1) pairs)
PASS: adversarial: resolver rejects unknown v6 primitive
PASS: adversarial: resolver rejects unknown tag for known primitive
PASS: BUG-038: exact train metadata assignment tuple resolves
PASS: BUG-038: five existing train aliases retain their targets
PASS: adversarial: resolver rejects duplicate (primitive, tag-set) tuple
PASS: every selftestExpectations row resolves to the documented v5 mode (5 rows)
PASS: every aliases.sh mode-alias target resolves (29 aliases)
PASS: every generated alias resolves to the exact runtime target (59 aliases)
PASS: every generated mode alias resolves to the exact runtime target (58 aliases)
mode-alias-selftest: PASS
```

**Syntax command:** `timeout 30 bash -n bubbles/scripts/release-train-metadata-assign.sh && timeout 30 bash -n bubbles/scripts/release-train-metadata-assign-selftest.sh && timeout 30 bash -n bubbles/scripts/mode-alias-selftest.sh && timeout 30 bash -n bubbles/scripts/workflow-runner-grants-lint-selftest.sh && echo "syntax_exit=0"`

**Exit Code:** 0

```text
syntax_exit=0
```

The focused helper selftest also exercised the same-directory portable `mktemp`, GNU/BSD file-mode fallback, shared portable mtime helper, byte identity, atomic rename, and absence of an internal `timeout` dependency. A separate `shellcheck` attempt was unavailable because no executable was resolved on `PATH`; it is not presented as passing evidence.

## Validation Summary

**Claim Source:** executed

Focused GREEN, sole-owner authorization, alias compatibility, and syntax checkpoints passed. Framework validation, release-manifest generation, release readiness, artifact lint, final transition validation, and certification did not run in this pass.

## Audit Verdict

**Claim Source:** not-run

The focused implementation checks pass. No aggregate, release, scope-completion, or certification verdict exists.

## Uncertainty Declarations

TP-B038-10 and TP-B038-11 remain unexecuted by explicit operator instruction. The scope therefore remains `in_progress`. `shellcheck` was unavailable on `PATH`; bounded Bash syntax and focused portability behavior did execute.

## Invocation Audit

The implementation pass invoked no subagents, did not commit, did not regenerate the release manifest, and did not run aggregate framework or release checks.

## Reconciled Direct-Only Authorization Implementation — Current Session

**Phase:** implement

**Claim Source:** executed

The reconciled authorization regression was run before production changes. It failed because the production helper rejected the newly required runner context.

**Command:** `timeout 240 bash bubbles/scripts/evidence-capture.sh --label 'BUG-038 reconciled authorization RED' -- timeout 180 bash bubbles/scripts/release-train-metadata-assign-selftest.sh`

**Exit Code:** 1

```text
# BUG-038 reconciled authorization RED
$ timeout 180 bash bubbles/scripts/release-train-metadata-assign-selftest.sh
exit: 2
lines: 5
sha256: 135fabe0741da0d95efee280383e4d4476f32d495b0d60bef7ee862fb64af5ab
PASS: exact v7 tuple resolves to release-train-assign-metadata
PASS: mode has the bounded train_metadata_assigned terminal token
PASS: mode has no lifecycle, build, or deployment phase
PASS: bubbles.train is the sole direct runner grant
release-train-metadata-assign: REFUSED: unknown option: --runner
```

The expanded focused suite passed after implementation. It covers exact and wildcard admission, exclusion precedence, default deny, missing and wrong runner refusal, environment spoof resistance, missing/duplicate/wrong ownership, requested-field ownership, dry-run, train and flag validation, atomic replacement, no-op identity, and the closed lifecycle side-effect boundary.

**Command:** `timeout 240 bash bubbles/scripts/evidence-capture.sh --label 'BUG-038 complete 13-scenario focused GREEN' -- timeout 180 bash bubbles/scripts/release-train-metadata-assign-selftest.sh`

**Exit Code:** 0

```text
# BUG-038 complete 13-scenario focused GREEN
$ timeout 180 bash bubbles/scripts/release-train-metadata-assign-selftest.sh
exit: 0
lines: 114
sha256: 2883d9537c1e8b0369aff36241e4ef674c6b8fe307ec5b5a42272a3aab40ea54
PASS: exact v7 tuple resolves to release-train-assign-metadata
PASS: mode has the bounded train_metadata_assigned terminal token
PASS: mode has no lifecycle, build, or deployment phase
PASS: bubbles.train is the sole direct runner grant
PASS: default dry-run changes train candidate and preserves omitted flags
PASS: default dry-run preserves destination bytes
PASS: explicit dry-run preserves destination bytes and creates no candidate
PASS: environment identity declaration alone refuses
PASS: missing authenticated runner refuses
PASS: wildcard-admitted non-train runner refuses
PASS: explicit exclusion over wildcard refuses
PASS: unregistered runner default deny refuses
PASS: wrong runner despite environment impersonation refuses
PASS: missing release-train-state owner refuses
PASS: duplicate release-train-state owner refuses
PASS: wrong release-train-state owner refuses
PASS: missing flagsIntroduced ownership refuses
PASS: malformed runner grant refuses
PASS: unsupported runner grant field refuses
PASS: malformed assignment mode refuses
PASS: exact owner applies existing train and explicit flags
PASS: apply preserves every non-owned state value semantically
PASS: atomic replacement preserves the destination file mode
PASS: assignment preserves config, bundles, generated output, manifest, and invokes no lifecycle tool
PASS: identical assignment is a byte-and-mtime preserving no-op
PASS: omitted flags preserve flagsIntroduced during apply
PASS: explicit empty flags array clears flagsIntroduced
PASS: unknown train preserves bytes and leaves no candidate residue
PASS: duplicate runner option refuses
release-train-metadata-assign-selftest: PASS
```

The mode resolver confirmed the persisted `bugfix-fastlane` mode has `statusCeiling: done`. The first focused grant-policy execution was replaced by unrelated concurrent BUG-039 output. A direct retry also executed unrelated BUG-039 traceability work and exited 1. The alias and combined syntax command was interrupted by concurrent terminal input. None of those contaminated or interrupted commands is claimed as passing evidence. The scope remains `in_progress` pending clean focused grant, alias, portability, and downstream validation evidence.

## Delegated Verification Addendum

**Claim Source:** executed

The refreshed packet validated against external session control at revision 7 with decision `rb:vscode-c1ccf1f664629b678cdfef54fed5c541:7:node:bubbles-patch-convergence`. No repository-binding preflight ran in this delegated task.

The operator-provided historical red-output reference is SHA-256 `70b54ebd667b71d50467eac0c1ab7f1309e4f671a9faa662115f9cde11bce71a`. Current implementation bytes were SHA-256 `fa8ab3ad5275c15220695d271352c949da60fad5c9b95d625b12d23ddb5cbb44`; current focused-selftest bytes were SHA-256 `4da28e42fa8040f8ec4de2e9465025631cc994da0459f974815a0118a1`. Both new shell files passed `bash -n` with exit 0.

## Independent Test Verification — 2026-09-02

**Phase:** test

**Claim Source:** executed

The independent test phase ran only the focused Bug 038 checks authorized by the operator. It did not run aggregate framework validation, release-manifest generation, or release readiness.

### Scenario Reference Resolution

**Claim Source:** executed

**Executed:** YES (in current session)

**Command:** `timeout 30 bash bubbles/scripts/evidence-capture.sh --label 'BUG-038 scenario test resolution' -- bash bubbles/scripts/scenario-test-resolve.sh bugs/BUG-038-train-metadata-assignment-mode-gap`

**Exit Code:** 0

```text
# BUG-038 scenario test resolution
$ bash bubbles/scripts/scenario-test-resolve.sh bugs/BUG-038-train-metadata-assignment-mode-gap
exit: 0
lines: 1
sha256: 0147bd502dd83e7a81603fbd6be0ae050873eb06d1f9e6e434cdc29990ef0237
--- output ---
[scenario-test-resolve] OK — 3 reference(s) resolved via literal-scan
```

**Result:** PASS

### Focused Metadata Assignment Regression

**Claim Source:** executed

**Executed:** YES (in current session)

**Command:** `TMPDIR=/tmp timeout 120 bash bubbles/scripts/evidence-capture.sh --label 'BUG-038 focused metadata assignment selftest' -- bash bubbles/scripts/release-train-metadata-assign-selftest.sh`

**Exit Code:** 0

```text
# BUG-038 focused metadata assignment selftest
$ bash bubbles/scripts/release-train-metadata-assign-selftest.sh
exit: 0
lines: 48
sha256: 8eb07a5c6e4d0af05f3eca985763268cb10f8cc65bc2e2c1d3b42e37142630bb
--- first 20 ---
PASS: exact v7 tuple resolves to release-train-assign-metadata
PASS: mode has the bounded train_metadata_assigned terminal token
PASS: mode has no lifecycle, build, or deployment phase
PASS: bubbles.train is the sole direct runner grant
release-train-metadata-assign: dry-run candidate for train 'beta': /tmp/bubbles-train-metadata.QFgzas/repo/specs/001-fixture/state.json
PASS: default dry-run changes train candidate and preserves omitted flags
PASS: default dry-run preserves destination bytes
PASS: apply without owner declaration refuses
PASS: apply without owner declaration names 'bubbles.train'
PASS: apply with wrong owner declaration refuses
PASS: apply with wrong owner declaration names 'bubbles.train'
release-train-metadata-assign: applied metadata assignment for train 'beta': /tmp/bubbles-train-metadata.QFgzas/repo/specs/001-fixture/state.json
PASS: exact owner applies existing train and explicit flags
PASS: apply preserves every non-owned state value semantically
PASS: atomic replacement preserves the destination file mode
PASS: assignment preserves config, bundles, generated output, manifest, and invokes no lifecycle tool
release-train-metadata-assign: idempotent no-op for train 'beta': /tmp/bubbles-train-metadata.QFgzas/repo/specs/001-fixture/state.json
PASS: identical assignment is a byte-and-mtime preserving no-op
release-train-metadata-assign: applied metadata assignment for train 'alpha': /tmp/bubbles-train-metadata.QFgzas/repo/specs/001-fixture/state.json
PASS: omitted flags preserve flagsIntroduced during apply
--- omitted 8 line(s); sha256 above covers the full output ---
--- last 20 ---
PASS: invalid flags [""] refuses
PASS: invalid flags [""] names 'flags-json'
PASS: invalid flags [""] preserve destination bytes
PASS: invalid flags [1] refuses
PASS: invalid flags [1] names 'flags-json'
PASS: invalid flags [1] preserve destination bytes
PASS: unknown train refuses
PASS: unknown train names 'missing-train'
PASS: unknown train preserves bytes and leaves no candidate residue
PASS: duplicate train option refuses
PASS: duplicate train option names 'exactly once'
PASS: duplicate flags option refuses
PASS: duplicate flags option names 'at most once'
PASS: conflicting mode options refuses
PASS: conflicting mode options names 'mutually exclusive'
PASS: caller-controlled agent option refuses
PASS: caller-controlled agent option names 'unknown option'
PASS: extra positional target refuses
PASS: extra positional target names 'one target'
release-train-metadata-assign-selftest: PASS
```

**Result:** PASS

### Runner Grant Compatibility

**Claim Source:** executed

**Executed:** YES (in current session)

**Command:** `timeout 120 bash bubbles/scripts/workflow-runner-grants-lint-selftest.sh`

**Exit Code:** 0

```text
PASS: clean exit=0
PASS: clean emitted marker 'workflow-runner-grants-lint: PASS'
PASS: train metadata assignment has the sole bubbles.train grant
PASS: all non-train agents are denied metadata assignment by the registry-derived default-deny matrix
PASS: unknown-mode exit=1
PASS: unknown-mode emitted marker 'references unknown mode 'not-a-real-mode''
PASS: missing-grant exit=1
PASS: missing-grant emitted marker 'enables workflow execution without a grant'
PASS: non-orchestrator exit=1
PASS: non-orchestrator emitted marker 'must have class orchestrator'
PASS: ungranted-intent-route exit=1
PASS: ungranted-intent-route emitted marker 'intent route targets 'bubbles.validate' for ungranted mode'
PASS: nested-runner exit=1
PASS: nested-runner emitted marker 'nested workflow-runner dispatch found'
PASS: dual-role-invocation-blocked exit=1
PASS: dual-role-invocation-blocked emitted marker 'dual-role phase owner and MUST NOT set disable-model-invocation'
PASS: pure-runner-missing-flag exit=1
PASS: pure-runner-missing-flag emitted marker 'MUST set disable-model-invocation: true'
PASS: allowlist-names-pure-runner exit=1
PASS: allowlist-names-pure-runner emitted marker 'names a pure top-level runner'
PASS: auto-submitting-handoff exit=1
PASS: auto-submitting-handoff emitted marker 'auto-submitting handoff'
PASS: unknown-frontmatter-agent exit=1
PASS: unknown-frontmatter-agent emitted marker 'references unknown agent'
workflow-runner-grants-lint-selftest: PASS
```

**Result:** PASS

### Alias Compatibility

**Claim Source:** executed

**Executed:** YES (in current session)

**Command:** `timeout 120 bash bubbles/scripts/mode-alias-selftest.sh`

**Exit Code:** 0

```text
PASS: aliases.yaml parses and v5Aliases is non-empty
PASS: every v5 mode in workflows.yaml has an alias entry (62)
PASS: no alias entry refers to an unknown v5 mode
PASS: every primitive used by v5Aliases is one of the 15 canonical v6 primitives
PASS: every (primitive, tag-set) tuple is unique
PASS: every v6 form (primitive + tags) resolves back to its v5 mode (62 round-trips)
PASS: resolved-mode definitions match byte-for-byte between v5 and v6 invocation (14 (one per primitive; full set under BUBBLES_MODE_ALIAS_FULL_PARITY=1) pairs)
PASS: adversarial: resolver rejects unknown v6 primitive
PASS: adversarial: resolver rejects unknown tag for known primitive
PASS: BUG-038: exact train metadata assignment tuple resolves
PASS: BUG-038: five existing train aliases retain their targets
PASS: adversarial: resolver rejects duplicate (primitive, tag-set) tuple
PASS: every selftestExpectations row resolves to the documented v5 mode (5 rows)
PASS: every aliases.sh mode-alias target resolves (29 aliases)
PASS: every generated alias resolves to the exact runtime target (59 aliases)
PASS: every generated mode alias resolves to the exact runtime target (58 aliases)
mode-alias-selftest: PASS
```

**Result:** PASS

### Syntax And Cross-Platform Portability

**Claim Source:** executed

**Executed:** YES (in current session)

**Commands:**

- `timeout 30 bash -n bubbles/scripts/release-train-metadata-assign.sh`
- `timeout 30 bash -n bubbles/scripts/release-train-metadata-assign-selftest.sh`
- `timeout 120 bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/release-train-metadata-assign.sh bubbles/scripts/release-train-metadata-assign-selftest.sh`

**Exit Codes:** 0, 0, 0

```text
# BUG-038 assignment helper syntax
$ bash -n bubbles/scripts/release-train-metadata-assign.sh
exit: 0
lines: 0
sha256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
--- output ---
# BUG-038 assignment selftest syntax
$ bash -n bubbles/scripts/release-train-metadata-assign-selftest.sh
exit: 0
lines: 0
sha256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
--- output ---
== macOS portability guard -- scanning 2 file(s) ==
ok   class-1 raw-timeout: none
ok   class-2 in-place-sed: none
ok   class-3 date-d-parse: none
ok   class-4 stat-c-mtime: none
ok   class-5 readlink-f-absolutize: none
ok   class-6 grep-pcre: none
ok   class-7 bracket-v-isset: none
ok   class-8 mapfile-readarray: none
ok   class-9 mktemp-suffix: none
ok   class-10 df-output: none
ok   class-11 bin-true-false: none
ok   class-12 paste-no-stdin-operand: none
ok   class-13 date-nanoseconds: none
ok   class-14 mktemp-parent-dir: none
ok   class-15 mktemp-nontrailing-x: none
ok   class-16 awk-3arg-match: none
PASS: the scanned surface is WSL+macOS portable.
```

**Result:** PASS

### Artifact Lint

**Claim Source:** executed

**Executed:** YES (in current session)

**Command:** `timeout 120 bash bubbles/scripts/artifact-lint.sh bugs/BUG-038-train-metadata-assignment-mode-gap`

**Exit Code:** 0

```text
✅ Required artifact exists: spec.md
✅ Required artifact exists: design.md
✅ Required artifact exists: uservalidation.md
✅ Required artifact exists: state.json
✅ Required artifact exists: scopes.md
✅ Required artifact exists: report.md
✅ No forbidden sidecar artifacts present
✅ Found DoD section in scopes.md
✅ scopes.md DoD contains checkbox items
✅ All DoD bullet items use checkbox syntax in scopes.md
✅ Found Checklist section in uservalidation.md
✅ uservalidation checklist contains checkbox entries
✅ All checklist bullet items use checkbox syntax
✅ uservalidation separates automation readiness from human acceptance
✅ Detected state.json status: in_progress
✅ Detected state.json workflowMode: bugfix-fastlane
✅ state.json v3 has required field: status
✅ state.json v3 has required field: execution
✅ state.json v3 has required field: certification
✅ state.json v3 has required field: policySnapshot
✅ state.json v3 has recommended field: transitionRequests
✅ state.json v3 has recommended field: reworkQueue
✅ state.json v3 has recommended field: executionHistory
✅ Top-level status matches certification.status
ℹ️  Workflow mode 'bugfix-fastlane' allows status 'done'; current status is 'in_progress'
✅ report.md contains section matching: ###[[:space:]]+Summary|^##[[:space:]]+Summary
✅ report.md contains section matching: ###[[:space:]]+Completion Statement|^##[[:space:]]+Completion Statement
✅ report.md contains section matching: ###[[:space:]]+Test Evidence|^##[[:space:]]+Test Evidence
✅ Mode-specific report gates skipped (status not in promotion set)
✅ Value-first selection rationale lint skipped (not a value-first report)
✅ Scenario path-placeholder lint skipped (no matching scenario sections found)
=== Anti-Fabrication Evidence Checks ===
✅ All checked DoD items in scopes.md have evidence blocks
✅ No unfilled evidence template placeholders in scopes.md
✅ No unfilled evidence template placeholders in report.md
=== End Anti-Fabrication Checks ===
Artifact lint PASSED.
```

**Result:** PASS

### Scenario And Negative-Control Accounting

**Claim Source:** interpreted

**Interpretation:** The scenario manifest and test plan map the six scenario IDs to the persistent files named below; the sensitivity column is grounded in the independently executed outputs recorded above.

| Scenario | Persistent proof | Sensitivity demonstrated by executed output |
|---|---|---|
| SCN-B038-001 | `release-train-metadata-assign-selftest.sh` | Dry-run byte preservation, exact-owner apply, semantic non-owner equality, mode preservation, and idempotent no-op all passed. |
| SCN-B038-002 | `release-train-metadata-assign-selftest.sh` | The unknown-train perturbation refused, named `missing-train`, preserved bytes, and left no candidate residue. |
| SCN-B038-003 | `release-train-metadata-assign-selftest.sh` | Configuration, bundle, generated-output, and manifest sentinels retained identity while assignment succeeded. |
| SCN-B038-004 | `release-train-metadata-assign-selftest.sh` | The executed mode-phase and side-effect assertions found no lifecycle, build, deployment, or lifecycle-tool behavior. |
| SCN-B038-005 | `workflow-runner-grants-lint-selftest.sh` and `mode-alias-selftest.sh` | The non-owner default-deny matrix and malformed-grant mutations exited nonzero while the sole owner and compatibility controls passed. |
| SCN-B038-006 | `release-train-metadata-assign-selftest.sh` | Omitted, empty, valid, malformed, duplicate, conflicting, caller-controlled, and extra-target inputs exercised distinct success or refusal outcomes. |

All six scenario IDs therefore have persistent test-plan coverage, and every declared negative-control class produced a discriminating executed outcome. No focused command printed `SKIP`, reported a skipped test, or exited nonzero.

### Independent Test Verdict

**Claim Source:** executed

The focused Bug 038 test selection passed with zero observed skips. TP-B038-10 and TP-B038-11 remain deliberately not run. Aggregate validation and release readiness are still required before certification, so this test phase routes to `bubbles.validate` and does not claim scope or bug completion.

## Focused Validate-Owned Certification Pass — 2026-09-02

**Claim Source:** interpreted

**Interpretation:** The declared Success Signal is: `bubbles.train` assigns a declared train without changing train configuration, bundles, manifests, or release lifecycle state. The current-session focused assignment selftest exited 0 and explicitly reported exact-owner assignment, semantic preservation of non-owned state, unchanged configuration/bundle/generated-output/manifest sentinels, and no lifecycle-tool invocation. This demonstrates the focused observable signal, but it does not replace the prohibited aggregate framework and release checks.

### Current-Session Command Evidence

**Claim Source:** executed

| Gate | Command | Exit | Result |
| --- | --- | ---: | --- |
| Repository packet | `repository-binding.sh validate-packet` against control revision 5 | 0 | PASS |
| Artifact shape | `artifact-lint.sh bugs/BUG-038-train-metadata-assignment-mode-gap` | 0 | PASS |
| Scenario references | `scenario-test-resolve.sh bugs/BUG-038-train-metadata-assignment-mode-gap` | 0 | PASS |
| Packet traceability | `traceability-guard.sh bugs/BUG-038-train-metadata-assignment-mode-gap` | 0 | PASS |
| Focused assignment behavior | `release-train-metadata-assign-selftest.sh` | 0 | PASS; 76 captured lines, SHA-256 `a19368efca157520294543eb0a8dd7949e695cba8610ad70e9693a3d3e799833` |
| Sole-owner grants | `workflow-runner-grants-lint-selftest.sh` | 0 | PASS |
| Mode and alias compatibility | `mode-alias-selftest.sh` | 0 | PASS |
| Goal fidelity | `goal-fidelity-guard.sh --boundary pre-certification ...` | 0 after this addendum | PASS |
| Artifact freshness | `artifact-freshness-guard.sh bugs/BUG-038-train-metadata-assignment-mode-gap` | 0 | PASS; zero failures and zero warnings |
| Implementation reality | `implementation-reality-scan.sh ... --verbose` | 0 | PASS with one warning: scope discovery fell back to `design.md` |
| Transition contract | `transition-contract-resolver.sh bugs/BUG-038-train-metadata-assignment-mode-gap` | 0 | PASS; `bugfix-fastlane`, target `done`, delivery audit required |
| State transition | `state-transition-guard.sh bugs/BUG-038-train-metadata-assignment-mode-gap` | 1 | FAIL; 25 failures, six failed gates |
| Aggregate framework validation | prohibited by the focused operator boundary | not run | UNRUN |
| Release-manifest regeneration | prohibited by the focused operator boundary | not run | UNRUN |
| Release readiness | prohibited by the focused operator boundary | not run | UNRUN |
| Human implementation acceptance | no acceptance record exists | not run | BLOCKED |

### Certification Disposition

**Claim Source:** interpreted

BUG-038 remains `in_progress`. Focused behavior, authorization, alias compatibility, artifact shape, and traceability pass. Terminal certification is blocked by TP-B038-10, TP-B038-11, and missing human implementation acceptance. The next owner is the aggregate workflow owner for framework validation, release-manifest regeneration, and release readiness, followed by human acceptance and a fresh validate-owned transition check.

### Transition Guard Result

**Claim Source:** executed

The current-session transition guard produced SHA-256 `9ee8c2329f0050b41e454d0dfd55046b7737fdf9976fdd381b4426a29351ae0f`, exit 1, `failureCount: 25`, and `blockingCode: DELIVERY_COMPLETION_FAILED`. Failed gates were `G055`, `G041`, `G022`, `G053`, `G027`, and `G136`. No certification field was advanced.

## Planning Artifact Correction — Full-Delivery Convergence Iteration 10

**Phase:** plan

**Claim Source:** current-session source inspection and planning checks

SCN-B038-003 requires two complementary persistent proofs. `workflow-runner-grants-lint-selftest.sh` directly exercises the production admission evaluator with a wildcard grant plus an explicit `release-train-assign-metadata` exclusion. `release-train-metadata-assign-selftest.sh` drives the production assignment helper through that excluded runner and separately verifies that `state.json` bytes remain unchanged. Neither test alone proves the complete Given/When/Then contract.

The corrected mapping keeps one scenario, one Test Plan row, and one matching DoD item. TP-B038-03 now requires both selftests in a single composite command. The scenario manifest links both files and assigns both the admission and no-mutation obligations to TP-B038-03. This preserves the 14-row Test Plan/DoD parity while strengthening semantic identity.

No source or test command was executed as behavior evidence during this planning correction. Historical test output remains historical. The only current-session executions are repository-packet validation and the planning checks recorded below.

### Current-Session Planning Checks

| Check | Command | Exit | Result |
| --- | --- | ---: | --- |
| Repository packet | `timeout 30 bash bubbles/scripts/repository-binding.sh validate-packet --session-id vscode-de65b1c933fd575a7b21798ea16c2028 --session-control-file /run/user/1000/bubbles/repository-binding/vscode-de65b1c933fd575a7b21798ea16c2028/repository-binding.json --packet-file /tmp/bug-038-repository-packet.json` | 0 | The supplied packet validated as actionable for the Bubbles root at control revision 1. |
| JSON syntax | `timeout 30 jq empty bugs/BUG-038-train-metadata-assignment-mode-gap/scenario-manifest.json bugs/BUG-038-train-metadata-assignment-mode-gap/test-plan.json bugs/BUG-038-train-metadata-assignment-mode-gap/state.json` | 0 | All changed JSON planning artifacts parse. |
| Artifact lint | `timeout 120 bash bubbles/scripts/artifact-lint.sh bugs/BUG-038-train-metadata-assignment-mode-gap` | 0 | Packet shape and nonterminal anti-fabrication checks pass. |
| Linked-test resolution | `timeout 120 bash bubbles/scripts/scenario-test-resolve.sh bugs/BUG-038-train-metadata-assignment-mode-gap` | 0 | Fourteen authored linked-test references resolve. |
| Traceability | `timeout 120 bash bubbles/scripts/traceability-guard.sh bugs/BUG-038-train-metadata-assignment-mode-gap` | 0 | Thirteen scenarios map to thirteen Test Plan rows and thirteen DoD items with zero warnings. |

BUG-038 remains `in_progress`. The next required owner remains `bubbles.test`. No new convergence iteration, certification transition, commit, push, reset, clean, source change, test change, or cross-repository change occurred.

## Routed ShellCheck Test Remediation - Current Session

**Phase:** test

**Claim Source:** executed

This test-owned slice addressed the three BUG-050 regression findings routed to BUG-038. It removed the unused `ALIASES_FILE`, `OWNERSHIP_FILE`, and `drift_before` assignments from `bubbles/scripts/release-train-metadata-assign-selftest.sh`. No suppression, severity change, production change, or behavioral assertion was removed.

The first complete post-edit selftest exposed a macOS-only observation defect in the existing file-mode assertion. The helper had preserved numeric mode `640`, while `/bin/ls` rendered the symbolic token as `-rw-r-----@` because the replaced file carried `com.apple.provenance`. The test now checks numeric mode through the same GNU/BSD `stat` fallback used by the production helper. The complete selftest then passed without weakening the `640` requirement.

### Focused ShellCheck RED And GREEN

**Claim Source:** executed

```text
# BUG-038 routed ShellCheck warning RED
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=5s 60 shellcheck -S warning -f gcc bubbles/scripts/release-train-metadata-assign-selftest.sh
exit: 1
lines: 3
sha256: bcecdebeb43a232b51ce1cfcc1cec27700ab4d575f5597239589b09a424aeb67
bubbles/scripts/release-train-metadata-assign-selftest.sh:11:1: warning: ALIASES_FILE appears unused. Verify use (or export if used externally). [SC2034]
bubbles/scripts/release-train-metadata-assign-selftest.sh:14:1: warning: OWNERSHIP_FILE appears unused. Verify use (or export if used externally). [SC2034]
bubbles/scripts/release-train-metadata-assign-selftest.sh:413:3: warning: drift_before appears unused. Verify use (or export if used externally). [SC2034]
# BUG-038 final focused ShellCheck after portable mode repair
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=5s 60 shellcheck -S warning -f gcc bubbles/scripts/release-train-metadata-assign-selftest.sh
exit: 0
lines: 0
sha256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
```

### Complete Assignment Selftest

**Claim Source:** executed

The first complete run exited 1 with 114 captured lines and SHA-256 `e70261fdd97633f44f1917b2039413ba27f14e1da8ff3d81a2e26964829b3fd3`. Its sole failure was `FAIL: atomic replacement changed destination file mode`. Two disposable probes then observed symbolic `-rw-r-----@` and numeric `640`, grounding the portable test-observation repair.

```text
# BUG-038 complete assignment selftest after portable mode repair
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=10s 180 /opt/homebrew/bin/bash bubbles/scripts/release-train-metadata-assign-selftest.sh
exit: 0
lines: 114
sha256: cfc89a7a8087ecff42455c1d440b6179ce199db9f95bb36ae14ab146cbc851a5
PASS: exact v7 tuple resolves to release-train-assign-metadata
PASS: default dry-run preserves destination bytes
PASS: wildcard-admitted refusal preserves destination bytes
PASS: explicit exclusion preserves destination bytes
PASS: environment impersonation refusal preserves destination bytes
PASS: atomic replacement preserves the destination file mode
PASS: replacement-time drift is preserved instead of overwritten
PASS: assignment preserves config, bundles, generated output, manifest, and invokes no lifecycle tool
PASS: identical assignment is a byte-and-mtime preserving no-op
PASS: unknown train preserves bytes and leaves no candidate residue
release-train-metadata-assign-selftest: PASS
```

### Linked Mechanisms And Traceability

**Claim Source:** executed

```text
scenario-test-resolve: exit=0; 14 reference(s) resolved via literal-scan; sha256=4e029abe95a9a334c2fa4a0dae92ca723db7058580b2768dbe148616c10b1b5c
workflow-runner-grants-lint-selftest: exit=0; lines=33; sha256=30a81a4a9b8800a789747d60b44cce7a01c908c03e9dcce76c609f1ce6b51985
PASS: wildcard-admission evaluator emitted marker 'admitted by wildcard grant'
PASS: exclusion-precedence evaluator emitted marker 'explicitly excluded'
PASS: default-denial evaluator emitted marker 'denied by default'
mode-alias-selftest: exit=0; lines=17; sha256=c5470d12ad19baf84a095efc8ec05a3e2f007fed6863b67ed66167aec03c84d9
PASS: BUG-038: exact train metadata assignment tuple resolves
PASS: BUG-038: five existing train aliases retain their targets
traceability-guard: exit=0; lines=119; sha256=e74ef3649db9e00a17dd8785294581f4875ee6bda0d504da6cea2017003f03ea
Scenarios checked: 13
Test rows checked: 14
Edge confidence: declared=26 inferred=0 ambiguous=0
RESULT: PASSED (0 warnings)
```

### Changed-Test Quality And Repository ShellCheck

**Claim Source:** executed

```text
SELFTEST_SYNTAX_EXIT=0
macOS portability guard: PASS; 16 portability classes clean
SELFTEST_PORTABILITY_EXIT=0
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 1
Files with adversarial signals: 1
SELFTEST_REGRESSION_QUALITY_EXIT=0
# BUG-038 repository ShellCheck lint after routed remediation
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=10s 780 /opt/homebrew/bin/bash bubbles/scripts/shellcheck-lint.sh
exit: 0
lines: 1
sha256: ab177e5a066145010668821ec9167f18e9e06968ccca9b42264b597add16cac9
shellcheck-lint: PASS - 605 script(s) clean at -S warning
```

### Release Manifest Regeneration And Freshness

**Claim Source:** executed

```text
# BUG-038 release manifest regeneration after test change
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=10s 240 /opt/homebrew/bin/bash bubbles/scripts/generate-release-manifest.sh
exit: 0
lines: 1
sha256: 9dba3ba137c0c0a6ad997d8dc69483ae6a2ed8fea003e3a934a02bba19728899
Updated release manifest: 7.29.0 (980 managed files)
# BUG-038 release manifest freshness after test change
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=10s 240 /opt/homebrew/bin/bash bubbles/scripts/generate-release-manifest.sh --check
exit: 0
lines: 1
sha256: 3107222d9960d0b8e46679a81e1503f39d2f87de4b0abd2998fdd55aad7a221b
Release manifest is current: 7.29.0 (980 managed files)
```

### Nonterminal Boundary

**Claim Source:** interpreted

**Interpretation:** The commands above prove the routed warning remediation, the unchanged focused behavior, the linked grant and alias mechanisms, traceability, portability, regression quality, and repository ShellCheck cleanliness. This narrow slice does not claim that the 14-row BUG-038 plan was independently executed as a completion sweep. It does not satisfy human acceptance, aggregate framework validation, release readiness, or validate-owned certification. BUG-038 and Scope 1 remain `in_progress`, every DoD checkbox remains unchanged, and the next required owner remains `bubbles.test` for the complete independent Test Plan run.
