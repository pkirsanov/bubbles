#!/usr/bin/env python3
"""Render side-by-side voice audition samples for the dev/PM/product pitch.

Goal: let the user pick the best-sounding narration voice before committing to a
full re-render. Each sample uses the SAME short script and the SAME cleaned-up
audio pipeline. The only thing that varies is the voice.

Audio pipeline (per sample):
- edge-tts -> MP3 at the voice's native rate (typically 24 kHz mono).
- Decode to PCM s16le. Keep native rate. NO resample yet. NO loudnorm.
- Single AAC pass at the end with soxr precision-28 resample to 48 kHz stereo
  and a gentle 80 Hz high-pass to remove low-frequency rumble.
"""

from __future__ import annotations

import argparse
import asyncio
import subprocess
import tempfile
from pathlib import Path

import edge_tts

VOICES: tuple[str, ...] = (
    "en-US-AndrewMultilingualNeural",
    "en-US-BrianMultilingualNeural",
    "en-US-AndrewNeural",
    "en-US-ChristopherNeural",
    "en-US-EricNeural",
    "en-US-RogerNeural",
    "en-US-SteffanNeural",
    "en-US-GuyNeural",  # baseline (current)
)

SAMPLE_TEXT = (
    "Done is the most expensive word in software. "
    "AI made it cheap to say. It did not make it cheap to verify. "
    "Bubbles is the workflow that asks the very useful question: "
    "where is the proof?"
)
RATE = "-5%"
VOLUME = "+0%"

AUDIO_BITRATE = "192k"
TARGET_RATE = "48000"
TARGET_CHANNELS = "2"


async def synth_mp3(voice: str, output: Path) -> None:
    communicate = edge_tts.Communicate(
        text=SAMPLE_TEXT,
        voice=voice,
        rate=RATE,
        volume=VOLUME,
    )
    await communicate.save(str(output))


def encode_clean_m4a(ffmpeg_bin: Path, source_mp3: Path, output: Path) -> None:
    """Single AAC pass: high-quality soxr resample, gentle high-pass, no loudnorm."""
    afilter = (
        "highpass=f=80,"
        f"aresample=resampler=soxr:precision=28:dither_method=triangular_hp:osr={TARGET_RATE}"
    )
    command = [
        str(ffmpeg_bin),
        "-y",
        "-hide_banner",
        "-nostats",
        "-i",
        str(source_mp3),
        "-af",
        afilter,
        "-ar",
        TARGET_RATE,
        "-ac",
        TARGET_CHANNELS,
        "-c:a",
        "aac",
        "-b:a",
        AUDIO_BITRATE,
        "-movflags",
        "+faststart",
        str(output),
    ]
    subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


async def main_async(ffmpeg_bin: Path, output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="bubbles-voice-samples-") as tmp:
        tmp_dir = Path(tmp)
        for voice in VOICES:
            mp3_path = tmp_dir / f"{voice}.mp3"
            print(f"Synthesizing: {voice}")
            await synth_mp3(voice, mp3_path)
            out_path = output_dir / f"voice-sample-{voice}.m4a"
            encode_clean_m4a(ffmpeg_bin, mp3_path, out_path)
            print(f"  wrote: {out_path}")
    # Index file so the user can see the ordering at a glance
    index_path = output_dir / "voice-samples-INDEX.md"
    lines = ["# Voice Audition Samples", ""]
    lines.append(f"Sample text: \"{SAMPLE_TEXT}\"")
    lines.append(f"Rate: {RATE} · Volume: {VOLUME}")
    lines.append("Pipeline: edge-tts -> MP3 (native rate) -> single AAC pass with soxr precision-28 resample to 48 kHz stereo + 80 Hz high-pass. No loudnorm.")
    lines.append("")
    lines.append("| # | Voice | File |")
    lines.append("|---|-------|------|")
    for i, voice in enumerate(VOICES, start=1):
        fname = f"voice-sample-{voice}.m4a"
        lines.append(f"| {i} | `{voice}` | `{fname}` |")
    lines.append("")
    lines.append("Listen to each, pick the winner, and tell the agent which voice to use.")
    index_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote index: {index_path}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ffmpeg-bin", required=True, type=Path, help="Path to ffmpeg")
    parser.add_argument("--output-dir", required=True, type=Path, help="Where to write the sample .m4a files")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if not args.ffmpeg_bin.is_file():
        raise SystemExit(f"Missing ffmpeg binary: {args.ffmpeg_bin}")
    asyncio.run(main_async(args.ffmpeg_bin, args.output_dir))


if __name__ == "__main__":
    main()
