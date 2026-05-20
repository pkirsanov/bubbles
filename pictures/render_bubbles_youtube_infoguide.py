#!/usr/bin/env python3
"""Render a YouTube-style Bubbles info guide with narrated voiceover.

The renderer uses ASS/libass overlays instead of ffmpeg drawtext, because the
static ffmpeg build used for these videos does not include drawtext.
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
SCENE_PAD_SECONDS = 0.78


@dataclass(frozen=True)
class Scene:
    eyebrow: str
    title: str
    subtitle: str
    bullets: tuple[str, ...]
    board_lines: tuple[str, ...]
    narration: str
    bg: str
    accent: str
    voice_rate: str = "-6%"


SCENES: tuple[Scene, ...] = (
    Scene(
        eyebrow="COLD OPEN",
        title="Stop Letting AI Say Done Like It Owns The Place",
        subtitle="A repo can look busy and still be one bad merge away from a parking lot meeting.",
        bullets=(
            "The agent wrote code. Great. Did it prove the work?",
            "The summary sounds confident. Lovely. Where are the receipts?",
            "Bubbles makes Copilot work behave like accountable delivery.",
        ),
        board_lines=(
            "HOOK:",
            "AI output is cheap.",
            "Verified work is valuable.",
            "Bubbles is the receipt machine.",
        ),
        narration=(
            "Okay, quick cold open. If you have ever watched an AI agent write a huge diff, say done, and then leave you to discover the tests were imaginary, this is for you. "
            "Because the problem is not that AI is too slow. No. The problem is that AI is fast enough to create a convincing mess before your coffee cools down. "
            "Bubbles is the operating loop that asks the very annoying, very useful question: cool story, where is the proof?"
        ),
        bg="0x101722",
        accent="0x39d0c8",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="THE THING",
        title="Bubbles Is A Delivery System For Copilot Chat",
        subtitle="Not a magic prompt. Not a motivational poster. A structured work loop.",
        bullets=(
            "It adds specialist agents, workflow modes, skills, templates, and gates.",
            "It routes work to owners instead of asking one chat to be every department.",
            "It keeps artifacts, evidence, and certification tied together.",
        ),
        board_lines=(
            "37 specialist agents",
            "34 workflow modes",
            "65 gates",
            "26 phases",
            "1 idea: prove the work",
        ),
        narration=(
            "So what is Bubbles? Bubbles is a spec-driven AI agent orchestration system for VS Code Copilot Chat. Translation: it gives Copilot a delivery crew and a clipboard. "
            "You get specialist agents for analysis, UX, design, planning, implementation, testing, docs, validation, audit, releases, and more. You get workflow modes for different kinds of work. You get gates that say, no, a confident paragraph is not the same as evidence. "
            "It is practical. It is strict. And, yes, it has a trailer park sense of humor because somebody had to make governance less beige."
        ),
        bg="0x0f1d26",
        accent="0x58a6ff",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="WHY NOW",
        title="AI Made Typing Cheap. It Did Not Make Trust Free.",
        subtitle="The bottleneck moved from creating code to believing code.",
        bullets=(
            "Generated code can outrun review, tests, and documentation.",
            "Helpful summaries can hide missing proof and broken assumptions.",
            "Without structure, every session becomes archaeology with autocomplete.",
        ),
        board_lines=(
            "Old bottleneck:",
            "typing code",
            "New bottleneck:",
            "knowing what is true",
            "Bubbles attacks the new bottleneck.",
        ),
        narration=(
            "Here is the shift. AI made typing cheap. That is excellent. It did not make trust free. The bottleneck moved. "
            "Before, you spent time writing code. Now you spend time asking, did this actually satisfy the requirement? Did it break a user flow? Did the agent change the test to match the bug? Did the documentation drift into a decorative fossil? "
            "Bubbles is built for that new bottleneck. It turns the work into artifacts, tests, evidence, and certification so you are not just nodding at a cheerful final answer."
        ),
        bg="0x24151a",
        accent="0xff7b72",
        voice_rate="-7%",
    ),
    Scene(
        eyebrow="THE FAILURE MODE",
        title="The Fake Done Tax Is Brutal",
        subtitle="Fake done feels fast until it comes back with a fake mustache.",
        bullets=(
            "A checked DoD item without raw output is just decorative Markdown.",
            "A passing test that cannot fail is a stage prop, not a guardrail.",
            "A final answer without evidence is a nice story, not delivery.",
        ),
        board_lines=(
            "Fake done tax:",
            "1. Reopened bugs",
            "2. Review confusion",
            "3. Stale docs",
            "4. Lost context",
            "5. Trust erosion",
        ),
        narration=(
            "Fake done is expensive. It feels fast because everybody gets to move on, and then two days later the same bug walks back in with a fake mustache and asks for database access. "
            "Bubbles is harsh about this on purpose. If a definition of done item is checked, it needs raw evidence. If a test claims to protect behavior, it must be able to fail. If a spec says done, the scopes underneath it need to be done too. "
            "This is not process for process. This is avoiding the fake done tax. And that tax has a terrible interest rate."
        ),
        bg="0x251414",
        accent="0xf85149",
        voice_rate="-7%",
    ),
    Scene(
        eyebrow="TPB OPS BOARD",
        title="Think Trailer Park Supervisor For Agent Work",
        subtitle="Everybody has a job. Nobody gets to repaint the office because they found a typo.",
        bullets=(
            "Analyst owns business outcomes and user truth.",
            "Design owns technical shape. Plan owns scopes and DoD.",
            "Implement ships code. Test verifies. Validate certifies. Audit reviews.",
        ),
        board_lines=(
            "Park rules:",
            "Analyst: what must be true",
            "Design: how it survives",
            "Plan: executable slices",
            "Implement: code",
            "Validate: prove it",
        ),
        narration=(
            "The TPB-style mental model is simple. Picture a tiny operations office with too many clipboards and one person saying, hold on, who owns this? That is Bubbles. "
            "Analyst owns business truth. UX owns interaction flows. Design owns technical architecture. Plan owns scopes, scenarios, and definitions of done. Implement writes code. Test verifies. Docs publishes truth. Validate owns certification. Audit reviews. "
            "It means diagnostic agents do not casually rewrite design. Implementers do not certify themselves. And nobody gets to repaint the entire office because they found one crooked label."
        ),
        bg="0x17251f",
        accent="0x3fb950",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="HOW IT MOVES",
        title="Intent Becomes A Work Trail",
        subtitle="Plain English goes in. Artifacts, scopes, evidence, and status come out.",
        bullets=(
            "Use /bubbles.workflow as the normal entry point for real work.",
            "The workflow resolves intent, picks owners, runs phases, and routes rework.",
            "The repo keeps the evidence trail so the next session can continue cleanly.",
        ),
        board_lines=(
            "User intent",
            "-> analysis",
            "-> design",
            "-> plan",
            "-> implement",
            "-> test",
            "-> validate",
            "-> audit",
        ),
        narration=(
            "Most of the time, you start with slash bubbles dot workflow. You do not need to memorize the whole crew. Just describe the work. Fix this regression. Improve this onboarding flow. Continue the current spec. Prepare the next release packet. "
            "Workflow resolves intent, picks the right owners, runs phases, enforces status ceilings, and routes rework when gates fail. The important part is that the work leaves a trail. "
            "So the next session does not start with, wait, were we touching auth? It starts with: here are the artifacts, here is the scope, here is the evidence, and here is what remains, which is much better."
        ),
        bg="0x102033",
        accent="0x58a6ff",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="REAL PAIN 1",
        title="Your UI Calls An Endpoint That Does Not Exist",
        subtitle="Classic. Beautiful. Terrible. Bubbles is allergic to it.",
        bullets=(
            "Vertical slice gates connect frontend calls to real backend routes.",
            "Integration checks prevent lonely endpoints and imaginary consumers.",
            "E2E scenarios verify the user-visible behavior, not just a happy log line.",
        ),
        board_lines=(
            "Common failure:",
            "frontend calls /api/thing",
            "router has /api/things",
            "test mocks it",
            "demo smiles",
            "user clicks. boom.",
        ),
        narration=(
            "Actual developer problem number one: the UI calls an endpoint that does not exist. Or the method is wrong. Or the response shape changed. Or the test intercepted the request and gave everybody a little bedtime story. "
            "Bubbles has vertical slice and integration completeness gates for exactly this kind of nonsense. Frontend calls need matching backend routes. New endpoints need consumers or external documentation. User-visible behavior needs scenarios and tests that exercise the real path. "
            "It is the difference between, the demo works on my laptop, and, the system path is actually wired. Tiny difference. Enormous Friday night."
        ),
        bg="0x2b2018",
        accent="0xffa657",
        voice_rate="-6%",
    ),
    Scene(
        eyebrow="REAL PAIN 2",
        title="The Test Passes Because It Avoids The Bug",
        subtitle="That is not testing. That is politely walking around the hole.",
        bullets=(
            "Regression tests need adversarial data that catches the old failure mode.",
            "Required E2E tests cannot silently return on missing behavior.",
            "Live-stack tests must hit the real stack, not canned responses.",
        ),
        board_lines=(
            "Bad test:",
            "if login failed: return",
            "Good test:",
            "assert protected page stays open",
            "assert required control works",
        ),
        narration=(
            "Actual developer problem number two: the test passes because it carefully avoids the bug. You have seen it. If login redirects, return. If the layout is missing, skip that assertion. If every fixture has the field the old bug required, congratulations, the regression test is ceremonial furniture. "
            "Bubbles pushes tests toward adversarial proof. A bug fix needs an input that would fail if the bug came back. Required E2E tests must fail loudly when behavior is missing. Live-stack tests cannot quietly fake the backend and still call themselves live. "
            "That one rule alone saves a lot of very confident nonsense."
        ),
        bg="0x191d23",
        accent="0xf2cc60",
        voice_rate="-6%",
    ),
    Scene(
        eyebrow="REAL PAIN 3",
        title="The Context Window Went For A Walk",
        subtitle="Long work needs durable state, not one heroic chat transcript.",
        bullets=(
            "Specs, designs, scopes, reports, validation, and state files carry truth forward.",
            "Recap and handoff agents make long work survivable across sessions.",
            "Workflow can continue from artifacts instead of restarting from fog.",
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
            "Actual developer problem number three: context vanishes. The chat was long. The work was complicated. Then the session compacts, the thread gets fuzzy, and now everybody is guessing what the last agent meant by mostly fixed. "
            "Bubbles centers durable artifacts. Specs, designs, scopes, reports, user validation, and state files carry the truth. Recap and handoff help move between sessions. Workflow can continue from the artifact state. "
            "That is boring in the best possible way. Boring is underrated. Boring lets you ship without reconstructing the plot from tire tracks."
        ),
        bg="0x0e2630",
        accent="0x39d0c8",
        voice_rate="-6%",
    ),
    Scene(
        eyebrow="INSTALL",
        title="Install Once, Then Start With Workflow",
        subtitle="The setup is deliberately boring because exciting setup is usually a warning sign.",
        bullets=(
            "Install the framework assets into a repo that needs agent delivery discipline.",
            "Bootstrap to add or refresh the local Bubbles layer safely.",
            "Then run /bubbles.workflow on one real problem and inspect the trail.",
        ),
        board_lines=(
            "Install:",
            "curl ... install.sh | bash",
            "Bootstrap:",
            "install.sh --bootstrap",
            "Run:",
            "/bubbles.workflow continue",
        ),
        narration=(
            "Installation is intentionally not dramatic. You install the framework assets into a repo. Bootstrap sets up the local Bubbles layer: agents, prompts, instructions, skills, templates, and governance surfaces. "
            "Then start with slash bubbles dot workflow. Give it a real problem. Not a toy problem if you can avoid it. Pick the annoying bug, the drifted feature, the release packet that always becomes a scavenger hunt. "
            "The point is not to admire the framework. The point is to see whether the evidence trail makes the work easier to trust."
        ),
        bg="0x102033",
        accent="0x58a6ff",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="SMALL JOBS",
        title="Use Specialists When You Need One Sharp Tool",
        subtitle="Not every question needs a full parade and three laminated forms.",
        bullets=(
            "Use grill to pressure-test an idea before the wrong work starts.",
            "Use code-review for engineering findings without product drift.",
            "Use docs, status, recap, or commands when the surface is narrow.",
        ),
        board_lines=(
            "/bubbles.grill",
            "/bubbles.code-review",
            "/bubbles.docs",
            "/bubbles.status",
            "/bubbles.recap",
        ),
        narration=(
            "For small jobs, use a specialist. If you want an idea pressure-tested, use grill. If you want engineering findings, use code-review. If you need docs aligned, use docs. If you need a clean status report, use status. If you need the story so far, use recap. "
            "This is important. Bubbles is not maximum process all the time. That would be awful. It is the right tool for the size of the work. "
            "Sometimes you need the full crew. Sometimes you need one person with a flashlight and a suspicious expression."
        ),
        bg="0x181f2b",
        accent="0xffa657",
        voice_rate="-4%",
    ),
    Scene(
        eyebrow="NORMAL JOBS",
        title="Workflow Is The Everyday Workhorse",
        subtitle="Features, bugs, docs loops, validation passes, and continuation work live here.",
        bullets=(
            "It can analyze, design, plan, implement, test, validate, audit, and route rework.",
            "It respects artifact ownership and mode-specific status ceilings.",
            "It keeps moving until work converges or the blocker is real.",
        ),
        board_lines=(
            "/bubbles.workflow fix bug",
            "/bubbles.workflow build feature",
            "/bubbles.workflow validate spec",
            "/bubbles.workflow continue",
        ),
        narration=(
            "For normal feature and bug work, workflow is the everyday workhorse. It can analyze the request, pick the next executable slice, route to owners, run phases, enforce gates, and packet rework when something fails. "
            "This is where Bubbles feels different from a prompt. You are not just asking, please be careful. You are running a workflow that understands artifact ownership, validation, test integrity, and certification boundaries. "
            "And when validate gets unimpressed, that is not a vibe problem. That is the system doing its job."
        ),
        bg="0x14231c",
        accent="0x3fb950",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="BIG JOBS",
        title="Goal, Sprint, And Releases Handle Bigger Outcomes",
        subtitle="When the work spans phases, give a coordinator the steering wheel.",
        bullets=(
            "goal drives one outcome through a full convergence loop.",
            "sprint prioritizes multiple goals inside a time budget.",
            "releases prepares phase packets, carry-forward, and launch context.",
        ),
        board_lines=(
            "/bubbles.goal ship one outcome",
            "/bubbles.sprint goals + budget",
            "/bubbles.releases phase packet",
            "Use bigger controllers for bigger blast radius.",
        ),
        narration=(
            "For bigger outcomes, Bubbles has bigger controllers. Goal handles one outcome across phases. Sprint handles several goals with prioritization and a time budget. Releases handles phase packets, launch context, carry-forward, and the business side of shipping. "
            "This is useful when the work is too broad for one specialist and too important for a vague instruction. You give the coordinator the steering wheel, then make the workflow prove what happened. "
            "It is still agentic work. It just has lane markers now. Very fancy. Almost civilized."
        ),
        bg="0x202033",
        accent="0xd2a8ff",
        voice_rate="-6%",
    ),
    Scene(
        eyebrow="THE DEMO DAY",
        title="One Checkout Bug, Two Different Futures",
        subtitle="Without structure, it comes back. With Bubbles, it leaves fingerprints.",
        bullets=(
            "Request: checkout fails when availability changes during payment.",
            "Bubbles routes outcome, design, scope, implementation, adversarial tests, validation, and audit.",
            "Closeout names files changed, evidence observed, and remaining risk.",
        ),
        board_lines=(
            "Flow:",
            "reproduce",
            "design transaction boundary",
            "plan scenarios",
            "implement",
            "adversarial regression",
            "validate evidence",
        ),
        narration=(
            "Picture one real bug. Checkout fails when availability changes during payment. Without structure, an agent patches a handler, adds a happy-path test, says done, and everybody hopes physics takes the weekend off. "
            "With Bubbles, analyst clarifies the business outcome. Design shapes the transaction boundary. Plan creates scenarios and definitions of done. Implement changes code. Test adds adversarial regression coverage. Chaos can poke timing. Validate checks evidence. Audit names residual risk. "
            "Same AI assistance. Much better operating loop. The difference is not drama. The difference is proof."
        ),
        bg="0x111827",
        accent="0x39d0c8",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="WHY DEVS CARE",
        title="It Reduces Rework, Not Creativity",
        subtitle="The goal is not to slow you down. It is to stop paying twice.",
        bullets=(
            "Less time reconstructing what the last session actually did.",
            "Less time arguing with unsupported completion claims.",
            "More time making product decisions with verified implementation state.",
        ),
        board_lines=(
            "What you get back:",
            "continuity",
            "review clarity",
            "fewer reopened bugs",
            "cleaner handoffs",
            "higher trust",
        ),
        narration=(
            "The obvious worry is, does this slow me down? Sometimes it adds a step. Usually it removes five later. That is the trade. "
            "Bubbles reduces rework. It reduces mystery. It reduces the weird feeling where a lot of code changed, but nobody can name the user behavior that improved. "
            "It does not replace creativity. It protects it from cleanup debt. Because nothing kills momentum like spending Thursday proving Tuesday was imaginary."
        ),
        bg="0x101f2a",
        accent="0x58a6ff",
        voice_rate="-6%",
    ),
    Scene(
        eyebrow="THE PAYOFF",
        title="Evidence Becomes Trust",
        subtitle="That is the whole trick. Simple sentence. Hard habit. Huge payoff.",
        bullets=(
            "Intent becomes artifact. Artifact becomes scope.",
            "Scope becomes implementation. Implementation becomes evidence.",
            "Evidence becomes trust, and trust is what lets agents take bigger swings safely.",
        ),
        board_lines=(
            "Intent",
            "-> artifact",
            "-> scope",
            "-> implementation",
            "-> evidence",
            "-> trust",
        ),
        narration=(
            "Here is the payoff. Bubbles does not make agents magic. It makes them accountable. That is better. Magic is hard to debug. Accountability has file paths. "
            "Intent becomes artifact. Artifact becomes scope. Scope becomes implementation. Implementation becomes evidence. Evidence becomes trust. "
            "And trust is what lets you give agents bigger work without handing them the keys to the whole park and hoping they remember where the brakes are."
        ),
        bg="0x0f1d26",
        accent="0x39d0c8",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="TRY IT",
        title="Run It On One Painful Workflow",
        subtitle="Do not boil the ocean. Pick the bug that keeps coming back with a fake mustache.",
        bullets=(
            "Install Bubbles in a repo where agent work needs stronger discipline.",
            "Run /bubbles.workflow on one real feature, bug, or cleanup outcome.",
            "Judge the artifacts and evidence, not the charm of the final answer.",
        ),
        board_lines=(
            "1. Install",
            "2. Bootstrap",
            "3. Run workflow",
            "4. Inspect evidence",
            "5. Decide with receipts",
        ),
        narration=(
            "So try it on one painful workflow. Not your whole company. Not every repository you have ever loved. One real workflow. "
            "Pick the bug that keeps coming back. Pick the feature where specs and implementation drift. Pick the release packet that always becomes archaeology. Install Bubbles, bootstrap the repo, run slash bubbles dot workflow, and inspect the trail. "
            "If you want AI coding help that moves fast and still shows its work, Bubbles is worth a serious look. It is strict. It is useful. And it is just funny enough that the clipboard does not ruin the day."
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


def add_wrapped_text(
    lines: list[str],
    layer: int,
    start: float,
    end: float,
    value: str,
    x: int,
    y: int,
    size: int,
    color: str,
    max_chars: int,
    line_gap: int,
    alpha: str = "00",
    bold: bool = False,
    font: str = FONT,
) -> int:
    wrapped = wrap_line(value, max_chars)
    for line_index, wrapped_line in enumerate(wrapped):
        lines.append(
            dialogue(
                layer,
                start,
                end,
                text(wrapped_line, x, y + line_index * line_gap, size, color, alpha, 7, bold, font),
            )
        )
    return y + max(1, len(wrapped)) * line_gap


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
    lines = ["# Bubbles YouTube Info Guide Voiceover Transcript", ""]
    lines.append(f"Voice: {VOICE}")
    lines.append("Note: generated narration uses varied rates, punctuation, and conversational phrasing for a more natural delivery.")
    lines.append("")
    for index, scene in enumerate(SCENES, start=1):
        lines.append(f"## {index:02d}. {scene.title}")
        lines.append("")
        lines.append(f"Rate: {scene.voice_rate}")
        lines.append("")
        lines.append(scene.narration)
        lines.append("")
    return "\n".join(lines)


def add_background_motif(lines: list[str], start: float, end: float, scene: Scene, index: int) -> None:
    for grid_x in range(260, WIDTH, 260):
        lines.append(dialogue(1, start, end, rect(grid_x, 0, 1, HEIGHT, "0xffffff", "ED")))
    for grid_y in range(240, HEIGHT, 240):
        lines.append(dialogue(1, start, end, rect(0, grid_y, WIDTH, 1, "0xffffff", "ED")))
    for dot_index in range(8):
        x = 1255 + ((dot_index * 137 + index * 53) % 520)
        y = 260 + ((dot_index * 169 + index * 79) % 620)
        size = 44 + ((dot_index + index) % 5) * 18
        lines.append(dialogue(2, start, end, text("o", x, y, size, scene.accent, "AD", 5, True)))


def add_bullet_list(lines: list[str], start: float, end: float, scene: Scene) -> None:
    cursor = 494
    for bullet_index, bullet in enumerate(scene.bullets):
        wrapped = wrap_line(bullet, 58)
        box_height = 54 + len(wrapped) * 31
        lines.append(dialogue(2, start, end, rect(112, cursor - 18, 1080, box_height, "0x000000", "93")))
        lines.append(dialogue(2, start, end, rect(112, cursor - 18, 10, box_height, scene.accent, "06")))
        lines.append(dialogue(3, start, end, text(str(bullet_index + 1), 146, cursor - 1, 29, scene.accent, "00", 7, True, MONO_FONT)))
        text_y = cursor - 1
        for line_index, bullet_line in enumerate(wrapped):
            lines.append(dialogue(3, start, end, text(bullet_line, 206, text_y + line_index * 31, 28, "0xffffff", "18", 7)))
        cursor += box_height + 20


def add_board(lines: list[str], start: float, end: float, scene: Scene) -> None:
    board_left = 1240
    board_top = 438
    board_width = 588
    board_height = 502
    lines.append(dialogue(2, start, end, rect(board_left, board_top, board_width, board_height, "0x05070d", "38")))
    lines.append(dialogue(2, start, end, rect(board_left, board_top, board_width, 48, scene.accent, "08")))
    lines.append(dialogue(3, start, end, text("PARK OPS BOARD", board_left + 24, board_top + 13, 21, "0x111827", "00", 7, True, MONO_FONT)))

    cursor = board_top + 72
    for line_index, board_line in enumerate(scene.board_lines):
        is_heading = board_line.endswith(":") or line_index == 0
        font_size = 23 if is_heading else 21
        line_color = scene.accent if is_heading else "0xffffff"
        cursor = add_wrapped_text(
            lines,
            3,
            start,
            end,
            board_line,
            board_left + 28,
            cursor,
            font_size,
            line_color,
            39,
            28,
            "00" if is_heading else "08",
            is_heading,
            MONO_FONT,
        )
        cursor += 12 if is_heading else 8


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
        lines.append(dialogue(0, start, end, rect(0, 0, WIDTH, HEIGHT, scene.bg)))
        lines.append(dialogue(1, start, end, rect(0, 0, 52, HEIGHT, scene.accent)))
        lines.append(dialogue(1, start, end, rect(108, 72, 350, 48, scene.accent, "08")))
        lines.append(dialogue(1, start, end, rect(108, 210, 1710, 4, scene.accent, "18")))
        lines.append(dialogue(1, start, end, rect(1488, 72, 330, 92, "0x000000", "86")))
        lines.append(dialogue(2, start, end, text(f"{index:02d}/{len(SCENES):02d}", 1530, 96, 35, scene.accent, "00", 7, True, MONO_FONT)))
        add_background_motif(lines, start, end, scene, index)

        lines.append(dialogue(3, start, end, text(scene.eyebrow, 132, 88, 25, "0x111827", "00", 7, True, MONO_FONT)))
        title_y = 248
        for line_index, title_line in enumerate(wrap_line(scene.title, 38)):
            lines.append(dialogue(3, start, end, text(title_line, 108, title_y + line_index * 72, 62, "0xffffff", "00", 7, True)))
        subtitle_y = 366 + max(0, len(wrap_line(scene.title, 38)) - 1) * 47
        for line_index, subtitle_line in enumerate(wrap_line(scene.subtitle, 76)):
            lines.append(dialogue(3, start, end, text(subtitle_line, 112, subtitle_y + line_index * 39, 32, "0xffffff", "22", 7)))

        add_bullet_list(lines, start, end, scene)
        add_board(lines, start, end, scene)

        footer = "Bubbles | fun informational guide for accountable AI coding work"
        lines.append(dialogue(3, start, end, text(footer, 112, 1010, 23, "0xffffff", "76", 7)))

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
        "160k",
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
        "18",
        "-pix_fmt",
        "yuv420p",
        "-c:a",
        "aac",
        "-b:a",
        "160k",
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

    with tempfile.TemporaryDirectory(prefix="bubbles-youtube-info-") as temp_dir_name:
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

        ass_path = temp_dir / "bubbles-youtube-info.ass"
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
