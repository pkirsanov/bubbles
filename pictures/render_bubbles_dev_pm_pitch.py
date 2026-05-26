#!/usr/bin/env python3
"""Render the dev/PM/product pitch video for Bubbles.

Audio pipeline (chosen via A/B audition):
- Voice: en-US-AndrewMultilingualNeural (newest Microsoft multilingual male).
- NO loudnorm anywhere.
- Per-scene MP3 -> PCM s16le at native 24 kHz mono. Pad only. No resample yet.
- Concat as PCM s16le at 24 kHz mono. Lossless splice.
- Single AAC pass at the end: 256 kbps, soxr precision-28 resample to 48 kHz
  stereo, dither=triangular_hp. This is the single resample stage in the whole
  pipeline. The audition variant `aac-256-clean` was chosen as the cleanest.
- Support an --audio-only mode so the voiceover can be auditioned before the
  full video is rendered.

The renderer reuses the ASS overlay, scene timing, and transcript helpers from
``render_bubbles_youtube_infoguide`` but overrides the audio pipeline.
"""

from __future__ import annotations

import argparse
import asyncio
import subprocess
import sys
import tempfile
from pathlib import Path

import render_bubbles_youtube_infoguide as base
from render_bubbles_youtube_infoguide import (
    FONT,
    FPS,
    HEIGHT,
    MONO_FONT,
    Scene,
    WIDTH,
    add_wrapped_text,
    dialogue,
    hex_to_ass_bgr,
    rect,
    require_file,
    text,
    wrap_line,
)

# Voice / pacing
VOICE = "en-US-AndrewMultilingualNeural"
VOICE_VOLUME = "+0%"
SCENE_PAD_SECONDS = 0.78

# PCM intermediate (kept at edge-tts native rate to avoid a double-resample).
# edge-tts emits 24 kHz mono MP3, so the PCM intermediates stay at 24 kHz mono
# all the way through pad and concat. The single resample to the delivery rate
# happens once in the final AAC encode via soxr precision-28 dithered.
INTERMEDIATE_SAMPLE_RATE = "24000"
INTERMEDIATE_CHANNELS = "1"

# Final delivery format (single AAC pass, single resample stage).
AUDIO_BITRATE = "256k"
AUDIO_SAMPLE_RATE = "48000"
AUDIO_CHANNELS = "2"
FINAL_AFILTER = (
    "aresample=resampler=soxr:precision=28:dither_method=triangular_hp"
    f":osr={AUDIO_SAMPLE_RATE}"
)

# Video encoding
VIDEO_CRF = "18"
VIDEO_PRESET = "fast"


SCENES: tuple[Scene, ...] = (
    Scene(
        eyebrow="THE PROBLEM",
        title="Done Is The Most Expensive Word In Software",
        subtitle="AI made it cheap to say. It did not make it cheap to verify.",
        bullets=(
            "An agent can finish a task and still leave the work undone.",
            "A confident summary can hide the parts that quietly broke.",
            "The team pays for the gap: rework, regressions, lost trust.",
        ),
        board_lines=(
            "Symptom:",
            "agent says done",
            "user finds it broken",
            "team loses a day",
            "Repeat next sprint.",
        ),
        narration=(
            "Here is the problem. Done is the most expensive word in software. AI made it cheap to say. It did not make it cheap to verify. "
            "An agent finishes. The summary sounds complete. Then a user finds the part that broke, and the team spends the next day untangling it. "
            "Bubbles closes that gap by replacing trust with structure: specs as the source of truth, mechanical gates that block bad transitions, and raw evidence on every checkbox. "
            "Here is what that means for your role."
        ),
        bg="0x101722",
        accent="0x39d0c8",
        voice_rate="-2%",
    ),
    Scene(
        eyebrow="DEVELOPERS",
        title="Stop Debugging Your Own AI",
        subtitle="Gates and evidence, not vibes.",
        bullets=(
            "Every checkbox needs raw terminal output, ten lines minimum.",
            "Tests validate the spec, not the implementation. If a test fails, fix the code.",
            "Mechanical scans block stubs, mocked live tests, and tautological regressions.",
        ),
        board_lines=(
            "no evidence, no done",
            "no mock posing as live",
            "no test rewritten to pass",
            "self-healing capped",
            "at three retries",
        ),
        narration=(
            "If you are a developer, here is what changes. The agent has to prove the work. "
            "Every Definition of Done item needs ten lines of real terminal output, tagged with the phase that produced it. "
            "A state transition guard runs around twenty mechanical checks before any status can flip to done. "
            "An implementation reality scan rejects stub code, fabricated data, and fake responses. "
            "A regression quality guard catches bug fix tests that would still pass if you put the bug back. "
            "When something fails, the agent gets three retries with narrowing context, then it has to escalate. No infinite loops. "
            "You stop debugging the AI and start reading the receipts."
        ),
        bg="0x0f1d26",
        accent="0x58a6ff",
        voice_rate="-2%",
    ),
    Scene(
        eyebrow="PRODUCT MANAGERS",
        title="Track Artifacts, Not Confidence",
        subtitle="Spec, scope, report, evidence. The receipts replace the status meeting.",
        bullets=(
            "Every feature ships with six artifacts. Implementation cannot start without them.",
            "Outcome Contract: Intent, Success Signal, Hard Constraints, Failure Condition.",
            "Traceability chain: requirement to Gherkin to test to evidence. No orphan work.",
        ),
        board_lines=(
            "spec.md, design.md,",
            "scopes.md, report.md,",
            "uservalidation.md,",
            "state.json.",
            "All six. No exceptions.",
        ),
        narration=(
            "If you manage the product, here is what changes. You stop reading status from chat and start reading it from artifacts. "
            "Every feature carries six required documents. The spec, the design, the scopes, the report, the user validation list, and a machine readable state file. No artifact, no implementation. "
            "Every spec declares an outcome contract: what the user should be able to do, the signal that proves it works, the constraints that must hold, and what would make it a failure even if every test passed. "
            "Every requirement traces through a given when then scenario to a test plan to a live system test to a checked Definition of Done item. "
            "When a user unchecks an item in the validation list, that is a regression report, and the workflow has to address it before new work proceeds."
        ),
        bg="0x16202a",
        accent="0xf2c14e",
        voice_rate="-2%",
    ),
    Scene(
        eyebrow="CAPABILITY DESIGN",
        title="Foundation Before Overlay",
        subtitle="Do not let the first provider secretly become the architecture.",
        bullets=(
            "Analyst defines the domain capability model before provider details.",
            "Design writes the foundation contract, concrete implementations, and variation axes.",
            "Plan orders foundation scopes before ntfy, email, connector, or variant overlays.",
        ),
        board_lines=(
            "G094:",
            "capability first",
            "provider second",
            "foundation:true",
            "then overlays",
        ),
        narration=(
            "Capability-first design stops the first implementation from becoming accidental architecture. If notifications start with ntfy, Bubbles still asks for the notification capability: the domain primitives, the dispatch contract, the variation axes, and the foundation scope before provider overlays. Build the trailer, then park the cars in it — not the other way around, decent."
        ),
        bg="0x1f2430",
        accent="0xf2c14e",
        voice_rate="-2%",
    ),
    Scene(
        eyebrow="PRODUCT LEADERS",
        title="Ship Features That Survive Real Users",
        subtitle="Stay current. Catch drift. Cut the slop tax.",
        bullets=(
            "code-review and system-review diagnose without entering the gated lifecycle.",
            "spec-review flags stale, drifted, and superseded specs before they mislead.",
            "retro tracks the slop tax: reopens, retries, reversions. Target under fifteen percent.",
        ),
        board_lines=(
            "single active truth",
            "superseded goes",
            "into an appendix",
            "capability ledger",
            "is the truth source",
        ),
        narration=(
            "If you own the product, here is the bar. A demo is not a launch. A passing test suite is not a product. The contract is the experience the user actually gets. "
            "Bubbles keeps that contract honest over time. Code review and system review give you diagnosis without dragging you into the gated lifecycle. Spec review flags drift the moment a doc no longer matches the code. "
            "Retro tracks what we call the slop tax: scope reopens, phase retries, post-validate reversions, fix-on-fix chains. The target is under fifteen percent. "
            "Old requirements move into a clearly labeled superseded section. The capability ledger is the single source of truth for what is actually shipped. "
            "Your release notes stop being apologies."
        ),
        bg="0x24151a",
        accent="0xff7b72",
        voice_rate="-2%",
    ),
    Scene(
        eyebrow="THE SHIFT",
        title="You Do Not Need A Smarter Agent. You Need A Stricter Loop.",
        subtitle="Three ways to run the loop. The receipts do not change.",
        bullets=(
            "Basic: call one specialist directly. You drive the steps.",
            "Coordinator: workflow picks the chain, runs the phases, enforces the gates.",
            "Super agents: goal and sprint loop autonomously until convergence.",
        ),
        board_lines=(
            "1. specialist call",
            "2. /bubbles.workflow",
            "3. /bubbles.goal",
            "   /bubbles.sprint",
            "Same gates underneath.",
        ),
        narration=(
            "Here is the shift. You do not need a smarter agent. You need a stricter loop. And you get to choose how much of the loop you run yourself. "
            "Basic mode: you call one specialist at a time. Implement, test, audit, docs. You drive the sequence. "
            "Coordinator mode: one command, slash bubbles workflow, picks the right specialist chain for the job, runs every phase in order, and enforces every gate. "
            "Super agents take the wheel: slash bubbles goal converges on a single outcome, slash bubbles sprint takes a list of goals plus a time budget and works the whole list autonomously. "
            "Same evidence chain runs underneath all three. Choosing more autonomy never lowers the bar."
        ),
        bg="0x121b22",
        accent="0x39d0c8",
        voice_rate="-1%",
    ),
    Scene(
        eyebrow="DEVELOPER DETAIL",
        title="Every Claim Points At A Receipt",
        subtitle="Bidirectional traceability is the unit of truth.",
        bullets=(
            "Requirement to Gherkin to test plan to DoD item to raw output.",
            "Every link is named. Every link is checked. Nothing orphans.",
            "When a test fails, the chain tells you which requirement is at risk.",
        ),
        board_lines=(
            "spec  ->  gherkin",
            "gherkin  ->  test",
            "test  ->  evidence",
            "evidence  ->  DoD item",
            "Linked both ways.",
        ),
        narration=(
            "Now the developer detail. Bubbles uses one chain that runs in both directions. "
            "Every requirement traces forward into a Gherkin scenario, into a test plan row, into a Definition of Done item, into raw terminal output. "
            "And every piece of evidence traces backward to the requirement it proves. "
            "There are no orphan tests. There are no orphan checkboxes. There are no orphan claims. "
            "When a test fails, you can see which requirement is at risk. When a requirement changes, you can see which tests have to move with it. "
            "The chain replaces the stack of stale documents most teams quietly tolerate."
        ),
        bg="0x0f1d26",
        accent="0x58a6ff",
        voice_rate="-1%",
    ),
    Scene(
        eyebrow="DEVELOPER DETAIL",
        title="Specialists With Declared Lanes",
        subtitle="Around forty specialist agents. Each owns specific artifacts and phases.",
        bullets=(
            "Ownership is declared in YAML, not negotiated in chat.",
            "Handoffs route by capability, not by whichever agent answered first.",
            "Adding a specialist or a workflow mode is config. Not framework code.",
        ),
        board_lines=(
            "ownsArtifacts:",
            "  spec.md, design.md",
            "ownsPhases:",
            "  analyze, design",
            "Routing is deterministic.",
        ),
        narration=(
            "Bubbles ships with around forty specialist agents. Each one declares the artifacts it owns and the phases it runs. "
            "The analyst owns the requirements section of the spec. The designer owns the design doc. The planner owns the scope decomposition. The implementer owns the code. The tester owns the test pass. The auditor signs off. "
            "Ownership lives in configuration, not in conversation, so handoffs route by capability instead of by whichever agent happened to answer first. "
            "Adding a new specialist or a new workflow mode is a YAML edit. The framework reads it on the next run. No code change. No release."
        ),
        bg="0x16202a",
        accent="0xf2c14e",
        voice_rate="-1%",
    ),
    Scene(
        eyebrow="DEVELOPER DETAIL",
        title="Scopes That Do Not Collide",
        subtitle="Per-scope lanes. Parallel work without pollution.",
        bullets=(
            "Six or more scopes flips the spec into per-scope directory mode automatically.",
            "Each scope owns its directory, its DoD, its report. One agent inside the lane.",
            "Scopes can be Done independently. The spec status rolls up from the scopes.",
        ),
        board_lines=(
            "scopes/",
            "  01-foo/",
            "  02-bar/",
            "  03-baz/",
            "Independently Done.",
        ),
        narration=(
            "Scopes are how Bubbles handles the realistic case where one feature has multiple parallel slices. "
            "When a feature has six or more scopes, the framework flips into per-scope directory mode automatically. "
            "Each scope gets its own folder, its own Definition of Done, its own report file, and its own evidence trail. "
            "The owning agent works inside that lane and only that lane. Two agents on two different scopes cannot pollute each other's status or overwrite each other's evidence. "
            "A scope can be marked Done the moment its own evidence chain is complete. The spec status rolls up from the underlying scopes, not from a separate hand-maintained tracker. "
            "Parallel work stops being a coordination problem. It becomes a directory layout."
        ),
        bg="0x14202a",
        accent="0x39d0c8",
        voice_rate="-1%",
    ),
    Scene(
        eyebrow="WORKFLOWS",
        title="Pre-Built Specialist Sequences For The Work You Already Do",
        subtitle="Fix a bug. Ship a feature. Sweep for drift. Harden. Sprint.",
        bullets=(
            "fix-a-bug: discovery, root cause, spec-driven fix, adversarial regression.",
            "spec-freshness-review: classify every spec as fresh, drifted, stale, or superseded.",
            "post-impl-hardening and autonomous-sprint: cleanup and time-budgeted execution.",
        ),
        board_lines=(
            "fix-a-bug",
            "new-feature",
            "spec-freshness-review",
            "post-impl-hardening",
            "autonomous-sprint",
        ),
        narration=(
            "Workflows are pre-built specialist sequences for work you already do every week. "
            "Fix-a-bug runs discovery, root cause analysis, a spec-driven fix, and an adversarial regression test that would actually fail if you reintroduced the bug. No tautological green checks. "
            "New-feature runs the outcome contract, scope decomposition, implementation, real tests, audit, and docs in one chain. "
            "Spec-freshness-review classifies every spec as fresh, drifted, stale, or superseded so downstream agents stop trusting documents that no longer match the code. "
            "Post-implementation hardening sweeps the recently changed files for stubs, coverage gaps, and policy violations before they reach a user. "
            "Autonomous sprint takes a list of goals and a time budget and works the whole list to convergence, prioritizing by impact and effort. "
            "You pick the workflow. The framework runs the right specialists in the right order under the same evidence rules."
        ),
        bg="0x111f1c",
        accent="0x39d0c8",
        voice_rate="-1%",
    ),
    Scene(
        eyebrow="DEVELOPER DETAIL",
        title="Tests That Actually Mean Something",
        subtitle="Eight categories. Mocked tests cannot satisfy live test gates.",
        bullets=(
            "Live test categories run against real services. Internal mocks are forbidden.",
            "Bug-fix tests must include an adversarial case that would fail on regression.",
            "Reality scan rejects stub data, hardcoded responses, and fake handlers.",
        ),
        board_lines=(
            "unit, functional,",
            "integration, ui-unit,",
            "e2e-api, e2e-ui,",
            "stress, load.",
            "Each rule is enforced.",
        ),
        narration=(
            "Bubbles classifies tests into eight named categories: unit, functional, integration, user-interface unit, end-to-end API, end-to-end UI, stress, and load. "
            "Each category has explicit rules. Live test categories run against the real running stack. Internal mocks are forbidden inside them, because a mocked test labelled as live is a silent lie that fails in production. "
            "Bug-fix tests have to include at least one adversarial case: a scenario that would actually fail if you reintroduced the bug. No tautological green checks that would pass either way. "
            "Behind all of it, an implementation reality scan rejects stub data, hardcoded responses, and fake handlers before they reach a user. "
            "Tests stop being a green light you negotiate with the agent. They become a gate the agent cannot fake."
        ),
        bg="0x102018",
        accent="0x7ee787",
        voice_rate="-1%",
    ),
    Scene(
        eyebrow="STRONG SIDES",
        title="The Loop Is The Differentiator. Not The Model.",
        subtitle="The bar holds because the rules are mechanical and the lanes are explicit.",
        bullets=(
            "Mechanical gates instead of conventions you have to remember.",
            "Evidence is the unit of truth. Summaries do not promote.",
            "Self-healing capped. Failure escalates instead of looping forever.",
        ),
        board_lines=(
            "mechanical gates",
            "explicit ownership",
            "raw evidence",
            "capped retries",
            "config over code",
        ),
        narration=(
            "Why this holds up over time has very little to do with the model behind it. It is the loop. "
            "The gates are mechanical scripts, not gentle conventions you have to remember. They run the same way at three in the morning as they do during a code review. "
            "Ownership is declared, not negotiated, so handoffs do not depend on who is talking or how persuasive the summary sounds. "
            "Evidence is raw terminal output, not a polished narrative, so the loop cannot quietly lie its way to done. If the output is missing, the gate blocks. "
            "Self-healing is capped at three retries per phase and five per workflow, so a stuck workflow escalates to you instead of burning the rest of your day in a private loop. "
            "Adding a new specialist, a new workflow mode, a new gate, or a new workflow is configuration, not framework code, so the framework grows with your repo instead of forcing your repo to grow into it. "
            "Swap the model later. Swap the team later. The bar does not move."
        ),
        bg="0x1a1722",
        accent="0xb392f0",
        voice_rate="-1%",
    ),
    Scene(
        eyebrow="THE FIRST MOVE",
        title="One Painful Outcome. End To End. Inspect The Trail.",
        subtitle="Do not boil the ocean. Pick the work that already hurts.",
        bullets=(
            "Install Bubbles in a repo where AI work needs more discipline.",
            "Run /bubbles.workflow on one real bug, feature, or cleanup.",
            "Read the artifacts and the evidence. Judge it on the trail.",
        ),
        board_lines=(
            "1. Install",
            "2. Bootstrap",
            "3. One outcome",
            "4. Read the trail",
            "5. Decide on receipts",
        ),
        narration=(
            "If you take one thing from this video, take this. Pick one painful outcome and run it end to end. "
            "Install Bubbles in a repo where AI work needs more discipline. Bootstrap it. Run slash bubbles workflow on one real bug, feature, or cleanup. "
            "Then read the artifacts and the evidence. Do not judge it on the final cheerful answer. Judge it on the trail it left behind. "
            "If the trail is honest, you have your answer."
        ),
        bg="0x151515",
        accent="0xffffff",
        voice_rate="-1%",
    ),
)


def build_transcript() -> str:
    lines = ["# Bubbles Overview Voiceover Transcript", ""]
    lines.append(f"Voice: {VOICE}")
    lines.append("Pipeline: edge-tts -> WAV PCM intermediate -> single AAC pass at the end. No loudnorm.")
    lines.append("")
    for index, scene in enumerate(SCENES, start=1):
        lines.append(f"## {index:02d}. {scene.title}")
        lines.append("")
        lines.append(f"Rate: {scene.voice_rate}")
        lines.append("")
        lines.append(scene.narration)
        lines.append("")
    return "\n".join(lines)


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


def add_background_motif(lines: list[str], start: float, end: float, scene: Scene, index: int) -> None:
    # Subtle grid only on the LEFT half so it never collides with the right-side panel.
    for grid_x in range(260, 1180, 260):
        lines.append(dialogue(1, start, end, rect(grid_x, 0, 1, HEIGHT, "0xffffff", "ED")))
    for grid_y in range(240, HEIGHT, 240):
        lines.append(dialogue(1, start, end, rect(0, grid_y, 1180, 1, "0xffffff", "ED")))
    # Soft accent glow just under the eyebrow — gives each scene a tiny living detail.
    lines.append(dialogue(1, start, end, rect(108, 130, 60, 6, scene.accent, "20")))
    lines.append(dialogue(1, start, end, rect(174, 130, 24, 6, scene.accent, "60")))


# ---------------------------------------------------------------------------
# Right-side infographic panel system (replaces the static "board" on every
# scene with a scene-specific diagram). Geometry must stay inside the locked
# safe zone (1240..1828, 438..940) so it never collides with title, subtitle,
# bullets, footer, or chapter strip.
# ---------------------------------------------------------------------------

PANEL_LEFT = 1240
PANEL_TOP = 438
PANEL_WIDTH = 588
PANEL_HEIGHT = 502


def with_fade(body: str, fade_in: int = 350, fade_out: int = 0) -> str:
    """Inject a \\fad(in,out) into the first {} block of an ASS body."""
    return body.replace("{\\an", f"{{\\fad({fade_in},{fade_out})\\an", 1)


# ---------------------------------------------------------------------------
# DIAGRAM PRIMITIVES — real lines, arrows, circles, diamonds via ASS \p1.
# Every primitive emits a dialogue line directly into `lines`. Use these
# instead of plain rects whenever a panel is supposed to *look* like a
# diagram with connecting flow rather than a stack of text boxes.
# ---------------------------------------------------------------------------

def stagger(start: float, end: float, idx: int, base: float = 0.10, step: float = 0.10) -> float:
    """Per-element start time so panel pieces appear in sequence rather than all at once."""
    return min(end - 0.05, start + base + idx * step)


def draw_thick_line(lines: list[str], layer: int, start: float, end: float,
                     x1: int, y1: int, x2: int, y2: int,
                     color: str, alpha: str = "00", thickness: int = 3) -> None:
    """Solid line of any angle drawn as a rotated polygon."""
    import math
    dx = x2 - x1
    dy = y2 - y1
    length = math.sqrt(dx * dx + dy * dy)
    if length < 1:
        return
    # ASS \frz rotates clockwise from +x in screen coordinates (Y goes down).
    angle = math.degrees(math.atan2(dy, dx))
    cx = (x1 + x2) // 2
    cy = (y1 + y2) // 2
    half_l = int(length // 2)
    half_t = max(1, thickness // 2)
    body = (
        f"{{\\an5\\pos({cx},{cy})\\frz{-angle:.2f}\\bord0\\shad0"
        f"\\1c&H{hex_to_ass_bgr(color)}&\\alpha&H{alpha}&"
        f"\\fad(350,0)\\p1}}"
        f"m {-half_l} {-half_t} l {half_l} {-half_t} "
        f"l {half_l} {half_t} l {-half_l} {half_t}{{\\p0}}"
    )
    lines.append(dialogue(layer, start, end, body))


def draw_arrowhead(lines: list[str], layer: int, start: float, end: float,
                    tip_x: int, tip_y: int, direction: str, size: int,
                    color: str, alpha: str = "00") -> None:
    """Filled triangle arrowhead with its tip at (tip_x, tip_y).

    direction: one of E (right), W (left), N (up), S (down), NE, NW, SE, SW.
    """
    s = size
    if direction == "E":
        path = f"m 0 0 l {-s} {-s} l {-s} {s}"
    elif direction == "W":
        path = f"m 0 0 l {s} {-s} l {s} {s}"
    elif direction == "S":
        path = f"m 0 0 l {-s} {-s} l {s} {-s}"
    elif direction == "N":
        path = f"m 0 0 l {-s} {s} l {s} {s}"
    elif direction == "NE":
        path = f"m 0 0 l {-s} 0 l 0 {s}"
    elif direction == "NW":
        path = f"m 0 0 l {s} 0 l 0 {s}"
    elif direction == "SE":
        path = f"m 0 0 l {-s} 0 l 0 {-s}"
    elif direction == "SW":
        path = f"m 0 0 l {s} 0 l 0 {-s}"
    else:
        path = f"m 0 0 l {-s} {-s} l {-s} {s}"
    body = (
        f"{{\\an7\\pos({tip_x},{tip_y})\\bord0\\shad0"
        f"\\1c&H{hex_to_ass_bgr(color)}&\\alpha&H{alpha}&"
        f"\\fad(350,0)\\p1}}{path}{{\\p0}}"
    )
    lines.append(dialogue(layer, start, end, body))


def draw_arrow(lines: list[str], layer: int, start: float, end: float,
                x1: int, y1: int, x2: int, y2: int,
                color: str, alpha: str = "00",
                thickness: int = 3, head_size: int = 9) -> None:
    """Straight horizontal/vertical arrow with a filled triangle head."""
    if y1 == y2:
        direction = "E" if x2 > x1 else "W"
        adj = head_size if direction == "E" else -head_size
        draw_thick_line(lines, layer, start, end, x1, y1, x2 - adj, y2, color, alpha, thickness)
        draw_arrowhead(lines, layer + 1, start, end, x2, y2, direction, head_size, color, alpha)
    elif x1 == x2:
        direction = "S" if y2 > y1 else "N"
        adj = head_size if direction == "S" else -head_size
        draw_thick_line(lines, layer, start, end, x1, y1, x2, y2 - adj, color, alpha, thickness)
        draw_arrowhead(lines, layer + 1, start, end, x2, y2, direction, head_size, color, alpha)
    else:
        # Diagonal — line plus generic head facing the cardinal closest to the angle.
        import math
        ang = math.degrees(math.atan2(y2 - y1, x2 - x1))
        if -45 <= ang < 45:
            direction = "E"
        elif 45 <= ang < 135:
            direction = "S"
        elif ang >= 135 or ang < -135:
            direction = "W"
        else:
            direction = "N"
        draw_thick_line(lines, layer, start, end, x1, y1, x2, y2, color, alpha, thickness)
        draw_arrowhead(lines, layer + 1, start, end, x2, y2, direction, head_size, color, alpha)


def draw_circle(lines: list[str], layer: int, start: float, end: float,
                 cx: int, cy: int, r: int, color: str, alpha: str = "00") -> None:
    """Filled circle via 4-segment cubic bezier (Kappa = 0.5523)."""
    k = int(r * 0.5523)
    path = (
        f"m 0 {-r} "
        f"b {k} {-r} {r} {-k} {r} 0 "
        f"b {r} {k} {k} {r} 0 {r} "
        f"b {-k} {r} {-r} {k} {-r} 0 "
        f"b {-r} {-k} {-k} {-r} 0 {-r}"
    )
    body = (
        f"{{\\an5\\pos({cx},{cy})\\bord0\\shad0"
        f"\\1c&H{hex_to_ass_bgr(color)}&\\alpha&H{alpha}&"
        f"\\fad(350,0)\\p1}}{path}{{\\p0}}"
    )
    lines.append(dialogue(layer, start, end, body))


def draw_ring(lines: list[str], layer: int, start: float, end: float,
               cx: int, cy: int, r_outer: int, r_inner: int,
               color: str, alpha: str = "00") -> None:
    """True hollow ring — single filled donut path (outer arc CW + inner arc CCW)."""
    import math
    segments = 36
    pts: list[str] = []
    # Outer arc clockwise (full 360deg).
    for i in range(segments + 1):
        ang = 2 * math.pi * i / segments
        x = int(r_outer * math.cos(ang))
        y = int(r_outer * math.sin(ang))
        pts.append(f"{'m' if i == 0 else 'l'} {x} {y}")
    # Bridge to inner ring start (close outer, jump to inner via implicit segment).
    # Inner arc counter-clockwise.
    for i in range(segments + 1):
        ang = -2 * math.pi * i / segments
        x = int(r_inner * math.cos(ang))
        y = int(r_inner * math.sin(ang))
        pts.append(f"{'m' if i == 0 else 'l'} {x} {y}")
    path = " ".join(pts)
    body = (
        f"{{\\an5\\pos({cx},{cy})\\bord0\\shad0"
        f"\\1c&H{hex_to_ass_bgr(color)}&\\alpha&H{alpha}&"
        f"\\fad(350,0)\\p1}}{path}{{\\p0}}"
    )
    lines.append(dialogue(layer, start, end, body))


def draw_arc_band(lines: list[str], layer: int, start: float, end: float,
                   cx: int, cy: int, r_outer: int, r_inner: int,
                   start_deg: float, end_deg: float,
                   color: str, alpha: str = "00", segments: int = 30) -> None:
    """Filled arc band (donut segment) — outer arc CW + inner arc CCW = real donut slice."""
    import math
    pts: list[str] = []
    # Outer arc start_deg -> end_deg.
    for i in range(segments + 1):
        t = i / segments
        ang = math.radians(start_deg + (end_deg - start_deg) * t)
        x = int(r_outer * math.cos(ang))
        y = int(r_outer * math.sin(ang))
        pts.append(f"{'m' if i == 0 else 'l'} {x} {y}")
    # Inner arc end_deg -> start_deg (reverse).
    for i in range(segments + 1):
        t = i / segments
        ang = math.radians(end_deg - (end_deg - start_deg) * t)
        x = int(r_inner * math.cos(ang))
        y = int(r_inner * math.sin(ang))
        pts.append(f"l {x} {y}")
    path = " ".join(pts)
    body = (
        f"{{\\an5\\pos({cx},{cy})\\bord0\\shad0"
        f"\\1c&H{hex_to_ass_bgr(color)}&\\alpha&H{alpha}&"
        f"\\fad(350,0)\\p1}}{path}{{\\p0}}"
    )
    lines.append(dialogue(layer, start, end, body))


def draw_diamond(lines: list[str], layer: int, start: float, end: float,
                  cx: int, cy: int, w: int, h: int,
                  color: str, alpha: str = "00") -> None:
    """Diamond / rhombus centered at (cx, cy)."""
    hw, hh = w // 2, h // 2
    path = f"m 0 {-hh} l {hw} 0 l 0 {hh} l {-hw} 0"
    body = (
        f"{{\\an5\\pos({cx},{cy})\\bord0\\shad0"
        f"\\1c&H{hex_to_ass_bgr(color)}&\\alpha&H{alpha}&"
        f"\\fad(350,0)\\p1}}{path}{{\\p0}}"
    )
    lines.append(dialogue(layer, start, end, body))


def draw_wedge(lines: list[str], layer: int, start: float, end: float,
                cx: int, cy: int, r: int,
                start_deg: float, end_deg: float,
                color: str, alpha: str = "00", segments: int = 18) -> None:
    """Pie-slice wedge from start_deg to end_deg (degrees, screen-space CW from east).

    Approximated as a polygon fan from the center outward.
    """
    import math
    pts = ["m 0 0"]
    for i in range(segments + 1):
        t = i / segments
        ang = math.radians(start_deg + (end_deg - start_deg) * t)
        x = int(r * math.cos(ang))
        y = int(r * math.sin(ang))
        pts.append(f"l {x} {y}")
    path = " ".join(pts)
    body = (
        f"{{\\an5\\pos({cx},{cy})\\bord0\\shad0"
        f"\\1c&H{hex_to_ass_bgr(color)}&\\alpha&H{alpha}&"
        f"\\fad(350,0)\\p1}}{path}{{\\p0}}"
    )
    lines.append(dialogue(layer, start, end, body))


def tpb_tape_label(lines: list[str], layer: int, start: float, end: float,
                    cx: int, cy: int, label: str,
                    width: int = 200, height: int = 30,
                    rotation: float = -5.0,
                    fill: str = "0xfde047",
                    text_color: str = "0x111827") -> None:
    """Trailer-Park-style angled tape strip with handwritten-feel label."""
    hw, hh = width // 2, height // 2
    path = f"m {-hw} {-hh} l {hw} {-hh} l {hw} {hh} l {-hw} {hh}"
    bg = (
        f"{{\\an5\\pos({cx},{cy})\\frz{rotation}\\bord0\\shad0"
        f"\\1c&H{hex_to_ass_bgr(fill)}&\\alpha&H10&"
        f"\\fad(350,0)\\p1}}{path}{{\\p0}}"
    )
    lines.append(dialogue(layer, start, end, bg))
    txt = (
        f"{{\\an5\\pos({cx},{cy})\\frz{rotation}\\bord0\\shad0"
        f"\\fnDejaVu Sans\\fs{max(12, height - 12)}\\b1"
        f"\\1c&H{hex_to_ass_bgr(text_color)}&\\alpha&H00&"
        f"\\fad(350,0)}}{label}"
    )
    lines.append(dialogue(layer + 1, start, end, txt))


def tpb_stamp(lines: list[str], layer: int, start: float, end: float,
               cx: int, cy: int, label: str,
               width: int = 150, height: int = 60,
               rotation: float = 8.0,
               color: str = "0xff5f56") -> None:
    """Diagonal red rubber-stamp box for things like S.O.L. PERMIT."""
    hw, hh = width // 2, height // 2
    # Two thin rect borders create the stamp outline.
    border = 4
    outer = f"m {-hw} {-hh} l {hw} {-hh} l {hw} {hh} l {-hw} {hh}"
    inner = (
        f"m {-hw + border * 2} {-hh + border * 2} "
        f"l {hw - border * 2} {-hh + border * 2} "
        f"l {hw - border * 2} {hh - border * 2} "
        f"l {-hw + border * 2} {hh - border * 2}"
    )
    body = (
        f"{{\\an5\\pos({cx},{cy})\\frz{rotation}\\bord{border}\\shad0"
        f"\\1c&H{hex_to_ass_bgr(color)}&\\3c&H{hex_to_ass_bgr(color)}&\\alpha&H30&"
        f"\\fad(450,0)\\p1}}{outer}{{\\p0}}"
    )
    lines.append(dialogue(layer, start, end, body))
    txt = (
        f"{{\\an5\\pos({cx},{cy})\\frz{rotation}\\bord0\\shad0"
        f"\\fnDejaVu Sans Mono\\fs{max(14, height - 36)}\\b1"
        f"\\1c&H{hex_to_ass_bgr(color)}&\\alpha&H10&"
        f"\\fad(450,0)}}{label}"
    )
    lines.append(dialogue(layer + 1, start, end, txt))


def add_corner_park_badge(lines: list[str], start: float, end: float, scene: Scene) -> None:
    """Bottom-left small Sunnyvale Park trailer-icon badge (TPB visual flair)."""
    bx = 1380
    by = 1006
    # Tiny trailer silhouette: rect body + small wheel rings.
    body_path = "m 0 0 l 64 0 l 64 24 l 0 24"
    badge = (
        f"{{\\an7\\pos({bx},{by})\\bord0\\shad0"
        f"\\1c&H{hex_to_ass_bgr(scene.accent)}&\\alpha&H40&"
        f"\\fad(350,0)\\p1}}{body_path}{{\\p0}}"
    )
    lines.append(dialogue(2, start, end, badge))
    # Two wheel dots.
    for wx in (10, 52):
        wheel = (
            f"{{\\an5\\pos({bx + wx},{by + 28})\\bord0\\shad0"
            f"\\1c&H{hex_to_ass_bgr(scene.accent)}&\\alpha&H40&"
            f"\\fad(350,0)\\p1}}m -3 0 l 0 -3 l 3 0 l 0 3{{\\p0}}"
        )
        lines.append(dialogue(2, start, end, wheel))


def panel_frame(lines: list[str], start: float, end: float, scene: Scene, header_label: str) -> None:
    """Common chrome: dark fill + accent header bar + uppercase label."""
    lines.append(dialogue(2, start, end,
        with_fade(rect(PANEL_LEFT, PANEL_TOP, PANEL_WIDTH, PANEL_HEIGHT, "0x05070d", "38"))))
    lines.append(dialogue(2, start, end,
        with_fade(rect(PANEL_LEFT, PANEL_TOP, PANEL_WIDTH, 48, scene.accent, "08"))))
    lines.append(dialogue(3, start, end,
        with_fade(text(header_label, PANEL_LEFT + 24, PANEL_TOP + 13, 21, "0x111827", "00", 7, True, MONO_FONT))))


def render_panel_board(lines: list[str], start: float, end: float, scene: Scene, data: dict) -> None:
    """INCIDENT LOOP: simple 4-step vertical flow with a trace-back rail (no broken ring layout)."""
    panel_frame(lines, start, end, scene, data.get("header", "INCIDENT LOOP"))
    steps = (
        ("agent says done", "PR opens with green checkmarks"),
        ("user finds broken", "real-system smoke test fails"),
        ("team loses a day", "context-switch + redo cycle"),
        ("next sprint repeats", "same shape of failure"),
    )
    inner_left = PANEL_LEFT + 56
    inner_top = PANEL_TOP + 78
    cell_w = PANEL_WIDTH - 132
    cell_h = 70
    gap_y = 18
    centers_y: list[int] = []
    for idx, (label, sub) in enumerate(steps):
        y = inner_top + idx * (cell_h + gap_y)
        centers_y.append(y + cell_h // 2)
        sub_start = stagger(start, end, idx, base=0.10, step=0.20)
        # Card background + accent rail.
        lines.append(dialogue(2, sub_start, end, with_fade(rect(inner_left, y, cell_w, cell_h, "0x0e1623", "20"))))
        lines.append(dialogue(2, sub_start, end, with_fade(rect(inner_left, y, 6, cell_h, scene.accent, "00"))))
        # Number badge.
        lines.append(dialogue(3, sub_start, end,
            with_fade(text(f"{idx+1:02d}", inner_left + 22, y + 8, 28, scene.accent, "00", 7, True, MONO_FONT))))
        # Label + sub-text.
        lines.append(dialogue(3, sub_start, end,
            with_fade(text(label, inner_left + 78, y + 10, 20, "0xffffff", "00", 7, True, MONO_FONT))))
        lines.append(dialogue(3, sub_start, end,
            with_fade(text(sub, inner_left + 78, y + 38, 13, "0xffffff", "30", 7, False, FONT))))
    # Forward arrows down between consecutive cards.
    arrow_x = inner_left + cell_w // 2
    for idx in range(len(centers_y) - 1):
        sub_start = stagger(start, end, idx + 1, base=0.30, step=0.20)
        a_top = centers_y[idx] + cell_h // 2
        a_bot = centers_y[idx + 1] - cell_h // 2
        draw_arrow(lines, 3, sub_start, end, arrow_x, a_top + 2, arrow_x, a_bot - 2, scene.accent, "00", 3, 9)
    # Trace-back rail on the right showing the loop returns to step 1.
    back_x = inner_left + cell_w + 32
    a_top = centers_y[0]
    a_bot = centers_y[-1]
    sub_start = stagger(start, end, len(centers_y) + 2, base=0.6, step=0.0)
    for cy_node in (a_top, a_bot):
        draw_thick_line(lines, 2, sub_start, end, inner_left + cell_w, cy_node, back_x, cy_node, scene.accent, "60", 4)
    draw_thick_line(lines, 2, sub_start, end, back_x, a_bot, back_x, a_top, scene.accent, "60", 4)
    draw_arrowhead(lines, 3, sub_start, end, back_x, a_top + 4, "N", 14, scene.accent, "00")
    # Single clean caption sits just RIGHT of the rail, mid-height between the two stub rows.
    cap_y = (a_top + a_bot) // 2 - 8
    lines.append(dialogue(4, stagger(start, end, len(centers_y) + 4, base=1.0, step=0.0), end,
        with_fade(text("loops back", back_x + 10, cap_y, 13, scene.accent, "00", 5, True, MONO_FONT))))


def render_panel_terminal(lines: list[str], start: float, end: float, scene: Scene, data: dict) -> None:
    """Faux terminal window with command + colored output and a blinking cursor."""
    panel_frame(lines, start, end, scene, data.get("header", "BASH — bubbles"))
    # Three traffic-light dots in the header row (right side).
    dot_y = PANEL_TOP + 12
    for i, color in enumerate(("0xff5f56", "0xffbd2e", "0x27c93f")):
        lines.append(dialogue(3, start, end,
            with_fade(text("\u2b24", PANEL_LEFT + 470 + i * 28, dot_y, 16, color, "00", 7, False, MONO_FONT))))
    # Body lines.
    cursor_y = PANEL_TOP + 70
    line_gap = 26
    last_y = cursor_y
    for term_line in data["lines"]:
        if term_line.startswith("$ "):
            color = scene.accent
        elif term_line.startswith("\u2713 ") or term_line.startswith("PASS"):
            color = "0x7ee787"
        elif term_line.startswith("\u2717 ") or term_line.startswith("FAIL") or term_line.startswith("BLOCK"):
            color = "0xff7b72"
        elif term_line.startswith("\u2192 ") or term_line.startswith("# "):
            color = "0x9aa4ad"
        else:
            color = "0xe5e7eb"
        lines.append(dialogue(3, start, end,
            with_fade(text(term_line, PANEL_LEFT + 22, cursor_y, 18, color, "08", 7, False, MONO_FONT))))
        last_y = cursor_y
        cursor_y += line_gap
    # Blinking cursor: alternate visible / invisible blocks ~0.6s period.
    blink_x = PANEL_LEFT + 22
    blink_y = last_y + line_gap
    period = 0.6
    t = 0.4  # short delay so the typing "settles"
    while t < (end - start):
        sub_start = start + t
        sub_end = min(end, start + t + period / 2)
        lines.append(dialogue(4, sub_start, sub_end,
            text("\u2588", blink_x, blink_y, 18, scene.accent, "00", 7, True, MONO_FONT)))
        t += period


def render_panel_six_artifacts(lines: list[str], start: float, end: float, scene: Scene, data: dict) -> None:
    """2 rows x 3 cols of required Bubbles artifacts."""
    panel_frame(lines, start, end, scene, data.get("header", "REQUIRED ARTIFACTS"))
    artifacts = (
        ("spec.md", "what to build"),
        ("design.md", "how it works"),
        ("scopes.md", "DoD per slice"),
        ("report.md", "raw evidence"),
        ("uservalidation", "regressions"),
        ("state.json", "machine truth"),
    )
    inner_x = PANEL_LEFT + 18
    inner_y = PANEL_TOP + 70
    cell_w = 178
    cell_h = 145
    gap_x = 8
    gap_y = 12
    for idx, (name, desc) in enumerate(artifacts):
        col = idx % 3
        row = idx // 3
        x = inner_x + col * (cell_w + gap_x)
        y = inner_y + row * (cell_h + gap_y)
        lines.append(dialogue(2, start, end, with_fade(rect(x, y, cell_w, cell_h, "0x0e1623", "20"))))
        lines.append(dialogue(2, start, end, with_fade(rect(x, y, cell_w, 4, scene.accent, "00"))))
        lines.append(dialogue(3, start, end,
            with_fade(text(name, x + 12, y + 18, 18, "0xffffff", "00", 7, True, MONO_FONT))))
        for li, dl in enumerate(wrap_line(desc, 16)[:3]):
            lines.append(dialogue(3, start, end,
                with_fade(text(dl, x + 12, y + 60 + li * 22, 16, "0xffffff", "30", 7, False, FONT))))


def render_panel_workflow_modes(lines: list[str], start: float, end: float, scene: Scene, data: dict) -> None:
    """Three columns + a SHARED-GATES bar at the bottom they all feed into."""
    panel_frame(lines, start, end, scene, data.get("header", "THREE WAYS TO RUN THE LOOP"))
    modes = (
        ("BASIC", "/bubbles.<agent>", "you drive each phase"),
        ("COORDINATOR", "/bubbles.workflow", "auto picks the chain"),
        ("SUPER AGENT", "/bubbles.goal", "loops to convergence"),
    )
    col_w = 178
    gap = 8
    y = PANEL_TOP + 70
    h = 320
    bar_y = y + h + 26
    bar_x = PANEL_LEFT + 18
    bar_w = PANEL_WIDTH - 36
    bar_h = 44
    col_centers: list[int] = []
    for idx, (label, cmd, desc) in enumerate(modes):
        x = PANEL_LEFT + 18 + idx * (col_w + gap)
        col_centers.append(x + col_w // 2)
        sub_start = stagger(start, end, idx, base=0.10, step=0.18)
        lines.append(dialogue(2, sub_start, end, with_fade(rect(x, y, col_w, h, "0x0e1623", "20"))))
        lines.append(dialogue(2, sub_start, end, with_fade(rect(x, y, col_w, 6, scene.accent, "00"))))
        lines.append(dialogue(3, sub_start, end,
            with_fade(text(label, x + 12, y + 22, 19, scene.accent, "00", 7, True, MONO_FONT))))
        lines.append(dialogue(3, sub_start, end,
            with_fade(text(f"{idx+1:02d}", x + col_w - 38, y + 18, 26, "0xffffff", "20", 7, True, MONO_FONT))))
        lines.append(dialogue(3, sub_start, end,
            with_fade(text(cmd, x + 12, y + 78, 15, "0xffffff", "00", 7, False, MONO_FONT))))
        for li, dl in enumerate(wrap_line(desc, 18)[:3]):
            lines.append(dialogue(3, sub_start, end,
                with_fade(text(dl, x + 12, y + 170 + li * 24, 16, "0xffffff", "20", 7, False, FONT))))
    # Shared-gates bar at the bottom.
    sub_start_b = stagger(start, end, len(modes) + 2, base=0.7, step=0.0)
    lines.append(dialogue(2, sub_start_b, end, with_fade(rect(bar_x, bar_y, bar_w, bar_h, scene.accent, "30"))))
    lines.append(dialogue(3, sub_start_b, end,
        with_fade(text("\u2192 same gates, same evidence \u2190", bar_x + bar_w // 2 - 156, bar_y + 12, 17, "0x111827", "00", 7, True, MONO_FONT))))
    # Down-arrow connectors from each column into the shared bar.
    for idx, ccx in enumerate(col_centers):
        sub_start_a = stagger(start, end, len(modes) + idx, base=0.55, step=0.10)
        draw_arrow(lines, 3, sub_start_a, end, ccx, y + h + 4, ccx, bar_y - 2, scene.accent, "50", 2, 7)


def render_panel_chain(lines: list[str], start: float, end: float, scene: Scene, data: dict) -> None:
    """Vertical evidence chain with REAL forward arrows + a reverse trace-back arrow on the side."""
    panel_frame(lines, start, end, scene, data.get("header", "TRACEABILITY CHAIN"))
    nodes = ("spec", "gherkin", "test", "evidence", "DoD checkbox")
    inner_left = PANEL_LEFT + 60
    inner_top = PANEL_TOP + 70
    cell_w = PANEL_WIDTH - 120
    cell_h = 56
    gap_y = 22
    centers_y: list[int] = []
    for idx, label in enumerate(nodes):
        y = inner_top + idx * (cell_h + gap_y)
        centers_y.append(y + cell_h // 2)
        sub_start = stagger(start, end, idx, base=0.10, step=0.18)
        lines.append(dialogue(2, sub_start, end, with_fade(rect(inner_left, y, cell_w, cell_h, "0x0e1623", "20"))))
        lines.append(dialogue(2, sub_start, end, with_fade(rect(inner_left, y, 6, cell_h, scene.accent, "00"))))
        lines.append(dialogue(3, sub_start, end,
            with_fade(text(label, inner_left + 24, y + 16, 22, "0xffffff", "00", 7, True, MONO_FONT))))
        lines.append(dialogue(3, sub_start, end,
            with_fade(text(f"{idx+1:02d}", inner_left + cell_w - 56, y + 13, 24, scene.accent, "00", 7, True, MONO_FONT))))
    # Forward arrows down the centre.
    arrow_x = inner_left + cell_w // 2
    for idx in range(len(centers_y) - 1):
        sub_start = stagger(start, end, idx + 1, base=0.30, step=0.18)
        a_top = centers_y[idx] + cell_h // 2
        a_bot = centers_y[idx + 1] - cell_h // 2
        draw_arrow(lines, 3, sub_start, end, arrow_x, a_top + 2, arrow_x, a_bot - 2, scene.accent, "00", 3, 9)
    # Reverse trace-back arrow on the right rail (last -> first). Bold + visible.
    back_x = inner_left + cell_w + 24
    a_top = centers_y[0]
    a_bot = centers_y[-1]
    sub_start = stagger(start, end, len(centers_y) + 2, base=0.6, step=0.0)
    # Connector stubs from each card out to the rail so the trace-back reads as a real loop.
    for cy_node in (a_top, a_bot):
        draw_thick_line(lines, 2, sub_start, end, inner_left + cell_w, cy_node, back_x, cy_node, scene.accent, "60", 4)
    draw_thick_line(lines, 2, sub_start, end, back_x, a_bot, back_x, a_top, scene.accent, "60", 4)
    draw_arrowhead(lines, 3, sub_start, end, back_x, a_top + 4, "N", 14, scene.accent, "00")
    lines.append(dialogue(4, sub_start, end,
        with_fade(text("trace back", back_x + 10, (a_top + a_bot) // 2 - 8, 13, scene.accent, "00", 5, True, MONO_FONT))))


def render_panel_agent_flow(lines: list[str], start: float, end: float, scene: Scene, data: dict) -> None:
    """Specialist swimlanes -> single bus rail -> 'router' label -> MECHANICAL GATES box. No spider web."""
    panel_frame(lines, start, end, scene, data.get("header", "DISPATCH MAP"))
    specialists = ("analyst", "designer", "planner", "implementer", "tester", "auditor")
    inner_x = PANEL_LEFT + 18
    inner_y = PANEL_TOP + 70
    spec_w = 170
    spec_h = 34
    gap_y = 8
    # Geometry: agents column on the left, gates box on the right, single bus + arrow connecting them.
    bus_x = inner_x + spec_w + 16
    gate_w = 200
    gate_h = 200
    gate_x = PANEL_LEFT + PANEL_WIDTH - 18 - gate_w
    # Specialist lanes.
    lane_centers: list[int] = []
    for idx, name in enumerate(specialists):
        y = inner_y + idx * (spec_h + gap_y)
        lane_centers.append(y + spec_h // 2)
        sub_start = stagger(start, end, idx, base=0.10, step=0.10)
        lines.append(dialogue(2, sub_start, end, with_fade(rect(inner_x, y, spec_w, spec_h, "0x0e1623", "20"))))
        lines.append(dialogue(2, sub_start, end, with_fade(rect(inner_x, y, 4, spec_h, scene.accent, "00"))))
        lines.append(dialogue(3, sub_start, end,
            with_fade(text("/" + name, inner_x + 14, y + 8, 17, "0xffffff", "00", 7, True, MONO_FONT))))
        # Short horizontal stub from lane right edge to the bus rail.
        draw_thick_line(lines, 2, sub_start, end, inner_x + spec_w, lane_centers[-1], bus_x, lane_centers[-1], scene.accent, "60", 3)
    # Vertical bus rail collecting all stubs.
    bus_top = lane_centers[0]
    bus_bot = lane_centers[-1]
    sub_start_bus = stagger(start, end, len(specialists), base=0.55, step=0.0)
    draw_thick_line(lines, 2, sub_start_bus, end, bus_x, bus_top, bus_x, bus_bot, scene.accent, "70", 4)
    # Single arrow from bus mid-point to the gates box, with a "router" label above it.
    bus_mid_y = (bus_top + bus_bot) // 2
    sub_start_arrow = stagger(start, end, len(specialists) + 1, base=0.7, step=0.0)
    draw_arrow(lines, 3, sub_start_arrow, end, bus_x + 4, bus_mid_y, gate_x - 4, bus_mid_y, scene.accent, "00", 3, 10)
    lines.append(dialogue(4, sub_start_arrow, end,
        with_fade(text("router", (bus_x + gate_x) // 2 - 28, bus_mid_y - 24, 14, scene.accent, "00", 7, True, MONO_FONT))))
    # Gates box (vertically centered relative to the lanes).
    gate_y = bus_mid_y - gate_h // 2
    sub_start_g = stagger(start, end, len(specialists) + 2, base=0.85, step=0.0)
    lines.append(dialogue(2, sub_start_g, end, with_fade(rect(gate_x, gate_y, gate_w, gate_h, "0x0e1623", "20"))))
    lines.append(dialogue(2, sub_start_g, end, with_fade(rect(gate_x, gate_y, gate_w, 6, scene.accent, "00"))))
    lines.append(dialogue(3, sub_start_g, end,
        with_fade(text("MECHANICAL", gate_x + 16, gate_y + 18, 17, scene.accent, "00", 7, True, MONO_FONT))))
    lines.append(dialogue(3, sub_start_g, end,
        with_fade(text("GATES", gate_x + 16, gate_y + 42, 17, scene.accent, "00", 7, True, MONO_FONT))))
    for li, txt_ in enumerate(("ownership", "evidence", "retries")):
        lines.append(dialogue(3, sub_start_g, end,
            with_fade(text("\u2713 " + txt_, gate_x + 16, gate_y + 86 + li * 28, 16, "0x7ee787", "00", 7, False, FONT))))


def render_panel_scopes_tree(lines: list[str], start: float, end: float, scene: Scene, data: dict) -> None:
    """File-tree view of the per-scope directory layout with status tags."""
    panel_frame(lines, start, end, scene, data.get("header", "PER-SCOPE LAYOUT"))
    tree_lines = (
        ("specs/210-feature/", scene.accent, True),
        ("  spec.md", "0xe5e7eb", False),
        ("  design.md", "0xe5e7eb", False),
        ("  scopes/", scene.accent, True),
        ("    01-ingest/    [DONE]", "0x7ee787", False),
        ("    02-validate/  [DONE]", "0x7ee787", False),
        ("    03-route/     [WIP]", "0xffbd2e", False),
        ("    04-render/    [TODO]", "0x9aa4ad", False),
        ("    05-export/    [TODO]", "0x9aa4ad", False),
        ("    06-audit/     [TODO]", "0x9aa4ad", False),
        ("  uservalidation.md", "0xe5e7eb", False),
        ("  state.json", "0xe5e7eb", False),
    )
    inner_x = PANEL_LEFT + 22
    inner_y = PANEL_TOP + 72
    line_gap = 30
    for i, (txt, color, bold) in enumerate(tree_lines):
        y = inner_y + i * line_gap
        lines.append(dialogue(3, start, end,
            with_fade(text(txt, inner_x, y, 18, color, "00", 7, bold, MONO_FONT))))


def render_panel_recipe_stack(lines: list[str], start: float, end: float, scene: Scene, data: dict) -> None:
    """Stacked recipe cards (real recipe names from the repo)."""
    panel_frame(lines, start, end, scene, data.get("header", "WORKFLOW LIBRARY"))
    recipes = (
        ("fix-a-bug", "discover \u2192 RCA \u2192 fix \u2192 adv. regress"),
        ("new-feature", "outcome \u2192 scopes \u2192 build \u2192 audit"),
        ("spec-freshness-review", "fresh / drifted / stale / superseded"),
        ("post-impl-hardening", "stub scan \u2192 gap fix \u2192 policy sweep"),
        ("autonomous-sprint", "goals + time budget \u2192 converge"),
    )
    inner_x = PANEL_LEFT + 18
    inner_y = PANEL_TOP + 70
    card_w = PANEL_WIDTH - 36
    card_h = 70
    gap = 6
    for idx, (name, flow) in enumerate(recipes):
        y = inner_y + idx * (card_h + gap)
        lines.append(dialogue(2, start, end, with_fade(rect(inner_x, y, card_w, card_h, "0x0e1623", "20"))))
        lines.append(dialogue(2, start, end, with_fade(rect(inner_x, y, 6, card_h, scene.accent, "00"))))
        lines.append(dialogue(3, start, end,
            with_fade(text(name, inner_x + 22, y + 12, 19, scene.accent, "00", 7, True, MONO_FONT))))
        lines.append(dialogue(3, start, end,
            with_fade(text(flow, inner_x + 22, y + 42, 15, "0xffffff", "10", 7, False, MONO_FONT))))


def render_panel_test_grid(lines: list[str], start: float, end: float, scene: Scene, data: dict) -> None:
    """4 rows x 2 cols of canonical test categories. Live categories tinted."""
    panel_frame(lines, start, end, scene, data.get("header", "TEST TAXONOMY"))
    cats = (
        ("unit", "isolated"),
        ("functional", "real deps"),
        ("integration", "live stack"),
        ("ui-unit", "mocked UI"),
        ("e2e-api", "live API"),
        ("e2e-ui", "live UI"),
        ("stress", "burst load"),
        ("load", "sustained"),
    )
    inner_x = PANEL_LEFT + 18
    inner_y = PANEL_TOP + 70
    cols = 2
    cell_w = (PANEL_WIDTH - 36 - 8) // cols
    cell_h = 80
    gap = 8
    for idx, (name, desc) in enumerate(cats):
        col = idx % cols
        row = idx // cols
        x = inner_x + col * (cell_w + gap)
        y = inner_y + row * (cell_h + gap)
        is_live = name in ("integration", "e2e-api", "e2e-ui", "stress", "load")
        accent = scene.accent if is_live else "0x9aa4ad"
        lines.append(dialogue(2, start, end, with_fade(rect(x, y, cell_w, cell_h, "0x0e1623", "20"))))
        lines.append(dialogue(2, start, end, with_fade(rect(x, y, cell_w, 4, accent, "00"))))
        lines.append(dialogue(3, start, end,
            with_fade(text(name, x + 14, y + 14, 19, "0xffffff", "00", 7, True, MONO_FONT))))
        lines.append(dialogue(3, start, end,
            with_fade(text(desc, x + 14, y + 44, 15, "0xffffff", "30", 7, False, FONT))))


def render_panel_loop_wheel(lines: list[str], start: float, end: float, scene: Scene, data: dict) -> None:
    """THE LOOP: 5 strong-side principles in a clean vertical list with a back-to-top rail."""
    panel_frame(lines, start, end, scene, data.get("header", "THE LOOP"))
    principles = (
        ("mechanical gates", "no opinion-based pass / fail"),
        ("explicit ownership", "each artifact has one owner"),
        ("raw evidence", "ten lines of real terminal output"),
        ("capped retries", "at most three self-heal attempts"),
        ("config over code", "new mode = new yaml entry"),
    )
    inner_left = PANEL_LEFT + 56
    inner_top = PANEL_TOP + 78
    cell_w = PANEL_WIDTH - 132
    cell_h = 60
    gap_y = 12
    centers_y: list[int] = []
    for idx, (label, sub) in enumerate(principles):
        y = inner_top + idx * (cell_h + gap_y)
        centers_y.append(y + cell_h // 2)
        sub_start = stagger(start, end, idx, base=0.10, step=0.16)
        lines.append(dialogue(2, sub_start, end, with_fade(rect(inner_left, y, cell_w, cell_h, "0x0e1623", "20"))))
        lines.append(dialogue(2, sub_start, end, with_fade(rect(inner_left, y, 6, cell_h, scene.accent, "00"))))
        lines.append(dialogue(3, sub_start, end,
            with_fade(text(f"{idx+1:02d}", inner_left + 22, y + 8, 24, scene.accent, "00", 7, True, MONO_FONT))))
        lines.append(dialogue(3, sub_start, end,
            with_fade(text(label, inner_left + 70, y + 8, 18, "0xffffff", "00", 7, True, MONO_FONT))))
        lines.append(dialogue(3, sub_start, end,
            with_fade(text(sub, inner_left + 70, y + 32, 12, "0xffffff", "30", 7, False, FONT))))
    # Forward arrows down the centre.
    arrow_x = inner_left + cell_w // 2
    for idx in range(len(centers_y) - 1):
        sub_start = stagger(start, end, idx + 1, base=0.30, step=0.16)
        a_top = centers_y[idx] + cell_h // 2
        a_bot = centers_y[idx + 1] - cell_h // 2
        draw_arrow(lines, 3, sub_start, end, arrow_x, a_top + 2, arrow_x, a_bot - 2, scene.accent, "00", 3, 9)
    # Loop-back rail on the right (last -> first).
    back_x = inner_left + cell_w + 32
    a_top = centers_y[0]
    a_bot = centers_y[-1]
    sub_start = stagger(start, end, len(centers_y) + 2, base=0.6, step=0.0)
    for cy_node in (a_top, a_bot):
        draw_thick_line(lines, 2, sub_start, end, inner_left + cell_w, cy_node, back_x, cy_node, scene.accent, "60", 4)
    draw_thick_line(lines, 2, sub_start, end, back_x, a_bot, back_x, a_top, scene.accent, "60", 4)
    draw_arrowhead(lines, 3, sub_start, end, back_x, a_top + 4, "N", 14, scene.accent, "00")
    lines.append(dialogue(4, sub_start, end,
        with_fade(text("loop", back_x - 14, (a_top + a_bot) // 2 - 8, 13, scene.accent, "00", 5, True, MONO_FONT))))


def render_panel_slop_gauge(lines: list[str], start: float, end: float, scene: Scene, data: dict) -> None:
    """Clean SLOP TAX KPI: big target value + small caption + 4 contributing-factor cards (no dial)."""
    panel_frame(lines, start, end, scene, data.get("header", "SLOP TAX KPI"))
    inner_x = PANEL_LEFT + 18
    inner_y = PANEL_TOP + 70
    inner_w = PANEL_WIDTH - 36
    # Hero KPI block (target value + caption) inside its own card.
    hero_h = 130
    lines.append(dialogue(2, stagger(start, end, 0, base=0.10, step=0.0), end,
        with_fade(rect(inner_x, inner_y, inner_w, hero_h, "0x0e1623", "20"))))
    lines.append(dialogue(2, stagger(start, end, 0, base=0.10, step=0.0), end,
        with_fade(rect(inner_x, inner_y, 6, hero_h, scene.accent, "00"))))
    # "TARGET" label, small, at top of hero card.
    lines.append(dialogue(3, stagger(start, end, 1, base=0.20, step=0.0), end,
        with_fade(text("TARGET", inner_x + 22, inner_y + 12, 14, "0xffffff", "30", 7, True, MONO_FONT))))
    # Big "< 15%" centered in the hero card.
    lines.append(dialogue(4, stagger(start, end, 2, base=0.35, step=0.0), end,
        with_fade(text("< 15%", inner_x + 22, inner_y + 36, 60, scene.accent, "00", 7, True, FONT))))
    # Caption under the value.
    lines.append(dialogue(3, stagger(start, end, 3, base=0.5, step=0.0), end,
        with_fade(text("of scopes can reopen, retry, or revert", inner_x + 22, inner_y + 100, 14, "0xffffff", "30", 7, False, FONT))))
    # Section divider header for factors.
    factors_header_y = inner_y + hero_h + 18
    lines.append(dialogue(3, stagger(start, end, 4, base=0.65, step=0.0), end,
        with_fade(text("CONTRIBUTING FACTORS", inner_x, factors_header_y, 13, scene.accent, "00", 7, True, MONO_FONT))))
    # Contributing factor cards.
    items = (
        ("scope reopens", "regressions opened twice"),
        ("phase retries", "self-heal attempts"),
        ("post-validate reverts", "user uncheck after sign-off"),
        ("fix-on-fix chains", "patching the patch"),
    )
    list_y = factors_header_y + 22
    card_h = 42
    card_gap = 6
    for idx, (label, desc) in enumerate(items):
        y = list_y + idx * (card_h + card_gap)
        sub_start = stagger(start, end, idx + 5, base=0.85, step=0.10)
        lines.append(dialogue(2, sub_start, end,
            with_fade(rect(inner_x, y, inner_w, card_h, "0x0e1623", "20"))))
        lines.append(dialogue(2, sub_start, end, with_fade(rect(inner_x, y, 6, card_h, scene.accent, "00"))))
        lines.append(dialogue(3, sub_start, end,
            with_fade(text(label, inner_x + 22, y + 6, 15, "0xffffff", "00", 7, True, MONO_FONT))))
        lines.append(dialogue(3, sub_start, end,
            with_fade(text(desc, inner_x + 22, y + 24, 12, "0xffffff", "30", 7, False, FONT))))


PANEL_RENDERERS = {
    "board": render_panel_board,
    "terminal": render_panel_terminal,
    "six_artifacts": render_panel_six_artifacts,
    "workflow_modes": render_panel_workflow_modes,
    "chain": render_panel_chain,
    "agent_flow": render_panel_agent_flow,
    "scopes_tree": render_panel_scopes_tree,
    "recipe_stack": render_panel_recipe_stack,
    "test_grid": render_panel_test_grid,
    "loop_wheel": render_panel_loop_wheel,
    "slop_gauge": render_panel_slop_gauge,
}


def render_panel(lines: list[str], start: float, end: float, scene: Scene, panel: dict) -> None:
    PANEL_RENDERERS[panel["kind"]](lines, start, end, scene, panel)


# Panel mapped to each scene (parallel to SCENES). Keep narration unchanged;
# only the right-side visual changes per scene.
PANELS: tuple[dict, ...] = (
    # 1 THE PROBLEM
    {"kind": "board", "header": "SUNNYVALE OPS LOG"},
    # 2 DEVELOPERS
    {
        "kind": "terminal",
        "header": "BASH \u2014 bubbles",
        "lines": (
            "$ /bubbles.workflow --feature 312",
            "[ implement ]  PASS",
            "[ test      ]  PASS",
            "[ audit     ]  PASS",
            "[ docs      ]  PASS",
            "$ state-transition-guard",
            "\u2713 every DoD has raw evidence",
            "\u2713 no stub data detected",
            "\u2713 live tests are unmocked",
            "\u2192 status: in_progress -> done",
        ),
    },
    # 3 PRODUCT MANAGERS
    {"kind": "six_artifacts", "header": "REQUIRED ARTIFACTS"},
    # 4 PRODUCT LEADERS
    {"kind": "slop_gauge", "header": "SLOP TAX KPI"},
    # 5 THE SHIFT
    {"kind": "workflow_modes", "header": "THREE WAYS TO RUN THE LOOP"},
    # 6 EVIDENCE / RECEIPTS
    {"kind": "chain", "header": "TRACEABILITY CHAIN"},
    # 7 SPECIALISTS WITH LANES
    {"kind": "agent_flow", "header": "DISPATCH MAP"},
    # 8 SCOPES THAT DO NOT COLLIDE
    {"kind": "scopes_tree", "header": "PER-SCOPE LAYOUT"},
    # 9 WORKFLOWS
    {"kind": "recipe_stack", "header": "WORKFLOW LIBRARY"},
    # 10 TESTS
    {"kind": "test_grid", "header": "TEST TAXONOMY"},
    # 11 STRONG SIDES
    {"kind": "loop_wheel", "header": "THE LOOP"},
    # 12 THE FIRST MOVE
    {
        "kind": "terminal",
        "header": "BASH \u2014 first run",
        "lines": (
            "$ git clone bubbles && cd bubbles",
            "$ ./install.sh",
            "$ /bubbles.bootstrap",
            "$ /bubbles.goal \"one painful outcome,",
            "    end to end, with receipts\"",
            "\u2192 specs/318-painful-outcome/",
            "\u2192 6 artifacts written",
            "\u2192 specialist chain dispatched",
            "\u2713 inspect specs/318/report.md",
            "  to read the trail.",
        ),
    },
)


# Bullets with a soft fade-in stagger so each row "lands" instead of popping.
def add_bullet_list_animated(lines: list[str], start: float, end: float, scene: Scene) -> None:
    cursor = 494
    for bullet_index, bullet in enumerate(scene.bullets):
        wrapped = wrap_line(bullet, 58)
        box_height = 54 + len(wrapped) * 31
        bullet_start = min(end - 0.05, start + 0.10 + bullet_index * 0.18)
        lines.append(dialogue(2, bullet_start, end,
            with_fade(rect(112, cursor - 18, 1080, box_height, "0x000000", "93"))))
        lines.append(dialogue(2, bullet_start, end,
            with_fade(rect(112, cursor - 18, 10, box_height, scene.accent, "06"))))
        lines.append(dialogue(3, bullet_start, end,
            with_fade(text(str(bullet_index + 1), 146, cursor - 1, 29, scene.accent, "00", 7, True, MONO_FONT))))
        text_y = cursor - 1
        for line_index, wline in enumerate(wrapped):
            lines.append(dialogue(3, bullet_start, end,
                with_fade(text(wline, 206, text_y + line_index * 31, 28, "0xffffff", "18", 7))))
        cursor += box_height + 20


# Bottom-edge progress strip that fills left-to-right scene by scene.
CHAPTER_STRIP_Y = 1056
CHAPTER_STRIP_H = 8


def add_chapter_strip(lines: list[str], scene_timings: list[tuple[float, float]]) -> None:
    total = scene_timings[-1][1]
    # Always-visible faint background.
    lines.append(dialogue(1, 0, total,
        rect(0, CHAPTER_STRIP_Y, WIDTH, CHAPTER_STRIP_H, "0xffffff", "E0")))
    seg_x = 0
    for (sstart, send), sscene in zip(scene_timings, SCENES):
        seg_w = int(WIDTH * (send - sstart) / total)
        scene_dur_ms = max(1, int((send - sstart) * 1000))
        # Filled segment: appears at scene start, grows from 0% to 100% width
        # over the scene duration, then stays full afterwards.
        body = (
            f"{{\\an7\\pos({seg_x},{CHAPTER_STRIP_Y})\\bord0\\shad0"
            f"\\1c&H{hex_to_ass_bgr(sscene.accent)}&\\alpha&H00&"
            f"\\fscx0\\t(0,{scene_dur_ms},\\fscx100)\\p1}}"
            f"m 0 0 l {seg_w} 0 l {seg_w} {CHAPTER_STRIP_H} l 0 {CHAPTER_STRIP_H}"
            "{\\p0}"
        )
        lines.append(dialogue(2, sstart, total, body))
        # Tick separator at the segment boundary (always visible).
        if seg_x + seg_w < WIDTH:
            lines.append(dialogue(2, 0, total,
                rect(seg_x + seg_w, CHAPTER_STRIP_Y - 2, 1, CHAPTER_STRIP_H + 4, "0xffffff", "60")))
        seg_x += seg_w


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
        f"Style: Default,DejaVu Sans,36,&H00FFFFFF,&H00FFFFFF,&H00000000,&H00000000,"
        "0,0,0,0,100,100,0,0,1,0,0,7,0,0,0,1",
        "",
        "[Events]",
        "Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text",
    ]

    total = scene_timings[-1][1]
    lines.append(dialogue(0, 0, total, rect(0, 0, WIDTH, HEIGHT, "0x0b1017")))

    # Bottom progress strip (one bar per scene, fills as time advances).
    add_chapter_strip(lines, scene_timings)

    scenes = SCENES
    for index, (scene, timing) in enumerate(zip(scenes, scene_timings), start=1):
        start, end = timing
        lines.append(dialogue(0, start, end, rect(0, 0, WIDTH, HEIGHT, scene.bg)))
        lines.append(dialogue(1, start, end, rect(0, 0, 52, HEIGHT, scene.accent)))
        lines.append(dialogue(1, start, end, rect(108, 72, 350, 48, scene.accent, "08")))
        lines.append(dialogue(1, start, end, rect(108, 210, 1710, 4, scene.accent, "18")))
        lines.append(dialogue(1, start, end, rect(1488, 72, 330, 92, "0x000000", "86")))
        lines.append(dialogue(2, start, end, text(f"{index:02d}/{len(scenes):02d}", 1530, 96, 35, scene.accent, "00", 7, True, MONO_FONT)))
        add_background_motif(lines, start, end, scene, index)

        lines.append(dialogue(3, start, end, text(scene.eyebrow, 132, 88, 25, "0x111827", "00", 7, True, MONO_FONT)))
        title_y = 248
        for line_index, title_line in enumerate(wrap_line(scene.title, 38)):
            lines.append(dialogue(3, start, end, text(title_line, 108, title_y + line_index * 72, 62, "0xffffff", "00", 7, True)))
        subtitle_y = 366 + max(0, len(wrap_line(scene.title, 38)) - 1) * 47
        for line_index, subtitle_line in enumerate(wrap_line(scene.subtitle, 76)):
            lines.append(dialogue(3, start, end, text(subtitle_line, 112, subtitle_y + line_index * 39, 32, "0xffffff", "22", 7)))

        add_bullet_list_animated(lines, start, end, scene)
        render_panel(lines, start, end, scene, PANELS[index - 1])
        add_corner_park_badge(lines, start, end, scene)

        footer = "Sunnyvale Park  \u00b7  Bubbles overview"
        lines.append(dialogue(3, start, end, text(footer, 112, 1010, 23, "0xffffff", "76", 7)))

    return "\n".join(lines) + "\n"


def pad_scene_audio(ffmpeg_bin: Path, source: Path, output: Path, duration: float) -> None:
    """Pad a single narration MP3 into a PCM WAV at the SOURCE rate (24 kHz mono).

    No loudnorm. No resample. The intermediate stays at the edge-tts native
    rate so that the only resample in the whole pipeline is the soxr-quality
    one that happens during the final AAC encode.
    """
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
        "-c:a",
        "pcm_s16le",
        "-ar",
        INTERMEDIATE_SAMPLE_RATE,
        "-ac",
        INTERMEDIATE_CHANNELS,
        str(output),
    ]
    subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def concat_audio_pcm(ffmpeg_bin: Path, padded_paths: list[Path], list_path: Path, output: Path) -> None:
    """Concatenate padded PCM WAVs at the intermediate rate. No re-encoding."""
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
        "pcm_s16le",
        "-ar",
        INTERMEDIATE_SAMPLE_RATE,
        "-ac",
        INTERMEDIATE_CHANNELS,
        str(output),
    ]
    subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def encode_audio_m4a(ffmpeg_bin: Path, source_pcm: Path, output: Path) -> None:
    """Single AAC pass for the standalone narration .m4a. NO loudnorm.

    The PCM input is at the source rate (24 kHz mono). This is the ONLY place
    in the whole pipeline that resamples — soxr precision-28 with triangular
    high-pass dither, up to 48 kHz stereo, then AAC at the chosen bitrate.
    """
    command = [
        str(ffmpeg_bin),
        "-y",
        "-hide_banner",
        "-nostats",
        "-i",
        str(source_pcm),
        "-af",
        FINAL_AFILTER,
        "-c:a",
        "aac",
        "-b:a",
        AUDIO_BITRATE,
        "-ar",
        AUDIO_SAMPLE_RATE,
        "-ac",
        AUDIO_CHANNELS,
        "-movflags",
        "+faststart",
        str(output),
    ]
    subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def render_video(ffmpeg_bin: Path, ass_path: Path, audio_pcm: Path, duration: float, output_path: Path) -> None:
    """Render the MP4. The audio source is the source-rate PCM, so the video
    file contains a single AAC encode with the same single soxr resample stage
    used by the standalone .m4a — never a re-encode of an already-AAC file.
    """
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
        str(audio_pcm),
        "-vf",
        f"ass={ass_path}",
        "-af",
        FINAL_AFILTER,
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
        "-ac",
        AUDIO_CHANNELS,
        "-movflags",
        "+faststart",
        str(output_path),
    ]
    subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


CHAPTER_TITLES: tuple[str, ...] = (
    "The Problem",
    "Developers",
    "Product Managers",
    "Product Leaders",
    "The Shift",
    "Mechanical Gates",
    "Six Required Artifacts",
    "Per-Scope Layout",
    "Workflow Library",
    "Specialists With Lanes",
    "The Loop",
    "The First Move",
)


def build_ffmetadata_chapters(scene_timings: list[tuple[float, float]]) -> str:
    """Build an ffmpeg metadata file with [CHAPTER] blocks (TIMEBASE 1/1000)."""
    if len(scene_timings) != len(CHAPTER_TITLES):
        raise RuntimeError(
            f"CHAPTER_TITLES count ({len(CHAPTER_TITLES)}) must match scene count ({len(scene_timings)})"
        )
    parts: list[str] = [";FFMETADATA1", ""]
    for (start_s, end_s), title in zip(scene_timings, CHAPTER_TITLES):
        parts.append("[CHAPTER]")
        parts.append("TIMEBASE=1/1000")
        parts.append(f"START={int(round(start_s * 1000))}")
        parts.append(f"END={int(round(end_s * 1000))}")
        parts.append(f"title={title}")
        parts.append("")
    return "\n".join(parts)


def build_youtube_chapter_description(scene_timings: list[tuple[float, float]]) -> str:
    """Build a plain-text MM:SS chapter list for the YouTube description.

    YouTube requires the first chapter to start at 00:00 and there must be at
    least three chapters each ten seconds or more apart.
    """
    if len(scene_timings) != len(CHAPTER_TITLES):
        raise RuntimeError(
            f"CHAPTER_TITLES count ({len(CHAPTER_TITLES)}) must match scene count ({len(scene_timings)})"
        )
    lines: list[str] = []
    for (start_s, _end_s), title in zip(scene_timings, CHAPTER_TITLES):
        total = int(start_s)
        mm = total // 60
        ss = total % 60
        lines.append(f"{mm:02d}:{ss:02d} {title}")
    return "\n".join(lines) + "\n"


def mux_chapters(ffmpeg_bin: Path, video_path: Path, chapters_metadata: Path) -> None:
    """Re-mux the MP4 in place, attaching chapter metadata without re-encoding."""
    tmp_out = video_path.with_suffix(".chapters.mp4")
    command = [
        str(ffmpeg_bin),
        "-y",
        "-hide_banner",
        "-nostats",
        "-i",
        str(video_path),
        "-i",
        str(chapters_metadata),
        "-map_metadata",
        "1",
        "-map_chapters",
        "1",
        "-c",
        "copy",
        str(tmp_out),
    ]
    subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    tmp_out.replace(video_path)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ffmpeg-bin", required=True, type=Path, help="Path to ffmpeg")
    parser.add_argument("--output", type=Path, help="Output MP4 path (omit when --audio-only is set)")
    parser.add_argument("--audio-output", type=Path, help="Combined narration .m4a path")
    parser.add_argument("--transcript-output", type=Path, help="Optional transcript markdown output")
    parser.add_argument(
        "--audio-only",
        action="store_true",
        help="Render only the narration .m4a so the voice can be auditioned before MP4 work.",
    )
    args = parser.parse_args()

    if args.audio_only:
        if not args.audio_output:
            parser.error("--audio-only requires --audio-output")
    else:
        if not args.output:
            parser.error("--output is required unless --audio-only is set")
    return args


def main() -> None:
    args = parse_args()
    require_file(args.ffmpeg_bin, "ffmpeg binary")
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
    if args.audio_output:
        args.audio_output.parent.mkdir(parents=True, exist_ok=True)
    if args.transcript_output:
        args.transcript_output.parent.mkdir(parents=True, exist_ok=True)
        args.transcript_output.write_text(build_transcript(), encoding="utf-8")

    with tempfile.TemporaryDirectory(prefix="bubbles-dev-pm-pitch-") as temp_dir_name:
        temp_dir = Path(temp_dir_name)
        raw_audio_paths = [temp_dir / f"scene-{index:02d}.mp3" for index in range(len(SCENES))]
        asyncio.run(synthesize_all(raw_audio_paths))

        scene_durations: list[float] = []
        padded_paths: list[Path] = []
        for index, raw_path in enumerate(raw_audio_paths):
            speech_duration = base.probe_duration(args.ffmpeg_bin, raw_path)
            scene_duration = speech_duration + SCENE_PAD_SECONDS
            scene_durations.append(scene_duration)
            padded_path = temp_dir / f"scene-{index:02d}-padded.wav"
            pad_scene_audio(args.ffmpeg_bin, raw_path, padded_path, scene_duration)
            padded_paths.append(padded_path)

        combined_pcm = temp_dir / "combined-narration.wav"
        concat_audio_pcm(args.ffmpeg_bin, padded_paths, temp_dir / "audio-list.txt", combined_pcm)

        total_duration = sum(scene_durations)
        scene_timings: list[tuple[float, float]] = []
        cursor = 0.0
        for duration in scene_durations:
            scene_timings.append((cursor, cursor + duration))
            cursor += duration

        if args.audio_output:
            encode_audio_m4a(args.ffmpeg_bin, combined_pcm, args.audio_output)
            print(f"Wrote narration: {args.audio_output}")

        if args.audio_only:
            print(f"Audio-only mode complete. Total duration: {total_duration:.2f}s ({total_duration/60:.2f} min).")
            return

        ass_path = temp_dir / "overlay.ass"
        ass_path.write_text(build_ass(scene_timings), encoding="utf-8")
        render_video(args.ffmpeg_bin, ass_path, combined_pcm, total_duration, args.output)

        # Attach YouTube chapter metadata in-place (no re-encode).
        ffmeta_path = temp_dir / "chapters.ffmetadata"
        ffmeta_path.write_text(build_ffmetadata_chapters(scene_timings), encoding="utf-8")
        mux_chapters(args.ffmpeg_bin, args.output, ffmeta_path)

        # Write the description-friendly chapter list next to the MP4.
        chapters_txt_path = args.output.with_name(args.output.stem + "-chapters.txt")
        chapters_txt_path.write_text(build_youtube_chapter_description(scene_timings), encoding="utf-8")
        print(f"Wrote video: {args.output}")
        print(f"Wrote chapter list: {chapters_txt_path}")
        print(f"Total duration: {total_duration:.2f}s ({total_duration/60:.2f} min).")


if __name__ == "__main__":
    main()
