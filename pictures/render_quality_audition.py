#!/usr/bin/env python3
"""Render Andrew Multilingual through several audio-processing variants.

Goal: isolate the source of residual distortion.

Variants:
  1. lossless-flac     - FLAC of the raw decode. If THIS sounds distorted, the
                         edge-tts source is the ceiling and we cannot fix it.
  2. aac-256-clean     - AAC 256k, no filters except soxr resample to 48k stereo.
  3. aac-320-clean     - AAC 320k, no filters except soxr resample to 48k stereo.
  4. aac-320-limited   - AAC 320k, soft limiter at -1 dBTP to kill any clipping,
                         soxr resample to 48k stereo.
  5. aac-vbr-high      - AAC native VBR mode (-q:a 2), highest native quality,
                         soxr resample to 48k stereo.
  6. aac-320-mono      - AAC 320k, mono native 24 kHz preserved (no resample,
                         no upmix). Smallest pipeline, fewest transformations.

All variants use the same source MP3 from Andrew Multilingual. Same script.
Same TTS rate. Only the processing differs.
"""

from __future__ import annotations

import argparse
import asyncio
import subprocess
import tempfile
from pathlib import Path

import edge_tts

VOICE = "en-US-AndrewMultilingualNeural"

SAMPLE_TEXT = (
    "Done is the most expensive word in software. "
    "AI made it cheap to say. It did not make it cheap to verify. "
    "Bubbles is the workflow that asks the very useful question: "
    "where is the proof?"
)
RATE = "-5%"
VOLUME = "+0%"


async def synth_mp3(output: Path) -> None:
    communicate = edge_tts.Communicate(
        text=SAMPLE_TEXT,
        voice=VOICE,
        rate=RATE,
        volume=VOLUME,
    )
    await communicate.save(str(output))


def run(ffmpeg_bin: Path, args: list[str]) -> None:
    subprocess.run(
        [str(ffmpeg_bin), "-y", "-hide_banner", "-nostats", *args],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )


def encode_lossless_flac(ffmpeg_bin: Path, src: Path, out: Path) -> None:
    run(ffmpeg_bin, ["-i", str(src), "-c:a", "flac", str(out)])


def encode_aac_clean(ffmpeg_bin: Path, src: Path, out: Path, bitrate: str) -> None:
    afilter = "aresample=resampler=soxr:precision=28:dither_method=triangular_hp:osr=48000"
    run(ffmpeg_bin, [
        "-i", str(src),
        "-af", afilter,
        "-ar", "48000", "-ac", "2",
        "-c:a", "aac", "-b:a", bitrate,
        "-movflags", "+faststart",
        str(out),
    ])


def encode_aac_limited(ffmpeg_bin: Path, src: Path, out: Path) -> None:
    # Soft brick-wall limiter at ~-1 dBTP to prevent any clipping during encode.
    afilter = (
        "alimiter=limit=0.891:level=disabled,"
        "aresample=resampler=soxr:precision=28:dither_method=triangular_hp:osr=48000"
    )
    run(ffmpeg_bin, [
        "-i", str(src),
        "-af", afilter,
        "-ar", "48000", "-ac", "2",
        "-c:a", "aac", "-b:a", "320k",
        "-movflags", "+faststart",
        str(out),
    ])


def encode_aac_vbr(ffmpeg_bin: Path, src: Path, out: Path) -> None:
    afilter = "aresample=resampler=soxr:precision=28:dither_method=triangular_hp:osr=48000"
    run(ffmpeg_bin, [
        "-i", str(src),
        "-af", afilter,
        "-ar", "48000", "-ac", "2",
        "-c:a", "aac", "-q:a", "2",
        "-movflags", "+faststart",
        str(out),
    ])


def encode_aac_mono_native(ffmpeg_bin: Path, src: Path, out: Path) -> None:
    # No resample, no upmix. Honest minimum: just AAC the raw decode.
    run(ffmpeg_bin, [
        "-i", str(src),
        "-c:a", "aac", "-b:a", "320k",
        "-movflags", "+faststart",
        str(out),
    ])


async def main_async(ffmpeg_bin: Path, output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="bubbles-quality-") as tmp:
        tmp_dir = Path(tmp)
        mp3 = tmp_dir / "andrew.mp3"
        print(f"Synthesizing source: {VOICE}")
        await synth_mp3(mp3)

        variants: list[tuple[str, str, callable]] = [
            ("lossless-flac",  ".flac", lambda o: encode_lossless_flac(ffmpeg_bin, mp3, o)),
            ("aac-256-clean",  ".m4a",  lambda o: encode_aac_clean(ffmpeg_bin, mp3, o, "256k")),
            ("aac-320-clean",  ".m4a",  lambda o: encode_aac_clean(ffmpeg_bin, mp3, o, "320k")),
            ("aac-320-limited",".m4a",  lambda o: encode_aac_limited(ffmpeg_bin, mp3, o)),
            ("aac-vbr-high",   ".m4a",  lambda o: encode_aac_vbr(ffmpeg_bin, mp3, o)),
            ("aac-320-mono",   ".m4a",  lambda o: encode_aac_mono_native(ffmpeg_bin, mp3, o)),
        ]

        for name, ext, fn in variants:
            out = output_dir / f"quality-{name}{ext}"
            fn(out)
            print(f"  wrote: {out}")

    index = output_dir / "quality-samples-INDEX.md"
    lines = [
        "# Audio Quality Variant Samples",
        "",
        f"Voice: `{VOICE}` · Rate: {RATE} · Volume: {VOLUME}",
        f"Sample text: \"{SAMPLE_TEXT}\"",
        "",
        "All variants share the SAME source MP3 from edge-tts. Only the post-processing changes.",
        "",
        "| # | Variant | What It Tests | File |",
        "|---|---------|---------------|------|",
        "| 1 | `lossless-flac` | Source ceiling. If this distorts, edge-tts itself is the cap. | `quality-lossless-flac.flac` |",
        "| 2 | `aac-256-clean` | Lower-bitrate clean encode. | `quality-aac-256-clean.m4a` |",
        "| 3 | `aac-320-clean` | Higher-bitrate clean encode (no high-pass, no limiter). | `quality-aac-320-clean.m4a` |",
        "| 4 | `aac-320-limited` | High bitrate + soft limiter at -1 dBTP (kills clipping). | `quality-aac-320-limited.m4a` |",
        "| 5 | `aac-vbr-high` | Native AAC VBR `-q:a 2` (highest native quality). | `quality-aac-vbr-high.m4a` |",
        "| 6 | `aac-320-mono` | No resample, no stereo upmix. Pure minimal pipeline. | `quality-aac-320-mono.m4a` |",
        "",
        "Listen in order. If FLAC (#1) sounds distorted, that's the edge-tts ceiling.",
        "If FLAC sounds clean and only the AAC ones distort, we pick the cleanest AAC.",
    ]
    index.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote index: {index}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ffmpeg-bin", required=True, type=Path, help="Path to ffmpeg")
    parser.add_argument("--output-dir", required=True, type=Path, help="Where to write the variant files")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if not args.ffmpeg_bin.is_file():
        raise SystemExit(f"Missing ffmpeg binary: {args.ffmpeg_bin}")
    asyncio.run(main_async(args.ffmpeg_bin, args.output_dir))


if __name__ == "__main__":
    main()
