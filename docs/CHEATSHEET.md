# <img src="../icons/bubbles-glasses.svg" width="28"> Bubbles Cheat Sheet

<!-- GENERATED:FRAMEWORK_STATS_SUMMARY_START -->
> **29 Agents · 45 Gates · 24 Workflow Modes · 18 Phases**
<!-- GENERATED:FRAMEWORK_STATS_SUMMARY_END -->
>
> *"It Ain't Rocket Appliances, But It Works."*

---

## <img src="../icons/lahey-badge.svg" width="32"> Start Here

| | Agent | Alias | Role | Quote |
|---|-------|-------|------|-------|
| <img src="../icons/lahey-badge.svg" width="32"> | `bubbles.super` | Mr. Lahey | First-touch assistant. The park super for prompts, framework help, workflow advice, and getting the right next move. | *"I'm the trailer park supervisor. Start here and I'll tell you the next move."* |

## <img src="../icons/bubbles-glasses.svg" width="32"> Orchestrators

| | Agent | Alias | Role | Quote |
|---|-------|-------|------|-------|
| <img src="../icons/bubbles-glasses.svg" width="32"> | `bubbles.workflow` | Bubbles | Cross-spec orchestrator. Sees the whole board, routes the work, and keeps the whole job moving. | *"Decent. I can see how all this fits together."* |
| <img src="../icons/jacob-hardhat.svg" width="32"> | `bubbles.iterate` | Jacob | Single-iteration scope runner. Quietly keeps the next scope moving and only falls back to review when the next executable action is unclear. | *"I can help with that."* |
| <img src="../icons/green-bastard-outline.svg" width="32"> | `bubbles.code-review` | Green Bastard | Engineering-first code reviewer. Reviews repos, services, packages, modules, and paths strictly from a code perspective. | *"From parts unknown, I can smell what's broken in the code."* |
| <img src="../icons/private-dancer-spotlight.svg" width="32"> | `bubbles.system-review` | Private Dancer | Holistic system reviewer. Reviews features, components, journeys, and full systems across product, UX, runtime, trust, simplification, and engineering lenses. | *"You gotta watch the whole show, boys."* |

## <img src="../icons/julian-glass.svg" width="32"> Phase Specialists

| | Agent | Alias | Role | Quote |
|---|-------|-------|------|-------|
| <img src="../icons/julian-glass.svg" width="32"> | `bubbles.implement` | Julian | Delivers code. Every. Time. Zero drops, zero rollbacks. | *"I got work to do."* |
| <img src="../icons/trinity-notebook.svg" width="32"> | `bubbles.test` | Trinity | Grew up in chaos. Learned to verify everything independently. Trust nothing. | *"Dad, that's not how that works."* |
| <img src="../icons/jroc-mic.svg" width="32"> | `bubbles.docs` | J-Roc | Makes sure everything is narrated, recorded, and documented. | *"It could happen to you, 'cause it happened to me. And T."* |
| <img src="../icons/randy-cheeseburger.svg" width="32"> | `bubbles.validate` | Randy | Does the grunt work of checking every gate. Shirt comes off when it's serious. | *"Mr. Lahey, the tests aren't passing!"* |
| <img src="../icons/ted-badge.svg" width="32"> | `bubbles.audit` | Ted Johnson | Official, procedural, and impossible to sweet-talk. The final compliance cop. | *"This is an official audit now."* |
| <img src="../icons/ricky-dynamite.svg" width="32"> | `bubbles.chaos` | Ricky | Breaks things in ways nobody could predict. Worst case Ontario, something catches fire. | *"It's not rocket appliances."* |

## <img src="../icons/barb-keys.svg" width="32"> Planning & Design

| | Agent | Alias | Role | Quote |
|---|-------|-------|------|-------|
| <img src="../icons/ray-lawnchair.svg" width="32"> | `bubbles.analyst` | Ray | Figures out WHY the way she goes. Sees patterns from his chair. | *"Sometimes she goes, sometimes she doesn't."* |
| <img src="../icons/lucy-mirror.svg" width="32"> | `bubbles.ux` | Lucy | Cares about how things feel and look. Emotional intelligence. | *"Ricky, you can't just— fine."* |
| <img src="../icons/sarah-clipboard.svg" width="32"> | `bubbles.design` | Sarah | Turns loose ideas into a clean architecture and keeps the details from falling apart. | *"Let's get this organized before anybody breaks it."* |
| <img src="../icons/barb-keys.svg" width="32"> | `bubbles.plan` | Barb Lahey | Ran the trailer park's business side. Defines scopes. Keeps the books. | *"Jim, you need a plan."* |
| <img src="../icons/george-green-badge.svg" width="32"> | `bubbles.clarify` | George Green | Asks obvious questions that somehow reveal important things. | *"What in the f— is going on here?"* |
| <img src="../icons/conky-puppet.svg" width="32"> | `bubbles.harden` | Conky | Puppet alter-ego. Says uncomfortable truths. Confrontational. Necessary. | *"Why don't you go pave your cave?"* |
| <img src="../icons/phil-collins-baam.svg" width="32"> | `bubbles.gaps` | Phil Collins | BAAAAAM! Finds the gaps nobody else sees. | *"What are ya lookin' at my gut fer?"* |

### Ownership Quick Reference

| Artifact | Owner | Notes |
|----------|-------|-------|
| `spec.md` business requirements | `bubbles.analyst` | `bubbles.ux` may update UX sections only |
| `design.md` | `bubbles.design` | Technical design owner |
| `scopes.md` / planning structure | `bubbles.plan` | Gherkin, Test Plan, DoD, `uservalidation.md` |
| Findings from validate/harden/gaps/security/stabilize/code-review/system-review | owner via `runSubagent` | Diagnostic agents route, they do not self-author foreign artifacts |

## <img src="../icons/bill-wrench.svg" width="32"> Quality & Ops

| | Agent | Alias | Role | Quote |
|---|-------|-------|------|-------|
| <img src="../icons/cory-cap.svg" width="32"> | `bubbles.bug` | Cory | Finds the problems when sent looking. Reluctant but effective. | *"I found the thing that's busted."* |
| <img src="../icons/bill-wrench.svg" width="32"> | `bubbles.stabilize` | Shitty Bill | Quiet. Reliable. Shows up, fixes infrastructure. Just... stabilizes. | *"..."* |
| <img src="../icons/steve-french-paw.svg" width="32"> | `bubbles.regression` | Steve French | Prowls the codebase. Catches cross-feature interference. Territorial guardian. | *"Something's prowlin' around in the code, boys."* |
| <img src="../icons/cyrus-sunglasses.svg" width="32"> | `bubbles.security` | Cyrus | In our system — safety is ALWAYS ON. Finds threats. Confrontational. | *"F*** off, I got work to do."* |
| <img src="../icons/donny-ducttape.svg" width="32"> | `bubbles.simplify` | Donny | Duct tape fixes everything. Cuts through the noise. | *"Have another drink, Ray!"* |
| <img src="../icons/sebastian-guitar.svg" width="32"> | `bubbles.cinematic-designer` | Sebastian Bach | Celebrity guest. Over-the-top production value. Rock star UI. | *"I was in Skid Row!"* |

## <img src="../icons/camera-crew.svg" width="32"> Utilities

| | Agent | Alias | Role | Quote |
|---|-------|-------|------|-------|
| <img src="../icons/camera-crew.svg" width="32"> | `bubbles.status` | Camera Crew | Documentary crew. Observes. Reports. Never interferes. Read-only. | *(just watches silently)* |
| <img src="../icons/trevor-handoff.svg" width="32"> | `bubbles.handoff` | Trevor | Runs the handoff package to the next shift. Carries things. | *"Cory, take this to Julian."* |
| <img src="../icons/cory-trevor-smokes.svg" width="32"> | `bubbles.bootstrap` | Cory & Trevor | The errand duo. Set up scaffolding. Do the prep. | *"Smokes, let's go."* |
| <img src="../icons/t-cap.svg" width="32"> | `bubbles.commands` | T | J-Roc's right hand. Makes the registry. Always there. | *"True."* |
| <img src="../icons/sam-binoculars.svg" width="32"> | `bubbles.create-skill` | Sam Losco | Packages weird but useful specializations into something you can actually use again later. | *"You need a specialty for this one."* |

---

## <img src="../icons/ricky-dynamite.svg" width="32"> Command Aliases

| Alias | Maps To | Quote |
|-------|---------|-------|
| `sunnyvale pull-the-strings` | `bubbles.workflow` | *"Bubbles is pulling the strings, boys."* |
| `sunnyvale worst-case-ontario` | `bubbles.chaos` | *"Worst case Ontario, something breaks"* |
| `sunnyvale by-the-book` | `bubbles.audit --strict` | *"This is by the book now."* |
| `sunnyvale open-and-shut` | `bubbles.audit` | *"Open and shut case."* |
| `sunnyvale get-two-birds-stoned` | `bubbles.implement` + `bubbles.test` | *"Get two birds stoned at once"* |
| `sunnyvale smokes-lets-go` | `bubbles.bootstrap` | *"Smokes, let's go."* |
| `sunnyvale know-what-im-sayin` | `bubbles.docs` | *"Know what I'm sayin'?"* |
| `sunnyvale somethings-fucky` | `bubbles.validate` | *"Something's fucky"* |
| `sunnyvale way-she-goes` | `bubbles.analyst` | *"Way she goes, boys."* |
| `sunnyvale peanut-butter-and-jam` | `bubbles.gaps` | *"BAAAAM! Peanut butter and JAAAAM!"* |
| `sunnyvale safety-always-off` | `bubbles.security` | *"Safety... always off"* |
| `sunnyvale somethings-prowlin` | `bubbles.regression` | *"Something's prowlin' around in the code, boys."* |
| `sunnyvale roll-camera` | `bubbles.status` | *(camera keeps rolling)* |
| `sunnyvale greasy` | `bubbles.harden` | *"That's greasy, boys."* |
| `sunnyvale supply-and-command` | `bubbles.plan` | *"It's supply and command, Julian"* |
| `sunnyvale water-under-the-fridge` | `bubbles.simplify` | *"It's all water under the fridge"* |
| `sunnyvale have-a-good-one` | `bubbles.handoff` | *"Have a good one, boys"* |
| `sunnyvale skid-row` | `bubbles.cinematic-designer` | *"I was in Skid Row!"* |
| `sunnyvale mans-gotta-eat` | `bubbles.validate` | *"A man's gotta eat, Julian"* |
| `sunnyvale the-super` | `bubbles.super` | *"Ask the super first."* |
| `sunnyvale parts-unknown` | `bubbles.code-review` | *"From parts unknown, the code review sees all."* |
| `sunnyvale whole-show` | `bubbles.system-review` | *"You gotta watch the whole show, boys."* |

---

## <img src="../icons/julian-glass.svg" width="32"> Workflow Modes

| Mode | Alias | What It Does |
|------|-------|-------------|
| `value-first-e2e-batch` | boys-plan | Auto-discover highest-value work, full delivery pipeline |
| `full-delivery` | full-send | Standard complete delivery — the default |
| `full-delivery-strict` | clean-and-sober | Strict enforcement, no blocked continuation |
| `chaos-hardening` | shit-storm | Iterative chaos + bugfix cycles until clean |
| `bugfix-fastlane` | smash-and-grab | Fast bug closure — in, fix, out |
| `validate-only` | randy-put-a-shirt-on | Run validation gates only |
| `stochastic-quality-sweep` | bottle-kids | Randomized probing — you never know where they'll hit |
| `harden-gaps-to-doc` | conky-says | Thorough pre-release sweep |
| `product-to-delivery` | freedom-35 | Full pipeline: analyst → UX → design → implement → ship |
| `docs-only` | gnome-sayin | Documentation maintenance only |
| `feature-bootstrap` | — | Set up artifacts without implementing |
| `iterate` | — | Continue scope-by-scope implementation |
| `resume-only` | — | Resume from last session state |
| `product-discovery` | — | Business analysis + UX exploration only |
| `test-to-doc` | — | Run tests, fix failures, update docs |
| `audit-only` | — | Run audit phase only |
| `stabilize-to-doc` | — | Stability fixes → test → docs |
| `improve-existing` | — | Harden → simplify → test → docs |
| `spec-scope-hardening` | — | Tighten specs and scope definitions |
| `harden-to-doc` | — | Harden → test → docs |
| `gaps-to-doc` | — | Gap analysis → test → docs |
| `chaos-to-doc` | — | Chaos → test → docs |
| `reconcile-to-doc` | — | Reconcile conflicts → test → docs |
| `validate-to-doc` | — | Validate + audit + docs |

**Optional execution tags:** `socratic`, `socraticQuestions`, `gitIsolation`, `autoCommit` (off|scope|dod), `maxScopeMinutes`, `maxDodMinutes`, `microFixes`

---

<!-- GENERATED:FRAMEWORK_STATS_CHEATSHEET_GATES_START -->
## <img src="../icons/lahey-badge.svg" width="32"> The 42 Gates
<!-- GENERATED:FRAMEWORK_STATS_CHEATSHEET_GATES_END -->

**Phase flow:**
`analyze` → `discover` → `select` → `bootstrap` → `harden` → `gaps` → `stabilize` → `implement` → `test` → `regression` → `simplify` → `stabilize` → `security` → `docs` → `validate` → `audit` → `chaos` → `finalize`

| Gate | Name | What It Checks |
|------|------|---------------|
| G001 | Artifact gate | Required artifacts exist |
| G002 | Scope definition | Scope has scenarios, test plan, and DoD |
| G003 | Test integrity | Test classifications match execution reality |
| G004 | Test execution | Required tests executed and passing |
| G005 | Evidence gate | Raw execution evidence captured |
| G006 | Docs sync | Docs updated and coherent |
| G007 | Validation | Validation checks pass |
| G008 | Audit gate | Audit verdict acceptable |
| G009 | Chaos gate | Chaos rounds complete without failures |
| G010 | User validation | User validation checklist updated |
| G011 | Session gate | Session state updated for resume |
| G012 | Final promotion | All mode-required gates pass |
| G013 | Priority selection | Highest-value work selected with rationale |
| G014 | Bootstrap readiness | Design/spec/scopes ready before implementation |
| G015 | Scenario depth | Detailed Gherkin scenarios covering use cases |
| G016 | Gherkin traceability | Scenarios map to E2E tests |
| G017 | DoD E2E expansion | DoD includes E2E items |
| G018 | DoD completion | All DoD checkboxes checked |
| G019 | Sequential completion | Previous spec done before starting next |
| G020 | Anti-fabrication | Evidence is real, not fabricated |
| G021 | Detection heuristics | < 10 lines = presumed fabricated |
| G022 | Specialist execution | Required phases actually executed |
| G023 | State transition guard | Mechanical enforcement script passes |
| G024 | All scopes done | All scopes Done before spec done |
| G025 | Per-DoD evidence | Every `[x]` has inline evidence ≥ 10 lines |
| G026 | Stress for SLA | SLA scopes have stress tests |
| G027 | Phase-scope coherence | Completed phases match completed scopes |
| G028 | Implementation reality | No stubs/fakes/hardcoded data in source |
| G029 | Integration completeness | All artifacts wired into the system |
| G030 | No defaults/no fallbacks | Production code fails fast instead of masking missing inputs |
| G031 | Findings artifact update | Findings are recorded in artifacts before verdict |
| G032 | Business analysis | Actors, use cases, scenarios, wireframes are present when required |
| G033 | Design readiness | design.md + scopes.md exist before implement |
| G034 | Security scan | No vulnerabilities in changed code |
| G035 | Vertical slice | Frontend API calls match backend handlers |
| G036 | Red→green traceability | Changed behavior shows failing proof before passing proof |
| G037 | Scope size discipline | Scopes stay small, isolated, and single-outcome |
| G038 | Micro-fix containment | Failures are repaired in narrow loops before broad reruns |
| G039 | Self-healing containment | Fix loops never stack; maxDepth=1, maxRetries=3, narrowing context |
| G040 | Zero deferral language | Scope artifacts scanned for "deferred", "future scope", "out of scope", etc. — can't mark done with outstanding work |
| G041 | DoD format integrity | Prevents agents from bypassing guards by reformatting checkboxes (`- (deferred)`) or inventing scope statuses (`Deferred — Planned Improvement`) |
| G042 | Agent ownership | Foreign-owned artifacts must be routed to the owning specialist; no cross-authoring by diagnostic agents |
| G043 | Consumer trace | Renames/removals require zero stale references across all consumers |
| G044 | Regression baseline | Before/after test count comparison — previously-passing tests must still pass |
| G045 | Cross-spec regression | Done specs' tests rerun after changes — no cross-feature interference |
| G046 | Spec conflict detection | Route/table/API collisions scanned against all existing specs |

---

## <img src="../icons/phil-collins-baam.svg" width="32"> Fun Mode Messages (`BUBBLES_FUN_MODE=true`)

| Event | Message |
|-------|---------|
| ✅ Gate passed | *"Decent!"* |
| ✅ Scope ready | *"Looks good, boys."* |
| ❌ Gate failure | *"Something's fucky."* |
| ❌ Fabrication detected | *"That's GREASY, boys. Real greasy."* |
| ❌ Missing evidence | *"Where's your evidence? Shit hawk circling."* |
| ✅ All gates pass | *"Way she goes, boys. Way she goes."* |
| ❌ Build failed | *"Holy f\*\*\*, boys."* |
| ✅ Spec completed | *"DEEEE-CENT!"* |
| ❌ Warnings found | *"The shit winds are coming, Randy."* |
| ✅ Chaos clean | *"Worst case Ontario... nothing broke."* |
| 🟢 Regression clean | *"Steve French is purrin'. No regressions, boys."* |
| 🔴 Regression found | *"Something's prowlin' around in the code, boys."* |
| 🔴 Spec conflict | *"Steve French found another cougar's territory. Two specs, same route."* |
| ❌ Security vuln | *"Safety... always ON."* |
| ✅ Docs updated | *"Know what I'm sayin'? It's documented."* |
| ❌ Deferral detected | *"You can't just NOT do things, Corey!"* |
| ❌ Deferral blocks done | *"That's NOT gettin' two birds stoned — that's just sayin' you WILL."* |
| ❌ Manipulation detected | *"That's GREASY, boys. You can't just cross things out and say they're done!"* |
| ❌ Format bypass | *"You can't just erase the checkboxes and call it a day, Ricky!"* |
| ❌ Invented status | *"'Deferred — Planned Improvement'?! That's not even a real thing, Julian!"* |
| ✅ Handoff complete | *"Have a good one, boys."* |
| ❌ Gap found | *"This is f\*\*\*ed. BAAAAM!"* |
| ✅ Bug located | *"That's a nice f\*\*\*ing kitty right there."* |
| ✅ Build succeeds | *"Knock knock." "A passing build."* |
| Milestone reached | *"Freedom 35, boys!"* |

---

## <img src="../icons/trinity-notebook.svg" width="32"> Quick Reference — What To Type When

### Starting a Job

| Situation | Command |
|-----------|---------|
| New feature from scratch | `/bubbles.analyst  <describe feature>` |
| Plan and scope a feature | `/bubbles.plan  <feature>` |
| Full delivery pipeline | `/bubbles.workflow  full-delivery for <feature>` |
| Bootstrap artifacts | `/bubbles.bootstrap  create feature for <name>` |
| Fix a bug | `/bubbles.bug  <describe bug>` |
| **Don't know what to do?** | **`/bubbles.super  help me <describe goal>`** |

### Natural Language — Just Say What You Want

All agents accept natural language. You don't need to know the exact mode or parameters — just describe what you want:

| You Type | Agent Understands |
|----------|-------------------|
| `/bubbles.workflow  improve the booking feature to be competitive` | mode: improve-existing, spec: booking |
| `/bubbles.workflow  do 10 rounds of stabilize on booking` | mode: stochastic-quality-sweep, triggerAgents: stabilize, maxRounds: 10, spec: booking |
| `/bubbles.code-review  do an engineering sweep on the gateway` | profile: engineering-sweep, scope: service:gateway |
| `/bubbles.system-review  review the booking feature as a user` | mode: full, scope: feature:booking |
| `/bubbles.workflow  spend 2 hours working on whatever needs attention` | mode: iterate, minutes: 120 |
| `/bubbles.iterate  fix tests for the page builder` | type: tests, feature: page-builder |
| `/bubbles.implement  do the next scope` | mode: next |
| `/bubbles.test  why are integration tests failing?` | action: triage, types: integration |
| `/bubbles.analyst  how does our booking compare to competitors?` | mode: improve, competitive research on |
| `/bubbles.security  scan for hardcoded secrets` | focus: secrets |
| `/bubbles.chaos  break the search feature` | scope: search |
| `/bubbles.super  what's the best way to fix a bug?` | Platform Assistant: recommend bugfix sequence |

### Using The Super as Your Assistant

When you're not sure which agent to use, ask `bubbles.super` first:

| You Ask | The Super Responds With |
|---------|-------------------|
| `/bubbles.super  I have a new feature idea for search` | Recommended sequence: analyst → ux → workflow product-to-delivery |
| `/bubbles.super  I want to make the booking feature better` | `/bubbles.workflow  <booking-spec> mode: improve-existing` |
| `/bubbles.super  review this repo before we decide what to spec` | `/bubbles.system-review  scope: full-system output: summary-doc` |
| `/bubbles.super  which mode should I use?` | Decision tree based on your situation |
| `/bubbles.super  help me write a command for chaos testing` | `/bubbles.workflow mode: stochastic-quality-sweep maxRounds: 5` |
| `/bubbles.super  what should I do before shipping?` | Ship-readiness sequence: harden → chaos → security → audit |
| `/bubbles.super  why did my workflow stop after validate?` | Short diagnosis + the next command to recover or continue |
| `/bubbles.super  turn this problem into the right Bubbles prompts` | A command sequence with brief reasons for each step |

### During Implementation

| Situation | Command |
|-----------|---------|
| Implement a scope | `/bubbles.implement  execute scope 1 of <feature>` |
| Continue next scope | `/bubbles.iterate  continue <feature>` |
| Simplify complex code | `/bubbles.simplify` |
| Design the architecture | `/bubbles.design  create design for <feature>` |

### Testing & Validation

| Situation | Command |
|-----------|---------|
| Run and fix tests | `/bubbles.test  run tests for <feature>` |
| Validate gates | `/bubbles.validate` |
| Full audit | `/bubbles.audit` |
| Chaos testing | `/bubbles.chaos` |

### When Things Go Wrong

| Situation | Command |
|-----------|---------|
| Something seems off | `/bubbles.validate` |
| Find what's missing | `/bubbles.gaps` |
| Harden weak spots | `/bubbles.harden` |
| Security scan | `/bubbles.security` |
| Check for regressions | `/bubbles.regression` |
| Quality sweep | `/bubbles.workflow  harden-gaps-to-doc` |

### Success & Wrap-Up

| Situation | Command |
|-----------|---------|
| Check progress | `/bubbles.status` |
| Check progress (narrative) | `/bubbles.status --explain` |
| Update documentation | `/bubbles.docs` |
| End of session | `/bubbles.handoff` |
| Resume tomorrow | `/bubbles.workflow  resume` |

### Framework Operations — `bubbles.super` or CLI

| Situation | Agent | CLI |
|-----------|-------|-----|
| Check project health | `/bubbles.super doctor` | `bubbles doctor` |
| Auto-fix health issues | `/bubbles.super doctor --heal` | `bubbles doctor --heal` |
| Install git hooks | `/bubbles.super install hooks` | `bubbles hooks install --all` |
| Show available hooks | `/bubbles.super list hook catalog` | `bubbles hooks catalog` |
| Add custom hook | `/bubbles.super add pre-push hook for license` | `bubbles hooks add pre-push script.sh --name my-hook` |
| Add custom gate | `/bubbles.super add license gate` | `bubbles project gates add name --script path` |
| Show scope dependencies | `/bubbles.super show dag for 042` | `bubbles dag 042` |
| Enable metrics | `/bubbles.super enable metrics` | `bubbles metrics enable` |
| View lessons learned | `/bubbles.super show lessons` | `bubbles lessons` |
| Compact old lessons | `/bubbles.super compact lessons` | `bubbles lessons compact` |
| Upgrade Bubbles | `/bubbles.super upgrade` | `bubbles upgrade` |
| Upgrade (dry run) | `/bubbles.super upgrade --dry-run` | `bubbles upgrade --dry-run` |
| **Help me choose an agent** | **`/bubbles.super help me <goal>`** | — |
| **Generate a command** | **`/bubbles.super what command for <task>`** | — |
| **Recommend workflow** | **`/bubbles.super which mode for <situation>`** | — |
| **Multi-step plan** | **`/bubbles.super plan steps for <goal>`** | — |

---

## <img src="../icons/ricky-dynamite.svg" width="32"> Rickyisms — The Official Glossary

| Rickyism | What He Meant | Bubbles Context |
|----------|--------------|-----------------|
| "Worst case Ontario" | Worst case scenario | Chaos testing fallback |
| "Get two birds stoned at once" | Kill two birds with one stone | Implement + test combo |
| "It's not rocket appliances" | It's not rocket science | Overcomplicating things |
| "Supply and command" | Supply and demand | Planning & resources |
| "Water under the fridge" | Water under the bridge | Simplification done, move on |
| "I toad a so" | I told you so | When Conky (harden) was right |
| "Make like a tree and f*** off" | Make like a tree and leave | Cleaning up dead code |
| "What comes around is all around" | What goes around comes around | Circular dependency |
| "Denial and error" | Trial and error | Ignoring failing tests |
| "Passed with flying carpets" | Passed with flying colors | All gates passed |
| "Survival of the fitness, boys" | Survival of the fittest | Stochastic sweep results |
| "Gorilla see, gorilla do" | Monkey see, monkey do | Copy-paste code detected |
| "Steve French is just a big stoned kitty" | The regression guardian is doing its job | Cross-spec check running |
| "It's a doggy-dog world" | Dog-eat-dog world | Competitive analysis |
| "I'll do it tomorrah" | I'll do it tomorrow | Deferring work (G040 violation) |

---

<p align="center">
  <img src="../icons/bubbles-glasses.svg" width="40"><br>
  <em>"Have a good one, boys."</em><br>
  Sunnyvale Trailer Park Software Division<br>
  0 Shit Hawks
</p>
