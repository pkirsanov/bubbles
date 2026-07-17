# Bug: BUG-013 G028 Sensitive Client Storage Classification

## Summary

G028 Scan 2B uses line-local regular expressions instead of storage-operation
semantics. It misses credential persistence when a durable storage key is
indirected through a constant, flags noncredential market-cache and proven
cleanup lines, cannot distinguish approved from unknown market-data providers,
and its managed selftest cannot run on stock macOS because it invokes raw GNU
`timeout`.

## Severity

- [ ] Critical - System unusable, data loss
- [x] High - A blocking security gate has both false negatives and false positives
- [ ] Medium - Feature broken, workaround exists
- [ ] Low - Minor issue, cosmetic

## Status

- [ ] Reported
- [x] Confirmed by current-session production-scanner execution
- [x] In Progress
- [ ] Fixed
- [ ] Verified
- [ ] Closed

## Reproduction Steps

1. Create a JavaScript implementation file referenced by `scopes.md`.
2. Define `KEY_STORE = "providerCredentials"` and persist a credential with
   `localStorage.setItem(KEY_STORE, ...)` on a different line from the constant.
3. Add two otherwise identical `sessionStorage.setItem(...)` calls: one for an
   approved market provider and one for an unknown provider.
4. Add a noncredential market-cache write whose inline comment mentions an auth
   token, and a cleanup line that calls `localStorage.removeItem(...)` after an
   auth-token condition.
5. Run the canonical `implementation-reality-scan.sh` with `--verbose`.
6. Run `implementation-reality-scan-selftest.sh` on macOS without a command
   named `timeout` on `PATH`.

## Expected Behavior

- Credential-bearing `localStorage` persistence is always blocking, including
  literal, constant, alias-chain, and helper-indirected storage keys.
- `sessionStorage` credential access is blocking unless one exact normalized
  repo-relative path, storage key, and provider tuple is explicitly classified
  in project-owned config as a same-tab, low-privilege, third-party market-data
  credential.
- An unknown or dynamically unresolved provider fails closed.
- Auth, login-session, bearer/refresh-token, payment, card, CVV/CVC, and similar
  trust material remains blocking in every client storage kind; project config
  cannot authorize it.
- Comments and noncredential market-cache keys do not create credential taint.
- `removeItem`, delete/clear operations, and writes proven to contain only a
  scrubbed object do not create persistence violations.
- The managed selftest routes time limits through the portable helper and runs
  on macOS and Linux with exit `124` preserved for timeouts.

## Actual Behavior

The hermetic production-path reproduction exits `1` with four violations. It
misses the indirect durable credential write, reports both session providers
identically, flags the market-cache write only because its inline comment names
auth/payment terms, and flags `removeItem` through the reverse-order regex.

Against Research Lab, the same scanner reports nine Scan 2B violations. Among
them are the noncredential `rlData` cache comment/write and three lines that
delete legacy `apiKey` fields before rewriting scrubbed objects. At the same
time, the durable `KEY_STORE = "rlApiKeys"` read/write path in `rldata.js` is
not reported because the key name and storage call occur on different lines.

The managed selftest invokes `timeout 180` at three call sites. This macOS host
has `gtimeout` but no command named `timeout`, so all four existing selftest
scenarios fail before the production scanner runs.

## Environment

- Canonical repository: `/Users/pkirsanov/Projects/bubbles`
- Reporter: Research Lab
- Gate: G028 `implementation_reality_scan_gate`, Scan 2B
- Platform: macOS
- Date observed: 2026-07-12 local / 2026-07-13 UTC

## Error Output

The complete current-session output is recorded in [report.md](report.md).
Discriminating results:

```text
INDIRECT_DURABLE_OBSERVED=missed
APPROVED_SESSION_OBSERVED=flagged
UNKNOWN_SESSION_OBSERVED=flagged
SESSION_CLASSIFICATION_DIFFERENTIATED=false
NONCREDENTIAL_CACHE_OBSERVED=flagged
CREDENTIAL_CLEANUP_OBSERVED=flagged
```

## Root Cause

`implementation-reality-scan.sh` defines six case-insensitive regexes and runs
each against one physical source line at a time. The implementation does not
parse operation kind, strip inline comments, resolve string constants, follow
aliases, classify the persisted value, or consult project config for an exact
provider tuple. Its broad reverse-order expression can match any sensitive word
before any storage identifier, including `removeItem` cleanup and comments.

`implementation-reality-scan-selftest.sh` has no Scan 2B fixture. Its three
scanner wrappers call raw `timeout 180` rather than sourcing `guard-lib.sh` and
calling `bubbles_run_with_timeout`, so its existing coverage is not portable.

## Change Boundary

Allowed implementation surfaces:

- `bubbles/scripts/implementation-reality-scan.sh`
- `bubbles/scripts/implementation-reality-scan-selftest.sh`
- one narrowly scoped internal Scan 2B helper under `bubbles/scripts/` if the
  implementation owner proves it is required for token-aware analysis
- `tests/regression/test_24_g028_sensitive_client_storage.sh`
- `agents/bubbles_shared/project-config-contract.md`
- direct G028 registry and generated registry/docs surfaces
- release-manifest inputs and generated release metadata through canonical
  generators only
- this BUG-013 packet and the canonical `BUGS.md` entry

Excluded surfaces:

- Research Lab and every other downstream installed `.github/bubbles/**` copy
- Research Lab product source or project config
- unrelated implementation-reality scans, gates, tests, docs, or refactors
- a broad credential allowlist, path glob, key regex, provider wildcard,
  caller-controlled exemption, or bypass flag
- weakening the universal ban on auth/session/payment secrets in client storage
- hand-editing generated release artifacts

## Related

- Gate G028 in `bubbles/registry/gates.yaml`
- Production scanner: `bubbles/scripts/implementation-reality-scan.sh`
- Managed selftest: `bubbles/scripts/implementation-reality-scan-selftest.sh`
- Portable timeout helper: `bubbles/scripts/guard-lib.sh`
- Reporter evidence: Research Lab Feature 001 `report.md`

## Routing

The current session has no subagent-dispatch tool. Ownership therefore requires
`bubbles.design` to reconcile [design.md](design.md), then `bubbles.plan` to
reconcile [scopes.md](scopes.md) and `test-plan.json`, before
`bubbles.implement`, `bubbles.test`, `bubbles.docs`, and `bubbles.validate`
execute their phases. No fix or specialist execution is claimed by this packet.
