# Design: BUG-039 Unusable Interpreter Misreported As Classification Failures

## Root Cause, Precisely Located

Two predicates are being conflated:

| Predicate | Answered by | True on this machine |
|---|---|---|
| Is `python3` **present**? | `command -v python3` | yes |
| Can `python3` **run**? | executing it | **no** — exit 69 |

`bubbles/scripts/implementation-reality-scan.sh:696` gates the sensitive-storage
classifier on the first predicate. The `/usr/bin/python3` shim dispatches through
the *active developer directory*; with Xcode.app selected and its licence
unaccepted, the shim resolves (satisfying `command -v`) and then exits 69 without
executing a line of the helper.

The scanner's response to that is correct and must not change. It prints
`sensitive-storage classifier failed: exit=69`, echoes the interpreter's stderr,
and fails closed by degrading every candidate line to
`SENSITIVE_STORAGE_CLASSIFICATION_UNRESOLVED`. The selftest's own
"Parser-unavailable configured approval fails closed" scenario depends on exactly
that behaviour.

The defect is one layer up, in the **selftest**: it asserts on classifier output
without ever checking that the classifier could produce any. The failure text it
then emits describes the code under scan when the real subject is the harness's
missing prerequisite.

## The Blast Radius Is Wider Than The 11 Reds

Measured, not assumed. Under the dead interpreter the scan emits
`CONFIG_INVALID` for **any** config that declares a `sensitiveClientStorage`
key — including the deliberately *valid* one:

```
SENSITIVE_STORAGE_CONFIG_INVALID occurrences:  A (dead interpreter) = 6,  B (live) = 5
```

The extra occurrence in A is the valid-config run. Therefore the four
`assert_sensitive_invalid_config` scenarios (8 assertions) report **PASS**
under the dead interpreter no matter what the config contains. They cannot
distinguish valid from invalid. Likewise 4 of the 15 semantic assertions pass
vacuously because the blanket `CLASSIFICATION_UNRESOLVED` degradation happens
to satisfy them.

So the honest tally under a dead interpreter is not "11 failures". It is
**23 assertions across 5 scenarios, none of which produced an earned verdict** —
11 red for the wrong reason, 12 green for no reason.

## Repair Chosen

**Add a usability probe to the selftest and emit a named SKIP for the scenario
group whose preconditions cannot hold.** This is the operator's preferred
option, and the evidence above strengthens it: the skip must cover the config
scenarios too, not only the visibly-failing semantic block.

### Why this layer

The scanner is correct; changing it would break a contract the framework relies
on. The selftest is what asserts a precondition it never established. Fix the
predicate where the wrong predicate is used.

### The probe

`command -v python3` is replaced, for this decision only, by an execution probe:

```bash
python3 -c 'import sys; sys.stdout.write("classifier-probe-ok")' </dev/null
```

Both the exit status and the payload are checked, so a wrapper that exits 0
while emitting a warning cannot masquerade as a healthy interpreter.

### The skip message

Names the cause and the operator action, matching the framework's existing idiom
(`SKIP: BLOCK (#4) schema-invalid tool-log line — python 'jsonschema' not
importable`). When the probe output carries the Xcode licence signature the
remediation is specific:

- `sudo xcodebuild -license accept`, **or**
- point the active developer directory at an accepted toolchain
  (`sudo xcode-select -s /Library/Developer/CommandLineTools`, or
  `DEVELOPER_DIR=/Library/Developer/CommandLineTools` for one shell).

Otherwise it falls back to a generic repair instruction carrying the captured
diagnostic. The message also states which assertions did not run, so a reader
cannot mistake a quiet run for a thorough one.

### The sentinel

One stable, greppable line for machine consumers:

```
SENSITIVE_STORAGE_CLASSIFIER_UNAVAILABLE=1
```

Absent ⇒ the scenario group executed. Present ⇒ it did not. This is what lets
`test_24` tell a skip from a pass without parsing prose.

## Rejected Alternatives

**Override `DEVELOPER_DIR` inside the test.** Confirmed rejected, and the
operator's reasoning holds. The sanitized-PATH scenario's entire value is that
it proves the scanner works under **default** system resolution with no
Homebrew. Injecting a hand-picked developer directory makes the scenario
pass by construction: it would no longer be able to observe the class of
environment defect it exists to expose, while still reporting green. That is a
strictly worse failure mode than the current loud-but-misnamed one, because it
is silent.

**Relax the semantic assertions, or teach `test_24` to tolerate 11 mismatches.**
Forbidden and correctly so. The assertions encode the classifier's contract. The
mutation proof below exists precisely to demonstrate they are untouched and still
lethal.

**Fix it in the scanner** (e.g. make the scanner probe usability and refuse).
Rejected **as to refusal**, and that half stands: the scanner's degradation is
contracted behaviour that the "Parser-unavailable configured approval fails
closed" scenario asserts, so the scanner must still degrade rather than refuse.

Superseded **as to probing**. The original entry also claimed "the scanner is
not the thing making an unchecked assumption". Evidence gathered during delivery
falsifies that clause. `implementation-reality-scan.sh:696` gated on
`command -v python3`, which is the presence-versus-usability conflation this bug
is about, sitting in the producer itself. The scanner therefore does probe
usability now, and it still degrades exactly as before; only the gate predicate,
the diagnostic string, and the interpreter actually invoked changed. The
contracted `SENSITIVE_STORAGE_CLASSIFICATION_UNRESOLVED` reason strings are
untouched. See `## Change Boundary` for the recorded rationale and its limits.

## Guarantee Preservation

A skip path that swallows real failures is worse than the bug. The design is
therefore validated by mutation, not by inspection:

1. With a **usable** interpreter, break the classifier's classification logic.
2. The selftest must go **RED** — proving the skip does not engage and the
   assertions still bite.
3. Revert; the selftest must go **GREEN**.
4. The mutated file must be byte-identical to HEAD afterwards (`git diff --quiet`
   plus a hash comparison).

## Cascade: `test_24`

`assert_status 0 "managed selftest runs with the system-only PATH"` is
unconditional and so cannot distinguish "ran everything and passed" from "ran
almost nothing". A skip is not a pass and must never be counted as one.

Resolution: a third outcome. `test_24` gains a `SKIP_COUNT` and a `skip()`
recorder. After running the managed selftest with the sanitized PATH it
branches on the sentinel:

- sentinel **absent** → the selftest ran the full scenario set → `assert_status 0`
  exactly as before; meaning unchanged.
- sentinel **present** → record an explicit **SKIP** for the coverage claim
  (never a pass), and separately still require exit 0, because a selftest that
  skips must not also be failing. The unmet coverage is named in the output.

## Change Boundary

Ratified by `bubbles.plan` after independent verification. Two paths outside the
originally declared boundary were widened into it. The widening is bounded to
one defect class and is not a standing licence over either file.

### In boundary

| Path | Why it is in scope |
|---|---|
| `bugs/BUG-039-.../**` | The packet itself. |
| `bubbles/scripts/implementation-reality-scan-selftest.sh` | The harness that asserted without establishing its precondition. |
| `tests/regression/test_24_g028_sensitive_client_storage.sh` | The cascade that could not tell a skip from a pass. |
| `bubbles/scripts/implementation-reality-scan.sh` | **Widened.** The presence-versus-usability conflation lives here, at the `command -v python3` gate. Repairing only the harness would leave the producer still choosing an interpreter by presence. |
| `bubbles/scripts/python-env.sh` | **Widened.** The framework's designated usability-aware interpreter resolver. It carried the same misreporting defect one layer down. |
| `bubbles/scripts/python-env-selftest.sh` | **Widened (second widening).** The owning module's selftest, for the API this packet added to that module. Rationale below. |

### Recorded rationale for the two widened paths

`implementation-reality-scan.sh` is admitted because the bug's subject is the
conflation of presence with usability, and this file is where that conflation is
literally written. The change is confined to three things: the gate predicate,
the diagnostic string, and the interpreter actually invoked. The contracted
degradation to `SENSITIVE_STORAGE_CLASSIFICATION_UNRESOLVED` is byte-for-byte
unchanged, so the "Parser-unavailable configured approval fails closed" scenario
keeps its meaning. The file now sources `python-env.sh`; that is safe because
`python-env.sh` guards its CLI dispatch behind `[[ "${BASH_SOURCE[0]}" == "${0}" ]]`,
produces no output when sourced, and is itself a managed install, so it is
present wherever the scanner is.

`python-env.sh` is admitted because it carried the same defect class as the
filed bug. Under `set -u` with `HOME` unset, `${XDG_CACHE_HOME:-$HOME/.cache}`
did not merely abort. It yielded an empty home and the caller then published
`/bin/python3` — a path that does not exist — as a resolved interpreter. An
absent locator was reported as "no interpreter satisfies the required modules",
which is a sentence about interpreters when nothing had been able to name one.
That is the filed bug's failure mode, one layer down, in the module the
framework designates to answer this exact question.

The alternative — probing usability locally inside the scanner — was rejected
because it would put a third interpreter-resolution contract in the tree, in the
file whose wrong local guess started this.

### Measured justification for admitting `python-env.sh` rather than deferring it

Deferring it does not merely postpone a repair; it permanently surrenders
coverage. With a sanitized PATH and `HOME` set — the ordinary real-world
invocation — the repaired resolver reaches the managed venv and the Scan 2B
scenario group **runs to completion with zero skips**. Without the repair the
same invocation selects the dead `/usr/bin/python3`, degrades, and the group is
skipped every time. A selftest-only fix would have converted a loud wrong answer
into a quiet permanent gap.

### Recorded rationale for the second widening: `python-env-selftest.sh`

Declared after the first widening was ratified, because that widening is what
created the obligation. Admitting `python-env.sh` added new API to a shared
module — `bubbles_python_runs`, `bubbles_python_resolve_runnable`, and the
globals `BUBBLES_PYTHON_RUNNABLE` / `BUBBLES_PYTHON_RUNNABLE_REASON` — and
changed an existing contract, because `bubbles_python_home` and
`bubbles_python_venv_python` can now decline instead of always printing.

The admitting argument is deliberately **not** "same defect class"; that argument
is refused below and stays refused. It is narrower and it is about this packet's
own output: a boundary must cover the change that was made, and the change added
API to this module. The owning module's selftest is where that API is pinned.

The measurement that makes it necessary rather than tidy: the original defect
survived **because** nothing in this file pinned the module's behaviour when the
locator was absent. `python-env.sh` was already usability-aware, and it still
published `/bin/python3` — a path that does not exist on this machine — as a
resolved interpreter, because `${XDG_CACHE_HOME:-$HOME/.cache}` aborted inside a
command substitution and the empty result was concatenated with `/bin/python3`.
Every other case in the file passed throughout. Coverage that cannot observe the
defect sitting next to it is what let this reach two consumers.

Admitted work is confined to **adding** cases that pin the API this packet
introduced: the ordered locator precedence, the absent-locator condition, the
payload check, and the absent-locator reason string. No existing case is
modified, relaxed, renumbered, or deleted.

### Explicitly out of boundary

The following are **not** admitted by either widening, and must not join them by
analogy:

- Any `python-env.sh` change unrelated to locator guarding or interpreter
  usability. Module-resolution policy, the pinned requirements set, venv
  provisioning behaviour, and the `bubbles_python_resolve` module contract are
  all untouched and stay untouched.
- Migrating any of the 20+ remaining `command -v python3` call sites. Those are
  the same defect class, which is exactly why they need their own packet with
  their own blast-radius analysis rather than being swept in here.
- Any `python-env-selftest.sh` change that is not new coverage for the API this
  packet added. Weakening, relaxing, or renumbering an existing case is refused,
  and so is repairing an unrelated pre-existing weakness in that file — see the
  routed finding below.
- Any file that merely consumes `python-env.sh`.

"It is the same defect class" is the argument this section exists to refuse. A
shared module is widened one defect at a time, with the measurement that shows
what deferring it would cost.

### Known gap: closed by the second widening

Previously recorded as open and unadmitted, on the rule that a boundary must
describe the change that was made rather than the change that might be made.
The change has now been made, the widening above declares it, and the gap is
closed: `python-env-selftest.sh` gained Cases 12-15, which pin the ordered
locator precedence, the absent-locator condition, the payload check, and the
absent-locator reason string. Non-vacuity is established by mutation — the
historical unguarded `$HOME` is restored, the new assertions go red naming the
fabricated `/bin/python3`, and the file is verified byte-identical after revert.

### Routed finding, not absorbed: `test_24` never sources `python-env.sh`

Found while executing this packet's evidence, reported rather than repaired.

`tests/regression/test_24_g028_sensitive_client_storage.sh` calls
`bubbles_python_home` and `bubbles_python_runs` in its BUG-040 block without
ever sourcing the module that defines them. The run emits
`test_24…: line 614: bubbles_python_home: command not found`, the `if` is
therefore false, `bubbles_python_runs` is never reached, and the block reports
`no managed venv at <no locator>`.

That diagnostic is false, and it is false in exactly this bug's shape: an absent
prerequisite — the unsourced module — is being reported as a statement about
where the venv lives. The scenario cannot execute under any environment, so its
six assertions are unreachable and the skip it records is unearned.

It is left open deliberately. The call sites do not exist at HEAD, so this is
in-flight work in this tree with no owning packet: `bugs/BUG-040-*` does not
exist. Repairing it would newly activate six assertions whose outcome is not
measured here, which is a blast radius that belongs to a declared packet, not to
a drive-by edit made while another validation run is in flight. Routed to the
parent runner with the measured evidence above.

### Consumers of `python-env.sh` at time of ratification

12 files reference the module. Only these call its functions:

| Consumer | Functions used | Affected by this change |
|---|---|---|
| `cli.sh` | `bubbles_python_activate` | No, when a locator is set. Returns 1 cleanly instead of aborting when none is. |
| `dependency-posture.sh` | `bubbles_python_activate` | Same. |
| `python-env-selftest.sh` | `bubbles_python_activate`, `bubbles_python_provision` | Same, plus a new exit-2 path that only fires with no locator. |
| `framework-validate.sh` | executes `--path`, never sources | Diagnostic text only. |
| `implementation-reality-scan.sh` | `bubbles_python_resolve_runnable` | In boundary. |
| `implementation-reality-scan-selftest.sh` | `bubbles_python_resolve_runnable` | In boundary. |
| `test_24_g028_sensitive_client_storage.sh` | `bubbles_python_home`, `bubbles_python_runs` | In boundary. |

The remaining references are comments or documentation. `bubbles_python_runs`
and `bubbles_python_resolve_runnable` are additive: no pre-existing consumer
calls them. The signature changes on `bubbles_python_home` and
`bubbles_python_venv_python` are observable only when no locator is set at all,
which previously produced a fabricated path rather than a correct one.

The summary line reports skips alongside passes and failures, so a skipped run
is visible in the transcript and in any log scraped from it. `FAIL_COUNT` still
governs the exit code, so a genuine regression is still fatal.
