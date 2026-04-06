# Feature: 001 Competitive Framework Parity

## Problem Statement
Bubbles has a differentiated control plane, ownership model, and validation discipline, but it still loses ground to competing agent frameworks on adoption speed, interoperability, packaging, and externally legible value. Teams comparing Bubbles against Claude Code, Roo Code, Cursor, and Cline can understand that Bubbles is powerful, yet still conclude that it is heavier to install, harder to migrate into, and less obvious to operationalize at scale.

## Outcome Contract
**Intent:** Make Bubbles competitively stronger against leading agent frameworks by closing the highest-value gaps in onboarding, interoperability, packaging, downstream validation, and product clarity without weakening the framework's rigor model. The result should be a framework that remains strict and auditable while becoming materially easier to adopt, compare, and trust.
**Success Signal:** A new downstream repo can install Bubbles, reach a usable project-ready state with minimal manual cleanup, understand the value proposition quickly, and verify framework health with clear docs and automated checks. Existing users can map Bubbles concepts to adjacent ecosystems and migrate or integrate with less friction.
**Hard Constraints:** Bubbles must preserve validate-owned certification, artifact ownership boundaries, scenario-contract discipline, project-agnostic command indirection, and framework-managed file immutability. Competitive improvements must not degrade anti-fabrication enforcement or turn repo-readiness guidance into fake certification.
**Failure Condition:** The work is a failure if Bubbles adds more docs and surface area without materially reducing adoption friction, if interoperability remains weak, if source-repo and downstream trust gaps stay under-documented, or if simplification compromises the framework's governance model.

## Actors & Personas
| Actor | Description | Key Goals | Permissions |
|-------|-------------|-----------|-------------|
| Framework Maintainer | Person evolving the Bubbles source repo and shipping upgrades downstream | Ship framework changes safely, prove source-repo quality, keep docs truthful, reduce downstream breakage | Full source-repo authority, framework release ownership |
| Downstream Repo Maintainer | Team adopting Bubbles in a product repo | Install quickly, customize safely, avoid framework drift, understand which files are framework-owned vs repo-owned | Repo-owned config and project overrides, no framework-owned file edits |
| Delivery Engineer | Developer using Bubbles for day-to-day feature and bug work | Reach value quickly, trust workflow routing, avoid setup drag, get reliable validation outcomes | Uses Bubbles agents, workflows, and repo CLI commands |
| Platform Evaluator | Technical leader comparing Bubbles with Claude Code, Roo Code, Cursor, Cline, or similar tools | Decide whether Bubbles is worth adopting, understand competitive tradeoffs, estimate migration cost and team fit | Read-only evaluation and pilot decision authority |
| Repo Readiness Reviewer | Engineer checking whether a target repo is safe and prepared for agentic work | Distinguish advisory readiness gaps from certification, fix onboarding and command drift, avoid false confidence | Advisory framework-ops and hygiene authority |

## Current Capabilities
| Capability | Backend / Framework Surface | User / Docs Surface | Status |
|-----------|------------------------------|---------------------|--------|
| Universal natural-language entry point | `bubbles.workflow`, workflow mode registry, orchestrator chain | README, workflow guide, recipes | Complete |
| Specialized role-based agents | `agents/bubbles.*.agent.md`, ownership registry | README roster, Agent Manual | Complete |
| Validate-owned certification model | `state.json` v3, ownership registry, transition guards | Control plane docs | Complete |
| Scenario and gate-based delivery enforcement | `workflows.yaml`, guard/lint scripts, manifests | README, cheat sheet, workflow docs | Complete |
| Runtime lease coordination | CLI runtime commands, runtime lease scripts, selftests | Framework-ops recipe, control plane docs | Partial: implemented but public issue/docs freshness is inconsistent |
| Repo bootstrap and command indirection | `install.sh`, `.specify/memory/agents.md`, templates | Installation guide, README | Partial: powerful but high-friction |
| Downstream repo-readiness guidance | `repo-readiness.sh`, super/CLI surfaces, skill | Framework-ops recipe, skill docs | Partial |
| External ecosystem interoperability | Limited command/rule coexistence mentions only | Minimal | Missing |
| Shareable packaging / migration helpers | Install + bootstrap only | Installation docs | Missing |
| Source-repo proof of continuous framework quality | `framework-validate`, `release-check`, selftests | Implicit in docs and CI | Partial |

## Competitive Analysis
| Area | Bubbles | Claude Code | Roo Code | Cursor | Cline | Gap |
|------|---------|-------------|----------|--------|-------|-----|
| Specialized agents / modes | Rich specialist agent set with workflow ownership | Strong subagent system with hooks, memory, isolation | Strong custom modes plus orchestrator | Strong autonomous agents, less explicit role ownership | Lighter single-agent model with rules | Bubbles strong on governance, weaker on ease of creation/customization |
| Workflow orchestration | Best-in-class explicit phase/gate model | Moderate via subagents and teams | Strong orchestrator mode | Strong product-level autonomous execution | Light | Bubbles advantage |
| Repo-local governance | Very strong | Strong via CLAUDE.md, hooks, settings | Strong via modes/rules | Moderate via rules/docs | Strong lightweight rules | Bubbles advantage, but high setup cost |
| Interoperability with other ecosystems | Minimal | Moderate plugin and MCP ecosystem | Strong mode import/export and team sharing | Strong marketplace/product integrations | Strong rule compatibility with other formats | Bubbles behind |
| Setup and onboarding speed | Heavy bootstrap and repo config expectations | Faster install and subagent setup | Faster UI-driven mode setup | Very low-friction product experience | Very low-friction | Bubbles behind |
| Public value narrative | Strong internal docs, weaker simple comparison story | Strong product story | Strong customization story | Strong productivity story | Strong simplicity story | Bubbles behind |
| Continuous trust signals | Real selftests and release checks | Strong product polish and enterprise trust | Strong product/docs surface | Strong enterprise/polish surface | Simpler but clear | Bubbles needs stronger external trust packaging |

## Competitor Deep Dives

### Claude Code Deep Dive
- **Closest overlap:** Subagents, hooks, skills, scoped memory, MCP access, background/foreground execution, session and agent persistence.
- **Where Bubbles wins:** Stronger artifact ownership, stronger completion semantics, stronger validate-owned certification, stronger scenario-driven delivery model.
- **Where Claude Code wins:** Easier subagent authoring, stronger built-in execution ergonomics, richer background execution behavior, stronger multi-surface product packaging.
- **Implication for Bubbles:** Bubbles should not copy Claude's generic subagent model directly. It should adopt Claude-like ergonomics for specialist creation, memory, and constrained execution while keeping Bubbles' explicit ownership and gate model.

### Roo Code Deep Dive
- **Closest overlap:** Custom modes, orchestrator, team-sharable project-local behavior, strong customization story.
- **Where Bubbles wins:** More rigorous workflow lifecycle, stronger validation and evidence model, clearer artifact/certification separation.
- **Where Roo wins:** Mode setup UX, import/export portability, lower friction for teams to create and share constrained behaviors.
- **Implication for Bubbles:** The highest-value response is not more governance. It is portable packaging and migration support for repo-local specialization.

### Cursor Deep Dive
- **Closest overlap:** Autonomous multi-step coding, parallel execution, broad model support, product narrative around acceleration.
- **Where Bubbles wins:** Stronger repo-local control plane, stronger auditability, stronger explicit workflow semantics.
- **Where Cursor wins:** Clearer value proposition, better polish, lower-friction onboarding, more obvious enterprise-ready experience.
- **Implication for Bubbles:** Bubbles needs a lighter front door, better benchmark/evidence packaging, and clearer business-facing messaging.

### Cline Deep Dive
- **Closest overlap:** Repo-local rules, configurable behavior, tool access in editor/terminal, lightweight extensibility.
- **Where Bubbles wins:** Far deeper orchestration and completion discipline.
- **Where Cline wins:** Simplicity, cross-tool rule compatibility, faster initial usefulness.
- **Implication for Bubbles:** Import and coexistence support for external rule ecosystems would create an easy adoption path for teams currently using simpler tools.

## Platform Direction & Market Trends

### Industry Trends
| Trend | Status | Relevance | Impact on Product |
|-------|--------|-----------|-------------------|
| Specialized subagents and mode-based delegation | Established | High | Bubbles must keep role specialization but improve creation, discoverability, and reuse |
| Repo-local rules and memory as first-class workflow inputs | Established | High | Bubbles already does this well, but needs easier onboarding and better interop |
| Parallel and background execution with isolation controls | Growing | High | Bubbles has meaningful foundations; it needs easier UX and stronger narrative |
| Cross-tool interoperability and migration paths | Growing | High | Competing tools increasingly coexist; lock-in-resistant adoption is becoming table stakes |
| Enterprise trust through visible automation checks | Growing | Medium | Bubbles should expose clearer source-repo and downstream trust signals |

### Strategic Opportunities
| Opportunity | Type | Priority | Rationale |
|------------|------|----------|-----------|
| Bubbles Lite onboarding path | Table Stakes | High | Reduces adoption friction without weakening advanced control plane capabilities |
| Rule and mode interoperability import/export | Differentiator | High | Creates migration pull from Cline, Roo, Cursor-style rule ecosystems |
| Source-to-downstream confidence pipeline | Table Stakes | High | Makes framework quality visible and reduces fear of framework-managed upgrades |
| Competitive positioning docs and benchmark evidence | Table Stakes | High | Converts internal rigor into external buying confidence |
| Framework issue freshness and shipped-vs-proposed hygiene | Table Stakes | Medium | Prevents trust erosion when docs lag implementation |
| Maturity-tier governance profiles | Differentiator | Medium | Lets teams start lighter and grow into full rigor instead of bouncing off early |

## Use Cases

### UC-001: Evaluate Bubbles Against Competing Agent Frameworks
- **Actor:** Platform Evaluator
- **Preconditions:** Evaluator can access Bubbles docs, installation flow, and comparison materials.
- **Main Flow:**
  1. Evaluator identifies criteria such as setup friction, orchestration depth, trust signals, and interoperability.
  2. Evaluator reviews Bubbles' comparison material and framework capabilities.
  3. Evaluator understands how Bubbles differs from Claude Code, Roo Code, Cursor, and Cline.
  4. Evaluator makes an informed adoption or pilot decision.
- **Alternative Flows:**
  1. Evaluator cannot map Bubbles concepts to familiar tool concepts and abandons evaluation.
  2. Evaluator sees stale docs or known issues that reduce trust in the framework.
- **Postconditions:** Bubbles' strengths, tradeoffs, and maturity are legible enough to support a rational decision.

### UC-002: Bootstrap A New Repo With Minimal Manual Repair
- **Actor:** Downstream Repo Maintainer
- **Preconditions:** Repo has Git, VS Code Copilot Chat, and a known project root.
- **Main Flow:**
  1. Maintainer installs Bubbles with bootstrap.
  2. Maintainer reaches a repo-ready state with minimal unresolved placeholders.
  3. Maintainer can verify framework health and repo-readiness distinctly.
  4. Maintainer knows what is framework-owned versus repo-owned.
- **Alternative Flows:**
  1. Bootstrap leaves too much TODO debt and the maintainer cannot tell what matters first.
  2. Framework-managed files appear to require downstream patching.
- **Postconditions:** Repo reaches a usable operational state quickly and safely.

### UC-003: Migrate Existing Rule Or Mode Investments Into Bubbles
- **Actor:** Downstream Repo Maintainer
- **Preconditions:** Repo already uses Cline rules, Roo modes, Cursor rules, or similar conventions.
- **Main Flow:**
  1. Maintainer points Bubbles at existing rule/mode assets.
  2. Bubbles imports or translates those assets into Bubbles-compatible surfaces.
  3. Maintainer reviews the resulting artifacts and resolves conflicts.
  4. Repo begins using Bubbles without discarding prior investment.
- **Alternative Flows:**
  1. Imported assets conflict with Bubbles ownership or governance expectations.
  2. Imported assets are unsupported and require manual mapping.
- **Postconditions:** Migration cost is lower and Bubbles becomes easier to trial in mature repos.

### UC-004: Trust A Framework Upgrade In A Downstream Repo
- **Actor:** Framework Maintainer, Downstream Repo Maintainer
- **Preconditions:** New Bubbles release exists and downstream repo wants to refresh.
- **Main Flow:**
  1. Maintainer upgrades Bubbles from an upstream release.
  2. Source-repo release hygiene and downstream compatibility checks are visible.
  3. Downstream maintainer sees what changed, what remains repo-owned, and what additional action is required.
  4. Repo reaches a healthy post-upgrade state without patching framework files manually.
- **Alternative Flows:**
  1. Local dirty-source installs leak unpublished framework changes downstream.
  2. Managed-doc defaults or selftests mismatch downstream reality.
- **Postconditions:** Framework upgrades are more trustworthy and less error-prone.

## Business Scenarios

### BS-001: Evaluator gets a clear adoption answer
Given a technical leader comparing Bubbles against other agent frameworks
When they review Bubbles' competitive and operational guidance
Then they can understand why to choose Bubbles, when not to choose it, and what migration cost to expect

### BS-002: New repo reaches usable state quickly
Given a maintainer bootstrapping Bubbles in a fresh repo
When the install and bootstrap flow completes
Then the maintainer can reach a workable project-ready state without extensive manual placeholder cleanup

### BS-003: Existing rule investment is not wasted
Given a repo already using another tool's rules or custom modes
When the team adopts Bubbles
Then they can import, translate, or coexist with that existing guidance rather than rewriting everything manually

### BS-004: Framework health and repo-readiness are clearly distinct
Given a maintainer checking whether a repo is safe to use with Bubbles
When they run framework and repo-readiness surfaces
Then they can distinguish advisory hygiene gaps from actual framework validation or delivery certification

### BS-005: Public docs do not overstate missing or shipped capabilities
Given a maintainer reading Bubbles issue and framework docs
When a capability has already shipped or is still incomplete
Then public artifacts clearly reflect that current truth without stale contradictions

### BS-006: Upgrade path preserves trust in framework-managed files
Given a downstream repo consuming a new Bubbles release
When framework-managed files are refreshed
Then the maintainer can verify integrity, understand overrides, and avoid patching installed framework files manually

## UI Scenario Matrix
| Scenario | Actor | Entry Point | Steps | Expected Outcome | Screen(s) |
|----------|-------|-------------|-------|------------------|-----------|
| Compare Bubbles with competitors | Platform Evaluator | README / docs landing page | Open comparison docs, scan quick matrix, inspect deeper comparison docs | Value proposition and tradeoffs are easy to understand | README, competitive docs, recipes/guides |
| Bootstrap and verify a repo | Downstream Repo Maintainer | Installation guide / CLI | Install, bootstrap, run readiness and framework health checks | Maintainer knows next actions and ownership boundaries | Installation docs, CLI outputs |
| Import prior rule assets | Downstream Repo Maintainer | Framework ops or migration surface | Select source tool, import assets, review mapped outputs | Existing rules are converted or coexist safely | CLI or docs-guided migration flow |
| Inspect upgrade confidence | Framework Maintainer / Downstream Maintainer | Release docs / framework ops | Review release notes, run checks, inspect managed-doc registry and write guard | Upgrade trust is explicit and actionable | Changelog, install docs, framework-ops docs |

## Improvement Proposals

### IP-001: Bubbles Lite Onboarding Path
- **Impact:** High
- **Effort:** M
- **Competitive Advantage:** Narrows the biggest adoption gap versus Cursor, Roo, Claude Code, and Cline while preserving an upgrade path into full governance.
- **Actors Affected:** Downstream Repo Maintainer, Delivery Engineer, Platform Evaluator
- **Business Scenarios:** BS-001, BS-002

### IP-002: Cross-Framework Rule And Mode Interoperability
- **Impact:** High
- **Effort:** L
- **Competitive Advantage:** Gives Bubbles a migration wedge instead of forcing greenfield adoption.
- **Actors Affected:** Downstream Repo Maintainer, Platform Evaluator
- **Business Scenarios:** BS-001, BS-003

### IP-003: Source-To-Downstream Confidence Pipeline
- **Impact:** High
- **Effort:** M
- **Competitive Advantage:** Turns Bubbles' internal rigor into externally visible trust, especially during upgrades.
- **Actors Affected:** Framework Maintainer, Downstream Repo Maintainer
- **Business Scenarios:** BS-004, BS-006

### IP-004: Competitive Positioning And Benchmark Evidence Pack
- **Impact:** High
- **Effort:** M
- **Competitive Advantage:** Makes Bubbles easier to evaluate and defend internally.
- **Actors Affected:** Platform Evaluator, Framework Maintainer
- **Business Scenarios:** BS-001

### IP-005: Framework Freshness And Known-Issue Hygiene
- **Impact:** Medium
- **Effort:** M
- **Competitive Advantage:** Keeps Bubbles credible as a framework that enforces on itself what it asks from downstream repos.
- **Actors Affected:** Framework Maintainer, Platform Evaluator
- **Business Scenarios:** BS-005, BS-006

### IP-006: Maturity-Tier Governance Profiles
- **Impact:** Medium
- **Effort:** L
- **Competitive Advantage:** Lets teams adopt Bubbles progressively instead of all-or-nothing.
- **Actors Affected:** Downstream Repo Maintainer, Delivery Engineer
- **Business Scenarios:** BS-002, BS-004

## Recommended Program Roadmap

### Phase 1: Trust And Truth Foundations
- Reconcile public docs, issue surfaces, and shipped framework behavior so Bubbles' own public truth is fresh.
- Add source-to-downstream confidence artifacts for install provenance, release manifests, and clearer downstream verification.
- Publish clearer competitive positioning and value narrative for evaluators.

### Phase 2: Adoption Friction Reduction
- Introduce a Bubbles Lite onboarding/profile path that preserves full-governance upgradeability.
- Reduce bootstrap placeholder debt and improve post-install guidance sequencing.
- Make framework health, repo-readiness, and upgrade confidence easier to understand distinctly.

### Phase 3: Interoperability And Migration
- Add intake and translation support for competitor rule and mode assets.
- Define coexistence and precedence behavior for imported assets versus Bubbles-owned artifacts.
- Publish migration guidance for common source ecosystems.

### Phase 4: Progressive Governance And Team Scale
- Add maturity-tier governance profiles with identical core invariants and different activation envelopes.
- Strengthen downstream compatibility testing in source-repo CI.
- Publish benchmarks and adoption case studies that prove Bubbles' rigor has operational payoff.

## Issue Proposal Candidates

### ISSUE-001: Public Capability Freshness Reconciliation
- **Problem:** Shipped framework capabilities and issue/docs surfaces can diverge, reducing trust.
- **Target Outcome:** Public docs and issue files clearly distinguish proposed, partial, and shipped behavior.
- **Likely Owners:** Framework Maintainer, `bubbles.docs`, framework ops surfaces.

### ISSUE-002: Source-To-Downstream Release Trust Manifest
- **Problem:** Users lack an obvious trust chain from source-repo release quality to downstream install confidence.
- **Target Outcome:** Release artifacts expose provenance, self-check coverage, and downstream verification steps.
- **Likely Owners:** Framework Maintainer, `bubbles.devops`, framework ops surfaces.

### ISSUE-003: Bubbles Lite Bootstrap Profile
- **Problem:** First-run adoption is too heavy for many repos evaluating Bubbles.
- **Target Outcome:** A lighter entry path reaches usable state faster without creating a separate governance fork.
- **Likely Owners:** Framework Maintainer, install/bootstrap surfaces, workflow/profile registry.

### ISSUE-004: Cross-Framework Rule Intake And Translation
- **Problem:** Teams with existing rule/mode investments face high migration friction.
- **Target Outcome:** Bubbles can import or map common external rule and mode assets into project-owned intake surfaces.
- **Likely Owners:** Framework Maintainer, interoperability surfaces, framework ops.

### ISSUE-005: Competitive Benchmark And Evaluation Pack
- **Problem:** Bubbles' strengths are not packaged into simple evaluation material.
- **Target Outcome:** Evaluators can compare Bubbles against competitors quickly using clear benchmark and fit criteria.
- **Likely Owners:** Framework Maintainer, docs, benchmark/reporting surfaces.

### ISSUE-006: Maturity-Tier Governance Profiles
- **Problem:** The current path to full rigor is powerful but can feel all-or-nothing.
- **Target Outcome:** Teams adopt Bubbles progressively with explicit profile semantics and no weakened certification truth.
- **Likely Owners:** Framework Maintainer, policy registry, workflow modes, validate-compatible rollout.

## Non-Functional Requirements
- Adoption friction must measurably decrease for first-run downstream setups.
- Interoperability features must not weaken artifact ownership or validate-owned certification.
- Public docs and issue surfaces must be freshness-checked against shipped framework behavior.
- Competitive comparison material must be concise enough for executive evaluation and specific enough for technical trial planning.
- Any new automation for migration, readiness, or upgrade trust must fail loudly instead of silently masking unsupported cases.