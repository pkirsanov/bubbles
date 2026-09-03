# Report: BUG-038 — `bubbles_run_with_progress_timeout` BSD `wc` padding

All evidence below is raw output from commands executed in this session on macOS
(Darwin, arm64) with real exit codes. Nothing is summarized in place of output.

---

## Summary

`bubbles_run_with_progress_timeout` returned `2` on the first poll of any command that
outlived one second, on every BSD/macOS host, because BSD `wc` pads its count with
leading spaces and the count was regex-tested without normalization. One line of
whitespace normalization fixes it. The committed selftest went from 4 failures to 0.

---

## Completion Statement

**Delivered outcome.** `bubbles_run_with_progress_timeout` in
`bubbles/scripts/guard-lib.sh` no longer aborts with `rc=2` on the first poll on a BSD
userland. One line normalizes the `wc -c` capture before the `^[0-9]+$` test:
`current_size="${current_size//[[:space:]]/}"`. Scope is one file and one hunk. The
adversarial regression that proves it — `guard-lib-timeout-selftest.sh` — was already
committed, was failing at HEAD, and was **not modified**, so the GREEN result is
measured against unchanged assertions.

**Evidence that proves it.** The claim rests on two runs of the same unmodified
selftest, both recorded verbatim under `## Test Evidence` below, in this order.
The red-stage run came first, at HEAD, with no fix applied.
The green-stage run came second, with the one-line fix applied.

| Stage | Command | Exit code | Result | Provenance |
|---|---|---|---|---|
| RED (pre-fix) | `bash bubbles/scripts/guard-lib-timeout-selftest.sh` | `1` | 4 failures | recorded in this packet by the originating session; **not** re-executed here |
| GREEN (post-fix) | `bash bubbles/scripts/guard-lib-timeout-selftest.sh` | `0` | `OK (10 cases)` | executed twice: originating session 07:02:12→07:02:39, and **re-executed 2026-08-25T19:26:06Z→19:26:33Z** (see `### Green stage — re-execution`) |

Two supporting facts were re-verified in the current session rather than assumed:

```
$ grep -n 'current_size="${current_size//' bubbles/scripts/guard-lib.sh
137:    current_size="${current_size//[[:space:]]/}"
GREP_EXIT=0

$ git diff --stat -- bubbles/scripts/guard-lib-timeout-selftest.sh
DIFFSTAT_EXIT=0   (empty output = selftest unmodified vs HEAD)

$ git diff --stat -- bubbles/scripts/guard-lib.sh
 bubbles/scripts/guard-lib.sh | 6 ++++++
 1 file changed, 6 insertions(+)
```

**Claim Source:** executed.

**What this statement does NOT claim.** It does not claim promotion. `status` remains
`in_progress` and `certification.status` remains `in_progress`. Certification is
validate-owned, and the two obligations that gate it are still open and are listed under
`## Unresolved`: `framework-validate` and `release-check` have not been run on the
combined revision, and the `v5.3-selftest.sh` second-order reading at
`## Second-order impact on the other caller` is a labelled code reading, not an observed
run. This section is a scope-level completion claim backed by executed commands, not a
certification.

---

## Test Evidence

`policySnapshot.tdd.mode` is `scenario-first` for this packet, so both stages are given
explicitly below for the changed scenario contract. Both stages run the **same
unmodified** `bubbles/scripts/guard-lib-timeout-selftest.sh`; the only variable between
them is the presence of the one-line fix. Each capture is 11 lines, which is at or below
the 40-line inline-raw threshold in `bubbles/registry/report-sections.yaml`, so verbatim
inline output is the admissible form and no bounded capture is required.

### Red stage — pre-fix, exit 1

**Claim Source:** not-run — **not re-executed in the current session.** This is the RED
baseline the originating session recorded in this packet (see
`## Reproduction BEFORE fix — fails without the fix (RED)`, `CAPTURE_EXIT=1`,
`sha256: 046afc210b64d322bd313e28d339c1135d39294a33518e4aaca0d05b776ed472`). It is
quoted here rather than reproduced, because re-deriving it would require reverting the
fix in a shared working tree that other in-flight sessions are editing.

```
$ bash bubbles/scripts/guard-lib-timeout-selftest.sh
exit: 1
  FAIL  progress-aware command returned rc=2 after 2s
  FAIL  idle timeout returned rc=2 reason=none after 2s
  FAIL  absolute timeout returned rc=2 reason=none after 2s
  FAIL  timed-out validator leaked or blocked: pid=81706 rc=2 reason=none elapsed=6s
guard-lib timeout selftest: 4 failure(s)
```

All four failures report `rc=2`, which is the padded-capture abort, and three of them
additionally report `reason=none` — the runner returned before either deadline was
evaluated. These four cases are adversarial: no value of the padded capture satisfies
them, so reintroducing the defect fails all four again.

### Green stage — post-fix, exit 0, executed by the originating session

**Claim Source:** executed. Run at 07:02:12, returned at 07:02:39 (27 s wall clock).

```
$ bash bubbles/scripts/guard-lib-timeout-selftest.sh
  PASS  instant command in $( ) returns promptly (0s, output intact)
  PASS  timeout fires and normalizes to 124 (3s)
  PASS  command exit code preserved (rc=7, 0s)
  PASS  fallback child can trap SIGINT (rc=130, 0s)
  PASS  progress extends the idle window without exceeding the absolute ceiling (4s)
  PASS  silent command stops at the idle deadline with rc=124 (3s)
  PASS  chatty command stops at the absolute deadline with rc=125 (5s)
  PASS  progress runner preserves command exit code (rc=9)
  PASS  absolute timeout force-terminates a TERM-resistant validator process group (9s)
  PASS  lost progress log fails loud through bounded cleanup (2s)
guard-lib timeout selftest: OK (10 cases)
SELFTEST_EXIT=0
```

10 of 10 cases pass. **Zero skipped**, zero failures. The four cases that were RED are
now PASS, and they now report the deadline codes they are supposed to report —
`rc=124` at the idle deadline, `rc=125` at the absolute deadline, and force-termination
of a TERM-resistant process group — rather than the undifferentiated `rc=2 reason=none`
of the defect. A silent pass is therefore excluded: the assertions distinguish "the
deadline fired correctly" from "the runner bailed out early".

**Flake disclosure.** This selftest asserts wall-clock bounds, and the host was under
heavy memory pressure during the run (`vm_stat` reported 4,178 free pages, roughly 67 MB
free, against 335,510 inactive pages). A timing-sensitive case could therefore have
flaked. It did not: the run above is the **first and only** execution of this selftest in
the originating session, taken as-is. No run was discarded and no retry-until-green was
performed.

### Green stage — re-execution

**Claim Source:** executed. Re-run in the present session, on the same host, against the
same unmodified selftest, to confirm the passing result still describes the current tree
rather than a tree from two days ago. Started `2026-08-25T19:26:06Z`, returned
`2026-08-25T19:26:33Z` (27 s wall clock). This was the first and only invocation in this
session; no run was discarded.

```
$ echo "IMPL_MTIME=$(date -u -r bubbles/scripts/guard-lib.sh +%Y-%m-%dT%H:%M:%SZ)"
IMPL_MTIME=2026-08-23T23:12:17Z
$ echo "START=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
START=2026-08-25T19:26:06Z
$ bash bubbles/scripts/guard-lib-timeout-selftest.sh
  PASS  instant command in $( ) returns promptly (0s, output intact)
  PASS  timeout fires and normalizes to 124 (3s)
  PASS  command exit code preserved (rc=7, 0s)
  PASS  fallback child can trap SIGINT (rc=130, 0s)
  PASS  progress extends the idle window without exceeding the absolute ceiling (4s)
  PASS  silent command stops at the idle deadline with rc=124 (3s)
  PASS  chatty command stops at the absolute deadline with rc=125 (5s)
  PASS  progress runner preserves command exit code (rc=9)
  PASS  absolute timeout force-terminates a TERM-resistant validator process group (9s)
  PASS  lost progress log fails loud through bounded cleanup (2s)
guard-lib timeout selftest: OK (10 cases)
SELFTEST_EXIT=0
$ echo "END=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
END=2026-08-25T19:26:33Z
```

Real exit code `SELFTEST_EXIT=0`, 10 of 10, identical case-for-case to the originating
session's capture. `IMPL_MTIME` is the modification time of the fixed
`bubbles/scripts/guard-lib.sh`; it precedes both green runs, so both measured the tree
with the fix in place.

### Supporting facts re-derived in the present session

**Claim Source:** executed

```
$ echo "TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
TS=2026-08-25T19:26:43Z
$ grep -n "current_size" bubbles/scripts/guard-lib.sh
122:  local current_size=0
131:    current_size="$(wc -c 2>/dev/null < "$log_file")" || current_size=""
137:    current_size="${current_size//[[:space:]]/}"
138:    if [[ ! "$current_size" =~ ^[0-9]+$ ]]; then
143:    if [[ "$current_size" -ne "$last_size" ]]; then
144:      last_size="$current_size"
GREP_EXIT=0
$ git diff --stat -- bubbles/scripts/guard-lib.sh bubbles/scripts/guard-lib-timeout-selftest.sh
 bubbles/scripts/guard-lib.sh | 6 ++++++
 1 file changed, 6 insertions(+)
DIFFSTAT_EXIT=0
$ shellcheck -x bubbles/scripts/guard-lib.sh
SHELLCHECK_EXIT=0
```

Line 137 carries the normalization and line 138 is the numeric test, so the strip still
precedes the regex. The diffstat names `guard-lib.sh` and only `guard-lib.sh`:
`guard-lib-timeout-selftest.sh` produced no diffstat row, so the adversarial regression
is still byte-identical to HEAD and the 10-of-10 above is still measured against
unmodified assertions. `shellcheck -x` is clean at exit 0.

---

## Root cause isolation

**Claim Source:** executed

```
$ printf "hello world\n" > /tmp/bugwc.txt
$ raw="$(wc -c < /tmp/bugwc.txt)"; printf "raw=[%s] len=%s\n" "$raw" "${#raw}"
raw=[      12] len=8
$ if [[ "$raw" =~ ^[0-9]+$ ]]; then echo "regex: MATCHES"; else echo "regex: DOES NOT MATCH -> timeout_rc=2"; fi
regex: DOES NOT MATCH -> timeout_rc=2
```

Exit code: 0. The capture is 8 bytes for a 2-digit count; six leading spaces survive
command substitution, which strips only the trailing newline.

---

## Attribution — pre-existing at HEAD, not a regression

**Claim Source:** executed

```
$ git status --short -- bubbles/scripts/guard-lib.sh bubbles/scripts/guard-lib-timeout-selftest.sh
(exit=0)
$ git diff HEAD --stat -- bubbles/scripts/guard-lib.sh bubbles/scripts/guard-lib-timeout-selftest.sh
(exit=0)
```

Both commands emitted zero lines with exit 0. Both files were byte-identical to HEAD
before the fix, so the defect ships at HEAD and is not caused by in-flight work.

---

## Reproduction BEFORE fix — fails without the fix (RED)

**Claim Source:** executed

```
# BUG-wc-padding RED baseline guard-lib-timeout-selftest
$ bash bubbles/scripts/guard-lib-timeout-selftest.sh
exit: 1
lines: 11
sha256: 046afc210b64d322bd313e28d339c1135d39294a33518e4aaca0d05b776ed472
--- output ---
  PASS  instant command in $( ) returns promptly (0s, output intact)
  PASS  timeout fires and normalizes to 124 (3s)
  PASS  command exit code preserved (rc=7, 0s)
  PASS  fallback child can trap SIGINT (rc=130, 0s)
  FAIL  progress-aware command returned rc=2 after 2s
  FAIL  idle timeout returned rc=2 reason=none after 2s
  FAIL  absolute timeout returned rc=2 reason=none after 2s
  PASS  progress runner preserves command exit code (rc=9)
  FAIL  timed-out validator leaked or blocked: pid=81706 rc=2 reason=none elapsed=6s
  PASS  lost progress log fails loud through bounded cleanup (2s)
guard-lib timeout selftest: 4 failure(s)
```

Real exit code: `CAPTURE_EXIT=1`.

This is an **adversarial regression** and it is already committed, which is why no new
test was written. Its four failing cases exercise inputs the broken code path cannot
satisfy under any value: a command that produces progress, a silent command that must
hit the idle deadline, a chatty command that must hit the absolute deadline, and a
TERM-resistant process group that must be force-killed. None can pass while the first
poll aborts with `2`. Reintroducing the defect fails all four again.

---

## The fix

### Code Diff Evidence

Changed path: `bubbles/scripts/guard-lib.sh` (the only tracked source file this
packet modified).

**Claim Source:** executed

```
$ git diff -- bubbles/scripts/guard-lib.sh
diff --git a/bubbles/scripts/guard-lib.sh b/bubbles/scripts/guard-lib.sh
index fd037b3..e8e404a 100755
--- a/bubbles/scripts/guard-lib.sh
+++ b/bubbles/scripts/guard-lib.sh
@@ -129,6 +129,12 @@ bubbles_run_with_progress_timeout() {
     kill -0 "$cmd_pid" 2>/dev/null || break
 
     current_size="$(wc -c 2>/dev/null < "$log_file")" || current_size=""
+    # BSD `wc` right-aligns its count in a fixed-width field ("      12"); GNU
+    # does not, and command substitution strips only the TRAILING newline. The
+    # raw capture therefore failed `^[0-9]+$` on the first poll of every BSD
+    # host, returning 2 before either deadline was ever evaluated. Normalize
+    # before the numeric test; an unreadable log still yields "" and fails loud.
+    current_size="${current_size//[[:space:]]/}"
     if [[ ! "$current_size" =~ ^[0-9]+$ ]]; then
       timeout_rc=2
       break
```

One file, one hunk. The regex is retained deliberately: an unreadable log still yields
`""`, which still fails the test and still fails loud. That path is covered by the
`lost progress log fails loud through bounded cleanup` case, which passed before and
after.

### Portability of the fix

**Claim Source:** executed

```
$ /bin/bash --version | head -1
GNU bash, version 3.2.57(1)-release (arm64-apple-darwin25)
$ /bin/bash -c 'printf 12 > /tmp/n.txt; raw=$(wc -c < /tmp/n.txt); ...'
raw=[       2]
stripped=[2]
regex: MATCHES (bash 3.2.57(1)-release)
```

Exit code: 0. `${var//[[:space:]]/}` is fork-free and works on bash 3.2.57, the macOS
baseline. It is not a macOS special-case: it removes whitespace GNU `wc` never emits, so
the GNU path is byte-for-byte unaffected.

---

## Reproduction AFTER fix — passes with the fix (GREEN)

**Claim Source:** executed

```
# BUG-038 GREEN guard-lib-timeout-selftest after wc normalization
$ bash bubbles/scripts/guard-lib-timeout-selftest.sh
exit: 0
lines: 11
sha256: 06054735b7d1ade85254102451e6ef7406693818baeb32d1b3c972efd6c7f102
--- output ---
  PASS  instant command in $( ) returns promptly (0s, output intact)
  PASS  timeout fires and normalizes to 124 (3s)
  PASS  command exit code preserved (rc=7, 0s)
  PASS  fallback child can trap SIGINT (rc=130, 0s)
  PASS  progress extends the idle window without exceeding the absolute ceiling (4s)
  PASS  silent command stops at the idle deadline with rc=124 (3s)
  PASS  chatty command stops at the absolute deadline with rc=125 (5s)
  PASS  progress runner preserves command exit code (rc=9)
  PASS  absolute timeout force-terminates a TERM-resistant validator process group (9s)
  PASS  lost progress log fails loud through bounded cleanup (2s)
guard-lib timeout selftest: OK (10 cases)
```

Real exit code: `CAPTURE_EXIT=0`. All 10 cases pass. The four previously-failing cases
now pass against **unmodified assertions** — the selftest was not touched:

```
$ git diff --stat -- bubbles/scripts/guard-lib-timeout-selftest.sh
(empty — file unmodified)
```

The GREEN output is not merely "no failure". The passing case names show the deadlines
are now genuinely enforced: `rc=124` at the idle deadline, `rc=125` at the absolute
deadline, and force-termination of a TERM-resistant process group. Under the defect all
three reported `rc=2 reason=none`.

---

## Second-order impact on the other caller

**Claim Source:** interpreted — read from the source, NOT executed. `v5.3-selftest.sh`
T3 drives a downstream `framework-validate.sh` and is long-running; the operator
withheld authorization to run long suites in this session, so end-to-end confirmation
is routed to `bubbles.validate` and carried as `DI-038-01` under `## Discovered
Issues`. This is a code-path reading, and it is
labelled as such rather than presented as an observed run.

`bubbles/scripts/v5.3-selftest.sh:200` is the only non-test caller of the runner. It
branches on the return code at lines 206, 208, 229, 270, 282 and 316, and it recognizes
exactly three values: `0`, `124`, `125`.

```
$ grep -n "ds_rc\|ds_full" bubbles/scripts/v5.3-selftest.sh
197:ds_rc=0
204:  run_in_downstream_root bash .github/bubbles/scripts/framework-validate.sh || ds_rc=$?
206:if [[ $ds_rc -eq 124 ]]; then
208:elif [[ $ds_rc -eq 125 ]]; then
229:if [[ $ds_rc -ne 124 && $ds_rc -ne 125 ]]; then
270:if [[ $ds_rc -ne 0 && $ds_rc -ne 124 && $ds_rc -ne 125 ]]; then
282:if [[ $ds_rc -ne 0 && $ds_rc -ne 124 && $ds_rc -ne 125 && ${#observed_failures[@]} -eq 0 ]]; then
283:  fail "T3c: downstream framework-validate exited $ds_rc without a trailing Failed checks block"
```

Under the defect the runner returned `2`, which is none of the three. Tracing the
branches: `2` escapes the idle branch (206) and the absolute branch (208), so no timeout
is reported; it enters the label scan (229) against a log holding roughly one second of
downstream output; then at 282 it satisfies every condition with an empty
`observed_failures`, reaching the `fail` at 283.

So T3c did **not** silently pass — it failed. But it failed with
`downstream framework-validate exited 2 without a trailing Failed checks block`, which
blames the downstream repository for a defect in this repository's runner. The failure
mode was a misdirected diagnosis, not a missed one. With the fix, `2` is again reserved
for genuine invalid invocation and the three recognized codes carry their intended
meaning.

This is stated as a bounded reading of the branch conditions. Confirming it end-to-end
requires running `v5.3-selftest.sh` against a downstream checkout, which is owed to the
parent runner along with the other long suites.

---

## Lint

**Claim Source:** executed

```
$ shellcheck -x bubbles/scripts/guard-lib.sh
SHELLCHECK_EXIT=0
```

Clean, no findings.

```
$ shfmt -d -i 2 -ci -bn bubbles/scripts/guard-lib.sh
SHFMT_EXIT=1
```

shfmt exit 1 is **pre-existing style drift, not introduced by this fix**. Verified by
running shfmt against the HEAD version of the same file:

```
$ git show HEAD:bubbles/scripts/guard-lib.sh | shfmt -d -i 2 -ci -bn
SHFMT_AT_HEAD_EXIT=1
$ git show HEAD:bubbles/scripts/guard-lib.sh | shfmt -d -i 2 -ci -bn | grep -c "^[+-]"
36
$ shfmt -d -i 2 -ci -bn bubbles/scripts/guard-lib.sh | grep -c "^[+-]"
36
```

Identical hunk-line count before and after. Neither added line appears as a `+`/`-` line
in the shfmt diff; the comment appears only as a context line. The drift is in unrelated
constructs (`local x="$1"; shift`, `> "$f"` spacing, `(( ))` spacing) that this fix does
not touch. Reformatting them would be scope creep into lines other in-flight work is
editing. Left as-is and recorded.

The pre-existing SC2016 info in `acceptance-authority-lib.sh` is a different file and is
not conflated with this result.

Syntax verified under both interpreters:

```
$ bash -n bubbles/scripts/guard-lib.sh    ; echo $?   # bash 5.3.15
0
$ /bin/bash -n bubbles/scripts/guard-lib.sh ; echo $? # bash 3.2.57
0
```

---

## Sweep

**Claim Source:** executed

```
$ grep -rn 'wc -[clmw]' bubbles/scripts/ tests/
SWEEP_EXIT=0
```

The sweep returned roughly 100 hits. Filtering out the `| tr -d ' '` / `| tr -d
'[:space:]'` normalized majority leaves 40 unnormalized captures.

**Result: `guard-lib.sh:131` is the only instance in this failure class.** The defect
class is a `wc` capture consumed by a *regex or string comparison*. A targeted search
for any other regex test against a `wc` capture returned nothing:

```
$ grep -rnE 'wc -[clmw][^|]*\)"?[[:space:]]*=~|=~[^"]*\$\(.*wc ' bubbles/scripts/ tests/
(no output)
```

### Fixed

| Location | Consumption | Why it is in the failure class |
|---|---|---|
| `bubbles/scripts/guard-lib.sh:131` | `[[ ! "$current_size" =~ ^[0-9]+$ ]]` | Regex test on the padded capture. **Fixed.** |

### Safe — verified, not assumed

| Consumption pattern | Locations | Why safe |
|---|---|---|
| `\| tr -d ' '` / `\| tr -d '[:space:]'` | ~60 hits across `cli.sh`, `tool-log.sh`, `gate-id-grep.sh`, `closeout-report.sh`, `surface-reachability-guard.sh`, `effective-bundle-measure.sh`, and others | Already normalized at capture. |
| Arithmetic comparison `-eq` / `-ge` / `-gt` in `[[ ]]` or `[ ]` | `tool-log-selftest.sh:55,88`; `goal-fidelity-telemetry-selftest.sh:58,92`; `guard-lib-timeout-selftest.sh:120`; `cli.sh:2352,2363`; `implementation-reality-scan.sh:392,1184` | Arithmetic evaluation strips leading whitespace. |
| `$((var + 0))` normalization | `adversarial-resolve-selftest.sh:1797,1799` | Explicitly coerced through arithmetic. |
| Word-splitting via `set -- $out` | `tests/regression/test_29_..._nounset.sh:140` | Splitting discards the pad by construction. |
| Display only — `printf`/`echo` interpolation | `spec-dashboard.sh:103`; `instruction-budget-lint.sh:54,83`; `mode-alias-selftest.sh:115,128,133`; `state-transition-guard-perf-selftest.sh:254`; `cli.sh:3852,3865`; `release-train-rollup.sh:82`; `release-train-guard.sh:153`; `observability-adapter-lint.sh:120`; `codeindex-adapter-contract-selftest.sh:380`; `regen-derived-selftest.sh:106`; `generate-telemetry-reader-map-selftest.sh:72,155` | A padded count renders with extra spaces. Cosmetic at most; no control flow depends on it. |

The two safety claims that were not self-evident were verified by execution rather than
asserted:

```
$ /bin/bash -c 'p=$(wc -c < /tmp/n.txt); if [[ "$p" -eq 2 ]]; then echo "[[ -eq ]] with padded value: OK (arithmetic strips)"; fi; if [ "$p" -ge 1 ]; then echo "[ -ge ] with padded value: OK"; fi'
[[ -eq ]] with padded value: OK (arithmetic strips)
[ -ge ] with padded value: OK

$ pad="$(wc -c < /tmp/p.txt)"; printf "  [%8d]\n" "$pad"; echo "printf_rc=$?"
  [      12]
printf_rc=0

$ sed -n "1,${pad}p" /tmp/p.txt; echo "sed_rc=$?"
hello world
sed_rc=0
```

Exit code 0 throughout. `printf %d` and `sed` line addresses both tolerate a padded
argument, which is what makes the display-only and `sed`-range hits safe rather than
latent.

### Out of boundary — not inspected for fixing

`bubbles/scripts/state-transition-guard.sh` lines 3304, 3892, 4169, 4231, 4343, 4344 and
`bubbles/scripts/state-transition-guard-selftest.sh:3525` carry `wc` captures. The
operator placed both files out of boundary for this bug (in-flight under BUG-033 /
BUG-037). They were not modified. Of these, 3525, 4169 and 4231 already normalize or use
arithmetic; the remainder were not analyzed because analysis without authority to fix
would be advisory only.

---

## Boundary compliance

**Claim Source:** executed

`git status --short` over the whole repository shows this session modified exactly one
tracked file, `bubbles/scripts/guard-lib.sh`, plus the new
`bugs/BUG-038-progress-timeout-bsd-wc-padding/` packet. Every other modified path
(`BUG-033`, `BUG-037`, `state-transition-guard.sh`, `receipt-identity-selftest.sh`,
and the rest) was already dirty on entry from in-flight work and was not touched.

No `git` command that discards changes was run. `framework-validate` and
`release-check` were not run, per operator instruction.

---

## Discovered Issues

| ID | Date | Discovered | Disposition | Reference |
|---|---|---|---|---|
| DI-038-01 | 2026-08-25 | The `v5.3-selftest.sh` T3 second-order effect at `## Second-order impact on the other caller` is a source reading, not an observed run. End-to-end confirmation needs a downstream checkout and a long suite. | routed | `bubbles.validate`, via `state.json.execution.nextRequiredOwner` |
| DI-038-02 | 2026-08-25 | `shfmt -d -i 2 -ci -bn bubbles/scripts/guard-lib.sh` exits 1 on style drift in constructs this fix does not touch. Proven identical at HEAD (36 hunk lines before and after), so it is not introduced here. | routed | `bubbles.validate`, recorded at `## Lint` with the HEAD-parity measurement |
| DI-038-03 | 2026-08-25 | Eleven evidence receipts in the shared `.specify/runtime/tool-calls.jsonl` are stale. All eleven belong to `bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization`, which `state.json.workBoundary.explicitlyOutOfBoundary` places outside this packet. Refreshing them requires re-running BUG-033's captures against files this packet may not touch. | routed | `bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization` (owner of every stale receipt) |
| DI-038-04 | 2026-08-25 | `state-transition-guard.sh` contradicts itself on a `compact` bug packet. Check 5 at line 1642 FAILS a compact packet whose `certification.completedScopes` is non-empty ("a packet with no scope decomposition cannot have completed one"). Check 15 / Gate G027 at line 4232 FAILS a packet that claims the `implement` or `test` phase while `completedScopes` is empty ("FABRICATION"). Under `bugfix-fastlane` both checks are active, so no value of `completedScopes` satisfies both: claiming the two phases that genuinely happened trips G027, and omitting them trips G022. Check 5 was taught the compact form; Check 15 was not. | resolved | Repaired in `bugs/BUG-042-compact-packet-has-no-completion-basis` (owner of `bubbles/scripts/state-transition-guard.sh`); evidence at `### DI-038-04 resolution` below |

### DI-038-04 measurement

**Claim Source:** executed — the two guard runs below bracket this packet's edits and
were captured in the present session.

```
$ bash bubbles/scripts/state-transition-guard.sh bugs/BUG-038-progress-timeout-bsd-wc-padding   # before
🔴 TRANSITION BLOCKED: 20 failure(s), 3 warning(s)
failedGateIds: [G055,G060,G022,G053,G040,G033,G095]
$ bash bubbles/scripts/state-transition-guard.sh bugs/BUG-038-progress-timeout-bsd-wc-padding   # after
🔴 TRANSITION BLOCKED: 7 failure(s), 2 warning(s)
failedGateIds: [G022,G027,G033]
```

G027 is absent from the before-set and present in the after-set. It appeared only once
the `implement` and `test` phases were recorded truthfully, which is the contradiction
DI-038-04 describes. This packet leaves the two phase records in place rather than
deleting them, because they describe work that demonstrably happened; the residual G027
objection is a guard defect, not a fabrication by this packet.

### DI-038-04 resolution

**Claim Source:** executed — run in a later session against this packet, unchanged
except for this entry, after BUG-042 made Check 15 form-aware.

BUG-042 kept G027's intent (phases must not be recorded without work evidence) and
replaced only its proxy. On a packet form whose registry-declared artifact set omits
`scopes.md`, G027 no longer asks "are scopes completed?" — a question Check 5 forbids
that form from answering yes — and instead asks whether every registry-declared
obligation is attested. Anti-fabrication is preserved: an unattested obligation still
fails G027 by name.

```
$ bash bubbles/scripts/state-transition-guard.sh bugs/BUG-038-progress-timeout-bsd-wc-padding
--- Check 15: Phase-Scope Coherence (Gate G027) ---
✅ PASS: Phase-obligation coherence verified: implement/test are backed by all 4 registry-declared obligation attestation(s) for the 'compact' form
🔴 TRANSITION BLOCKED: 5 failure(s), 2 warning(s)
failedGateIds: [G022,G033]
```

The two G027 failures are gone; `7 failure(s), 2 warning(s)` becomes
`5 failure(s), 2 warning(s)`. The remaining G022 entries (`regression`, `validate`,
`audit`) are phases this packet legitimately has not run, and G033 is DI-038-03's
BUG-033-owned stale receipts. Neither is affected by this repair.

---

## Obligation Attestations

The required set is registry-derived from `bubbles/registry/bug-packet.yaml` →
`packetForms.compact.obligationsRetained`. It is not author-chosen and cannot be
shortened. Each line below cites a discharge site that already exists in this packet.

- [x] `reproduce-before-fix` — discharged in `report.md` § "Reproduction BEFORE fix — fails without the fix": real exit code `CAPTURE_EXIT=1`, four named case failures, capture sha256 `046afc210b64d322bd313e28d339c1135d39294a33518e4aaca0d05b776ed472`. Recorded by the originating session and quoted, not re-derived; the quotation is labelled `not-run` at `### Red stage`.
- [x] `adversarial-regression` — discharged in `report.md` § "Reproduction AFTER fix": the regression is the already-committed `guard-lib-timeout-selftest.sh`, whose four adversarial cases no padded capture can satisfy. `git diff --stat` over it is empty, so the 10-of-10 result is measured against unmodified assertions.
- [x] `root-cause-stated` — discharged in `bug.md` § "Root cause": BSD `wc` field padding survives command substitution, which strips only the trailing newline, so `^[0-9]+$` rejects `"      12"`. The cause named is the absent normalization, not the regex, and not the symptom `rc=2`.
- [x] `evidence-is-execution` — discharged in `report.md`: every code block carries a `**Claim Source:**` tag, and the two blocks that are not first-hand execution (`### Red stage`, `## Second-order impact on the other caller`) are tagged `not-run` and `interpreted` rather than presented as runs. The passing stage was re-executed in the present session at `### Green stage — re-execution`, `SELFTEST_EXIT=0`.

---

## Unresolved

- `shfmt -d -i 2 -ci -bn bubbles/scripts/guard-lib.sh` still exits 1 on pre-existing
  style drift in unrelated constructs. Proven identical at HEAD. Not fixed here to avoid
  scope creep into lines other in-flight work is editing.
- `framework-validate` and `release-check` were not run in this session, by instruction.
  Full-suite confirmation that no other guard regressed is owed to the parent runner.
