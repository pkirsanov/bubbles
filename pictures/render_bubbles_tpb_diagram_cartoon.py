#!/usr/bin/env python3
"""Render an animated Bubbles cartoon using the repo's hand-drawn diagram style."""

from __future__ import annotations

import argparse
import math
import subprocess
import struct
import tempfile
import wave
from pathlib import Path

WIDTH = 1920
HEIGHT = 1080
FPS = 30
DURATION_SECONDS = 54
AUDIO_SAMPLE_RATE = 48000
FONT = "Comic Sans MS"
FALLBACK_FONT = "DejaVu Sans"
MONO_FONT = "DejaVu Sans Mono"

PAPER = "0xfdfcf9"
INK = "0x2c3e50"
BLUE = "0x2980b9"
GREEN = "0x27ae60"
ORANGE = "0xd35400"
RED = "0xc0392b"
PURPLE = "0x8e44ad"
YELLOW = "0xf1c40f"
GRAY = "0x7f8c8d"


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


def pos_tag(xpos: float, ypos: float) -> str:
    return f"\\pos({xpos:.0f},{ypos:.0f})"


def move_tag(x1: float, y1: float, x2: float, y2: float) -> str:
    return f"\\move({x1:.0f},{y1:.0f},{x2:.0f},{y2:.0f})"


def shape_path(body: str, transform: str, color: str, alpha: str = "00", align: int = 7, rotate: float = 0.0) -> str:
    rot = f"\\frz{rotate:.1f}" if rotate else ""
    return f"{{\\an{align}{transform}{rot}\\p1\\bord0\\shad0{color_tag(color, alpha)}}}{body}{{\\p0}}"


def rect_path(width: int, height: int, wobble: int = 0) -> str:
    if wobble <= 0:
        return f"m 0 0 l {width} 0 l {width} {height} l 0 {height}"
    return f"m 0 {wobble} l {width - wobble} 0 l {width} {height - wobble} l {wobble} {height}"


def tri_path(width: int, height: int) -> str:
    return f"m 0 {height} l {width // 2} 0 l {width} {height}"


def circle_path(radius: int) -> str:
    diameter = radius * 2
    control = int(radius * 0.55228475)
    return (
        f"m {radius} 0 "
        f"b {radius + control} 0 {diameter} {radius - control} {diameter} {radius} "
        f"b {diameter} {radius + control} {radius + control} {diameter} {radius} {diameter} "
        f"b {radius - control} {diameter} 0 {radius + control} 0 {radius} "
        f"b 0 {radius - control} {radius - control} 0 {radius} 0"
    )


def rect_obj(xpos: int, ypos: int, width: int, height: int, color: str, alpha: str = "00", wobble: int = 0, rotate: float = 0.0) -> str:
    return shape_path(rect_path(width, height, wobble), pos_tag(xpos, ypos), color, alpha, rotate=rotate)


def move_rect(x1: int, y1: int, x2: int, y2: int, width: int, height: int, color: str, alpha: str = "00", wobble: int = 0, rotate: float = 0.0) -> str:
    return shape_path(rect_path(width, height, wobble), move_tag(x1, y1, x2, y2), color, alpha, rotate=rotate)


def circle_obj(xpos: int, ypos: int, radius: int, color: str, alpha: str = "00") -> str:
    return shape_path(circle_path(radius), pos_tag(xpos - radius, ypos - radius), color, alpha)


def move_circle(x1: int, y1: int, x2: int, y2: int, radius: int, color: str, alpha: str = "00") -> str:
    return shape_path(circle_path(radius), move_tag(x1 - radius, y1 - radius, x2 - radius, y2 - radius), color, alpha)


def text_obj(value: str, xpos: int, ypos: int, size: int, color: str, alpha: str = "00", align: int = 7, bold: bool = False, font: str = FONT, rotate: float = 0.0) -> str:
    weight = "\\b1" if bold else "\\b0"
    rot = f"\\frz{rotate:.1f}" if rotate else ""
    return f"{{\\an{align}{pos_tag(xpos, ypos)}{rot}\\fn{font}\\fs{size}{weight}\\bord0\\shad0{color_tag(color, alpha)}}}{clean(value)}"


def move_text(value: str, x1: int, y1: int, x2: int, y2: int, size: int, color: str, alpha: str = "00", align: int = 7, bold: bool = False, font: str = FONT, rotate: float = 0.0) -> str:
    weight = "\\b1" if bold else "\\b0"
    rot = f"\\frz{rotate:.1f}" if rotate else ""
    return f"{{\\an{align}{move_tag(x1, y1, x2, y2)}{rot}\\fn{font}\\fs{size}{weight}\\bord0\\shad0{color_tag(color, alpha)}}}{clean(value)}"


def fade_text(value: str, xpos: int, ypos: int, size: int, color: str, align: int = 5, bold: bool = True) -> str:
    return f"{{\\an{align}{pos_tag(xpos, ypos)}\\fn{FONT}\\fs{size}\\b{1 if bold else 0}\\fad(180,220)\\bord0\\shad0{color_tag(color)}}}{clean(value)}"


def add_static_background(lines: list[str]) -> None:
    start, end = 0, DURATION_SECONDS
    lines.append(dialogue(0, start, end, rect_obj(0, 0, WIDTH, HEIGHT, PAPER)))
    lines.append(dialogue(1, start, end, rect_obj(34, 34, 1852, 1012, INK, "00", 12)))
    lines.append(dialogue(2, start, end, rect_obj(46, 46, 1828, 988, PAPER, "00", 10)))
    lines.append(dialogue(3, start, end, rect_obj(84, 86, 1752, 910, BLUE, "E2", 4)))
    for grid_x in range(180, WIDTH - 120, 180):
        lines.append(dialogue(2, start, end, rect_obj(grid_x, 95, 2, 882, INK, "F0")))
    for grid_y in range(185, HEIGHT - 100, 150):
        lines.append(dialogue(2, start, end, rect_obj(96, grid_y, 1728, 2, INK, "F0")))

    lines.append(dialogue(4, start, end, shape_path("m 0 22 l 840 0 l 888 72 l 820 100 l 20 92", pos_tag(506, 70), INK, "00")))
    lines.append(dialogue(5, start, end, shape_path("m 0 22 l 820 0 l 860 68 l 798 92 l 18 86", pos_tag(522, 82), "0xffffff", "00")))
    lines.append(dialogue(6, start, end, text_obj("BUBBLES DISPATCH CARTOON", 960, 111, 51, INK, "00", 5, True)))
    lines.append(dialogue(6, start, end, text_obj("park-office diagram style: specialists move work through gates", 960, 160, 25, GRAY, "00", 5)))

    labels = ((170, "CHAOS LOT", RED), (500, "DISPATCH", BLUE), (820, "SPEC SHACK", PURPLE), (1135, "BUILD LANE", GREEN), (1440, "PERMIT GATES", ORANGE), (1690, "DONE-DONE", INK))
    for xpos, label, color in labels:
        lines.append(dialogue(5, start, end, rect_obj(xpos - 95, 238, 190, 52, color, "00", 5)))
        lines.append(dialogue(6, start, end, text_obj(label, xpos, 252, 25, PAPER, "00", 5, True)))

    # Office shack.
    lines.append(dialogue(4, start, end, rect_obj(390, 690, 320, 116, "0xf7d99b", "00", 7)))
    lines.append(dialogue(4, start, end, shape_path(tri_path(385, 72), pos_tag(355, 625), RED, "00")))
    lines.append(dialogue(5, start, end, rect_obj(432, 718, 92, 88, "0x21313f", "00", 4)))
    lines.append(dialogue(5, start, end, rect_obj(562, 718, 104, 58, "0x21313f", "00", 4)))
    lines.append(dialogue(6, start, end, text_obj("TBD HQ", 552, 660, 36, PAPER, "00", 5, True)))

    # Permit board.
    lines.append(dialogue(4, start, end, rect_obj(1290, 340, 430, 480, "0x7d6608", "00", 7)))
    lines.append(dialogue(5, start, end, rect_obj(1307, 358, 396, 446, "0xfef5e7", "00", 7)))
    lines.append(dialogue(6, start, end, text_obj("PERMIT BOARD", 1505, 382, 31, "0x7d6608", "00", 5, True)))
    for index, label in enumerate(("spec.md", "scopes.md", "report.md", "raw output")):
        ypos = 438 + index * 74
        lines.append(dialogue(6, start, end, rect_obj(1340, ypos, 320, 44, "0xffffff", "00", 5)))
        lines.append(dialogue(7, start, end, circle_obj(1354, ypos + 10, 11, RED)))
        lines.append(dialogue(7, start, end, text_obj(label, 1382, ypos + 8, 24, INK, "00", 7, True)))

    # Manager booth.
    lines.append(dialogue(4, start, end, rect_obj(1610, 690, 220, 118, "0xd6eaf8", "00", 7)))
    lines.append(dialogue(5, start, end, shape_path(tri_path(260, 54), pos_tag(1590, 638), BLUE, "00")))
    lines.append(dialogue(6, start, end, text_obj("STATUS", 1720, 675, 31, PAPER, "00", 5, True)))

    # Road.
    lines.append(dialogue(3, start, end, rect_obj(90, 842, 1725, 54, "0x34495e", "44", 8)))
    for xpos in range(130, 1760, 160):
        lines.append(dialogue(4, start, end, rect_obj(xpos, 866, 70, 6, PAPER, "32", 2)))


def add_walking_person(lines: list[str], start: float, end: float, x1: int, y1: int, x2: int, y2: int, color: str, label: str, hat_color: str | None = None, layer: int = 30) -> None:
    # All parts move together. Alternating leg/arm cards create actual character action instead of a static mascot.
    lines.append(dialogue(layer, start, end, move_circle(x1, y1 - 78, x2, y2 - 78, 34, "0xfff2d5")))
    lines.append(dialogue(layer + 1, start, end, move_circle(x1 - 11, y1 - 84, x2 - 11, y2 - 84, 4, INK)))
    lines.append(dialogue(layer + 1, start, end, move_circle(x1 + 12, y1 - 84, x2 + 12, y2 - 84, 4, INK)))
    lines.append(dialogue(layer + 1, start, end, move_rect(x1 - 16, y1 - 62, x2 - 16, y2 - 62, 34, 4, INK, "00", 0)))
    lines.append(dialogue(layer, start, end, move_rect(x1 - 30, y1 - 42, x2 - 30, y2 - 42, 60, 68, color, "00", 5)))
    lines.append(dialogue(layer + 1, start, end, move_rect(x1 - 56, y1 - 28, x2 - 56, y2 - 28, 34, 9, color, "00", 2, -17)))
    lines.append(dialogue(layer + 1, start, end, move_rect(x1 + 24, y1 - 26, x2 + 24, y2 - 26, 34, 9, color, "00", 2, 18)))
    lines.append(dialogue(layer, start, end, move_rect(x1 - 27, y1 + 26, x2 - 27, y2 + 26, 18, 47, INK, "00", 2, 12)))
    lines.append(dialogue(layer, start, end, move_rect(x1 + 8, y1 + 26, x2 + 8, y2 + 26, 18, 47, INK, "00", 2, -12)))
    if hat_color:
        lines.append(dialogue(layer + 2, start, end, move_rect(x1 - 38, y1 - 124, x2 - 38, y2 - 124, 76, 18, hat_color, "00", 3)))
        lines.append(dialogue(layer + 2, start, end, move_rect(x1 - 22, y1 - 152, x2 - 22, y2 - 152, 44, 34, hat_color, "00", 3)))
    lines.append(dialogue(layer + 3, start, end, move_text(label, x1, y1 + 83, x2, y2 + 83, 22, INK, "00", 5, True)))


def add_artifact_card(lines: list[str], start: float, end: float, x1: int, y1: int, x2: int, y2: int, label: str, color: str, layer: int = 50) -> None:
    lines.append(dialogue(layer, start, end, move_rect(x1, y1, x2, y2, 148, 68, "0xffffff", "00", 5, -4)))
    lines.append(dialogue(layer + 1, start, end, move_rect(x1, y1, x2, y2, 14, 68, color, "00", 2, -4)))
    lines.append(dialogue(layer + 2, start, end, move_text(label, x1 + 28, y1 + 20, x2 + 28, y2 + 20, 24, INK, "00", 7, True, MONO_FONT, -4)))


def add_static_person(lines: list[str], start: float, end: float, xpos: int, ypos: int, color: str, label: str, hat_color: str | None = None, layer: int = 30) -> None:
    add_walking_person(lines, start, end, xpos, ypos, xpos, ypos, color, label, hat_color, layer)


def add_truck(lines: list[str], start: float, end: float, x1: int, y1: int, x2: int, y2: int, label: str, color: str, smoke: bool) -> None:
    lines.append(dialogue(16, start, end, move_rect(x1, y1, x2, y2, 230, 82, color, "00", 7)))
    lines.append(dialogue(17, start, end, move_rect(x1 + 138, y1 - 48, x2 + 138, y2 - 48, 80, 54, color, "00", 5)))
    lines.append(dialogue(18, start, end, move_circle(x1 + 48, y1 + 90, x2 + 48, y2 + 90, 26, INK)))
    lines.append(dialogue(18, start, end, move_circle(x1 + 178, y1 + 90, x2 + 178, y2 + 90, 26, INK)))
    lines.append(dialogue(19, start, end, move_text(label, x1 + 38, y1 + 22, x2 + 38, y2 + 22, 22, PAPER, "00", 7, True)))
    if smoke:
        for index in range(4):
            offset = index * 22
            lines.append(dialogue(20, start + index * 0.18, end, move_circle(x1 - 22 - offset, y1 - 8 - index * 8, x2 - 110 - offset, y2 - 70 - index * 8, 16 + index * 5, GRAY, "86")))


def add_stamp(lines: list[str], start: float, end: float, x1: int, y1: int, x2: int, y2: int, label: str, color: str) -> None:
    lines.append(dialogue(65, start, end, move_rect(x1, y1, x2, y2, 138, 54, color, "00", 5, -14)))
    lines.append(dialogue(66, start, end, move_text(label, x1 + 68, y1 + 13, x2 + 68, y2 + 13, 28, PAPER, "00", 5, True, MONO_FONT, -14)))


def add_speech(lines: list[str], start: float, end: float, xpos: int, ypos: int, text: str, color: str, layer: int = 80) -> None:
    lines.append(dialogue(layer, start, end, f"{{\\an5{pos_tag(xpos, ypos)}\\fn{FONT}\\fs32\\b1\\fad(120,160)\\bord4\\3c&H{hex_to_ass_bgr(color)}&\\shad0{color_tag(PAPER)}}}{clean(text)}"))


def add_action_sequence(lines: list[str]) -> None:
    # Cast idles at HQ.
    add_static_person(lines, 0, 6.2, 470, 845, BLUE, "dispatcher", BLUE, 30)
    add_static_person(lines, 0.6, 6.2, 610, 855, GREEN, "agent", None, 35)
    add_static_person(lines, 1.2, 6.2, 1452, 845, ORANGE, "gate", ORANGE, 40)
    add_speech(lines, 1.0, 4.7, 960, 515, "Tiny department. Big receipts.", BLUE)

    # Vibes truck rolls in, smoking.
    add_truck(lines, 4.6, 13.0, -260, 755, 128, 755, "VIBES-ONLY", RED, True)
    add_artifact_card(lines, 7.4, 13.0, 240, 680, 468, 650, "help?", RED, 55)
    add_speech(lines, 7.8, 11.6, 315, 570, "It says done, but where is the proof?", RED)

    # Dispatcher walks to the board.
    add_walking_person(lines, 10.6, 18.0, 470, 845, 775, 835, BLUE, "dispatcher", BLUE, 30)
    add_artifact_card(lines, 12.5, 18.3, 560, 610, 817, 540, "spec.md", PURPLE, 56)
    add_artifact_card(lines, 14.0, 19.2, 620, 690, 910, 612, "design", BLUE, 57)
    add_artifact_card(lines, 15.4, 20.0, 670, 760, 1008, 690, "scopes", ORANGE, 58)
    add_speech(lines, 13.2, 17.2, 920, 470, "Route it. Own it. Write it down.", PURPLE)

    # Agent carries artifacts down the lane.
    add_walking_person(lines, 18.0, 30.0, 790, 845, 1205, 845, GREEN, "implement", None, 34)
    add_artifact_card(lines, 18.2, 24.4, 830, 620, 1030, 575, "tests", GREEN, 58)
    add_artifact_card(lines, 21.2, 28.2, 960, 700, 1210, 650, "report", BLUE, 59)
    add_speech(lines, 21.0, 25.6, 1045, 500, "No mystery diff. No magic shrug.", GREEN)

    # Gate inspector stamps the board.
    add_walking_person(lines, 26.0, 35.0, 1240, 850, 1430, 850, ORANGE, "validate", ORANGE, 39)
    add_stamp(lines, 29.2, 31.2, 1425, 725, 1430, 610, "EVIDENCE?", RED)
    add_stamp(lines, 32.2, 34.4, 1435, 725, 1450, 685, "PASS", GREEN)
    add_speech(lines, 29.8, 34.0, 1510, 885, "A checkbox is not a receipt.", ORANGE)

    # Manager gets status, leadership gets confidence.
    add_static_person(lines, 34.0, 44.0, 1730, 852, BLUE, "manager", None, 46)
    add_artifact_card(lines, 35.0, 41.5, 1410, 590, 1630, 590, "state", BLUE, 61)
    add_artifact_card(lines, 36.0, 42.4, 1420, 665, 1640, 655, "evidence", GREEN, 62)
    add_speech(lines, 37.2, 42.5, 1600, 515, "Now status has receipts.", BLUE)

    # Final repaired truck and team lineup.
    add_truck(lines, 42.0, 54.0, 180, 765, 300, 765, "CERTIFIED", GREEN, False)
    add_static_person(lines, 43.0, 54.0, 520, 855, BLUE, "dispatch", BLUE, 30)
    add_static_person(lines, 43.4, 54.0, 700, 855, GREEN, "build", None, 35)
    add_static_person(lines, 43.8, 54.0, 880, 855, PURPLE, "review", None, 40)
    add_static_person(lines, 44.2, 54.0, 1060, 855, ORANGE, "gate", ORANGE, 45)
    lines.append(dialogue(83, 44.0, 54.0, fade_text("DONE-DONE", 960, 445, 82, GREEN, 5, True)))
    lines.append(dialogue(84, 45.0, 54.0, fade_text("specialists move, artifacts move,\\Nproof moves with them", 960, 525, 35, INK, 5, True)))
    for index in range(26):
        x1 = 280 + (index * 57) % 1320
        y1 = 150 + (index * 91) % 240
        x2 = x1 + ((index % 5) - 2) * 44
        y2 = y1 + 560 + (index % 4) * 35
        color = (BLUE, GREEN, ORANGE, PURPLE, YELLOW)[index % 5]
        lines.append(dialogue(75, 44.4 + index * 0.05, 54.0, move_circle(x1, y1, x2, y2, 10 + (index % 3) * 4, color, "26")))


def add_scene_captions(lines: list[str]) -> None:
    captions = (
        (0.4, 5.7, "Bubbles is a tiny dispatch office for serious AI coding work."),
        (6.0, 11.9, "Before: vibes-only work rolls in smoking and suspicious."),
        (12.0, 18.2, "The dispatcher routes the job to the right specialist owners."),
        (18.2, 27.6, "Artifacts travel with the work: specs, scopes, tests, reports."),
        (28.0, 36.0, "Gates inspect proof before anybody claims done."),
        (36.0, 44.2, "Managers get status with receipts, not folklore."),
        (44.3, 53.5, "That is Bubbles: moving work through a visible, validated path."),
    )
    for start, end, caption in captions:
        lines.append(dialogue(90, start, end, f"{{\\an2{pos_tag(960, 1015)}\\fn{FONT}\\fs31\\b1\\fad(120,160)\\bord5\\3c&H{hex_to_ass_bgr(PAPER)}&\\shad0{color_tag(INK)}}}{clean(caption)}"))


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
        f"Style: Default,{FALLBACK_FONT},36,&H00FFFFFF,&H00FFFFFF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,0,0,7,0,0,0,1",
        "",
        "[Events]",
        "Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text",
    ]
    add_static_background(lines)
    add_action_sequence(lines)
    add_scene_captions(lines)
    return "\n".join(lines) + "\n"


def envelope(position: float, duration: float, decay: float = 8.0) -> float:
    if position < 0.0 or position >= duration:
        return 0.0
    attack = 0.012
    if position < attack:
        return position / attack
    return math.exp(-decay * (position - attack))


def write_audio(path: Path) -> None:
    frame_count = DURATION_SECONDS * AUDIO_SAMPLE_RATE
    stamp_times = (29.2, 32.2)
    step_times = tuple(10.8 + idx * 0.42 for idx in range(18)) + tuple(18.4 + idx * 0.36 for idx in range(28)) + tuple(26.2 + idx * 0.38 for idx in range(22))
    with wave.open(str(path), "wb") as wav:
        wav.setnchannels(2)
        wav.setsampwidth(2)
        wav.setframerate(AUDIO_SAMPLE_RATE)
        for frame in range(frame_count):
            current_time = frame / AUDIO_SAMPLE_RATE
            beat_position = current_time % 0.5
            note = (220.0, 246.94, 293.66, 329.63, 392.0, 493.88)[int(current_time * 2.0) % 6]
            pluck = 0.08 * envelope(beat_position, 0.32) * math.sin(2.0 * math.pi * note * current_time)
            hum = 0.012 * math.sin(2.0 * math.pi * 92.0 * current_time)
            step = 0.0
            for step_time in step_times:
                step += 0.055 * envelope(current_time - step_time, 0.08, 28.0) * math.sin(2.0 * math.pi * 130.0 * current_time)
            stamp = 0.0
            for stamp_time in stamp_times:
                stamp += 0.34 * envelope(current_time - stamp_time, 0.2, 18.0) * math.sin(2.0 * math.pi * 76.0 * current_time)
                stamp += 0.12 * envelope(current_time - stamp_time, 0.18, 15.0) * math.sin(2.0 * math.pi * 190.0 * current_time)
            value = max(-0.95, min(0.95, pluck + hum + step + stamp))
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
    with tempfile.TemporaryDirectory(prefix="bubbles-tpb-cartoon-") as temp_dir_name:
        temp_dir = Path(temp_dir_name)
        ass_path = temp_dir / "bubbles-tpb-cartoon.ass"
        audio_path = temp_dir / "bubbles-tpb-cartoon.wav"
        ass_path.write_text(build_ass(), encoding="utf-8")
        write_audio(audio_path)
        command = [
            str(args.ffmpeg_bin),
            "-y",
            "-f",
            "lavfi",
            "-i",
            f"color=c=0xfdfcf9:s={WIDTH}x{HEIGHT}:r={FPS}:d={DURATION_SECONDS}",
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
            "160k",
            "-movflags",
            "+faststart",
            str(args.output),
        ]
        subprocess.run(command, check=True)
    print(f"Rendered {args.output} ({DURATION_SECONDS} seconds)")


if __name__ == "__main__":
    main()
