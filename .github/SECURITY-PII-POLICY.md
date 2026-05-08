# PII & Secret Prevention Policy

> **Status:** Authoritative.
> **Scope:** Every commit, every branch, every contributor.
> **Enforcement:** automated (`gitleaks` pre-commit hook + CI scan).
> **Bypass:** `SKIP_PII_SCAN=1` — emergency only, MUST be justified in commit message.

---

## What this policy prevents

| Category | Examples (placeholders only) | Why it's blocked |
|---|---|---|
| Personal email on public providers | `<user>@gmail.com`, `<user>@yahoo.com` | Personal identity leak |
| Corporate email on major employer domains | `<user>@<bigtech>.com` | Employment / identity leak |
| Tailscale CGNAT IPs | `100.64.0.0/10` range | Network topology leak |
| Tailscale machine handles | `tail######` form | Device identity leak |
| Date-shaped values 1900-2010 | `YYYYMMDD` matching DOB range | Birthday / DOB leak |
| Inline credentials in URLs | `proto://user:<password>@host` | Credential leak |
| Private key blocks | `-----BEGIN ... PRIVATE KEY-----` | Cryptographic key leak |
| Absolute Linux home paths | `/home/<username>/...` | Local user identity leak |
| Shell prompts | `<user>@<HOSTNAME>` | Local user + machine name leak |

The exact regex patterns live in [`.gitleaks.toml`](../.gitleaks.toml). All
patterns describe **categories**, never specific values — this file and the
rule file MUST stay free of real PII tokens at all times.

---

## What you MUST do

### 1. Use placeholders, env vars, or templates for any sensitive value

| Forbidden (concrete) | Required (generic) |
|---|---|
| Real personal email | `<your-email>`, `noreply@example.test`, `user@example.test` |
| Real device hostname | `<YOUR-DEVICE>`, `${HOSTNAME}`, `localhost` |
| Real Tailscale IP | `<YOUR-TAILNET-IP>`, `100.x.y.z` (with `# placeholder` comment) |
| Real local path | `~/<project>/...`, `${HOME}/<project>/...`, `<repo-root>/...` |
| Real password in URL | `${DB_PASSWORD}`, `<password>`, `{{db_password}}` |
| Real private key | Reference the secret manager path; never inline the key |

### 2. Configure a machine-local token list (recommended)

Owner-specific identifiers (your real first name, your real laptop hostname,
etc.) cannot be encoded in a generic regex without leaking the value into
the rule file itself. Instead, list them in a machine-local file that never
leaves your machine:

```bash
mkdir -p ~/.config/bubbles
chmod 700 ~/.config/bubbles
# Create the token list (one literal token per line; comments with # OK):
${EDITOR:-vi} ~/.config/bubbles/pii-tokens.txt
chmod 600 ~/.config/bubbles/pii-tokens.txt
```

Suggested categories to include (use YOUR actual values, locally only):

- Your real first name and last name
- Your real laptop / workstation hostname (full and short forms)
- Your real personal email address(es)
- Your real Tailscale device IP(s) and machine handle(s)
- Your date of birth in any format you commonly type
- Any other personal identifier you've previously typed accidentally

The `pii-scan.sh` hook reads this file, strips comments and blank lines,
and case-insensitively greps your staged diff for any of those literal
strings. If a match is found, the commit is blocked.

> **The token list is on YOUR machine only.** It is not committed, not
> synced, not transmitted. Override its location with `$BUBBLES_PII_TOKENS`
> if you want to keep it elsewhere (e.g. a shared encrypted vault).

### 3. Run a sanity check before pushing

```bash
gitleaks detect --config .gitleaks.toml --no-banner --redact
```

If any new finding appears, fix it before pushing.

---

## What happens if you commit a leak

1. **Pre-commit hook blocks the commit.** You see the finding (redacted),
   the file, and the line. Fix the value, restage, retry.
2. **CI scan blocks the PR.** The same scan runs in GitHub Actions on every
   PR; merging is blocked until the finding is fixed or baselined.
3. **GitHub Push Protection blocks the push** for known secret patterns
   (API keys, tokens) at the protocol level — even before CI runs.

If a leak DID land in history, recovery is expensive: history rewrite,
force-push, every collaborator re-clones, and the leaked secret MUST be
rotated. Prevention is cheap; remediation is not.

---

## Allowlists & baselines

### Inline (single line)

Append `# gitleaks:allow` to a line that is a known false positive:

```python
example_url = "https://user:fakepassword@example.com"  # gitleaks:allow
```

### Repo-wide (single fingerprint)

If a finding is verified safe and the line cannot reasonably be edited
(e.g. binary doc, generated artifact, immutable historical artifact),
add the gitleaks fingerprint to `.gitleaksignore`:

```
<commit>:<file>:<rule-id>:<line>
```

Each baseline addition MUST be reviewed: explain WHY the value is safe in
the PR description. The `.gitleaksignore` file is NOT a dumping ground —
prefer fixing the value over baselining it.

### Path-wide (a directory or glob)

Edit `.gitleaks.toml` and add a `paths = [ ... ]` entry under one of the
global `[[allowlists]]` blocks. Use this only for test fixtures, generated
content directories, and documentation that catalogs forbidden patterns.

---

## Bypass (emergency only)

```bash
SKIP_PII_SCAN=1 git commit -m "emergency: <reason>"
```

The bypass:

- Is logged in the commit message (the agent reading later will see `SKIP_PII_SCAN=1` is needed)
- Does NOT bypass CI — your push will still be scanned remotely
- MUST be followed by a corrective commit if the bypass introduced a leak

**Do not use bypass to "save time."** If the hook is blocking you, the
fastest path is almost always to fix the value, not to bypass.

---

## What this policy does NOT prevent

- **Side-channel leaks** outside committed text (browser screenshots in
  a PR comment, terminal output pasted into an issue, log uploads).
  Use the same placeholder discipline in those surfaces.
- **History from before this policy existed.** Existing findings are
  baselined in `.gitleaksignore` (audited per entry). Force-pushing to
  rewrite history is a separate, manual remediation.
- **Compromised dev machine.** If your laptop is stolen, the
  machine-local token file is one of many things at risk; rotate
  everything per your incident response plan.

---

## Rule philosophy

The rules in `.gitleaks.toml` describe **categories of forbidden content**,
never specific values. This is non-negotiable:

- A rule that contains your real hostname IS a leak of your real hostname.
- A rule that contains your real email IS a leak of your real email.
- A rule MUST be portable across machines, contributors, and forks.

Owner-specific values are caught by the machine-local token list, which
lives outside any repo.

---

## Updating the policy

Changes to `.gitleaks.toml`, `.gitleaksignore`, or this document MUST:

1. Add or remove only **patterns** and **path allowlists** — never specific
   values.
2. Be reviewed in PR by at least one other contributor.
3. Trigger a full repo re-scan before merge to confirm no new findings
   appear.

If a new category of PII becomes relevant, add a generic rule, document it
in the table at the top of this file, and run the full scan to baseline
any pre-existing matches.
