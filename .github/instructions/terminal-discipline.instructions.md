---
applyTo: "**"
---

# Terminal Discipline Policy (NON-NEGOTIABLE)

> **Scope:** This is the **Bubbles framework SOURCE repository**. It hosts no
> product runtime — the maintainer command surface is
> [`bubbles/scripts/cli.sh`](../../bubbles/scripts/cli.sh) and the selftest /
> guard suite under [`bubbles/scripts/`](../../bubbles/scripts). The rules below
> mirror the project-agnostic terminal-discipline family shipped to downstream
> consumer repos, adapted to the source repo's `cli.sh` surface.

## 1. No Piping/Redirecting Output Into Files (ABSOLUTE)

**FORBIDDEN:** Using shell pipes or redirects to write files.

```bash
# ❌ FORBIDDEN — piping/redirecting into files
echo "content" > path/to/file.md
cat source.txt > dest.txt
command | tee output.log
command > output.txt 2>&1
sed 's/old/new/' file > file.tmp && mv file.tmp file
printf "data" >> append.txt
some_command | python3 -c '...' > result.json
heredoc > script.sh <<'EOF' ... EOF
```

**REQUIRED:** Use the dedicated IDE file creation/editing tools (create_file,
replace_string_in_file, multi_replace_string_in_file, etc.) for ALL file writes.
These tools are atomic, auditable, and visible to the user.

**Exception:** File writes performed *internally* by repo scripts (generators
writing their generated targets, `generate-release-manifest.sh` writing
`bubbles/release-manifest.json`, selftests writing to their own `mktemp`
workspaces) are normal side effects of running those commands, not author-time
shell redirection in the working tree.

---

## 2. No Truncating Command Output (ABSOLUTE)

**FORBIDDEN:** Filtering, truncating, or limiting command output with pipes.

```bash
# ❌ FORBIDDEN — truncating output
command | head -20
command | tail -50
command | head -n 100
command | grep "pattern" | head
command | awk 'NR<=10'
command | sed -n '1,20p'
command 2>&1 | head
bash bubbles/scripts/cli.sh framework-validate 2>&1 | tail -30
```

**REQUIRED:** Always capture and display the FULL unfiltered output of every
command.

```bash
# ✅ REQUIRED — full output, no filters
bash bubbles/scripts/cli.sh framework-validate
bash bubbles/scripts/cli.sh doctor
bash bubbles/scripts/state-transition-guard.sh specs/<NNN-feature-name>

# ✅ OK — grep/search for READING existing files (not truncating command output)
grep -rn "TODO" bubbles/scripts/
grep -rnE 'G[0-9]{3}' bubbles/registry/gates.yaml
```

**Why:** Truncated output hides errors, warnings, and context critical for
debugging and evidence. The Bubbles Execution Evidence Standard requires ≥10
lines of raw terminal output — truncation risks hiding the lines that matter.

**Exception:** Using `grep` to SEARCH files (not to filter a command's
stdout/stderr) is allowed. The prohibition is on piping a command's output
through filters that discard lines.

---

## 3. Use `bash bubbles/scripts/cli.sh` — No Ad-Hoc Tool Invocation (ABSOLUTE)

The source repo validates framework behavior through the committed CLI, its
selftests, and its guards — not a product build/test toolchain. There is **no**
`./bubbles.sh` runtime CLI in this repo; do not invent one.

**FORBIDDEN:** Ad-hoc invocation of a build/test/deploy toolchain as the normal
maintainer workflow.

```bash
# ❌ FORBIDDEN — inventing a product CLI or bypassing the canonical surface
./bubbles.sh test                    # does NOT exist in the source repo
npm test                             # no product stack in this repo
cargo build                          # no product stack in this repo
docker compose up                    # no application stack in this repo
```

**REQUIRED:** Drive validation through `bash bubbles/scripts/cli.sh` and the
selftest/guard scripts it wraps.

```bash
# ✅ REQUIRED — canonical maintainer surface
bash bubbles/scripts/cli.sh framework-validate   # build + test all (selftests + guards)
bash bubbles/scripts/cli.sh release-check         # ship-readiness
bash bubbles/scripts/cli.sh agnosticity           # lint
bash bubbles/scripts/cli.sh doctor                # status
bash bubbles/scripts/cli.sh lint <spec>           # artifact lint
bash bubbles/scripts/cli.sh guard <spec>          # transition guard
```

**Why:** `cli.sh` is the single source of truth for the maintainer command
surface. Direct tool invocation bypasses the selftest wiring, the GNU/BSD PATH
shims, and the bash-baseline guard that keep validation reproducible.

**Exception:** Read-only inspection commands that don't build, test, or mutate
state are allowed: `ls`, `cat`, `find`, `grep`, `wc`; `git log`, `git diff`,
`git status`; `bash -n` / `shellcheck -x` on scripts; and individual
`bash bubbles/scripts/*selftest.sh` runs.

---

## 4. Never Echo Secret Values (ABSOLUTE)

**FORBIDDEN:** Printing the value of a secret-bearing variable — directly, or
accidentally via a shell-parameter-expansion default. Secrets include any
`*_TOKEN` / `*_KEY` / `*_PASSWORD` / `*_SECRET` and any credential that reaches
the shell.

```bash
# ❌ FORBIDDEN — prints the VALUE when the var is set
echo "$GITHUB_TOKEN"
echo "TOK=${GITHUB_TOKEN:-<unset>}"    # :- substitutes the VALUE when set!
echo "TOK=${GITHUB_TOKEN-<unset>}"     # same trap without the colon
set -x; use "$GITHUB_TOKEN"; set +x    # xtrace prints the value
printenv | grep -i token               # dumps token values
env                                    # dumps every secret value
```

**The expansion trap:** `${VAR:-X}` and `${VAR-X}` substitute `X` ONLY when
`VAR` is unset/empty. When `VAR` is **set**, they expand to its **value** — so a
"mask" like `${SECRET:-<unset>}` prints the real secret whenever it is present.
This leaks into terminal output and, when an agent drives the shell, into the
non-retractable session transcript / context.

**REQUIRED:** Report only presence/absence with a value-safe form that can NEVER
emit the value:

```bash
[ -n "${GITHUB_TOKEN:-}" ] && echo "GITHUB_TOKEN: set" || echo "GITHUB_TOKEN: unset"
echo "GITHUB_TOKEN: ${GITHUB_TOKEN:+set}"   # ":+" emits "set" or empty — value-safe
echo "len=${#GITHUB_TOKEN}"                 # length only, never contents
```

If a secret value IS emitted by mistake, treat it as a security incident:
`unset` it from the shell and rotate the leaked credential. The session
transcript cannot be retracted, so rotation is the only safe remedy.

## Summary Table

| Category | FORBIDDEN | REQUIRED |
|----------|-----------|----------|
| **File writes** | `>`, `>>`, `tee`, heredoc-to-file, pipe-to-file | IDE file tools (create_file, replace_string_in_file) |
| **Output filtering** | `head`, `tail`, `awk 'NR<=N'`, `sed -n`, pipe-to-grep on commands | Full unfiltered output from every command |
| **Build/test/lint** | `./bubbles.sh`, direct `npm`/`cargo`/`docker` | `bash bubbles/scripts/cli.sh <command>` |
| **Secret values** | `echo "$SECRET"`, `${SECRET:-mask}` (expands to value when set), `set -x`/`env`/`printenv` around secrets | `${SECRET:+set}` / `[ -n "$SECRET" ]` presence checks |

**Violations of this policy are blocking issues. Commands using forbidden
patterns MUST be re-executed correctly.**
