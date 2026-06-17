# Bubbles Framework — Known Bugs

> **Why this file exists:** the Bubbles source repo cannot keep `specs/` (G085 dogfood guard), so framework-internal defects are tracked here as the operator-visible bug log. Downstream consumer repos file their bugs in their own `specs/<feature>/bugs/BUG-NNN-*/` structure as usual.
>
> Every entry below has an explicit disposition per Gate G095 (Discovered-Issue Disposition).

---

## BUG-001 — state-transition-guard.sh hangs in Check 3G (Framework Ownership And Result Contract)

- **Filed:** 2026-05-27
- **Disposition:** mitigated + items 2/4 hypothesis-invalidated (2026-06-11 empirical re-test) — fail-safe timeout shipped AND the suspected filesystem-walk root cause does NOT exist in the actual Check 3G sub-guard; no hang reproduces in source or any of the 5 downstream layouts. See "Empirical Re-Test (2026-06-11)" below.
- **Discovered by:** `bubbles.goal` session implementing G022/G060/G061 fixes
- **Severity:** low (was medium) — the guard now fails cleanly instead of hanging; selftest converges
- **Affects:** `bubbles/scripts/state-transition-guard.sh` Check 3G (Framework Ownership And Result Contract — gates G042/G063/G064)

### Mitigation Shipped (partial)

Check 3G now wraps its sub-guard invocation in a hard timeout and reports its
wall-clock cost, so the indefinite hang is gone — the check fails safe with a
named error instead of blocking forever:

- `state-transition-guard.sh` ~L765: `bubbles_run_with_timeout 30 bash "$framework_ownership_lint_script"` — on overrun it emits `Framework ownership lint TIMED OUT after 30s (BUG-001 guard)` and counts a failure (item 1 — done for Check 3G).
- `state-transition-guard.sh` ~L779: `warn "Check 3G wall-clock ${_c3g_elapsed}s exceeded the 30s budget"` (item 3 — per-check budget surfaced for Check 3G).
- The same `bubbles_run_with_timeout` wrapper now guards the other heavy sub-invocations (artifact-lint ~L2158, freshness-guard ~L2176, reality-scan ~L2352).

Items 2 & 4 are RECLASSIFIED as hypothesis-invalidated (not a live defect) — see the
Empirical Re-Test below. A full Checks 3–34 timeout audit (item 1 broadened to every
check) remains advisable but is not blocking.

### Empirical Re-Test (2026-06-11)

Re-investigated under a `bubbles.goal` monitoring session. Findings:

- Check 3G's ONLY sub-guard is `agent-ownership-lint.sh` (`state-transition-guard.sh`
  L364: `framework_ownership_lint_script="$SCRIPT_DIR/agent-ownership-lint.sh"`).
- That script contains **no** `find` / `grep -r` / `ls -R` recursive walk, so the
  "filesystem-walk exclusions" root cause (item 2) does not apply to it — it only
  greps a fixed set of known files.
- Measured runtime: **~0.3s** in the source layout and RC=0 / "Agent ownership lint
  passed." in all 5 downstream installed layouts. No hang anywhere.
- The only way its `grep -nE "$pattern" "$file"` helpers could hang is if `grep`
  received **zero** file args and fell back to stdin (verified: that path does hang,
  RC=124 under `timeout`). But every call passes a quoted `"$file"`, and
  `set -euo pipefail` makes an unset path a hard error — so grep always gets exactly
  one file arg and can never block on stdin. A missing/empty file arg returns RC=2
  (clean error), not a hang.

Conclusion: the documented hang does not reproduce in the current sub-guard; items 2
(walk exclusions) and 4 (500-spec walk perf fixture) target a root cause that is not
present. The shipped 30s timeout already makes any hypothetical future regression
fail-safe. If a hang ever recurs, root-cause it in `state-transition-guard.sh`'s own
Check-3G framing or a *different* check — not in a (nonexistent) sub-guard walk.

### Reproduction

```bash
cd /path/to/any/downstream/repo/with/real/spec
timeout 15 bash <bubbles>/bubbles/scripts/state-transition-guard.sh specs/<NNN-feature>
# Observed: process times out (exit 124); last printed line is "--- Check 3G: Framework Ownership And Result Contract (G042/G063/G064) ---"
# Hang occurs AFTER Check 3F completes successfully.
```

Concrete observation during the G022/G060/G061 fix session:

```
✅ PASS: state.json transitionRequests queue is empty
✅ PASS: state.json reworkQueue is empty
✅ PASS: Transition and rework routing is closed

--- Check 3G: Framework Ownership And Result Contract (G042/G063/G064) ---
<hangs indefinitely until SIGTERM>
```

### Suspected Root Cause

> **INVALIDATED 2026-06-11** (see Empirical Re-Test above): the actual Check 3G
> sub-guard `agent-ownership-lint.sh` performs NO recursive filesystem walk and
> runs in ~0.3s across source + all 5 downstream layouts. The walk hypothesis below
> is retained for history only.

Check 3G appears to invoke a sub-guard (likely `agent-ownership-lint.sh` or a packet-routing scanner) without a timeout, OR performs a recursive filesystem walk that touches large generated directories (`.git/`, `node_modules/`, `target/`, `vendor/`, `dist/`, container build caches) without exclusions. Needs root-cause investigation.

### Impact

- `state-transition-guard.sh` cannot complete on real downstream spec dirs in reasonable time (observed >60s, killed at 300s during selftest).
- `state-transition-guard-selftest.sh` runs all 1230 lines through the guard repeatedly and exceeds wall-clock budget on developer machines.
- Forces operators to invoke individual sub-guards instead of the unified entry point.

### Required Fix

1. ~~Add a 30s hard timeout around every sub-guard invocation in Check 3G (and audit Checks 3-34 for the same pattern).~~ **DONE for Check 3G + the heavy sub-invocations** (see Mitigation Shipped above); a full Checks 3–34 audit is still advisable.
2. Add exclusion globs (`.git`, `node_modules`, `target`, `vendor`, `dist`, `__pycache__`, `.bubbles-cache`, container build dirs) to any filesystem walks in Check 3G's sub-guards. **INVALIDATED 2026-06-11** — the Check 3G sub-guard has no filesystem walk; nothing to exclude (see Empirical Re-Test).
3. ~~Add a per-check wall-clock budget reported in the verdict so future regressions surface immediately.~~ **DONE for Check 3G** (budget warn at ~L779); broaden to all checks if the pattern recurs.
4. Add a hermetic perf regression to `tests/regression/` that runs Check 3G against a synthetic 500-spec fixture and fails if elapsed > 5s. **MOOT 2026-06-11** — the sub-guard does not walk specs, so a 500-spec fixture exercises no slow path; a generic per-check wall-clock budget (item 3, broadened) is the better guard if regressions recur.

### Acceptance

- `timeout 60 bash bubbles/scripts/state-transition-guard.sh specs/<real-feature>` returns exit code (any) within 60s on every downstream repo.
- `state-transition-guard-selftest.sh` completes within 5 minutes.
- Per-check wall-clock budget appears in verdict block.

### Cross-References

- Discovered while implementing G022/G060/G061 (commit `1d79931`).
- This bug is the canonical demonstration of Gate G095 (Discovered-Issue Disposition) — it was previously deflected with "pre-existing and unrelated" and is now filed properly.

---

## BUG-002 — MCP stdio transport used Content-Length framing; VS Code's newline-delimited JSON-RPC hung the server

- **Filed:** 2026-06-11
- **Disposition:** fixed (working tree; not committed) — fix + adversarial regression landed across canonical + all 5 vendored copies
- **Discovered by:** operator report — VS Code "Configure Tools" could not populate the `bubbles-<slug>` MCP tool list (the checkbox would not stick; "Update Tools" spun forever)
- **Severity:** high — the stdio MCP server was unusable from VS Code (the primary MCP client): no tool list, no tool calls
- **Affects:** `bubbles/mcp/server.py` → `StdioTransport.read_message` / `write_message` (and the byte-identical vendored copies in all 5 product repos). HTTP transport unaffected.

> **Artifact convention:** the Bubbles source repo cannot keep `specs/` (Gate
> G085 dogfood guard), so this single entry is the full bug artifact
> (reproduction + root cause + expected-behavior spec + fix design + scope/DoD +
> evidence), standing in for the `specs/<feature>/bugs/BUG-NNN-*/` six-file set
> that downstream consumer repos use.

### Reproduction

The MCP stdio transport frames each JSON-RPC message as newline-delimited JSON
(one object per line). VS Code sends exactly that. The pre-fix server used
LSP-style `Content-Length:` header framing for stdio read AND write, so the
line VS Code sends was parsed as an HTTP header block, `Content-Length` was
never found, `read_message` looped on `readline()` and blocked forever — the
server never replied, so "Configure Tools" could not populate the tool list.

Driving the pre-fix server (materialized via `git worktree add --detach HEAD`)
through the adversarial regression suite reproduces the failure modes:

```
test_newline_delimited_object_parses ... FAIL
    AssertionError: None != {'jsonrpc': '2.0', 'id': 1, 'method': 'initialize', 'params': {}}
test_writes_newline_terminated_json_without_header ... FAIL
    AssertionError: b'Content-Length: 45\r\n\r\n{"jsonrpc":"2.0","id":1,"result":{"ok":true}}'
test_newline_framed_handshake_lists_ten_tools ... FAIL
    AssertionError: 1 not found in {} : no initialize reply; stdout=b'' stderr=b''
test_content_length_backcompat ... ok
Ran 7 tests ... FAILED (failures=3, errors=1)
```

### Root Cause (proven)

`StdioTransport.read_message` assumed an LSP-style `Content-Length:` header
block and `write_message` emitted one. MCP stdio is newline-delimited
JSON-RPC 2.0. VS Code sends `{...}\n`; the header parser never finds
`Content-Length`, leaves `content_length=None`, loops on `readline()`, and
blocks indefinitely.

### Expected Behavior (spec)

- stdio read and write MUST be newline-delimited JSON-RPC 2.0 (one object per
  line, terminated by `\n`) per the MCP stdio transport spec.
- A legacy LSP-style `Content-Length` header block MUST still be accepted on
  READ for back-compat.
- The HTTP transport (which legitimately uses `Content-Length`) MUST be
  untouched.

### The Fix

`bubbles/mcp/server.py`:
- `read_message` reads a line, skips blank separator lines, and parses it as a
  JSON object (newline-delimited, primary path). If the line begins with
  `content-length:` it falls back to consuming the legacy header block + body.
- `write_message` writes `payload + b"\n"` with no header.
- The module docstring transport line and the framing comment block above
  `class StdioTransport` were corrected to describe newline-delimited framing
  (legacy Content-Length accepted on read).

`bubbles/scripts/mcp-server-selftest.sh`:
- The in-harness `read_frame()` now reads newline-delimited replies (with a
  legacy Content-Length fallback), mirroring the server. `frame()` still WRITES
  Content-Length so the selftest keeps exercising the server's back-compat read
  path. All T1–T19 stay green.

The `StdioTransport` class body + comment block + docstring transport line are
byte-identical across all 6 copies (canonical + 5 vendored).

### Regression Test

`tests/test_mcp_stdio_framing.py` — stdlib `unittest`, adversarial:
- (a) newline `read_message` returns the parsed dict;
- (b) `write_message` emits JSON + `\n` and contains NO `Content-Length`;
- (c) legacy Content-Length is still accepted on read (back-compat);
- (d) full subprocess handshake (initialize → notifications/initialized →
  tools/list) over NEWLINE framing returns exactly the 10 tools, with a hard
  15 s timeout so a regression fails the test instead of hanging the suite.

Parameterizable via `BUBBLES_MCP_SERVER_PATH` to run the same suite against any
vendored copy.

### Evidence (2026-06-11)

Fixed canonical server — 7/7 pass:

```
server under test: bubbles/mcp/server.py
test_newline_framed_handshake_lists_ten_tools ... ok
test_blank_lines_between_messages_skipped ... ok
test_content_length_backcompat ... ok
test_eof_returns_none ... ok
test_newline_delimited_object_parses ... ok
test_write_read_roundtrip ... ok
test_writes_newline_terminated_json_without_header ... ok
----------------------------------------------------------------------
Ran 7 tests in 0.100s
OK
```

Newline-framed handshake (canonical AND a downstream `~/<repo>/.github/bubbles/mcp/server.py`):

```
initialize.protocolVersion = 2024-11-05
initialize.serverInfo = {"name": "bubbles", "version": "7.7.0"}
tools/list count = 10
tools/list names = ['check_gate', 'list_open_findings', 'query_tool_log', 'read_spec', 'record_evidence', 'resolve_mode', 'route_finding', 'search_code', 'validate_dod', 'verify_status_transition']
MATCHES_EXPECTED_10 = True
```

Existing framework selftest stays green:

```
$ bash bubbles/scripts/mcp-server-selftest.sh
PASS: T1 .. T19 (all)
mcp-server-selftest passed: MCP server boots, dispatches, and surfaces verbatim script output.
MCP_SELFTEST_EXIT=0
```

All 6 `server.py` copies byte-identical after the fix (single sha256
`ee8358600ccc385ef8e59ec0b7cf3342d4b85e8bc892bbf93880ef642a60f7b0`).

### Scope / DoD

- [x] `read_message` newline-primary + Content-Length fallback (canonical)
- [x] `write_message` newline-delimited, no header (canonical)
- [x] docstring + framing comment block corrected (canonical)
- [x] identical code fix propagated to all 5 vendored copies (byte-identical)
- [x] `mcp-server-selftest.sh` `read_frame()` updated; T1–T19 green
- [x] adversarial regression test added; passes fixed, fails pre-fix (3 FAIL + 1 ERROR)
- [x] newline handshake verified on canonical + a downstream copy (10 tools each)

### Vendored-Copy Integrity Guard

Editing the vendored `server.py` in each product repo changes its sha256, which
diverges from the value recorded in that repo's `.github/bubbles/.checksums` and
`.github/bubbles/release-manifest.json` (`bubbles/mcp/server.py` was `bf8ee84…`,
now `ee835860…`). This is detected by `framework-write-guard` / `cli.sh doctor`.
Per Bubbles policy the resolution is NOT to repair the checksum locally but to
land the fix upstream and re-vendor (`/bubbles.setup` / `install.sh`), which
copies the fixed file AND regenerates the snapshot. No guard was disabled,
bypassed, or `--skip`-ed.

### Acceptance

- VS Code "Configure Tools" populates the `bubbles-<repo>` MCP tool list.
- `python3 tests/test_mcp_stdio_framing.py` passes (7/7) against the fixed
  server and fails against the pre-fix server.
- `bash bubbles/scripts/mcp-server-selftest.sh` exits 0 (T1–T19).
- A newline-framed handshake against any of the 6 copies returns the 10 tools.

### Cross-References

- Design surface: `docs/v6-mcp-design.md`, `docs/MCP.md`.
- Regression: `tests/test_mcp_stdio_framing.py`.
- Adjacent selftest: `bubbles/scripts/mcp-server-selftest.sh` (T1–T19).
- Vendored copies (re-sync via `/bubbles.setup`): all 5 downstream installs — each at `.github/bubbles/mcp/server.py`.

---

## BUG-003 — runSubagent dispatch fails with Anthropic 400 — thinking blocks in the latest assistant message are mutated during sub-agent payload construction (extended-thinking + tool-use)

- **Filed:** 2026-06-11
- **Disposition:** external/upstream — NOT a Bubbles framework defect and not fixable in this repo; workaround documented; upstream fix recommended to `microsoft/vscode-copilot-chat` (filing pending a one-time SAML PAT authorization). Per Gate G095 this entry is a tracked EXTERNAL dependency, not an open framework defect.
- **Discovered by:** operator report during a `bubbles.goal` orchestrator session (4 consecutive dispatch failures in one turn)
- **Severity:** high for orchestrator/delegation modes (`bubbles.goal`, `bubbles.workflow`, `bubbles.sprint`) — these perform all implementation via `runSubagent`, so a failed dispatch halts progress for the rest of that turn. No impact on non-orchestrator agents.
- **Affects:** the VS Code Copilot Chat agent runtime's `runSubagent` dispatch payload serializer (`microsoft/vscode-copilot-chat`). NOT any file in this repo. The Bubbles agent definitions are correct.

> **Artifact convention:** the Bubbles source repo cannot keep `specs/` (Gate
> G085 dogfood guard), so this single entry is the full bug artifact. Because
> the defect is UPSTREAM (in the VS Code Copilot Chat agent runtime, not in this
> repo), the entry documents reproduction + root cause + recommended upstream fix
> + confirmed workaround IN LIEU OF an in-repo fix. No code changed in this repo
> for this bug, and none can — there is nothing here to fix.

### Reproduction

Extended-thinking model with interleaved thinking enabled; a long parent turn
with many tool calls and accumulated thinking blocks, including at least one
large (greater than ~8 KB) tool result that triggers the runtime's "large tool
result written to file" content-substitution rewrite; then a `runSubagent`
call. The dispatch fails with an Anthropic `400 invalid_request_error` at
`messages.N.content.M` where that block is a `thinking` / `redacted_thinking`
block (observed locus: `messages.1.content.4` — message index 1, content block
index 4).

### Root Cause (hypothesis)

The sub-agent dispatch harness rebuilds the outbound message array and mutates a
prior assistant message's `thinking` / `redacted_thinking` blocks
(re-serialization, whitespace/key-order normalization, content-block
re-ordering, signature drop, or splicing injected content such as the
large-result-to-file pointer or reminder text) instead of forwarding them
verbatim. Anthropic requires `thinking` blocks on extended-thinking + tool-use
round-trips to be returned byte-for-byte unchanged INCLUDING the signature and
in their original position relative to the `tool_use` block; any change yields a
400.

Tell-tale: a clean stateless sub-agent payload is `[system, user(dispatch
prompt)]` — content index 4 of message 1 (a user message) is never a thinking
block, so a thinking block there is direct evidence the harness is replaying a
parent assistant turn into the sub-agent request and then mutating it.

### Recommended Upstream Fix

Priority order:

1. **Start sub-agents with a clean message history** — build the payload from
   system prompt + dispatch prompt only; do not replay parent thinking-bearing
   assistant turns. If parent context is needed, forward a plain-text summary as
   user content, never replayed assistant thinking blocks. (Primary fix;
   directly explains the `messages.1.content.4` tell.)
2. **(Reframed) Preserve `thinking` / `redacted_thinking` blocks verbatim** —
   applies to the PARENT turn-continuation after the sub-agent returns (text +
   signature, original position). For sub-agent dispatch itself, fix 1
   supersedes (do not forward them at all).
3. **Decouple harness content-substitution from thinking blocks** — the
   large-tool-result-to-file rewrite and reminder injection must touch user-role
   messages ONLY (`tool_result` blocks live in user-role messages and carry no
   signature). Pass assistant messages through verbatim; if an assistant message
   must be edited, strip its thinking blocks entirely and consistently, never
   partially. (Primary fix for the parent-continuation manifestation.)
4. **Fail soft** — detect the modified-thinking-block condition pre-flight (or
   on the 400) and retry once with a thinking-stripped history instead of
   surfacing a raw 400; self-verify by diffing outbound thinking bytes against
   what the model originally returned. (Safety net.)

### Confirmed Workaround

A fresh user turn clears it — the mutated in-turn assistant message is no longer
the latest, so the next turn's dispatch succeeds; no data lost. Operationally
for orchestrator modes: dispatch sub-agents earlier in a turn (before
accumulating many large tool results + thinking blocks) to reduce trigger
probability.

### Triage Note

An earlier note linked the failure to a source file in a downstream product
(an internal agent file that was merely open in the editor at failure time).
That was a RED HERRING — that file uses a plain `Role`+`Content` string message
model over a Python sidecar and cannot emit Anthropic content-block errors.
Route the upstream issue to the sub-agent request serialization path in
`microsoft/vscode-copilot-chat`, NOT to any downstream product or the framework.

---

## BUG-004 — agnosticity-lint flags the installer's own per-repo MCP-id substitution (bubbles-<repo>) downstream; hardcoded project-name list also omits unlisted products

- **Filed:** 2026-06-12
- **Disposition:** fixed (working tree; not committed) — `agnosticity-lint.sh` now derives the repo's own project slug instead of a hardcoded name list, and exempts the installer's `bubbles-<slug>` MCP-id token on agent `tools:` lines; an adversarial selftest case was added. Per Gate G095 this is a resolved discovered-issue. See "The Fix (landed)" below.
- **Discovered by:** a downstream framework upgrade (7.7.0 → 7.11.2) where `bubbles doctor` reported 15 passed / 1 failed in a downstream repo whose project name was on the hardcoded list, while the byte-identical upgrade in another downstream repo (not on the list) reported 16 passed / 0 failed.
- **Severity:** medium — makes `bubbles doctor` report a Framework Integrity failure ("Portable Bubbles surfaces contain project/tool drift") in every downstream repo whose project name is on the hardcoded list. It is **advisory**: it does NOT block the consumer repo's own pre-push, because Bubbles-managed pre-commit/pre-push hooks are installed in the Bubbles SOURCE repo only — consumer repos run their own product pre-push, which does not invoke `bubbles agnosticity-lint` against installed files. But it makes `doctor` permanently red and erodes trust in the check.
- **Affects:** `bubbles/scripts/agnosticity-lint.sh` (the `PROJECT_NAME` rule, around line 157 in canonical) as consumed by `cli.sh doctor` against downstream-installed agent files. Also implicates `bubbles/agnosticity-allowlist.txt` (framework-managed) and the installer's MCP-id substitution in `install.sh`.

> **Artifact convention:** the Bubbles source repo cannot keep `specs/` (Gate
> G085 dogfood guard), so this single entry is the full bug artifact —
> reproduction + proven root cause + the fix that landed.

### Reproduction

1. Install/upgrade Bubbles into a downstream repo whose project name was one of
   the hardcoded names in the old `PROJECT_NAME` list — e.g.
   `bash .github/bubbles/scripts/cli.sh upgrade --local-source <bubbles>`.
2. The installer substitutes the per-repo MCP server id into the `tools:` line
   (line 3) of the 5 restricted-orchestrator agents (`bubbles.bug`,
   `bubbles.goal`, `bubbles.iterate`, `bubbles.sprint`, `bubbles.workflow`):
   canonical `tools: [..., bubbles, ...]` becomes
   `tools: [..., bubbles-<slug>, ...]`.
3. `bubbles doctor` (or `agnosticity-lint` run on the INSTALLED files) reports
   `❌ [PROJECT_NAME] agents/bubbles.goal.agent.md:3` for each of the 5 agents,
   then `❌ Portable Bubbles surfaces contain project/tool drift`, giving
   `doctor` a "1 failed" result.

### Root Cause (proven)

- `agnosticity-lint.sh` built its `PROJECT_NAME` detector from a HARDCODED list
  of specific downstream product names (~L157), written with intra-string
  concatenation so the lint script itself did not contain its own banned token:

  ```bash
  grep_project_name="$(printf '%s|' "<product-a>" "<product-b>" "<product-c>")"
  grep_project_name="${grep_project_name%|}"
  ```

- The case-insensitive bounded grep (~L165) then matched a hardcoded product
  name *inside* the installer-substituted token `bubbles-<slug>`
  on the `tools:` line and raised a `PROJECT_NAME` violation:

  ```bash
  grep -niE "(^|[^[:alnum:]_])(${grep_project_name})([^[:alnum:]_]|$)" ...
  ```

  The leading boundary `(^|[^[:alnum:]_])` is satisfied by the `-` in
  `bubbles-<slug>` (a hyphen is not alphanumeric/underscore), and the trailing
  boundary is satisfied by the following `,`/`]`/space — so the embedded project
  name matched.
- The substitution is LEGITIMATE: `install.sh` deliberately rewrites the MCP
  server id to a unique per-repo id (`bubbles-<slug>`) so each repo's
  `.vscode/mcp.json` server is uniquely addressable. The lint has no exemption
  for this installer-owned token, so it flags the framework's own output.

### Why It Was Asymmetric (an unlisted repo passed)

- A downstream repo NOT on the hardcoded list never had its `bubbles-<slug>`
  token matched, so its `doctor` reported 16 / 0 / 0.
- That repo passed by ACCIDENT — and this is itself a coverage hole: a genuine
  project-name leak from an unlisted product into a portable surface would NOT
  be caught.
- So the same bug both (a) false-positived on listed repos and (b) under-checked
  unlisted repos.

### Expected Behavior

- `agnosticity-lint`, when checking downstream-installed agent files, MUST NOT
  flag the installer's own per-repo MCP-id substitution token (`bubbles-<slug>`)
  as project drift. The `PROJECT_NAME` rule should target genuine project-name
  leaks in portable surfaces, not the framework's deliberate per-repo id.
- The check should not depend on a hand-maintained, per-product hardcoded name
  list (which is guaranteed to drift — it already omitted at least one product).

### The Fix (landed)

1. **Exempt the per-repo MCP-id token on `tools:` lines.** When linting
   installed files, derive the repo's own MCP id (from `.vscode/mcp.json` or
   `.github/bubbles-project.yaml`) and skip that exact `bubbles-<slug>` token,
   OR generically treat a `bubbles-<slug>` token on an agent `tools:` array as
   an installer substitution and exempt it. This removes the false positive for
   every downstream repo without weakening real drift detection.
2. **Replace the hardcoded project-name list with a derived value** (the repo's
   own project name/slug) so the check is correct for ANY project and cannot
   omit one (closes the unlisted-product under-checking hole).
3. **Do NOT fix this by adding an entry to `bubbles/agnosticity-allowlist.txt`
   downstream** — that file is framework-managed (listed in
   `release-manifest.json`, overwritten on every upgrade), so a per-repo
   allowlist entry would be wiped on the next upgrade. The fix belongs in
   canonical `agnosticity-lint.sh` + its selftest
   (`agnosticity-lint-selftest.sh`).
4. **Any fix MUST update `agnosticity-lint-selftest.sh`** with an adversarial
   case proving (a) `bubbles-<slug>` on a `tools:` line is allowed, and (b) a
   genuine bare project-name leak in prose/comments is still flagged — so the
   exemption cannot become a hole.

### Workaround

Not needed — the fix has landed. Before the fix, the failure was an advisory
`doctor` result (not a push gate) and the substitution was correct, so operators
could safely ignore the single `doctor` `PROJECT_NAME` failure on the 5
restricted-orchestrator agents.

### Scope Note

The fix (agnosticity-lint slug derivation + `bubbles-<slug>` exemption +
adversarial selftest) landed in the working tree as part of the v7.12.0
PII/agnosticity hardening, alongside scrubbing real downstream product names out
of the framework's docs and test fixtures. Pre-existing: the substituted token
was identical at 7.7.0, so the 7.11.2 upgrade did not introduce this; it merely
made it visible during a `doctor` run.

---

## BUG-005 — state-transition-guard.sh Check 11 is O(forks): ~126s on a large report.md (downstream sweeps appear to "hang")

- **Filed:** 2026-06-14
- **Disposition:** fixed (working tree; not committed) — Check 11's per-line/per-block `echo|grep` fork-storm converted to zero-fork bash builtins; the 8 per-block signal greps collapsed into per-line DISTINCT-category flag accumulation (verdict byte-identical: block legit iff ≥3 lines AND ≥2 distinct categories); the sibling hot loops (Check 4A DoD-format, Check 9 evidence-marker, Check 12 duplicate-evidence) also de-forked; a perf+correctness regression was added to `state-transition-guard-perf-selftest.sh`; `release-manifest.json` regenerated (guard + perf-selftest checksums change). Canonical Bubbles source ONLY — downstream re-vendor of the 5 copies via the release manifest is a separate propagation follow-up. Per Gate G095 this is a resolved discovered-issue, distinct from BUG-001 (Check 3G / `agent-ownership-lint.sh`, which does not cover this inline loop). See "Fix Applied" below.
- **Discovered by:** `bubbles.goal` session driving knb deploy-test-drift remediation (downstream repo `knb`, spec-019 sweep test)
- **Severity:** medium — not a wrong result, but a ~2-minute wall-clock cost per large `report.md` that makes any downstream test/gate invoking the guard with no timeout look hung; CI/pre-push wall-clock inflation
- **Affects:** `bubbles/scripts/state-transition-guard.sh` **Check 11** (Report.md required sections / evidence-block legitimacy), the inline `while IFS= read -r line` loop (canonical ~L2069). Every downstream repo that vendors the guard inherits it (confirmed in `knb`).

### Symptom

A downstream knb test (`tests/deploy/spec_019_sweep_test.sh`, G2 SWEEP-GOVERNANCE) invokes `state-transition-guard.sh specs/019-...` with **no timeout** and captures its output. Against `specs/019-.../report.md` (4888 lines) the guard takes:

```
$ /usr/bin/time -v timeout 200 bash bubbles/scripts/state-transition-guard.sh specs/019-zero-manual-deploy-orchestrator
        Elapsed (wall clock) time (h:mm:ss or m:ss): 2:06.13
  exit: 1
```

2:06 wall clock — long enough that an un-timed caller (the sweep test) reads as a hang. The guard *does* finish and returns a correct verdict (exit 1: the spec is legitimately `blocked`); it is purely a performance defect, not a correctness one.

### Root Cause

Check 11's evidence-block-legitimacy loop forks a subshell **per line** and **8× per closed code block** via the `echo "$var" | grep` anti-pattern:

```bash
while IFS= read -r line; do
  if [[ "$in_block" -eq 0 ]] && echo "$line" | grep -qE '^```'; then      # fork/line
    ...
  elif [[ "$in_block" -eq 1 ]] && echo "$line" | grep -qE '^```$'; then   # fork/line
    ...
    echo "$block_content" | grep -qiE '(passed|failed|ok$|...)' && ...     # 8 forks
    echo "$block_content" | grep -qiE '(exit code|...)'          && ...     #   per
    ... (8 signal greps total) ...                                          #  block
  fi
done < "$report_path"
```

On a 4888-line file that is ~9.8k `echo|grep` forks for the per-line fence test alone, plus 8 more per block. `grep -cE 'echo "\$(line|block_content)" \| grep'` counts **23** such calls in hot per-line/per-block loops; **48** `echo "$x" | grep` anti-patterns exist in the script overall.

BUG-001 shipped `bubbles_run_with_timeout` around heavy **sub-script** invocations (artifact-lint, freshness-guard, reality-scan), but Check 11 is an **inline bash loop**, so it is not wrapped — the fail-safe timeout does not apply here.

### Recommended Fix (not yet implemented)

1. Replace every per-line/per-block `echo "$x" | grep -qE 'pat'` with a **bash builtin** `[[ "$x" =~ pat ]]` (zero fork). Fence detection becomes `[[ "$line" == '```'* ]]`.
2. Collapse the 8 per-block signal greps into a single pass — e.g. accumulate `block_content` and run one `grep -cE '(alt1|alt2|...)'`, or evaluate the 8 alternations with bash regex against the accumulated string — so a block costs O(1) forks (ideally zero) instead of 8.
3. Apply the same builtin conversion to the other hot loops flagged by `grep -nE 'echo "\$(line|...)" \| grep'` (canonical ~L849 DoD scan, ~L1752, ~L1928 evidence-link scan).
4. Re-propagate the canonical fix into the 5 vendored downstream copies via `release-manifest.json` (the guard is framework-managed downstream; `downstream-framework-write-guard.sh` rejects per-repo edits, so the fix MUST land canonical).
5. Add a perf regression guard: a selftest fixture with a synthetic ~5000-line `report.md` asserting the guard completes well under a budget (e.g. < 10s), so the fork-storm cannot regress.

### Reproduction

```
# In any repo with the vendored guard and a large report.md:
/usr/bin/time -v bash .github/bubbles/scripts/state-transition-guard.sh \
  specs/<feature-with-4000+line-report>/   # ~2 min wall clock; dominated by Check 11
```

### Downstream Impact / Workaround

- `knb` `tests/deploy/spec_019_sweep_test.sh` invokes the guard untimed and so appears to hang for ~2 min before the guard's (correct) exit 1 surfaces. That sweep also fails on the merits (spec-019 is `blocked`), so the perf defect is not what's blocking knb — but it masks the real signal behind a 2-minute stall.
- Downstream workaround until the canonical fix lands: wrap the guard call in `timeout` in the consuming test/gate so a slow run fails fast with a named timeout rather than appearing to hang. This is a band-aid; the real fix is the builtin conversion above.

### Fix Applied (2026-06-14)

All four hot loops in `bubbles/scripts/state-transition-guard.sh` were converted from per-line/per-block `echo "$x" | grep -qE` subshell forks to zero-fork bash builtins:

1. **Check 11 (evidence-block legitimacy — the hot path):** fence detection is now `[[ "$line" == '```'* ]]` (open) / `[[ "$line" == '```' ]]` (close). The 8 per-block signal greps are collapsed into **8 per-line category flags** OR'd as each in-block line streams by; at block close `signals` is the sum of the 8 flags and the unchanged `signals < 2` rule applies. The verdict is **byte-identical** — distinct-CATEGORY counting (threshold ≥2), NOT matching-line counting. Case-insensitive categories (i/ii/iv/v/vii — original `grep -qiE`) run under `shopt -s nocasematch`; case-sensitive categories (iii/vi/viii — original `grep -qE`) run with it off. Per-line testing also preserves grep's line-oriented `^`/`$` anchors. The now-unused `block_content` accumulator (an O(n²) string concat) was removed.
2. **Check 4A** (DoD format manipulation), **Check 9** (per-`[x]` evidence-marker scan), and **Check 12** (duplicate-evidence fence detection) had their per-line boolean `echo|grep` tests converted to `[[ =~ ]]` / glob builtins. `grep -oE | sed` EXTRACTION pipelines (which run at most once per matched line) were intentionally left as-is.

A new BUG-005 section in `state-transition-guard-perf-selftest.sh` builds a synthetic ~5000-line `report.md` (≈1000 legitimate filler blocks + one exactly-2-category legit block + one single-category-repeated illegitimate block) and runs the real guard with `BUBBLES_STATE_TRANSITION_GUARD_SELFTEST_FAST=1`. It asserts the guard completes well under budget AND that exactly one illegitimate block is detected (proving the distinct-category semantics survived — a regression to line-counting would pass the repeated-single-category block and fail this assert):

```
  PASS: guard over 6036-line report.md completes in 3s (< 30s; fork-storm was ~126s)
  PASS: Check 11 distinct-category semantics preserved (exactly 1 illegitimate block detected)

[state-transition-guard-perf-selftest] 7 passed, 0 failed
[state-transition-guard-perf-selftest] OK
```

The existing `state-transition-guard-selftest.sh` stays green (≈50 assertions; verdict semantics unchanged), and `release-manifest.json` was regenerated so the guard + perf-selftest checksum changes are recorded. Shipped as v7.12.1.

---

## BUG-006 — state-transition-guard Check 4B (G041) flags a header summary blockquote `> **Status:** …` as a non-canonical scope status

- **Filed:** 2026-06-17
- **Disposition:** fixed (working tree; not committed) — Check 4B (canonicality) and Check 5 (per-scope status counting) now exclude `^>`-prefixed blockquote lines, so a header/summary rollup is never read as a scope status. An adversarial selftest pair was added to `state-transition-guard-selftest.sh`: (a) a fixture with a `> **Status:** all scopes Not Started (planning refreshed …)` header blockquote still passes; (b) a plain `**Status:** Deferred` scope line is STILL flagged non-canonical (no over-exclusion). Selftest green (50+ assertions), perf-selftest green (2s), shellcheck clean. Canonical source only; re-vendors downstream via `release-manifest.json`. Per Gate G095 this is a resolved discovered-issue.
- **Discovered by:** session review of QuantitativeFinance planning-refresh work (2026-06-17) — a `scopes.md` whose top-of-file rollup blockquote read `> **Status:** all scopes Not Started (planning refreshed …)` tripped Check 4B.
- **Severity:** low-medium — no incorrect PASS, but it forces agents to **reword legitimate human-readable summary blockquotes** to satisfy a guard that should ignore them. That inversion (artifact bent to fit the regex) is the exact anti-pattern the framework warns against, and it erodes trust in the guard.
- **Affects:** `bubbles/scripts/state-transition-guard.sh` **Check 4B** (Scope Status Canonicality — Gate G041), canonical ~L900–945. Vendored byte-identical into all 5 downstream repos.

> **Artifact convention:** the Bubbles source repo cannot keep `specs/` (Gate
> G085 dogfood guard), so this entry is the full bug artifact — reproduction +
> proven root cause + expected-behavior spec + scoped fix.

### Reproduction

A `scopes.md` (or `scopes/_index.md`) that carries a top-of-file summary blockquote, e.g.:

```markdown
> **Status:** all scopes Not Started (planning refreshed 2026-06-17)

## Scope 1: …
**Status:** Not Started
```

Run `state-transition-guard.sh specs/<feature>`. Check 4B fails:

```
--- Check 4B: Scope Status Canonicality (Gate G041) ---
❌ Non-canonical scope status detected in scopes.md: 'all scopes Not Started (planning refreshed 2026-06-17)' …
```

### Root Cause (proven)

Check 4B enumerates status lines with an UNANCHORED grep:

```bash
done < <(grep -E '\*\*Status:\*\*' "$scope_path" || true)
```

That matches ANY line containing `**Status:**`, including a Markdown blockquote
(`>`-prefixed) rollup in the header preamble. The value `all scopes Not Started
(planning refreshed …)` strips its parenthetical to base `all scopes Not Started`,
which is not one of the four canonical values (`Not Started` / `In Progress` /
`Done` / `Blocked`) → FAIL. A canonical scope status is a **plain** `**Status:**
<value>` line under a `## Scope N:` heading, never a `>`-quoted summary.

### Expected Behavior

Check 4B validates only genuine per-scope status declarations. A `>`-prefixed
blockquote `**Status:**` line is a human-readable summary/annotation and MUST NOT
be treated as a scope status value.

### Scoped Fix

1. In Check 4B, skip blockquote lines — filter out `^[[:space:]]*>` before the
   canonicality test (e.g. `grep -E '\*\*Status:\*\*' | grep -vE '^[[:space:]]*>'`).
2. **Safety (no bypass):** confirm the completion-reading path (Gate G024
   all-scopes-Done, and any scope-status enumeration that decides Done-ness) also
   ignores blockquote `**Status:**` lines, so a fake `> **Status:** Done` cannot
   smuggle a scope to Done. Align if needed.
3. `state-transition-guard-selftest.sh` gains an adversarial pair: (a) a header
   `> **Status:** all scopes Not Started (planning refreshed)` blockquote no
   longer fails Check 4B; (b) a plain `**Status:** Deferred` scope line is STILL
   flagged non-canonical.
4. Canonical source only; re-vendors downstream via `release-manifest.json`.

---

## BUG-007 — state-transition-guard Check 8C (Shared-Infra Blast-Radius) trigger over-matches benign prose (`session` + `flow`)

- **Filed:** 2026-06-17
- **Disposition:** fixed (working tree; not committed) — the Check 8C trigger's middle-alternation second arm was tightened from `(fixture|fixtures|harness|setup|bootstrap|contract|flow)` to `(fixture|fixtures|harness|bootstrap)`, so a real test-infrastructure noun must co-occur with the infra subject; the `shared|global|common|core` qualifier arm and the specific multi-word-phrase arm (which signal GENUINE shared infra) are unchanged. An adversarial selftest was added: a benign "regression session re-runs the booking user flow" note no longer trips 8C, while the existing genuine shared-fixture positive/negative fixtures STILL trigger it. Selftest green, shellcheck clean. Canonical source only; re-vendors downstream via `release-manifest.json`. Per Gate G095 this is a resolved discovered-issue.
- **Discovered by:** session review of QuantitativeFinance planning work (2026-06-17) — a scope whose Test Plan row described a "regression session" exercising a user "flow" tripped Check 8C's shared-infrastructure trigger, demanding an inapplicable Shared Infrastructure Impact Sweep.
- **Severity:** low-medium — over-broad trigger forces agents to either add an **inapplicable** Shared Infrastructure Impact Sweep (+ canary DoD item + rollback DoD item + canary Test Plan row + downstream-contract enumeration) or **reword legitimate prose** to dodge the keywords. False gating + artifact churn.
- **Affects:** `bubbles/scripts/guards/planning-checks.sh` **Check 8C** (Shared Infrastructure Blast-Radius Planning), canonical ~L129–180; sourced by `state-transition-guard.sh`. Vendored into all 5 downstream repos.

### Reproduction

A scope whose prose / Test Plan contains a benign co-occurrence of a trigger noun
(`session`, `auth`, `login`, `token`, `role`, `context`) and a generic second-arm
word (`flow`, `contract`), e.g. a Test Plan row:

```markdown
| Regression E2E | e2e | … | Regression session re-runs the booking user flow end to end | … |
```

Run the guard. Check 8C fires:

```
--- Check 8C: Shared Infrastructure Blast-Radius Planning ---
❌ Scope touches shared fixture/bootstrap infrastructure but has no Shared Infrastructure Impact Sweep section: Scope N
❌ … missing the canary DoD item …
❌ … missing the rollback/restore DoD item …
```

### Root Cause (proven)

The Check 8C trigger alternation includes generic single words that appear
constantly in ordinary test prose:

```bash
if grep -Eiq '… \b(auth|login|session|password reset|token refresh|tenant context|role detection|storage injection|init script|addinitscript)\b.*\b(fixture|fixtures|harness|setup|bootstrap|contract|flow)\b …' "$scope_path"; then
```

`session … flow` (or `… contract`) on a single line satisfies it. The trigger is
meant to fire on genuine SHARED test-infrastructure changes (global Playwright
setup, auth-fixture bootstrap, `storageState` / `addInitScript` injection), not
any sentence that mentions a session and a flow.

### Expected Behavior

Check 8C fires only when a scope genuinely modifies SHARED fixture / bootstrap /
global-setup infrastructure — not when benign prose co-mentions trigger keywords.

### Scoped Fix

1. Tighten the trigger so a match requires a **shared-scope qualifier**
   (`shared` / `global` / `common` / `core` / `global setup` / `playwright setup`
   / `storageState` / `addInitScript` / `auth fixture` / `login fixture` /
   `bootstrap helper`) **co-occurring with** an infrastructure noun. Drop the bare
   `flow` / `contract` second-arm words and the standalone `session`/`role`/`context`
   arms that over-match generic prose.
2. `state-transition-guard-selftest.sh` (which already exercises a positive Check
   8C fixture at ~L1033) gains an adversarial pair: (a) a benign "regression
   session re-runs the booking user flow" Test Plan row no longer trips 8C;
   (b) a real "modifies the shared Playwright global-setup auth fixture" scope
   STILL requires the Impact Sweep + canary + rollback items.
3. Canonical source only; re-vendors downstream via `release-manifest.json`.

### Relationship to BUG-006 / IMP-009

BUG-006 and BUG-007 are two instances of the same class: a guard trigger/scan
that matches ordinary artifact wording and forces the agent to bend the artifact
to the regex. `improvements/IMP-009` proposes the systemic hardening (structural
matching + a meta-selftest that proves guards do not flag their own fixtures);
these two bugs are the concrete fixes that land first.
