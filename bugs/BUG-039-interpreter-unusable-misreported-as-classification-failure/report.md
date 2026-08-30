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
