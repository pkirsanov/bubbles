# Bubbles Practical Synthetic Walkthrough Transcript

Voice: en-US-BrianNeural
Demo data: synthetic pocket-crm-demo project and synthetic Bubbles artifacts.
Captions: English full narration captions plus Spanish and Russian scene-summary captions.

## 01. From Blank Repo To Verified Result

Rate: -4%

This is a practical walkthrough, not a real customer project. The repo is synthetic. The bug is synthetic. The artifacts are synthetic. That is on purpose. We are going to show the shape of a Bubbles workflow from setup to actual result: commands, responses, generated artifacts, tests, validation, and final evidence. The example is a tiny product called pocket CRM demo, where the email retry button spins forever if the provider times out. Small bug. Realistic pain. Perfect little clipboard exercise.

## 02. Start With A Small Synthetic Repo

Rate: -5%

We start with a small repo. Not an enterprise space station. Just a web UI, an API, and a test folder. The product sends follow-up emails from a contact record. The bug is simple: if the email provider times out, the retry button keeps spinning forever. Users do not see a clear status. Sometimes the action queues twice. The desired result is also simple: the button recovers, the status is visible, and retry is queued exactly once. Notice the phrasing. We are already thinking in user-visible behavior, not just code changes.

## 03. Install And Bootstrap Bubbles

Rate: -5%

Next, install and bootstrap. The exact install command depends on how you distribute Bubbles in your environment, so this panel shows the shape, not a live download. After setup, the repo has the local Bubbles layer: agents, prompts, instructions, skills, templates, workflow scripts, and governance checks. Then run doctor. The important habit is boring but useful. Before asking the framework to guide real work, confirm that the framework surface is present and healthy. Exciting setup usually means somebody is about to lose an afternoon.

## 04. Ask Super If You Do Not Know The Route

Rate: -4%

If you do not know which route to take, ask super. Super is the first-touch assistant for Bubbles questions, agent selection, commands, recipes, setup, and recovery. In this synthetic example, we say: fix the retry spinner bug, and I need proof. Super recommends slash bubbles dot workflow, with a bugfix fastlane style path, because this is not just a question. We need artifacts, a fix, tests, validation, and evidence. That is bigger than one quick review. That is workflow territory.

## 05. Run Workflow With The Real User Problem

Rate: -5%

Now run workflow with the actual user problem. Do not start with, change this handler. Start with the behavior. Email retry spins forever after timeout. Expected result: recover, show status, queue once. The workflow resolves a bugfix route and creates a synthetic feature or bug folder. Then it starts in the right order: analysis, design, planning. That is the point. Bubbles tries to understand what must be true before it starts flinging code around the park.

## 06. Spec Captures The Outcome Contract

Rate: -6%

The first important artifact is the spec. In this synthetic example, the spec captures an outcome contract. Intent: retry recovers after timeout. Success signal: the user sees queued once. Hard constraint: no duplicate retry job. Failure condition: spinner remains after timeout. That is more useful than, fix the button. It gives tests and implementation something concrete to satisfy. Bubbles wants requirements to be observable. If nobody can prove the outcome, the outcome is probably fog wearing a hat.

## 07. Design Names The Safe Fix Shape

Rate: -6%

Next, design names the safe fix shape. This is where the workflow stops the agent from doing the classic thing: hiding the spinner and calling it fixed. The design identifies the timeout boundary around the email client call. It defines idempotency using contact ID and template ID, so repeated clicks do not queue duplicate jobs. It names UI state transitions: sending, timeout, retryable, queued, failed. Now the implementation has rails. It is not just a patch. It is a behavior change with failure handling.

## 08. Plan Slices The Work Into Proveable Scopes

Rate: -5%

Then plan slices the work into proveable scopes. Scope one might be retry timeout recovery. It names the scenario, the API test, the UI test, the files likely touched, and the definition of done. This is where Bubbles gets strict again. Every test-plan row needs a matching definition-of-done item. Later, every checked definition-of-done item needs raw evidence. That means the plan is not decorative. It is a contract for how the work will be proven.

## 09. Implementation Changes The Behavior

Rate: -5%

Now implementation can change behavior. In this synthetic diff, the API returns a retryable state when the provider times out. The retry queue uses an idempotency key. The UI stops the spinner, shows retry available, and confirms queued status after retry. Notice what is not happening: the agent is not only changing CSS, and it is not only changing an API branch. The vertical slice matters. The user-visible fix crosses UI, API, queue behavior, and tests. This is exactly where Bubbles earns its keep: keeping the whole path in view.

## 10. Run Tests That Can Actually Fail

Rate: -5%

Then run tests that can actually fail. This is not the time for a happy provider response and a victory lap. The regression case simulates the timeout. The API test asserts that duplicate retry attempts queue one job. The UI test asserts the spinner stops after timeout and queued status appears after retry. If the old bug comes back, these tests should get loud. Quiet tests are not polite. They are expensive.

## 11. Report Records Raw Evidence

Rate: -6%

The report records evidence. Not a summary pretending to be evidence. The command, the observed output, the pass count, and the behavior assertion. This is what a reviewer needs later. It is also what the next agent needs after context compaction. When Bubbles says raw evidence, this is the spirit: show what ran, show what passed, and show what user-visible behavior was proven. Anything less is just trust me bro with Markdown formatting.

## 12. Validation Gates Push Back

Rate: -6%

Now validation gates push back. This is the part that makes Bubbles feel strict, and it should. State-transition guard checks whether the work is even allowed to move toward done. Artifact lint checks structure, checkboxes, evidence sections, and required fields. Reality scan looks for stubs and fake implementation. Integration completeness checks wiring. Vertical slice completeness checks frontend-to-backend behavior. If something is missing, the gate fails and routes rework. That is not bureaucracy. That is the system refusing to publish fake done.

## 13. Quality Agents Add Pressure

Rate: -5%

After the fix works, the quality agents add pressure. Chaos tries real-system usage variations around the retry path. Double click. Navigate away. Return. Retry after timeout. Simplify reviews the diff and cleans awkward duplication. Harden checks completion and policy. Security looks for auth, exposure, and risk issues around the retry path. This is how Bubbles avoids the classic delivery pattern where the first implementation technically works, and the second developer quietly inherits a shed full of questionable wiring.

## 14. Docs And Specs Stay In Sync

Rate: -5%

Docs and specs need to stay in sync. The fix is not complete if durable truth still describes the old behavior. In the synthetic response, docs now explain timeout recovery and retry status. The spec outcome contract reflects the final behavior. Spec-review confirms the active truth is current. State records the completed scope. This is not glamorous. It is how future work starts from reality instead of historical fiction.

## 15. The Actual Result Is A Verified User Behavior

Rate: -5%

The actual result is not, code changed. The actual result is verified user behavior. Timeout leads to retry available. Retry leads to queued status. Repeated clicks lead to one queue job, not a tiny job parade. The artifacts show what changed, what ran, what passed, and what risk remains. The final answer can be concise because the proof trail exists. That is the practical Bubbles loop: setup, route, artifacts, implementation, tests, gates, quality pressure, docs, and a result you can inspect.

## 16. Use This Pattern On One Real Workflow

Rate: -4%

Use this pattern on one real workflow. Pick a painful bug, a drifted spec, or a feature where you need more than a cheerful final paragraph. Start with the user-visible outcome. Let Bubbles route the work. Inspect the artifacts. Run the tests and gates. Use the quality agents when the blast radius deserves pressure. Keep docs and specs current. Then judge the result by evidence. Not charm. Not vibes. Evidence. That is the practical move.
