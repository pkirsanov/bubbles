# User Validation: BUG-039

Items are checked because they were just validated by execution. Uncheck any item
that does not reproduce for you; an unchecked item is a reported regression.

## Checklist

### [Bug Fix] [BUG-039] Unusable interpreter is named, not misreported as classification failures

- [x] **What:** With an unusable interpreter the managed selftest skips the Scan 2B group with a named cause and remediation instead of reporting 11 classification failures.
  - **Steps:**
    1. `env -i PATH=/usr/bin:/bin:/usr/sbin:/sbin /bin/bash bubbles/scripts/implementation-reality-scan-selftest.sh </dev/null`
  - **Expected:** exit 0; one `SKIP:` naming the interpreter, its exit status and the operator remediation; zero `FAIL:` lines; `SENSITIVE_STORAGE_CLASSIFIER_UNAVAILABLE=1` present.
  - **Verify:** terminal exit code and output
  - **Evidence:** [report.md](report.md) §6
  - **Notes:** Before the fix this run reported `failed with 11 issue(s)`.

- [x] **What:** With a usable interpreter under the same sanitized PATH, every assertion still runs.
  - **Steps:**
    1. `env -i PATH=/usr/bin:/bin:/usr/sbin:/sbin DEVELOPER_DIR=/Library/Developer/CommandLineTools /bin/bash bubbles/scripts/implementation-reality-scan-selftest.sh </dev/null`
  - **Expected:** exit 0, zero skips, `implementation-reality-scan selftest passed.`
  - **Verify:** terminal exit code and output
  - **Evidence:** [report.md](report.md) §6

- [x] **What:** A real classifier regression is still caught; the skip does not swallow failures.
  - **Steps:**
    1. In `bubbles/scripts/guards/sensitive-client-storage-scan.py` change `storage != "sessionStorage"` to `storage != "localStorage"`.
    2. `bash bubbles/scripts/implementation-reality-scan-selftest.sh </dev/null`
    3. Revert the change.
  - **Expected:** step 2 exits 1 with 3 semantic failures; after revert, exit 0 and the file is byte-identical.
  - **Verify:** terminal exit code, then `git diff --quiet` on the file
  - **Evidence:** [report.md](report.md) §7

- [x] **What:** The cascading regression test records a skip, not a pass.
  - **Steps:**
    1. `bash tests/regression/test_24_g028_sensitive_client_storage.sh </dev/null`
  - **Expected:** exit 0; summary `57 passed, 0 failed, 1 skipped`; the label `managed selftest runs with the system-only PATH` is absent.
  - **Verify:** terminal exit code and summary line
  - **Evidence:** [report.md](report.md) §8
  - **Notes:** Before the fix this reported `FAIL: managed selftest runs with the system-only PATH`.

## Operator Action Still Available

The skip is a correct response to an absent prerequisite, not a substitute for
it. To restore full Scan 2B coverage on this machine, either accept the Xcode
licence (`sudo xcodebuild -license accept`) or point the active developer
directory at an accepted toolchain
(`sudo xcode-select -s /Library/Developer/CommandLineTools`). Both require a
password and are the operator's to give.
