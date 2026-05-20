#!/usr/bin/env python3
"""Render fixed YouTube Bubbles videos with section progress, chapters, and captions."""

from __future__ import annotations

import argparse
import asyncio
import re
import subprocess
import sys
import tempfile
from pathlib import Path

import render_bubbles_youtube_infoguide as base
import render_bubbles_youtube_quality_suite as quality

VOICE = "en-US-BrianNeural"
VOICE_VOLUME = "+0%"
SCENE_PAD_SECONDS = 0.72
AUDIO_BITRATE = "320k"
AUDIO_SAMPLE_RATE = "48000"
VIDEO_CRF = "14"
VIDEO_PRESET = "slow"
LOUDNESS_FILTER = "loudnorm=I=-16:TP=-1.5:LRA=11"

INFO_SCENES = tuple(base.SCENES)
QUALITY_SCENES = tuple(quality.SCENES)

VARIANTS = {
    "problems": {
        "scenes": INFO_SCENES,
        "footer": "Bubbles | informational guide to accountable AI coding work",
        "transcript_title": "Bubbles Problems-Solved YouTube Guide Transcript",
    },
    "quality": {
        "scenes": QUALITY_SCENES,
        "footer": "Bubbles | deeper guide to accountable AI coding work",
        "transcript_title": "Bubbles Quality Suite YouTube Guide Transcript",
    },
}

LOCALIZED_TITLES = {
    "Stop Letting AI Say Done Like It Owns The Place": {
        "es": "Deja de aceptar que la IA diga terminado como si mandara",
        "ru": "Хватит принимать слова ИИ 'готово' без доказательств",
    },
    "Bubbles Is A Delivery System For Copilot Chat": {
        "es": "Bubbles es un sistema de entrega para Copilot Chat",
        "ru": "Bubbles — система поставки работы для Copilot Chat",
    },
    "AI Made Typing Cheap. It Did Not Make Trust Free.": {
        "es": "La IA abarató escribir, no regaló la confianza",
        "ru": "ИИ удешевил набор кода, но доверие не стало бесплатным",
    },
    "The Fake Done Tax Is Brutal": {
        "es": "El impuesto de lo falsamente terminado es brutal",
        "ru": "Налог за фальшивое 'готово' очень дорогой",
    },
    "Think Trailer Park Supervisor For Agent Work": {
        "es": "Piensa en un supervisor de parque para el trabajo de agentes",
        "ru": "Представь диспетчера парка для работы агентов",
    },
    "Intent Becomes A Work Trail": {
        "es": "La intención se convierte en una ruta de trabajo",
        "ru": "Намерение превращается в след выполненной работы",
    },
    "Your UI Calls An Endpoint That Does Not Exist": {
        "es": "Tu interfaz llama a un endpoint que no existe",
        "ru": "Интерфейс вызывает endpoint, которого нет",
    },
    "The Test Passes Because It Avoids The Bug": {
        "es": "La prueba pasa porque esquiva el error",
        "ru": "Тест проходит, потому что обходит баг",
    },
    "The Context Window Went For A Walk": {
        "es": "La ventana de contexto se fue de paseo",
        "ru": "Окно контекста ушло прогуляться",
    },
    "Install Once, Then Start With Workflow": {
        "es": "Instala una vez y empieza con Workflow",
        "ru": "Установи один раз и начни с Workflow",
    },
    "Use Specialists When You Need One Sharp Tool": {
        "es": "Usa especialistas cuando necesitas una herramienta precisa",
        "ru": "Используй специалистов, когда нужен один точный инструмент",
    },
    "Workflow Is The Everyday Workhorse": {
        "es": "Workflow es el caballo de batalla diario",
        "ru": "Workflow — рабочая лошадка на каждый день",
    },
    "Goal, Sprint, And Releases Handle Bigger Outcomes": {
        "es": "Goal, Sprint y Releases manejan resultados más grandes",
        "ru": "Goal, Sprint и Releases ведут более крупные результаты",
    },
    "One Checkout Bug, Two Different Futures": {
        "es": "Un bug de checkout, dos futuros distintos",
        "ru": "Один баг checkout — два разных будущих",
    },
    "It Reduces Rework, Not Creativity": {
        "es": "Reduce retrabajo, no creatividad",
        "ru": "Это сокращает переделки, а не творчество",
    },
    "Evidence Becomes Trust": {
        "es": "La evidencia se convierte en confianza",
        "ru": "Доказательства превращаются в доверие",
    },
    "Run It On One Painful Workflow": {
        "es": "Pruébalo en un flujo de trabajo doloroso",
        "ru": "Запусти это на одном болезненном workflow",
    },
    "Stop Accepting AI Vibes As Delivery": {
        "es": "Deja de aceptar vibras de IA como entrega",
        "ru": "Хватит принимать уверенный тон ИИ за поставленную работу",
    },
    "Bubbles Is The Work System Around Copilot": {
        "es": "Bubbles es el sistema de trabajo alrededor de Copilot",
        "ru": "Bubbles — рабочая система вокруг Copilot",
    },
    "Strict Validation Is The Main Character": {
        "es": "La validación estricta es el personaje principal",
        "ru": "Строгая валидация — главный герой",
    },
    "A Checked Box Without Output Is Just Confetti": {
        "es": "Una casilla marcada sin salida real es solo confeti",
        "ru": "Галочка без вывода команд — просто конфетти",
    },
    "Chaos, Simplify, Harden, Gaps, And Security": {
        "es": "Chaos, Simplify, Harden, Gaps y Security",
        "ru": "Chaos, Simplify, Harden, Gaps и Security",
    },
    "Chaos Is Not Random For Fun": {
        "es": "Chaos no es aleatorio por diversión",
        "ru": "Chaos не случайный ради развлечения",
    },
    "Harden Asks If Done Means Done": {
        "es": "Harden pregunta si terminado realmente significa terminado",
        "ru": "Harden спрашивает, действительно ли 'готово' значит готово",
    },
    "Simplify Cleans Up After The Sprint Brain": {
        "es": "Simplify limpia después del cerebro de sprint",
        "ru": "Simplify убирает после спринтового режима мышления",
    },
    "Security Is Not A Sticker At The End": {
        "es": "Security no es una pegatina al final",
        "ru": "Security — не наклейка в самом конце",
    },
    "Code Review, System Review, And Spec Review": {
        "es": "Code Review, System Review y Spec Review",
        "ru": "Code Review, System Review и Spec Review",
    },
    "Docs And Specs Must Stay Alive": {
        "es": "La documentación y las especificaciones deben seguir vivas",
        "ru": "Документация и спецификации должны оставаться живыми",
    },
    "Retro Finds The Hotspots Nobody Wants To Name": {
        "es": "Retro encuentra los puntos calientes que nadie quiere nombrar",
        "ru": "Retro находит горячие зоны, о которых никто не хочет говорить",
    },
    "Ask Super When You Do Not Know The Move": {
        "es": "Pregunta a Super cuando no sabes el siguiente movimiento",
        "ru": "Спрашивай Super, когда не знаешь следующий ход",
    },
    "Workflow Handles The Normal Delivery Loop": {
        "es": "Workflow maneja el ciclo normal de entrega",
        "ru": "Workflow ведет обычный цикл поставки",
    },
    "Goal, Sprint, And Releases Handle Bigger Work": {
        "es": "Goal, Sprint y Releases manejan trabajo más grande",
        "ru": "Goal, Sprint и Releases ведут большую работу",
    },
    "The UI Calls A Route From A Dream Sequence": {
        "es": "La interfaz llama a una ruta salida de un sueño",
        "ru": "Интерфейс вызывает маршрут из сна",
    },
    "The Test Passes By Avoiding The Fire": {
        "es": "La prueba pasa porque evita el incendio",
        "ru": "Тест проходит, потому что обходит пожар",
    },
    "One Checkout Bug, Two Futures": {
        "es": "Un bug de checkout, dos futuros",
        "ru": "Один баг checkout — два будущих",
    },
    "Bubbles Lets Agents Take Bigger Swings Safely": {
        "es": "Bubbles permite a los agentes intentar cosas más grandes con seguridad",
        "ru": "Bubbles позволяет агентам безопасно брать задачи крупнее",
    },
    "Run Bubbles On One Painful Workflow": {
        "es": "Ejecuta Bubbles en un flujo de trabajo doloroso",
        "ru": "Запусти Bubbles на одном болезненном workflow",
    },
}

SUMMARY_BY_LANG = {
    "es": "Este segmento resume la idea y muestra en pantalla los pasos clave para aplicarla con Bubbles.",
    "ru": "Этот раздел кратко объясняет идею и показывает на экране ключевые шаги для применения в Bubbles.",
}

LANG_NAMES = {
    "en": "English",
    "es": "Spanish",
    "ru": "Russian",
}


def localized_title(scene: base.Scene, lang: str) -> str:
    if lang == "en":
        return scene.title
    return LOCALIZED_TITLES.get(scene.title, {}).get(lang, scene.title)


def srt_time(seconds: float) -> str:
    milliseconds = int(round(seconds * 1000))
    hours, milliseconds = divmod(milliseconds, 3_600_000)
    minutes, milliseconds = divmod(milliseconds, 60_000)
    secs, milliseconds = divmod(milliseconds, 1000)
    return f"{hours:02d}:{minutes:02d}:{secs:02d},{milliseconds:03d}"


def vtt_time(seconds: float) -> str:
    return srt_time(seconds).replace(",", ".")


def youtube_time(seconds: float) -> str:
    total = int(seconds)
    hours, remainder = divmod(total, 3600)
    minutes, secs = divmod(remainder, 60)
    if hours:
        return f"{hours:02d}:{minutes:02d}:{secs:02d}"
    return f"{minutes:02d}:{secs:02d}"


def sentence_chunks(value: str) -> list[str]:
    chunks = [chunk.strip() for chunk in re.split(r"(?<=[.!?])\s+", value.strip()) if chunk.strip()]
    return chunks or [value.strip()]


def write_srt(path: Path, cues: list[tuple[float, float, str]]) -> None:
    blocks: list[str] = []
    for index, (start, end, text_value) in enumerate(cues, start=1):
        blocks.append(str(index))
        blocks.append(f"{srt_time(start)} --> {srt_time(end)}")
        blocks.append(text_value)
        blocks.append("")
    path.write_text("\n".join(blocks), encoding="utf-8")


def write_vtt(path: Path, cues: list[tuple[float, float, str]]) -> None:
    lines = ["WEBVTT", ""]
    for start, end, text_value in cues:
        lines.append(f"{vtt_time(start)} --> {vtt_time(end)}")
        lines.append(text_value)
        lines.append("")
    path.write_text("\n".join(lines), encoding="utf-8")


def english_cues(scenes: tuple[base.Scene, ...], timings: list[tuple[float, float]]) -> list[tuple[float, float, str]]:
    cues: list[tuple[float, float, str]] = []
    for scene, (start, end) in zip(scenes, timings):
        chunks = sentence_chunks(scene.narration)
        duration = max(0.1, end - start)
        total_chars = sum(max(1, len(chunk)) for chunk in chunks)
        cursor = start
        for chunk_index, chunk in enumerate(chunks):
            if chunk_index == len(chunks) - 1:
                chunk_end = end
            else:
                chunk_duration = duration * (max(1, len(chunk)) / total_chars)
                chunk_end = min(end, cursor + max(1.8, chunk_duration))
            cues.append((cursor, chunk_end, chunk))
            cursor = chunk_end
    return cues


def localized_summary_cues(
    scenes: tuple[base.Scene, ...], timings: list[tuple[float, float]], lang: str
) -> list[tuple[float, float, str]]:
    cues: list[tuple[float, float, str]] = []
    for scene, (start, end) in zip(scenes, timings):
        midpoint = start + (end - start) * 0.38
        title = localized_title(scene, lang)
        cues.append((start, midpoint, title))
        cues.append((midpoint, end, SUMMARY_BY_LANG[lang]))
    return cues


def write_captions_and_chapters(
    output_stem: Path,
    scenes: tuple[base.Scene, ...],
    timings: list[tuple[float, float]],
) -> None:
    chapter_languages = ("en", "es", "ru")
    for lang in chapter_languages:
        chapter_lines = [
            f"{youtube_time(start)} - {localized_title(scene, lang)}"
            for scene, (start, _end) in zip(scenes, timings)
        ]
        output_stem.with_name(f"{output_stem.name}-chapters-{lang}.txt").write_text(
            "\n".join(chapter_lines) + "\n", encoding="utf-8"
        )

    caption_sets = {
        "en": english_cues(scenes, timings),
        "es": localized_summary_cues(scenes, timings, "es"),
        "ru": localized_summary_cues(scenes, timings, "ru"),
    }
    for lang, cues in caption_sets.items():
        write_srt(output_stem.with_name(f"{output_stem.name}-captions-{lang}.srt"), cues)
        write_vtt(output_stem.with_name(f"{output_stem.name}-captions-{lang}.vtt"), cues)


def build_transcript(title: str, scenes: tuple[base.Scene, ...]) -> str:
    lines = [f"# {title}", ""]
    lines.append(f"Voice: {VOICE}")
    lines.append("Audio: PCM intermediate, loudness-normalized AAC target 320k at 48 kHz in the rendered video.")
    lines.append("Captions: English full narration captions plus Spanish and Russian scene-summary captions.")
    lines.append("")
    for index, scene in enumerate(scenes, start=1):
        lines.append(f"## {index:02d}. {scene.title}")
        lines.append("")
        lines.append(f"Rate: {scene.voice_rate}")
        lines.append("")
        lines.append(scene.narration)
        lines.append("")
    return "\n".join(lines)


def add_section_progress(
    lines: list[str],
    start: float,
    end: float,
    scene: base.Scene,
    index: int,
    total: int,
) -> None:
    label = f"SECTION {index:02d}/{total:02d}: {scene.eyebrow}"
    lines.append(base.dialogue(3, start, end, base.text(label, 1530, 136, 18, "0xffffff", "18", 7, True, base.MONO_FONT)))

    rail_left = 112
    rail_top = 960
    rail_width = 1706
    rail_height = 10
    gap = 4
    segment_width = max(8, (rail_width - gap * (total - 1)) // total)
    lines.append(base.dialogue(2, start, end, base.rect(rail_left, rail_top, rail_width, rail_height, "0x000000", "8A")))
    for segment_index in range(total):
        x = rail_left + segment_index * (segment_width + gap)
        if segment_index + 1 < index:
            color = "0xffffff"
            alpha = "68"
        elif segment_index + 1 == index:
            color = scene.accent
            alpha = "00"
        else:
            color = "0xffffff"
            alpha = "CE"
        lines.append(base.dialogue(3, start, end, base.rect(x, rail_top, segment_width, rail_height, color, alpha)))


def build_ass(
    scenes: tuple[base.Scene, ...],
    scene_timings: list[tuple[float, float]],
    footer: str,
) -> str:
    lines = [
        "[Script Info]",
        "ScriptType: v4.00+",
        "ScaledBorderAndShadow: yes",
        f"PlayResX: {base.WIDTH}",
        f"PlayResY: {base.HEIGHT}",
        "WrapStyle: 0",
        "",
        "[V4+ Styles]",
        "Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, "
        "Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, "
        "Alignment, MarginL, MarginR, MarginV, Encoding",
        f"Style: Default,{base.FONT},36,&H00FFFFFF,&H00FFFFFF,&H00000000,&H00000000,"
        "0,0,0,0,100,100,0,0,1,0,0,7,0,0,0,1",
        "",
        "[Events]",
        "Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text",
    ]

    total_duration = scene_timings[-1][1]
    lines.append(base.dialogue(0, 0, total_duration, base.rect(0, 0, base.WIDTH, base.HEIGHT, "0x0b1017")))

    total = len(scenes)
    for index, (scene, timing) in enumerate(zip(scenes, scene_timings), start=1):
        start, end = timing
        lines.append(base.dialogue(0, start, end, base.rect(0, 0, base.WIDTH, base.HEIGHT, scene.bg)))
        lines.append(base.dialogue(1, start, end, base.rect(0, 0, 52, base.HEIGHT, scene.accent)))
        lines.append(base.dialogue(1, start, end, base.rect(108, 72, 350, 48, scene.accent, "08")))
        lines.append(base.dialogue(1, start, end, base.rect(108, 210, 1710, 4, scene.accent, "18")))
        lines.append(base.dialogue(1, start, end, base.rect(1488, 72, 330, 92, "0x000000", "86")))
        lines.append(base.dialogue(2, start, end, base.text(f"{index:02d}/{total:02d}", 1530, 96, 35, scene.accent, "00", 7, True, base.MONO_FONT)))
        add_section_progress(lines, start, end, scene, index, total)
        base.add_background_motif(lines, start, end, scene, index)

        lines.append(base.dialogue(3, start, end, base.text(scene.eyebrow, 132, 88, 25, "0x111827", "00", 7, True, base.MONO_FONT)))
        title_y = 248
        title_lines = base.wrap_line(scene.title, 38)
        for line_index, title_line in enumerate(title_lines):
            lines.append(base.dialogue(3, start, end, base.text(title_line, 108, title_y + line_index * 72, 62, "0xffffff", "00", 7, True)))
        subtitle_y = 366 + max(0, len(title_lines) - 1) * 47
        for line_index, subtitle_line in enumerate(base.wrap_line(scene.subtitle, 76)):
            lines.append(base.dialogue(3, start, end, base.text(subtitle_line, 112, subtitle_y + line_index * 39, 32, "0xffffff", "22", 7)))

        base.add_bullet_list(lines, start, end, scene)
        base.add_board(lines, start, end, scene)
        lines.append(base.dialogue(3, start, end, base.text(footer, 112, 1010, 23, "0xffffff", "76", 7)))

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
        f"apad=pad_dur={SCENE_PAD_SECONDS},aresample={AUDIO_SAMPLE_RATE}",
        "-t",
        f"{duration:.3f}",
        "-ar",
        AUDIO_SAMPLE_RATE,
        "-ac",
        "2",
        "-c:a",
        "pcm_s16le",
        str(output),
    ]
    subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def concat_audio_wav(ffmpeg_bin: Path, padded_paths: list[Path], list_path: Path, output: Path) -> None:
    list_path.write_text("\n".join(f"file '{path}'" for path in padded_paths) + "\n", encoding="utf-8")
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
        "-ar",
        AUDIO_SAMPLE_RATE,
        "-ac",
        "2",
        "-c:a",
        "pcm_s16le",
        str(output),
    ]
    subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def encode_audio_m4a(ffmpeg_bin: Path, source: Path, output: Path) -> None:
    command = [
        str(ffmpeg_bin),
        "-y",
        "-hide_banner",
        "-nostats",
        "-i",
        str(source),
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
        f"color=c=0x000000:s={base.WIDTH}x{base.HEIGHT}:r={base.FPS}:d={duration:.3f}",
        "-i",
        str(audio_path),
        "-vf",
        f"ass={ass_path}",
        "-af",
        LOUDNESS_FILTER,
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
        "-movflags",
        "+faststart",
        str(output_path),
    ]
    subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--variant", required=True, choices=sorted(VARIANTS), help="Video variant to render")
    parser.add_argument("--ffmpeg-bin", required=True, type=Path, help="Path to ffmpeg")
    parser.add_argument("--output", required=True, type=Path, help="Output MP4 path")
    parser.add_argument("--audio-output", type=Path, help="Optional AAC narration output")
    parser.add_argument("--transcript-output", type=Path, help="Optional transcript markdown output")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    variant = VARIANTS[args.variant]
    scenes = variant["scenes"]
    base.require_file(args.ffmpeg_bin, "ffmpeg binary")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    if args.audio_output:
        args.audio_output.parent.mkdir(parents=True, exist_ok=True)
    if args.transcript_output:
        args.transcript_output.parent.mkdir(parents=True, exist_ok=True)
        args.transcript_output.write_text(build_transcript(variant["transcript_title"], scenes), encoding="utf-8")

    base.VOICE = VOICE
    base.VOICE_VOLUME = VOICE_VOLUME
    base.SCENE_PAD_SECONDS = SCENE_PAD_SECONDS
    base.SCENES = scenes

    with tempfile.TemporaryDirectory(prefix=f"bubbles-{args.variant}-fixed-") as temp_dir_name:
        temp_dir = Path(temp_dir_name)
        raw_audio_paths = [temp_dir / f"scene-{index:02d}.mp3" for index in range(len(scenes))]
        asyncio.run(base.synthesize_all(raw_audio_paths))

        scene_durations: list[float] = []
        padded_paths: list[Path] = []
        for index, raw_path in enumerate(raw_audio_paths):
            speech_duration = base.probe_duration(args.ffmpeg_bin, raw_path)
            scene_duration = speech_duration + SCENE_PAD_SECONDS
            scene_durations.append(scene_duration)
            padded_path = temp_dir / f"scene-{index:02d}-padded.wav"
            pad_scene_audio(args.ffmpeg_bin, raw_path, padded_path, scene_duration)
            padded_paths.append(padded_path)

        combined_audio = temp_dir / "combined-narration.wav"
        concat_audio_wav(args.ffmpeg_bin, padded_paths, temp_dir / "audio-list.txt", combined_audio)
        if args.audio_output:
            encode_audio_m4a(args.ffmpeg_bin, combined_audio, args.audio_output)

        scene_timings: list[tuple[float, float]] = []
        cursor = 0.0
        for duration in scene_durations:
            start = cursor
            cursor += duration
            scene_timings.append((start, cursor))

        write_captions_and_chapters(args.output.with_suffix(""), scenes, scene_timings)

        ass_path = temp_dir / f"bubbles-{args.variant}-fixed.ass"
        ass_path.write_text(build_ass(scenes, scene_timings, variant["footer"]), encoding="utf-8")
        total_duration = scene_timings[-1][1]
        render_video(args.ffmpeg_bin, ass_path, combined_audio, total_duration, args.output)
        print(f"Rendered {args.output} ({total_duration:.2f} seconds)")
        print(f"Wrote captions and YouTube chapters for {args.output.with_suffix('').name}")


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"render failed: {exc}", file=sys.stderr)
        raise
