#!/usr/bin/env python3
"""Render a practical synthetic Bubbles walkthrough video.

The video demonstrates setup-to-result flow with synthetic commands, responses,
and artifact examples. No real project artifacts are embedded.
"""

from __future__ import annotations

import argparse
import asyncio
import re
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path

import render_bubbles_youtube_infoguide as base

WIDTH = base.WIDTH
HEIGHT = base.HEIGHT
FPS = base.FPS
FONT = base.FONT
MONO_FONT = base.MONO_FONT
VOICE = "en-US-BrianNeural"
VOICE_VOLUME = "+0%"
SCENE_PAD_SECONDS = 0.72
AUDIO_BITRATE = "320k"
AUDIO_SAMPLE_RATE = "48000"
VIDEO_CRF = "14"
VIDEO_PRESET = "veryfast"
LOUDNESS_FILTER = "loudnorm=I=-16:TP=-1.5:LRA=11"


@dataclass(frozen=True)
class Scene:
    eyebrow: str
    title: str
    subtitle: str
    bullets: tuple[str, ...]
    panel_title: str
    panel_lines: tuple[str, ...]
    narration: str
    bg: str
    accent: str
    voice_rate: str = "-5%"


SCENES: tuple[Scene, ...] = (
    Scene(
        eyebrow="PRACTICAL DEMO",
        title="From Blank Repo To Verified Result",
        subtitle="A synthetic walkthrough: setup, workflow, artifacts, tests, validation, and the final proof trail.",
        bullets=(
            "Project is fictional: pocket-crm-demo.",
            "Bug is fictional: email retry spinner never stops after provider timeout.",
            "Commands and responses are realistic examples for a Bubbles-guided workflow.",
        ),
        panel_title="DEMO CONTRACT",
        panel_lines=(
            "Synthetic examples only",
            "No real repo artifacts",
            "Goal: show the shape",
            "Result: verified behavior",
        ),
        narration=(
            "This is a practical walkthrough, not a real customer project. The repo is synthetic. The bug is synthetic. The artifacts are synthetic. That is on purpose. "
            "We are going to show the shape of a Bubbles workflow from setup to actual result: commands, responses, generated artifacts, tests, validation, and final evidence. "
            "The example is a tiny product called pocket CRM demo, where the email retry button spins forever if the provider times out. Small bug. Realistic pain. Perfect little clipboard exercise."
        ),
        bg="0x101722",
        accent="0x39d0c8",
        voice_rate="-4%",
    ),
    Scene(
        eyebrow="STEP 1",
        title="Start With A Small Synthetic Repo",
        subtitle="The demo app is intentionally ordinary: one web UI, one API, one bug users can feel.",
        bullets=(
            "The product sends follow-up emails from a contact record.",
            "When the provider times out, the retry button keeps spinning forever.",
            "The user-visible fix: button recovers, shows status, and retry is queued exactly once.",
        ),
        panel_title="TERMINAL",
        panel_lines=(
            "$ mkdir pocket-crm-demo",
            "$ cd pocket-crm-demo",
            "$ git init",
            "Initialized empty Git repository",
            "$ tree -L 2",
            "api/  web/  tests/  README.md",
        ),
        narration=(
            "We start with a small repo. Not an enterprise space station. Just a web UI, an API, and a test folder. The product sends follow-up emails from a contact record. "
            "The bug is simple: if the email provider times out, the retry button keeps spinning forever. Users do not see a clear status. Sometimes the action queues twice. "
            "The desired result is also simple: the button recovers, the status is visible, and retry is queued exactly once. Notice the phrasing. We are already thinking in user-visible behavior, not just code changes."
        ),
        bg="0x0f1d26",
        accent="0x58a6ff",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="STEP 2",
        title="Install And Bootstrap Bubbles",
        subtitle="Setup gives the repo the local agents, prompts, instructions, skills, templates, and workflow surfaces.",
        bullets=(
            "Install the framework assets once for the repository.",
            "Bootstrap refreshes the local Bubbles layer safely.",
            "Doctor confirms the framework surface is reachable before real work begins.",
        ),
        panel_title="TERMINAL",
        panel_lines=(
            "$ curl -fsSL https://example.invalid/bubbles/install.sh | bash",
            "Bubbles install complete",
            "Agents: 37 | Modes: 34 | Gates: 65",
            "$ bash .github/bubbles/scripts/cli.sh doctor",
            "doctor: ok",
            "workflow surface: ready",
        ),
        narration=(
            "Next, install and bootstrap. The exact install command depends on how you distribute Bubbles in your environment, so this panel shows the shape, not a live download. "
            "After setup, the repo has the local Bubbles layer: agents, prompts, instructions, skills, templates, workflow scripts, and governance checks. Then run doctor. "
            "The important habit is boring but useful. Before asking the framework to guide real work, confirm that the framework surface is present and healthy. Exciting setup usually means somebody is about to lose an afternoon."
        ),
        bg="0x102033",
        accent="0x58a6ff",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="STEP 3",
        title="Ask Super If You Do Not Know The Route",
        subtitle="Super is the first-touch helper when you need agent guidance instead of guessing the workflow.",
        bullets=(
            "Super explains which workflow or specialist fits the problem.",
            "It can point to recipes like bugfix fastlane, validation loop, or docs refresh.",
            "For this demo, it recommends workflow because we need artifacts, implementation, tests, and validation.",
        ),
        panel_title="COPILOT CHAT",
        panel_lines=(
            "> /bubbles.super",
            "User: Fix retry spinner bug. Need proof.",
            "Super: use /bubbles.workflow",
            "Reason: bug + implementation + tests",
            "Suggested recipe: bugfix fastlane",
        ),
        narration=(
            "If you do not know which route to take, ask super. Super is the first-touch assistant for Bubbles questions, agent selection, commands, recipes, setup, and recovery. "
            "In this synthetic example, we say: fix the retry spinner bug, and I need proof. Super recommends slash bubbles dot workflow, with a bugfix fastlane style path, because this is not just a question. "
            "We need artifacts, a fix, tests, validation, and evidence. That is bigger than one quick review. That is workflow territory."
        ),
        bg="0x181f2b",
        accent="0xffa657",
        voice_rate="-4%",
    ),
    Scene(
        eyebrow="STEP 4",
        title="Run Workflow With The Real User Problem",
        subtitle="Do not ask for a patch first. Ask for the outcome and let the workflow build the trail.",
        bullets=(
            "The request names the user-visible failure and expected outcome.",
            "Workflow resolves the route and starts with analysis instead of jumping straight to code.",
            "The first response creates a synthetic bug folder and execution state.",
        ),
        panel_title="COPILOT CHAT",
        panel_lines=(
            "> /bubbles.workflow fix bug:",
            "Email retry spins forever after timeout.",
            "Expected: recover, show status, queue once.",
            "Workflow: resolved bugfix-fastlane",
            "Created: specs/014-email-retry-spinner/",
            "Next: analyst -> design -> plan",
        ),
        narration=(
            "Now run workflow with the actual user problem. Do not start with, change this handler. Start with the behavior. "
            "Email retry spins forever after timeout. Expected result: recover, show status, queue once. The workflow resolves a bugfix route and creates a synthetic feature or bug folder. "
            "Then it starts in the right order: analysis, design, planning. That is the point. Bubbles tries to understand what must be true before it starts flinging code around the park."
        ),
        bg="0x14231c",
        accent="0x3fb950",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="ARTIFACT 1",
        title="Spec Captures The Outcome Contract",
        subtitle="The spec says what must be true from the user and business perspective.",
        bullets=(
            "Outcome contract names intent, success signal, hard constraints, and failure condition.",
            "Business scenarios describe behavior before technical design details.",
            "The spec becomes the truth source tests and implementation must satisfy.",
        ),
        panel_title="spec.md",
        panel_lines=(
            "## Outcome Contract",
            "Intent: retry recovers after timeout",
            "Success: user sees Queued once",
            "Hard constraint: no duplicate retry job",
            "Failure: spinner remains after timeout",
            "BS-001: timeout -> retry available",
        ),
        narration=(
            "The first important artifact is the spec. In this synthetic example, the spec captures an outcome contract. Intent: retry recovers after timeout. Success signal: the user sees queued once. Hard constraint: no duplicate retry job. Failure condition: spinner remains after timeout. "
            "That is more useful than, fix the button. It gives tests and implementation something concrete to satisfy. "
            "Bubbles wants requirements to be observable. If nobody can prove the outcome, the outcome is probably fog wearing a hat."
        ),
        bg="0x24151a",
        accent="0xff7b72",
        voice_rate="-6%",
    ),
    Scene(
        eyebrow="ARTIFACT 2",
        title="Design Names The Safe Fix Shape",
        subtitle="Design explains how the behavior should survive timing, retries, and partial failure.",
        bullets=(
            "It identifies the timeout boundary and the retry queue write path.",
            "It defines idempotency so repeated clicks do not enqueue duplicate jobs.",
            "It names UI state transitions: sending, timeout, retryable, queued, failed.",
        ),
        panel_title="design.md",
        panel_lines=(
            "## Fix Design",
            "Timeout boundary: email client call",
            "Idempotency key: contactId + templateId",
            "UI states: sending -> retryable",
            "Retry action: queue once",
            "Read-after-write confirms queued status",
        ),
        narration=(
            "Next, design names the safe fix shape. This is where the workflow stops the agent from doing the classic thing: hiding the spinner and calling it fixed. "
            "The design identifies the timeout boundary around the email client call. It defines idempotency using contact ID and template ID, so repeated clicks do not queue duplicate jobs. It names UI state transitions: sending, timeout, retryable, queued, failed. "
            "Now the implementation has rails. It is not just a patch. It is a behavior change with failure handling."
        ),
        bg="0x251414",
        accent="0xf85149",
        voice_rate="-6%",
    ),
    Scene(
        eyebrow="ARTIFACT 3",
        title="Plan Slices The Work Into Proveable Scopes",
        subtitle="Scopes connect scenarios, files, commands, and Definition of Done items.",
        bullets=(
            "Each scope has scenarios and a test plan before implementation claims completion.",
            "Every test-plan row needs a matching DoD item.",
            "Every checked DoD item later needs evidence, not just confidence.",
        ),
        panel_title="scopes.md",
        panel_lines=(
            "### Scope 1: retry timeout recovery",
            "Scenario: provider timeout",
            "Test: e2e-ui timeout retry",
            "Test: api idempotent enqueue",
            "DoD: behavior complete",
            "DoD: evidence recorded",
        ),
        narration=(
            "Then plan slices the work into proveable scopes. Scope one might be retry timeout recovery. It names the scenario, the API test, the UI test, the files likely touched, and the definition of done. "
            "This is where Bubbles gets strict again. Every test-plan row needs a matching definition-of-done item. Later, every checked definition-of-done item needs raw evidence. "
            "That means the plan is not decorative. It is a contract for how the work will be proven."
        ),
        bg="0x191d23",
        accent="0xf2cc60",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="STEP 5",
        title="Implementation Changes The Behavior",
        subtitle="The synthetic diff wires timeout recovery, idempotent retry, and visible status.",
        bullets=(
            "API returns retryable state when provider timeout occurs.",
            "Retry enqueue uses an idempotency key to prevent duplicates.",
            "UI stops spinner, shows retryable status, and confirms queued state after retry.",
        ),
        panel_title="WORKFLOW RESPONSE",
        panel_lines=(
            "Changed files:",
            "api/email/send.ts",
            "api/email/retryQueue.ts",
            "web/ContactEmailPanel.tsx",
            "tests/email-retry.spec.ts",
            "Result: timeout path implemented",
        ),
        narration=(
            "Now implementation can change behavior. In this synthetic diff, the API returns a retryable state when the provider times out. The retry queue uses an idempotency key. The UI stops the spinner, shows retry available, and confirms queued status after retry. "
            "Notice what is not happening: the agent is not only changing CSS, and it is not only changing an API branch. The vertical slice matters. The user-visible fix crosses UI, API, queue behavior, and tests. "
            "This is exactly where Bubbles earns its keep: keeping the whole path in view."
        ),
        bg="0x102033",
        accent="0x58a6ff",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="STEP 6",
        title="Run Tests That Can Actually Fail",
        subtitle="The proof has to hit the old failure mode, not politely walk around it.",
        bullets=(
            "The API test asserts one queued job across duplicate retry attempts.",
            "The UI test asserts spinner stops and queued status appears.",
            "The regression case simulates timeout, not a happy provider response.",
        ),
        panel_title="TERMINAL",
        panel_lines=(
            "$ npm test -- email-retry.spec.ts",
            "PASS timeout returns retryable state",
            "PASS duplicate retry queues one job",
            "$ npx playwright test email-retry.e2e.ts",
            "PASS spinner stops after timeout",
            "PASS queued status visible",
        ),
        narration=(
            "Then run tests that can actually fail. This is not the time for a happy provider response and a victory lap. The regression case simulates the timeout. "
            "The API test asserts that duplicate retry attempts queue one job. The UI test asserts the spinner stops after timeout and queued status appears after retry. "
            "If the old bug comes back, these tests should get loud. Quiet tests are not polite. They are expensive."
        ),
        bg="0x17251f",
        accent="0x3fb950",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="ARTIFACT 4",
        title="Report Records Raw Evidence",
        subtitle="The report captures what ran, what passed, and what behavior was proven.",
        bullets=(
            "Evidence includes command output, pass counts, and behavior assertions.",
            "It records enough context for a reviewer or future session to trust the claim.",
            "The report is the difference between done and trust me bro with Markdown.",
        ),
        panel_title="report.md",
        panel_lines=(
            "## Test Evidence",
            "Command: npm test -- email-retry.spec.ts",
            "Result: 2 passed, 0 failed",
            "Command: npx playwright test email-retry.e2e.ts",
            "Result: 2 passed, 0 failed",
            "Observed: queued status visible",
        ),
        narration=(
            "The report records evidence. Not a summary pretending to be evidence. The command, the observed output, the pass count, and the behavior assertion. "
            "This is what a reviewer needs later. It is also what the next agent needs after context compaction. "
            "When Bubbles says raw evidence, this is the spirit: show what ran, show what passed, and show what user-visible behavior was proven. Anything less is just trust me bro with Markdown formatting."
        ),
        bg="0x0e2630",
        accent="0x39d0c8",
        voice_rate="-6%",
    ),
    Scene(
        eyebrow="STEP 7",
        title="Validation Gates Push Back",
        subtitle="This is where fake completion gets stopped before it becomes a release note.",
        bullets=(
            "State-transition guard checks whether the work is allowed to move toward done.",
            "Artifact lint checks structure, checkboxes, evidence sections, and required fields.",
            "Reality and integration gates catch stubs, unwired endpoints, and weak vertical slices.",
        ),
        panel_title="TERMINAL",
        panel_lines=(
            "$ bash .github/bubbles/scripts/state-transition-guard.sh specs/014-email-retry-spinner",
            "G023 status transition: PASS",
            "G025 per-DoD evidence: PASS",
            "G028 reality scan: PASS",
            "G035 vertical slice: PASS",
            "guard: PASS",
        ),
        narration=(
            "Now validation gates push back. This is the part that makes Bubbles feel strict, and it should. "
            "State-transition guard checks whether the work is even allowed to move toward done. Artifact lint checks structure, checkboxes, evidence sections, and required fields. Reality scan looks for stubs and fake implementation. Integration completeness checks wiring. Vertical slice completeness checks frontend-to-backend behavior. "
            "If something is missing, the gate fails and routes rework. That is not bureaucracy. That is the system refusing to publish fake done."
        ),
        bg="0x202033",
        accent="0xd2a8ff",
        voice_rate="-6%",
    ),
    Scene(
        eyebrow="STEP 8",
        title="Quality Agents Add Pressure",
        subtitle="After the fix works, use the quality suite to find brittle behavior and cleanup opportunities.",
        bullets=(
            "chaos tries real-system usage variations around the retry path.",
            "simplify cleans the diff after behavior is proven.",
            "harden and security pressure completion, policy, and risk before closeout.",
        ),
        panel_title="COPILOT CHAT",
        panel_lines=(
            "> /bubbles.chaos retry flow",
            "Finding: double-click safe",
            "> /bubbles.simplify recent diff",
            "Refactor: extracted retryStatusLabel()",
            "> /bubbles.security email retry",
            "Finding: no auth regression detected",
        ),
        narration=(
            "After the fix works, the quality agents add pressure. Chaos tries real-system usage variations around the retry path. Double click. Navigate away. Return. Retry after timeout. "
            "Simplify reviews the diff and cleans awkward duplication. Harden checks completion and policy. Security looks for auth, exposure, and risk issues around the retry path. "
            "This is how Bubbles avoids the classic delivery pattern where the first implementation technically works, and the second developer quietly inherits a shed full of questionable wiring."
        ),
        bg="0x111827",
        accent="0xffa657",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="STEP 9",
        title="Docs And Specs Stay In Sync",
        subtitle="The fix is not complete if the durable truth surfaces still describe the old behavior.",
        bullets=(
            "Docs updates explain timeout recovery and retry status to future maintainers.",
            "Spec-review can flag stale or drifted requirements after implementation.",
            "The final state records what completed and what evidence supports it.",
        ),
        panel_title="DOCS RESPONSE",
        panel_lines=(
            "Updated docs/EmailDelivery.md",
            "Added retry timeout behavior",
            "Updated spec outcome contract",
            "spec-review: current truth active",
            "state.json: scope-1 Done",
        ),
        narration=(
            "Docs and specs need to stay in sync. The fix is not complete if durable truth still describes the old behavior. "
            "In the synthetic response, docs now explain timeout recovery and retry status. The spec outcome contract reflects the final behavior. Spec-review confirms the active truth is current. State records the completed scope. "
            "This is not glamorous. It is how future work starts from reality instead of historical fiction."
        ),
        bg="0x14231c",
        accent="0x3fb950",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="FINAL RESULT",
        title="The Actual Result Is A Verified User Behavior",
        subtitle="The button recovers, retry queues once, status is visible, and the proof trail is readable.",
        bullets=(
            "User sees retry available after timeout instead of infinite spinner.",
            "Retry creates one queue job even when clicked repeatedly.",
            "Artifacts show what changed, what ran, what passed, and what risk remains.",
        ),
        panel_title="FINAL RESPONSE",
        panel_lines=(
            "Fixed behavior:",
            "timeout -> retry available",
            "retry -> queued status",
            "duplicates -> one job",
            "Evidence: tests + guard pass",
            "Residual risk: provider outage duration",
        ),
        narration=(
            "The actual result is not, code changed. The actual result is verified user behavior. Timeout leads to retry available. Retry leads to queued status. Repeated clicks lead to one queue job, not a tiny job parade. "
            "The artifacts show what changed, what ran, what passed, and what risk remains. The final answer can be concise because the proof trail exists. "
            "That is the practical Bubbles loop: setup, route, artifacts, implementation, tests, gates, quality pressure, docs, and a result you can inspect."
        ),
        bg="0x0f1d26",
        accent="0x39d0c8",
        voice_rate="-5%",
    ),
    Scene(
        eyebrow="WRAP",
        title="Use This Pattern On One Real Workflow",
        subtitle="Pick a painful bug, a drifted spec, or a feature that needs evidence. Then make the work prove itself.",
        bullets=(
            "Start with the user-visible outcome, not a vague patch request.",
            "Let Bubbles produce the artifacts and route the right agents.",
            "Judge the result by evidence, gates, and maintained truth surfaces.",
        ),
        panel_title="CHECKLIST",
        panel_lines=(
            "1. Install + doctor",
            "2. Ask super if unsure",
            "3. Run /bubbles.workflow",
            "4. Inspect artifacts",
            "5. Run tests and gates",
            "6. Ship only with evidence",
        ),
        narration=(
            "Use this pattern on one real workflow. Pick a painful bug, a drifted spec, or a feature where you need more than a cheerful final paragraph. "
            "Start with the user-visible outcome. Let Bubbles route the work. Inspect the artifacts. Run the tests and gates. Use the quality agents when the blast radius deserves pressure. Keep docs and specs current. "
            "Then judge the result by evidence. Not charm. Not vibes. Evidence. That is the practical move."
        ),
        bg="0x151515",
        accent="0xffffff",
        voice_rate="-4%",
    ),
)

LOCALIZED_TITLES = {
    "From Blank Repo To Verified Result": {
        "es": "De un repositorio vacío a un resultado verificado",
        "ru": "От пустого репозитория к проверенному результату",
    },
    "Start With A Small Synthetic Repo": {
        "es": "Empieza con un repositorio sintético pequeño",
        "ru": "Начни с небольшого синтетического репозитория",
    },
    "Install And Bootstrap Bubbles": {
        "es": "Instala y prepara Bubbles",
        "ru": "Установи и подготовь Bubbles",
    },
    "Ask Super If You Do Not Know The Route": {
        "es": "Pregunta a Super si no conoces la ruta",
        "ru": "Спроси Super, если не знаешь маршрут",
    },
    "Run Workflow With The Real User Problem": {
        "es": "Ejecuta Workflow con el problema real del usuario",
        "ru": "Запусти Workflow с реальной пользовательской проблемой",
    },
    "Spec Captures The Outcome Contract": {
        "es": "La spec captura el contrato de resultado",
        "ru": "Spec фиксирует контракт результата",
    },
    "Design Names The Safe Fix Shape": {
        "es": "Design define la forma segura del arreglo",
        "ru": "Design задает безопасную форму исправления",
    },
    "Plan Slices The Work Into Proveable Scopes": {
        "es": "Plan divide el trabajo en alcances verificables",
        "ru": "Plan режет работу на проверяемые scope",
    },
    "Implementation Changes The Behavior": {
        "es": "La implementación cambia el comportamiento",
        "ru": "Implementation меняет поведение",
    },
    "Run Tests That Can Actually Fail": {
        "es": "Ejecuta pruebas que realmente pueden fallar",
        "ru": "Запусти тесты, которые реально могут упасть",
    },
    "Report Records Raw Evidence": {
        "es": "Report registra evidencia cruda",
        "ru": "Report записывает сырые доказательства",
    },
    "Validation Gates Push Back": {
        "es": "Las gates de validación presionan de vuelta",
        "ru": "Validation gates сопротивляются фальшивому завершению",
    },
    "Quality Agents Add Pressure": {
        "es": "Los agentes de calidad añaden presión",
        "ru": "Quality agents добавляют давление",
    },
    "Docs And Specs Stay In Sync": {
        "es": "Docs y specs se mantienen sincronizados",
        "ru": "Docs и specs остаются синхронизированными",
    },
    "The Actual Result Is A Verified User Behavior": {
        "es": "El resultado real es un comportamiento verificado",
        "ru": "Реальный результат — проверенное поведение пользователя",
    },
    "Use This Pattern On One Real Workflow": {
        "es": "Usa este patrón en un flujo real",
        "ru": "Используй этот паттерн на одном реальном workflow",
    },
}

SUMMARY_BY_LANG = {
    "es": "Este segmento muestra un paso práctico del flujo Bubbles con ejemplos sintéticos de comandos, respuestas y artefactos.",
    "ru": "Этот раздел показывает практический шаг Bubbles с синтетическими примерами команд, ответов и артефактов.",
}


def require_file(path: Path, label: str) -> None:
    if not path.is_file():
        raise SystemExit(f"Missing {label}: {path}")


def localized_title(scene: Scene, lang: str) -> str:
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


def english_cues(timings: list[tuple[float, float]]) -> list[tuple[float, float, str]]:
    cues: list[tuple[float, float, str]] = []
    for scene, (start, end) in zip(SCENES, timings):
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


def localized_summary_cues(timings: list[tuple[float, float]], lang: str) -> list[tuple[float, float, str]]:
    cues: list[tuple[float, float, str]] = []
    for scene, (start, end) in zip(SCENES, timings):
        midpoint = start + (end - start) * 0.38
        cues.append((start, midpoint, localized_title(scene, lang)))
        cues.append((midpoint, end, SUMMARY_BY_LANG[lang]))
    return cues


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


def write_captions_and_chapters(output_stem: Path, timings: list[tuple[float, float]]) -> None:
    for lang in ("en", "es", "ru"):
        chapter_lines = [
            f"{youtube_time(start)} - {localized_title(scene, lang)}"
            for scene, (start, _end) in zip(SCENES, timings)
        ]
        output_stem.with_name(f"{output_stem.name}-chapters-{lang}.txt").write_text(
            "\n".join(chapter_lines) + "\n", encoding="utf-8"
        )

    caption_sets = {
        "en": english_cues(timings),
        "es": localized_summary_cues(timings, "es"),
        "ru": localized_summary_cues(timings, "ru"),
    }
    for lang, cues in caption_sets.items():
        write_srt(output_stem.with_name(f"{output_stem.name}-captions-{lang}.srt"), cues)
        write_vtt(output_stem.with_name(f"{output_stem.name}-captions-{lang}.vtt"), cues)


def build_transcript() -> str:
    lines = ["# Bubbles Practical Synthetic Walkthrough Transcript", ""]
    lines.append(f"Voice: {VOICE}")
    lines.append("Demo data: synthetic pocket-crm-demo project and synthetic Bubbles artifacts.")
    lines.append("Captions: English full narration captions plus Spanish and Russian scene-summary captions.")
    lines.append("")
    for index, scene in enumerate(SCENES, start=1):
        lines.append(f"## {index:02d}. {scene.title}")
        lines.append("")
        lines.append(f"Rate: {scene.voice_rate}")
        lines.append("")
        lines.append(scene.narration)
        lines.append("")
    return "\n".join(lines)


def add_wrapped_text(
    lines: list[str],
    layer: int,
    start: float,
    end: float,
    value: str,
    x: int,
    y: int,
    size: int,
    color: str,
    max_chars: int,
    line_gap: int,
    alpha: str = "00",
    bold: bool = False,
    font: str = FONT,
) -> int:
    for line_index, wrapped_line in enumerate(base.wrap_line(value, max_chars)):
        lines.append(base.dialogue(layer, start, end, base.text(wrapped_line, x, y + line_index * line_gap, size, color, alpha, 7, bold, font)))
    return y + max(1, len(base.wrap_line(value, max_chars))) * line_gap


def add_section_progress(lines: list[str], start: float, end: float, scene: Scene, index: int) -> None:
    total = len(SCENES)
    label = f"STEP {index:02d}/{total:02d}: {scene.eyebrow}"
    lines.append(base.dialogue(3, start, end, base.text(label, 1530, 136, 18, "0xffffff", "18", 7, True, MONO_FONT)))
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
            color, alpha = "0xffffff", "68"
        elif segment_index + 1 == index:
            color, alpha = scene.accent, "00"
        else:
            color, alpha = "0xffffff", "CE"
        lines.append(base.dialogue(3, start, end, base.rect(x, rail_top, segment_width, rail_height, color, alpha)))


def add_bullet_list(lines: list[str], start: float, end: float, scene: Scene) -> None:
    cursor = 494
    for bullet_index, bullet in enumerate(scene.bullets):
        wrapped = base.wrap_line(bullet, 58)
        box_height = 54 + len(wrapped) * 31
        lines.append(base.dialogue(2, start, end, base.rect(112, cursor - 18, 1080, box_height, "0x000000", "93")))
        lines.append(base.dialogue(2, start, end, base.rect(112, cursor - 18, 10, box_height, scene.accent, "06")))
        lines.append(base.dialogue(3, start, end, base.text(str(bullet_index + 1), 146, cursor - 1, 29, scene.accent, "00", 7, True, MONO_FONT)))
        for line_index, bullet_line in enumerate(wrapped):
            lines.append(base.dialogue(3, start, end, base.text(bullet_line, 206, cursor - 1 + line_index * 31, 28, "0xffffff", "18", 7)))
        cursor += box_height + 20


def add_demo_panel(lines: list[str], start: float, end: float, scene: Scene) -> None:
    panel_left = 1232
    panel_top = 412
    panel_width = 596
    panel_height = 532
    lines.append(base.dialogue(2, start, end, base.rect(panel_left, panel_top, panel_width, panel_height, "0x05070d", "34")))
    lines.append(base.dialogue(2, start, end, base.rect(panel_left, panel_top, panel_width, 50, scene.accent, "08")))
    lines.append(base.dialogue(3, start, end, base.text(scene.panel_title, panel_left + 24, panel_top + 14, 21, "0x111827", "00", 7, True, MONO_FONT)))
    cursor = panel_top + 74
    for panel_line in scene.panel_lines:
        is_command = panel_line.startswith("$") or panel_line.startswith(">")
        is_heading = panel_line.endswith(":") or panel_line.startswith("##")
        color = scene.accent if is_command or is_heading else "0xffffff"
        size = 20 if len(panel_line) < 58 else 18
        max_chars = 45 if size == 20 else 50
        cursor = add_wrapped_text(
            lines,
            3,
            start,
            end,
            panel_line,
            panel_left + 28,
            cursor,
            size,
            color,
            max_chars,
            25,
            "00" if is_command or is_heading else "08",
            is_command or is_heading,
            MONO_FONT,
        )
        cursor += 7


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
    total_duration = scene_timings[-1][1]
    lines.append(base.dialogue(0, 0, total_duration, base.rect(0, 0, WIDTH, HEIGHT, "0x0b1017")))
    for index, (scene, timing) in enumerate(zip(SCENES, scene_timings), start=1):
        start, end = timing
        lines.append(base.dialogue(0, start, end, base.rect(0, 0, WIDTH, HEIGHT, scene.bg)))
        lines.append(base.dialogue(1, start, end, base.rect(0, 0, 52, HEIGHT, scene.accent)))
        lines.append(base.dialogue(1, start, end, base.rect(108, 72, 350, 48, scene.accent, "08")))
        lines.append(base.dialogue(1, start, end, base.rect(108, 210, 1710, 4, scene.accent, "18")))
        lines.append(base.dialogue(1, start, end, base.rect(1488, 72, 330, 92, "0x000000", "86")))
        lines.append(base.dialogue(2, start, end, base.text(f"{index:02d}/{len(SCENES):02d}", 1530, 96, 35, scene.accent, "00", 7, True, MONO_FONT)))
        add_section_progress(lines, start, end, scene, index)
        base.add_background_motif(lines, start, end, scene, index)
        lines.append(base.dialogue(3, start, end, base.text(scene.eyebrow, 132, 88, 25, "0x111827", "00", 7, True, MONO_FONT)))
        title_lines = base.wrap_line(scene.title, 38)
        for line_index, title_line in enumerate(title_lines):
            lines.append(base.dialogue(3, start, end, base.text(title_line, 108, 248 + line_index * 72, 62, "0xffffff", "00", 7, True)))
        subtitle_y = 366 + max(0, len(title_lines) - 1) * 47
        for line_index, subtitle_line in enumerate(base.wrap_line(scene.subtitle, 76)):
            lines.append(base.dialogue(3, start, end, base.text(subtitle_line, 112, subtitle_y + line_index * 39, 32, "0xffffff", "22", 7)))
        add_bullet_list(lines, start, end, scene)
        add_demo_panel(lines, start, end, scene)
        footer = "Bubbles | practical synthetic walkthrough for accountable AI coding work"
        lines.append(base.dialogue(3, start, end, base.text(footer, 112, 1010, 23, "0xffffff", "76", 7)))
    return "\n".join(lines) + "\n"


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
        f"color=c=0x000000:s={WIDTH}x{HEIGHT}:r={FPS}:d={duration:.3f}",
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
    parser.add_argument("--ffmpeg-bin", required=True, type=Path, help="Path to ffmpeg")
    parser.add_argument("--output", required=True, type=Path, help="Output MP4 path")
    parser.add_argument("--audio-output", type=Path, help="Optional AAC narration output")
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

    with tempfile.TemporaryDirectory(prefix="bubbles-practical-walkthrough-") as temp_dir_name:
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

        write_captions_and_chapters(args.output.with_suffix(""), scene_timings)
        ass_path = temp_dir / "bubbles-practical-walkthrough.ass"
        ass_path.write_text(build_ass(scene_timings), encoding="utf-8")
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
