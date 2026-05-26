#!/usr/bin/env python3
"""Render a short original TBD-style Bubbles cartoon overview."""

from __future__ import annotations

import argparse
import asyncio
import re
import subprocess
import tempfile
from dataclasses import dataclass
from pathlib import Path

WIDTH = 1920
HEIGHT = 1080
FPS = 30
FONT = "DejaVu Sans"
MONO_FONT = "DejaVu Sans Mono"
VOICE = "en-US-BrianNeural"
VOICE_VOLUME = "+0%"
SCENE_PAD_SECONDS = 0.45
AUDIO_BITRATE = "256k"
AUDIO_SAMPLE_RATE = "48000"
LOUDNESS_FILTER = "loudnorm=I=-16:TP=-1.5:LRA=11"
VIDEO_CRF = "16"
VIDEO_PRESET = "veryfast"


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
    face: str
    voice_rate: str = "-4%"


SCENES: tuple[Scene, ...] = (
    Scene(
        eyebrow="TBD HQ",
        title="Bubbles: Tiny Bubble Department",
        subtitle="A goofy little dispatch office for serious AI coding work.",
        bullets=(
            "Copilot brings the engine.",
            "Bubbles brings the crew, rules, and receipts.",
            "The vibe is silly. The workflow is not.",
        ),
        board_lines=(
            "HIGH LEVEL:",
            "Idea in",
            "specialists route it",
            "work leaves proof",
            "done means actually done",
        ),
        narration=(
            "Welcome to TBD, the Tiny Bubble Department. Bubbles gives AI coding a tiny dispatch office, a clipboard, and one serious rule: if you say done, bring receipts."
        ),
        bg="0x101722",
        accent="0x39d0c8",
        face="boss",
    ),
    Scene(
        eyebrow="THE MESS",
        title="Before Bubbles: The Vibes Truck Is On Fire",
        subtitle="AI wrote a diff. Great. Now everyone has questions and one snack left.",
        bullets=(
            "Requirements drift into the weeds.",
            "Tests may pass because nobody asked the hard question.",
            "A final answer sounds confident while the repo sweats.",
        ),
        board_lines=(
            "NORMAL CHAOS:",
            "big diff",
            "tiny proof",
            "stale docs",
            "mystery endpoint",
            "manager squinting",
        ),
        narration=(
            "Here is the usual mess. The agent writes a giant diff, smiles proudly, and the repo whispers: cool, but did anybody test the actual thing?"
        ),
        bg="0x251414",
        accent="0xff7b72",
        face="worried",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="DISPATCH",
        title="Bubbles Sends The Right Specialist",
        subtitle="Not every job needs one mega-agent wearing twelve hats badly.",
        bullets=(
            "Analyst figures out what must be true.",
            "Design, plan, implement, test, docs, validate, and audit own lanes.",
            "Workflow routes the work so artifacts stop arm wrestling.",
        ),
        board_lines=(
            "CREW CALL:",
            "analyst -> truth",
            "design -> shape",
            "plan -> slices",
            "implement -> code",
            "validate -> proof",
        ),
        narration=(
            "Bubbles stops one chat from wearing twelve hats badly. Analyst finds truth, design shapes it, plan slices it, implement builds it, and validate asks for proof."
        ),
        bg="0x17251f",
        accent="0x3fb950",
        face="happy",
    ),
    Scene(
        eyebrow="WORKFLOW",
        title="Plain Request Becomes A Work Trail",
        subtitle="The useful part is not the ceremony. It is continuity with evidence.",
        bullets=(
            "Start with a goal or use /bubbles.workflow for normal delivery.",
            "Specs, scopes, reports, validation, and state stay connected.",
            "The next session can continue instead of excavating the parking lot.",
        ),
        board_lines=(
            "FLOW:",
            "request",
            "analysis",
            "design",
            "plan",
            "build",
            "test",
            "certify",
        ),
        narration=(
            "A plain request goes in. Bubbles turns it into specs, scopes, tests, reports, and state, so the next session starts with evidence instead of archaeology."
        ),
        bg="0x102033",
        accent="0x58a6ff",
        face="dispatcher",
    ),
    Scene(
        eyebrow="CAPABILITY FIRST",
        title="Build The Foundation, Then Plug In Providers",
        subtitle="One shed, many tools. Don't weld the wrench to the shed.",
        bullets=(
            "Analyst models the domain capability.",
            "Design splits foundation from concrete implementations.",
            "Plan puts foundation scopes before provider overlays.",
        ),
        board_lines=(
            "G094:",
            "capability foundation",
            "concrete implementations",
            "variation axes",
            "foundation:true first",
        ),
        narration=(
            "Capability first. Provider second. Bubbles designs the shed before parking tools in it: one notification foundation, then ntfy, email, webhook, or whatever else plugs in later."
        ),
        bg="0x1f2430",
        accent="0xf2c14e",
        face="strict",
    ),
    Scene(
        eyebrow="GATES",
        title="The Gates Are Tiny But Annoyingly Correct",
        subtitle="A checkbox without output is just decorative confetti.",
        bullets=(
            "Raw evidence is required for claims that work passed.",
            "No fake done, no silent skips, no test-shaped decorations.",
            "If validation fails, Bubbles routes the rework instead of shrugging.",
        ),
        board_lines=(
            "GATE SAYS:",
            "show output",
            "prove route exists",
            "prove test can fail",
            "update docs",
            "then celebrate",
        ),
        narration=(
            "The gates are tiny, strict, and allergic to vibes. Checked box? Show output. New endpoint? Show the consumer. Test passed? Prove it was real."
        ),
        bg="0x2c2011",
        accent="0xd29922",
        face="strict",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="WHO WINS",
        title="Developers, Managers, And Leadership All Get A Handle",
        subtitle="Same system, different headache reduced.",
        bullets=(
            "Developers get less rework and cleaner handoffs.",
            "Managers get inspectable progress instead of confident fog.",
            "Leadership gets AI adoption with control surfaces.",
        ),
        board_lines=(
            "BENEFITS:",
            "devs: less redo",
            "managers: visible status",
            "leaders: governance",
            "users: fewer broken things",
        ),
        narration=(
            "Developers get fewer mystery chores. Managers get inspectable status. Leadership gets AI adoption with control surfaces. Users get fewer broken things. Beautiful, suspiciously organized stuff."
        ),
        bg="0x241b2f",
        accent="0xbc8cff",
        face="team",
    ),
    Scene(
        eyebrow="START SMALL",
        title="Use It On One Painful Workflow First",
        subtitle="Pick a bug, a feature, or a release. Let the little office prove itself.",
        bullets=(
            "Try one real workflow where context usually gets lost.",
            "Let specialists create the trail and gates demand proof.",
            "If it saves a Friday, the department has earned its rent.",
        ),
        board_lines=(
            "TRY:",
            "/bubbles.workflow",
            "fix the flaky checkout bug",
            "prove it with evidence",
            "ship cleaner",
        ),
        narration=(
            "Try it on one painful workflow: a flaky bug, a fuzzy feature, or a release with extra elbows. Let the tiny department prove the work."
        ),
        bg="0x151515",
        accent="0xffffff",
        face="celebrate",
        voice_rate="-4%",
    ),
)


@dataclass(frozen=True)
class TimedScene:
    scene: Scene
    start: float
    end: float


def require_file(path: Path, label: str) -> None:
    if not path.is_file():
        raise SystemExit(f"Missing {label}: {path}")


def ass_time(seconds: float) -> str:
    centiseconds = int(round(seconds * 100))
    hours, centiseconds = divmod(centiseconds, 360000)
    minutes, centiseconds = divmod(centiseconds, 6000)
    secs, centiseconds = divmod(centiseconds, 100)
    return f"{hours}:{minutes:02d}:{secs:02d}.{centiseconds:02d}"


def srt_time(seconds: float) -> str:
    milliseconds = int(round(seconds * 1000))
    hours, milliseconds = divmod(milliseconds, 3_600_000)
    minutes, milliseconds = divmod(milliseconds, 60_000)
    secs, milliseconds = divmod(milliseconds, 1000)
    return f"{hours:02d}:{minutes:02d}:{secs:02d},{milliseconds:03d}"


def vtt_time(seconds: float) -> str:
    return srt_time(seconds).replace(",", ".")


def youtube_time(seconds: float) -> str:
    total_seconds = int(seconds)
    minutes, secs = divmod(total_seconds, 60)
    return f"{minutes:02d}:{secs:02d}"


def hex_to_ass_bgr(value: str) -> str:
    cleaned = value.removeprefix("0x").removeprefix("#")
    if len(cleaned) != 6:
        raise ValueError(f"Invalid color: {value}")
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


def shape(body: str, xpos: int, ypos: int, color: str, alpha: str = "00") -> str:
    return f"{{\\an7\\pos({xpos},{ypos})\\p1\\bord0\\shad0{color_tag(color, alpha)}}}{body}{{\\p0}}"


def rectangle(xpos: int, ypos: int, width: int, height: int, color: str, alpha: str = "00") -> str:
    body = f"m 0 0 l {width} 0 l {width} {height} l 0 {height}"
    return shape(body, xpos, ypos, color, alpha)


def polygon(xpos: int, ypos: int, points: tuple[tuple[int, int], ...], color: str, alpha: str = "00") -> str:
    first_xpos, first_ypos = points[0]
    segments = [f"m {first_xpos} {first_ypos}"]
    for point_xpos, point_ypos in points[1:]:
        segments.append(f"l {point_xpos} {point_ypos}")
    return shape(" ".join(segments), xpos, ypos, color, alpha)


def circle(xpos: int, ypos: int, radius: int, color: str, alpha: str = "00") -> str:
    diameter = radius * 2
    control = int(radius * 0.55228475)
    body = (
        f"m {radius} 0 "
        f"b {radius + control} 0 {diameter} {radius - control} {diameter} {radius} "
        f"b {diameter} {radius + control} {radius + control} {diameter} {radius} {diameter} "
        f"b {radius - control} {diameter} 0 {radius + control} 0 {radius} "
        f"b 0 {radius - control} {radius - control} 0 {radius} 0"
    )
    return shape(body, xpos - radius, ypos - radius, color, alpha)


def line_shape(start_xpos: int, start_ypos: int, end_xpos: int, end_ypos: int, color: str, alpha: str = "00") -> str:
    width = max(abs(end_xpos - start_xpos), 8)
    height = max(abs(end_ypos - start_ypos), 8)
    left = min(start_xpos, end_xpos)
    top = min(start_ypos, end_ypos)
    return rectangle(left, top, width, height, color, alpha)


def text(
    value: str,
    xpos: int,
    ypos: int,
    size: int,
    color: str,
    alpha: str = "00",
    align: int = 7,
    bold: bool = False,
    font: str = FONT,
) -> str:
    weight = "\\b1" if bold else "\\b0"
    return (
        f"{{\\an{align}\\pos({xpos},{ypos})\\fn{font}\\fs{size}{weight}\\bord0\\shad0"
        f"{color_tag(color, alpha)}}}{ass_text(value)}"
    )


def wrap_line(value: str, max_chars: int) -> list[str]:
    words = value.split()
    lines: list[str] = []
    current: list[str] = []
    current_len = 0
    for word in words:
        extra = 1 if current else 0
        if current and current_len + len(word) + extra > max_chars:
            lines.append(" ".join(current))
            current = [word]
            current_len = len(word)
        else:
            current.append(word)
            current_len += len(word) + extra
    if current:
        lines.append(" ".join(current))
    return lines


def wrapped_text(value: str, xpos: int, ypos: int, size: int, color: str, max_chars: int, alpha: str = "00", bold: bool = False) -> tuple[str, int]:
    lines = wrap_line(value, max_chars)
    line_height = int(size * 1.25)
    body = "\\N".join(ass_text(line_value) for line_value in lines)
    return text(body, xpos, ypos, size, color, alpha, 7, bold), max(len(lines), 1) * line_height


def add_bubble_person(
    lines: list[str],
    start: float,
    end: float,
    center_xpos: int,
    center_ypos: int,
    accent: str,
    label: str,
    face: str,
    scale: float = 1.0,
) -> None:
    radius = int(58 * scale)
    eye_offset_x = int(20 * scale)
    eye_offset_y = int(10 * scale)
    eye_radius = max(3, int(6 * scale))
    lines.append(dialogue(5, start, end, circle(center_xpos, center_ypos, radius, "0xf7fbff", "00")))
    lines.append(dialogue(6, start, end, circle(center_xpos, center_ypos, radius, accent, "A8")))
    lines.append(dialogue(7, start, end, circle(center_xpos - eye_offset_x, center_ypos - eye_offset_y, eye_radius, "0x111827", "00")))
    lines.append(dialogue(7, start, end, circle(center_xpos + eye_offset_x, center_ypos - eye_offset_y, eye_radius, "0x111827", "00")))
    mouth_width = int((42 if face != "strict" else 32) * scale)
    mouth_ypos = center_ypos + int((20 if face in {"happy", "celebrate", "team"} else 18) * scale)
    lines.append(dialogue(7, start, end, rectangle(center_xpos - mouth_width // 2, mouth_ypos, mouth_width, max(4, int(6 * scale)), "0x111827", "18")))
    if face in {"boss", "dispatcher", "strict"}:
        lines.append(dialogue(7, start, end, rectangle(center_xpos - int(42 * scale), center_ypos - int(88 * scale), int(84 * scale), int(22 * scale), accent, "00")))
        lines.append(dialogue(7, start, end, rectangle(center_xpos - int(25 * scale), center_ypos - int(118 * scale), int(50 * scale), int(38 * scale), accent, "00")))
    if face == "worried":
        lines.append(dialogue(8, start, end, text("?!", center_xpos - int(9 * scale), center_ypos - int(96 * scale), int(34 * scale), "0xffd866", "00", 7, True)))
    if face == "celebrate":
        lines.append(dialogue(8, start, end, text("OK", center_xpos - int(25 * scale), center_ypos - int(103 * scale), int(30 * scale), "0x111827", "00", 7, True)))
    note_x = center_xpos + int(48 * scale)
    note_y = center_ypos + int(35 * scale)
    lines.append(dialogue(7, start, end, rectangle(note_x, note_y, int(46 * scale), int(58 * scale), "0xf4d6a0", "00")))
    lines.append(dialogue(8, start, end, rectangle(note_x + int(8 * scale), note_y + int(9 * scale), int(30 * scale), max(3, int(4 * scale)), "0x111827", "60")))
    lines.append(dialogue(8, start, end, rectangle(note_x + int(8 * scale), note_y + int(23 * scale), int(30 * scale), max(3, int(4 * scale)), "0x111827", "60")))
    lines.append(dialogue(8, start, end, text(label, center_xpos, center_ypos + int(90 * scale), max(16, int(24 * scale)), "0xffffff", "35", 5, True)))


def add_tbd_office(lines: list[str], start: float, end: float, accent: str) -> None:
    base_xpos = 120
    base_ypos = 735
    lines.append(dialogue(3, start, end, rectangle(base_xpos + 20, base_ypos + 104, 500, 28, "0x000000", "AA")))
    lines.append(dialogue(4, start, end, rectangle(base_xpos + 58, base_ypos, 410, 104, "0xf4d6a0", "00")))
    lines.append(dialogue(4, start, end, rectangle(base_xpos + 74, base_ypos + 16, 378, 76, "0x1f2937", "B2")))
    lines.append(dialogue(4, start, end, polygon(base_xpos + 22, base_ypos - 52, ((0, 52), (242, 0), (500, 52)), accent, "00")))
    lines.append(dialogue(5, start, end, rectangle(base_xpos + 148, base_ypos + 35, 120, 69, "0x101722", "00")))
    lines.append(dialogue(5, start, end, rectangle(base_xpos + 302, base_ypos + 32, 112, 72, "0x101722", "00")))
    lines.append(dialogue(6, start, end, rectangle(base_xpos + 314, base_ypos + 44, 88, 13, accent, "18")))
    lines.append(dialogue(6, start, end, rectangle(base_xpos + 160, base_ypos + 46, 96, 4, accent, "35")))
    lines.append(dialogue(7, start, end, text("TBD", base_xpos + 250, base_ypos + 10, 33, "0xffffff", "00", 5, True)))
    lines.append(dialogue(7, start, end, text("Tiny Bubble Dept.", base_xpos + 360, base_ypos + 62, 18, "0xffffff", "18", 5, True)))


def add_cartoon_scene(lines: list[str], timed_scene: TimedScene, index: int, total: int) -> None:
    scene = timed_scene.scene
    start = timed_scene.start
    end = timed_scene.end
    accent = scene.accent
    duration = end - start

    lines.append(dialogue(0, start, end, rectangle(0, 0, WIDTH, HEIGHT, scene.bg)))
    lines.append(dialogue(1, start, end, rectangle(0, 0, WIDTH, HEIGHT, "0x000000", "CF")))
    lines.append(dialogue(1, start, end, rectangle(0, 0, 42, HEIGHT, accent, "08")))
    lines.append(dialogue(1, start, end, rectangle(0, HEIGHT - 124, WIDTH, 124, "0x000000", "82")))
    lines.append(dialogue(1, start, end, rectangle(0, HEIGHT - 124, int(WIDTH * (index + 1) / total), 10, accent, "00")))

    for grid_xpos in range(220, WIDTH, 220):
        lines.append(dialogue(1, start, end, rectangle(grid_xpos, 0, 1, HEIGHT, "0xffffff", "ED")))
    for grid_ypos in range(180, HEIGHT, 180):
        lines.append(dialogue(1, start, end, rectangle(0, grid_ypos, WIDTH, 1, "0xffffff", "F0")))

    for bubble_index in range(10):
        bubble_xpos = 1040 + ((bubble_index * 73 + index * 47) % 760)
        bubble_ypos = 150 + ((bubble_index * 107 + index * 39) % 760)
        bubble_radius = 16 + ((bubble_index + index) % 4) * 8
        lines.append(dialogue(2, start, end, circle(bubble_xpos, bubble_ypos, bubble_radius, accent, "A8")))

    add_tbd_office(lines, start, end, accent)
    add_bubble_person(lines, start, end, 270, 700, accent, "dispatcher", scene.face, 0.72)
    add_bubble_person(lines, start, end, 405, 707, "0x79c0ff", "agent", "happy", 0.72)
    add_bubble_person(lines, start, end, 540, 714, "0xffa657", "gate", "strict", 0.72)

    lines.append(dialogue(5, start, end, rectangle(110, 80, 280, 50, accent, "00")))
    lines.append(dialogue(6, start, end, text(scene.eyebrow, 132, 93, 28, "0x111827", "00", 7, True)))
    lines.append(dialogue(6, start, end, text(f"{index + 1:02d}/{total:02d}", 1710, 92, 34, accent, "00", 7, True)))

    title_text, title_height = wrapped_text(scene.title, 110, 170, 62, "0xffffff", 28, "00", True)
    lines.append(dialogue(6, start, end, title_text))
    subtitle_text, subtitle_height = wrapped_text(scene.subtitle, 114, 190 + title_height, 31, "0xffffff", 45, "35")
    lines.append(dialogue(6, start, end, subtitle_text))

    bullet_ypos = 342
    for bullet_index, bullet in enumerate(scene.bullets):
        bullet_text, bullet_height = wrapped_text(bullet, 188, bullet_ypos, 30, "0xffffff", 44, "22")
        box_height = bullet_height + 26
        lines.append(dialogue(4, start, end, rectangle(128, bullet_ypos - 16, 785, box_height, "0x000000", "A4")))
        lines.append(dialogue(5, start, end, rectangle(128, bullet_ypos - 16, 10, box_height, accent, "08")))
        lines.append(dialogue(6, start, end, circle(162, bullet_ypos + 12, 17, accent, "00")))
        lines.append(dialogue(7, start, end, text(str(bullet_index + 1), 154, bullet_ypos - 2, 23, "0x111827", "00", 7, True)))
        lines.append(dialogue(7, start, end, bullet_text))
        bullet_ypos += box_height + 12

    board_xpos = 990
    board_ypos = 178
    lines.append(dialogue(3, start, end, rectangle(board_xpos, board_ypos, 790, 615, "0x000000", "76")))
    lines.append(dialogue(4, start, end, rectangle(board_xpos + 18, board_ypos + 18, 754, 579, "0x111827", "00")))
    lines.append(dialogue(5, start, end, rectangle(board_xpos + 18, board_ypos + 18, 754, 64, accent, "10")))
    lines.append(dialogue(6, start, end, text("TBD NOTICE BOARD", board_xpos + 42, board_ypos + 35, 28, "0x111827", "00", 7, True)))
    board_line_ypos = board_ypos + 118
    for board_index, board_line in enumerate(scene.board_lines):
        is_header = board_index == 0
        board_size = 35 if is_header else 31
        board_color = accent if is_header else "0xffffff"
        board_text, board_height = wrapped_text(board_line, board_xpos + 58, board_line_ypos, board_size, board_color, 36, "00" if is_header else "24", is_header)
        lines.append(dialogue(6, start, end, board_text))
        board_line_ypos += board_height + 14

    lines.append(dialogue(6, start, end, text("Bubbles overview cartoon | original TBD park-office vibe", 118, 1002, 25, "0xffffff", "68", 7)))
    lines.append(dialogue(6, start, end, text(f"scene {index + 1} plays {duration:.1f}s", 1498, 1002, 25, "0xffffff", "74", 7)))


def build_ass(timed_scenes: tuple[TimedScene, ...]) -> str:
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
    total = len(timed_scenes)
    for index, timed_scene in enumerate(timed_scenes):
        add_cartoon_scene(lines, timed_scene, index, total)
    return "\n".join(lines) + "\n"


def probe_duration(ffmpeg_bin: Path, media_path: Path) -> float:
    result = subprocess.run(
        [str(ffmpeg_bin), "-hide_banner", "-i", str(media_path)],
        check=False,
        capture_output=True,
        text=True,
    )
    combined = f"{result.stdout}\n{result.stderr}"
    match = re.search(r"Duration: (\d+):(\d+):(\d+\.\d+)", combined)
    if not match:
        raise RuntimeError(f"Could not determine duration for {media_path}")
    hours = int(match.group(1))
    minutes = int(match.group(2))
    seconds = float(match.group(3))
    return hours * 3600 + minutes * 60 + seconds


async def synthesize_scene_audio(scene: Scene, output_path: Path, voice: str) -> None:
    try:
        import edge_tts
    except ImportError as exc:
        raise SystemExit("edge-tts is required. Run with PYTHONPATH=/tmp/bubbles-tts-tools or install edge-tts.") from exc
    communicate = edge_tts.Communicate(scene.narration, voice=voice, rate=scene.voice_rate, volume=VOICE_VOLUME)
    await communicate.save(str(output_path))


async def synthesize_all(ffmpeg_bin: Path, temp_dir: Path, voice: str) -> tuple[tuple[Path, ...], tuple[TimedScene, ...]]:
    audio_paths: list[Path] = []
    timed_scenes: list[TimedScene] = []
    cursor = 0.0
    for index, scene in enumerate(SCENES):
        audio_path = temp_dir / f"scene-{index + 1:02d}.mp3"
        print(f"Synthesizing scene {index + 1}/{len(SCENES)}: {scene.title}")
        await synthesize_scene_audio(scene, audio_path, voice)
        duration = probe_duration(ffmpeg_bin, audio_path) + SCENE_PAD_SECONDS
        timed_scenes.append(TimedScene(scene=scene, start=cursor, end=cursor + duration))
        audio_paths.append(audio_path)
        cursor += duration
    return tuple(audio_paths), tuple(timed_scenes)


def pad_scene_audio(ffmpeg_bin: Path, source_path: Path, output_path: Path, duration: float) -> None:
    subprocess.run(
        [
            str(ffmpeg_bin),
            "-y",
            "-i",
            str(source_path),
            "-af",
            f"apad,atrim=0:{duration:.3f},aresample={AUDIO_SAMPLE_RATE},aformat=channel_layouts=stereo",
            "-c:a",
            "pcm_s16le",
            str(output_path),
        ],
        check=True,
    )


def concat_audio_wav(ffmpeg_bin: Path, wav_paths: tuple[Path, ...], concat_list_path: Path, output_path: Path) -> None:
    concat_lines = [f"file '{wav_path.as_posix()}'" for wav_path in wav_paths]
    concat_list_path.write_text("\n".join(concat_lines) + "\n", encoding="utf-8")
    subprocess.run(
        [
            str(ffmpeg_bin),
            "-y",
            "-f",
            "concat",
            "-safe",
            "0",
            "-i",
            str(concat_list_path),
            "-c",
            "copy",
            str(output_path),
        ],
        check=True,
    )


def encode_audio_m4a(ffmpeg_bin: Path, wav_path: Path, output_path: Path) -> None:
    subprocess.run(
        [
            str(ffmpeg_bin),
            "-y",
            "-i",
            str(wav_path),
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
            str(output_path),
        ],
        check=True,
    )


def render_video(ffmpeg_bin: Path, ass_path: Path, audio_path: Path, output_path: Path, duration: float) -> None:
    subprocess.run(
        [
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
            "2",
            "-movflags",
            "+faststart",
            str(output_path),
        ],
        check=True,
    )


def sentence_chunks(value: str) -> list[str]:
    chunks = [chunk.strip() for chunk in re.split(r"(?<=[.!?])\s+", value) if chunk.strip()]
    return chunks or [value]


def write_transcript(path: Path, timed_scenes: tuple[TimedScene, ...]) -> None:
    lines = ["# Bubbles TBD Cartoon Overview Transcript", ""]
    for index, timed_scene in enumerate(timed_scenes, start=1):
        scene = timed_scene.scene
        lines.extend(
            [
                f"## {index}. {scene.title}",
                f"Time: {youtube_time(timed_scene.start)} - {youtube_time(timed_scene.end)}",
                "",
                scene.narration,
                "",
            ]
        )
    path.write_text("\n".join(lines), encoding="utf-8")


def cue_entries(timed_scenes: tuple[TimedScene, ...]) -> list[tuple[float, float, str]]:
    entries: list[tuple[float, float, str]] = []
    for timed_scene in timed_scenes:
        chunks = sentence_chunks(timed_scene.scene.narration)
        scene_duration = timed_scene.end - timed_scene.start
        chunk_duration = scene_duration / len(chunks)
        for chunk_index, chunk in enumerate(chunks):
            cue_start = timed_scene.start + chunk_index * chunk_duration
            cue_end = min(timed_scene.end, cue_start + chunk_duration)
            entries.append((cue_start, cue_end, chunk))
    return entries


def write_srt(path: Path, cues: list[tuple[float, float, str]]) -> None:
    lines: list[str] = []
    for index, (cue_start, cue_end, cue_text) in enumerate(cues, start=1):
        lines.extend([str(index), f"{srt_time(cue_start)} --> {srt_time(cue_end)}", cue_text, ""])
    path.write_text("\n".join(lines), encoding="utf-8")


def write_vtt(path: Path, cues: list[tuple[float, float, str]]) -> None:
    lines = ["WEBVTT", ""]
    for cue_start, cue_end, cue_text in cues:
        lines.extend([f"{vtt_time(cue_start)} --> {vtt_time(cue_end)}", cue_text, ""])
    path.write_text("\n".join(lines), encoding="utf-8")


def write_chapters(path: Path, timed_scenes: tuple[TimedScene, ...]) -> None:
    lines = [f"{youtube_time(timed_scene.start)} {timed_scene.scene.title}" for timed_scene in timed_scenes]
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ffmpeg-bin", required=True, type=Path, help="Path to an ffmpeg executable")
    parser.add_argument("--output", required=True, type=Path, help="Output MP4 path")
    parser.add_argument("--audio-output", required=True, type=Path, help="Output M4A voiceover path")
    parser.add_argument("--transcript-output", required=True, type=Path, help="Output Markdown transcript path")
    parser.add_argument("--voice", default=VOICE, help="Edge TTS voice name")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    require_file(args.ffmpeg_bin, "ffmpeg binary")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.audio_output.parent.mkdir(parents=True, exist_ok=True)
    args.transcript_output.parent.mkdir(parents=True, exist_ok=True)

    base_path = args.output.with_suffix("")
    captions_srt = base_path.with_name(f"{base_path.name}-captions-en.srt")
    captions_vtt = base_path.with_name(f"{base_path.name}-captions-en.vtt")
    chapters_path = base_path.with_name(f"{base_path.name}-chapters-en.txt")

    with tempfile.TemporaryDirectory(prefix="bubbles-tbd-cartoon-") as temp_dir_name:
        temp_dir = Path(temp_dir_name)
        audio_paths, timed_scenes = asyncio.run(synthesize_all(args.ffmpeg_bin, temp_dir, args.voice))

        wav_paths: list[Path] = []
        for audio_path, timed_scene in zip(audio_paths, timed_scenes, strict=True):
            wav_path = audio_path.with_suffix(".wav")
            pad_scene_audio(args.ffmpeg_bin, audio_path, wav_path, timed_scene.end - timed_scene.start)
            wav_paths.append(wav_path)

        concat_wav = temp_dir / "voiceover-concat.wav"
        concat_audio_wav(args.ffmpeg_bin, tuple(wav_paths), temp_dir / "concat.txt", concat_wav)
        encode_audio_m4a(args.ffmpeg_bin, concat_wav, args.audio_output)

        ass_path = temp_dir / "bubbles-tbd-cartoon.ass"
        ass_path.write_text(build_ass(timed_scenes), encoding="utf-8")
        total_duration = timed_scenes[-1].end
        render_video(args.ffmpeg_bin, ass_path, args.audio_output, args.output, total_duration)

    write_transcript(args.transcript_output, timed_scenes)
    cues = cue_entries(timed_scenes)
    write_srt(captions_srt, cues)
    write_vtt(captions_vtt, cues)
    write_chapters(chapters_path, timed_scenes)
    print(f"Rendered {args.output} ({total_duration:.2f} seconds)")
    print(f"Wrote {args.audio_output}")
    print(f"Wrote {args.transcript_output}")
    print(f"Wrote {captions_srt}")
    print(f"Wrote {captions_vtt}")
    print(f"Wrote {chapters_path}")


if __name__ == "__main__":
    main()
