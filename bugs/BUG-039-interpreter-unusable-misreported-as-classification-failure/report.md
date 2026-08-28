# Report: BUG-039

All output below came from commands executed in this session, with their real
exit codes. Nothing is reconstructed.

---

## 1. Machine Context

```
$ xcode-select -p
/Applications/Xcode.app/Contents/Developer          # exit 0

$ ls -d /Library/Developer/CommandLineTools
/Library/Developer/CommandLineTools                 # present

$ sudo -n true
sudo: a password is required                        # exit 1
```

Accepting the Xcode licence requires a password and is an operator action. The
framework cannot depend on it having been taken.

## 2. Files Clean At HEAD Before Any Change

```
$ git status --short -- bubbles/scripts/implementation-reality-scan-selftest.sh \
                        bubbles/scripts/guards/sensitive-client-storage-scan.py \
                        tests/regression/test_24_g028_sensitive_client_storage.sh
(no output)
```

Confirms the defect is pre-existing, not introduced by in-flight work.

## 3. Bug Reproduction — Before Fix

Single-variable A/B, reproduced independently rather than taken on trust.

```
$ env -i PATH=/usr/bin:/bin:/usr/sbin:/sbin /bin/bash \
    bubbles/scripts/implementation-reality-scan-selftest.sh </dev/null
A_EXIT=1
implementation-reality-scan selftest failed with 11 issue(s).

$ env -i PATH=/usr/bin:/bin:/usr/sbin:/sbin \
    DEVELOPER_DIR=/Library/Developer/CommandLineTools /bin/bash \
    bubbles/scripts/implementation-reality-scan-selftest.sh </dev/null
B_EXIT=0
implementation-reality-scan selftest passed.
```

Interpreter under each environment:

```
A python3: You have not agreed to the Xcode license agreements. Please run
           'sudo xcodebuild -license' ...          # exit 69
B python3: Python 3.9.6
```

The eleven failures, all in the Scan 2B semantic block:

```
FAIL: Literal and alias-resolved durable credentials are blocked
FAIL: Exact configured session credential is allowed
FAIL: Unknown session provider is blocked distinctly
FAIL: High-trust session material cannot use approval
FAIL: Inline comment vocabulary does not taint cache
FAIL: removeItem remains cleanup
FAIL: Proven scrubbed rewrite remains clear
FAIL: IndexedDB credential access remains covered
FAIL: SharedPreferences credential persistence remains covered
FAIL: AsyncStorage credential persistence remains covered
FAIL: IndexedDB object-store credential persistence remains covered
```

The scanner's own diagnostic in the same transcript already named the true cause:

```
   sensitive-storage classifier failed: exit=69 helper=.../sensitive-client-storage-scan.py
   sensitive-storage classifier inputs: ... python3=/usr/bin/python3
   sensitive-storage classifier stderr: You have not agreed to the Xcode license agreements. ...
```

**Verdict: the A/B proof is confirmed exactly as supplied. The scanner is
correct and is starved of an interpreter.**

## 4. Correction To The Reported Blast Radius

The eleven reds are not the whole failure. Measured:

```
SENSITIVE_STORAGE_CONFIG_INVALID occurrences:  A (dead interpreter) = 6,  B (live) = 5
```

The extra occurrence in A is the run using the deliberately **valid** config.
Under a dead interpreter the scan emits `CONFIG_INVALID` for any config that
declares a `sensitiveClientStorage` key, so the four config-integrity scenarios
report PASS regardless of content:

```
PASS: Traversal and wildcard approval blocks / reports config integrity
PASS: Duplicate approval tuple blocks / reports config integrity
PASS: Unknown field and enum values blocks / reports config integrity
PASS: Malformed sensitive storage YAML blocks / reports config integrity
```

Those eight greens are vacuous, as are four of the fifteen semantic assertions.
The honest tally is 23 assertions across 5 scenarios with **no earned verdict**:
11 red for the wrong reason and 12 green for no reason. The skip therefore
covers both groups, not only the visibly-failing one.

## 5. Packet Route

```
$ bash bubbles/scripts/micro-fix-admission.sh bugs/BUG-039-...
[micro-fix-admission] ... fails admission (no-new-behavior contract-preserving)
    - it escalates automatically to the full bug packet.
[micro-fix-admission] Escalation is mechanical. There is no reviewer discretion
    and no override flag.
admission_exit=0
```

Route: **full packet**.

## 6. After Fix — Three Environments

| Run | Command | Exit | FAIL | SKIP |
|---|---|---|---|---|
| V1 | `bash …selftest.sh` (normal PATH) | **0** | 0 | 0 |
| V2 | `env -i PATH=/usr/bin:/bin:/usr/sbin:/sbin /bin/bash …selftest.sh </dev/null` | **0** | 0 | 1 |
| V3 | V2 + `DEVELOPER_DIR=/Library/Developer/CommandLineTools` | **0** | 0 | 0 |

V2 output — the named skip:

```
SENSITIVE_STORAGE_CLASSIFIER_UNAVAILABLE=1
SKIP: semantic Scan 2B classification and sensitive-storage config integrity — python3 at
      /usr/bin/python3 exited 69 without running: You have not agreed to the Xcode license
      agreements. Please run 'sudo xcodebuild -license' ...
      remediation: the active developer directory (/Applications/Xcode.app/Contents/Developer)
      has an unaccepted Xcode licence. Run 'sudo xcodebuild -license accept', or point the
      active developer directory at an accepted toolchain ('sudo xcode-select -s
      /Library/Developer/CommandLineTools', or export
      DEVELOPER_DIR=/Library/Developer/CommandLineTools for one shell).
      not run: 15 semantic classification assertions, 8 config-integrity assertions.
      ...
implementation-reality-scan selftest skipped 1 scenario group(s) for an absent prerequisite.
implementation-reality-scan selftest passed the scenarios it could run (1 skipped).
```

V3 is the control that matters: **same sanitized PATH, usable interpreter, zero
skips.** The skip is conditioned on measured usability, not applied blanket.

## 7. Mutation Proof — The Guarantee Survives

Mutation applied to `bubbles/scripts/guards/sensitive-client-storage-scan.py`,
one token in the classification ladder:

```python
-    elif storage != "sessionStorage":
+    elif storage != "localStorage":
         reason = "DURABLE_CREDENTIAL_STORAGE"
```

| Run | Interpreter | Exit | FAIL | SKIP |
|---|---|---|---|---|
| Mutant, normal PATH | usable | **1** | 3 | 0 |
| Mutant, sanitized PATH + `DEVELOPER_DIR` | usable | **1** | 3 | 0 |
| Mutant, sanitized PATH | dead | 0 | 0 | 1 |

Failures raised by the mutant with a usable interpreter:

```
FAIL: Literal and alias-resolved durable credentials are blocked (missing: reason=DURABLE_CREDENTIAL_STORAGE storage=loc...)
FAIL: Exact configured session credential is allowed (unexpected: src/provider-client.js:6)
FAIL: Unknown session provider is blocked distinctly (missing: reason=SESSION_PROVIDER_UNKNOWN)
```

Row 2 is the decisive one: under the **exact scenario that was broken**
(sanitized PATH), a usable interpreter still executes every assertion and the
regression is still caught. The skip path does not swallow real failures.

Revert verified byte-identical:

```
$ shasum -a 256 bubbles/scripts/guards/sensitive-client-storage-scan.py
77a02ff179d529812d75cfa223bef5f9f171a9169dce050ab46fb2f1f0834df3   # == pre-mutation
$ git diff --quiet -- bubbles/scripts/guards/sensitive-client-storage-scan.py
IDENTICAL (exit 0)

REVERT_V1_EXIT=0   implementation-reality-scan selftest passed.
REVERT_V3_EXIT=0   implementation-reality-scan selftest passed.
```

Honest limitation, stated rather than hidden: row 3 shows the mutant escapes
detection when no interpreter can run. That is unavoidable — the assertions
cannot execute without one. What the fix changes is that the gap is now loud,
named, remediated and machine-detectable instead of silently green or falsely
red.

## 8. Cascade — `test_24`

```
$ bash tests/regression/test_24_g028_sensitive_client_storage.sh </dev/null
TEST24_EXIT=0
FAILs=0

SKIP: managed selftest Scan 2B coverage (classifier interpreter unusable; selftest reported the cause and remediation)
PASS: managed selftest exits cleanly when it skips an absent prerequisite
PASS: managed selftest preserves watchdog exit 124
=== BUG-013 regression summary ===
test_24_g028_sensitive_client_storage: 57 passed, 0 failed, 1 skipped
```

Before the fix this reported `FAIL: managed selftest runs with the system-only
PATH`. It now reports the coverage as a **skip**, counted in its own column. The
label `managed selftest runs with the system-only PATH` is deliberately **not**
emitted, because that claim was not established. `FAIL_COUNT` still governs the
exit code, so a genuine regression remains fatal.

## 9. Lint

```
$ shellcheck -x bubbles/scripts/implementation-reality-scan-selftest.sh          # exit 0
$ shellcheck -x tests/regression/test_24_g028_sensitive_client_storage.sh        # exit 0
```

`shfmt -d -i 2 -ci -bn` reports a diff on both files (exit 1). **Pre-existing**,
established by comparison against HEAD:

| File | shfmt diff lines at HEAD | after change |
|---|---|---|
| `implementation-reality-scan-selftest.sh` | 250 | 250 |
| `test_24_g028_sensitive_client_storage.sh` | 127 | 127 |

None of the added code appears in the shfmt diff (searched for
`classifier_usable`, `CLASSIFIER_`, `SENSITIVE_STORAGE_CLASSIFIER_UNAVAILABLE`,
`SKIP_COUNT`, `skips=`, `skip()` — no matches). The change adds zero new
formatting deviations, and the pre-existing ones were left untouched rather
than reformatted into an unrelated diff.

## 10. Consumer Safety

`framework-validate` judges selftests by exit status
(`run_check "Discovered selftest: …" bash "$selftest_path"`), not by parsing
stdout. The contract it depends on is preserved: exit 0 when nothing failed,
exit 1 when something did. No other script parses this selftest's success
sentence.

## Test Evidence

Every figure below was produced by a command executed in this session, on the
working tree as delivered. Runs over 40 lines went through
`bubbles/scripts/evidence-capture.sh`, whose emitted block carries the command,
the exit code, the line count and a sha256 over every line produced; the hash is
re-derivable with `--verify` using the pointer recorded beside each run.

### Verdict table

| # | Condition | Exit | FAIL | SKIP | Sentinel |
|---|---|---|---|---|---|
| V1 | `bash bubbles/scripts/implementation-reality-scan-selftest.sh` (normal PATH) | **0** | 0 | 0 | absent |
| V2 | `env -i PATH=/usr/bin:/bin:/usr/sbin:/sbin /bin/bash …selftest.sh </dev/null` | **0** | 0 | 1 | present |
| V3 | V2 + `HOME="$HOME"` | **0** | 0 | 0 | absent |
| T24 | `bash tests/regression/test_24_g028_sensitive_client_storage.sh </dev/null` | **0** | 0 | 2 | n/a |
| PE | `bash bubbles/scripts/python-env-selftest.sh` | **0** | 0 | — | n/a |

`FAIL` and `SKIP` are counts of lines matching `^FAIL:` / `^SKIP:`; `Sentinel`
is the presence of `SENSITIVE_STORAGE_CLASSIFIER_UNAVAILABLE=1`. Counted
mechanically rather than read off the summary sentence, so a summary line that
drifted from its own tallies could not hide behind prose:

```
$ for label in V1 V2 V3; do ... printf "%s: exit=%s FAIL=%s SKIP=%s sentinel=%s\n" ... done
V1: exit=0 FAIL=0 SKIP=0 sentinel=0
V2: exit=0 FAIL=0 SKIP=1 sentinel=1
V3: exit=0 FAIL=0 SKIP=0 sentinel=0
```

### V1 — normal PATH, full coverage

```
# V1 implementation-reality-scan-selftest normal PATH
$ bash bubbles/scripts/implementation-reality-scan-selftest.sh
exit: 0
lines: 790
sha256: 5adde28ce7d3e1478aefedc37d764e96572bd04a3e7ad64b205919587211e930
--- last 4 ---
PASS: Parser-unavailable configured approval fails closed
Scenario: portable watchdog preserves exit 124 without GNU coreutils.
PORTABLE_WATCHDOG_FALLBACK=124
PASS: Portable watchdog preserves exit 124
implementation-reality-scan selftest passed.
```
<!-- verify: bash bubbles/scripts/evidence-capture.sh --verify 5adde28ce7d3e1478aefedc37d764e96572bd04a3e7ad64b205919587211e930 -- bash bubbles/scripts/implementation-reality-scan-selftest.sh -->

### V2 — sanitized PATH, no locator: the named skip

The environment is emptied, so `HOME` is gone and the managed venv cannot be
named at all. The only interpreter left is `/usr/bin/python3`, which on this
machine exits 69 without running.

```
# V2 sanitized PATH, no HOME
$ env -i PATH=/usr/bin:/bin:/usr/sbin:/sbin /bin/bash bubbles/scripts/implementation-reality-scan-selftest.sh
exit: 0
lines: 363
sha256: aed5a1393257ada518623c7e61e81267a4233d38aae0f03e73677cc51bba6c37
--- last 2 ---
implementation-reality-scan selftest skipped 1 scenario group(s) for an absent prerequisite.
implementation-reality-scan selftest passed the scenarios it could run (1 skipped).
```
<!-- verify: bash bubbles/scripts/evidence-capture.sh --verify aed5a1393257ada518623c7e61e81267a4233d38aae0f03e73677cc51bba6c37 -- env -i PATH=/usr/bin:/bin:/usr/sbin:/sbin /bin/bash bubbles/scripts/implementation-reality-scan-selftest.sh -->

The 363-line output against V1's 790 is the skip made visible: 427 lines of
scenario work did not run, and the run says so rather than reporting the absence
as classification defects.

### V3 — sanitized PATH, HOME restored: the control that matters

One variable is re-introduced. PATH is still system-only, so this is the same
environment that produced eleven false failures before the fix.

```
# V3 sanitized PATH, HOME set
$ env -i PATH=/usr/bin:/bin:/usr/sbin:/sbin HOME=/Users/pkirsanov /bin/bash bubbles/scripts/implementation-reality-scan-selftest.sh
exit: 0
lines: 790
sha256: 54a91ac264b88feb7a48b544c3e6588bde6ef343d73aca4621b48cf55fe41409
--- last 1 ---
implementation-reality-scan selftest passed.
```
<!-- verify: bash bubbles/scripts/evidence-capture.sh --verify 54a91ac264b88feb7a48b544c3e6588bde6ef343d73aca4621b48cf55fe41409 -- env -i PATH=/usr/bin:/bin:/usr/sbin:/sbin HOME=/Users/pkirsanov /bin/bash bubbles/scripts/implementation-reality-scan-selftest.sh -->

790 lines, byte-for-byte the same volume as V1, zero skips. The skip is
conditioned on measured usability, not applied blanket to a sanitized
environment.

### T24 — the cascade

```
# test_24 G028 sensitive client storage regression
$ bash tests/regression/test_24_g028_sensitive_client_storage.sh
exit: 0
lines: 1670
sha256: 7d6daecd65ed8ed2bd2059c55e957aa8d0f124c3ea82cdcb59c86f20ce17e4a1
--- last 6 ---
SKIP: managed selftest Scan 2B coverage (classifier interpreter unusable; selftest reported the cause and remediation)
PASS: managed selftest exits cleanly when it skips an absent prerequisite
PASS: managed selftest preserves watchdog exit 124
=== BUG-040 managed selftest sanitized PATH with the managed interpreter ===
tests/regression/test_24_g028_sensitive_client_storage.sh: line 614: bubbles_python_home: command not found
SKIP: managed selftest full Scan 2B coverage under a sanitized PATH (no managed venv at <no locator>; provision with 'bash bubbles/scripts/python-env.sh --provision')
=== BUG-013 regression summary ===
test_24_g028_sensitive_client_storage: 57 passed, 0 failed, 2 skipped
BUG013_GREEN_REGRESSION=SEMANTIC_STORAGE_CLASSIFICATION_SATISFIED
```
<!-- verify: bash bubbles/scripts/evidence-capture.sh --verify 7d6daecd65ed8ed2bd2059c55e957aa8d0f124c3ea82cdcb59c86f20ce17e4a1 -- bash tests/regression/test_24_g028_sensitive_client_storage.sh -->

57 passed / 0 failed / 2 skipped, exit 0. **One of those two skips is not
sound, and it is named here rather than counted quietly.** See
`## Finding Raised While Recording This Evidence` below.

### PE — `python-env-selftest.sh`, the second widening

Baseline before the file was touched, and the result after:

```
$ bash bubbles/scripts/python-env-selftest.sh          # BEFORE
python-env selftest: 24 passed, 0 failed
PYENV_SELFTEST_BASELINE_EXIT=0

$ bash bubbles/scripts/python-env-selftest.sh          # AFTER
PASS: Case 12: BUBBLES_PYTHON_HOME outranks XDG_CACHE_HOME and HOME
PASS: Case 12b: XDG_CACHE_HOME outranks HOME, with the trailing slash normalized
PASS: Case 12c: HOME is the last locator, under .cache
PASS: A6: bubbles_python_home declines when no locator is set
PASS: A6b: bubbles_python_venv_python declines instead of publishing a path
PASS: A7 (healthy): an interpreter that executes and returns the payload is usable
PASS: A7 (silent): an interpreter that exits 0 while producing NOTHING is not usable
PASS: A7 (noisy): an interpreter that pollutes stdout cannot pass the payload check
PASS: A7 (dead): an interpreter that emits the payload and then exits 69 is not usable
PASS: Case 13: absent-locator reason names the locator variables
PASS: Case 13b: reason claims no venv path when none could be named

python-env selftest: 35 passed, 0 failed
PYENV_SELFTEST_EXIT=0
```

24 → 35 is 11 added assertions and no existing case altered.

### Mutation proof for the added assertions

Coverage that cannot go red is decoration. The mutation chosen is the original
defect itself: the historical unguarded `${XDG_CACHE_HOME:-$HOME/.cache}`
restored in `bubbles_python_home`, together with the historical
`bubbles_python_venv_python` that concatenated its output unconditionally.

The mutant reproduces the exact fabrication, verified before running anything:

```
$ env -u HOME -u XDG_CACHE_HOME -u BUBBLES_PYTHON_HOME /bin/bash -c \
    'set -u; . "$1"; out=$(bubbles_python_venv_python 2>/dev/null); \
     printf "rc=%s venv_python=[%s] exists=%s\n" "$?" "$out" "$([[ -e $out ]] && echo yes || echo no)"' _ …
rc=0 venv_python=[/bin/python3] exists=no
```

A **success** return code, publishing a path that **does not exist**. That is
what the resolver did before this packet, and it is what the new assertions must
catch.

| Stage | sha256 of `python-env.sh` | Selftest | Passed | Failed |
|---|---|---|---|---|
| Before mutation | `23a345fb…cd23300` | exit **0** | 35 | 0 |
| Mutant applied | `cbfd54eb…9ba9cc9d` | exit **1** | 30 | **5** |
| After revert | `23a345fb…cd23300` | exit **0** | 35 | 0 |

The five assertions that went red under the mutant:

```
FAIL: Case 12b: locator printed '…/c12/xdg//bubbles/python', expected '…/c12/xdg/bubbles/python'
FAIL: A6: bubbles_python_home returned 'RESOLVED|/.cache/bubbles/python', expected 'DECLINED|' (a fabricated or empty-but-successful home is the BUG-039 defect)
FAIL: A6b: bubbles_python_venv_python returned 'RESOLVED|/.cache/bubbles/python/bin/python3', expected 'DECLINED|' — publishing a nonexistent interpreter path (historically '/bin/python3') is the BUG-039 defect
FAIL: Case 13: reason was 'the managed venv (/.cache/bubbles/python/bin/python3) is absent or does not execute; no python3 on PATH', expected it to name 'the managed venv has no locator' and 'BUBBLES_PYTHON_HOME, XDG_CACHE_HOME, or HOME'
FAIL: Case 13b: reason names a concrete venv path while no locator is set: 'the managed venv (/.cache/bubbles/python/bin/python3) is absent or does not execute; no python3 on PATH'
```

A6b is the decisive line: it names the fabricated path the mutant published
instead of declining. Case 13/13b catch the second half of the same defect —
the diagnostic that described a venv the module had never located.

Stated rather than glossed: the four **A7** payload assertions stayed green
under this mutant. That is correct, not a weakness — the mutation is to the
locator, and A7 pins the execution probe. A7's own non-vacuity is established by
its `silent` case, which passes an interpreter that exits 0 and emits nothing
and is refused; an exit-code-only check accepts it.

Byte-identity after revert, so no mutation residue reaches the delivered tree:

```
$ shasum -a 256 bubbles/scripts/python-env.sh
23a345fbdfec46d11508bcb69777684352e080b46ddbe470d40e681dacd23300
$ git diff --stat -- bubbles/scripts/python-env.sh
 bubbles/scripts/python-env.sh | 149 ++++++++++++++++++++++++++++++++++++++----
 1 file changed, 138 insertions(+), 11 deletions(-)      # the ratified diff, unchanged
```

The three consumers were re-run after the revert and are the V1/V2/V3/T24 rows
above, so the verdict table reflects the reverted tree, not the mutant.

### Lint on the file this session touched

`bubbles/scripts/python-env-selftest.sh` is the only `.sh` modified in this
session. Findings were compared against HEAD before being attributed.

| Check | HEAD | After | Attribution |
|---|---|---|---|
| `shellcheck -x` exit | 1 | 1 | pre-existing |
| `shellcheck -x` SC2016 (info) count | 7 | 14 | +7, same idiom |
| `shellcheck -x` findings above info | 0 | 0 | none added |
| `shellcheck -x -S warning` exit | — | **0** | clean |
| `shfmt -d -i 2 -ci -bn` diff lines | 18 | 18 | pre-existing, unchanged |

```
$ shellcheck -x -S warning bubbles/scripts/python-env-selftest.sh
SHELLCHECK_SEVERITY_WARNING_EXIT=0
```

Every SC2016 is the file's deliberate `bash -c '. "$1"; …'` idiom, where single
quotes are required so `$1` reaches the child shell rather than being expanded
by the parent. The seven added instances are the same construct as the seven
already at HEAD; no new finding class appears, and nothing above `info` does.

The 18-line `shfmt` diff lies entirely in the pre-existing A3 block. No added
code appears in it:

```
$ shfmt -d -i 2 -ci -bn bubbles/scripts/python-env-selftest.sh | \
    grep -E 'no_locator|probe_runs|assert_runs|make_probe_python|LOCATOR_VARS_EXPECTED|a6_home|a6_venv|c12|c13'
    (none)
```

The pre-existing deviations were left alone rather than reformatted into an
unrelated diff.

## Finding Raised While Recording This Evidence

> **Superseded — see "Finding Above — Now Repaired In-Boundary" below.** The
> section as written stands as the record of what was known when it was written:
> the finding was reported and deliberately left open. The parent runner later
> confirmed it independently and returned it for repair, and the repair is
> recorded after it. Nothing here is retracted; the disposition changed.

Reported, not repaired. Recording it is part of the evidence; absorbing it is
not this session's work.

`tests/regression/test_24_g028_sensitive_client_storage.sh` calls
`bubbles_python_home` and `bubbles_python_runs` in its BUG-040 block without
ever sourcing the module that defines them:

```
$ grep -n 'python-env\|bubbles_python' tests/regression/test_24_g028_sensitive_client_storage.sh
614:if MANAGED_PYTHON_HOME="$(bubbles_python_home)"; then
617:if [[ -z "$MANAGED_PYTHON" ]] || ! bubbles_python_runs "$MANAGED_PYTHON"; then
618:  skip "managed selftest full Scan 2B coverage under a sanitized PATH (no managed venv at ${MANAGED_PYTHON_HOME:-<no locator>}; …"
```

There is no `source`/`.` of `python-env.sh` anywhere in the file. The run
confirms it:

```
tests/regression/test_24_g028_sensitive_client_storage.sh: line 614: bubbles_python_home: command not found
SKIP: managed selftest full Scan 2B coverage under a sanitized PATH (no managed venv at <no locator>; …)
```

Consequences, measured:

- The `if` at line 614 can never be true, so `MANAGED_PYTHON` stays empty, the
  `-z` test short-circuits, and `bubbles_python_runs` is never reached.
- The `else` branch — six assertions including the three "teeth" that check the
  classifier really classified — is **unreachable under every environment**.
- The skip it records blames the locator. That diagnostic is false, and it is
  false in this bug's exact shape: an absent prerequisite, the unsourced module,
  is being reported as a statement about where the venv lives.

Attribution, checked rather than assumed:

```
$ git show HEAD:tests/regression/test_24_g028_sensitive_client_storage.sh | grep -n 'bubbles_python\|python-env'
  (none at HEAD -> the call sites are NEW in this working tree)
$ ls -d bugs/BUG-04*
  no BUG-040 packet exists
```

So this is in-flight work in this tree with no owning packet. It is left open
deliberately: repairing it would newly activate six assertions whose outcome is
not measured here, and that blast radius belongs to a declared packet rather
than a drive-by edit made while another validation run is in flight. Routed to
the parent runner, with the evidence above.

It does not invalidate the V1/V2/V3 or PE rows, which do not depend on that
block. It does mean T24's "2 skipped" should be read as one sound skip and one
unearned one.

## Finding Above — Now Repaired In-Boundary

The parent runner reviewed the routed finding, confirmed it independently, and
returned it for repair. `tests/regression/test_24_g028_sensitive_client_storage.sh`
is already in this packet's ratified `workBoundary.allowedPaths`, so no widening
was needed. Everything below was executed in that session.

### R1 — diagnosis reconfirmed before touching anything

```
$ grep -nE '^[[:space:]]*(source|\.)[[:space:]]+' tests/regression/test_24_g028_sensitive_client_storage.sh
24:source "$GUARD_LIB"
      (guard-lib only; python-env.sh is never sourced)

$ bash tests/regression/test_24_g028_sensitive_client_storage.sh </dev/null
T24_BASELINE_EXIT=0
test_24_g028_sensitive_client_storage: 57 passed, 0 failed, 2 skipped
line 1666: bubbles_python_home: command not found
line 1667: SKIP: managed selftest full Scan 2B coverage under a sanitized PATH
           (no managed venv at <no locator>; ...)
```

The machine state at that moment, which is what makes the skip message false:

```
locator OK: home=/Users/<operator>/.cache/bubbles/python
candidate=/Users/<operator>/.cache/bubbles/python/bin/python3
-x: yes · runs: yes · satisfies(yaml,jsonschema): yes
```

A provisioned, runnable, satisfying venv, reported as "no managed venv at
\<no locator\>". Both halves of that sentence were wrong.

**Baseline attribution.** `57 passed, 0 failed, 2 skipped` is the WORKING-TREE
baseline, not a HEAD baseline. The whole BUG-040 block is working-tree-only:

```
$ git show HEAD:tests/…/test_24….sh | wc -l        →  579
$ wc -l tests/…/test_24….sh                        →  671 (after repair)
$ git show HEAD:tests/…/test_24….sh | grep -c 'BUG-040 managed selftest'  →  0
```

### R2 — sourcing verified safe before relying on it

`python-env.sh` documents itself SOURCEABLE. That claim was checked, not taken:

```
$ out=$( set -uo pipefail; source bubbles/scripts/python-env.sh 2>&1; echo "SOURCE_RC=$?" )
SOURCE_RC=0
bytes emitted besides that line: 0

function-name collisions with guard-lib (16 fns) : none
function-name collisions with test_24's own 15 fns: none  (bubbles_python_* vs
  cleanup/pass/fail/skip/assert_*/line_for/run_scanner/write_*)
global collisions: python-env exports BUBBLES_PYTHON_{MODULES,LOCATOR_VARS,
  RUN_SENTINEL,RUNNABLE,RUNNABLE_REASON}; test_24 assigns none of them
set -u interaction: none — the module sets no shell options and every locator
  read is guarded (${VAR:-})
```

The `framework-validate.sh` caveat ("python-env.sh is EXECUTED, never sourced")
was read and does not apply: it is scoped to `repo-drift-report-selftest`'s
staged stub tree, where every sibling ends in `exit 0`. `test_24` sources from
the real `$REPO_ROOT/bubbles/scripts/`. The idiom used is the one already in
`implementation-reality-scan.sh:66` and, decisively,
`implementation-reality-scan-selftest.sh:19` — the very selftest this block
invokes.

### R3 — the repair

Two hunks, nothing else:

1. `PYTHON_ENV` added to the required-surface list and sourced after
   `guard-lib`. It is a REQUIRED surface, not a probed one: an absent module
   must refuse loudly, because refusing quietly is what produced this bug.
2. The skip reason split into three conditions that name themselves. The gate is
   unchanged — `bubbles_python_runs` already returns 1 for a non-executable
   path, so pulling the `-x` case out splits the REASON, never the decision.

### R4 — the six assertions on their first-ever execution

All six PASS. None was weakened, deleted, or re-disabled.

```
$ bash tests/regression/test_24_g028_sensitive_client_storage.sh </dev/null
T24_FIXED_EXIT=0
test_24_g028_sensitive_client_storage: 63 passed, 0 failed, 1 skipped

grep 'command not found'  → exit 1 (none)
grep '^FAIL:'             → exit 1 (none)

PASS: managed selftest runs with the system-only PATH and the managed interpreter
PASS: managed interpreter removes the classifier-unavailable degradation
PASS: managed interpreter leaves no skipped scenario group
PASS: managed interpreter runs the exact-approval semantic assertion
PASS: managed interpreter runs the unknown-provider semantic assertion
PASS: managed interpreter runs the config-integrity assertion
BUG013_GREEN_REGRESSION=SEMANTIC_STORAGE_CLASSIFICATION_SATISFIED
```

`57 → 63` passed and `2 → 1` skipped: exactly +6 assertions and −1 unearned
skip. The counts move by the amount the repair claims and by nothing else.

### R5 — non-vacuity

All mutations are ENVIRONMENT-only. No framework file was edited, deliberately:
a `v5.3-selftest.sh` run was in flight and mutating a script it reads could
corrupt it.

**Mutation A — my design error, recorded rather than hidden.** A `-S` wrapper
hiding `yaml`/`jsonschema` did NOT fail the block: `63 passed, 0 failed`. Cause:
`implementation-reality-scan.sh:714` resolves the classifier through
`bubbles_python_resolve_runnable`, which is stdlib-only by design, so PyYAML is
irrelevant to it. The experiment was wrong; the test was not.

**Mutation B — the one that bites.** An interpreter that answers a probe but
cannot run a program: forwards `-c` (the `bubbles_python_runs` sentinel) to a
real python so the gate OPENS, refuses everything else — including the
classifier helper, which is invoked as a script path.

```
gate: runs=YES → block ENTERED (grep '^SKIP: managed selftest full Scan 2B' → 0 hits)

$ BUBBLES_PYTHON_HOME=/tmp/bug039-probeonly bash tests/…/test_24….sh </dev/null
T24_MUTB_EXIT=1
test_24_g028_sensitive_client_storage: 29 passed, 34 failed, 1 skipped

FAIL: managed selftest runs with the system-only PATH and the managed interpreter (expected exit 0, got 1)
PASS: managed interpreter removes the classifier-unavailable degradation
PASS: managed interpreter leaves no skipped scenario group
FAIL: managed interpreter runs the exact-approval semantic assertion
FAIL: managed interpreter runs the unknown-provider semantic assertion
PASS: managed interpreter runs the config-integrity assertion
```

The block ran and 3 of 6 went red, including 2 of the 3 teeth. The suite exits
1. These assertions can fail.

**Mutations D/E/F — each skip reason names its own condition.** No message ever
claims "no managed venv" while a venv exists.

| Mutation | Condition | Skip reason emitted | exit |
|---|---|---|---|
| E | `BUBBLES_PYTHON_HOME`/`XDG_CACHE_HOME`/`HOME` all unset | `no locator names the managed venv (none of BUBBLES_PYTHON_HOME, XDG_CACHE_HOME, or HOME is set), so its path cannot be resolved` | 0 · 57/0/2 |
| D | locator resolves, dir empty | `no managed venv interpreter at /tmp/bug039-nonvenv/bin/python3` | 0 · 57/0/2 |
| F | interpreter present, does not execute (`/usr/bin/python3` shim) | `the managed venv interpreter at /tmp/bug039-unusable/bin/python3 is present but does not execute` | 0 · 57/0/2 |

**Revert.** Mutants deleted; no repo byte was ever mutated, so revert is
`git status` on the one intended file plus a rerun:

```
$ bash tests/…/test_24….sh </dev/null
T24_REVERT_EXIT=0
test_24_g028_sensitive_client_storage: 63 passed, 0 failed, 1 skipped
grep '^SKIP: managed selftest full Scan 2B' → no hits (block ran)
BUG013_GREEN_REGRESSION=SEMANTIC_STORAGE_CLASSIFICATION_SATISFIED
```

### R6 — verification, with attribution

| Command | Exit | Result |
|---|---|---|
| `bash tests/regression/test_24_g028_sensitive_client_storage.sh` | 0 | 63 passed, 0 failed, 1 skipped |
| `bash bubbles/scripts/python-env-selftest.sh` | 0 | `python-env selftest: 35 passed, 0 failed` — unchanged |
| `bash bubbles/scripts/implementation-reality-scan-selftest.sh` | 0 | `implementation-reality-scan selftest passed.` |
| `bash -n tests/regression/test_24_…sh` | 0 | parses |
| `shellcheck -x tests/regression/test_24_…sh` | 0 | clean |
| `shfmt -d -i 2 -ci -bn tests/regression/test_24_…sh` | 1 | 14 hunks — **pre-existing** |
| `bash bubbles/scripts/artifact-lint.sh bugs/BUG-039-…` | 0 | `Artifact lint PASSED.` |

shfmt attribution, measured rather than asserted: the HEAD copy produces the
same **14** hunks, and `shfmt -d … | grep -cE 'PYTHON_ENV|SKIP_REASON'` returns
**0** — none of the added lines is flagged. The findings are the file's
pre-existing `cat > "$X"` spacing and its missing trailing newline, both present
at HEAD and both outside this repair.

`framework-validate` and `release-check` were NOT run: excluded by operator
instruction because a `v5.3-selftest.sh` run was in flight.

## Summary

One missing prerequisite was being reported as eleven classification defects,
and the same dead interpreter was silently manufacturing twelve meaningless
passes. The scanner was correct throughout. The selftest now probes interpreter
**usability** rather than presence, skips the scenario group whose preconditions
cannot hold with a named cause and a concrete operator remediation, and emits a
sentinel so `test_24` records unmet coverage as a skip rather than a pass.
Mutation proves the assertions remain lethal whenever an interpreter exists.

The same defect shape was then found and repaired one level up. `test_24` called
the resolver without sourcing it, so its BUG-040 block was unreachable under
every environment and reported the absent function as a claim about where the
venv lives. Sourcing the module made six assertions executable for the first
time; all six pass, and mutation shows three of them — two of the three teeth —
go red against an interpreter that answers a probe but cannot run a program. The
skip that remains now names which of three conditions produced it.

## Completion Statement

Implementation and its evidence are complete and recorded above with real exit
codes. Certification is **not** claimed: `framework-validate` and
`release-check` were excluded by operator instruction and are owned by the
parent runner, and human acceptance has not been recorded. Status remains
`in_progress`.
