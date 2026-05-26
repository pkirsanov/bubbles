#!/usr/bin/env python3
"""Render a short original TBD-style Bubbles cartoon overview MP4."""

from __future__ import annotations

import argparse
import math
import subprocess
import struct
import tempfile
import wave
from dataclasses import dataclass
from pathlib import Path

WIDTH = 1920
HEIGHT = 1080
FPS = 30
DURATION_SECONDS = 42
FONT = "DejaVu Sans"
MONO_FONT = "DejaVu Sans Mono"
AUDIO_SAMPLE_RATE = 48000


@dataclass(frozen=True)
class Slide:
    start: int
    end: int
    eyebrow: str
    title: str
    subtitle: str
    board: tuple[str, ...]
    bg: str
    accent: str
    mood: str


SLIDES: tuple[Slide, ...] = (
    Slide(
        0,
        6,
        "TBD HQ",
        "Bubbles: Tiny Bubble Department",
        "A tiny dispatch office for serious AI coding work.",
        ("Idea in", "specialists route it", "gates ask for proof", "done means done"),
        "0x101722",
        "0x39d0c8",
        "ready",
    ),
    Slide(
        6,
        12,
        "BEFORE",
        "The Vibes Truck Is On Fire",
        "Big AI diff. Tiny proof. Everybody starts squinting.",
        ("mystery endpoint", "stale docs", "test says yup", "repo says uh oh"),
        "0x251414",
        "0xff7b72",
        "panic",
    ),
    Slide(
        12,
        18,
        "DISPATCH",
        "Bubbles Sends Specialists",
        "One mega-agent does not need twelve hats and a whistle.",
        ("analyst -> truth", "design -> shape", "plan -> slices", "validate -> receipts"),
        "0x17251f",
        "0x3fb950",
        "boss",
    ),
    Slide(
        18,
        24,
        "WORKFLOW",
        "Request Becomes A Work Trail",
        "Specs, scopes, tests, reports, and state stay connected.",
        ("/bubbles.workflow", "pick owners", "run phases", "route rework"),
        "0x102033",
        "0x58a6ff",
        "moving",
    ),
    Slide(
        24,
        30,
        "GATES",
        "Tiny, Strict, Correct",
        "A checked box without output is just confetti in a vest.",
        ("show output", "prove route exists", "prove tests matter", "then celebrate"),
        "0x2c2011",
        "0xd29922",
        "strict",
    ),
    Slide(
        30,
        36,
        "CAPABILITY",
        "Build The Shed First",
        "Capability first. Provider second. That's the way she goes, boys.",
        ("foundation", "ntfy overlay", "email overlay", "no welded wrench"),
        "0x1f2430",
        "0xf2c14e",
        "strict",
    ),
    Slide(
        36,
        42,
        "PAYOFF",
        "Less Chaos, More Receipts",
        "Developers, managers, and leadership all get something inspectable.",
        ("devs: less redo", "managers: status", "leaders: control", "users: fewer boom-clicks"),
        "0x151515",
        "0xffffff",
        "party",
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
    if len(cleaned) != 6:
        raise ValueError(f"Invalid color: {value}")
    return f"{cleaned[4:6]}{cleaned[2:4]}{cleaned[0:2]}".upper()


def color_tag(value: str, alpha: str = "00") -> str:
    return f"\\c&H{hex_to_ass_bgr(value)}&\\alpha&H{alpha}&"


def clean(value: str) -> str:
    return value.replace("{", "(").replace("}", ")")


def dialogue(layer: int, start: float, end: float, body: str) -> str:
    return f"Dialogue: {layer},{ass_time(start)},{ass_time(end)},Default,,0,0,0,,{body}"


def shape(body: str, xpos: int, ypos: int, color: str, alpha: str = "00") -> str:
    return f"{{\\an7\\pos({xpos},{ypos})\\p1\\bord0\\shad0{color_tag(color, alpha)}}}{body}{{\\p0}}"


def rectangle(xpos: int, ypos: int, width: int, height: int, color: str, alpha: str = "00") -> str:
    return shape(f"m 0 0 l {width} 0 l {width} {height} l 0 {height}", xpos, ypos, color, alpha)


def triangle(xpos: int, ypos: int, width: int, height: int, color: str, alpha: str = "00") -> str:
    return shape(f"m 0 {height} l {width // 2} 0 l {width} {height}", xpos, ypos, color, alpha)


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


def text(value: str, xpos: int, ypos: int, size: int, color: str, alpha: str = "00", align: int = 7, bold: bool = False, font: str = FONT) -> str:
    weight = "\\b1" if bold else "\\b0"
    return f"{{\\an{align}\\pos({xpos},{ypos})\\fn{font}\\fs{size}{weight}\\bord0\\shad0{color_tag(color, alpha)}}}{clean(value)}"


def add_person(lines: list[str], slide: Slide, xpos: int, ypos: int, color: str, label: str, hat: bool, mouth: str) -> None:
    start = slide.start
    end = slide.end
    lines.append(dialogue(6, start, end, circle(xpos, ypos, 52, "0xf7fbff")))
    lines.append(dialogue(7, start, end, circle(xpos, ypos, 52, color, "A6")))
    lines.append(dialogue(8, start, end, circle(xpos - 18, ypos - 8, 6, "0x111827")))
    lines.append(dialogue(8, start, end, circle(xpos + 18, ypos - 8, 6, "0x111827")))
    if mouth == "smile":
        lines.append(dialogue(8, start, end, text("_", xpos - 17, ypos + 4, 46, "0x111827", "00", 7, True, MONO_FONT)))
    elif mouth == "panic":
        lines.append(dialogue(8, start, end, text("o", xpos - 10, ypos + 5, 32, "0x111827", "00", 7, True, MONO_FONT)))
    else:
        lines.append(dialogue(8, start, end, rectangle(xpos - 20, ypos + 24, 40, 6, "0x111827", "18")))
    if hat:
        lines.append(dialogue(9, start, end, rectangle(xpos - 38, ypos - 83, 76, 20, slide.accent)))
        lines.append(dialogue(9, start, end, rectangle(xpos - 22, ypos - 110, 44, 36, slide.accent)))
    lines.append(dialogue(9, start, end, text(label, xpos, ypos + 72, 21, "0xffffff", "30", 5, True)))


def add_office(lines: list[str], slide: Slide) -> None:
    start = slide.start
    end = slide.end
    x = 118
    y = 735
    lines.append(dialogue(3, start, end, rectangle(x + 20, y + 108, 598, 28, "0x000000", "AA")))
    lines.append(dialogue(4, start, end, rectangle(x + 50, y, 500, 108, "0xf4d6a0")))
    lines.append(dialogue(4, start, end, rectangle(x + 68, y + 16, 464, 78, "0x1f2937", "B2")))
    lines.append(dialogue(5, start, end, triangle(x + 8, y - 62, 590, 66, slide.accent)))
    lines.append(dialogue(6, start, end, text("TBD", x + 300, y + 14, 34, "0xffffff", "00", 5, True)))
    lines.append(dialogue(6, start, end, rectangle(x + 170, y + 48, 120, 60, "0x101722")))
    lines.append(dialogue(6, start, end, rectangle(x + 338, y + 44, 128, 64, "0x101722")))
    add_person(lines, slide, x + 150, y - 32, slide.accent, "dispatcher", slide.mood in {"ready", "boss", "strict"}, "panic" if slide.mood == "panic" else "smile")
    add_person(lines, slide, x + 300, y - 24, "0x79c0ff", "agent", False, "flat")
    add_person(lines, slide, x + 450, y - 18, "0xffd8aa", "gate", True, "flat")


def add_board(lines: list[str], slide: Slide) -> None:
    start = slide.start
    end = slide.end
    x = 1040
    y = 210
    lines.append(dialogue(3, start, end, rectangle(x, y, 720, 530, "0x000000", "78")))
    lines.append(dialogue(4, start, end, rectangle(x + 16, y + 16, 688, 498, "0x111827")))
    lines.append(dialogue(5, start, end, rectangle(x + 16, y + 16, 688, 60, slide.accent, "0C")))
    lines.append(dialogue(6, start, end, text("TBD NOTICE BOARD", x + 40, y + 32, 26, "0x111827", "00", 7, True)))
    lines.append(dialogue(6, start, end, text("PARK RULES:", x + 52, y + 120, 33, slide.accent, "00", 7, True)))
    for index, line in enumerate(slide.board):
        lines.append(dialogue(6, start, end, text(line, x + 74, y + 180 + index * 62, 31, "0xffffff", "22", 7, False)))


def add_slide(lines: list[str], slide: Slide, index: int, total: int) -> None:
    start = slide.start
    end = slide.end
    lines.append(dialogue(0, start, end, rectangle(0, 0, WIDTH, HEIGHT, slide.bg)))
    lines.append(dialogue(1, start, end, rectangle(0, 0, WIDTH, HEIGHT, "0x000000", "D4")))
    lines.append(dialogue(1, start, end, rectangle(0, 0, 42, HEIGHT, slide.accent, "08")))
    lines.append(dialogue(1, start, end, rectangle(0, HEIGHT - 128, WIDTH, 128, "0x000000", "82")))
    lines.append(dialogue(1, start, end, rectangle(0, HEIGHT - 128, int(WIDTH * (index + 1) / total), 10, slide.accent)))
    for grid_x in range(220, WIDTH, 220):
        lines.append(dialogue(1, start, end, rectangle(grid_x, 0, 1, HEIGHT, "0xffffff", "EE")))
    for grid_y in range(180, HEIGHT, 180):
        lines.append(dialogue(1, start, end, rectangle(0, grid_y, WIDTH, 1, "0xffffff", "F0")))
    for bubble_index in range(9):
        xpos = 1010 + ((bubble_index * 89 + index * 53) % 760)
        ypos = 130 + ((bubble_index * 113 + index * 41) % 760)
        radius = 18 + ((bubble_index + index) % 4) * 9
        lines.append(dialogue(2, start, end, circle(xpos, ypos, radius, slide.accent, "A8")))

    lines.append(dialogue(6, start, end, rectangle(110, 80, 280, 50, slide.accent)))
    lines.append(dialogue(7, start, end, text(slide.eyebrow, 132, 94, 27, "0x111827", "00", 7, True)))
    lines.append(dialogue(7, start, end, text(f"{index + 1:02d}/{total:02d}", 1710, 92, 34, slide.accent, "00", 7, True)))
    lines.append(dialogue(7, start, end, text(slide.title.replace(": ", ":\\N"), 112, 170, 58, "0xffffff", "00", 7, True)))
    lines.append(dialogue(7, start, end, text(slide.subtitle, 116, 340, 32, "0xffffff", "32")))

    chips = ("spec", "design", "scope", "test", "audit")
    for chip_index, chip in enumerate(chips):
        chip_x = 126 + chip_index * 145
        chip_y = 438 + (chip_index % 2) * 70
        lines.append(dialogue(5, start, end, rectangle(chip_x, chip_y, 118, 42, "0x000000", "9A")))
        lines.append(dialogue(6, start, end, rectangle(chip_x, chip_y, 8, 42, slide.accent)))
        lines.append(dialogue(7, start, end, text(chip, chip_x + 21, chip_y + 8, 23, "0xffffff", "22", 7, True, MONO_FONT)))

    add_office(lines, slide)
    add_board(lines, slide)
    lines.append(dialogue(7, start, end, text("Bubbles overview cartoon | original TBD park-office vibe", 118, 1005, 25, "0xffffff", "68", 7)))


def build_ass() -> str:
    lines = [
        "[Script Info]",
        "ScriptType: v4.00+",
        "ScaledBorderAndShadow: yes",
        f"PlayResX: {WIDTH}",
        f"PlayResY: {HEIGHT}",
        "WrapStyle: 0",
        "",
        "[V4+ Styles]",
        "Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding",
        f"Style: Default,{FONT},36,&H00FFFFFF,&H00FFFFFF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,0,0,7,0,0,0,1",
        "",
        "[Events]",
        "Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text",
    ]
    for index, slide in enumerate(SLIDES):
        add_slide(lines, slide, index, len(SLIDES))
    return "\n".join(lines) + "\n"


def envelope(position: float, duration: float) -> float:
    if position < 0.0 or position >= duration:
        return 0.0
    attack = 0.015
    if position < attack:
        return position / attack
    return math.exp(-7.5 * (position - attack))


def write_cartoon_audio(path: Path) -> None:
    notes = (261.63, 329.63, 392.0, 493.88, 523.25, 392.0)
    transition_notes = (196.0, 246.94, 293.66, 349.23, 392.0, 523.25)
    frame_count = DURATION_SECONDS * AUDIO_SAMPLE_RATE
    with wave.open(str(path), "wb") as wav:
        wav.setnchannels(2)
        wav.setsampwidth(2)
        wav.setframerate(AUDIO_SAMPLE_RATE)
        for frame in range(frame_count):
            current_time = frame / AUDIO_SAMPLE_RATE
            note_index = int(current_time * 2.0) % len(notes)
            beat_position = current_time % 0.5
            pluck = 0.14 * envelope(beat_position, 0.34) * math.sin(2.0 * math.pi * notes[note_index] * current_time)

            slide_position = current_time % 6.0
            transition_index = int(current_time / 6.0) % len(transition_notes)
            bell = 0.18 * envelope(slide_position, 0.45) * math.sin(2.0 * math.pi * transition_notes[transition_index] * current_time)
            bell += 0.08 * envelope(slide_position - 0.09, 0.35) * math.sin(2.0 * math.pi * transition_notes[transition_index] * 1.5 * current_time)

            office_hum = 0.012 * math.sin(2.0 * math.pi * 98.0 * current_time)
            value = max(-0.95, min(0.95, pluck + bell + office_hum))
            sample = int(value * 32767)
            wav.writeframes(struct.pack("<hh", sample, sample))


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ffmpeg-bin", required=True, type=Path, help="Path to ffmpeg")
    parser.add_argument("--output", required=True, type=Path, help="Output MP4 path")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    require_file(args.ffmpeg_bin, "ffmpeg binary")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="bubbles-tbd-short-") as temp_dir_name:
        ass_path = Path(temp_dir_name) / "bubbles-tbd-short.ass"
        audio_path = Path(temp_dir_name) / "bubbles-tbd-short-audio.wav"
        ass_path.write_text(build_ass(), encoding="utf-8")
        write_cartoon_audio(audio_path)
        command = [
            str(args.ffmpeg_bin),
            "-y",
            "-f",
            "lavfi",
            "-i",
            f"color=c=0x000000:s={WIDTH}x{HEIGHT}:r={FPS}:d={DURATION_SECONDS}",
            "-i",
            str(audio_path),
            "-vf",
            f"ass={ass_path}",
            "-map",
            "0:v",
            "-map",
            "1:a",
            "-t",
            str(DURATION_SECONDS),
            "-c:v",
            "libx264",
            "-preset",
            "veryfast",
            "-crf",
            "16",
            "-pix_fmt",
            "yuv420p",
            "-c:a",
            "aac",
            "-b:a",
            "128k",
            "-movflags",
            "+faststart",
            str(args.output),
        ]
        subprocess.run(command, check=True)
    print(f"Rendered {args.output} ({DURATION_SECONDS} seconds)")


if __name__ == "__main__":
    main()
