# Bubbles Overview Voiceover Transcript

Voice: en-US-AndrewMultilingualNeural
Pipeline: edge-tts -> WAV PCM intermediate -> single AAC pass at the end. No loudnorm.

## 01. Done Is The Most Expensive Word In Software

Rate: -2%

Here is the problem. Done is the most expensive word in software. AI made it cheap to say. It did not make it cheap to verify. An agent finishes. The summary sounds complete. Then a user finds the part that broke, and the team spends the next day untangling it. Bubbles closes that gap by replacing trust with structure: specs as the source of truth, mechanical gates that block bad transitions, and raw evidence on every checkbox. Here is what that means for your role.

## 02. Stop Debugging Your Own AI

Rate: -2%

If you are a developer, here is what changes. The agent has to prove the work. Every Definition of Done item needs ten lines of real terminal output, tagged with the phase that produced it. A state transition guard runs around twenty mechanical checks before any status can flip to done. An implementation reality scan rejects stubs, hardcoded data, and fake responses. A regression quality guard rejects bug-fix tests that would still pass with the bug back in. When something fails, the agent gets three retries with narrowing context, then it has to escalate. No infinite loops. You stop debugging the AI and start reading the receipts.

## 03. Track Artifacts, Not Confidence

Rate: -2%

If you manage the product, here is what changes. You stop reading status from chat and start reading it from artifacts. Every feature carries six required documents. The spec, the design, the scopes, the report, the user validation list, and a machine-readable state file. No artifact, no implementation. Every spec declares an outcome contract: what the user should be able to do, the signal that proves it works, the constraints that must hold, and what would make it a failure even if every test passed. Every requirement traces through a Gherkin scenario to a test plan to an end-to-end test to a checked Definition of Done item. When a user unchecks an item in the validation list, that is a regression report, and the workflow has to address it before new work proceeds.

## 04. Ship Features That Survive Real Users

Rate: -2%

If you own the product, here is the bar. A demo is not a launch. A passing test suite is not a product. The contract is the experience the user actually gets. Bubbles keeps that contract honest over time. Code review and system review give you diagnosis without dragging you into the gated lifecycle. Spec review flags drift the moment a doc no longer matches the code. Retro tracks what we call the slop tax: scope reopens, phase retries, post-validate reversions, fix-on-fix chains. The target is under fifteen percent. Old requirements move into a clearly labeled superseded section. The capability ledger is the single source of truth for what is actually shipped. Your release notes stop being apologies.

## 05. You Do Not Need A Smarter Agent. You Need A Stricter Loop.

Rate: -1%

Here is the shift. You do not need a smarter agent. You need a stricter loop. And you get to choose how much of the loop you run yourself. Basic mode: you call one specialist at a time. Implement, test, audit, docs. You drive the sequence. Coordinator mode: one command, slash bubbles workflow, picks the right specialist chain for the job, runs every phase in order, and enforces every gate. Super agents take the wheel: slash bubbles goal converges on a single outcome, slash bubbles sprint takes a list of goals plus a time budget and works the whole list autonomously. Same evidence chain runs underneath all three. Choosing more autonomy never lowers the bar.

## 06. Every Claim Points At A Receipt

Rate: -1%

Now the developer detail. Bubbles uses one chain that runs in both directions. Every requirement traces forward into a Gherkin scenario, into a test plan row, into a Definition of Done item, into raw terminal output. And every piece of evidence traces backward to the requirement it proves. There are no orphan tests. There are no orphan checkboxes. There are no orphan claims. When a test fails, you can see which requirement is at risk. When a requirement changes, you can see which tests have to move with it. The chain replaces the stack of stale documents most teams quietly tolerate.

## 07. Specialists With Declared Lanes

Rate: -1%

Bubbles ships with around forty specialist agents. Each one declares the artifacts it owns and the phases it runs. The analyst owns the requirements section of the spec. The designer owns the design doc. The planner owns the scope decomposition. The implementer owns the code. The tester owns the test pass. The auditor signs off. Ownership lives in configuration, not in conversation, so handoffs route by capability instead of by whichever agent happened to answer first. Adding a new specialist or a new workflow mode is a YAML edit. The framework reads it on the next run. No code change. No release.

## 08. Scopes That Do Not Collide

Rate: -1%

Scopes are how Bubbles handles the realistic case where one feature has multiple parallel slices. When a feature has six or more scopes, the framework flips into per-scope directory mode automatically. Each scope gets its own folder, its own Definition of Done, its own report file, and its own evidence trail. The owning agent works inside that lane and only that lane. Two agents on two different scopes cannot pollute each other's status or overwrite each other's evidence. A scope can be marked Done the moment its own evidence chain is complete. The spec status rolls up from the underlying scopes, not from a separate hand-maintained tracker. Parallel work stops being a coordination problem. It becomes a directory layout.

## 09. Pre-Built Sequences For The Work You Already Do

Rate: -1%

Recipes are pre-built sequences for work you already do every week. Fix-a-bug runs discovery, root cause analysis, a spec-driven fix, and an adversarial regression test that would actually fail if you reintroduced the bug. No tautological green checks. New-feature runs the outcome contract, scope decomposition, implementation, real tests, audit, and docs in one chain. Spec-freshness-review classifies every spec as fresh, drifted, stale, or superseded so downstream agents stop trusting documents that no longer match the code. Post-implementation hardening sweeps the recently changed files for stubs, coverage gaps, and policy violations before they reach a user. Autonomous sprint takes a list of goals and a time budget and works the whole list to convergence, prioritizing by impact and effort. You pick the recipe. The framework runs the right specialists in the right order under the same evidence rules.

## 10. Tests That Actually Mean Something

Rate: -1%

Bubbles classifies tests into eight named categories: unit, functional, integration, user-interface unit, end-to-end API, end-to-end UI, stress, and load. Each category has explicit rules. Live test categories run against the real running stack. Internal mocks are forbidden inside them, because a mocked test labelled as live is a silent lie that fails in production. Bug-fix tests have to include at least one adversarial case: a scenario that would actually fail if you reintroduced the bug. No tautological green checks that would pass either way. Behind all of it, an implementation reality scan rejects stub data, hardcoded responses, and fake handlers before they reach a user. Tests stop being a green light you negotiate with the agent. They become a gate the agent cannot fake.

## 11. The Loop Is The Differentiator. Not The Model.

Rate: -1%

Why this holds up over time has very little to do with the model behind it. It is the loop. The gates are mechanical scripts, not gentle conventions you have to remember. They run the same way at three in the morning as they do during a code review. Ownership is declared, not negotiated, so handoffs do not depend on who is talking or how persuasive the summary sounds. Evidence is raw terminal output, not a polished narrative, so the loop cannot quietly lie its way to done. If the output is missing, the gate blocks. Self-healing is capped at three retries per phase and five per workflow, so a stuck workflow escalates to you instead of burning the rest of your day in a private loop. Adding a new specialist, a new workflow mode, a new gate, or a new recipe is configuration, not framework code, so the framework grows with your repo instead of forcing your repo to grow into it. Swap the model later. Swap the team later. The bar does not move.

## 12. One Painful Outcome. End To End. Inspect The Trail.

Rate: -1%

If you take one thing from this video, take this. Pick one painful outcome and run it end to end. Install Bubbles in a repo where AI work needs more discipline. Bootstrap it. Run slash bubbles workflow on one real bug, feature, or cleanup. Then read the artifacts and the evidence. Do not judge it on the final cheerful answer. Judge it on the trail it left behind. If the trail is honest, you have your answer.
