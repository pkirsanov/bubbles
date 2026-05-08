#!/usr/bin/env python3
"""Render a Bubbles marketing pitch MP4 with narrated voiceover.

This script intentionally avoids ffmpeg drawtext because the static ffmpeg build
used for these videos does not include that filter. Text and shapes are rendered
through ASS/libass overlays.
"""

from __future__ import annotations

import argparse
import asyncio
import re
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path

WIDTH = 1920
HEIGHT = 1080
FPS = 30
FONT = "DejaVu Sans"
MONO_FONT = "DejaVu Sans Mono"
VOICE = "en-US-GuyNeural"
VOICE_VOLUME = "+0%"
SCENE_PAD_SECONDS = 0.72


@dataclass(frozen=True)
class Scene:
    eyebrow: str
    title: str
    subtitle: str
    bullets: tuple[str, ...]
    command_lines: tuple[str, ...]
    narration: str
    bg: str
    accent: str
    voice_rate: str = "-6%"


SCENES: tuple[Scene, ...] = (
    Scene(
        eyebrow="COLD OPEN",
        title="Your Agent Said Done. Cool. Prove It.",
        subtitle="Bubbles turns AI coding help into accountable software delivery.",
        bullets=(
            "Agents are great at moving fast and sounding confident.",
            "Projects still need specs, evidence, tests, docs, and ownership.",
            "Bubbles gives Copilot Chat a delivery system, not just a louder keyboard.",
        ),
        command_lines=(
            "/bubbles.workflow fix the checkout regression",
            "agent -> artifacts -> gates -> evidence -> certification",
            "No proof? Not done. Very simple. Slightly rude. Useful.",
        ),
        narration=(
            "Okay, quick picture. Your AI agent says, done. The diff looks busy. The comments sound mature. Everybody feels productive for almost nine seconds. "
            "Then somebody asks, did it run the real tests? Did the spec change? Did the docs change? Is the endpoint even wired into the UI? And suddenly the room gets quiet. "
            "Bubbles exists for that moment. It is an orchestration system for VS Code Copilot Chat that makes agent work prove itself before it gets to wear the little done hat."
        ),
        bg="0x111827",
        accent="0x39d0c8",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="THE PAIN",
        title="Modern AI Work Has A Receipt Problem",
        subtitle="The output is cheap. Trust is expensive.",
        bullets=(
            "An assistant can generate code faster than a team can review the blast radius.",
            "A friendly summary can hide missing tests, stale specs, and fake completion.",
            "Without structure, every session becomes detective work with better autocomplete.",
        ),
        command_lines=(
            "Symptom: 'all tests pass' with no output",
            "Symptom: UI calls an endpoint that does not exist",
            "Symptom: bug fix changes the test to match the bug",
        ),
        narration=(
            "Here is the actual developer problem. Not the demo problem, the Tuesday afternoon problem. AI makes output cheap. That is wonderful. Also dangerous. "
            "Because now the bottleneck is not typing the code. The bottleneck is knowing whether the code is true. Did it satisfy the requirement? Did it regress the old behavior? Did it leave a tiny little landmine under the build script? "
            "Without a receipt trail, you are not doing assisted engineering. You are doing vibes with syntax highlighting."
        ),
        bg="0x24151a",
        accent="0xf85149",
        voice_rate="-7%",
    ),
    Scene(
        eyebrow="THE MESS",
        title="The Agent Drift Loop Is Real",
        subtitle="Spec drift, test drift, doc drift, state drift. Lovely weather for bugs.",
        bullets=(
            "The agent starts with one intent and finishes with six side quests.",
            "Artifacts disagree, so each next session inherits a slightly different truth.",
            "Nobody knows which claim is certified and which claim was just narration.",
        ),
        command_lines=(
            "spec.md says A",
            "design.md implements B",
            "report.md says 'probably fine'",
            "state.json says... eh, let's not look directly at it",
        ),
        narration=(
            "You have seen the loop. The agent starts fixing a bug. Then it notices a style issue. Then it rewrites a helper. Then it updates a test. Then it forgets the original bug like a goldfish with a GitHub token. "
            "Meanwhile the spec says one thing, the design says another thing, and the final answer says, everything is handled. Is it? Maybe. Is maybe a deployment strategy? I mean, legally, no. "
            "Bubbles attacks that drift by making the work live in named artifacts with named owners."
        ),
        bg="0x1a1f2b",
        accent="0xd2a8ff",
        voice_rate="-6%",
    ),
    Scene(
        eyebrow="THE PRODUCT",
        title="Bubbles Is The Operating Loop Around Copilot",
        subtitle="One framework layer. Many specialist agents. Evidence before celebration.",
        bullets=(
            "37 specialist agents cover analysis, design, planning, implementation, tests, docs, audit, and release work.",
            "34 workflow modes encode different delivery shapes instead of one mega-prompt for everything.",
            "65 gates keep assertions tied to proof instead of confidence theater.",
        ),
        command_lines=(
            "37 agents",
            "34 workflow modes",
            "65 gates",
            "26 phases",
            "One practical idea: make the work accountable",
        ),
        narration=(
            "Bubbles is not another magic prompt. It is the operating loop around Copilot Chat. It installs a structured set of agents, prompts, skills, instructions, templates, workflow modes, and gates. "
            "So instead of asking one general assistant to be product manager, architect, implementer, tester, auditor, release manager, and snack committee, Bubbles routes the work to owners. "
            "Thirty seven agents. Thirty four workflow modes. Sixty five gates. Twenty six phases. That sounds like a lot until you compare it with the alternative, which is asking one chat window to remember reality for six hours. Bold strategy."
        ),
        bg="0x0f1d26",
        accent="0x58a6ff",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="WHO IT HELPS",
        title="For Developers Who Like Speed And Receipts",
        subtitle="The target user is not allergic to AI. They are allergic to unverified work.",
        bullets=(
            "Solo builders get continuity between sessions instead of starting from fog every morning.",
            "Teams get clearer ownership, review surfaces, and evidence-backed status.",
            "Maintainers get less mystery meat in pull requests and fewer heroic archaeology days.",
        ),
        command_lines=(
            "Solo dev: continue work without losing the thread",
            "Team lead: see what was proven, not just claimed",
            "Maintainer: reject fake done early",
        ),
        narration=(
            "Who is this for? Developers who already know AI can help, but do not want their repo turned into a motivational poster with semicolons. "
            "If you are solo, Bubbles gives you continuity. If you lead a team, it gives you evidence and ownership. If you maintain a serious codebase, it gives you a polite way to say, interesting claim, please attach reality. "
            "It is for people who like speed, but still want receipts. Which, honestly, should be most adults near production systems."
        ),
        bg="0x14231c",
        accent="0x3fb950",
        voice_rate="-6%",
    ),
    Scene(
        eyebrow="PROBLEM 1",
        title="Fake Done Costs More Than Slow Done",
        subtitle="A checked box without evidence is just decorative Markdown.",
        bullets=(
            "Bubbles requires raw execution evidence for completed DoD items.",
            "Certification is separate from the agent that did the work.",
            "The system can reopen work through packets instead of vague shame fog.",
        ),
        command_lines=(
            "DoD item checked? Show raw output.",
            "Spec done? All scopes must be done first.",
            "Certification owned by validate, not whoever feels optimistic.",
        ),
        narration=(
            "The first problem Bubbles solves is fake done. Fake done is worse than slow done because slow done at least has the decency to be honest. "
            "Bubbles says if a definition of done item is checked, it needs evidence. Real command output. Real observed behavior. Not a summary that says, all good, boss. That is not evidence. That is a scented candle. "
            "And certification is separated from execution. The agent that implemented something does not get to crown itself king of correctness."
        ),
        bg="0x251414",
        accent="0xff7b72",
        voice_rate="-7%",
    ),
    Scene(
        eyebrow="PROBLEM 2",
        title="Wrong Agent, Wrong Artifact, Weird Results",
        subtitle="Bubbles gives artifacts owners, so diagnostic work does not scribble on design.",
        bullets=(
            "Analyst owns business requirements and outcomes.",
            "Design owns technical architecture and API shape.",
            "Plan owns scopes, scenarios, DoD, and test structure.",
        ),
        command_lines=(
            "analyst -> spec.md business truth",
            "design -> design.md technical shape",
            "plan -> scopes.md executable slices",
            "validate -> certification authority",
        ),
        narration=(
            "The second problem is role confusion. A general agent will happily review a design, fix a test, rewrite a spec, change a route, and update a release note in one breath. Impressive. Also, no thank you. "
            "Bubbles has artifact ownership. Analyst owns business truth. Design owns the technical shape. Plan owns scopes and definitions of done. Validate owns certification. Audit reviews. Implement implements. "
            "It is not bureaucracy. It is the difference between a kitchen and a blender full of dinner."
        ),
        bg="0x221b2f",
        accent="0xd2a8ff",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="PROBLEM 3",
        title="Tests That Cannot Fail Are Tiny Stage Props",
        subtitle="Regression tests must be adversarial, not ceremonial.",
        bullets=(
            "Required E2E tests must fail if the behavior is missing.",
            "Bug regressions need adversarial cases that catch the old failure mode.",
            "Live-stack tests cannot quietly intercept the backend and still call themselves live.",
        ),
        command_lines=(
            "Forbidden: if redirected to /login, return;",
            "Forbidden: all fixtures satisfy the broken filter",
            "Required: prove the bug would come back if the fix vanished",
        ),
        narration=(
            "The third problem is theater tests. You know the ones. The test passes if the button exists, but never clicks it. The E2E test intercepts the API, then brags about the live stack. The regression test only uses data that would have passed before the fix. "
            "Bubbles calls that out. Required tests must be able to fail. Bug regressions need adversarial input. Live tests must hit live systems. "
            "A test that cannot catch the bug is not a guardrail. It is a cardboard cutout wearing a hard hat."
        ),
        bg="0x191d23",
        accent="0xf2cc60",
        voice_rate="-6%",
    ),
    Scene(
        eyebrow="PROBLEM 4",
        title="Long Sessions Need Memory With Structure",
        subtitle="Conversation context disappears. Artifacts stay boring and useful.",
        bullets=(
            "Spec, design, scopes, reports, validation, and state carry truth across sessions.",
            "Handoffs and recaps preserve what happened and what remains.",
            "Workflow can continue from the artifact state instead of restarting from vibes.",
        ),
        command_lines=(
            "/bubbles.recap what happened",
            "/bubbles.handoff prepare next session",
            "/bubbles.workflow continue",
        ),
        narration=(
            "The fourth problem is continuity. Long agent sessions are powerful until the context window gets tired, wanders into the woods, and returns with half a map. "
            "Bubbles makes durable artifacts the center of the work. Specs, designs, scopes, reports, user validation, and state files carry the truth forward. Recap and handoff agents help move between sessions. "
            "So when you say continue, the system has something better than, I feel like we were doing backend stuff."
        ),
        bg="0x0e2630",
        accent="0x39d0c8",
        voice_rate="-6%",
    ),
    Scene(
        eyebrow="INSTALL",
        title="Install It Like A Framework, Use It Like A Crew",
        subtitle="Bootstrap once, then start with the universal entry point.",
        bullets=(
            "Install the framework assets into a repo that needs agent governance.",
            "Use bootstrap mode to add/update the Bubbles layer safely.",
            "Most users start with /bubbles.workflow and let it route the work.",
        ),
        command_lines=(
            "curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/main/install.sh | bash",
            "curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/main/install.sh | bash -s -- --bootstrap",
            "/bubbles.workflow improve this onboarding flow",
        ),
        narration=(
            "The installation story is intentionally boring, which is a compliment. You install the Bubbles framework assets into a downstream repo. Bootstrap sets up the instructions, agents, prompts, skills, templates, and governance surfaces. "
            "Then, for most work, you start with slash bubbles dot workflow. Describe what you want in plain English. It resolves intent, picks the right route, and drives the phases. "
            "Basically, you hire the crew, then stop asking the electrician to write the product strategy."
        ),
        bg="0x102033",
        accent="0x58a6ff",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="SMALL JOBS",
        title="Use Specialists When The Job Is Narrow",
        subtitle="Not every question needs a full parade and three clipboards.",
        bullets=(
            "Use grill to pressure-test an idea before implementation starts.",
            "Use code-review for engineering-only findings.",
            "Use docs, commands, status, or recap when the work has a focused surface.",
        ),
        command_lines=(
            "/bubbles.grill pressure-test this plan",
            "/bubbles.code-review review the API boundary",
            "/bubbles.docs align the managed docs",
            "/bubbles.status report current progress",
        ),
        narration=(
            "For small jobs, run a specialist. You do not need an autonomous sprint to ask whether an idea survives contact with users. Use grill. You do not need a product review for a pure engineering diff. Use code review. "
            "Need docs cleaned up? Use docs. Need a status report? Use status. Need a recap? Use recap. "
            "This matters because good orchestration is not maximum process all the time. It is the right amount of process before the work turns into soup."
        ),
        bg="0x181f2b",
        accent="0xffa657",
        voice_rate="-4%",
    ),
    Scene(
        eyebrow="MEDIUM JOBS",
        title="Use Workflow For Normal Feature And Bug Work",
        subtitle="Workflow is the everyday operating loop.",
        bullets=(
            "It can analyze, design, plan, implement, test, validate, audit, and route rework.",
            "It understands mode ceilings, artifact owners, and retry boundaries.",
            "It keeps the work moving without pretending every step belongs to one agent.",
        ),
        command_lines=(
            "/bubbles.workflow build guest refund handling",
            "/bubbles.workflow fix public search regression",
            "/bubbles.workflow continue",
        ),
        narration=(
            "For normal feature and bug work, use workflow. This is the daily driver. It can analyze the intent, pick the next work, route to owners, execute phases, enforce gates, and keep going through rework. "
            "The nice part is that workflow does not need you to manually micromanage every agent. It knows when to ask analyst, when to involve design, when plan owns the scope, when implement does the code, when test checks it, and when validate gets to be very unimpressed. "
            "Honestly, validate being unimpressed is a feature."
        ),
        bg="0x14231c",
        accent="0x3fb950",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="BIG JOBS",
        title="Goal, Sprint, And Releases Handle Bigger Outcomes",
        subtitle="When the work spans phases, let a coordinator own the loop.",
        bullets=(
            "goal drives one outcome to convergence across multiple phases.",
            "sprint prioritizes several goals inside a time budget.",
            "releases creates phase packets, rollout strategy, carry-forward, and business context.",
        ),
        command_lines=(
            "/bubbles.goal ship direct-booking deposit holds",
            "/bubbles.sprint goals: auth hardening, docs, regression sweep; budget: 4h",
            "/bubbles.releases prepare phase 2 launch packet",
        ),
        narration=(
            "For bigger outcomes, Bubbles has bigger controllers. Goal is for one outcome that needs a full loop. Sprint is for multiple goals with prioritization and a time budget. Releases is for phase packets, launch logic, carry-forward, business context, and all the stuff that makes shipping less like yelling into a fog machine. "
            "This is where Bubbles becomes more than a prompt library. It is a delivery control plane for agentic work. Still in VS Code. Still practical. Just less, hey buddy, please remember the entire project forever."
        ),
        bg="0x202033",
        accent="0xd2a8ff",
        voice_rate="-6%",
    ),
    Scene(
        eyebrow="THE DEMO",
        title="A Real Developer Day With Bubbles",
        subtitle="Take one messy request and force it through evidence.",
        bullets=(
            "Request: checkout fails when availability changes during payment.",
            "Bubbles routes business behavior, design, scope, implementation, tests, chaos, validation, and audit.",
            "Closeout includes what changed, what ran, what passed, and what still needs an owner.",
        ),
        command_lines=(
            "User: checkout race condition is back",
            "Workflow: reproduce -> design -> plan -> implement -> test -> validate",
            "Final: files changed, evidence observed, residual risk named",
        ),
        narration=(
            "Picture a real day. Checkout fails when availability changes during payment. Without structure, the agent patches a handler, adds a happy-path test, says done, and you find the race again next week wearing a fake mustache. "
            "With Bubbles, analyst clarifies the business outcome. Design shapes the transaction boundary. Plan creates scenarios and definitions of done. Implement changes the code. Test adds adversarial regression coverage. Chaos can poke the timing. Validate checks evidence. Audit reports residual risk. "
            "Same AI help. Much better operating loop."
        ),
        bg="0x111827",
        accent="0x39d0c8",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="WHY DEVS CARE",
        title="It Reduces Rework, Not Creativity",
        subtitle="The point is not to slow developers down. It is to stop paying twice.",
        bullets=(
            "Less time reconstructing what the last session actually did.",
            "Less time arguing with polished but unsupported completion claims.",
            "More time making product decisions with verified implementation state.",
        ),
        command_lines=(
            "Fewer reopened bugs",
            "Clearer PR review",
            "Cleaner handoffs",
            "Better trust in agent-assisted delivery",
        ),
        narration=(
            "The obvious fear is, does this slow me down? Sometimes it adds a step. Usually it removes five later. That is the trade. "
            "Bubbles reduces rework. It reduces mystery. It reduces that weird feeling where the code changed a lot, but nobody can say which user behavior is actually better. "
            "It does not replace creativity. It protects it from cleanup debt. Because nothing kills creative momentum like spending Thursday proving Tuesday was imaginary."
        ),
        bg="0x101f2a",
        accent="0x58a6ff",
        voice_rate="-6%",
    ),
    Scene(
        eyebrow="DIFFERENTIATOR",
        title="Bubbles Makes Governance Usable At Dev Speed",
        subtitle="Strict does not have to mean ceremonial.",
        bullets=(
            "The rules live where the agent works: instructions, agents, prompts, templates, and skills.",
            "Workflow modes encode real project policies instead of relying on memory or vibes.",
            "Gates are mechanical enough to catch nonsense and human enough to route rework.",
        ),
        command_lines=(
            "Policy in the repo",
            "Workflows in the repo",
            "Evidence in the repo",
            "Certification in the repo",
        ),
        narration=(
            "Here is the differentiator. Lots of teams want governance. Almost nobody wants a second job feeding governance. Bubbles puts the rules where the agent actually works. In the repo. In the instructions. In the agents. In the templates. In the workflow. "
            "That makes strictness usable at development speed. The agent does not have to remember the culture. The framework encodes it. "
            "Is that glamorous? No. Is it how reliable systems usually happen? Yes. Annoyingly, yes."
        ),
        bg="0x161b22",
        accent="0xf2cc60",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="OBJECTION",
        title="But I Already Have Prompts",
        subtitle="Prompts are useful. Bubbles is the system around the prompts.",
        bullets=(
            "A prompt can request good behavior; a workflow can require proof.",
            "A checklist can be ignored; gates can block invalid status transitions.",
            "A general agent can help; specialist ownership makes help reviewable.",
        ),
        command_lines=(
            "Prompt: please run tests",
            "Bubbles: evidence missing, status cannot advance",
            "Prompt: update docs",
            "Bubbles: docs owner, artifact lint, managed-doc truth",
        ),
        narration=(
            "A fair objection: I already have prompts. Great. Prompts are useful. Bubbles is not anti-prompt. It is anti-pretend. "
            "A prompt can ask the agent to run tests. Bubbles can say, where is the raw output? A prompt can ask for docs. Bubbles can route docs to the docs owner and verify the artifact shape. "
            "Prompts are instructions. Bubbles is instructions plus workflow plus ownership plus gates plus evidence. It is the difference between a recipe and a kitchen that refuses to serve raw chicken."
        ),
        bg="0x2b2018",
        accent="0xffa657",
        voice_rate="-6%",
    ),
    Scene(
        eyebrow="OBJECTION",
        title="But My Project Is Weird",
        subtitle="Good. Repos are supposed to have local rules.",
        bullets=(
            "Bubbles is repo-local and customizable through instructions, skills, templates, and command registries.",
            "It can encode project-specific build, test, deployment, UI, config, and evidence policies.",
            "The framework gives shape; the repo supplies truth.",
        ),
        command_lines=(
            ".github/copilot-instructions.md",
            ".github/agents/*.agent.md",
            ".github/skills/*/SKILL.md",
            ".specify/memory/agents.md",
        ),
        narration=(
            "Another fair objection: my project is weird. Perfect. Most real projects are weird. Bubbles is designed to live in the repo, not above it like a motivational cloud. "
            "Your repo can define the commands, the test policy, the config rules, the UI standards, the deployment constraints, the artifact templates, and the domain-specific skills. "
            "The framework provides shape. The repo supplies truth. Which is good, because every codebase has at least one rule that sounds insane until you break it once. Then everybody gets religion."
        ),
        bg="0x17251f",
        accent="0x3fb950",
        voice_rate="-7%",
    ),
    Scene(
        eyebrow="THE PAYOFF",
        title="What You Actually Get Back",
        subtitle="Confidence, continuity, and fewer archaeological expeditions through chat history.",
        bullets=(
            "A safer way to let agents take bigger swings without losing control.",
            "A clearer way to review what changed and why it is believed to work.",
            "A repeatable way to turn vague intent into shipped, validated outcomes.",
        ),
        command_lines=(
            "Intent becomes artifact",
            "Artifact becomes scope",
            "Scope becomes implementation",
            "Implementation becomes evidence",
            "Evidence becomes trust",
        ),
        narration=(
            "The payoff is not that Bubbles makes agents magical. It makes them accountable. That is better. Magic is hard to debug. Accountability has file paths. "
            "You get confidence because evidence is required. You get continuity because artifacts outlive chat context. You get leverage because specialists and coordinators can take bigger swings without turning the project into a mystery novel. "
            "Intent becomes artifact. Artifact becomes scope. Scope becomes implementation. Implementation becomes evidence. Evidence becomes trust. That is the whole sales pitch, really. That and fewer surprises wearing production credentials."
        ),
        bg="0x0f1d26",
        accent="0x39d0c8",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="CALL TO ACTION",
        title="Try It On One Painful Workflow",
        subtitle="Do not boil the ocean. Pick the bug that keeps coming back with a fake mustache.",
        bullets=(
            "Install Bubbles in a repo where agent work needs stronger delivery discipline.",
            "Run /bubbles.workflow on one feature, bug, or cleanup outcome.",
            "Judge it by the evidence trail, not by how charming the final answer sounds.",
        ),
        command_lines=(
            "1. Install",
            "2. Bootstrap",
            "3. Run /bubbles.workflow on a real problem",
            "4. Inspect the artifacts and evidence",
            "5. Decide with receipts",
        ),
        narration=(
            "So here is the practical ask. Do not migrate your whole life in one afternoon. Pick one painful workflow. A bug that keeps coming back. A feature where specs and implementation drift. A release packet that always turns into archaeology. "
            "Install Bubbles. Bootstrap the repo. Run slash bubbles dot workflow on the real problem. Then judge the result by the artifacts and evidence, not by the final answer's sparkling personality. "
            "If you want AI coding help that can move fast and still show its work, Bubbles is worth a serious look. And yes, it has jokes. Because if software delivery is going to be strict, it might as well be at least a little funny."
        ),
        bg="0x151515",
        accent="0xffffff",
        voice_rate="-4%",
    ),
)


def require_file(path: Path, label: str) -> None:
    if not path.is_file():
        raise SystemExit(f"Missing {label}: {path}")


def ass_time(seconds: float) -> str:
    centiseconds = int(round(seconds * 100))
    hours, centiseconds = divmod(centiseconds, 360000)
    minutes, centiseconds = divmod(centiseconds, 6000)
    secs, centiseconds = divmod(centiseconds, 100)
    return f"{hours}:{minutes:02d}:{secs:02d}.{centiseconds:02d}"


def hex_to_ass_bgr(value: str) -> str:
    cleaned = value.removeprefix("0x").removeprefix("#")
    red = cleaned[0:2]
    green = cleaned[2:4]
    blue = cleaned[4:6]
    return f"{blue}{green}{red}".upper()


def color_tag(value: str, alpha: str = "00") -> str:
    return f"\\c&H{hex_to_ass_bgr(value)}&\\alpha&H{alpha}&"


def ass_text(value: str) -> str:
    return value.replace("{", "(").replace("}", ")")


def dialogue(layer: int, start: float, end: float, body: str) -> str:
    return f"Dialogue: {layer},{ass_time(start)},{ass_time(end)},Default,,0,0,0,,{body}"


def rect(x: int, y: int, width: int, height: int, color: str, alpha: str = "00") -> str:
    return (
        f"{{\\an7\\pos({x},{y})\\p1\\bord0\\shad0{color_tag(color, alpha)}}}"
        f"m 0 0 l {width} 0 l {width} {height} l 0 {height}"
        "{\\p0}"
    )


def text(
    value: str,
    x: int,
    y: int,
    size: int,
    color: str,
    alpha: str = "00",
    align: int = 7,
    bold: bool = False,
    font: str = FONT,
) -> str:
    weight = "\\b1" if bold else "\\b0"
    return (
        f"{{\\an{align}\\pos({x},{y})\\fn{font}\\fs{size}{weight}\\bord0\\shad0"
        f"{color_tag(color, alpha)}}}{ass_text(value)}"
    )


def wrap_line(value: str, max_chars: int) -> list[str]:
    words = value.split()
    lines: list[str] = []
    current: list[str] = []
    for word in words:
        candidate = " ".join([*current, word])
        if len(candidate) > max_chars and current:
            lines.append(" ".join(current))
            current = [word]
        else:
            current.append(word)
    if current:
        lines.append(" ".join(current))
    return lines


def probe_duration(ffmpeg_bin: Path, path: Path) -> float:
    proc = subprocess.run(
        [str(ffmpeg_bin), "-hide_banner", "-i", str(path)],
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    match = re.search(r"Duration: (\d+):(\d+):(\d+(?:\.\d+)?)", proc.stderr)
    if not match:
        raise RuntimeError(f"Could not read duration for {path}: {proc.stderr}")
    hours = int(match.group(1))
    minutes = int(match.group(2))
    seconds = float(match.group(3))
    return hours * 3600 + minutes * 60 + seconds


async def synthesize_scene_audio(scene: Scene, output_path: Path) -> None:
    import edge_tts

    communicate = edge_tts.Communicate(
        text=scene.narration,
        voice=VOICE,
        rate=scene.voice_rate,
        volume=VOICE_VOLUME,
    )
    await communicate.save(str(output_path))


async def synthesize_all(scene_audio_paths: list[Path]) -> None:
    for scene, path in zip(SCENES, scene_audio_paths):
        print(f"Synthesizing narration: {scene.eyebrow} - {scene.title} ({scene.voice_rate})")
        await synthesize_scene_audio(scene, path)


def build_transcript() -> str:
    lines = ["# Bubbles Marketing Pitch Voiceover Transcript", ""]
    lines.append(f"Voice: {VOICE}")
    lines.append("Note: narration is generated with varied rates and conversational phrasing for a more natural delivery.")
    lines.append("")
    for index, scene in enumerate(SCENES, start=1):
        lines.append(f"## {index:02d}. {scene.title}")
        lines.append("")
        lines.append(f"Rate: {scene.voice_rate}")
        lines.append("")
        lines.append(scene.narration)
        lines.append("")
    return "\n".join(lines)


def build_ass(scene_timings: list[tuple[float, float]]) -> str:
    lines = [
        "[Script Info]",
        "ScriptType: v4.00+",
        "ScaledBorderAndShadow: yes",
        f"PlayResX: {WIDTH}",
        f"PlayResY: {HEIGHT}",
        "WrapStyle: 0",
        "",
        "[V4+ Styles]",
        "Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, "
        "Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, "
        "Alignment, MarginL, MarginR, MarginV, Encoding",
        f"Style: Default,{FONT},36,&H00FFFFFF,&H00FFFFFF,&H00000000,&H00000000,"
        "0,0,0,0,100,100,0,0,1,0,0,7,0,0,0,1",
        "",
        "[Events]",
        "Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text",
    ]

    total = scene_timings[-1][1]
    lines.append(dialogue(0, 0, total, rect(0, 0, WIDTH, HEIGHT, "0x0b1017")))

    for index, (scene, timing) in enumerate(zip(SCENES, scene_timings), start=1):
        start, end = timing
        accent = scene.accent
        lines.append(dialogue(0, start, end, rect(0, 0, WIDTH, HEIGHT, scene.bg)))
        lines.append(dialogue(1, start, end, rect(0, 0, 48, HEIGHT, accent)))
        lines.append(dialogue(1, start, end, rect(112, 72, 330, 48, accent, "08")))
        lines.append(dialogue(1, start, end, rect(112, 210, 1695, 4, accent, "18")))
        lines.append(dialogue(1, start, end, rect(1478, 72, 330, 92, "0x000000", "86")))
        lines.append(dialogue(2, start, end, text(f"{index:02d}/{len(SCENES):02d}", 1522, 96, 35, accent, "00", 7, True, MONO_FONT)))

        for grid_x in range(240, WIDTH, 240):
            lines.append(dialogue(1, start, end, rect(grid_x, 0, 1, HEIGHT, "0xffffff", "EC")))
        for grid_y in range(240, HEIGHT, 240):
            lines.append(dialogue(1, start, end, rect(0, grid_y, WIDTH, 1, "0xffffff", "EC")))

        for bubble_index in range(7):
            x = 1300 + ((bubble_index * 131 + index * 47) % 430)
            y = 278 + ((bubble_index * 173 + index * 71) % 590)
            size = 52 + ((bubble_index + index) % 5) * 19
            lines.append(dialogue(2, start, end, text("o", x, y, size, accent, "A8", 5, True)))

        lines.append(dialogue(3, start, end, text(scene.eyebrow, 136, 88, 25, "0x111827", "00", 7, True, MONO_FONT)))
        for line_index, title_line in enumerate(wrap_line(scene.title, 37)):
            lines.append(dialogue(3, start, end, text(title_line, 112, 252 + line_index * 74, 64, "0xffffff", "00", 7, True)))
        subtitle_y = 368 + max(0, len(wrap_line(scene.title, 37)) - 1) * 50
        for line_index, subtitle_line in enumerate(wrap_line(scene.subtitle, 74)):
            lines.append(dialogue(3, start, end, text(subtitle_line, 116, subtitle_y + line_index * 42, 34, "0xffffff", "22", 7)))

        bullet_start_y = 498
        for bullet_index, bullet in enumerate(scene.bullets):
            y = bullet_start_y + bullet_index * 108
            lines.append(dialogue(2, start, end, rect(118, y - 22, 1092, 80, "0x000000", "94")))
            lines.append(dialogue(2, start, end, rect(118, y - 22, 10, 80, accent, "05")))
            lines.append(dialogue(3, start, end, text(str(bullet_index + 1), 154, y - 7, 30, accent, "00", 7, True, MONO_FONT)))
            for line_index, bullet_line in enumerate(wrap_line(bullet, 62)):
                lines.append(dialogue(3, start, end, text(bullet_line, 214, y - 8 + line_index * 34, 30, "0xffffff", "18", 7)))

        code_top = 484
        code_left = 1252
        code_width = 558
        code_height = max(226, 58 + len(scene.command_lines) * 42)
        lines.append(dialogue(2, start, end, rect(code_left, code_top, code_width, code_height, "0x05070d", "40")))
        lines.append(dialogue(2, start, end, rect(code_left, code_top, code_width, 42, accent, "10")))
        lines.append(dialogue(3, start, end, text("REAL-WORLD PROOF", code_left + 24, code_top + 10, 21, "0x111827", "00", 7, True, MONO_FONT)))
        for line_index, command in enumerate(scene.command_lines):
            y = code_top + 62 + line_index * 42
            for wrapped_index, command_line in enumerate(wrap_line(command, 50)):
                color = accent if line_index == 0 and wrapped_index == 0 else "0xffffff"
                lines.append(dialogue(3, start, end, text(command_line, code_left + 28, y + wrapped_index * 30, 22, color, "00", 7, False, MONO_FONT)))

        footer = "Bubbles marketing pitch | accountable Copilot workflows for serious repos"
        lines.append(dialogue(3, start, end, text(footer, 116, 1010, 24, "0xffffff", "76", 7)))

    return "\n".join(lines) + "\n"


def pad_scene_audio(ffmpeg_bin: Path, source: Path, output: Path, duration: float) -> None:
    command = [
        str(ffmpeg_bin),
        "-y",
        "-hide_banner",
        "-nostats",
        "-i",
        str(source),
        "-af",
        f"apad=pad_dur={SCENE_PAD_SECONDS}",
        "-t",
        f"{duration:.3f}",
        "-ar",
        "44100",
        "-ac",
        "2",
        str(output),
    ]
    subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def concat_audio(ffmpeg_bin: Path, padded_paths: list[Path], list_path: Path, output: Path) -> None:
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
        "-c:a",
        "aac",
        "-b:a",
        "128k",
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
        f"color=c=0x000000:s={WIDTH}x{HEIGHT}:r={FPS}:d={duration:.3f}",
        "-i",
        str(audio_path),
        "-vf",
        f"ass={ass_path}",
        "-map",
        "0:v",
        "-map",
        "1:a",
        "-t",
        f"{duration:.3f}",
        "-c:v",
        "libx264",
        "-preset",
        "medium",
        "-crf",
        "20",
        "-pix_fmt",
        "yuv420p",
        "-c:a",
        "aac",
        "-b:a",
        "128k",
        "-movflags",
        "+faststart",
        str(output_path),
    ]
    subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ffmpeg-bin", required=True, type=Path, help="Path to ffmpeg")
    parser.add_argument("--output", required=True, type=Path, help="Output MP4 path")
    parser.add_argument("--audio-output", type=Path, help="Optional copy of combined narration audio")
    parser.add_argument("--transcript-output", type=Path, help="Optional transcript markdown output")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    require_file(args.ffmpeg_bin, "ffmpeg binary")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    if args.audio_output:
        args.audio_output.parent.mkdir(parents=True, exist_ok=True)
    if args.transcript_output:
        args.transcript_output.parent.mkdir(parents=True, exist_ok=True)
        args.transcript_output.write_text(build_transcript(), encoding="utf-8")

    with tempfile.TemporaryDirectory(prefix="bubbles-marketing-") as temp_dir_name:
        temp_dir = Path(temp_dir_name)
        raw_audio_paths = [temp_dir / f"scene-{index:02d}.mp3" for index in range(len(SCENES))]
        asyncio.run(synthesize_all(raw_audio_paths))

        scene_durations: list[float] = []
        padded_paths: list[Path] = []
        for index, raw_path in enumerate(raw_audio_paths):
            speech_duration = probe_duration(args.ffmpeg_bin, raw_path)
            scene_duration = speech_duration + SCENE_PAD_SECONDS
            scene_durations.append(scene_duration)
            padded_path = temp_dir / f"scene-{index:02d}-padded.wav"
            pad_scene_audio(args.ffmpeg_bin, raw_path, padded_path, scene_duration)
            padded_paths.append(padded_path)

        combined_audio = temp_dir / "combined-narration.m4a"
        concat_audio(args.ffmpeg_bin, padded_paths, temp_dir / "audio-list.txt", combined_audio)
        if args.audio_output:
            subprocess.run(
                [
                    str(args.ffmpeg_bin),
                    "-y",
                    "-hide_banner",
                    "-nostats",
                    "-i",
                    str(combined_audio),
                    "-c",
                    "copy",
                    str(args.audio_output),
                ],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
            )

        scene_timings: list[tuple[float, float]] = []
        cursor = 0.0
        for duration in scene_durations:
            start = cursor
            cursor += duration
            scene_timings.append((start, cursor))

        ass_path = temp_dir / "bubbles-marketing.ass"
        ass_path.write_text(build_ass(scene_timings), encoding="utf-8")
        total_duration = scene_timings[-1][1]
        render_video(args.ffmpeg_bin, ass_path, combined_audio, total_duration, args.output)
        print(f"Rendered {args.output} ({total_duration:.2f} seconds)")


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"render failed: {exc}", file=sys.stderr)
        raise
