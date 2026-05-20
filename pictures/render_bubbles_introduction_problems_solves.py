#!/usr/bin/env python3
"""Render a Bubbles introduction video for devs, managers, and leadership."""

from __future__ import annotations

import argparse
import asyncio
import sys
import tempfile
from pathlib import Path

import render_bubbles_youtube_fixed_pair as fixed
import render_bubbles_youtube_infoguide as base

VOICE = "en-US-BrianNeural"
VOICE_VOLUME = "+0%"
SCENE_PAD_SECONDS = 0.72
VIDEO_PRESET = "veryfast"
TRANSCRIPT_TITLE = "Bubbles Introduction: Problems And Solutions For Devs, Managers, And Leadership"
FOOTER = "Bubbles | introduction to accountable AI coding work"

SCENES: tuple[base.Scene, ...] = (
    base.Scene(
        eyebrow="INTRO",
        title="Bubbles Makes AI Coding Work Prove Itself",
        subtitle="For devs, managers, and leadership: faster agent work with receipts instead of vibes.",
        bullets=(
            "AI can generate code quickly; teams still need proof it is correct.",
            "Bubbles wraps Copilot Chat with agents, workflows, artifacts, and gates.",
            "The goal is simple: move faster without pretending trust is free.",
        ),
        board_lines=(
            "The promise:",
            "speed + proof",
            "agents + ownership",
            "workflows + gates",
            "artifacts + evidence",
        ),
        narration=(
            "Here is the short version. AI coding tools made output cheap. Bubbles is for the part that stayed expensive: knowing whether the work is actually done. "
            "It is a framework around VS Code Copilot Chat that adds specialist agents, workflow modes, repo-local instructions, artifacts, validation gates, and evidence trails. "
            "For developers, it reduces rework. For managers, it makes status less mysterious. For leadership, it turns AI coding from a pile of clever conversations into a governed delivery system. Still practical. Still funny enough to survive a standup."
        ),
        bg="0x101722",
        accent="0x39d0c8",
        voice_rate="-5%",
    ),
    base.Scene(
        eyebrow="THE PROBLEM",
        title="AI Made Typing Cheap. It Did Not Make Trust Free.",
        subtitle="The bottleneck moved from writing code to believing code.",
        bullets=(
            "A confident final answer can hide missing tests, broken routes, or stale docs.",
            "Generated changes can outrun human review and project memory.",
            "The team needs a delivery trail, not just a cheerful summary.",
        ),
        board_lines=(
            "Old bottleneck:",
            "typing code",
            "New bottleneck:",
            "knowing what is true",
            "Bubbles attacks the new bottleneck.",
        ),
        narration=(
            "The core problem is not that AI is too slow. It is that AI is fast enough to create a convincing mess before anybody has checked the blast radius. "
            "The output looks serious. The summary sounds responsible. But did the agent run the real tests? Did it update the spec? Did it call an endpoint that exists? Did it break a workflow nobody mentioned in the prompt? "
            "Bubbles exists for that gap between code generation and verified delivery. It asks the annoying question every serious project eventually asks: cool story, where is the proof?"
        ),
        bg="0x24151a",
        accent="0xff7b72",
        voice_rate="-6%",
    ),
    base.Scene(
        eyebrow="DEVS",
        title="For Developers: Less Rework, Cleaner Continuity",
        subtitle="Bubbles helps agents take bigger swings without leaving mystery diffs behind.",
        bullets=(
            "Workflow turns a plain-language request into specs, design, scopes, implementation, tests, and validation.",
            "Specialists keep work focused: review, test, docs, simplify, harden, security, and more.",
            "Reports and state make the next session continue from evidence instead of fog.",
        ),
        board_lines=(
            "Developer pain:",
            "mystery diffs",
            "fake tests",
            "lost context",
            "stale docs",
            "Bubbles answer: work trail",
        ),
        narration=(
            "For developers, the pain is practical. The agent changes a lot of files. You spend the next hour figuring out what is real, what is accidental, and why the test suite suddenly behaves like a witness with a lawyer. "
            "Bubbles gives that work a trail. Analyst captures the outcome. Design names the safe shape. Plan slices the work. Implement changes code. Test verifies behavior. Docs updates durable truth. Validate checks whether the claim can advance. "
            "That does not make development slower. It reduces the rework tax. The useful kind of strict is the kind that saves your Friday."
        ),
        bg="0x0f1d26",
        accent="0x58a6ff",
        voice_rate="-5%",
    ),
    base.Scene(
        eyebrow="HOW FOR DEVS",
        title="How It Solves Developer Problems",
        subtitle="The framework makes proof part of the normal loop, not a heroic cleanup phase.",
        bullets=(
            "Vertical slice gates catch UI calls that do not map to real backend routes.",
            "Regression quality checks reject tests that politely avoid the bug.",
            "Simplify and harden agents clean up and pressure-test after the first working pass.",
        ),
        board_lines=(
            "/bubbles.workflow fix bug",
            "-> analyze",
            "-> design",
            "-> plan",
            "-> implement",
            "-> test",
            "-> validate",
            "-> audit",
        ),
        narration=(
            "How does it solve developer problems? By making the proof part of the loop. If the UI calls a route from a dream sequence, vertical slice checks should catch it. If a regression test only passes because it avoids the old bug, quality guards should complain. If the first implementation works but leaves duplicated logic everywhere, simplify gets a turn. "
            "The normal entry point is slash bubbles dot workflow. Describe the outcome. Bubbles routes the phases and keeps evidence attached to the work. "
            "You still write and review code. You just stop accepting a confident paragraph as the build artifact. A beautiful lifestyle change."
        ),
        bg="0x17251f",
        accent="0x3fb950",
        voice_rate="-5%",
    ),
    base.Scene(
        eyebrow="MANAGERS",
        title="For Managers: Status You Can Inspect",
        subtitle="Less 'I think it is done' and more 'here is what passed, what failed, and what remains.'",
        bullets=(
            "Scopes and DoD items show the work breakdown and completion criteria.",
            "Reports capture commands, raw output, evidence, and residual risk.",
            "Validation gates can route rework instead of letting weak completion claims drift forward.",
        ),
        board_lines=(
            "Manager pain:",
            "unclear status",
            "hidden risk",
            "handoff loss",
            "scope drift",
            "Bubbles answer: inspectable evidence",
        ),
        narration=(
            "For managers, the problem is not typing speed. It is inspectable status. Is this feature done, or did the agent just reach the end of the chat box? Which scenarios passed? Which risks remain? Which docs changed? Which scopes are still open? "
            "Bubbles turns that into artifacts you can inspect. Scopes explain the work. Definition of done items say what completion means. Reports show command output and evidence. State records progress. Validation gates can block a status transition when proof is missing. "
            "That makes status less like weather forecasting and more like reading the instrument panel. Still imperfect, but at least the knobs are labeled."
        ),
        bg="0x202033",
        accent="0xd2a8ff",
        voice_rate="-5%",
    ),
    base.Scene(
        eyebrow="HOW FOR MANAGERS",
        title="How It Solves Planning And Delivery Drift",
        subtitle="Owners, artifacts, and gates keep the work from becoming one enormous side quest.",
        bullets=(
            "Analyst owns business truth; design owns architecture; plan owns executable scopes.",
            "Workflow modes encode real delivery shapes: bugfix, feature, hardening, releases, and more.",
            "Recap, handoff, status, and spec-review help keep long work understandable.",
        ),
        board_lines=(
            "Artifact ownership:",
            "analyst -> spec",
            "design -> architecture",
            "plan -> scopes",
            "validate -> certification",
            "audit -> independent review",
        ),
        narration=(
            "Planning drift is what happens when one assistant tries to be product analyst, architect, implementer, tester, auditor, and release manager all at once. It can sound impressive. It can also turn a simple bug into a scenic tour of unrelated files. "
            "Bubbles separates ownership. Analyst owns business truth. Design owns architecture. Plan owns executable scopes. Implement implements. Test tests. Validate certifies. Audit reviews. "
            "Managers get a clearer operating model: who owns the artifact, what gate blocked the work, and what must happen next. That is much better than asking, why did the chatbot rewrite our onboarding copy while fixing a database lock?"
        ),
        bg="0x181f2b",
        accent="0xffa657",
        voice_rate="-5%",
    ),
    base.Scene(
        eyebrow="LEADERSHIP",
        title="For Leadership: AI Adoption With Control Surfaces",
        subtitle="Bubbles turns agentic coding from individual heroics into governed delivery practice.",
        bullets=(
            "Repo-local rules encode project standards for tests, docs, config, UI, security, and release evidence.",
            "Gates make risk visible before a claim becomes done.",
            "Release, audit, security, retro, and hotspot agents create management-level visibility.",
        ),
        board_lines=(
            "Leadership pain:",
            "AI risk without controls",
            "inconsistent delivery",
            "unknown quality trend",
            "Bubbles answer: governance at dev speed",
        ),
        narration=(
            "For leadership, the question is bigger. How do we use AI coding tools without turning every repository into a private experiment? How do we get speed without losing compliance, quality signals, release discipline, and institutional memory? "
            "Bubbles gives control surfaces. The rules live in the repo. The workflow modes encode how work should move. Gates make risk visible. Security, audit, release, retro, and hotspot analysis can become part of the same operating model. "
            "It does not replace engineering judgment. It gives engineering judgment a repeatable rail system so AI help does not become unmanaged enthusiasm with commit access."
        ),
        bg="0x111827",
        accent="0xf2cc60",
        voice_rate="-6%",
    ),
    base.Scene(
        eyebrow="HOW FOR LEADERSHIP",
        title="How It Solves Governance Without Freezing Delivery",
        subtitle="Strict rules live beside the work, where agents and humans can actually use them.",
        bullets=(
            "Instructions and skills capture repo-specific standards instead of relying on tribal memory.",
            "Workflow gates check evidence, integration, vertical slices, docs, and certification state.",
            "Release workflows can carry forward context, risk, validation, and business readiness.",
        ),
        board_lines=(
            "Control surfaces:",
            "instructions",
            "skills",
            "templates",
            "workflow modes",
            "gates",
            "evidence",
        ),
        narration=(
            "The trick is governance without freezing delivery. A twenty-page policy PDF does not help if the agent never reads it and developers only remember it during an incident review. "
            "Bubbles keeps policy close to the work: instructions, skills, templates, workflows, and gates inside the repository. That means the agent can be guided by the same standards the team cares about. "
            "Leadership gets a path to scale AI-assisted delivery with fewer blind spots: not by slowing everyone down, but by making proof, ownership, and validation part of the default motion."
        ),
        bg="0x161b22",
        accent="0x58a6ff",
        voice_rate="-5%",
    ),
    base.Scene(
        eyebrow="ONE EXAMPLE",
        title="One Bug, Two Futures",
        subtitle="Without structure, the agent patches. With Bubbles, the team gets a verified trail.",
        bullets=(
            "Request: checkout fails when availability changes during payment.",
            "Without Bubbles: handler patch, happy-path test, vague final answer.",
            "With Bubbles: outcome, design, scope, adversarial tests, evidence, validation, residual risk.",
        ),
        board_lines=(
            "Before:",
            "patch + vibes",
            "After:",
            "repro + design",
            "tests + evidence",
            "audit + closeout",
        ),
        narration=(
            "Here is a concrete example. Checkout fails when availability changes during payment. Without structure, the agent patches a handler, adds a happy-path test, says done, and the race condition returns next week with sunglasses. "
            "With Bubbles, the workflow starts with the user-visible outcome. Design names the transaction boundary. Plan defines scenarios and done criteria. Implement changes the right path. Test adds adversarial coverage. Chaos can poke timing. Validate checks evidence. Audit names residual risk. "
            "Same AI coding help. Very different operating loop. One future gives you a patch. The other gives you a reason to believe the patch."
        ),
        bg="0x102033",
        accent="0x39d0c8",
        voice_rate="-5%",
    ),
    base.Scene(
        eyebrow="HOW TO START",
        title="Start Small: One Painful Workflow",
        subtitle="Do not boil the ocean. Pick the bug or feature where fake done hurts most.",
        bullets=(
            "Install and bootstrap the Bubbles assets in a repo that needs stronger agent discipline.",
            "Ask Super when you are unsure which agent or workflow fits.",
            "Use workflow for normal feature and bug work; goal, sprint, and releases for larger outcomes.",
        ),
        board_lines=(
            "Starter path:",
            "1. install",
            "2. doctor",
            "3. ask /bubbles.super",
            "4. run /bubbles.workflow",
            "5. inspect evidence",
        ),
        narration=(
            "The starting path is intentionally small. Do not boil the ocean. Pick one painful workflow: a bug that keeps coming back, a feature with drifting requirements, or a release packet that always turns into archaeology. "
            "Install and bootstrap Bubbles. Run doctor. Ask slash bubbles dot super if you do not know the move. Use slash bubbles dot workflow for normal work. Use goal, sprint, and releases when the outcome gets bigger. "
            "Then judge the system by the evidence trail. Not by charm. Not by vibes. By what it can show you."
        ),
        bg="0x14231c",
        accent="0x3fb950",
        voice_rate="-5%",
    ),
    base.Scene(
        eyebrow="THE RESULT",
        title="The Win Is Bigger Swings With Better Control",
        subtitle="Bubbles does not make agents magical. It makes their work reviewable, recoverable, and safer to trust.",
        bullets=(
            "Developers get less cleanup debt and better continuity.",
            "Managers get clearer status, evidence, and routing for rework.",
            "Leadership gets governed AI adoption without turning delivery into ceremony.",
        ),
        board_lines=(
            "Bubbles payoff:",
            "developer leverage",
            "manager visibility",
            "leadership control",
            "evidence becomes trust",
        ),
        narration=(
            "The win is not that Bubbles makes agents magical. Magic is hard to debug. The win is that agents can take bigger swings while the work stays reviewable, recoverable, and safer to trust. "
            "Developers get less cleanup debt. Managers get clearer status and evidence. Leadership gets a practical governance layer for AI-assisted delivery. "
            "Output is cheap now. Verified work is valuable. Bubbles is the system that tries to turn one into the other, without making everybody wear a committee hat. That is the introduction. That is the pitch. And honestly, that is the job."
        ),
        bg="0x151515",
        accent="0xffffff",
        voice_rate="-4%",
    ),
)

LOCALIZED_TITLES = {
    "Bubbles Makes AI Coding Work Prove Itself": {
        "es": "Bubbles hace que el trabajo de IA demuestre sus resultados",
        "ru": "Bubbles заставляет работу ИИ доказывать результат",
    },
    "AI Made Typing Cheap. It Did Not Make Trust Free.": {
        "es": "La IA abarató escribir, no regaló la confianza",
        "ru": "ИИ удешевил набор кода, но доверие не стало бесплатным",
    },
    "For Developers: Less Rework, Cleaner Continuity": {
        "es": "Para desarrolladores: menos retrabajo y mejor continuidad",
        "ru": "Для разработчиков: меньше переделок и лучшее продолжение работы",
    },
    "How It Solves Developer Problems": {
        "es": "Cómo resuelve problemas de desarrollo",
        "ru": "Как это решает проблемы разработчиков",
    },
    "For Managers: Status You Can Inspect": {
        "es": "Para managers: estado que se puede inspeccionar",
        "ru": "Для менеджеров: статус, который можно проверить",
    },
    "How It Solves Planning And Delivery Drift": {
        "es": "Cómo resuelve la deriva de planificación y entrega",
        "ru": "Как это решает дрейф планирования и поставки",
    },
    "For Leadership: AI Adoption With Control Surfaces": {
        "es": "Para liderazgo: adopción de IA con controles",
        "ru": "Для руководства: внедрение ИИ с контрольными поверхностями",
    },
    "How It Solves Governance Without Freezing Delivery": {
        "es": "Cómo resuelve gobernanza sin congelar la entrega",
        "ru": "Как это дает управление без остановки поставки",
    },
    "One Bug, Two Futures": {
        "es": "Un bug, dos futuros",
        "ru": "Один баг, два будущих",
    },
    "Start Small: One Painful Workflow": {
        "es": "Empieza pequeño: un flujo doloroso",
        "ru": "Начни с малого: один болезненный workflow",
    },
    "The Win Is Bigger Swings With Better Control": {
        "es": "La ganancia es más ambición con mejor control",
        "ru": "Выигрыш — большие шаги с лучшим контролем",
    },
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ffmpeg-bin", required=True, type=Path, help="Path to ffmpeg")
    parser.add_argument("--output", required=True, type=Path, help="Output MP4 path")
    parser.add_argument("--audio-output", type=Path, help="Optional AAC narration output")
    parser.add_argument("--transcript-output", type=Path, help="Optional transcript markdown output")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    base.require_file(args.ffmpeg_bin, "ffmpeg binary")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    if args.audio_output:
        args.audio_output.parent.mkdir(parents=True, exist_ok=True)
    if args.transcript_output:
        args.transcript_output.parent.mkdir(parents=True, exist_ok=True)
        args.transcript_output.write_text(fixed.build_transcript(TRANSCRIPT_TITLE, SCENES), encoding="utf-8")

    fixed.LOCALIZED_TITLES.update(LOCALIZED_TITLES)
    fixed.VOICE = VOICE
    fixed.VOICE_VOLUME = VOICE_VOLUME
    fixed.SCENE_PAD_SECONDS = SCENE_PAD_SECONDS
    fixed.VIDEO_PRESET = VIDEO_PRESET
    base.VOICE = VOICE
    base.VOICE_VOLUME = VOICE_VOLUME
    base.SCENE_PAD_SECONDS = SCENE_PAD_SECONDS
    base.SCENES = SCENES

    with tempfile.TemporaryDirectory(prefix="bubbles-intro-problems-solves-") as temp_dir_name:
        temp_dir = Path(temp_dir_name)
        raw_audio_paths = [temp_dir / f"scene-{index:02d}.mp3" for index in range(len(SCENES))]
        asyncio.run(base.synthesize_all(raw_audio_paths))

        scene_durations: list[float] = []
        padded_paths: list[Path] = []
        for index, raw_path in enumerate(raw_audio_paths):
            speech_duration = base.probe_duration(args.ffmpeg_bin, raw_path)
            scene_duration = speech_duration + SCENE_PAD_SECONDS
            scene_durations.append(scene_duration)
            padded_path = temp_dir / f"scene-{index:02d}-padded.wav"
            fixed.pad_scene_audio(args.ffmpeg_bin, raw_path, padded_path, scene_duration)
            padded_paths.append(padded_path)

        combined_audio = temp_dir / "combined-narration.wav"
        fixed.concat_audio_wav(args.ffmpeg_bin, padded_paths, temp_dir / "audio-list.txt", combined_audio)
        if args.audio_output:
            fixed.encode_audio_m4a(args.ffmpeg_bin, combined_audio, args.audio_output)

        scene_timings: list[tuple[float, float]] = []
        cursor = 0.0
        for duration in scene_durations:
            start = cursor
            cursor += duration
            scene_timings.append((start, cursor))

        fixed.write_captions_and_chapters(args.output.with_suffix(""), SCENES, scene_timings)
        ass_path = temp_dir / "bubbles-introduction-problems-solves.ass"
        ass_path.write_text(fixed.build_ass(SCENES, scene_timings, FOOTER), encoding="utf-8")
        total_duration = scene_timings[-1][1]
        fixed.render_video(args.ffmpeg_bin, ass_path, combined_audio, total_duration, args.output)
        print(f"Rendered {args.output} ({total_duration:.2f} seconds)")
        print(f"Wrote captions and YouTube chapters for {args.output.with_suffix('').name}")


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"render failed: {exc}", file=sys.stderr)
        raise
