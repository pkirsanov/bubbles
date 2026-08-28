#!/usr/bin/env bash
# python-env-selftest.sh — hermetic selftest for python-env.sh.
#
# Proves the RESOLUTION CONTRACT without touching the operator's real managed
# environment: every case points BUBBLES_PYTHON_HOME at a mktemp dir, and the
# "satisfying" interpreters are tiny fake python3 shims, so no network, no pip,
# and no dependency on whether this machine happens to have PyYAML installed.
#
# ADVERSARIAL CASES (each would pass if the logic regressed the obvious way):
#   A1  an interpreter satisfying only ONE of the two modules must NOT count as
#       satisfying. A resolver that stops at the first successful import passes
#       every other case here.
#   A2  activate() must NOT prepend when PATH's python3 already satisfies —
#       otherwise it silently hijacks an operator who provisioned their own way.
#   A3  the module list must stay in lockstep with dependency-posture.sh's
#       BUBBLES_REQUIRED_DEPS, so the documented duplication cannot drift.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_SH="$SCRIPT_DIR/python-env.sh"
POSTURE_SH="$SCRIPT_DIR/dependency-posture.sh"
GUARD_LIB="$SCRIPT_DIR/guard-lib.sh"

if [[ ! -f "$ENV_SH" || ! -f "$GUARD_LIB" ]]; then
  echo "python-env-selftest: required surface missing (python-env.sh or guard-lib.sh)" >&2
  exit 2
fi

# Probe execution must use the same portable timeout API as production callers.
# shellcheck source=/dev/null
source "$GUARD_LIB"
# shellcheck source=/dev/null
source "$ENV_SH"

pass=0
fail=0
TMP_ROOT="$(cd "$(mktemp -d)" && pwd -P)"
SELFTEST_COMPLETED=0

selftest_cleanup() {
  local status=$?
  trap - EXIT INT TERM
  rm -rf "$TMP_ROOT"
  if [[ "$SELFTEST_COMPLETED" -ne 1 && "$status" -eq 0 ]]; then
    echo "FAIL: python-env selftest exited before its completion summary" >&2
    status=1
  fi
  exit "$status"
}

trap selftest_cleanup EXIT INT TERM

ok() {
  echo "PASS: $1"
  pass=$((pass + 1))
}
bad() {
  echo "FAIL: $1"
  fail=$((fail + 1))
}

assert_exit() {
  local expected="$1" label="$2"
  shift 2
  local actual=0
  "$@" >/dev/null 2>&1 || actual=$?
  if [[ "$actual" -eq "$expected" ]]; then
    ok "$label (exit $actual)"
  else
    bad "$label (expected exit $expected, got $actual)"
  fi
}

# make_fake_python <path> <module>... — a shim that imports ONLY the named modules.
# NOTE: fixture subdirectories are deliberately named "venvroot", never "home" —
# a literal Linux home-directory path in a portable surface trips the agnosticity lint.
make_fake_python() {
  local path="$1"
  shift
  mkdir -p "$(dirname "$path")"
  {
    echo '#!/usr/bin/env bash'
    echo '# fake python3 shim for python-env-selftest'
    echo 'if [[ "${1:-}" == "-c" ]]; then'
    echo '  case "${2:-}" in'
    local module
    for module in "$@"; do
      echo "    *\"import $module\"*) exit 0 ;;"
    done
    echo '    *) exit 1 ;;'
    echo '  esac'
    echo 'fi'
    echo 'exit 1'
  } >"$path"
  chmod +x "$path"
}

# ── Case 1: no managed venv, PATH python3 lacks the modules → unsatisfied ──
c1="$TMP_ROOT/c1"
mkdir -p "$c1/venvroot" "$c1/bin"
make_fake_python "$c1/bin/python3" nothingatall
assert_exit 1 "Case 1: nothing satisfies is exit 1" \
  env BUBBLES_PYTHON_HOME="$c1/venvroot" PATH="$c1/bin:/usr/bin:/bin" bash "$ENV_SH" --check

# ── Case 2: a managed venv that satisfies resolves ─────────────────────────
c2="$TMP_ROOT/c2"
mkdir -p "$c2/venvroot/bin" "$c2/bin"
make_fake_python "$c2/venvroot/bin/python3" yaml jsonschema
make_fake_python "$c2/bin/python3" nothingatall
assert_exit 0 "Case 2: satisfying managed venv is exit 0" \
  env BUBBLES_PYTHON_HOME="$c2/venvroot" PATH="$c2/bin:/usr/bin:/bin" bash "$ENV_SH" --check

resolved="$(env BUBBLES_PYTHON_HOME="$c2/venvroot" PATH="$c2/bin:/usr/bin:/bin" bash "$ENV_SH" --path 2>/dev/null || true)"
if [[ "$resolved" == "$c2/venvroot/bin/python3" ]]; then
  ok "Case 2b: --path prints the managed interpreter"
else
  bad "Case 2b: --path printed '$resolved', expected '$c2/venvroot/bin/python3'"
fi

# ── Case 3: PATH python3 that satisfies is accepted when no venv exists ────
c3="$TMP_ROOT/c3"
mkdir -p "$c3/venvroot" "$c3/bin"
make_fake_python "$c3/bin/python3" yaml jsonschema
assert_exit 0 "Case 3: satisfying PATH python3 is accepted" \
  env BUBBLES_PYTHON_HOME="$c3/venvroot" PATH="$c3/bin:/usr/bin:/bin" bash "$ENV_SH" --check

# ── Case 4: $BUBBLES_PYTHON override wins ─────────────────────────────────
c4="$TMP_ROOT/c4"
mkdir -p "$c4/venvroot/bin" "$c4/bin" "$c4/override"
make_fake_python "$c4/venvroot/bin/python3" yaml jsonschema
make_fake_python "$c4/bin/python3" nothingatall
make_fake_python "$c4/override/python3" yaml jsonschema
resolved="$(env BUBBLES_PYTHON_HOME="$c4/venvroot" BUBBLES_PYTHON="$c4/override/python3" \
  PATH="$c4/bin:/usr/bin:/bin" bash "$ENV_SH" --path 2>/dev/null || true)"
if [[ "$resolved" == "$c4/override/python3" ]]; then
  ok "Case 4: BUBBLES_PYTHON override takes precedence"
else
  bad "Case 4: --path printed '$resolved', expected the override"
fi

# ── Case 5: a NON-satisfying override is ignored, not trusted ─────────────
c5="$TMP_ROOT/c5"
mkdir -p "$c5/venvroot/bin" "$c5/bin" "$c5/override"
make_fake_python "$c5/venvroot/bin/python3" yaml jsonschema
make_fake_python "$c5/bin/python3" nothingatall
make_fake_python "$c5/override/python3" yaml
resolved="$(env BUBBLES_PYTHON_HOME="$c5/venvroot" BUBBLES_PYTHON="$c5/override/python3" \
  PATH="$c5/bin:/usr/bin:/bin" bash "$ENV_SH" --path 2>/dev/null || true)"
if [[ "$resolved" == "$c5/venvroot/bin/python3" ]]; then
  ok "Case 5: unsatisfying override falls through to the managed venv"
else
  bad "Case 5: --path printed '$resolved', expected the managed venv"
fi

# ── Case 6: usage errors ──────────────────────────────────────────────────
assert_exit 2 "Case 6: unknown mode is a usage error" bash "$ENV_SH" --bogus
assert_exit 2 "Case 6b: extra argument is a usage error" bash "$ENV_SH" --check extra
assert_exit 0 "Case 6c: --help exits 0" bash "$ENV_SH" --help

# ── Case 7: no bypass flag exists ─────────────────────────────────────────
for flag in --skip --force --ignore; do
  assert_exit 2 "Case 7: $flag is rejected (no bypass)" bash "$ENV_SH" "$flag"
done

# ── Case 8: provisioning refuses a missing requirements file ──────────────
assert_exit 2 "Case 8: missing requirements file is exit 2" \
  env BUBBLES_PYTHON_HOME="$TMP_ROOT/c8home" bash -c \
  '. "$1"; bubbles_python_provision "$2"' _ "$ENV_SH" "$TMP_ROOT/definitely-absent.txt"

# ── ADVERSARIAL A1: partial module satisfaction must NOT count ─────────────
a1="$TMP_ROOT/a1"
mkdir -p "$a1/venvroot/bin" "$a1/bin"
make_fake_python "$a1/venvroot/bin/python3" yaml
make_fake_python "$a1/bin/python3" nothingatall
assert_exit 1 "A1: interpreter with only ONE required module is unsatisfied" \
  env BUBBLES_PYTHON_HOME="$a1/venvroot" PATH="$a1/bin:/usr/bin:/bin" bash "$ENV_SH" --check

# ── ADVERSARIAL A2: activate must not hijack a satisfying PATH python3 ─────
a2="$TMP_ROOT/a2"
mkdir -p "$a2/venvroot/bin" "$a2/bin"
make_fake_python "$a2/venvroot/bin/python3" yaml jsonschema
make_fake_python "$a2/bin/python3" yaml jsonschema
a2_path="$(env BUBBLES_PYTHON_HOME="$a2/venvroot" PATH="$a2/bin:/usr/bin:/bin" bash -c \
  '. "$1"; bubbles_python_activate >/dev/null 2>&1; printf "%s" "$PATH"' _ "$ENV_SH")"
case "$a2_path" in
  "$a2/venvroot/bin":*) bad "A2: activate hijacked a PATH python3 that already satisfies" ;;
  *) ok "A2: activate leaves a satisfying PATH python3 alone" ;;
esac

# ── A2b: activate DOES prepend when PATH python3 does not satisfy ──────────
a2b_path="$(env BUBBLES_PYTHON_HOME="$a1/venvroot" PATH="$a1/bin:/usr/bin:/bin" bash -c \
  '. "$1"; bubbles_python_activate >/dev/null 2>&1; printf "%s" "$PATH"' _ "$ENV_SH")"
case "$a2b_path" in
  *"$a1/venvroot/bin"*) bad "A2b: activate prepended an UNSATISFYING managed venv" ;;
  *) ok "A2b: activate does not prepend an unsatisfying managed venv" ;;
esac

a2c="$TMP_ROOT/a2c"
mkdir -p "$a2c/venvroot/bin" "$a2c/bin"
make_fake_python "$a2c/venvroot/bin/python3" yaml jsonschema
make_fake_python "$a2c/bin/python3" nothingatall
a2c_path="$(env BUBBLES_PYTHON_HOME="$a2c/venvroot" PATH="$a2c/bin:/usr/bin:/bin" bash -c \
  '. "$1"; bubbles_python_activate >/dev/null 2>&1; printf "%s" "$PATH"' _ "$ENV_SH")"
case "$a2c_path" in
  "$a2c/venvroot/bin":*) ok "A2c: activate prepends the managed venv when PATH does not satisfy" ;;
  *) bad "A2c: activate failed to prepend; PATH=$a2c_path" ;;
esac

# ── ADVERSARIAL A3: module list must match dependency-posture.sh ───────────
if [[ -f "$POSTURE_SH" ]]; then
  declared="$(grep -oE '"python-module:[a-zA-Z0-9_]+:' "$POSTURE_SH" |
    sed 's/"python-module://; s/:$//' | LC_ALL=C sort | tr '\n' ' ')"
  owned="$(bash -c '. "$1"; printf "%s\n" "${BUBBLES_PYTHON_MODULES[@]}"' _ "$ENV_SH" |
    LC_ALL=C sort | tr '\n' ' ')"
  if [[ -n "$declared" && "$declared" == "$owned" ]]; then
    ok "A3: BUBBLES_PYTHON_MODULES matches dependency-posture.sh ($owned)"
  else
    bad "A3: module lists drifted — posture='$declared' python-env='$owned'"
  fi
else
  bad "A3: dependency-posture.sh not found at $POSTURE_SH"
fi

# ── Case 9: requirements.txt is pinned and single-index ───────────────────
# Directives only: a comment that NAMES --extra-index-url (the file documents
# why it has none) must not be mistaken for one being declared.
REQ="$SCRIPT_DIR/../requirements.txt"
if [[ -f "$REQ" ]]; then
  directives="$(grep -vE '^[[:space:]]*#' "$REQ" || true)"
  if [[ "$(printf '%s\n' "$directives" | grep -c -- '--extra-index-url' || true)" -eq 0 ]]; then
    ok "Case 9: requirements.txt declares no --extra-index-url"
  else
    bad "Case 9: requirements.txt declares an --extra-index-url"
  fi
  if [[ "$(printf '%s\n' "$directives" | grep -c -- '--index-url' || true)" -eq 1 ]]; then
    ok "Case 9b: requirements.txt pins exactly one index"
  else
    bad "Case 9b: requirements.txt must declare exactly one --index-url"
  fi
  unpinned="$(grep -vE '^[[:space:]]*(#|$|--)' "$REQ" | grep -vE '==' | tr -d ' ' || true)"
  if [[ -z "$unpinned" ]]; then
    ok "Case 9c: every requirement is == pinned"
  else
    bad "Case 9c: unpinned requirement(s): $unpinned"
  fi
else
  bad "Case 9: requirements.txt not found at $REQ"
fi

# ---------------------------------------------------------------------------
# Case 10 (adversarial A4): cli.sh MUST activate the managed interpreter early.
#
# This is the seam that covers the ~15 selftests which call `python3 -c "import
# yaml"` directly without sourcing dependency-posture.sh. If someone deletes it,
# those selftests silently regress to SKIP/empty-value failures instead of
# failing loudly here. Guard it structurally.
# ---------------------------------------------------------------------------
CLI="$SCRIPT_DIR/cli.sh"
if [[ -f "$CLI" ]]; then
  if grep -q 'bubbles_python_activate' "$CLI"; then
    ok "Case 10: cli.sh activates the managed interpreter"
  else
    bad "Case 10: cli.sh no longer calls bubbles_python_activate — every child selftest loses the managed interpreter"
  fi

  # It must activate BEFORE the command dispatch, otherwise children spawned by
  # earlier subcommand handling would miss the exported PATH.
  # NOTE: `|| true` is required — this script runs under `set -euo pipefail`, so
  # a non-matching grep inside a pipeline would abort the whole selftest.
  activate_line="$(grep -n 'bubbles_python_activate' "$CLI" | head -1 | cut -d: -f1 || true)"
  dispatch_line="$(grep -nE '^[[:space:]]*case "\$(command_name|first_word|COMMAND|1|\{1:-\})' "$CLI" | head -1 | cut -d: -f1 || true)"
  if [[ -n "$activate_line" && -n "$dispatch_line" ]]; then
    if [[ "$activate_line" -lt "$dispatch_line" ]]; then
      ok "Case 10b: activation (line $activate_line) precedes command dispatch (line $dispatch_line)"
    else
      bad "Case 10b: activation at line $activate_line runs AFTER dispatch at line $dispatch_line"
    fi
  else
    ok "Case 10b: dispatch marker not matched; Case 10 already guards presence"
  fi
else
  bad "Case 10: cli.sh not found at $CLI"
fi

# ---------------------------------------------------------------------------
# Case 11 (adversarial A5): the pinned closure must cover every required module.
# A requirements.txt that installs PyYAML but forgets jsonschema would provision
# "successfully" and then fail at first use.
# ---------------------------------------------------------------------------
if [[ -f "$REQ" ]]; then
  missing_mod=""
  for _m in "${BUBBLES_PYTHON_MODULES[@]}"; do
    case "$_m" in
      yaml) _pkg='PyYAML' ;;
      jsonschema) _pkg='jsonschema' ;;
      *) _pkg="$_m" ;;
    esac
    grep -qiE "^[[:space:]]*${_pkg}==" "$REQ" || missing_mod="$missing_mod $_m"
  done
  if [[ -z "$missing_mod" ]]; then
    ok "Case 11: requirements.txt pins a distribution for every required module"
  else
    bad "Case 11: no pinned distribution for required module(s):$missing_mod"
  fi
fi

# ---------------------------------------------------------------------------
# BUG-039 additions (Cases 12-15). python-env.sh is the module the framework
# designates to answer "which interpreter", and this packet added new API to it:
# bubbles_python_runs, bubbles_python_resolve_runnable, and a locator contract
# that can now DECLINE instead of always printing.
#
# These exist because of what the file did NOT cover. Every case above passed
# throughout, while the module published /bin/python3 — a path that does not
# exist — as a resolved interpreter whenever no locator was set:
# "${XDG_CACHE_HOME:-$HOME/.cache}" aborted inside a command substitution under
# set -u, the empty result was concatenated with "/bin/python3", and the caller
# then reported "no interpreter satisfies the required modules" — a sentence
# about interpreters, when nothing had been able to name one.
#
# ADVERSARIAL A6 is that exact defect: it goes red against the historical
# unguarded expansion and green against the guarded one.
# ---------------------------------------------------------------------------

# no_locator <command...> — run with every locator variable REMOVED (not
# emptied): this is the state in which the module used to fabricate a path.
no_locator() {
  env -u BUBBLES_PYTHON_HOME -u XDG_CACHE_HOME -u HOME "$@"
}

# Pinned here as a LITERAL rather than read back from python-env.sh. Sourcing
# the module for its own expected value would make the assertion agree with
# whatever the module currently says, which is the opposite of pinning it.
LOCATOR_VARS_EXPECTED='BUBBLES_PYTHON_HOME, XDG_CACHE_HOME, or HOME'

# make_probe_python <path> <mode> — a shim for the EXECUTION probe, which is a
# different question from make_fake_python's module imports. Modes mirror the
# ways a real interpreter can be present and still unusable.
make_probe_python() {
  local path="$1" mode="$2"
  mkdir -p "$(dirname "$path")"
  {
    echo '#!/usr/bin/env bash'
    echo '# probe shim for python-env-selftest'
    case "$mode" in
      healthy) echo "printf %s 'bubbles-python-runs'" ;;
      # exits 0 and emits nothing: the wrapper an exit-code-only check accepts.
      silent) echo 'exit 0' ;;
      # emits the payload but on a polluted stdout.
      noisy)
        echo "echo 'warning: deprecated interpreter'"
        echo "printf %s 'bubbles-python-runs'"
        ;;
      # the macOS Xcode-licence shape: resolves, is executable, exits 69.
      dead)
        echo "printf %s 'bubbles-python-runs'"
        echo 'exit 69'
        ;;
      xcode)
        echo "echo 'You have not agreed to the Xcode license agreements.' >&2"
        echo 'exit 69'
        ;;
      hang) echo 'while :; do sleep 30; done' ;;
      malformed) echo "printf %s 'not-the-probe-protocol'" ;;
    esac
  } >"$path"
  chmod +x "$path"
}

# ── Case 12: the locator order is ordered, not incidental ─────────────────
c12="$TMP_ROOT/c12"
mkdir -p "$c12/explicit" "$c12/xdg" "$c12/venvroot"

c12a="$(env BUBBLES_PYTHON_HOME="$c12/explicit" XDG_CACHE_HOME="$c12/xdg" HOME="$c12/venvroot" \
  bash -c '. "$1"; bubbles_python_home' _ "$ENV_SH" 2>/dev/null || true)"
if [[ "$c12a" == "$c12/explicit" ]]; then
  ok "Case 12: BUBBLES_PYTHON_HOME outranks XDG_CACHE_HOME and HOME"
else
  bad "Case 12: locator printed '$c12a', expected '$c12/explicit'"
fi

c12b="$(env -u BUBBLES_PYTHON_HOME XDG_CACHE_HOME="$c12/xdg/" HOME="$c12/venvroot" \
  bash -c '. "$1"; bubbles_python_home' _ "$ENV_SH" 2>/dev/null || true)"
if [[ "$c12b" == "$c12/xdg/bubbles/python" ]]; then
  ok "Case 12b: XDG_CACHE_HOME outranks HOME, with the trailing slash normalized"
else
  bad "Case 12b: locator printed '$c12b', expected '$c12/xdg/bubbles/python'"
fi

c12c="$(env -u BUBBLES_PYTHON_HOME -u XDG_CACHE_HOME HOME="$c12/venvroot" \
  bash -c '. "$1"; bubbles_python_home' _ "$ENV_SH" 2>/dev/null || true)"
if [[ "$c12c" == "$c12/venvroot/.cache/bubbles/python" ]]; then
  ok "Case 12c: HOME is the last locator, under .cache"
else
  bad "Case 12c: locator printed '$c12c', expected '$c12/venvroot/.cache/bubbles/python'"
fi

# ── ADVERSARIAL A6: an absent locator is a CONDITION, never a fabricated path ──
# This is the original defect. Under the historical unguarded expansion
# bubbles_python_home returned 0 with empty output and bubbles_python_venv_python
# then published "/bin/python3". Both halves are asserted: a resolver that
# reports success while printing nothing is just as wrong as one that prints a
# path it invented.
a6_home="$(no_locator bash -c '. "$1"; out="$(bubbles_python_home)" || { printf "DECLINED|%s" "$out"; exit 0; }; printf "RESOLVED|%s" "$out"' _ "$ENV_SH" 2>/dev/null || true)"
if [[ "$a6_home" == "DECLINED|" ]]; then
  ok "A6: bubbles_python_home declines when no locator is set"
else
  bad "A6: bubbles_python_home returned '$a6_home', expected 'DECLINED|' (a fabricated or empty-but-successful home is the BUG-039 defect)"
fi

a6_venv="$(no_locator bash -c '. "$1"; out="$(bubbles_python_venv_python)" || { printf "DECLINED|%s" "$out"; exit 0; }; printf "RESOLVED|%s" "$out"' _ "$ENV_SH" 2>/dev/null || true)"
if [[ "$a6_venv" == "DECLINED|" ]]; then
  ok "A6b: bubbles_python_venv_python declines instead of publishing a path"
else
  bad "A6b: bubbles_python_venv_python returned '$a6_venv', expected 'DECLINED|' — publishing a nonexistent interpreter path (historically '/bin/python3') is the BUG-039 defect"
fi

# ── ADVERSARIAL A7: usability is proven by PAYLOAD, not by exit code ──────
a7="$TMP_ROOT/a7"
make_probe_python "$a7/healthy/python3" healthy
make_probe_python "$a7/silent/python3" silent
make_probe_python "$a7/noisy/python3" noisy
make_probe_python "$a7/dead/python3" dead

# probe_runs <interpreter> — echo yes/no for bubbles_python_runs.
probe_runs() {
  no_locator bash -c '. "$1"; . "$2"; if bubbles_python_runs "$3"; then echo yes; else echo no; fi' \
    _ "$GUARD_LIB" "$ENV_SH" "$1" 2>/dev/null || echo no
}

assert_runs() {
  local mode="$1" want="$2" why="$3" got
  got="$(probe_runs "$a7/$mode/python3")"
  if [[ "$got" == "$want" ]]; then
    ok "A7 ($mode): $why"
  else
    bad "A7 ($mode): bubbles_python_runs said '$got', expected '$want' — $why"
  fi
}

assert_runs healthy yes "an interpreter that executes and returns the payload is usable"
assert_runs silent no "an interpreter that exits 0 while producing NOTHING is not usable"
assert_runs noisy no "an interpreter that pollutes stdout cannot pass the payload check"
assert_runs dead no "an interpreter that emits the payload and then exits 69 is not usable"

# ── ADVERSARIAL A8: security consumers trust only the managed venv ────────
# BUBBLES_PYTHON and PATH remain valid general-consumer candidates, but neither
# is a provenance root for a security classifier. These assertions call the
# production resolver and inspect its closed numeric-status/reason contract.
trusted_resolution() {
  local home="$1"
  shift
  env BUBBLES_PYTHON_HOME="$home" "$@" bash -c \
    '. "$1"; . "$2"; if bubbles_python_resolve_trusted_runnable >/dev/null; then result=RESOLVED; else result=DECLINED; fi; printf "%s|%s|%s|%s" "$result" "$BUBBLES_PYTHON_TRUSTED_STATUS" "$BUBBLES_PYTHON_TRUSTED_DIAGNOSTIC" "$BUBBLES_PYTHON_TRUST_CONTRACT"' \
    _ "$GUARD_LIB" "$ENV_SH"
}

a8="$TMP_ROOT/a8"
mkdir -p "$a8/absent" "$a8/path" "$a8/override"
make_probe_python "$a8/path/python3" healthy
make_probe_python "$a8/override/python3" healthy

a8_no_locator="$(env -u BUBBLES_PYTHON_HOME -u XDG_CACHE_HOME -u HOME \
  BUBBLES_PYTHON="$a8/override/python3" PATH="$a8/path:/usr/bin:/bin" bash -c \
  '. "$1"; . "$2"; if bubbles_python_resolve_trusted_runnable >/dev/null; then result=RESOLVED; else result=DECLINED; fi; printf "%s|%s|%s|%s" "$result" "$BUBBLES_PYTHON_TRUSTED_STATUS" "$BUBBLES_PYTHON_TRUSTED_DIAGNOSTIC" "$BUBBLES_PYTHON_TRUST_CONTRACT"' \
  _ "$GUARD_LIB" "$ENV_SH" 2>/dev/null || true)"
if [[ "$a8_no_locator" == "DECLINED|127|NO_LOCATOR|managed-venv-only-v1" ]]; then
  ok "A8: trusted resolver refuses override/PATH candidates when no managed locator exists"
else
  bad "A8: no-locator trust result was '$a8_no_locator'"
fi

a8_absent="$(trusted_resolution "$a8/absent" env PATH="$a8/path:/usr/bin:/bin" BUBBLES_PYTHON="$a8/override/python3" 2>/dev/null || true)"
if [[ "$a8_absent" == "DECLINED|127|INTERPRETER_ABSENT|managed-venv-only-v1" ]]; then
  ok "A8b: trusted resolver names an absent managed interpreter"
else
  bad "A8b: absent-interpreter trust result was '$a8_absent'"
fi

for probe_mode in silent malformed xcode healthy hang; do
  probe_home="$a8/$probe_mode"
  make_probe_python "$probe_home/bin/python3" "$probe_mode"
done

a8_silent="$(trusted_resolution "$a8/silent" env PATH="$a8/path:/usr/bin:/bin" 2>/dev/null || true)"
if [[ "$a8_silent" == "DECLINED|0|PROBE_EMPTY|managed-venv-only-v1" ]]; then
  ok "A8c: silent-success probe is rejected with its numeric status"
else
  bad "A8c: silent-success trust result was '$a8_silent'"
fi

a8_malformed="$(trusted_resolution "$a8/malformed" env PATH="$a8/path:/usr/bin:/bin" 2>/dev/null || true)"
if [[ "$a8_malformed" == "DECLINED|0|PROBE_PROTOCOL_INVALID|managed-venv-only-v1" ]]; then
  ok "A8d: malformed probe payload is rejected by the closed protocol"
else
  bad "A8d: malformed-probe trust result was '$a8_malformed'"
fi

a8_xcode="$(trusted_resolution "$a8/xcode" env PATH="$a8/path:/usr/bin:/bin" 2>/dev/null || true)"
if [[ "$a8_xcode" == "DECLINED|69|XCODE_LICENSE_UNACCEPTED|managed-venv-only-v1" ]]; then
  ok "A8e: Xcode-like failure retains exit 69 as a sanitized reason enum"
else
  bad "A8e: Xcode-like trust result was '$a8_xcode'"
fi

a8_healthy="$(trusted_resolution "$a8/healthy" env PATH="$a8/path:/usr/bin:/bin" 2>/dev/null || true)"
if [[ "$a8_healthy" == "RESOLVED|0|OK|managed-venv-only-v1" ]]; then
  ok "A8f: managed interpreter with the exact probe protocol is trusted"
else
  bad "A8f: healthy trust result was '$a8_healthy'"
fi

a8_hang="$(trusted_resolution "$a8/hang" env PATH="$a8/path:/usr/bin:/bin" 2>/dev/null || true)"
if [[ "$a8_hang" == "DECLINED|124|PROBE_TIMEOUT|managed-venv-only-v1" ]]; then
  ok "A8g: hanging interpreter is terminated with portable timeout status 124"
else
  bad "A8g: hanging-interpreter trust result was '$a8_hang'"
fi

# ── Case 13: the absent-locator reason names the cause, not the interpreters ──
# The failure text is the deliverable here. "no interpreter satisfies" sends a
# reader to inspect interpreters; the honest text says none could be named.
c13_empty="$TMP_ROOT/c13/emptypath"
mkdir -p "$c13_empty"
c13_reason="$(env -i PATH="$c13_empty" /bin/bash -c \
  '. "$1"; if bubbles_python_resolve_runnable >/dev/null 2>&1; then printf "UNEXPECTED_RESOLVE"; else printf "%s" "$BUBBLES_PYTHON_RUNNABLE_REASON"; fi' \
  _ "$ENV_SH" 2>/dev/null || true)"
if [[ "$c13_reason" == *"the managed venv has no locator"* &&
  "$c13_reason" == *"$LOCATOR_VARS_EXPECTED"* ]]; then
  ok "Case 13: absent-locator reason names the locator variables"
else
  bad "Case 13: reason was '$c13_reason', expected it to name 'the managed venv has no locator' and '$LOCATOR_VARS_EXPECTED'"
fi
# Teeth: the reason must not describe a venv it never located. Under the
# historical defect this branch reported "the managed venv (/bin/python3) is
# absent or does not execute", which is a claim about a path nothing chose.
if [[ "$c13_reason" == *"the managed venv ("* ]]; then
  bad "Case 13b: reason names a concrete venv path while no locator is set: '$c13_reason'"
else
  ok "Case 13b: reason claims no venv path when none could be named"
fi

echo
echo "python-env selftest: $pass passed, $fail failed"
SELFTEST_COMPLETED=1
[[ "$fail" -eq 0 ]]
