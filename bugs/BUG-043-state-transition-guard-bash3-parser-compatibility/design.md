# BUG-043 Design - Bash Parser Compatibility

## Design Brief

### Current State

The origin-matching transition guard passes Bash 5.3 syntax validation.
The same bytes fail Bash 3.2 syntax validation at the Check 16 heading.

The reported line is a recovery point, not the defect origin.
Check 16 parses independently under both interpreters.

### Target State

The complete guard must parse under Bash 3.2 and Bash 5.3.
Supported-runtime transition behavior must remain unchanged.

The repair must remove the parser-sensitive quoting context.
It must not remove or rewrite executable Check 7C logic.

### Patterns to Follow

- Keep the repair in the canonical [transition guard](../../bubbles/scripts/state-transition-guard.sh).
- Extend the existing [Bash baseline selftest](../../bubbles/scripts/bash-baseline-guard-selftest.sh).
- Preserve semantic coverage in the [transition guard selftest](../../bubbles/scripts/state-transition-guard-selftest.sh).
- Regenerate the release manifest through the existing generator.
- Verify downstream bytes through the existing installer selftests.

### Patterns to Avoid

- Do not edit the Check 16 heading. It parses independently under Bash 3.2.
- Do not reword one Python comment as the primary repair. That leaves the parser-sensitive context intact.
- Do not rewrite Check 7C. Its claim-backing behavior is unrelated to the parser defect.
- Do not treat Bash 3.2 parse support as Bash 3.2 runtime support.
- Do not patch a downstream installed copy.

### Resolved Decisions

- The first failing complete source region is Check 7C.
- The first offending token is the apostrophe in `Check 6B's _phase_name`.
- The apostrophe sits inside a quoted Python heredoc nested in a double-quoted command substitution.
- The selected repair removes the redundant outer assignment quotes.
- The selected repair changes two shell quote characters and no heredoc bytes.
- The regression executes a source-derived sentinel beyond the former recovery boundary.
- The exact pre-fix quote form is the adversarial mutant.

### Open Questions

None found. Planning must still absorb the sentinel contract before test mutation.

## Purpose and Scope

This design resolves the parser root cause for the frozen source revision.
It selects the smallest durable shell edit that removes the incompatible context.

This phase changes no production source or test.
It also leaves all certification fields unchanged.

<a id="exact-investigation"></a>

## Root-Cause Analysis

### Frozen Source Identity

The worktree `HEAD` and `origin/main` both resolve to
`830883fd5639ac066cb3d40a2a40a567cc3df22f`.

The worktree and origin object for the transition guard both resolve to
`2665c6e34ec9a9876e0c48d96897988500a8a742`.
The file SHA-256 is
`1f42f6d5a96a464fd622c2d39b341eed07967499a9fb4869b6752d13d75367b0`.

### Observed Parser Divergence

The macOS system interpreter is Bash 3.2.57.
It rejects the complete source with exit 2.

The Homebrew interpreter is Bash 5.3.15.
It accepts the same source with exit 0.

Bash 3.2 reports the failure at baseline line 4016.
That line is the quoted Check 16 heading.
The complete Check 16 region parses independently under Bash 3.2.

### Earliest Failing Complete Region

A cumulative prefix ending before Check 7C parses under both interpreters.
That prefix ends at baseline line 2714.

A cumulative prefix that includes complete Check 7C fails under Bash 3.2.
The same prefix passes under Bash 5.3.

Check 7C also fails when parsed as an independent complete shell unit.
Replacing only its heredoc assignment makes that unit parse under both interpreters.

### Earliest Offending Construct

This assignment creates the failing context:

```bash
claim_backing_analysis="$(python3 - "$state_file" <<'PY'
```

Its quoted Python heredoc contains this baseline line 2756 comment:

```python
# reported NO_CLAIMS and passed. Check 6B's _phase_name already normalises
```

The apostrophe after `6B` is the first offending token.
A heredoc-body prefix through line 2755 parses under Bash 3.2.
Adding line 2756 changes the Bash 3.2 result to exit 2.

An isolated Check 7C fixture with that exact line also exits 2 under Bash 3.2.
Removing only that apostrophe makes the isolated fixture parse.

The apostrophe is Python comment text, not shell logic.
Bash 3.2 nevertheless tokenizes it inside the outer double-quoted command substitution.
Its diagnostic initially reports an unmatched single quote.

Later source text changes the parser recovery state.
The next visible recovery point is the parenthesis in the Check 16 heading.
Editing that heading would only hide the symptom.

### Introducing Revision

Git blame assigns the offending comment to
`5ea651a6dfdf519761a0a938d4e5d6fbf7a21fdc`.
That revision is titled `fix(guard): Check 7C was inert against the claim shape packets actually write`.

Its parent is `52317c2c1a62bdff9c4af1b5bbe62cdb0a1ae23d`.
The parent guard parses under Bash 3.2 and Bash 5.3.
The introducing revision fails Bash 3.2 and passes Bash 5.3.

### Impact Analysis

- **Affected component:** the source and installed transition guard.
- **Affected operation:** syntax parsing before any guard check runs.
- **Affected consumers:** macOS callers using the system Bash parser.
- **Integrity risk:** a direct downstream patch would diverge from install provenance.

## Fix Design

### Selected Repair

Remove the redundant outer quotes around the Check 7C assignment command substitution.
Keep every heredoc byte unchanged.

Current form:

```bash
claim_backing_analysis="$(python3 - "$state_file" <<'PY'
...
PY
)"
```

Selected form:

```bash
claim_backing_analysis=$(python3 - "$state_file" <<'PY'
...
PY
)
```

This edit removes exactly two quote characters.
Assignment context already preserves command-substitution output as one assignment value.
No word splitting or pathname expansion applies to that assignment value.

The Python program remains byte-identical.
The Check 7C branches remain byte-identical.
The emitted `claim_backing_analysis` value remains unchanged under Bash 5.3.

The current-state diagnostic produced `NO_CLAIMS=1` before and after the candidate transformation.
Both Bash 5.3 runs exited zero with byte-identical output.

### Why Comment Rewording Is Not Selected

Rewording `Check 6B's` also makes the current file parse.
That change treats one payload token instead of the parser-sensitive shell context.

A later apostrophe in the same heredoc could recreate the defect.
Removing the redundant outer quotes eliminates that hazard class for this assignment.

### Single-Implementation Justification

This is a two-character repair inside one existing guard path.
It adds no provider, adapter, variant, shared contract, or reusable capability.
A capability foundation would add structure without removing any real variation.

## Architecture and Control Flow

The guard architecture does not change.
Check 7C still invokes the same Python analysis with the same state path.

The subprocess still returns the same text into `claim_backing_analysis`.
The existing shell branches still interpret that text.

No transition gate moves.
No applicability rule changes.
No error or warning changes severity.

## Data Model and Storage

None found. The repair changes no state schema, persisted field, or storage path.

## API and Error Model

None found. The repair changes no command argument, output contract, or exit code.

Parser diagnostics remain test observations only.
The production guard retains its existing structured transition result.

## Security and Compliance

The fix introduces no bypass or fallback.
It does not weaken Check 7C claim-backing enforcement.

The test fixture must remain private and short-lived.
It must not read secrets or modify repository state.

## Configuration, Migration, and Rollout

No configuration migration applies.

After source and regression validation, run the canonical release-manifest generator.
Only the generated release manifest may change from that operation.

Installer selftests must compare source and installed guard hashes.
The downstream copy must arrive through install or upgrade.

## Observability and Failure Handling

The parser matrix must report these fields for each leg:

- Interpreter path.
- Interpreter version.
- Source SHA-256.
- Exit code.
- Complete stderr.
- Sentinel count for the executable parser fixture.

Any missing interpreter is a test failure on the required macOS validation host.
A timeout is a failure, not a skipped result.

## Non-Goals

- Do not declare full Bash 3 runtime support.
- Do not change transition policy or gate applicability.
- Do not add a parser bypass or a second guard implementation.
- Do not patch installed downstream files directly.
- Do not edit documentation, registries, or unrelated bugs.

## Adversarial Regression Design

### Persistent Test Location

Extend the existing Bash baseline selftest.
That selftest already runs from framework validation under supported Bash.
It can invoke both real parser binaries as child processes.

Keep semantic guard assertions in the transition guard selftest.
Do not duplicate the transition fixture matrix in the Bash baseline selftest.

### Production Parser Matrix

Run both real interpreters with `-n` against the same canonical guard path.
Freeze one SHA-256 before either leg runs.

Require Bash 3.2 and Bash 5.3 to return zero.
Capture stderr independently for both legs.

### Source-Derived Sentinel Fixture

Build a private fixture from current source anchors.
Do not hand-copy the Check 7C body into the test.

Extract the complete `claim_backing_analysis` assignment by its opening line and closing delimiter.
Extract the exact Check 16 heading by its full text.

Prepend a valid `state_file` fixture path.
Append `BUG043_SENTINEL_AFTER_FORMER_LINE_4016` after the Check 16 heading.

Execute this fixture under Bash 3.2 and Bash 5.3.
Require exit zero and exactly one sentinel from each interpreter.

The sentinel proves execution crossed the former recovery boundary.
A parse-only assertion cannot provide that proof by itself.

### Exact Adversarial Mutant

Create a private copy from the repaired guard.
Restore only the two outer assignment quotes.
Do not change the apostrophe or any executable Check 7C byte.

Require the mutant to produce this closed result matrix:

| Source | Bash 3.2 parse | Bash 5.3 parse | Bash 3.2 sentinel | Bash 5.3 sentinel |
| --- | ---: | ---: | ---: | ---: |
| Repaired | 0 | 0 | 1 | 1 |
| Exact quote mutant | 2 | 0 | 0 | 1 |

The test must fail if the mutation does not occur exactly once.
It must also fail if either source anchor is missing or duplicated.

### Semantic Preservation

Run the complete transition guard selftest under supported Bash.
Require every existing verdict to remain unchanged.

Run the Bash baseline selftest directly before aggregate validation.
Then run framework validation and release readiness on the final source bytes.

### Downstream Propagation

Generate the release manifest after all source checks pass.
Install into a private downstream fixture.

Compare the source and installed guard hashes.
Run the same production parser matrix against the installed copy.

## Scenario-to-Test Mapping

| Scenario | Test surface | Required assertion |
| --- | --- | --- |
| `SCN-B043-001` | Bash baseline selftest | Both real parsers accept one frozen source hash. |
| `SCN-B043-002` | Bash baseline selftest | Repaired fixture reaches the sentinel, while the exact quote mutant blocks only Bash 3.2 before the sentinel. |
| `SCN-B043-003` | Transition guard selftest | Existing transition verdicts remain unchanged. |
| `SCN-B043-004` | Installer selftests | Installed bytes match source bytes and pass the same parser matrix. |

## Change Boundaries

### Filing Boundary

Allowed now:

- `bugs/BUG-043-state-transition-guard-bash3-parser-compatibility/**`

Everything else is protected. Preserve `.bubbles-worktree` exactly.

### Delivery Boundary

Allowed during implementation:

- Change `bubbles/scripts/state-transition-guard.sh`.
- Change `bubbles/scripts/state-transition-guard-selftest.sh`.
- Change `bubbles/scripts/bash-baseline-guard-selftest.sh`.
- Generate `bubbles/release-manifest.json` with the canonical generator.
- Update this packet's `report.md` and execution-owned state fields.

Protected during implementation:

- Preserve workflow and gate registries.
- Preserve other source scripts.
- Preserve other bug packets.
- Preserve docs and improvements.
- Preserve every downstream repository working tree.

Any required path outside this boundary must return to planning before mutation.

## Planning Reconciliation Required

The current planning artifacts do not encode the sentinel reach assertion.
They also contain a different negative control for `SCN-B043-002`.

The scenario manifest currently removes an interpreter leg as its control.
The specification requires restoration of the incompatible grammar.

`bubbles.plan` must reconcile these planning-owned surfaces:

- Make `TP-03` require the exact outer-quote mutant.
- Require the repaired Bash 3.2 fixture to reach the post-boundary sentinel.
- Require the mutant Bash 3.2 fixture to emit no sentinel.
- Align the `SCN-B043-002` negative control with the exact quote mutation.
- Keep all delivery DoD items unchecked.

No design-owned edit can substitute for that planning reconciliation.

## Alternatives Considered

1. **Edit the Check 16 heading.** Rejected because that complete region parses under Bash 3.2.
2. **Reword the apostrophe-bearing comment.** Rejected because the unsafe outer quoting context would remain.
3. **Move the Python program into another file.** Rejected because it creates a new source surface for a two-character repair.
4. **Rewrite Check 7C in shell.** Rejected because it changes semantics and increases the review surface.
5. **Require Bash 5 for parse-only validation.** Rejected because the defect contract requires the macOS system parser leg.
6. **Patch a downstream install.** Rejected because source provenance would diverge.

## Rollback

Restore the two outer assignment quote characters.
Regenerate the release manifest if it had already changed.

The exact mutant test must then recreate the Bash 3.2 failure.
No data, configuration, or runtime migration needs reversal.

## Complexity Tracking

None — simplest viable approach used.

## Residual Risks

No unresolved design question remains.
Planning drift remains until `bubbles.plan` reconciles its owned artifacts.

## Related Artifacts

- [Expected behavior](spec.md)
- [Delivery scope](scopes.md)
- [Evidence record](report.md)
