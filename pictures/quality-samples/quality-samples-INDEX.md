# Audio Quality Variant Samples

Voice: `en-US-AndrewMultilingualNeural` · Rate: -5% · Volume: +0%
Sample text: "Done is the most expensive word in software. AI made it cheap to say. It did not make it cheap to verify. Bubbles is the workflow that asks the very useful question: where is the proof?"

All variants share the SAME source MP3 from edge-tts. Only the post-processing changes.

| # | Variant | What It Tests | File |
|---|---------|---------------|------|
| 1 | `lossless-flac` | Source ceiling. If this distorts, edge-tts itself is the cap. | `quality-lossless-flac.flac` |
| 2 | `aac-256-clean` | Lower-bitrate clean encode. | `quality-aac-256-clean.m4a` |
| 3 | `aac-320-clean` | Higher-bitrate clean encode (no high-pass, no limiter). | `quality-aac-320-clean.m4a` |
| 4 | `aac-320-limited` | High bitrate + soft limiter at -1 dBTP (kills clipping). | `quality-aac-320-limited.m4a` |
| 5 | `aac-vbr-high` | Native AAC VBR `-q:a 2` (highest native quality). | `quality-aac-vbr-high.m4a` |
| 6 | `aac-320-mono` | No resample, no stereo upmix. Pure minimal pipeline. | `quality-aac-320-mono.m4a` |

Listen in order. If FLAC (#1) sounds distorted, that's the edge-tts ceiling.
If FLAC sounds clean and only the AAC ones distort, we pick the cleanest AAC.
