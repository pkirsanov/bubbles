# <img src="../icons/bubbles-glasses.svg" width="28"> Bubbles Cheat Sheet

> **26 Agents · 39 Gates · 23 Workflow Modes · 17 Phases**
>
> *"It Ain't Rocket Appliances, But It Works."*

---

## <img src="../icons/bubbles-glasses.svg" width="32"> Orchestrators

| | Agent | Alias | Role | Quote |
|---|-------|-------|------|-------|
| <img src="../icons/bubbles-glasses.svg" width="32"> | `bubbles.workflow` | Bubbles | Cross-spec orchestrator. Sees everything through those thick glasses. The real brains. | *"Something's fucky."* |
| <img src="../icons/julian-glass.svg" width="32"> | `bubbles.iterate` | Julian | Single-iteration scope runner. Cool. Composed. Drink never spills. | *"Boys, we need a plan. A good plan this time."* |

## <img src="../icons/julian-glass.svg" width="32"> Phase Specialists

| | Agent | Alias | Role | Quote |
|---|-------|-------|------|-------|
| <img src="../icons/julian-glass.svg" width="32"> | `bubbles.implement` | Julian | Delivers code. Every. Time. Zero drops, zero rollbacks. | *"I got work to do."* |
| <img src="../icons/trinity-notebook.svg" width="32"> | `bubbles.test` | Trinity | Grew up in chaos. Learned to verify everything independently. Trust nothing. | *"Dad, that's not how that works."* |
| <img src="../icons/jroc-mic.svg" width="32"> | `bubbles.docs` | J-Roc | Makes sure everything is narrated, recorded, and documented. | *"It could happen to you, 'cause it happened to me. And T."* |
| <img src="../icons/randy-cheeseburger.svg" width="32"> | `bubbles.validate` | Randy | Does the grunt work of checking every gate. Shirt comes off when it's serious. | *"Mr. Lahey, the tests aren't passing!"* |
| <img src="../icons/lahey-bottle.svg" width="32"> | `bubbles.audit` | Mr. Lahey | "I AM the liquor." I AM the policy. Enforces every. last. rule. | *"The shit winds are coming, Randy."* |
| <img src="../icons/ricky-dynamite.svg" width="32"> | `bubbles.chaos` | Ricky | Breaks things in ways nobody could predict. Worst case Ontario, something catches fire. | *"It's not rocket appliances."* |

## <img src="../icons/barb-keys.svg" width="32"> Planning & Design

| | Agent | Alias | Role | Quote |
|---|-------|-------|------|-------|
| <img src="../icons/ray-lawnchair.svg" width="32"> | `bubbles.analyst` | Ray | Figures out WHY the way she goes. Sees patterns from his chair. | *"Sometimes she goes, sometimes she doesn't."* |
| <img src="../icons/lucy-mirror.svg" width="32"> | `bubbles.ux` | Lucy | Cares about how things feel and look. Emotional intelligence. | *"Ricky, you can't just— fine."* |
| <img src="../icons/jacob-hardhat.svg" width="32"> | `bubbles.design` | Jacob | Quietly competent architecture. Does the thinking while others take credit. | *"I can help with that, Mr. Lahey."* |
| <img src="../icons/barb-keys.svg" width="32"> | `bubbles.plan` | Barb Lahey | Ran the trailer park's business side. Defines scopes. Keeps the books. | *"Jim, you need a plan."* |
| <img src="../icons/george-green-badge.svg" width="32"> | `bubbles.clarify` | George Green | Asks obvious questions that somehow reveal important things. | *"What in the f— is going on here?"* |
| <img src="../icons/conky-puppet.svg" width="32"> | `bubbles.harden` | Conky | Puppet alter-ego. Says uncomfortable truths. Confrontational. Necessary. | *"Why don't you go pave your cave?"* |
| <img src="../icons/phil-collins-baam.svg" width="32"> | `bubbles.gaps` | Phil Collins | BAAAAAM! Finds the gaps nobody else sees. | *"What are ya lookin' at my gut fer?"* |

## <img src="../icons/bill-wrench.svg" width="32"> Quality & Ops

| | Agent | Alias | Role | Quote |
|---|-------|-------|------|-------|
| <img src="../icons/cory-trevor-smokes.svg" width="32"> | `bubbles.bug` | Cory | Finds the problems when sent looking. Reluctant but effective. | *"Trevor, I think we broke something."* |
| <img src="../icons/bill-wrench.svg" width="32"> | `bubbles.stabilize` | Shitty Bill | Quiet. Reliable. Shows up, fixes infrastructure. Just... stabilizes. | *"..."* |
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
| <img src="../icons/phil-collins-baam.svg" width="32"> | `bubbles.create-skill` | Phil Collins | Creates new things. Big, bold, unmissable. | *"BAAAAM!"* |
| <img src="../icons/bubbles-glasses.svg" width="32"> | `bubbles.ops` | Bubbles (the super) | Manages the park. Health checks, hooks, upgrades, metrics, gates. | *"Decent! Everything's running smooth."* |

---

## <img src="../icons/ricky-dynamite.svg" width="32"> Command Aliases

| Alias | Maps To | Quote |
|-------|---------|-------|
| `sunnyvale pull-the-strings` | `bubbles.workflow` | *"Bubbles is pulling all the strings, boys"* |
| `sunnyvale worst-case-ontario` | `bubbles.chaos` | *"Worst case Ontario, something breaks"* |
| `sunnyvale i-am-the-liquor` | `bubbles.audit --strict` | *"I AM the liquor, Randy"* |
| `sunnyvale shit-winds` | `bubbles.audit` | *"The shit winds are coming"* |
| `sunnyvale get-two-birds-stoned` | `bubbles.implement` + `bubbles.test` | *"Get two birds stoned at once"* |
| `sunnyvale smokes-lets-go` | `bubbles.bootstrap` | *"Smokes, let's go."* |
| `sunnyvale know-what-im-sayin` | `bubbles.docs` | *"Know what I'm sayin'?"* |
| `sunnyvale somethings-fucky` | `bubbles.validate` | *"Something's fucky"* |
| `sunnyvale way-she-goes` | `bubbles.analyst` | *"Way she goes, boys."* |
| `sunnyvale peanut-butter-and-jam` | `bubbles.gaps` | *"BAAAAM! Peanut butter and JAAAAM!"* |
| `sunnyvale safety-always-off` | `bubbles.security` | *"Safety... always off"* |
| `sunnyvale decent` | `bubbles.status` | *"DEEEE-CENT!"* |
| `sunnyvale greasy` | `bubbles.harden` | *"That's greasy, boys."* |
| `sunnyvale supply-and-command` | `bubbles.plan` | *"It's supply and command, Julian"* |
| `sunnyvale water-under-the-fridge` | `bubbles.simplify` | *"It's all water under the fridge"* |
| `sunnyvale have-a-good-one` | `bubbles.handoff` | *"Have a good one, boys"* |
| `sunnyvale skid-row` | `bubbles.cinematic-designer` | *"I was in Skid Row!"* |
| `sunnyvale mans-gotta-eat` | `bubbles.validate` | *"A man's gotta eat, Julian"* |
| `sunnyvale the-super` | `bubbles.ops` | *"I'm the park supervisor."* |

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

**Optional execution tags:** `socratic`, `socraticQuestions`, `gitIsolation`, `autoCommit` (off|scope|dod), `maxScopeMinutes`, `maxDodMinutes`, `microFixes`

---

## <img src="../icons/lahey-bottle.svg" width="32"> The 39 Gates

**Phase flow:**
`analyze` → `discover` → `select` → `bootstrap` → `harden` → `gaps` → `implement` → `test` → `security` → `docs` → `validate` → `audit` → `chaos` → `finalize`

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
| ❌ Security vuln | *"Safety... always ON."* |
| ✅ Docs updated | *"Know what I'm sayin'? It's documented."* |
| ❌ Deferral detected | *"You can't just NOT do things, Corey!"* |
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
| Quality sweep | `/bubbles.workflow  harden-gaps-to-doc` |

### Success & Wrap-Up

| Situation | Command |
|-----------|---------|
| Check progress | `/bubbles.status` |
| Check progress (narrative) | `/bubbles.status --explain` |
| Update documentation | `/bubbles.docs` |
| End of session | `/bubbles.handoff` |
| Resume tomorrow | `/bubbles.workflow  resume` |

### Framework Operations — `bubbles.ops` or CLI

| Situation | Agent | CLI |
|-----------|-------|-----|
| Check project health | `/bubbles.ops doctor` | `bubbles doctor` |
| Auto-fix health issues | `/bubbles.ops doctor --heal` | `bubbles doctor --heal` |
| Install git hooks | `/bubbles.ops install hooks` | `bubbles hooks install --all` |
| Show available hooks | `/bubbles.ops list hook catalog` | `bubbles hooks catalog` |
| Add custom hook | `/bubbles.ops add pre-push hook for license` | `bubbles hooks add pre-push script.sh --name my-hook` |
| Add custom gate | `/bubbles.ops add license gate` | `bubbles project gates add name --script path` |
| Show scope dependencies | `/bubbles.ops show dag for 042` | `bubbles dag 042` |
| Enable metrics | `/bubbles.ops enable metrics` | `bubbles metrics enable` |
| View lessons learned | `/bubbles.ops show lessons` | `bubbles lessons` |
| Compact old lessons | `/bubbles.ops compact lessons` | `bubbles lessons compact` |
| Upgrade Bubbles | `/bubbles.ops upgrade` | `bubbles upgrade` |
| Upgrade (dry run) | `/bubbles.ops upgrade --dry-run` | `bubbles upgrade --dry-run` |

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
| "It's a doggy-dog world" | Dog-eat-dog world | Competitive analysis |

---

<p align="center">
  <img src="../icons/bubbles-glasses.svg" width="40"><br>
  <em>"Have a good one, boys."</em><br>
  Sunnyvale Trailer Park Software Division<br>
  0 Shit Hawks
</p>
