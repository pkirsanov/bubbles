#!/usr/bin/env python3
"""Render a narrated Bubbles instructional overview MP4."""

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
VOICE_RATE = "-6%"
VOICE_VOLUME = "+0%"
SCENE_PAD_SECONDS = 0.85


@dataclass(frozen=True)
class Scene:
    title: str
    eyebrow: str
    subtitle: str
    bullets: tuple[str, ...]
    command_lines: tuple[str, ...]
    narration: str
    bg: str
    accent: str


SCENES = [
    Scene(
        eyebrow="OVERVIEW",
        title="What Bubbles Is",
        subtitle="Spec-driven AI agent orchestration for VS Code Copilot.",
        bullets=(
            "Turns plain-English work into a delivery pipeline.",
            "Uses 37 specialized agents, 34 workflow modes, and 65 gates.",
            "Keeps humans in control while forcing evidence for claims.",
        ),
        command_lines=(
            "/bubbles.workflow fix the calendar bug",
            "/bubbles.workflow improve search for mobile users",
            "/bubbles.workflow continue",
        ),
        narration=(
            "Bubbles is a spec-driven agent orchestration system for VS Code Copilot. "
            "Instead of asking one assistant to remember every job, Bubbles routes work through specialists. "
            "It can start from a vague sentence, build the required artifacts, run implementation, test, validation, audit, and docs, "
            "then leave a paper trail. Think less magic button, more accountable delivery crew with very serious clipboards."
        ),
        bg="0x101827",
        accent="0x58a6ff",
    ),
    Scene(
        eyebrow="THE PROBLEM",
        title="Modern Agent Work Gets Messy",
        subtitle="Good intentions, stale plans, and suspiciously confident done-claims.",
        bullets=(
            "Requirements drift away from implementation.",
            "Tests get summarized instead of actually run.",
            "Docs, scopes, and state files start telling different stories.",
        ),
        command_lines=(
            "Symptom: 'Looks done.'",
            "Reality: build failed, docs stale, no evidence.",
            "Diagnosis: vibes tried to impersonate verification.",
        ),
        narration=(
            "The problem Bubbles solves is not that agents cannot write code. They can. The problem is operational discipline. "
            "A single assistant can skip context, over-trust stale docs, say tests passed without proof, or call a feature complete while scopes still have open work. "
            "Bubbles treats that as the real bug. Vibes are not a test runner, and a confident paragraph is not certification."
        ),
        bg="0x211629",
        accent="0xbc8cff",
    ),
    Scene(
        eyebrow="HOW IT SOLVES IT",
        title="Route Work Through Owners",
        subtitle="Every artifact has an owner; every phase has a job.",
        bullets=(
            "Analyst owns business truth in spec.md.",
            "Design owns architecture; plan owns scopes and DoD.",
            "Validate owns certification; audit owns final compliance verdicts.",
        ),
        command_lines=(
            "request -> workflow -> owner agents -> evidence",
            "diagnostic agents route findings; they do not silently edit foreign artifacts",
        ),
        narration=(
            "Bubbles solves the mess by giving work a structure. Business analysis, user experience, design, planning, implementation, testing, validation, audit, and docs are separate jobs. "
            "Each agent has ownership boundaries. An audit agent can find a problem, but it does not pretend to be the design owner. A validation agent can reopen work, but certification state belongs to validation. "
            "That separation prevents artifact wrestling, which is a technical term meaning everybody stop touching the same file at once."
        ),
        bg="0x10231f",
        accent="0x3fb950",
    ),
    Scene(
        eyebrow="INSTALL",
        title="Install In A Downstream Repo",
        subtitle="Bootstrap gives the target project a Bubbles-ready control surface.",
        bullets=(
            "Run the installer from the project you want to equip.",
            "Use --bootstrap to create project config and specs/ if missing.",
            "Pin a version when you need reproducible adoption.",
        ),
        command_lines=(
            "curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/main/install.sh | bash -s -- --bootstrap",
            "curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/v1.0.0/install.sh | bash -s -- --bootstrap",
        ),
        narration=(
            "For a downstream project, installation is intentionally boring. From the target repository, run the installer with bootstrap. "
            "Bootstrap detects the project, creates the Copilot instructions, terminal discipline, constitution, command registry, and specs directory when needed. "
            "If you are maintaining the Bubbles source repository itself, do not run the installer inside it. Edit the framework directly and validate with the framework commands. Yes, boring is good here. Boring means fewer emergency sandwiches."
        ),
        bg="0x2a2112",
        accent="0xd29922",
    ),
    Scene(
        eyebrow="FIRST USE",
        title="Start With Workflow",
        subtitle="Most users should begin with the universal entry point.",
        bullets=(
            "Accepts plain English, structured requests, or continue.",
            "Resolves intent through super and picks work through iterate.",
            "Chooses the right workflow mode instead of making you memorize it.",
        ),
        command_lines=(
            "/bubbles.workflow build a new notification system",
            "/bubbles.workflow fix login redirect regression",
            "/bubbles.workflow spend 2 hours on whatever needs attention",
        ),
        narration=(
            "The default way to use Bubbles is slash bubbles dot workflow. Describe the outcome. Workflow resolves the intent, asks the supervisor layer for command interpretation when needed, picks the next useful work, and runs the specialist chain. "
            "For most requests, you do not need to know whether the right mode is bugfix fastlane, full delivery, improve existing, or validate only. Workflow handles the routing so you can focus on what you want done."
        ),
        bg="0x121f33",
        accent="0x79c0ff",
    ),
    Scene(
        eyebrow="SIMPLE AGENT RUNS",
        title="Use Specialists Directly When The Job Is Narrow",
        subtitle="Direct agents are useful for focused analysis, planning, tests, or docs.",
        bullets=(
            "analyst discovers business requirements and scenarios.",
            "plan decomposes spec and design into scopes and DoD.",
            "test verifies, fixes gaps, and records evidence.",
        ),
        command_lines=(
            "/bubbles.analyst specs/123-search mode: review output: diagnostic",
            "/bubbles.plan specs/123-search",
            "/bubbles.test specs/123-search",
        ),
        narration=(
            "You can also run individual specialists. Use analyst when you want business requirements, actors, use cases, competitive gaps, or scenario discovery. "
            "Use plan when a spec and design need executable scopes, Gherkin scenarios, test plans, and definitions of done. Use test when you need verification and gap fixing. "
            "The trick is to use direct specialists for narrow work. If the work crosses phases, go back to workflow and let the coordinator drive."
        ),
        bg="0x191b24",
        accent="0x39d0c8",
    ),
    Scene(
        eyebrow="COORDINATORS",
        title="Coordinator Agents Keep Work Moving",
        subtitle="They select, route, and resume without becoming artifact owners.",
        bullets=(
            "workflow is the universal front door.",
            "iterate selects the next executable slice.",
            "bug reproduces, packets, routes, and drives closure.",
        ),
        command_lines=(
            "/bubbles.iterate continue the active scope",
            "/bubbles.bug investigate broken checkout calendar",
            "/bubbles.workflow continue",
        ),
        narration=(
            "Coordinator agents are different from owner agents. They keep work moving, but they do not own every artifact. Workflow is the front door. Iterate chooses the next executable slice when you are already in motion. Bug handles defect discovery, reproduction, packet creation, routing, and closure. "
            "That means less manual traffic control. Nobody has to stand in the hallway yelling, who owns this? The answer is in the system. Usually on a clipboard."
        ),
        bg="0x241616",
        accent="0xf85149",
    ),
    Scene(
        eyebrow="AUTONOMOUS GOALS",
        title="Goal, Sprint, And Release",
        subtitle="For bigger jobs, use higher-level controllers.",
        bullets=(
            "goal executes one feature, bug, ops task, or hardening objective.",
            "sprint prioritizes multiple goals within a time budget.",
            "releases produces phase packets and carry-forward planning.",
        ),
        command_lines=(
            "/bubbles.goal ship the owner export flow end to end",
            "/bubbles.sprint goals: fix auth, harden search, update docs; budget: 2h",
            "/bubbles.releases phase 2 release packet",
        ),
        narration=(
            "For larger work, Bubbles has higher-level controllers. Goal is for one outcome: a feature, bug, operations task, or hardening objective. It plans, implements, tests, validates, and loops until convergence or a real blocker. "
            "Sprint accepts multiple goals and a time budget, then prioritizes and executes. Releases creates phase release packets, carry-forward plans, and cross-product coordination. Use these when the work is bigger than one specialist but still needs accountable structure."
        ),
        bg="0x102a2a",
        accent="0x3fb950",
    ),
    Scene(
        eyebrow="STRUCTURE",
        title="Bubbles Is An Artifact System",
        subtitle="The framework is strict because the files are the contract.",
        bullets=(
            "spec.md explains the outcome and business scenarios.",
            "design.md explains the technical approach.",
            "scopes.md, report.md, uservalidation.md, and state.json track execution.",
        ),
        command_lines=(
            "specs/123-feature/spec.md",
            "specs/123-feature/design.md",
            "specs/123-feature/scopes.md",
            "specs/123-feature/report.md",
            "specs/123-feature/state.json",
        ),
        narration=(
            "Structurally, Bubbles is an artifact system. Work lives under feature or bug folders. The spec states the outcome and business behavior. The design explains the technical approach. Scopes define executable slices, scenarios, test plans, and definitions of done. "
            "The report captures execution evidence. User validation remains the human acceptance surface. State tracks workflow and certification metadata. If those files disagree, Bubbles treats it as drift, not as a fun little mystery."
        ),
        bg="0x111827",
        accent="0xbc8cff",
    ),
    Scene(
        eyebrow="WORKFLOW MODES",
        title="Modes Encode Delivery Shape",
        subtitle="Different problems need different phase chains.",
        bullets=(
            "full-delivery is the maximum-assurance default.",
            "bugfix-fastlane reproduces, fixes, regresses, validates, and audits.",
            "docs-only, validate-only, improve-existing, and release-planning tune the path.",
        ),
        command_lines=(
            "mode: full-delivery",
            "mode: bugfix-fastlane",
            "mode: improve-existing",
            "mode: release-planning-to-doc",
        ),
        narration=(
            "Workflow modes encode the shape of delivery. Full delivery is the broad, maximum-assurance path. Bugfix fastlane focuses on reproduction, repair, regression, validation, and audit. Improve existing reconciles stale truth before changing a feature. Docs only and validate only cap what the agent is allowed to do. "
            "This matters because a documentation pass should not secretly become a production rewrite. That is how software gets a fake mustache and sneaks into release notes."
        ),
        bg="0x20182e",
        accent="0xd29922",
    ),
    Scene(
        eyebrow="GATES",
        title="65 Gates Say: Prove It",
        subtitle="Gates are the rules that stop fake completion.",
        bullets=(
            "Artifact, design, scope, test, evidence, docs, validation, and audit gates.",
            "Implementation reality scan blocks stubs, hardcoded data, and fake handlers.",
            "Vertical slice and regression gates protect real user behavior.",
        ),
        command_lines=(
            "G021 anti_fabrication_gate",
            "G025 per_dod_item_raw_evidence_gate",
            "G028 implementation_reality_scan_gate",
            "G035 vertical_slice_gate",
            "G070 outcome_contract_gate",
        ),
        narration=(
            "The gates are where Bubbles gets strict. There are gates for required artifacts, design readiness, test integrity, raw evidence, documentation sync, validation, audit, implementation reality, vertical slice completeness, scenario contracts, outcome contracts, and workflow consistency. "
            "The short version is simple: if an agent says a thing is done, Bubbles asks for proof. If proof is missing, the answer is no. Not maybe. Not good enough. Just no."
        ),
        bg="0x251414",
        accent="0xf85149",
    ),
    Scene(
        eyebrow="VALIDATION",
        title="Evidence Beats Narration",
        subtitle="Certification is separate from execution claims.",
        bullets=(
            "Every checked DoD item needs raw evidence, not summaries.",
            "All scopes must be done before a spec can be done.",
            "validate owns certification state; other agents submit claims or rework packets.",
        ),
        command_lines=(
            "state.json.execution: runtime claims",
            "state.json.certification: validate-owned authority",
            "report.md: raw command output and observed evidence",
        ),
        narration=(
            "Validation is where Bubbles separates execution claims from certification authority. A specialist may say it ran tests. The report must show real output. State execution can record runtime claims. Certification belongs to validate. "
            "A checked definition-of-done item without evidence is invalid. A spec with unfinished scopes cannot be done. If all of that sounds strict, excellent. The whole point is to make fake progress more expensive than real progress."
        ),
        bg="0x101f2a",
        accent="0x58a6ff",
    ),
    Scene(
        eyebrow="SCENARIOS",
        title="Scenarios Become Contracts",
        subtitle="User-visible behavior gets stable scenario IDs and regression proof.",
        bullets=(
            "Gherkin scenarios define the business behavior.",
            "scenario-manifest.json links behavior to tests and evidence.",
            "Regression contracts stop old behavior from being weakened quietly.",
        ),
        command_lines=(
            "Given a host has a published booking page",
            "When a guest searches valid dates",
            "Then matching availability is shown with a real live-stack assertion",
        ),
        narration=(
            "Scenario contracts are one of the most important structural ideas. Bubbles wants user-visible behavior written as scenarios, then tied to tests and evidence. The scenario manifest keeps stable identifiers for changed behavior, so validation can replay or verify the linked proof. "
            "Regression contracts stop agents from quietly weakening old behavior to make new work pass. In other words, no moving the goalposts while the referee is looking at the sandwich table."
        ),
        bg="0x1b2330",
        accent="0x39d0c8",
    ),
    Scene(
        eyebrow="STRICTNESS",
        title="What Bubbles Refuses",
        subtitle="The rules are there because agents are excellent at sounding confident.",
        bullets=(
            "No fabricated evidence, no batch-checking, no silent skips.",
            "No stubs, fake implementations, or hidden defaults in delivered code.",
            "No foreign-artifact edits by agents that do not own the surface.",
        ),
        command_lines=(
            "Forbidden: 'all tests pass' without execution output",
            "Forbidden: checking every DoD box in one sweep",
            "Forbidden: audit agent rewriting design.md directly",
        ),
        narration=(
            "Bubbles refuses a few tempting shortcuts. It rejects fabricated evidence, batch-checked definitions of done, silent test skips, TODO confetti, stubs pretending to be implementation, and diagnostic agents editing artifacts they do not own. "
            "This is not bureaucracy for sport. It is a defense against the exact failure mode where an assistant sounds helpful while quietly leaving the system less trustworthy. A charming mess is still a mess."
        ),
        bg="0x2a1818",
        accent="0xf85149",
    ),
    Scene(
        eyebrow="RECIPES",
        title="Pick The Right Size Tool",
        subtitle="Small command, coordinator, or autonomous controller: choose by blast radius.",
        bullets=(
            "Small: run a specialist for focused diagnostic or artifact work.",
            "Medium: use workflow for most feature, bug, validation, or doc loops.",
            "Large: use goal, sprint, or releases for autonomous multi-phase work.",
        ),
        command_lines=(
            "Small: /bubbles.grill review this idea",
            "Medium: /bubbles.workflow fix checkout bug",
            "Large: /bubbles.sprint goals: release hardening, docs, audit; budget: 4h",
        ),
        narration=(
            "A practical rule: choose by blast radius. For a narrow diagnostic or artifact update, run the specialist. For a feature, bug, validation pass, or documentation loop, use workflow. For bigger outcomes, use goal, sprint, or releases. "
            "If you are unsure, start with workflow. It can route smaller. Starting with a giant autonomous sprint for a two-line question is how you end up with a parade permit and no parade."
        ),
        bg="0x14231c",
        accent="0x3fb950",
    ),
    Scene(
        eyebrow="WRAP-UP",
        title="Bubbles Makes Work Accountable",
        subtitle="It does not replace judgment; it gives judgment a safer operating loop.",
        bullets=(
            "Overview: orchestrate specialist agents around verified artifacts.",
            "Use: install, bootstrap, then start with /bubbles.workflow.",
            "Trust: gates, evidence, scenarios, validation, and certification keep it honest.",
        ),
        command_lines=(
            "/bubbles.workflow continue",
            "/bubbles.goal ship one outcome completely",
            "/bubbles.releases prepare the next phase packet",
        ),
        narration=(
            "That is Bubbles: a structured way to turn agent assistance into accountable software work. It gives you installable framework files, named specialists, workflow modes, artifacts, gates, scenario contracts, validation, and certification. "
            "It does not remove engineering judgment. It gives judgment a safer loop to operate in. Start with workflow, keep the evidence real, and let the crew do the jobs they actually own."
        ),
        bg="0x151515",
        accent="0xffffff",
    ),
]


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
        rate=VOICE_RATE,
        volume=VOICE_VOLUME,
    )
    await communicate.save(str(output_path))


async def synthesize_all(scene_audio_paths: list[Path]) -> None:
    for scene, path in zip(SCENES, scene_audio_paths):
        print(f"Synthesizing narration: {scene.eyebrow} - {scene.title}")
        await synthesize_scene_audio(scene, path)


def build_transcript() -> str:
    lines = ["# Bubbles Instructional Guide Voiceover Transcript", ""]
    lines.append(f"Voice: {VOICE}")
    lines.append("")
    for index, scene in enumerate(SCENES, start=1):
        lines.append(f"## {index:02d}. {scene.title}")
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
    lines.append(dialogue(0, 0, total, rect(0, 0, WIDTH, HEIGHT, "0x101827")))

    for index, (scene, timing) in enumerate(zip(SCENES, scene_timings), start=1):
        start, end = timing
        accent = scene.accent
        lines.append(dialogue(0, start, end, rect(0, 0, WIDTH, HEIGHT, scene.bg)))
        lines.append(dialogue(1, start, end, rect(0, 0, 42, HEIGHT, accent)))
        lines.append(dialogue(1, start, end, rect(112, 78, 270, 44, accent, "08")))
        lines.append(dialogue(1, start, end, rect(112, 207, 1695, 4, accent, "18")))
        lines.append(dialogue(1, start, end, rect(1488, 78, 320, 88, "0x000000", "86")))
        lines.append(dialogue(2, start, end, text(f"{index:02d}/{len(SCENES):02d}", 1530, 99, 35, accent, "00", 7, True, MONO_FONT)))

        for grid_x in range(240, WIDTH, 240):
            lines.append(dialogue(1, start, end, rect(grid_x, 0, 1, HEIGHT, "0xffffff", "EB")))
        for grid_y in range(240, HEIGHT, 240):
            lines.append(dialogue(1, start, end, rect(0, grid_y, WIDTH, 1, "0xffffff", "EB")))

        for bubble_index in range(5):
            x = 1340 + ((bubble_index * 113 + index * 41) % 400)
            y = 302 + ((bubble_index * 157 + index * 67) % 560)
            size = 62 + ((bubble_index + index) % 4) * 22
            lines.append(dialogue(2, start, end, text("o", x, y, size, accent, "A5", 5, True)))

        lines.append(dialogue(3, start, end, text(scene.eyebrow, 136, 89, 25, "0x111827", "00", 7, True, MONO_FONT)))
        for line_index, title_line in enumerate(wrap_line(scene.title, 36)):
            lines.append(dialogue(3, start, end, text(title_line, 112, 252 + line_index * 76, 66, "0xffffff", "00", 7, True)))
        subtitle_y = 370 + max(0, len(wrap_line(scene.title, 36)) - 1) * 50
        for line_index, subtitle_line in enumerate(wrap_line(scene.subtitle, 72)):
            lines.append(dialogue(3, start, end, text(subtitle_line, 116, subtitle_y + line_index * 42, 34, "0xffffff", "24", 7)))

        bullet_start_y = 500
        for bullet_index, bullet in enumerate(scene.bullets):
            y = bullet_start_y + bullet_index * 106
            lines.append(dialogue(2, start, end, rect(118, y - 20, 1085, 78, "0x000000", "94")))
            lines.append(dialogue(2, start, end, rect(118, y - 20, 10, 78, accent, "05")))
            lines.append(dialogue(3, start, end, text(str(bullet_index + 1), 154, y - 6, 30, accent, "00", 7, True, MONO_FONT)))
            for line_index, bullet_line in enumerate(wrap_line(bullet, 62)):
                lines.append(dialogue(3, start, end, text(bullet_line, 214, y - 6 + line_index * 34, 30, "0xffffff", "18", 7)))

        code_top = 482
        code_left = 1262
        code_width = 548
        code_height = max(210, 54 + len(scene.command_lines) * 44)
        lines.append(dialogue(2, start, end, rect(code_left, code_top, code_width, code_height, "0x05070d", "40")))
        lines.append(dialogue(2, start, end, rect(code_left, code_top, code_width, 42, accent, "10")))
        lines.append(dialogue(3, start, end, text("EXAMPLE", code_left + 24, code_top + 10, 21, "0x111827", "00", 7, True, MONO_FONT)))
        for line_index, command in enumerate(scene.command_lines):
            y = code_top + 62 + line_index * 44
            for wrapped_index, command_line in enumerate(wrap_line(command, 49)):
                color = accent if line_index == 0 and wrapped_index == 0 else "0xffffff"
                lines.append(dialogue(3, start, end, text(command_line, code_left + 28, y + wrapped_index * 30, 23, color, "00", 7, False, MONO_FONT)))

        footer = "Bubbles detailed guide | overview, install, scenarios, workflows, gates, certification"
        lines.append(dialogue(3, start, end, text(footer, 116, 1010, 24, "0xffffff", "76", 7)))

    return "\n".join(lines) + "\n"


def pad_scene_audio(ffmpeg_bin: Path, source: Path, output: Path, duration: float) -> None:
    command = [
        str(ffmpeg_bin),
        "-y",
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
    subprocess.run(command, check=True)


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

    with tempfile.TemporaryDirectory(prefix="bubbles-instructional-") as temp_dir_name:
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
                [str(args.ffmpeg_bin), "-y", "-i", str(combined_audio), "-c", "copy", str(args.audio_output)],
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

        ass_path = temp_dir / "bubbles-instructional.ass"
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
