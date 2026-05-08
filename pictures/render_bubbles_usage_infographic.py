#!/usr/bin/env python3
"""Render a short Bubbles usage infographic MP4 with ffmpeg and ASS overlays."""

from __future__ import annotations

import argparse
import subprocess
import tempfile
from pathlib import Path

WIDTH = 1920
HEIGHT = 1080
FPS = 30
DURATION_SECONDS = 32
FONT_FAMILY = "DejaVu Sans"

SLIDES = [
    {
        "start": 0,
        "end": 4,
        "bg": "0x111827",
        "accent": "0x58a6ff",
        "kicker": "PARK-LOT MODE",
        "title": "BUBBLES",
        "subtitle": "AI agents with a clipboard, receipts, and zero patience for fake work.",
        "bullets": [
            "Say what you want. Bubbles picks the crew.",
            "Specs, scopes, tests, audit: everybody has a job.",
            "Not magic. Organized nonsense with evidence.",
        ],
    },
    {
        "start": 4,
        "end": 8,
        "bg": "0x221b2f",
        "accent": "0xbc8cff",
        "kicker": "THE PROBLEM",
        "title": "Before Bubbles",
        "subtitle": "A very normal software picnic: twelve tabs, four plans, one brave guess.",
        "bullets": [
            "Mystery requirements wander around in flip-flops.",
            "Tests become bedtime stories if nobody runs them.",
            "Someone says 'done' and the build coughs politely.",
        ],
    },
    {
        "start": 8,
        "end": 12,
        "bg": "0x10231f",
        "accent": "0x3fb950",
        "kicker": "HOW IT WORKS",
        "title": "One Sentence In. A Whole Crew Out.",
        "subtitle": "/bubbles.workflow fix the calendar bug",
        "bullets": [
            "Analyst figures out the business mess.",
            "Design and plan turn it into buildable scopes.",
            "Implement, test, validate, audit: no freelancing, bud.",
        ],
    },
    {
        "start": 12,
        "end": 16,
        "bg": "0x2c2011",
        "accent": "0xd29922",
        "kicker": "SCENARIOS",
        "title": "When To Use It",
        "subtitle": "If your repo is making noises, bring the tiny supervisor.",
        "bullets": [
            "Build a feature from vague idea to verified delivery.",
            "Fix a bug with reproduction before and after.",
            "Harden a release until the shortcuts get nervous.",
        ],
    },
    {
        "start": 16,
        "end": 20,
        "bg": "0x121f33",
        "accent": "0x79c0ff",
        "kicker": "THE CREW",
        "title": "37 Agents. No Loitering.",
        "subtitle": "Each specialist owns a lane, so artifacts stop arm-wrestling each other.",
        "bullets": [
            "Analyst owns business truth.",
            "UX, design, plan, implement, test, audit own their turf.",
            "Workflow keeps the parade moving without losing the receipts.",
        ],
    },
    {
        "start": 20,
        "end": 24,
        "bg": "0x241616",
        "accent": "0xf85149",
        "kicker": "QUALITY GATES",
        "title": "65 Ways To Say: Prove It.",
        "subtitle": "Evidence or it did not happen. The gate is not impressed by vibes.",
        "bullets": [
            "No fabricated test output. No TODO confetti.",
            "Raw execution evidence goes in the report.",
            "Done means done, not 'close enough, park it by the shed.'",
        ],
    },
    {
        "start": 24,
        "end": 28,
        "bg": "0x102a2a",
        "accent": "0x39d0c8",
        "kicker": "BENEFITS",
        "title": "Why Teams Like It",
        "subtitle": "Less chaos karaoke. More repeatable shipping with a paper trail.",
        "bullets": [
            "Traceable work from request to verification.",
            "Fewer orphan docs, surprise endpoints, and haunted scopes.",
            "A sane loop for bugs, features, audits, and sprints.",
        ],
    },
    {
        "start": 28,
        "end": 32,
        "bg": "0x151515",
        "accent": "0xffffff",
        "kicker": "TRY THIS",
        "title": "/bubbles.workflow continue",
        "subtitle": "Tell it the goal. Let the crew do the accountable thing.",
        "bullets": [
            "Bubbles: spec-driven delivery with jokes in the glovebox.",
            "It ain't rocket appliances. It is receipts, bud.",
            "Zero fabrication. Maximum clipboard energy.",
        ],
    },
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


def dialogue(layer: int, start: int, end: int, body: str) -> str:
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
) -> str:
    weight = "\\b1" if bold else "\\b0"
    return (
        f"{{\\an{align}\\pos({x},{y})\\fn{FONT_FAMILY}\\fs{size}{weight}\\bord0\\shad0"
        f"{color_tag(color, alpha)}}}{ass_text(value)}"
    )


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
        "Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, "
        "Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, "
        "Alignment, MarginL, MarginR, MarginV, Encoding",
        f"Style: Default,{FONT_FAMILY},36,&H00FFFFFF,&H00FFFFFF,&H00000000,&H00000000,"
        "0,0,0,0,100,100,0,0,1,0,0,7,0,0,0,1",
        "",
        "[Events]",
        "Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text",
    ]

    for index, slide in enumerate(SLIDES):
        start = slide["start"]
        end = slide["end"]
        accent = slide["accent"]

        lines.append(dialogue(0, start, end, rect(0, 0, WIDTH, HEIGHT, slide["bg"])))
        lines.append(dialogue(1, start, end, rect(0, 0, 34, HEIGHT, accent)))
        lines.append(dialogue(1, start, end, rect(116, 88, 232, 44, accent, "08")))
        lines.append(dialogue(1, start, end, rect(116, 225, 1688, 4, accent, "15")))
        lines.append(dialogue(1, start, end, rect(1580, 88, 224, 74, "0x000000", "80")))

        for grid_x in range(240, WIDTH, 240):
            lines.append(dialogue(1, start, end, rect(grid_x, 0, 1, HEIGHT, "0xffffff", "E8")))
        for grid_y in range(240, HEIGHT, 240):
            lines.append(dialogue(1, start, end, rect(0, grid_y, WIDTH, 1, "0xffffff", "E8")))

        for bubble_index in range(6):
            x = 1340 + ((bubble_index * 91 + index * 37) % 410)
            y = 300 + ((bubble_index * 137 + index * 53) % 560)
            size = 58 + ((bubble_index + index) % 4) * 20
            lines.append(dialogue(2, start, end, text("o", x, y, size, accent, "9D", 5, True)))

        lines.append(dialogue(3, start, end, text(slide["kicker"], 135, 99, 26, "0x111827", "00", 7, True)))
        lines.append(dialogue(3, start, end, text(f"{index + 1:02d}/08", 1615, 108, 36, accent, "00", 7, True)))
        lines.append(dialogue(3, start, end, text(slide["title"], 116, 260, 76, "0xffffff", "00", 7, True)))
        lines.append(dialogue(3, start, end, text(slide["subtitle"], 120, 365, 38, "0xffffff", "22", 7)))

        for bullet_index, bullet in enumerate(slide["bullets"]):
            y = 500 + bullet_index * 126
            lines.append(dialogue(2, start, end, rect(124, y - 22, 1160, 86, "0x000000", "92")))
            lines.append(dialogue(2, start, end, rect(124, y - 22, 10, 86, accent, "08")))
            lines.append(dialogue(3, start, end, text(str(bullet_index + 1), 157, y - 8, 34, accent, "00", 7, True)))
            lines.append(dialogue(3, start, end, text(bullet, 220, y - 4, 34, "0xffffff", "18", 7)))

        footer = "Bubbles usage infographic | original park-office comedy vibe"
        lines.append(dialogue(3, start, end, text(footer, 120, 1008, 25, "0xffffff", "74", 7)))

    return "\n".join(lines) + "\n"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ffmpeg-bin", required=True, type=Path, help="Path to an ffmpeg executable")
    parser.add_argument("--output", required=True, type=Path, help="Output MP4 path")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    require_file(args.ffmpeg_bin, "ffmpeg binary")
    args.output.parent.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory(prefix="bubbles-video-") as temp_dir:
        ass_path = Path(temp_dir) / "bubbles-infographic.ass"
        ass_path.write_text(build_ass(), encoding="utf-8")

        command = [
            str(args.ffmpeg_bin),
            "-y",
            "-f",
            "lavfi",
            "-i",
            f"color=c=0x000000:s={WIDTH}x{HEIGHT}:r={FPS}:d={DURATION_SECONDS}",
            "-f",
            "lavfi",
            "-i",
            "anullsrc=channel_layout=stereo:sample_rate=44100",
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
            "medium",
            "-crf",
            "19",
            "-pix_fmt",
            "yuv420p",
            "-c:a",
            "aac",
            "-b:a",
            "96k",
            "-movflags",
            "+faststart",
            str(args.output),
        ]
        subprocess.run(command, check=True)


if __name__ == "__main__":
    main()
