#!/usr/bin/env python3
"""Render an expanded YouTube-style Bubbles guide focused on gates and quality agents."""

from __future__ import annotations

import argparse
import asyncio
import subprocess
import sys
import tempfile
from pathlib import Path

import render_bubbles_youtube_infoguide as base

VOICE = "en-US-BrianNeural"
VOICE_VOLUME = "+0%"
SCENE_PAD_SECONDS = 0.72
AUDIO_BITRATE = "320k"
AUDIO_SAMPLE_RATE = "48000"
VIDEO_CRF = "14"
VIDEO_PRESET = "slow"
LOUDNESS_FILTER = "loudnorm=I=-16:TP=-1.5:LRA=11"

Scene = base.Scene

SCENES: tuple[Scene, ...] = (
    Scene(
        eyebrow="COLD OPEN",
        title="Stop Accepting AI Vibes As Delivery",
        subtitle="If the agent says done, Bubbles politely asks for the keys, the receipt, and the incident report.",
        bullets=(
            "AI can generate a lot of work before anyone proves it helped.",
            "Bubbles turns confident output into traceable, testable delivery.",
            "This cut is the park tour: gates, quality agents, reviews, docs, retro, and recipes.",
        ),
        board_lines=(
            "HOOK:",
            "Fast output is nice.",
            "Verified output is useful.",
            "Bubbles makes the second one happen.",
        ),
        narration=(
            "Okay. Cold open. If an AI agent has ever produced three screens of confident final answer, and then you found out the test was fake, the docs were stale, and the endpoint existed only in the agent's imagination, welcome. This is your video. "
            "Bubbles is not here to make AI sound more impressive. We already have enough impressive-sounding nonsense. Bubbles is here to make AI coding work leave receipts. "
            "So in this version we are going deeper: gates, quality agents, review agents, docs, spec freshness, retros, hotspots, recipes, and the super agent you ask when you do not know which clipboard to grab."
        ),
        bg="0x101722",
        accent="0x39d0c8",
        voice_rate="-4%",
    ),
    Scene(
        eyebrow="WHAT IT IS",
        title="Bubbles Is The Work System Around Copilot",
        subtitle="Copilot writes and reasons. Bubbles gives the work structure, ownership, evidence, and review pressure.",
        bullets=(
            "Specialist agents own different jobs instead of one chat pretending to be everyone.",
            "Workflow modes move work through analysis, design, planning, implementation, validation, and audit.",
            "Artifacts keep durable truth across long sessions and context resets.",
        ),
        board_lines=(
            "37 specialist agents",
            "34 workflow modes",
            "65 gates",
            "26 phases",
            "1 big idea: accountable work",
        ),
        narration=(
            "Bubbles is a spec-driven AI agent orchestration system for VS Code Copilot Chat. Less fancy version: it is the work system around Copilot. "
            "Copilot can reason, write, search, and edit. Bubbles adds role separation, workflow modes, artifacts, gates, reviews, validation, and certification. "
            "It is the difference between asking one helpful person to be analyst, architect, tester, security reviewer, project manager, and release lead, versus giving the job to an organized crew with rules. Still AI. Fewer mystery puddles on the floor."
        ),
        bg="0x0f1d26",
        accent="0x58a6ff",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="THE GATE BOOTH",
        title="Strict Validation Is The Main Character",
        subtitle="The gates are not decoration. They are the permit booth between nice story and trusted work.",
        bullets=(
            "Gates block fake completion, missing evidence, stale artifacts, and weak tests.",
            "They check status transitions, all-scopes-done rules, and per-DoD raw evidence.",
            "They also inspect implementation reality, integration completeness, and vertical slice wiring.",
        ),
        board_lines=(
            "Gate examples:",
            "G023 state transition guard",
            "G024 all scopes done",
            "G025 per-DoD evidence",
            "G028 reality scan",
            "G029 integration complete",
            "G035 vertical slice",
        ),
        narration=(
            "Let's put the gates in the center, because they are the main character. Bubbles gates are not little badges you admire after the work is done. They are the permit booth. "
            "State transition guard checks whether status can move. All-scopes-done prevents a spec from pretending it is complete while scopes are still open. Per-DoD evidence says every checked item needs raw output, not a bedtime summary. "
            "Then the deeper gates start asking rude but necessary questions. Does the implementation contain stubs or hardcoded pretend data? Are endpoints wired into real consumers? Does the frontend call a backend route that actually exists? These gates are why Bubbles feels strict. And honestly, good. The repo needed adult supervision."
        ),
        bg="0x24151a",
        accent="0xff7b72",
        voice_rate="-7%",
    ),
    Scene(
        eyebrow="EVIDENCE RULES",
        title="A Checked Box Without Output Is Just Confetti",
        subtitle="Bubbles wants raw terminal output, real test execution, and scenarios that can fail.",
        bullets=(
            "Evidence must come from actual execution in the current session.",
            "Required test evidence needs raw output, not a rewritten victory paragraph.",
            "Regression tests must be adversarial enough to catch the old bug coming back.",
        ),
        board_lines=(
            "Not enough:",
            "tests pass trust me",
            "Enough:",
            "command",
            "exit code",
            "raw output",
            "behavior asserted",
        ),
        narration=(
            "The evidence rule is simple and slightly annoying, which is how you know it works. If a box is checked, where is the output? If a test passed, what command ran? If the bug is fixed, what adversarial case would fail if the bug returned? "
            "Bubbles is allergic to narrative evidence. It does not want, all good, boss. It wants the command, the exit code, the raw output, and the behavior that proves the scenario. "
            "That pressure changes how agents behave. They stop optimizing for sounding done and start optimizing for being verifiably done. Huge difference. Same keyboard. Better adult supervision."
        ),
        bg="0x251414",
        accent="0xf85149",
        voice_rate="-6%",
    ),
    Scene(
        eyebrow="QUALITY SUITE",
        title="Chaos, Simplify, Harden, Gaps, And Security",
        subtitle="This is the group you call when the feature says it is done but still smells like wet plywood.",
        bullets=(
            "chaos runs stochastic real-system usage to expose brittle paths and race conditions.",
            "simplify cleans up the implementation after the feature works.",
            "harden, gaps, and security pressure-test completion, missing work, and risk.",
        ),
        board_lines=(
            "Quality suite:",
            "chaos: random real usage",
            "simplify: clean the diff",
            "harden: prove complete",
            "gaps: find missing pieces",
            "security: threat + auth review",
        ),
        narration=(
            "Now, the quality suite. This is the crew you call after the first implementation says it is done, but the floor still makes a suspicious noise. "
            "Chaos runs random and semi-random real-system usage to find brittle paths, timing bugs, race conditions, and workflow weirdness. Simplify reviews recent implementation and trims duplication, awkward abstractions, and code that got a little too excited. "
            "Harden goes deep on completion. Gaps hunts missing requirements and unfinished vertical slices. Security looks at threat models, auth, dependencies, and compliance risk. Put together, this group turns, seems fine, into, we actually kicked the tires."
        ),
        bg="0x17251f",
        accent="0x3fb950",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="CHAOS AGENT",
        title="Chaos Is Not Random For Fun",
        subtitle="It acts like a user with caffeine, impatience, and absolutely no respect for your happy path.",
        bullets=(
            "It runs single actions and chained journeys against the real system.",
            "It catches brittle UI/API paths that scripted happy paths miss.",
            "It is especially useful after checkout, auth, onboarding, scheduling, and multi-step flows.",
        ),
        board_lines=(
            "Chaos checks:",
            "click around",
            "change order",
            "repeat actions",
            "race timing",
            "leave and return",
            "look for cracks",
        ),
        narration=(
            "Chaos sounds theatrical, but the idea is practical. Users do not follow your perfect demo script. They click things twice. They go backward. They refresh during a save. They open two tabs and create a small weather system. "
            "The chaos agent runs stochastic and semi-random real-system behavior, both single actions and chained journeys. It is not randomness for comedy, although comedy may occur. It is pressure on the paths your scripted tests forgot. "
            "Use it after important flows: checkout, authentication, onboarding, scheduling, anything with state, timing, or a user who might reasonably behave like a person."
        ),
        bg="0x102033",
        accent="0x58a6ff",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="HARDEN AND GAPS",
        title="Harden Asks If Done Means Done",
        subtitle="Gaps asks what everyone politely failed to mention.",
        bullets=(
            "harden validates all tasks, tests, policies, and completion claims with zero exception energy.",
            "gaps compares design, requirements, implementation, and tests to find missing pieces.",
            "Together they are excellent at turning vague discomfort into a fixable list.",
        ),
        board_lines=(
            "harden:",
            "completion pressure",
            "policy pressure",
            "test pressure",
            "gaps:",
            "what is missing?",
            "what drifted?",
        ),
        narration=(
            "Harden and gaps are the agents for that moment when everything looks complete, but your engineering instincts are making the old van door noise. "
            "Harden checks that tasks are actually complete, tests pass, policies were followed, and completion claims survive pressure. It is not there to be charming. Gaps compares requirements, design, code, tests, and docs to find missing pieces. "
            "Together they turn unease into a concrete list: missing scenario, weak test, stale spec, unwired endpoint, skipped validation, half-finished UI. You know, the stuff that likes to wait until production has snacks."
        ),
        bg="0x191d23",
        accent="0xf2cc60",
        voice_rate="-6%",
    ),
    Scene(
        eyebrow="SIMPLIFY",
        title="Simplify Cleans Up After The Sprint Brain",
        subtitle="Working code is good. Understandable working code is better. Future-you is the stakeholder.",
        bullets=(
            "It reviews recently changed files for duplication, rough abstractions, and inefficient patterns.",
            "It fixes cleanup opportunities after behavior is already proven.",
            "It protects velocity by reducing the mess that makes the next change expensive.",
        ),
        board_lines=(
            "Simplify looks for:",
            "duplication",
            "clever knots",
            "bloated functions",
            "awkward ownership",
            "reuse opportunities",
        ),
        narration=(
            "Simplify is underrated. After a feature works, the code often has sprint brain. It is technically alive, but it may be wearing two jackets and carrying a toaster. "
            "The simplify agent reviews recently changed files for duplication, poor reuse, awkward abstractions, bloated functions, and inefficient patterns. Then it fixes the cleanup while the context is fresh. "
            "That matters because velocity is not just how fast you write the first version. It is how expensive the second and third versions become. Simplify is how you avoid making future-you pay rent on today's mess."
        ),
        bg="0x181f2b",
        accent="0xffa657",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="SECURITY",
        title="Security Is Not A Sticker At The End",
        subtitle="It reviews threat models, auth paths, dependencies, exposure, and compliance before optimism gets expensive.",
        bullets=(
            "Security focuses on threat modeling, dependency scanning, code security review, and auth verification.",
            "It is useful for new endpoints, auth changes, sensitive data, deployment, and public surfaces.",
            "It keeps safety review in the same workflow trail as implementation evidence.",
        ),
        board_lines=(
            "Security asks:",
            "who can call this?",
            "what data moves?",
            "what can be abused?",
            "what changed exposure?",
            "what dependency risk?",
        ),
        narration=(
            "Security in Bubbles is not a sticker you slap on after the demo. It is an agent with a job: threat modeling, dependency scanning, code security review, authentication checks, compliance concerns, and exposure review. "
            "Use it when you add endpoints, change auth, touch sensitive data, ship deployment surfaces, or create public workflows. Basically, use it before optimism gets expensive. "
            "The nice part is that security review becomes part of the same evidence trail. Not a separate foggy meeting. Not a doc nobody links. It sits with the work, where future reviewers can find it."
        ),
        bg="0x202033",
        accent="0xd2a8ff",
        voice_rate="-6%",
    ),
    Scene(
        eyebrow="REVIEW AGENTS",
        title="Code Review, System Review, And Spec Review",
        subtitle="Three different flashlights. Please do not use the product flashlight for a code-only basement problem.",
        bullets=(
            "code-review is engineering-first: bugs, risks, regressions, tests, and code paths.",
            "system-review is holistic: product, UX, runtime behavior, trust, and coherence.",
            "spec-review checks whether specs are stale, drifted, redundant, or still trustworthy.",
        ),
        board_lines=(
            "***-review family:",
            "code-review: engineering",
            "system-review: whole product",
            "spec-review: artifact freshness",
            "reviews first, summaries second",
        ),
        narration=(
            "The review agents matter because not every review is the same. Code-review is engineering-first. It looks for bugs, behavioral regressions, missing tests, risky code paths, and security-ish smells in the code. Findings first. Summary later. Good. "
            "System-review zooms out. It looks at product behavior, UX, runtime trust, simplification, and whether the whole thing coheres. Spec-review checks whether your specs are still reliable or if the code has drifted past them while nobody was watching. "
            "That separation is important. Use the right flashlight. If you bring a whole-system product review to a two-line parser bug, everybody gets tired. If you bring a code-only review to a broken user journey, you miss the point."
        ),
        bg="0x0e2630",
        accent="0x39d0c8",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="DOCS AND SPECS",
        title="Docs And Specs Must Stay Alive",
        subtitle="A stale spec is a ghost with headings. Bubbles has agents to keep the ghosts out of the office.",
        bullets=(
            "docs aligns durable documentation with execution truth instead of old intentions.",
            "spec-review classifies stale or drifted specs so agents know what to trust.",
            "Analyst, design, plan, and docs ownership prevents one agent from rewriting every truth surface casually.",
        ),
        board_lines=(
            "Freshness loop:",
            "spec says intent",
            "design says shape",
            "scopes say work",
            "report says evidence",
            "docs publish truth",
            "spec-review catches drift",
        ),
        narration=(
            "Docs and specs are not paperwork in Bubbles. They are memory. They are the reason a long project does not become a campfire story with YAML. "
            "The docs agent keeps managed docs current, deduplicated, and aligned with execution truth. Spec-review checks whether specs are stale, obsolete, redundant, or drifted from the code. Analyst, design, plan, docs, and validation each own different surfaces so one agent does not casually rewrite the whole town charter because it got enthusiastic. "
            "This is how Bubbles keeps specs alive. Not perfect. Alive. That is the useful part."
        ),
        bg="0x14231c",
        accent="0x3fb950",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="RETRO",
        title="Retro Finds The Hotspots Nobody Wants To Name",
        subtitle="It is not a feel-good meeting. It is a map of where work keeps getting expensive.",
        bullets=(
            "retro tracks velocity patterns, gate health trends, and recurring failure modes.",
            "hotspot analysis finds code areas with churn, coupling, complexity, and repeated pain.",
            "It turns project memory into better priorities instead of just more heroic debugging.",
        ),
        board_lines=(
            "Retro features:",
            "velocity metrics",
            "gate health trends",
            "hotspot analysis",
            "coupling detection",
            "shipping patterns",
            "repeat-failure clues",
        ),
        narration=(
            "Retro is where Bubbles becomes a little more strategic. It is not just, how did everyone feel about the sprint, please choose an emoji. No. Retro looks at velocity metrics, gate health trends, shipping patterns, code hotspots, architectural coupling, and repeated failure areas. "
            "Hotspot analysis is especially useful. It asks where the repo keeps charging you extra. Which files churn? Which modules attract bugs? Which workflows keep failing gates? Which areas create review drag? "
            "That lets you improve the system, not just survive the next ticket. Very rude to the old chaos. Very helpful to the future."
        ),
        bg="0x111827",
        accent="0xffa657",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="SUPER AND RECIPES",
        title="Ask Super When You Do Not Know The Move",
        subtitle="Sometimes the best first step is asking the framework which first step is not ridiculous.",
        bullets=(
            "super is the universal first-touch assistant for Bubbles questions and workflow guidance.",
            "It helps with agents, commands, recipes, setup, upgrades, and behind-the-scenes platform advice.",
            "Recipes make repeatable patterns easier: bugfix fastlane, validation loops, release packets, hardening passes.",
        ),
        board_lines=(
            "Ask super:",
            "which agent?",
            "which workflow?",
            "which command?",
            "which recipe?",
            "how do I recover?",
            "what should run next?",
        ),
        narration=(
            "And then there is super. Super is the agent you ask when you do not know which agent to ask. Which is, frankly, humane. "
            "Super helps with framework operations, command generation, workflow guidance, agent selection, recipes, setup, upgrades, and general Bubbles advice. Recipes matter because repeated work should not be reinvented every time. Bugfix fastlane, validation loops, release packets, hardening passes, docs refreshes: these become patterns you can run, not folklore you remember if the moon is right. "
            "So if you are standing in the park office holding a broken workflow and three suspicious artifacts, ask super. It will point at the right clipboard."
        ),
        bg="0x151515",
        accent="0xffffff",
        voice_rate="-4%",
    ),
    Scene(
        eyebrow="EVERYDAY FLOW",
        title="Workflow Handles The Normal Delivery Loop",
        subtitle="Features, bugs, docs loops, validation passes, continuation work, and rework routing all live here.",
        bullets=(
            "workflow resolves intent, picks owners, runs phases, and routes failed gates back to the right specialist.",
            "It respects artifact ownership and status ceilings so diagnostic work does not pretend to be final certification.",
            "Use it when you want the system to carry work from request to evidence.",
        ),
        board_lines=(
            "/bubbles.workflow fix bug",
            "/bubbles.workflow build feature",
            "/bubbles.workflow validate spec",
            "/bubbles.workflow continue",
        ),
        narration=(
            "For everyday delivery, workflow is the workhorse. You describe the outcome. It resolves intent, picks owners, runs phases, and routes failed gates back to whoever owns the fix. "
            "This matters because diagnostic work should not accidentally become final certification. A review can find problems. A validator can certify evidence. An implementer can change code. Those are different jobs, and Bubbles tries very hard not to mix the badges. "
            "Use workflow when you want the whole trail: request, analysis, design if needed, scopes, implementation, tests, validation, docs, audit, and rework."
        ),
        bg="0x102033",
        accent="0x58a6ff",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="COORDINATORS",
        title="Goal, Sprint, And Releases Handle Bigger Work",
        subtitle="When one task becomes a campaign, use a coordinator instead of one heroic prompt.",
        bullets=(
            "goal drives one outcome through a convergence loop until it is done or truly blocked.",
            "sprint prioritizes multiple goals under a time budget and stops gracefully when budget expires.",
            "releases produces phase packets with vision, features, actions, carry-forward, and launch context.",
        ),
        board_lines=(
            "/bubbles.goal",
            "/bubbles.sprint",
            "/bubbles.releases",
            "Use them when blast radius grows.",
        ),
        narration=(
            "For bigger work, use bigger controllers. Goal drives one outcome through a convergence loop. Sprint handles several goals with prioritization and a time budget. Releases prepares phase packets with vision, feature lists, actions, business context, carry-forward, and launch material. "
            "That is important when the work is no longer one bug or one component. Coordinators keep the larger campaign moving without asking one agent to cosplay as an entire software department. "
            "It is still Copilot. It just has traffic control now, which is nice because the old intersection was mostly hope."
        ),
        bg="0x202033",
        accent="0xd2a8ff",
        voice_rate="-6%",
    ),
    Scene(
        eyebrow="DEVELOPER PAIN",
        title="The UI Calls A Route From A Dream Sequence",
        subtitle="Bubbles gates turn imaginary contracts into blocking problems before a user finds them.",
        bullets=(
            "Vertical slice completeness checks frontend calls against real backend handlers.",
            "Integration completeness prevents orphan endpoints, dead libraries, and unwired pages.",
            "E2E scenarios must prove user-visible behavior through the real path.",
        ),
        board_lines=(
            "Classic failure:",
            "UI calls /bookings/save",
            "backend has /booking/save",
            "test mocked fetch",
            "demo passes",
            "user clicks. nope.",
        ),
        narration=(
            "Actual developer pain: the UI calls a route from a dream sequence. The backend has almost the same route. The test mocked fetch. The demo smiled. Then the user clicked and the whole thing turned into interpretive logging. "
            "Bubbles attacks this with vertical slice completeness and integration completeness. Frontend API calls need real backend handlers. Backend endpoints need consumers or clear external documentation. Pages need to be reachable. Libraries need real imports. "
            "It sounds obvious because it is. And yet this bug has paid rent in almost every codebase."
        ),
        bg="0x2b2018",
        accent="0xffa657",
        voice_rate="-6%",
    ),
    Scene(
        eyebrow="DEVELOPER PAIN",
        title="The Test Passes By Avoiding The Fire",
        subtitle="A regression test that cannot catch the regression is just a decorative smoke alarm.",
        bullets=(
            "Regression guards look for bailout returns and weak required scenarios.",
            "Bug fixes need adversarial inputs that would fail if the old bug returned.",
            "Live-stack tests must hit the real stack, not intercepted bedtime stories.",
        ),
        board_lines=(
            "Bad:",
            "if page is login: return",
            "Better:",
            "assert no login redirect",
            "assert control works",
            "assert persisted state",
        ),
        narration=(
            "Another developer pain: the test passes by avoiding the fire. If redirected to login, return. If the control is missing, skip. If the data is weird, assert that something exists and call it a day. That is not testing. That is politely walking around the hole. "
            "Bubbles regression guard rules push the other way. Required scenarios cannot silently bail. Bug fixes need adversarial data. Live tests need the real stack. Persistence bugs need write, read, assert. "
            "Again, the goal is not fancy. The goal is that a broken feature makes the test angry. Groundbreaking, apparently."
        ),
        bg="0x191d23",
        accent="0xf2cc60",
        voice_rate="-6%",
    ),
    Scene(
        eyebrow="LONG WORK",
        title="The Context Window Went For A Walk",
        subtitle="Specs, scopes, reports, state, and validation keep long agent work from becoming folklore.",
        bullets=(
            "Durable artifacts carry truth across compaction, handoff, and new sessions.",
            "recap and handoff agents help summarize work without inventing completion.",
            "State files track execution without promoting certification dishonestly.",
        ),
        board_lines=(
            "Durable truth:",
            "spec.md",
            "design.md",
            "scopes.md",
            "report.md",
            "state.json",
            "uservalidation.md",
        ),
        narration=(
            "Long agent work has another problem: context wanders off. The chat was long, the feature was complicated, the session compacted, and now everybody is trying to remember whether mostly fixed meant fixed, or just emotionally available. "
            "Bubbles uses durable artifacts: spec, design, scopes, report, user validation, and state. Recap and handoff agents help move between sessions. State tracks execution without pretending certification is done. "
            "That lets the next session continue from evidence instead of vibes. The vibes may still attend, but they are not driving."
        ),
        bg="0x0e2630",
        accent="0x39d0c8",
        voice_rate="-6%",
    ),
    Scene(
        eyebrow="DEMO STORY",
        title="One Checkout Bug, Two Futures",
        subtitle="Without Bubbles it becomes a patch. With Bubbles it becomes a verified behavior change.",
        bullets=(
            "The bug is reproduced before the fix and verified after the fix.",
            "Design defines the risky transaction boundary and plan captures business scenarios.",
            "Test, chaos, harden, security, docs, validate, and audit each pressure the result differently.",
        ),
        board_lines=(
            "Bug flow:",
            "reproduce",
            "design",
            "plan",
            "implement",
            "test adversarially",
            "chaos + harden",
            "validate + audit",
        ),
        narration=(
            "Picture one checkout bug. Availability changes during payment. Without structure, an agent patches a handler, adds one happy-path test, and says done. This is how Friday learns martial arts. "
            "With Bubbles, the bug is reproduced first. Design defines the transaction boundary. Plan captures scenarios. Implement changes code. Test adds adversarial coverage. Chaos pokes real-system behavior. Harden checks completion. Security reviews exposure. Docs aligns truth. Validate checks evidence. Audit names risk. "
            "Same AI assistance. Much better operating loop. Less hoping. More receipts."
        ),
        bg="0x111827",
        accent="0x39d0c8",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="PAYOFF",
        title="Bubbles Lets Agents Take Bigger Swings Safely",
        subtitle="The win is not more text. The win is more trust per unit of generated work.",
        bullets=(
            "It reduces rework by catching fake done, stale specs, weak tests, and unwired code earlier.",
            "It gives reviewers a trail instead of a monologue.",
            "It lets teams use AI more aggressively without lowering the bar for delivery.",
        ),
        board_lines=(
            "Intent",
            "-> artifact",
            "-> scope",
            "-> implementation",
            "-> evidence",
            "-> review",
            "-> trust",
        ),
        narration=(
            "The payoff is trust. Not blind trust. Earned trust. Bubbles lets agents take bigger swings because the work has structure, gates, evidence, reviews, and ownership boundaries. "
            "It reduces rework by catching fake done, stale specs, weak tests, and unwired code earlier. It gives reviewers a trail instead of a monologue. It lets teams use AI more aggressively without quietly lowering the bar for delivery. "
            "That is the whole trick. More trust per unit of generated work. Simple sentence. Hard habit. Very useful."
        ),
        bg="0x0f1d26",
        accent="0x39d0c8",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="TRY IT",
        title="Run Bubbles On One Painful Workflow",
        subtitle="Pick the bug, drifted spec, or release packet that keeps returning with a fake mustache.",
        bullets=(
            "Install and bootstrap Bubbles in a repo where agent work needs stronger discipline.",
            "Ask super if you do not know which route to take, or start with /bubbles.workflow.",
            "Judge the artifacts, gates, evidence, and review trail, not just the final answer charm.",
        ),
        board_lines=(
            "1. Install",
            "2. Bootstrap",
            "3. Ask super or run workflow",
            "4. Inspect gates and evidence",
            "5. Keep what earns trust",
        ),
        narration=(
            "So try Bubbles on one painful workflow. Not every repo. Not the whole company. One real problem. "
            "Pick the bug that keeps coming back. Pick the spec that drifted. Pick the release packet that always becomes archaeology. Install, bootstrap, ask super if you are unsure, or start with slash bubbles dot workflow. Then inspect the gates, artifacts, evidence, and review trail. "
            "If you want AI coding work that moves fast and still proves itself, Bubbles is worth a serious look. It is strict. It is practical. And it keeps just enough park-office energy to make the clipboard survivable."
        ),
        bg="0x151515",
        accent="0xffffff",
        voice_rate="-4%",
    ),
)


def build_transcript() -> str:
    lines = ["# Bubbles Expanded YouTube Info Guide Transcript", ""]
    lines.append(f"Voice: {VOICE}")
    lines.append("Audio: PCM intermediate, loudness-normalized AAC at 320k in the rendered video.")
    lines.append("Note: narration uses varied rates, conversational phrasing, and small spoken-style turns for a more natural delivery.")
    lines.append("")
    for index, scene in enumerate(SCENES, start=1):
        lines.append(f"## {index:02d}. {scene.title}")
        lines.append("")
        lines.append(f"Rate: {scene.voice_rate}")
        lines.append("")
        lines.append(scene.narration)
        lines.append("")
    return "\n".join(lines)


def pad_scene_audio(ffmpeg_bin: Path, source: Path, output: Path, duration: float) -> None:
    command = [
        str(ffmpeg_bin),
        "-y",
        "-hide_banner",
        "-nostats",
        "-i",
        str(source),
        "-af",
        f"apad=pad_dur={SCENE_PAD_SECONDS},aresample={AUDIO_SAMPLE_RATE}",
        "-t",
        f"{duration:.3f}",
        "-ar",
        AUDIO_SAMPLE_RATE,
        "-ac",
        "2",
        "-c:a",
        "pcm_s16le",
        str(output),
    ]
    subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def concat_audio_wav(ffmpeg_bin: Path, padded_paths: list[Path], list_path: Path, output: Path) -> None:
    list_lines = [f"file '{path}'" for path in padded_paths]
    list_path.write_text("\n".join(list_lines) + "\n", encoding="utf-8")
    command = [
        str(ffmpeg_bin),
        "-y",
        "-hide_banner",
        "-nostats",
        "-f",
        "concat",
        "-safe",
        "0",
        "-i",
        str(list_path),
        "-ar",
        AUDIO_SAMPLE_RATE,
        "-ac",
        "2",
        "-c:a",
        "pcm_s16le",
        str(output),
    ]
    subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def encode_audio_m4a(ffmpeg_bin: Path, source: Path, output: Path) -> None:
    command = [
        str(ffmpeg_bin),
        "-y",
        "-hide_banner",
        "-nostats",
        "-i",
        str(source),
        "-af",
        LOUDNESS_FILTER,
        "-ar",
        AUDIO_SAMPLE_RATE,
        "-ac",
        "2",
        "-c:a",
        "aac",
        "-b:a",
        AUDIO_BITRATE,
        str(output),
    ]
    subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def render_video(ffmpeg_bin: Path, ass_path: Path, audio_path: Path, duration: float, output_path: Path) -> None:
    command = [
        str(ffmpeg_bin),
        "-y",
        "-hide_banner",
        "-nostats",
        "-f",
        "lavfi",
        "-i",
        f"color=c=0x000000:s={base.WIDTH}x{base.HEIGHT}:r={base.FPS}:d={duration:.3f}",
        "-i",
        str(audio_path),
        "-vf",
        f"ass={ass_path}",
        "-af",
        LOUDNESS_FILTER,
        "-map",
        "0:v",
        "-map",
        "1:a",
        "-t",
        f"{duration:.3f}",
        "-c:v",
        "libx264",
        "-preset",
        VIDEO_PRESET,
        "-crf",
        VIDEO_CRF,
        "-pix_fmt",
        "yuv420p",
        "-c:a",
        "aac",
        "-b:a",
        AUDIO_BITRATE,
        "-ar",
        AUDIO_SAMPLE_RATE,
        "-movflags",
        "+faststart",
        str(output_path),
    ]
    subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ffmpeg-bin", required=True, type=Path, help="Path to ffmpeg")
    parser.add_argument("--output", required=True, type=Path, help="Output MP4 path")
    parser.add_argument("--audio-output", type=Path, help="Optional AAC narration output")
    parser.add_argument("--transcript-output", type=Path, help="Optional transcript markdown output")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    base.require_file(args.ffmpeg_bin, "ffmpeg binary")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    if args.audio_output:
        args.audio_output.parent.mkdir(parents=True, exist_ok=True)
    if args.transcript_output:
        args.transcript_output.parent.mkdir(parents=True, exist_ok=True)
        args.transcript_output.write_text(build_transcript(), encoding="utf-8")

    base.VOICE = VOICE
    base.VOICE_VOLUME = VOICE_VOLUME
    base.SCENE_PAD_SECONDS = SCENE_PAD_SECONDS
    base.SCENES = SCENES

    with tempfile.TemporaryDirectory(prefix="bubbles-quality-suite-") as temp_dir_name:
        temp_dir = Path(temp_dir_name)
        raw_audio_paths = [temp_dir / f"scene-{index:02d}.mp3" for index in range(len(SCENES))]
        asyncio.run(base.synthesize_all(raw_audio_paths))

        scene_durations: list[float] = []
        padded_paths: list[Path] = []
        for index, raw_path in enumerate(raw_audio_paths):
            speech_duration = base.probe_duration(args.ffmpeg_bin, raw_path)
            scene_duration = speech_duration + SCENE_PAD_SECONDS
            scene_durations.append(scene_duration)
            padded_path = temp_dir / f"scene-{index:02d}-padded.wav"
            pad_scene_audio(args.ffmpeg_bin, raw_path, padded_path, scene_duration)
            padded_paths.append(padded_path)

        combined_audio = temp_dir / "combined-narration.wav"
        concat_audio_wav(args.ffmpeg_bin, padded_paths, temp_dir / "audio-list.txt", combined_audio)
        if args.audio_output:
            encode_audio_m4a(args.ffmpeg_bin, combined_audio, args.audio_output)

        scene_timings: list[tuple[float, float]] = []
        cursor = 0.0
        for duration in scene_durations:
            start = cursor
            cursor += duration
            scene_timings.append((start, cursor))

        ass_path = temp_dir / "bubbles-quality-suite.ass"
        ass_path.write_text(base.build_ass(scene_timings), encoding="utf-8")
        total_duration = scene_timings[-1][1]
        render_video(args.ffmpeg_bin, ass_path, combined_audio, total_duration, args.output)
        print(f"Rendered {args.output} ({total_duration:.2f} seconds)")


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"render failed: {exc}", file=sys.stderr)
        raise
