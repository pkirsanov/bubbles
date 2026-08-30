# Report: BUG-039

Sections through `## Completion Statement` preserve evidence from
earlier BUG-039 implementation runs. They are diagnostic input in this session,
not current-session execution proof. Their captured output remains unchanged.
Current-session evidence begins at `## Security Remediation SEC-B039-001..003`.

---

## 1. Machine Context

**Claim Source:** not-run

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

**Claim Source:** not-run

```
$ git status --short -- bubbles/scripts/implementation-reality-scan-selftest.sh \
                        bubbles/scripts/guards/sensitive-client-storage-scan.py \
                        tests/regression/test_24_g028_sensitive_client_storage.sh
(no output)
```

Confirms the defect is pre-existing, not introduced by in-flight work.

## 3. Bug Reproduction — Before Fix

**Claim Source:** not-run

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

**Claim Source:** not-run

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

**Claim Source:** not-run

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

**Claim Source:** not-run

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

**Claim Source:** not-run

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

**Claim Source:** not-run

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

**Claim Source:** not-run

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

**Claim Source:** not-run

`framework-validate` judges selftests by exit status
(`run_check "Discovered selftest: …" bash "$selftest_path"`), not by parsing
stdout. The contract it depends on is preserved: exit 0 when nothing failed,
exit 1 when something did. No other script parses this selftest's success
sentence.

## Test Evidence

**Claim Source:** not-run

Every figure below was produced by a command executed in this session, on the
working tree as delivered. Runs over 40 lines went through
`bubbles/scripts/evidence-capture.sh`, whose emitted block carries the command,
the exit code, the line count and a sha256 over every line produced; the hash is
re-derivable with `--verify` using the pointer recorded beside each run.

### Verdict table

**Claim Source:** not-run

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

**Claim Source:** not-run

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

**Claim Source:** not-run

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

**Claim Source:** not-run

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

**Claim Source:** not-run

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

**Claim Source:** not-run

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

**Claim Source:** not-run

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

**Claim Source:** not-run

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

**Claim Source:** not-run

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

**Claim Source:** not-run

The parent runner reviewed the routed finding, confirmed it independently, and
returned it for repair. `tests/regression/test_24_g028_sensitive_client_storage.sh`
is already in this packet's ratified `workBoundary.allowedPaths`, so no widening
was needed. Everything below was executed in that session.

### R1 — diagnosis reconfirmed before touching anything

**Claim Source:** not-run

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

**Claim Source:** not-run

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

**Claim Source:** not-run

Two hunks, nothing else:

1. `PYTHON_ENV` added to the required-surface list and sourced after
   `guard-lib`. It is a REQUIRED surface, not a probed one: an absent module
   must refuse loudly, because refusing quietly is what produced this bug.
2. The skip reason split into three conditions that name themselves. The gate is
   unchanged — `bubbles_python_runs` already returns 1 for a non-executable
   path, so pulling the `-x` case out splits the REASON, never the decision.

### R4 — the six assertions on their first-ever execution

**Claim Source:** not-run

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

**Claim Source:** not-run

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

**Claim Source:** not-run

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

**Claim Source:** not-run

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

**Claim Source:** not-run

The prior implementation run stated that its implementation evidence was
complete while certification remained `in_progress`. The security review
invalidated that statement for the current candidate. It is retained here as
historical context and does not support acceptance, certification, or terminal
status in this session.

## Security Remediation SEC-B039-001..003

### Root-Cause Verification And RED Proof

**Phase:** implement
**Claim Source:** interpreted
**Interpretation:** The commands and failure lines are directly executed; the
mapping from those failures to the three security root causes is the analysis
recorded after the raw blocks.

The new tests were written before production remediation. Each executed the
real resolver, scanner, selftest, or cascade path and failed against the
starting candidate `3ad43cee9b54e4d8767b470b7ef3b1d343cfc1ee`.

```
# SEC-B039 RED python-env trust and diagnostic contract
$ bash bubbles/scripts/python-env-selftest.sh
exit: 1
lines: 43
sha256: bd2b6b7bde45831083f158511f1136140e89af4d5525613bd7761b4f57d17bc3
FAIL: A8: no-locator trust result was 'DECLINED|||'
FAIL: A8b: absent-interpreter trust result was 'DECLINED|||'
FAIL: A8c: silent-success trust result was 'DECLINED|||'
FAIL: A8d: malformed-probe trust result was 'DECLINED|||'
FAIL: A8e: Xcode-like trust result was 'DECLINED|||'
FAIL: A8f: healthy trust result was 'DECLINED|||'
python-env selftest: 35 passed, 6 failed
```

```
# SEC-B039 corrected RED classifier protocol and trust boundary
$ bash bubbles/scripts/implementation-reality-scan-selftest.sh
exit: 1
lines: 1337
sha256: f8fd75634527137407bb890571797f0e95d16c84cf7125d0efc3f443de9dbb6b
FAIL: No locator fails closed (expected scanner exit 1, got 0)
FAIL: Absent managed interpreter fails closed (expected scanner exit 1, got 0)
FAIL: probe-silent fails closed (expected scanner exit 1, got 0)
FAIL: probe-malformed fails closed (expected scanner exit 1, got 0)
implementation-reality-scan selftest failed with 28 issue(s).
```

```
# SEC-B039 RED deterministic sentinel cascade
$ bash tests/regression/test_24_g028_sensitive_client_storage.sh
exit: 1
lines: 4317
sha256: c805c6afa403b9f1a07501b308de0d4f750afcf878fc4db2e5112a7298a33714
FAIL: managed selftest runs with the system-only PATH and the managed interpreter
=== BUG-013 regression summary ===
test_24_g028_sensitive_client_storage: 62 passed, 4 failed, 0 skipped
```

These failures independently confirmed all three reported roots: security
consumers accepted probe-passing ambient executables, successful but incomplete
classifier output had no completion contract, and the sentinel cascade depended
on host Python state.

### Protocol And Trust Design

**Phase:** implement
**Claim Source:** interpreted
**Interpretation:** The design below describes the implemented control flow
observed in the committed source and exercised by the GREEN tests in the next
section.

- Security-sensitive resolution uses `managed-venv-only-v1`. The general
  `BUBBLES_PYTHON` and PATH resolver remains available to non-security callers,
  but Scan 2B never executes either as a trust root.
- Probe execution uses the repository's progress-aware portable timeout with a
  5-second idle limit, a 10-second absolute limit, process-group termination,
  and a one-block output file limit. Exit `124` remains distinct.
- Probe diagnostics expose only a numeric status and one closed reason enum.
  Captured executable output is never replayed. The Xcode signature maps to
  `XCODE_LICENSE_UNACCEPTED` while retaining numeric status `69`.
- Classifier execution uses a 15-second idle limit, a 120-second absolute limit,
  and a 4 MiB file/output ceiling. Stderr and malformed bytes stay in the
  private capture and are never printed.
- Protocol `SCS1` accepts only closed `FINDING` tuples followed by exactly one
  final `COMPLETE\tSCS1\t<count>` record. The driver increments the count only
  after the production helper returns from each source file. Empty, malformed,
  incomplete, duplicate, post-completion, and count-mismatched streams all
  degrade to the existing fail-closed unresolved findings.
- Valid `FINDING` tuple behavior remains compatible. A valid completion with
  zero findings is explicitly distinguishable from empty helper output.

### Deterministic Test Matrix And GREEN Proof

**Phase:** implement
**Claim Source:** interpreted
**Interpretation:** The three commands exited zero. Their persistent assertions
map each listed fixture to production resolver/scanner behavior; the bounded
hashes cover every emitted line, including assertions outside the retained
first and last windows.

The persistent tests cover no locator, absent managed interpreter, silent probe
success, malformed probe payload, Xcode-like exit `69`, probe hang, helper hang,
helper exit `73`, empty helper output, malformed record, missing completion,
duplicate completion, completion-count mismatch, valid zero-finding completion,
and a valid sensitive-storage finding before completion. The cascade supplies a
dead managed interpreter and a probe-passing ambient substitute, so it reaches
the skip branch independently of the host interpreter. Its counter assertion
fails if that branch calls `pass()` instead of `skip()`.

```
# SEC-B039 final committed-candidate Python environment matrix
$ /bin/bash bubbles/scripts/python-env-selftest.sh
exit: 0
lines: 44
sha256: 80e71904790f1d63306d34acdaafc76c7e1a1a90247a3e78b1b1b8499e2d9e46
PASS: A8: trusted resolver refuses override/PATH candidates when no managed locator exists
PASS: A8b: trusted resolver names an absent managed interpreter
PASS: A8c: silent-success probe is rejected with its numeric status
PASS: A8d: malformed probe payload is rejected by the closed protocol
PASS: A8e: Xcode-like failure retains exit 69 as a sanitized reason enum
PASS: A8f: managed interpreter with the exact probe protocol is trusted
PASS: A8g: hanging interpreter is terminated with portable timeout status 124
python-env selftest: 42 passed, 0 failed
```

```
# SEC-B039 Bash 3.2 nested-timeout-free classifier matrix
$ /bin/bash bubbles/scripts/implementation-reality-scan-selftest.sh
exit: 0
lines: 1767
sha256: cdec519891c2342eb14db7d88ebe94b8e31cdd63e93ab825fde838cb9557fea4
Files scanned:  1
Violations:     0
Warnings:       0
🟢 PASSED: No source code reality violations detected
PASS: Classifier remains reusable after both watchdog timeouts
PASS: Post-timeout classifier completes its protocol
implementation-reality-scan selftest passed.
```

```
# SEC-B039 final deterministic G028 cascade under macOS Bash 3.2
$ /bin/bash tests/regression/test_24_g028_sensitive_client_storage.sh
exit: 0
lines: 4463
sha256: 5ef6a794598c32bf5bb4b74fb9cb45819cf190a4c2302ed7c388c613bc39816e
PASS: Classifier remains reusable after both watchdog timeouts
PASS: Post-timeout classifier completes its protocol
implementation-reality-scan selftest passed.
test_24_g028_sensitive_client_storage: 67 passed, 0 failed, 1 skipped
BUG039_DETERMINISTIC_CASCADE_VERIFIED=1
BUG013_GREEN_REGRESSION=SEMANTIC_STORAGE_CLASSIFICATION_SATISFIED
```

### Bash And Boundary Checks

**Phase:** implement
**Command:** `/bin/bash -n` on all five changed shell files; `shellcheck -x -S warning` on the same files; `git diff --check`
**Exit Code:** 0
**Claim Source:** executed

```
FINAL_BASH32_SYNTAX_EXIT=0
FINAL_WARNING_SHELLCHECK_EXIT=0
FINAL_SOURCE_TEST_DIFF_CHECK_EXIT=0
WORK_BOUNDARY_ALL_CHANGED_PATHS_EXIT=0
disposition=in-boundary
repoMatch=true
reason=candidate repo 'bubbles' is within repositoryRoots and within any declared spec/path scope
SOURCE_TEST_STAGED_DIFF_CHECK_EXIT=0
SOURCE_TEST_COMMIT_EXIT=0
```

The source/test commit is
`7573d8812f1ef8d676bd5501d3889a075927e459`, with parent
`3ad43cee9b54e4d8767b470b7ef3b1d343cfc1ee`.

### Artifact And Traceability Checks

**Phase:** implement
**Claim Source:** executed

The first artifact-lint run correctly rejected the renamed completion heading.
The heading was restored without changing the non-terminal statement, and the
rerun passed. The traceability guard retained all four scenario edges.

```
[claim-source-lint] OK — every execution-evidence block carries a valid Claim Source tag
CLAIM_SOURCE_LINT_EXIT=0
# SEC-B039 artifact lint after report provenance repair
exit: 1
lines: 40
sha256: 242bfb4fe37bb3b9973fd6412c9f5a8622248e21e53a33de02e0c6f706b9c195
❌ report.md missing required section matching: ###[[:space:]]+Completion Statement|^##[[:space:]]+Completion Statement
Artifact lint FAILED with 1 issue(s).
# SEC-B039 artifact lint after canonical completion heading repair
exit: 0
lines: 40
sha256: 182cf27f7948b167f9fdebccae5bf6994636355face5d8ae0a4d55666dc9b567
Artifact lint PASSED.
REPAIRED_ARTIFACT_LINT_EXIT=0
```

```
# SEC-B039 traceability guard after security remediation
$ bash bubbles/scripts/traceability-guard.sh bugs/BUG-039-interpreter-unusable-misreported-as-classification-failure
exit: 0
lines: 55
sha256: f5ae6bc9557936a61c323ef066fe53c63ba9b99d2f7c481b5b6c90cfcbe3f026
✅ scenario-manifest.json covers 4 scenario contract(s)
ℹ️  Scenarios checked: 4
ℹ️  Test rows checked: 4
ℹ️  Scenario-to-row mappings: 4
ℹ️  Concrete test file references: 4
ℹ️  Report evidence references: 4
ℹ️  DoD fidelity scenarios: 4 (mapped: 4, unmapped: 0)
ℹ️  Edge confidence (IMP-015 Scope B): declared=8 inferred=0 ambiguous=0
RESULT: PASSED (0 warnings)
TRACEABILITY_GUARD_EXIT=0
```

### Planning Artifact Reconciliation Required

**Phase:** implement
**Claim Source:** interpreted
**Interpretation:** The implementation and tests now enforce a stricter security
contract than the active planner-owned text. This agent did not modify those
foreign-owned artifacts or validate-owned certification.

| Artifact | Exact contradiction | Owner |
|---|---|---|
| `spec.md` | Requirements 1 and 2 require an interpreter path and arbitrary underlying diagnostic. The implementation emits numeric status plus a closed diagnostic enum and trusts only the managed venv. The success signal also requires full gates excluded from this invocation. | `bubbles.analyst` |
| `design.md` | The active text describes `$BUBBLES_PYTHON → managed venv → PATH`, raw probe output, and active developer-directory reporting. It must describe `managed-venv-only-v1`, bounded captures, `SCS1`, and no raw stderr replay. | `bubbles.design` |
| `scopes.md` | The four scenarios and Test Plan omit deterministic hostile interpreter/protocol fixtures. All DoD boxes remain checked against prior evidence even though certification is `in_progress` and the security contract changed. | `bubbles.plan` |
| `uservalidation.md` | The checklist is host-dependent, asks for raw diagnostics, records acceptance-style checked boxes, and expects `57 passed`; the current persistent regression reports `67 passed, 0 failed, 1 skipped`. | `bubbles.plan` |
| `scenario-manifest.json` | The four declared edges remain present, but their negative-control text still describes the old presence-only and host-toolchain behavior rather than the deterministic trust/protocol fixtures. | `bubbles.plan` |

Certification remains untouched and `in_progress`. No human acceptance or
terminal completion is claimed. Full `framework-validate` and `release-check`
were not run because this invocation explicitly excludes them.

<!-- BUG-039-ACTIVE-EPOCH-BEGIN -->

## Scope 2 TP-S2-01 RED Controls — Privileged Native Supervision

**Phase:** test
**Claim Source:** interpreted
**Interpretation:** The commands below directly establish candidate identity,
test exits, and named RED signals. The one-to-one finding mapping follows the
active Scope 2 contract. This is RED prerequisite evidence, not delivered
behavior and not a checked Definition of Done item.

### Candidate And Change Boundary

- Planning parent: `39ee0b639c13c8fd798f7a2a3ebf9c99a5438820`.
- Clean successor source commit: `72bbb987ef6c396ba00b1e6b94b95526d230e1a5`.
- Active epoch: `privileged-native-supervision-v2`.
- Retained worker trust: `root-protected-native-python-v1`.
- Candidate identity: planning parent plus the four test-file hashes recorded
  in the final static proof below. The immutable commit is recorded after Git
  creates it, in the result envelope, because a commit cannot contain its own
  object ID.
- Production files changed by TP-S2-01: none.
- Test/evidence files in the candidate: `bubbles/scripts/python-env-selftest.sh`,
  `bubbles/scripts/implementation-reality-scan-selftest.sh`,
  `tests/regression/test_24_g028_sensitive_client_storage.sh`,
  `bubbles/scripts/state-transition-guard-selftest.sh`, and this report.

Pre-edit identity capture:

```text
# BUG-039 TP-S2-01 pre-edit identity
exit: 0
lines: 41
sha256: 5121c5c795ef90416b21058e63cba7fc626fd67a7ac6d2f71d2e99b07dccf76b
ROOT=/private/tmp/bubbles-bug039-native-supervisor
HEAD=39ee0b639c13c8fd798f7a2a3ebf9c99a5438820
PARENT=72bbb987ef6c396ba00b1e6b94b95526d230e1a5
BRANCH=fix/bug039-native-supervisor
STATUS_EXIT=0
python-env.sh HEAD_BLOB=dec20d81b693d20ad8347fb2d7696553a440aeed
implementation-reality-scan.sh HEAD_BLOB=2fd7597b95c3ecd1c1d2798c4199f13e414a85e3
state-transition-guard.sh HEAD_BLOB=2665c6e34ec9a9876e0c48d96897988500a8a742
Every source blob matched HEAD^.
```

Immediately before this append, all five production inputs remained byte-equal
to `HEAD`:

```text
python-env.sh=78cd93af204a868ad98725104161d00d6d10414c4142bd03597fc1000f222e1e
implementation-reality-scan.sh=ad76539ffb3f815491cefecc2c76f010cabb02ed620c7d77daf7786061cdc5b8
cli.sh=a24bd78cb9e1cec772b2b9b4eee8d670dd68d4f2c75ce07e66e2b270b6c8dec8
state-transition-guard.sh=1f42f6d5a96a464fd622c2d39b341eed07967499a9fb4869b6752d13d75367b0
sensitive-client-storage-scan.py=77a02ff179d529812d75cfa223bef5f9f171a9169dce050ab46fb2f1f0834df3
UNCHANGED_FROM_HEAD=0 for all five paths
```

### Five-Finding RED Map

| Finding | Scenario | Intended RED signal on source commit `72bbb987` |
| --- | --- | --- |
| `SEC-R1` | `SCN-B039-005` | Hostile `BASH_ENV` and exported `source` cross the copied canonical CLI caller. Both runs exit 73 after one scanner-source marker; the scanner has no pre-source `compat-reexec`; Check 16 still invokes ordinary Bash. |
| `SEC-R2` | `SCN-B039-006` | Production reports zero fixed Perl-supervisor, `fork`, `waitpid`, `BPS1`, unreaped-owner guard, and boundary API signals. The closed operation-vector control remains green. |
| `HAR-R1` | `SCN-B039-007` | Production carries 32 Bash worker/FIFO-authority references, no supervisor wait handle, no supervisor reap/clear order, and no post-reap pending-signal return point. |
| `HAR-R2` | `SCN-B039-008` | Forged control becomes `CONTROL_MALFORMED` instead of an independent supervisor timeout; worker-closed control returns `OK` early; a descriptor-holding descendant drives FIFO timeout instead of direct-worker completion. Static control reports 12 worker-held FIFO/EOF references and no `waitpid` or `BPS1`. |
<!-- BUG-039-REPORT-ARCHIVE-BEGIN -->
| `HAR-R3` | `SCN-B039-009` | The active-window scan reports five stale `BPY1` source/test lines while every current identifier and current epoch/trust label is present. Its negative control allows archive-bracketed historical labels and rejects one active stale-label mutation. |
<!-- BUG-039-REPORT-ARCHIVE-END -->

### Intended RED Execution

**Command:** externally bounded `/bin/bash bubbles/scripts/python-env-selftest.sh`
with fixed `PATH` and `DEVELOPER_DIR=/Library/Developer/CommandLineTools`.
**Exit Code:** 1
**Claim Source:** executed

```text
# BUG-039 TP-S2-01 immutable python-env RED candidate
exit: 1
lines: 172
sha256: 69bb80f402ecc0a69f9f8e05e39e355370dc7df76dc6a06a566ed0fd063d8c59
FAIL: TP-S2-01 HAR-R2 worker cannot write supervisor control: scope2-forged-control result '125|CONTROL_MALFORMED|0|yes', expected '124|SUPERVISOR_TIMEOUT|1|yes'
FAIL: TP-S2-01 HAR-R2 pipe EOF cannot end the independent supervisor wall: scope2-early-eof result '0|OK|0|yes', expected '124|SUPERVISOR_TIMEOUT|1|yes'
FAIL: TP-S2-01 HAR-R2 descriptor-holding descendant cannot delay direct-worker completion: scope2-descriptor-descendant result '124|CONTROL_TIMEOUT|1|yes', expected '0|OK|0|yes'
RED: TP-S2-01 SEC-R1 mode=bash-env callerExit=73 hostileScannerSources=1 missing=BSEC1/direct
RED: TP-S2-01 SEC-R1 mode=exported-functions callerExit=73 hostileScannerSources=1 missing=BSEC1/direct
RED: TP-S2-01 SEC-R1 scannerCompatLine=absent firstSourceLine=46 missing=compat-reexec/env-i/bash-p
RED: TP-S2-01 SEC-R2 perl=0 supervisorContract=0 fork=0 waitpid=0 waitpidLine=absent BPS1=0 BPS1CompleteLine=absent unreapedSignalGuard=0 boundaryApi=0
RED: TP-S2-01 HAR-R1 bashWorkerAuthority=32 supervisorWaitHandle=0 waitLine=absent clearLine=absent pendingAfterReapLine=absent bashSignalsSupervisor=0 forbiddenLifecycle=0
RED: TP-S2-01 HAR-R2 workerControl=12 waitpid=0 BPS1=0
TP-S2-01_EPOCH=privileged-native-supervision-v2
TP-S2-01_RETAINED_WORKER_TRUST=root-protected-native-python-v1
python-env selftest: 119 passed, 9 failed
```

The TP-S2-01 failures are the expected RED set: three distinct `HAR-R2`
worker-channel adversaries plus aggregate failures for `SEC-R1`, `SEC-R2`,
`HAR-R1`, and `HAR-R2`. The other failure-shaped lines belong to existing
internal mutation children that the outer selftest expects and records as
passing negative controls.

**Command:** externally bounded targeted
`/bin/bash bubbles/scripts/state-transition-guard-selftest.sh --internal-bug039-scope2-red-controls privileged-native-supervision-v2`.
**Exit Code:** 1
**Claim Source:** executed

```text
# BUG-039 TP-S2-01 immutable Check16 HAR-R3 candidate
exit: 1
lines: 10
sha256: 354915fa613cf5335afc7ec093d44c72091906feafd3a09087fe79156dca9f9f
RED: TP-S2-01 SEC-R1 Check16 missing=env-i/bash-p/BSEC1-direct ordinary-bash-caller=present
FAIL: TP-S2-01 SEC-R1: transition-guard Check 16 still launches the scanner through ordinary Bash
RED: TP-S2-01 HAR-R3 staleActiveLines=5 missingCurrentIdentifiers=0 epoch=privileged-native-supervision-v2
FAIL: TP-S2-01 HAR-R3: active source/tests still carry stale finding, protocol, or epoch identifiers
PASS: TP-S2-01 HAR-R3 negative control: archived labels are allowed and one active stale-label mutation is rejected
TP-S2-01_STATE_GUARD_EPOCH=privileged-native-supervision-v2
TP-S2-01_STATE_GUARD_RETAINED_WORKER_TRUST=root-protected-native-python-v1
state-transition-guard BUG-039 Scope 2 RED summary: failures=2
```

### Preserved `SCN-B039-001` Through `SCN-B039-004` Controls

**Command:** externally bounded
`/bin/bash bubbles/scripts/implementation-reality-scan-selftest.sh` with fixed
environment.
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-039 TP-S2-01 immutable scanner control candidate
exit: 0
lines: 1708
sha256: d56f2026467b947db1c60e0a757d48ebea1a5ae07f56b8ad4ef6000b4530b86a
IMPLEMENTATION_REALITY_SELFTEST_ZERO_ARGUMENT_ENTRY=FULL_SUITE
PASS: TEST-B039-001 legacy SELFTEST_TARGET cannot select an ambient subset
PASS: Premature EXIT preserves fatal exit 1
PASS: Timeout exit preserves fatal exit 124
PASS: HUP interruption preserves fatal exit 129
PASS: TERM interruption preserves fatal exit 143
implementation-reality-scan selftest summary: failures=0 skips=0
BUG039_AUTHORIZED_CLASSIFIER_MUTATION_VERIFIED=1
IMPLEMENTATION_REALITY_SELFTEST_FULL_SUITE_COMPLETED=1
implementation-reality-scan selftest passed.
```

**Command:** externally bounded
`/bin/bash tests/regression/test_24_g028_sensitive_client_storage.sh` with fixed
environment.
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-039 TP-S2-01 immutable test_24 control candidate
exit: 0
lines: 4462
sha256: c35cd8eb51e2773350c67bacf78ddc5e99d8a4b167491c162fd54114be257f76
RED: NEG-B039-SENTINEL-TO-PASS mutant_exit=1 PASS_COUNT=1 SKIP_COUNT=0
PASS: NEG-B039-SENTINEL-TO-PASS copied skip-to-pass mutation turns counter accounting RED
BUG039_AUTHORIZED_CLASSIFIER_MUTATION_VERIFIED=1
PASS: authenticated root-protected runtime runs the managed selftest under system-only PATH
PASS: authenticated runtime removes classifier-unavailable degradation
PASS: authenticated runtime leaves no skipped scenario group
PASS: authenticated runtime preserves the authorized classifier mutation control
test_24_g028_sensitive_client_storage: 98 passed, 0 failed, 1 skipped
BUG039_DETERMINISTIC_CASCADE_VERIFIED=1
BUG039_UNAVAILABLE_PATH_VERIFIED=1
TEST24_FULL_SUITE_COMPLETED=1
BUG013_GREEN_REGRESSION=SEMANTIC_STORAGE_CLASSIFICATION_SATISFIED
```

The one skip is the deliberately forced unavailable-prerequisite branch. The
dedicated sentinel proves it executed, stayed separate from pass accounting,
and did not prevent the independent authenticated full-path run.

### TP-S2-01 Status

`TP-S2-01` remains unchecked by design. These tests establish the required RED
prerequisite only. They make no claim that privileged entry or native
supervision has been implemented. All five findings remain open for
`bubbles.implement`, with the exact test files above serving as the persistent
red-to-green contract.

### Test Candidate Identity And Static Proof

**Claim Source:** executed

```text
TP_S2_01_TEST_IDENTITY_BEGIN
PARENT=39ee0b639c13c8fd798f7a2a3ebf9c99a5438820
FILE=bubbles/scripts/python-env-selftest.sh
MODE=755
SHA256=9def8a9b221b694d4d893eca39f21840af2a4482214e939fd946b6d3096955bc
FILE=bubbles/scripts/implementation-reality-scan-selftest.sh
MODE=755
SHA256=3db38234b19302b3ff813c2dc2dd633255728fdb090482771502920ece743da7
FILE=tests/regression/test_24_g028_sensitive_client_storage.sh
MODE=644
SHA256=8cf2b8182c530d52cb1f3f8f4c54ef76c1d117459be961665a97b665205cb145
FILE=bubbles/scripts/state-transition-guard-selftest.sh
MODE=755
SHA256=00193b6210351ff71e04f97ee3160faf3ff7691de626351c4862b786bfbcaf53
TP_S2_01_TEST_IDENTITY_END
```

**Command:** stock-Bash syntax for all four tests, warning-level shellcheck,
`git diff --check`, and disabling-marker scan.
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-039 TP-S2-01 final static proof
exit: 0
lines: 10
sha256: f9db5c1f8774dd4370c4026e1125dbefbfd29739a1d40009bd9b9506ff3452b4
TP_S2_01_FINAL_STATIC_BEGIN
BASH_N_FILE=bubbles/scripts/python-env-selftest.sh
BASH_N_FILE=bubbles/scripts/implementation-reality-scan-selftest.sh
BASH_N_FILE=tests/regression/test_24_g028_sensitive_client_storage.sh
BASH_N_FILE=bubbles/scripts/state-transition-guard-selftest.sh
BASH_N_EXIT=0
SHELLCHECK_WARNING_EXIT=0
GIT_DIFF_CHECK_EXIT=0
DISABLING_MARKER_SCAN_EXIT=1
TP_S2_01_FINAL_STATIC_END
```

The disabling-marker command uses grep semantics: exit 1 means zero matches.
The earlier debt-token scan matched only the transition-guard selftest's
pre-existing Check 14 fixtures. It did not identify an added unfinished marker.

**Command:** `bash bubbles/scripts/regression-quality-guard.sh --bugfix` over
all four modified test files.
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-039 TP-S2-01 regression quality guard
exit: 0
lines: 21
sha256: a283d52de43c0a102d7d3f1d5deb63e96e866da9c35c39a543d78dea6e1c6bd5
Scanning bubbles/scripts/python-env-selftest.sh
Adversarial signal detected in bubbles/scripts/python-env-selftest.sh
Scanning bubbles/scripts/implementation-reality-scan-selftest.sh
Adversarial signal detected in bubbles/scripts/implementation-reality-scan-selftest.sh
Scanning tests/regression/test_24_g028_sensitive_client_storage.sh
Adversarial signal detected in tests/regression/test_24_g028_sensitive_client_storage.sh
Scanning bubbles/scripts/state-transition-guard-selftest.sh
Adversarial signal detected in bubbles/scripts/state-transition-guard-selftest.sh
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 4
Files with adversarial signals: 4
```

**Command:** `bash bubbles/scripts/cli.sh lint` for the BUG-039 packet.
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-039 TP-S2-01 artifact lint
exit: 0
lines: 40
sha256: 182cf27f7948b167f9fdebccae5bf6994636355face5d8ae0a4d55666dc9b567
Required artifact exists: spec.md
Required artifact exists: design.md
Required artifact exists: uservalidation.md
Required artifact exists: state.json
Required artifact exists: scopes.md
Required artifact exists: report.md
All checked DoD items in scopes.md have evidence blocks
No unfilled evidence template placeholders in scopes.md
No unfilled evidence template placeholders in report.md
Artifact lint PASSED.
```

### Residue Proof

**Command:** scan repository and temporary roots created at or after repository
binding epoch `1788077902`, then scan active test processes.
**Exit Code:** 0
**Claim Source:** executed

```text
TP_S2_01_CURRENT_RUN_RESIDUE_BEGIN
REPO_RESIDUE_BEGIN
REPO_RESIDUE_END
PROCESS_RESIDUE_BEGIN
PROCESS_RESIDUE_END
BINDING_CUTOFF_EPOCH=1788077902
RECENT_RESIDUE_COUNT=0
REPO_FIND_EXIT=0
PROCESS_SCAN_EXIT=1
TP_S2_01_CURRENT_RUN_RESIDUE_END
```

The process scan uses grep-style status: exit 1 means no matching test process.
The repository scan found no FIFO, `__pycache__`, `.pyc`, or `.pyo`. The bounded
temporary scan found no current-run private root, FIFO, capture directory, or
mutation fixture. Older global temporary directories predated the authoritative
binding epoch and were left untouched because they are not owned by this run.

### TP-S2-01 Test Contract Correction

**Phase:** test
**Claim Source:** interpreted
**Interpretation:** The parent executed the functional correction receipts on
the exact three-path dirty tree. This invocation reran only static and residue
checks. The correction repairs test meaning and does not establish production
implementation.

The earlier TP-S2-01 RED receipts remain intact above. This correction
supersedes only their test-contract interpretation. It neither erases their
observed RED state nor converts any production finding to green.

#### Correction Dispositions

| Finding | Disposition | Corrected contract |
| --- | --- | --- |
| `TST-R1` | Addressed | The historical Bash worker and FIFO mutation builder is replaced by native `BPS1` and Perl lifecycle mutations. Missing preimplementation anchors emit intended RED findings. They do not emit a setup failure. Mutation construction starts only after the future contract anchors exist. |
| `TST-R2` | Addressed | The security-specific suite executes through a real empty environment and privileged `/bin/bash -p`. Its setup marker proves hostile `BASH_ENV` and exported functions did not enter. General tests retain ordinary execution. |
| `TST-R3` | Addressed | Report archive markers exclude only bracketed historical labels. The same stale label remains detectable outside the archive. Nested, unclosed, and unmatched markers fail closed. |

#### Parent-Executed Correction Receipts

**Phase:** test
**Claim Source:** executed
**Execution attribution:** These receipts came from the current parent
`bubbles.test` execution named in the dispatch. This invocation did not present
them as its own reruns.

```text
PARENT_CORRECTION_RECEIPTS_BEGIN
STATIC_EXIT=0
STATIC_SIGNAL=TEST_CONTRACT_STATIC_FAILURES=0
STATIC_SHA256=not-emitted-in-dispatch
TARGETED_TRANSITION_RED_EXIT=1
TARGETED_TRANSITION_RED_LINES=11
TARGETED_TRANSITION_RED_SHA256=571f86ec8363c9906cbec3875c678dd561390ebc8a07c7068f9710e4600ddcbd
TARGETED_TRANSITION_RED_FAILURES=SEC-R1-ordinary-Check16,HAR-R3-4-active-stale-lines
TARGETED_TRANSITION_ARCHIVE_DISCRIMINATION=PASS
TARGETED_TRANSITION_MALFORMED_MARKERS_FAIL_CLOSED=PASS
STOCK_BASH_PYTHON_RED_EXIT=1
STOCK_BASH_PYTHON_RED_LINES=96
STOCK_BASH_PYTHON_RED_SHA256=41a3056cc1d2af48ff6061516f12cfe31efee59a941da4cba6d46fc69adfedeb
GENERAL_SUITE_SUMMARY=51-passed,7-missing-production-failures
PRIVILEGED_CHILD_SETUP=PASS
PRIVILEGED_SECURITY_SUMMARY=0-passed,9-intended-missing-production-failures
PRIVILEGED_SECURITY_CONTRADICTION_FAILURES=0
PRIVILEGED_SECURITY_SETUP_FAILURES=0
PRIVILEGED_SECURITY_TEST_CONTRACT_FAILURES=0
REGRESSION_QUALITY_EXIT=0
REGRESSION_QUALITY_LINES=17
REGRESSION_QUALITY_SHA256=597f53c2c61e49a8571b2e2f790e684b27c053892131babcdd0f064ad6181db4
REGRESSION_QUALITY_FILES=2
REGRESSION_QUALITY_ADVERSARIAL_SIGNALS=2
REGRESSION_QUALITY_VIOLATIONS=0
REGRESSION_QUALITY_WARNINGS=0
PARENT_PROCESS_RESIDUE_COUNT=0
PARENT_REPO_RESIDUE_COUNT=0
PARENT_CORRECTION_RESIDUE_FAILURES=0
PARENT_RESIDUE_EXIT=0
PARENT_RESIDUE_SHA256=not-emitted-in-dispatch
PARENT_CORRECTION_RECEIPTS_END
```

The targeted transition receipt fails only the ordinary Check 16 production
entry and four active stale-label lines. Its archive discrimination control
passes. All three malformed-marker controls also fail closed.

The stock-Bash receipt separates setup from production RED. The privileged
child setup passes. Its inner suite reports nine intended missing-production
failures, zero contradiction failures, and no setup or test-contract failure.

#### Current-Invocation Static Recheck

**Phase:** test
**Command:** bounded macOS Bash 3.2 syntax, modern Bash syntax, warning-level
ShellCheck, and `git diff --check` over the three authorized paths.
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-039 TP-S2-01 correction static recheck
exit: 0
lines: 12
sha256: 6293f5f3e20ead6cee6a0633858b69e7c9fe8e39465aac72ec550815541bc6c4
TEST_CONTRACT_STATIC_BEGIN
STATIC_FILE=bubbles/scripts/python-env-selftest.sh
BASH32_SYNTAX_EXIT=0
MODERN_BASH_SYNTAX_EXIT=0
STATIC_FILE=bubbles/scripts/state-transition-guard-selftest.sh
BASH32_SYNTAX_EXIT=0
MODERN_BASH_SYNTAX_EXIT=0
SHELLCHECK_PATH=/opt/homebrew/bin/shellcheck
SHELLCHECK_WARNING_EXIT=0
GIT_DIFF_CHECK_EXIT=0
TEST_CONTRACT_STATIC_FAILURES=0
TEST_CONTRACT_STATIC_END
```

#### Current-Invocation Residue Recheck

**Phase:** test
**Command:** bounded active-process and repository FIFO, bytecode, and cache
scan for the isolated BUG-039 checkout.
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-039 TP-S2-01 correction residue recheck
exit: 0
lines: 7
sha256: b47eb47b8a3f09756ab9bfa9ddd21a7702fcf701afb9e64b0505175b3807074e
CORRECTION_RESIDUE_BEGIN
REPO_RESIDUE_SCAN_BEGIN
REPO_RESIDUE_SCAN_END
PROCESS_RESIDUE_COUNT=0
REPO_RESIDUE_COUNT=0
CORRECTION_RESIDUE_FAILURES=0
CORRECTION_RESIDUE_END
```

#### Production Status After The Test Correction

**Phase:** test
**Claim Source:** interpreted
**Interpretation:** Passing setup and test-contract controls prove that the RED
failures now identify absent production invariants. They do not prove those
invariants exist.

`SEC-R1`, `SEC-R2`, `HAR-R1`, `HAR-R2`, and `HAR-R3` remain RED for production.
No implementation-green result is claimed. `TP-S2-01` remains unchecked, and
the production findings remain owned by `bubbles.implement`.

## TP-S2-01 BSD awk oracle correction

### Immutable failed receipt

**Phase:** test
**Claim Source:** not-run

The prior stock-Bash run remains immutable diagnostic input. It exited 1 after
119 lines with output SHA-256
`6b367b1454ac132ae7bbbc38b5eb0131e668f42efb85dd63ba4cdea9765713d0`.
Its BSD `/usr/bin/awk: newline in regular expression` diagnostic caused the
consequent `TEST-CONTRACT` failure. This invocation did not relabel that run.

### Corrected oracle and current execution

**Phase:** test
**Claim Source:** executed

The corrected `bubbles/scripts/python-env-selftest.sh` SHA-256 is
`76aaf240552b2f9b38b9b2c241a9cb8782cc78ae7f5063fc18c83556c1a4c35f`.
The oracle constructs the literal single-quote pair and matches it with
`index()`. Its strengthened ordering checks cover supervisor launch, reap,
wait-handle clear, cleanup, late owner clear, post-reap signal, worker-authored
completion, and caller authority.

```text
# BUG-039 TP-S2-01 BSD awk oracle static validation
exit: 0
lines: 7
sha256: 60daeeda90f8ac971b93a66e0b738cbcf8bfe453a98b49f29a61f8148cfc644f
BSD_AWK_ORACLE_EXIT=0
STOCK_BASH_SYNTAX_EXIT=0
MODERN_BASH_SYNTAX_EXIT=0
SHELLCHECK_WARNING_EXIT=0 BIN=/opt/homebrew/bin/shellcheck
TEST_DIFF_CHECK_EXIT=0
TEST_CORRECTION_SHA256=76aaf240552b2f9b38b9b2c241a9cb8782cc78ae7f5063fc18c83556c1a4c35f
STATIC_VALIDATION_EXIT=0
```

The full stock macOS `/bin/bash` contract ran exactly once after those test
bytes changed. It exited 0 after 149 lines with output SHA-256
`439793581cb9465b84778142ef0cd2e45341fbdb6e1753f331d9d6773da1c61e`.
The captured output contains no failure-shaped section or BSD awk syntax
diagnostic. It ends with `66 passed, 0 failed` for the general suite and
`58 passed, 0 failed` for the privileged security suite. The setup signal is a
`PASS`; no `SETUP` failure or `TEST-CONTRACT` failure was observed.

### Disposition

**Phase:** test
**Claim Source:** interpreted
**Interpretation:** The corrected stock-Bash test contract is green on the
current production bytes. This proves `TST-R4` is addressed. It does not certify
the production implementation or close its owner-controlled change set.

The remaining production-owned findings are exactly `SEC-R1`, `SEC-R2`,
`HAR-R1`, `HAR-R2`, and `HAR-R3`. Their disposition remains with
`bubbles.implement`.

## TP-S2-01 self-contained SEC-R1 mutant correction

### Prior red receipt preservation

**Phase:** test
**Claim Source:** not-run

The two prior receipts were supplied by the operator as diagnostic input. This
invocation did not relabel them as current execution evidence:

- Full scanner selftest: exit 1, 1,743 lines, SHA-256
  `c90f44cf3e8e25ed713d82120baa40239169dedc84b259a51897484bec072e1a`.
- Focused authority diagnostic: exit 1, 107 lines, SHA-256
  `65d5483c9643c350e7460f2bf0865c2ff389e58d7d9ca2d47ae21e10f199b206`.

Both receipts identified the copied SEC-R1 mutant aborting after privileged
`env -i` removed its two ambient fixture-path variables. They remain the RED
side of this test-fixture correction.

### Test-owned correction and mechanism

**Phase:** test
**Claim Source:** executed

The changed selftest SHA-256 is
`884c52cd70b1289769c21ec93ca57290ac28f9e65bc18e770d789c4b6e848464`.
The harness now validates each embedded fixture path as absolute, no longer than
4,096 bytes, and free of tab, carriage return, and newline. Stock Bash 3.2
`printf -v ... %q` creates shell-safe literal words. The construction-only AWK
environment carries those quoted words into the copied file. The copied mutant
does not read either path from its runtime environment.

**Test mechanism:** the copied `python-env.sh` replaces exactly one path
authentication branch, forces exactly one caller-owned candidate branch, and
runs through the copied production scanner's real compatibility re-entry. The
mutant writes `B039_AUTH_ENV_ABSENT` through its embedded trace path before it
forges clean `SCS1` output.

**Negative control:** requiring either fixture path from the ambient environment
would abort after production `env -i`, leaving no compromise marker or clean
classifier result. Preserving path authentication would reject the caller-owned
candidate and keep the real sensitive-storage finding.

### Static validation

**Phase:** test
**Command:** `/bin/bash -n bubbles/scripts/implementation-reality-scan-selftest.sh`; `/opt/homebrew/bin/bash -n bubbles/scripts/implementation-reality-scan-selftest.sh`; `/opt/homebrew/bin/shellcheck -S warning -x bubbles/scripts/implementation-reality-scan-selftest.sh`; `git diff --check -- bubbles/scripts/implementation-reality-scan-selftest.sh bugs/BUG-039-interpreter-unusable-misreported-as-classification-failure/report.md`; `/opt/homebrew/bin/bash bubbles/scripts/regression-quality-guard.sh --bugfix bubbles/scripts/implementation-reality-scan-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-039 TP-S2-01 self-contained SEC-R1 mutant static validation
exit: 0
lines: 24
sha256: de306e8a5521b74b50d4d052f1d0998f57972bdad1813cd3cf7d74945a21adab
STATIC_VALIDATION_BEGIN
STOCK_BASH_SYNTAX_EXIT=0
MODERN_BASH_SYNTAX_EXIT=0
SHELLCHECK_WARNING_EXIT=0
DIFF_CHECK_EXIT=0
============================================================
  BUBBLES REGRESSION QUALITY GUARD
  Repo: /private/tmp/bubbles-bug039-native-supervisor
  Timestamp: 2026-08-30T11:41:34Z
  Bugfix mode: true
============================================================

ℹ️  Scanning bubbles/scripts/implementation-reality-scan-selftest.sh
✅ Adversarial signal detected in bubbles/scripts/implementation-reality-scan-selftest.sh

============================================================
  REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
  Files scanned: 1
  Files with adversarial signals: 1
============================================================
REGRESSION_QUALITY_EXIT=0
884c52cd70b1289769c21ec93ca57290ac28f9e65bc18e770d789c4b6e848464  bubbles/scripts/implementation-reality-scan-selftest.sh
STATIC_VALIDATION_FAILURES=0
STATIC_VALIDATION_END
```

### Full stock-Bash verification

**Phase:** test
**Command:** `/usr/bin/env -u BUBBLES_AUTHORITY_BYPASS_CANDIDATE -u BUBBLES_AUTHORITY_BYPASS_TRACE -u BUBBLES_PYTHON_SELFTEST_CHILD_MODE -u BUBBLES_PYTHON_SELFTEST_READY_FILE -u BUBBLES_PYTHON_SELFTEST_NEGATIVE_CONTROL -u BUBBLES_PYTHON_LATE_SIGNAL_NAME -u BUBBLES_PYTHON_SELFTEST_LATE_ROOT_RECORD -u BUBBLES_PYTHON_MUTANT_WINDOW_READY -u BUBBLES_PYTHON_MUTANT_WINDOW_RELEASE -u BUBBLES_PYTHON_MUTANT_ROOT_RECORD -u BUBBLES_PYTHON_MUTANT_TRACE -u BUBBLES_SELFTEST_REAL_PYTHON -u BUBBLES_IMPLEMENTATION_REALITY_SELFTEST_TARGET -u BUBBLES_IMPLEMENTATION_REALITY_SELFTEST_CHILD_MODE -u BUBBLES_IMPLEMENTATION_REALITY_SELFTEST_READY_FILE -u BUBBLES_MUTATION_RUNNER_ROOT_RECORD -u BUBBLES_TEST24_CHILD_MODE -u BUBBLES_TEST24_NEGATIVE_CONTROL -u BUBBLES_TEST24_LIFECYCLE_CHILD_MODE -u BUBBLES_TEST24_READY_FILE PATH=/opt/local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin DEVELOPER_DIR=/Library/Developer/CommandLineTools /opt/local/bin/gtimeout --signal=TERM --kill-after=300s 7200 /bin/bash bubbles/scripts/implementation-reality-scan-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

The full stock macOS Bash 3.2 selftest ran exactly once after the test byte
change. The bounded capture covered every one of its 1,742 output lines. The
block below retains selected exact signals from the returned first and last
capture windows; the SHA-256 covers the complete output.

```text
# BUG-039 TP-S2-01 self-contained SEC-R1 mutant full stock Bash
exit: 0
lines: 1742
sha256: ead4155f7e08874c7e3f4f9e8820cf980c1b90fa3926f505c721bdfed8f7ac74
Scenario: TEST-B039-001 inherited subset selectors cannot replace the full-suite entrypoint.
IMPLEMENTATION_REALITY_SELFTEST_ZERO_ARGUMENT_ENTRY=FULL_SUITE
PASS: TEST-B039-001 legacy SELFTEST_TARGET cannot select an ambient subset
Scenario: premature and interrupted selftest exits fail closed while cleaning up.
PASS: Premature EXIT preserves fatal exit 1
PASS: Premature EXIT removes its temporary tree
PASS: Premature EXIT emits no success summary
PASS: Timeout exit preserves fatal exit 124
PASS: Timeout exit removes its temporary tree
PASS: Timeout exit emits no success summary
PASS: Classifier remains reusable after both watchdog timeouts
PASS: Post-timeout classifier completes its protocol
PASS: Post-timeout real producer leaves the helper directory clean
implementation-reality-scan selftest summary: failures=0 skips=0
BUG039_AUTHORIZED_CLASSIFIER_MUTATION_VERIFIED=1
IMPLEMENTATION_REALITY_SELFTEST_FULL_SUITE_COMPLETED=1
implementation-reality-scan selftest passed.
```

### Exact SEC-R1 authority proof

**Phase:** test
**Command:** `/usr/bin/env -u BUBBLES_AUTHORITY_BYPASS_CANDIDATE -u BUBBLES_AUTHORITY_BYPASS_TRACE -u BUBBLES_PYTHON_SELFTEST_CHILD_MODE -u BUBBLES_PYTHON_SELFTEST_READY_FILE -u BUBBLES_PYTHON_SELFTEST_NEGATIVE_CONTROL -u BUBBLES_PYTHON_LATE_SIGNAL_NAME -u BUBBLES_PYTHON_LATE_ROOT_RECORD -u BUBBLES_PYTHON_MUTANT_WINDOW_READY -u BUBBLES_PYTHON_MUTANT_WINDOW_RELEASE -u BUBBLES_PYTHON_MUTANT_ROOT_RECORD -u BUBBLES_PYTHON_MUTANT_TRACE -u BUBBLES_SELFTEST_REAL_PYTHON -u BUBBLES_IMPLEMENTATION_REALITY_SELFTEST_TARGET -u BUBBLES_IMPLEMENTATION_REALITY_SELFTEST_CHILD_MODE -u BUBBLES_IMPLEMENTATION_REALITY_SELFTEST_READY_FILE -u BUBBLES_MUTATION_RUNNER_ROOT_RECORD PATH=/opt/local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin DEVELOPER_DIR=/Library/Developer/CommandLineTools /opt/local/bin/gtimeout --signal=TERM --kill-after=60s 780 /bin/bash bubbles/scripts/implementation-reality-scan-selftest.sh --internal-authority-bypass-control b039-authority-bypass-v1`
**Exit Code:** 0
**Claim Source:** executed

The diagnostic capture emitted 173 lines with SHA-256
`893eb4a99bbdbff5a5c607596507a6f66d6ac7ff202f78968e45a0993a907287`.
These selected proof signals preserve the exact compromise and setup results:

```text
PASS: SCN-B039-005 authority mutation fixture paths satisfy the closed absolute path grammar
PASS: SCN-B039-005 authority mutation changes exactly one authentication branch and forces one caller-owned candidate branch
  sensitive-storage classifier protocol complete: version=SCS1 scanned=1 findings=0 status=0 diagnostic=OK entry=BSEC1 entryMode=compat-reexec supervisor=root-protected-perl-supervisor-v1 supervisorProtocol=BPS1 runtimeDiagnostic=OK rejection=NONE candidates=1 trust=root-protected-native-python-v1 provenance=root-protected-path pathProtocol=PYSEC1 moduleProtocol=PYMOD1 classifierProtocol=SCS1
B039_AUTH_ENV_ABSENT
B039_AUTH_BYPASS|/bin/bash|executable|1
B039_AUTH_ENV_ABSENT
B039_AUTH_BYPASS|/usr/bin/env|executable|1
B039_AUTH_ENV_ABSENT
B039_AUTH_BYPASS|/usr/bin/perl|executable|1
PASS: SCN-B039-005 privileged copied scanner receives no authority-bypass path variables
PASS: SCN-B039-005 forced caller-owned runtime reaches the copied authentication bypass
PASS: SCN-B039-005 authority-bypass mutation makes forged clean output and marker assertions red
PASS: SCN-B039-005 authority mutation leaves live production bytes identical
implementation-reality-scan authority-bypass control summary: failures=0 skips=0
```

### Residue and protected-byte proof

**Phase:** test
**Claim Source:** executed

The first broad temporary-directory sweep exited 1 with SHA-256
`1e88569c58945b4a5bdf45043c9b2595dc4b47ecccfdc11244a901821fa6c68f`.
It encountered protected macOS service directories and identified five old
selftest roots. Each root was owned by UID 501, had mode 0700, was between
55,611 and 97,028 seconds old, and returned `lsof +D` exit 1. Their bounded
cleanup removed all five roots. The corrected direct-root sweep then passed.

**Command:** bounded direct-root signature scan, repository FIFO/cache scan, untracked-path scan, and SHA-256 comparison against the four protected production baselines
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-039 TP-S2-01 SEC-R1 clean residue and production integrity
exit: 0
lines: 12
sha256: 5023981fef699fcc50f203c7f83b33f2b10c9dcef3d9d2a65e3d31d401a687c5
CLEAN_RESIDUE_INTEGRITY_BEGIN
PROCESS_RESIDUE_COUNT=0
PRIVATE_ROOT_FIFO_MUTATION_RESIDUE_COUNT=0
REPOSITORY_FIFO_COUNT=0
REPOSITORY_PYTHON_CACHE_COUNT=0
UNTRACKED_PATH_COUNT=0
PRODUCTION_HASH_UNCHANGED=64e37a7299b28513fc8fab78ce0e686dad6630d04a65827fc79f30419003853a bubbles/scripts/python-env.sh
PRODUCTION_HASH_UNCHANGED=4eb25cbb959c37caaf4f835742128d837e08935b59cba793359ca2fd78a5e9fb bubbles/scripts/implementation-reality-scan.sh
PRODUCTION_HASH_UNCHANGED=00ec96982dbfc19d5e0616496c094cd642b9d7eae7353c45cc9b618c57df30e4 bubbles/scripts/cli.sh
PRODUCTION_HASH_UNCHANGED=cabce8c9d223dc4a3637dab649fe293867466b7c95fd28192e37820ddf83d07e bubbles/scripts/state-transition-guard.sh
CLEAN_RESIDUE_INTEGRITY_FAILURES=0
CLEAN_RESIDUE_INTEGRITY_END
```

### Ownership boundary

**Phase:** test
**Claim Source:** interpreted
**Interpretation:** The executed evidence addresses the SEC-R1 test-fixture
defect and proves the copied bypass can compromise classification without either
ambient fixture-path variable. It does not certify the four implementation-owned
production edits or close the production findings. Production disposition stays
with `bubbles.implement`.

## T24-R1 authenticated child real-interpreter handoff

### Immutable red receipt

**Phase:** test
**Claim Source:** interpreted
**Interpretation:** This preserves the operator-supplied prior-session result
as diagnostic RED context only. It is not current execution evidence.

The operator supplied the prior failed cascade as diagnostic input. This
invocation did not relabel it as current execution evidence. It exited 1 after
2,785 lines with SHA-256
`783c457cee054ac485a3255a045672f6a106a761eb20125bc5d66589aea239b0`.
Its summary was `93 passed, 5 failed, 1 skipped`. The five authenticated-child
failures remain the RED side of T24-R1.

### Test-only correction and security boundary

**Phase:** test
**Claim Source:** interpreted
**Interpretation:** The authenticated `env -i` child now receives the same
independently resolved producer interpreter as the deterministic unavailable
lane. The poisoned caller runtime remains present and is asserted inert.

The one-line handoff is exactly
`BUBBLES_SELFTEST_REAL_PYTHON="$SELFTEST_REAL_PYTHON"`. The authenticated lane
still passes the poisoned `BUBBLES_PYTHON` and `BUBBLES_PYTHON_HOME` values. It
passes no other ambient variable. New assertions require the poison marker to
remain absent and require authenticated `BSEC1` and `BPS1` path signals.

Security authority remains fixed and root-protected. It does not derive from
`BUBBLES_SELFTEST_REAL_PYTHON`. That variable supports only the child selftest's
real producer and classifier tests after the privileged boundary authenticates
the actual runtime.

### General resolver and handoff proof

**Phase:** test
**Command:** value-safe production resolver and exact-handoff probe recorded by
`bubbles/scripts/tool-log.sh` with tag `T24-R1,general-resolver,handoff-proof,corrected`
**Exit Code:** 0
**Claim Source:** executed

An initial richer probe exited 1 only because it incorrectly required a
nonempty diagnostic reason on resolver success. The corrected probe recognizes
that the production API leaves its reason empty on success. It did not rerun
the cascade.

```text
T24_R1_RESOLVER_HANDOFF_BEGIN
PRODUCTION_RESOLVER_MODULES_PRESENT=1
GENERAL_RESOLVER_API_PRESENT=1
GENERAL_RUNNABLE_PROBE_API_PRESENT=1
GENERAL_RESOLVER_EXIT=0
RESOLVED_INTERPRETER_NONEMPTY=1
RESOLVED_INTERPRETER_EXECUTABLE=1
RESOLVED_INTERPRETER_RUNNABLE_EXIT=0
GENERAL_RESOLVER_SUCCESS_REASON_EMPTY=1
REAL_INTERPRETER_HANDOFF_OCCURRENCES=2
AUTH_POISONED_BUBBLES_PYTHON_OCCURRENCES=1
POISONED_BUBBLES_PYTHON_HOME_OCCURRENCES=2
T24_R1_RESOLVER_HANDOFF_FAILURES=0
T24_R1_RESOLVER_HANDOFF_END
```

### Static validation

**Phase:** test
**Command:** stock and modern Bash syntax checks, warning-level ShellCheck,
diff check, and bugfix regression-quality guard over the permitted test path
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-039 T24-R1 authenticated handoff static validation
exit: 0
lines: 24
sha256: 2c4a751936e2a3df413d4b12aaa167a799ea56cb9e0fc3140a9c5f634f843a0e
T24_R1_STATIC_BEGIN
STOCK_BASH_SYNTAX_EXIT=0
MODERN_BASH_SYNTAX_EXIT=0
SHELLCHECK_WARNING_EXIT=0
DIFF_CHECK_EXIT=0
============================================================
  BUBBLES REGRESSION QUALITY GUARD
  Bugfix mode: true
============================================================
Scanning tests/regression/test_24_g028_sensitive_client_storage.sh
Adversarial signal detected in tests/regression/test_24_g028_sensitive_client_storage.sh
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 1
Files with adversarial signals: 1
REGRESSION_QUALITY_EXIT=0
d3302f8a46e719b8bb93ab5a42bb56b6f64c5ee6e329989a9493dd1372e7dc6e  tests/regression/test_24_g028_sensitive_client_storage.sh
T24_R1_STATIC_FAILURES=0
T24_R1_STATIC_END
```

### Single post-edit stock-Bash cascade

**Phase:** test
**Command:** process-group-bounded `tool-log.sh` and `evidence-capture.sh`
execution of `/bin/bash tests/regression/test_24_g028_sensitive_client_storage.sh`
under the explicitly sanitized current-session environment
**Exit Code:** 0
**Claim Source:** executed

The full stock macOS Bash cascade ran exactly once after the test bytes changed.
The compact capture covers all 4,531 lines.

```text
# BUG-039 T24-R1 authenticated child real-interpreter handoff stock Bash cascade
exit: 0
lines: 4531
sha256: f30058b7e940f1827c10777fabe134cfe48b72ba53e29587e567f2cb6e8cbf49
=== TEST-B039-001 inherited selector dispatch control ===
TEST24_ZERO_ARGUMENT_ENTRY=FULL_SUITE
PASS: TEST-B039-001 legacy TEST24_CHILD_MODE cannot select sentinel accounting
ENTRY   BSEC1   privileged-bash-entry-v1        compat-reexec
implementation-reality-scan selftest summary: failures=0 skips=0
BUG039_AUTHORIZED_CLASSIFIER_MUTATION_VERIFIED=1
IMPLEMENTATION_REALITY_SELFTEST_FULL_SUITE_COMPLETED=1
implementation-reality-scan selftest passed.
PASS: authenticated root-protected runtime runs the managed selftest under system-only PATH
PASS: authenticated runtime removes classifier-unavailable degradation
PASS: authenticated runtime leaves no skipped scenario group
PASS: authenticated root-protected runtime leaves the poisoned Python marker absent
PASS: authenticated runtime executes the privileged BSEC1 path
PASS: authenticated runtime executes the native BPS1 supervisor path
PASS: authenticated runtime runs the exact-approval semantic assertion
PASS: authenticated runtime runs the unknown-provider semantic assertion
PASS: authenticated runtime runs the config-integrity assertion
PASS: authenticated runtime preserves the authorized classifier mutation control
test_24_g028_sensitive_client_storage: 101 passed, 0 failed, 1 skipped
BUG039_DETERMINISTIC_CASCADE_VERIFIED=1
BUG039_UNAVAILABLE_PATH_VERIFIED=1
TEST24_FULL_SUITE_COMPLETED=1
BUG013_GREEN_REGRESSION=SEMANTIC_STORAGE_CLASSIFICATION_SATISFIED
```

The single skip is the required deterministic unavailable-prerequisite lane.
The authenticated lane emitted no skip and exercised both current security
protocols.

### Residue and production-byte proof

**Phase:** test
**Claim Source:** executed

The first residue scan exited 1 with SHA-256
`ee13d8b9a684b1a1ab30d6b76f86e2b57d9052b94afcf3d92bf4a3e39c1c28ec`.
It found two current-user private roots with retained launch-window FIFOs.
Both roots were mode 0700, and `lsof +D` returned 1 for each. Exact guarded
cleanup removed only those two inactive roots. The cascade was not rerun.

**Command:** bounded final process, private-root, FIFO, bytecode, mutation,
untracked-path, and protected production-hash scan
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-039 T24-R1 clean residue and production integrity
exit: 0
lines: 12
sha256: cfafd61eb267e6848892d83cf3d230c2518219dab1ee68b8850e8c12d6e27e13
T24_R1_CLEAN_INTEGRITY_BEGIN
PROCESS_RESIDUE_COUNT=0
PRIVATE_ROOT_FIFO_MUTATION_RESIDUE_COUNT=0
REPOSITORY_FIFO_COUNT=0
REPOSITORY_PYTHON_CACHE_COUNT=0
UNTRACKED_PATH_COUNT=0
PRODUCTION_HASH_UNCHANGED=00ec96982dbfc19d5e0616496c094cd642b9d7eae7353c45cc9b618c57df30e4 bubbles/scripts/cli.sh
PRODUCTION_HASH_UNCHANGED=4eb25cbb959c37caaf4f835742128d837e08935b59cba793359ca2fd78a5e9fb bubbles/scripts/implementation-reality-scan.sh
PRODUCTION_HASH_UNCHANGED=64e37a7299b28513fc8fab78ce0e686dad6630d04a65827fc79f30419003853a bubbles/scripts/python-env.sh
PRODUCTION_HASH_UNCHANGED=cabce8c9d223dc4a3637dab649fe293867466b7c95fd28192e37820ddf83d07e bubbles/scripts/state-transition-guard.sh
T24_R1_CLEAN_INTEGRITY_FAILURES=0
T24_R1_CLEAN_INTEGRITY_END
```

### T24-R1 disposition

**Phase:** test
**Claim Source:** interpreted
**Interpretation:** The current cascade and static evidence close T24-R1's
test-harness handoff defect without changing production bytes. The production
implementation and broader Scope 2 verification remain open under
`bubbles.implement` ownership.

## Scope 2 Local Test Receipts — Privileged Native Supervision V2

### Retained Successful Receipts

**Phase:** test
**Claim Source:** interpreted
**Interpretation:** The structured receipts below were produced earlier in the
current repository-bound session. This closeout preserved their commands,
statuses, and hashes without rerunning the completed platform, stress, or CLI
lanes. The `python-env-selftest.sh` bytes remained unchanged while the Check 16
fixture correction changed only `state-transition-guard-selftest.sh`.

| Test Plan row | Proven local surface | Exit | Structured tool-log `stdoutHash` |
| --- | --- | ---: | --- |
| `TP-S2-03` | Stock macOS Bash 3.2 focused positive and negative matrix | 0 | `9a6a498085496411a0ce075206de007e055a023cc9718e465483ea8ede64624f` |
| `TP-S2-04` | Local fixed-Perl absent and untrusted negative controls only | 0 | `6c5535b99321fb50226368cbe9b39a903c5fe8d4820b673d71e1b4ee978db9c3` |
| `TP-S2-05` | Thirty iterations of all seven native-supervisor lifecycle classes | 0 | `8c71d8aef362c9789d5976d9e01523482419e1300fe49e6ca3334158064f1130` |
| `TP-S2-06` | Canonical CLI caller integration | 0 | `2ba86940ba95adc06dce7d4d89c48ef26beadbfd4eacdc1c5de164f1b028a260` |

Current byte identity used by the Check 16 closeout:

```text
BUG039_TP_S2_06_FINAL_STATIC_BEGIN
STATIC_FILE=bubbles/scripts/python-env-selftest.sh
BASH32_SYNTAX_EXIT=0
MODERN_BASH_SYNTAX_EXIT=0
SHELLCHECK_WARNING_EXIT=0
7696b39d7714bd5a9803e59a1024e80e7180486d2d4a7ae845b1c4b08a349376  bubbles/scripts/python-env-selftest.sh
STATIC_FILE=bubbles/scripts/state-transition-guard-selftest.sh
BASH32_SYNTAX_EXIT=0
MODERN_BASH_SYNTAX_EXIT=0
SHELLCHECK_WARNING_EXIT=0
119c5e1001a3822febd17a3dfc9667497ab5fc6355860bc214e47fba386da0e2  bubbles/scripts/state-transition-guard-selftest.sh
GIT_DIFF_CHECK_EXIT=0
STATIC_FAILURES=0
BUG039_TP_S2_06_FINAL_STATIC_END
```

### Check 16 Failed-Run Preservation

**Phase:** test
**Claim Source:** interpreted
**Interpretation:** The six failed Check 16 executions remain failures. Their
structured hashes are copied from the current-session tool log. The two raw
capture hashes available to this closeout are recorded separately and are not
substituted for any earlier receipt.

| Current-session order | Exit | Structured tool-log `stdoutHash` | Disposition |
| ---: | ---: | --- | --- |
| 1 | 1 | `153575cc6d20c935324517b81ae2e07389415d83f5d02b019641d0295d8a3d64` | Failed focused caller integration |
| 2 | 1 | `149fa454f9a4aa676b447dd2dd429786053150ab40252ca202bc4ccc3fbf9ed3` | Failed corrected focused dispatch |
| 3 | 1 | `a613c326a8a1c6c21168bcf8318f3bfb8b3c74d703349b7648fcb25008b5e594` | Failed fixed-modern-guard fixture |
| 4 | 1 | `caa585d219f3ac2a0ca5a1719637ed5050511dd6c64df1673f3051d77d0cf222` | Failed post-change caller integration |
| 5 | 1 | `32c6818c75ff442d352fa003ffd09678b57b527ea86ad384e598a69bfe6409e6` | Failed setup-only path-form control |
| 6 | 1 | `2bbd88010ac06a3faca11fda466e3d1db1fc759fb6300c6586afc03ef2c47241` | Failed absolute log-path assertion after setup passed |

The operator-supplied setup-only capture remains diagnostic input with five
lines and SHA-256
`cdf56cb7695ac0d526aab914b0dedf4194416eeb7c81b6a30e931194d54a2fcf`.
The closeout-executed absolute log-path assertion failure remains immutable at
810 lines and SHA-256
`20624ec7759af82c2d781f2d0989a5541a4f8a33f76a8445b31f570e74723251`.

### Final Focused Check 16 Control

**Phase:** test
**Command:** `/usr/bin/env -i LC_ALL=C PATH=/opt/local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin HOME=/Users/pkirsanov DEVELOPER_DIR=/Library/Developer/CommandLineTools /opt/local/bin/gtimeout --signal=TERM --kill-after=120s 1980 /bin/bash bubbles/scripts/state-transition-guard-selftest.sh --internal-bug039-check16-controls b039-check16-integration-v1`
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-039 TP-S2-06 focused Check16 final changed bytes single post-change run
exit: 0
lines: 32
sha256: ec1bc31b6548102add0942bd887f41c1fa0f65c94aebcbf12f13d563d31678cd
PASS: TP-S2-06 Check 16 SETUP: canonical fixture lint path exists
PASS: TP-S2-06 Check 16 SETUP: clean and blocking implementation paths exist
PASS: TP-S2-06 Check 16 SETUP: clean and blocking source bytes match their exact controls
PASS: TP-S2-06 Check 16 SETUP: absolute and repository-relative blocking paths resolve to the exact source
PASS: TP-S2-06 Check 16 SETUP: blocking repository-relative path has exact untracked git status
PASS: TP-S2-06 Check 16 SETUP: blocking scopes references only the absolute blocking implementation path
PASS: TP-S2-06 Check 16 SETUP: blocking report records only the repository-relative blocking path
PASS: TP-S2-06 Check 16 SETUP: clean and blocking fixtures pass artifact lint before guard invocation
Running BUG-039 TP-S2-06 Check 16 caller integration selftest...
PASS: TP-S2-06 Check 16 clean fixture preserves guard exit 0
PASS: TP-S2-06 Check 16 preserves a clean scanner status
PASS: TP-S2-06 Check 16 clean case enters direct BSEC1
PASS: TP-S2-06 Check 16 clean case validates native BPS1 completion
PASS: TP-S2-06 Check 16 clean fixture satisfies G053 with its real nonterminal source delta
PASS: TP-S2-06 Check 16 clean case exposes no ordinary-Bash compatibility authority
PASS: TP-S2-06 Check 16 clean case has one Check 16 execution and no unrelated violation or gate block
PASS: TP-S2-06 Check 16 production child remains fixed /bin/bash -p
PASS: TP-S2-06 Check 16 propagates exact blocking scanner exit 1 to the transition guard
PASS: TP-S2-06 Check 16 blocking case executes the real sensitive-storage classifier
PASS: TP-S2-06 Check 16 blocking case reports the exact durable auth-token violation
PASS: TP-S2-06 Check 16 reports the scanner's blocking result
PASS: TP-S2-06 Check 16 blocking case enters direct BSEC1
PASS: TP-S2-06 Check 16 blocking case validates native BPS1 completion
PASS: TP-S2-06 Check 16 blocking case exposes no ordinary-Bash compatibility authority
PASS: TP-S2-06 Check 16 blocking case does not degrade to unresolved classification
PASS: TP-S2-06 Check 16 blocking case has no unrelated storage-config failure
PASS: TP-S2-06 Check 16 blocking case resolves the declared implementation file
PASS: TP-S2-06 Check 16 blocking case scans the blocking fixture source file
PASS: TP-S2-06 Check 16 blocking case fails only for one sensitive-client-storage violation
PASS: TP-S2-06 Check 16 excludes hostile BASH_ENV and exported source before scanner startup
TP-S2-06_CHECK16_RESULTS cleanGuardExit=0 blockingGuardExit=1 cleanViolations=0 blockingViolations=1 hostileMarker=absent guardBash=/opt/homebrew/bin/bash scannerEntry=/bin/bash-p
state-transition-guard BUG-039 Check 16 summary: failures=0
```

**Test mechanism:** The focused dispatcher clones the real transition guard,
scanner, classifier helper, and fixture contracts into one temporary git root.
It drives a clean source and an adversarial `localStorage` auth-token source
through Check 16 and observes the guard's real status and scanner output.

**Negative control:** The blocking source must produce exactly one
`SENSITIVE_CLIENT_STORAGE` violation and exact guard exit 1. A positive-path
reference, missing git-backed delta, hostile Bash startup interception,
ordinary-Bash authority, missing `BPS1`, duplicate Check 16, or unrelated block
turns the focused selftest red.

### Lightweight Closeout Checks

**Phase:** test
**Claim Source:** executed
**Command:** `bash bubbles/scripts/scenario-test-resolve.sh bugs/BUG-039-interpreter-unusable-misreported-as-classification-failure --repo-root /private/tmp/bubbles-bug039-native-supervisor`; `bash bubbles/scripts/regression-quality-guard.sh --bugfix bubbles/scripts/python-env-selftest.sh bubbles/scripts/state-transition-guard-selftest.sh`; `bash bubbles/scripts/cli.sh lint bugs/BUG-039-interpreter-unusable-misreported-as-classification-failure`; bounded residue scan
**Exit Code:** 0

```text
[scenario-test-resolve] OK — 20 reference(s) resolved via literal-scan
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 2
Files with adversarial signals: 2
Artifact lint PASSED.
BUG039_TP_S2_06_RESIDUE_BEGIN
REPO_RESIDUE_BEGIN
REPO_RESIDUE_END
RECENT_PRIVATE_ROOTS_BEGIN
RECENT_PRIVATE_ROOTS_END
REPO_RESIDUE_COUNT=0
RECENT_PRIVATE_ROOT_COUNT=0
ACTIVE_TEST_PROCESS_COUNT=0
RESIDUE_FAILURES=0
BUG039_TP_S2_06_RESIDUE_END
```

### Linux Platform Non-Claim

**Phase:** test
**Claim Source:** not-run

> **Uncertainty Declaration**
> **What was attempted:** The local fixed-Perl absent and untrusted controls ran
> on macOS and produced structured receipt
> `6c5535b99321fb50226368cbe9b39a903c5fe8d4820b673d71e1b4ee978db9c3`.
> **What was observed:** The local negative controls exited 0. No live Linux
> command executed in this repository-bound invocation.
> **Why this is uncertain:** A macOS process result cannot establish the
> supported Linux platform lane required by `TP-S2-04`.
> **What would resolve this:** Execute the planned focused positive and negative
> matrix on the supported Linux runner against this exact committed candidate.

The local portions of `TP-S2-03`, `TP-S2-05`, and `TP-S2-06` have current
execution receipts. `TP-S2-04` carries only the local fixed-Perl negative
receipt and makes no Linux completion claim.

## HAR-R1 Mutation Harness Single-Owner Remediation

### Formal Finding And Change Boundary

**Phase:** test
**Claim Source:** interpreted
**Interpretation:** The formal security verdict was supplied by the operator for
base commit `52dfbde09417d2bd1a0e947c8ef478e36d11a99d`. This invocation did not
perform or impersonate a new security review. It produced test-owner proof for
the one returned harness finding only.

The supplied verdict marked `SEC-R1`, `SEC-R2`, `HAR-R2`, and `HAR-R3` clear.
It left `HAR-R1` blocking because the active mutation runner reaped its worker
before stopping a separately sleeping Bash watchdog. A deadline wake after the
reap could therefore act on recyclable numeric PID text.

The edit boundary stayed exact:

- test code: `bubbles/scripts/implementation-reality-scan-selftest.sh`;
- test evidence: this append-only section in `report.md`;
- production, other tests, planning, state, acceptance, certification, and
  scenario-manifest bytes: unchanged.

Production commit `769856e` remained immutable. No security-certification or
terminal-status claim is made here. The required independent owner after this
test remediation is `bubbles.security`.

### Immutable Pre-Fix Facts

**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=30s 120 /bin/bash -c 'printf "%s\n" "HAR_R1_PREF_FIX_FACTS_BEGIN"; printf "HEAD=%s\n" "$(git rev-parse HEAD)"; printf "PARENT=%s\n" "$(git rev-parse HEAD^)"; printf "SELFTEST_HEAD_BLOB=%s\n" "$(git rev-parse HEAD:bubbles/scripts/implementation-reality-scan-selftest.sh)"; printf "PRODUCTION_HEAD_BLOB=%s\n" "$(git rev-parse HEAD:bubbles/scripts/implementation-reality-scan.sh)"; git grep -n -E "SELFTEST_ACTIVE_CHILD|SELFTEST_WATCHDOG_PID|selftest_stop_watchdog|selftest_stop_active_child|launched_pid=|/bin/sleep.*wall_seconds|builtin kill -TERM.*launched_pid|builtin wait.*launched_pid" HEAD -- bubbles/scripts/implementation-reality-scan-selftest.sh; grep_status=$?; printf "PREF_FIX_PATTERN_SEARCH_EXIT=%s\n" "$grep_status"; printf "%s\n" "HAR_R1_PREF_FIX_FACTS_END"; exit "$grep_status"'`
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-039 HAR-R1 immutable pre-fix HEAD facts
exit: 0
lines: 41
sha256: 64a7eb868533a5a19fca2a7ff01396cd8f18f70f4cde5ae63ca0ca2d9c40f7c5
HAR_R1_PREF_FIX_FACTS_BEGIN
HEAD=52dfbde09417d2bd1a0e947c8ef478e36d11a99d
PARENT=77d91fd7549d30faf201e7946358ca64452c1375
SELFTEST_HEAD_BLOB=8c9de51c0b97b38149966f5e2b8abc6420978430
PRODUCTION_HEAD_BLOB=fdce8ed9df73e34bd4ee674d477931f3b1d813b3
HEAD:bubbles/scripts/implementation-reality-scan-selftest.sh:50:SELFTEST_ACTIVE_CHILD=''
HEAD:bubbles/scripts/implementation-reality-scan-selftest.sh:51:SELFTEST_WATCHDOG_PID=''
HEAD:bubbles/scripts/implementation-reality-scan-selftest.sh:65:selftest_stop_watchdog() {
HEAD:bubbles/scripts/implementation-reality-scan-selftest.sh:67:    builtin kill -TERM "$SELFTEST_WATCHDOG_PID" 2>/dev/null || true
HEAD:bubbles/scripts/implementation-reality-scan-selftest.sh:68:    builtin wait "$SELFTEST_WATCHDOG_PID" 2>/dev/null || true
HEAD:bubbles/scripts/implementation-reality-scan-selftest.sh:73:selftest_stop_active_child() {
HEAD:bubbles/scripts/implementation-reality-scan-selftest.sh:75:    builtin kill -TERM "$SELFTEST_ACTIVE_CHILD" 2>/dev/null || true
HEAD:bubbles/scripts/implementation-reality-scan-selftest.sh:77:    builtin wait "$SELFTEST_ACTIVE_CHILD" 2>/dev/null || true
HEAD:bubbles/scripts/implementation-reality-scan-selftest.sh:102:  SELFTEST_ACTIVE_CHILD=$!
HEAD:bubbles/scripts/implementation-reality-scan-selftest.sh:117:    /bin/sleep "$wall_seconds"
HEAD:bubbles/scripts/implementation-reality-scan-selftest.sh:118:    if builtin kill -TERM "$launched_pid" 2>/dev/null; then
HEAD:bubbles/scripts/implementation-reality-scan-selftest.sh:124:  SELFTEST_WATCHDOG_PID=$!
HEAD:bubbles/scripts/implementation-reality-scan-selftest.sh:126:  if builtin wait "$launched_pid" 2>/dev/null; then
HEAD:bubbles/scripts/implementation-reality-scan-selftest.sh:132:  selftest_stop_watchdog
PREF_FIX_PATTERN_SEARCH_EXIT=0
HAR_R1_PREF_FIX_FACTS_END
```

These are immutable `HEAD` facts, not a reconstruction from the edited working
tree. The captured ordering is the exact race returned as `HAR-R1`.

### Test-Only Single-Owner Design

**Phase:** test
**Claim Source:** interpreted
**Interpretation:** The code and execution records below establish the harness
mechanism. They do not strengthen the production security verdict.

`selftest_run_mutation_bounded()` now invokes one fixed embedded program with
fixed `/usr/bin/perl -T -w -e`. This is explicitly test-harness infrastructure,
not security authority. It accepts arbitrary absolute argv only because the
selftest must execute copied scanner mutations.

The Perl supervisor owns one direct worker from `fork` through `waitpid`. It
redirects worker stdout and stderr directly to the caller-selected private
output file. The worker closes the duplicated supervisor control descriptor
before replacing standard output and executing the requested argv. Bash stores
no worker PID, watchdog PID, process group, descendant list, or liveness probe.

The private `BMR1` record carries status owner, timeout ownership, worker kind,
ownership registration, and ordered events only after `waitpid`. Bash validates
that record and sets `SELFTEST_MUTATION_TIMED_OUT` plus
`SELFTEST_MUTATION_RUN_DIAGNOSTIC`. Numeric status remains exact for child exit
`124`, fast nonzero `73`, real signal `143`, and supervisor timeout `124`.

The separate outer-selftest lifecycle fixture still registers its own direct
test child so it can deliver the HUP and TERM cases it exists to test. It starts
no sleeper or watchdog, and it signals before its direct `wait`. The retired
mutation-worker and watchdog symbols are absent. The existing portable-timeout
scenario remains unchanged because it tests `guard-lib.sh` behavior and does not
own the mutation runner.

### Focused BMR1 And Negative-Control Proof

**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=30s 180 /usr/bin/env -u BUBBLES_MUTATION_RUNNER_ROOT_RECORD -u SELFTEST_MUTATION_SUPERVISOR_TEST_MODE PATH=/opt/local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin DEVELOPER_DIR=/Library/Developer/CommandLineTools /bin/bash bubbles/scripts/implementation-reality-scan-selftest.sh --internal-mutation-runner-focused-control b039-mutation-runner-focused-v1`
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-039 HAR-R1 final warning-free focused native runner proof
exit: 0
lines: 33
sha256: 9a592d58f4728afcafcf93dfe744499685fa8a3a81819ffaaac82fc739e7f433
MUTATION_RUNNER_CASE name=timeout status=124 timedOut=1 diagnostic=TIMEOUT protocol=BMR1 completed=1 ownership=1 owner=supervisor kind=signal events=FORK,OWNERSHIP_REGISTER,TERM_SIGNAL_OWNED,WAITPID,OWNERSHIP_CLEAR,COMPLETE
PASS: mutation runner native supervisor enforces timeout status 124
MUTATION_RUNNER_CASE name=child-124 status=124 timedOut=0 diagnostic=CHILD_EXIT_NONZERO owner=worker kind=exit completion=1
PASS: mutation runner distinguishes child exit 124 from supervisor timeout 124
MUTATION_RUNNER_CASE name=fast-nonzero status=73 timedOut=0 diagnostic=CHILD_EXIT_NONZERO owner=worker kind=exit completion=1
PASS: mutation runner preserves fast nonzero status and rejects worker-authored control text
MUTATION_RUNNER_CASE name=real-signal status=143 timedOut=0 diagnostic=CHILD_SIGNAL owner=worker kind=signal completion=1
PASS: mutation runner preserves a real child signal as status 143
MUTATION_RUNNER_CASE name=deadline-edge status=0 timedOut=0 diagnostic=OK owner=worker kind=exit completion=1 signalDecision=skipped-post-reap events=FORK,OWNERSHIP_REGISTER,WAITPID,OWNERSHIP_CLEAR,DEADLINE_EDGE,SIGNAL_SKIPPED_UNOWNED,COMPLETE
PASS: mutation runner deadline edge orders waitpid then ownership clear then no signal
MUTATION_RUNNER_FOCUSED_SUMMARY failures=0 cases=5 protocol=BMR1 bashWorkerPidState=absent bashWatchdogPidState=absent
PASS: focused mutation runner positive lifecycle matrix is green
MUTATION_RUNNER_CASE name=timeout status=125 timedOut=1 diagnostic=OWNERSHIP_REGISTRATION_INVALID protocol=BMR1 completed=1 ownership=0 owner=supervisor kind=signal events=FORK,OWNERSHIP_MISSING,TERM_SIGNAL_OWNED,WAITPID,OWNERSHIP_CLEAR,COMPLETE
RED: NEG-B039-MUTATION-REGISTRATION native supervisor omitted ownership registration
RED: NEG-B039-MUTATION-registration mutantExit=1 rootAbsent=yes outerProtocol=BMR1 outerOwnership=registered bashWorkerPidState=absent bashWatchdogPidState=absent
PASS: NEG-B039-MUTATION-registration copied mutation turns its owning lifecycle assertion RED without residue
MUTATION_RUNNER_CASE name=timeout status=0 timedOut=0 diagnostic=OK protocol=BMR1 completed=1 ownership=1 owner=worker kind=exit events=FORK,OWNERSHIP_REGISTER,WAITPID,OWNERSHIP_CLEAR,COMPLETE
RED: NEG-B039-MUTATION-BOUND native supervisor exceeded the declared wall
RED: NEG-B039-MUTATION-bound mutantExit=1 rootAbsent=yes outerProtocol=BMR1 outerOwnership=registered bashWorkerPidState=absent bashWatchdogPidState=absent
PASS: NEG-B039-MUTATION-bound copied mutation turns its owning lifecycle assertion RED without residue
MUTATION_RUNNER_CASE name=timeout status=124 timedOut=1 diagnostic=TIMEOUT protocol=BMR1 completed=1 ownership=1 owner=supervisor kind=signal events=FORK,OWNERSHIP_REGISTER,TERM_SIGNAL_OWNED,WAITPID,OWNERSHIP_CLEAR,COMPLETE
PASS: mutation runner native supervisor enforces timeout status 124
MUTATION_RUNNER_CASE name=deadline-edge status=125 timedOut=0 diagnostic=POST_REAP_SIGNAL_DECISION owner=worker kind=exit completion=1 signalDecision=forbidden-post-reap events=FORK,OWNERSHIP_REGISTER,WAITPID,OWNERSHIP_CLEAR,DEADLINE_EDGE,SIGNAL_WOULD_SEND_UNOWNED,COMPLETE
RED: NEG-B039-MUTATION-GUARD post-reap deadline made a forbidden signal decision
RED: NEG-B039-MUTATION-guard mutantExit=1 rootAbsent=yes outerProtocol=BMR1 outerOwnership=registered bashWorkerPidState=absent bashWatchdogPidState=absent
PASS: NEG-B039-MUTATION-guard copied mutation turns its owning lifecycle assertion RED without residue
MUTATION_RUNNER_COPIED_MUTATION_SUMMARY failures=0 mutations=3 exactConstruction=required setupFailureIsRed=no
```

The deadline-edge seam is trace-only after reap. The unmutated sequence is
`WAITPID -> OWNERSHIP_CLEAR -> SIGNAL_SKIPPED_UNOWNED`. The copied guard mutant
records `SIGNAL_WOULD_SEND_UNOWNED` and turns the owning assertion RED. It never
calls the operating-system signal primitive after reap. The registration and
wall mutations each match exactly once, execute the intended copied path, and
produce their own exact RED signal. A setup failure does not satisfy any RED
assertion.

The fast-nonzero worker writes forged `BMR1` text to its output file. The private
supervisor record still reports worker-owned status `73`, which proves worker
text cannot author completion evidence.

### Static And Regression-Quality Proof

**Phase:** test
**Command:** stock `/bin/bash -n`; modern `/opt/homebrew/bin/bash -n`; `/opt/homebrew/bin/shellcheck -S warning -x`; `git diff --check`; `bash bubbles/scripts/regression-quality-guard.sh --bugfix`; retired-runner symbol scans
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-039 HAR-R1 corrected final static and regression quality proof
exit: 0
lines: 27
sha256: 4a46405eab514fca7ff5a24129f0ec6a17281a59de5c151fc856fe4d07356b68
HAR_R1_STATIC_BEGIN
STOCK_BASH32_SYNTAX_EXIT=0
MODERN_BASH_SYNTAX_EXIT=0
SHELLCHECK_WARNING_EXIT=0
GIT_DIFF_CHECK_EXIT=0
BUBBLES REGRESSION QUALITY GUARD
Repo: /private/tmp/bubbles-bug039-native-supervisor
Bugfix mode: true
Scanning bubbles/scripts/implementation-reality-scan-selftest.sh
Adversarial signal detected in bubbles/scripts/implementation-reality-scan-selftest.sh
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 1
Files with adversarial signals: 1
REGRESSION_QUALITY_EXIT=0
HAR_R1_OLD_MUTATION_PID_STATE_COUNT=0
HAR_R1_STALE_SIGNAL_PRIMITIVE_COUNT=0
HAR_R1_FIXED_PERL_ENTRY_COUNT=1
HAR_R1_PERL_MODULE_IMPORT_COUNT=0
HAR_R1_STATIC_FAILURES=0
HAR_R1_STATIC_END
```

The first static bundle used an over-broad `setsid` text pattern. It exited 1
with output SHA-256
`4daaef97051b56e18b847a3b4fd9d1f665dbfb9f08752493b055113ec68e98aa`.
Both matches were the retained hostile-helper mutation, not lifecycle code.
The corrected command above preserves that required mutation and scopes the
absence check to retired PID, watchdog, liveness-probe, job-control, and
process-group signal primitives.

### One Full Stock-Bash Selftest On Final Test Bytes

**Phase:** test
**Command:** `/usr/bin/env -u BUBBLES_AUTHORITY_BYPASS_CANDIDATE -u BUBBLES_AUTHORITY_BYPASS_TRACE -u BUBBLES_PYTHON_SELFTEST_CHILD_MODE -u BUBBLES_PYTHON_SELFTEST_READY_FILE -u BUBBLES_PYTHON_SELFTEST_NEGATIVE_CONTROL -u BUBBLES_PYTHON_LATE_SIGNAL_NAME -u BUBBLES_PYTHON_SELFTEST_LATE_ROOT_RECORD -u BUBBLES_PYTHON_MUTANT_WINDOW_READY -u BUBBLES_PYTHON_MUTANT_WINDOW_RELEASE -u BUBBLES_PYTHON_MUTANT_ROOT_RECORD -u BUBBLES_PYTHON_MUTANT_TRACE -u BUBBLES_SELFTEST_REAL_PYTHON -u BUBBLES_IMPLEMENTATION_REALITY_SELFTEST_TARGET -u BUBBLES_IMPLEMENTATION_REALITY_SELFTEST_CHILD_MODE -u BUBBLES_IMPLEMENTATION_REALITY_SELFTEST_READY_FILE -u BUBBLES_MUTATION_RUNNER_ROOT_RECORD -u SELFTEST_MUTATION_SUPERVISOR_TEST_MODE -u BUBBLES_TEST24_CHILD_MODE -u BUBBLES_TEST24_NEGATIVE_CONTROL -u BUBBLES_TEST24_LIFECYCLE_CHILD_MODE -u BUBBLES_TEST24_READY_FILE PATH=/opt/local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin DEVELOPER_DIR=/Library/Developer/CommandLineTools /opt/local/bin/gtimeout --signal=TERM --kill-after=300s 7200 /bin/bash -c 'printf "BUG039_HAR_R1_BASE_HEAD=%s\n" "$(git rev-parse HEAD)"; printf "BUG039_HAR_R1_TEST_SHA256=%s\n" "$(/usr/bin/shasum -a 256 bubbles/scripts/implementation-reality-scan-selftest.sh | /usr/bin/awk "{print \$1}")"; printf "BUG039_HAR_R1_PRODUCTION_BLOB=%s\n" "$(git rev-parse HEAD:bubbles/scripts/implementation-reality-scan.sh)"; printf "%s\n" "BUG039_HAR_R1_EPOCH=privileged-native-supervision-v2"; /bin/bash bubbles/scripts/implementation-reality-scan-selftest.sh; test_status=$?; printf "BUG039_HAR_R1_FULL_SELFTEST_EXIT=%s\n" "$test_status"; exit "$test_status"'`
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-039 HAR-R1 single full stock Bash selftest final test bytes
exit: 0
lines: 1773
sha256: 00805637c21a62e12c99f2228d509b1e239fec0b3c6fb515164f35cd2e394ce3
--- first 20 ---
BUG039_HAR_R1_BASE_HEAD=52dfbde09417d2bd1a0e947c8ef478e36d11a99d
BUG039_HAR_R1_TEST_SHA256=9bc4aafba19ed31f55e56a2bd5b759701b7c8539fbb253d69590a30f0db62c69
BUG039_HAR_R1_PRODUCTION_BLOB=fdce8ed9df73e34bd4ee674d477931f3b1d813b3
BUG039_HAR_R1_EPOCH=privileged-native-supervision-v2
Scenario: TEST-B039-001 inherited subset selectors cannot replace the full-suite entrypoint.
IMPLEMENTATION_REALITY_SELFTEST_ZERO_ARGUMENT_ENTRY=FULL_SUITE
PASS: TEST-B039-001 legacy SELFTEST_TARGET cannot select an ambient subset
Scenario: premature and interrupted selftest exits fail closed while cleaning up.
PASS: Premature EXIT preserves fatal exit 1
PASS: Premature EXIT removes its temporary tree
PASS: Premature EXIT emits no success summary
PASS: Timeout exit preserves fatal exit 124
PASS: Timeout exit removes its temporary tree
PASS: Timeout exit emits no success summary
PASS: HUP interruption preserves fatal exit 129
PASS: HUP interruption removes its temporary tree
PASS: HUP interruption emits no success summary
PASS: TERM interruption preserves fatal exit 143
PASS: TERM interruption removes its temporary tree
PASS: TERM interruption emits no success summary
--- omitted 1733 line(s); sha256 above covers the full output ---
--- last 20 ---
--- Scan 8: Silent Decode Failure Detection (Gate G048) ---
IMPLEMENTATION REALITY SCAN RESULT
Files scanned:  1
Violations:     0
Warnings:       0
PASSED: No source code reality violations detected
PASS: Classifier remains reusable after both watchdog timeouts
PASS: Post-timeout classifier completes its protocol
PASS: Post-timeout real producer leaves the helper directory clean
implementation-reality-scan selftest summary: failures=0 skips=0
BUG039_AUTHORIZED_CLASSIFIER_MUTATION_VERIFIED=1
IMPLEMENTATION_REALITY_SELFTEST_FULL_SUITE_COMPLETED=1
implementation-reality-scan selftest passed.
BUG039_HAR_R1_FULL_SELFTEST_EXIT=0
```

This was the only full scanner-selftest execution on final test SHA-256
`9bc4aafba19ed31f55e56a2bd5b759701b7c8539fbb253d69590a30f0db62c69`.
It preserved all classifier, helper, authority, same-byte, skip-accounting, and
full-entrypoint sentinels with zero failures and zero skips.

### Residue, Byte Identity, And Linked-Test Resolution

**Phase:** test
**Command:** bounded process, private-root, FIFO, bytecode, mutation-residue, live-hash, protected-path, and worktree-delta checks
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-039 HAR-R1 post-full residue and live-byte identity
exit: 0
lines: 15
sha256: 15d58b8cb26ee8793cbbf4e536d2d1cd8d4cf462df0eef353e6983c38420349b
HAR_R1_RESIDUE_IDENTITY_BEGIN
ACTIVE_HAR_R1_PROCESS_COUNT=0
REPOSITORY_FIFO_COUNT=0
REPOSITORY_PYTHON_CACHE_COUNT=0
REPOSITORY_MUTATION_RESIDUE_COUNT=0
PRIVATE_MUTATION_RESIDUE_COUNT=0
LIVE_TEST_SHA256=9bc4aafba19ed31f55e56a2bd5b759701b7c8539fbb253d69590a30f0db62c69
FULL_EVIDENCE_TEST_SHA256=9bc4aafba19ed31f55e56a2bd5b759701b7c8539fbb253d69590a30f0db62c69
LIVE_PRODUCTION_BLOB=fdce8ed9df73e34bd4ee674d477931f3b1d813b3
IMMUTABLE_PRODUCTION_BLOB=fdce8ed9df73e34bd4ee674d477931f3b1d813b3
PRODUCTION_OTHER_TESTS_DOCS_PLANNING_DIFF_EXIT=0
WORKTREE_DELTA
bubbles/scripts/implementation-reality-scan-selftest.sh
HAR_R1_RESIDUE_IDENTITY_FAILURES=0
HAR_R1_RESIDUE_IDENTITY_END
```

**Phase:** test
**Command:** `/opt/homebrew/bin/bash bubbles/scripts/scenario-test-resolve.sh bugs/BUG-039-interpreter-unusable-misreported-as-classification-failure --repo-root /private/tmp/bubbles-bug039-native-supervisor`
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-039 HAR-R1 linked scenario test resolution
exit: 0
lines: 1
sha256: fc09dd35a2552de3ec38df88b13faaa0ca32d9075151aa877fd71f81a6f01ff8
[scenario-test-resolve] OK — 20 reference(s) resolved via literal-scan
```

The exact executable candidate is base
`52dfbde09417d2bd1a0e947c8ef478e36d11a99d`, parent
`77d91fd7549d30faf201e7946358ca64452c1375`, epoch
`privileged-native-supervision-v2`, test SHA-256
`9bc4aafba19ed31f55e56a2bd5b759701b7c8539fbb253d69590a30f0db62c69`,
and immutable production blob
`fdce8ed9df73e34bd4ee674d477931f3b1d813b3`. The final Git commit identity is
reported after Git creates it; a commit cannot contain its own object ID.

### Remediation Execution Ledger

Every remediation command remained bounded. Failed candidates stay failures and
are not substituted for accepted proof.

| Execution | Exit | Full-output SHA-256 | Disposition |
| --- | ---: | --- | --- |
| Initial stock and modern Bash syntax preflight | 0 | `858e34fc6ac075fa8e603cb71afe2c0001a5c0901ec4e76b3cbe991b7ad7d8d6` | Accepted syntax evidence before focused execution. |
| First focused BMR1 candidate | 1 | `4eec4da1771cccee68cf09b01db8f878c8a6c48561c88776645172df4ca72a45` | Invalid as RED proof. Taint mode rejected inherited worker environment before intended commands. |
| Focused core after closed worker environment | 0 | `a2a2b2449275146cb3093c9aa0c78d8c8c6016c9a80d4ffb220f5c3e7206a20c` | Intermediate green core before copied controls were added. |
| Focused core plus three copied mutations | 0 | `9a592d58f4728afcafcf93dfe744499685fa8a3a81819ffaaac82fc739e7f433` | Accepted focused proof. |
| Private-control candidate with Perl reopen warnings | 0 | `d381b5585107c4ed2f6e5e8ffed0fd5665e834fd543fa8a3790e2b3e0ada8edd` | Rejected as final evidence because warning-mode output was not clean. |
| Final warning-free focused candidate | 0 | `9a592d58f4728afcafcf93dfe744499685fa8a3a81819ffaaac82fc739e7f433` | Accepted final focused proof on the final test bytes. |
| Over-broad static surface | 1 | `4daaef97051b56e18b847a3b4fd9d1f665dbfb9f08752493b055113ec68e98aa` | Invalid static failure. It matched required `setsid` adversarial payload text. |
| Corrected static and regression-quality surface | 0 | `4a46405eab514fca7ff5a24129f0ec6a17281a59de5c151fc856fe4d07356b68` | Accepted static proof. |
| Single full stock-Bash scanner selftest | 0 | `00805637c21a62e12c99f2228d509b1e239fec0b3c6fb515164f35cd2e394ce3` | Accepted full-suite proof on final test bytes. |
| Post-full residue and identity check | 0 | `15d58b8cb26ee8793cbbf4e536d2d1cd8d4cf462df0eef353e6983c38420349b` | Accepted cleanup and immutable-byte proof. |
| Immutable pre-fix HEAD fact capture | 0 | `64a7eb868533a5a19fca2a7ff01396cd8f18f70f4cde5ae63ca0ca2d9c40f7c5` | Accepted pre-fix code-fact proof. |
| Linked scenario-test resolution | 0 | `fc09dd35a2552de3ec38df88b13faaa0ca32d9075151aa877fd71f81a6f01ff8` | Accepted reference-resolution proof. |

### Explicit Non-Runs And Evidence Invalidation

**Phase:** test
**Claim Source:** not-run

The earlier `TP-S2-08` candidate was stopped after the formal security finding.
It remains invalidated and supplies no evidence for this remediation. Per the
operator's exact execution boundary, this invocation did not rerun the
30-by-7 lifecycle matrix, `test_24`, `framework-validate`, `release-check`, or a
Linux lane. No result for those surfaces is claimed.

The focused and full selftest evidence above addresses the test-harness
`HAR-R1` finding for return to `bubbles.security`. It does not certify security,
acceptance, Scope 2 completion, or BUG-039 completion.
