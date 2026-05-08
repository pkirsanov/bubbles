# Bubbles Instructional Guide Voiceover Transcript

Voice: en-US-GuyNeural

## 01. What Bubbles Is

Bubbles is a spec-driven agent orchestration system for VS Code Copilot. Instead of asking one assistant to remember every job, Bubbles routes work through specialists. It can start from a vague sentence, build the required artifacts, run implementation, test, validation, audit, and docs, then leave a paper trail. Think less magic button, more accountable delivery crew with very serious clipboards.

## 02. Modern Agent Work Gets Messy

The problem Bubbles solves is not that agents cannot write code. They can. The problem is operational discipline. A single assistant can skip context, over-trust stale docs, say tests passed without proof, or call a feature complete while scopes still have open work. Bubbles treats that as the real bug. Vibes are not a test runner, and a confident paragraph is not certification.

## 03. Route Work Through Owners

Bubbles solves the mess by giving work a structure. Business analysis, user experience, design, planning, implementation, testing, validation, audit, and docs are separate jobs. Each agent has ownership boundaries. An audit agent can find a problem, but it does not pretend to be the design owner. A validation agent can reopen work, but certification state belongs to validation. That separation prevents artifact wrestling, which is a technical term meaning everybody stop touching the same file at once.

## 04. Install In A Downstream Repo

For a downstream project, installation is intentionally boring. From the target repository, run the installer with bootstrap. Bootstrap detects the project, creates the Copilot instructions, terminal discipline, constitution, command registry, and specs directory when needed. If you are maintaining the Bubbles source repository itself, do not run the installer inside it. Edit the framework directly and validate with the framework commands. Yes, boring is good here. Boring means fewer emergency sandwiches.

## 05. Start With Workflow

The default way to use Bubbles is slash bubbles dot workflow. Describe the outcome. Workflow resolves the intent, asks the supervisor layer for command interpretation when needed, picks the next useful work, and runs the specialist chain. For most requests, you do not need to know whether the right mode is bugfix fastlane, full delivery, improve existing, or validate only. Workflow handles the routing so you can focus on what you want done.

## 06. Use Specialists Directly When The Job Is Narrow

You can also run individual specialists. Use analyst when you want business requirements, actors, use cases, competitive gaps, or scenario discovery. Use plan when a spec and design need executable scopes, Gherkin scenarios, test plans, and definitions of done. Use test when you need verification and gap fixing. The trick is to use direct specialists for narrow work. If the work crosses phases, go back to workflow and let the coordinator drive.

## 07. Coordinator Agents Keep Work Moving

Coordinator agents are different from owner agents. They keep work moving, but they do not own every artifact. Workflow is the front door. Iterate chooses the next executable slice when you are already in motion. Bug handles defect discovery, reproduction, packet creation, routing, and closure. That means less manual traffic control. Nobody has to stand in the hallway yelling, who owns this? The answer is in the system. Usually on a clipboard.

## 08. Goal, Sprint, And Release

For larger work, Bubbles has higher-level controllers. Goal is for one outcome: a feature, bug, operations task, or hardening objective. It plans, implements, tests, validates, and loops until convergence or a real blocker. Sprint accepts multiple goals and a time budget, then prioritizes and executes. Releases creates phase release packets, carry-forward plans, and cross-product coordination. Use these when the work is bigger than one specialist but still needs accountable structure.

## 09. Bubbles Is An Artifact System

Structurally, Bubbles is an artifact system. Work lives under feature or bug folders. The spec states the outcome and business behavior. The design explains the technical approach. Scopes define executable slices, scenarios, test plans, and definitions of done. The report captures execution evidence. User validation remains the human acceptance surface. State tracks workflow and certification metadata. If those files disagree, Bubbles treats it as drift, not as a fun little mystery.

## 10. Modes Encode Delivery Shape

Workflow modes encode the shape of delivery. Full delivery is the broad, maximum-assurance path. Bugfix fastlane focuses on reproduction, repair, regression, validation, and audit. Improve existing reconciles stale truth before changing a feature. Docs only and validate only cap what the agent is allowed to do. This matters because a documentation pass should not secretly become a production rewrite. That is how software gets a fake mustache and sneaks into release notes.

## 11. 65 Gates Say: Prove It

The gates are where Bubbles gets strict. There are gates for required artifacts, design readiness, test integrity, raw evidence, documentation sync, validation, audit, implementation reality, vertical slice completeness, scenario contracts, outcome contracts, and workflow consistency. The short version is simple: if an agent says a thing is done, Bubbles asks for proof. If proof is missing, the answer is no. Not maybe. Not good enough. Just no.

## 12. Evidence Beats Narration

Validation is where Bubbles separates execution claims from certification authority. A specialist may say it ran tests. The report must show real output. State execution can record runtime claims. Certification belongs to validate. A checked definition-of-done item without evidence is invalid. A spec with unfinished scopes cannot be done. If all of that sounds strict, excellent. The whole point is to make fake progress more expensive than real progress.

## 13. Scenarios Become Contracts

Scenario contracts are one of the most important structural ideas. Bubbles wants user-visible behavior written as scenarios, then tied to tests and evidence. The scenario manifest keeps stable identifiers for changed behavior, so validation can replay or verify the linked proof. Regression contracts stop agents from quietly weakening old behavior to make new work pass. In other words, no moving the goalposts while the referee is looking at the sandwich table.

## 14. What Bubbles Refuses

Bubbles refuses a few tempting shortcuts. It rejects fabricated evidence, batch-checked definitions of done, silent test skips, TODO confetti, stubs pretending to be implementation, and diagnostic agents editing artifacts they do not own. This is not bureaucracy for sport. It is a defense against the exact failure mode where an assistant sounds helpful while quietly leaving the system less trustworthy. A charming mess is still a mess.

## 15. Pick The Right Size Tool

A practical rule: choose by blast radius. For a narrow diagnostic or artifact update, run the specialist. For a feature, bug, validation pass, or documentation loop, use workflow. For bigger outcomes, use goal, sprint, or releases. If you are unsure, start with workflow. It can route smaller. Starting with a giant autonomous sprint for a two-line question is how you end up with a parade permit and no parade.

## 16. Bubbles Makes Work Accountable

That is Bubbles: a structured way to turn agent assistance into accountable software work. It gives you installable framework files, named specialists, workflow modes, artifacts, gates, scenario contracts, validation, and certification. It does not remove engineering judgment. It gives judgment a safer loop to operate in. Start with workflow, keep the evidence real, and let the crew do the jobs they actually own.
