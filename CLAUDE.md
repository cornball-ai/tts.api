# ttsapi

Minimal-dependency R client for Text-to-Speech APIs.

## Supported Backends

- **OpenAI-compatible**: OpenAI, Chatterbox, LM Studio, OpenWebUI, AnythingLLM
- **ElevenLabs**: Separate API with voice cloning and multilingual support

## Dependencies

**Imports:** `curl`, `jsonlite`

**Suggests:** `processx`

**Excluded:** No ffmpeg, no tidyverse/httr2, no audio concatenation

---

## Exported Functions

### Configuration

| Function | Purpose |
|----------|---------|
| `set_tts_base(url)` | Set OpenAI-compatible API base URL |
| `set_tts_key(key)` | Set OpenAI-compatible API key |
| `set_elevenlabs_key(key)` | Set ElevenLabs API key |

### Speech Generation

| Function | Purpose |
|----------|---------|
| `speech(input, voice, file, backend, ...)` | Main synthesis function |
| `speech_clone(input, voice_file, file, ...)` | Voice cloning (Chatterbox) |
| `voice_upload(voice_file, voice_name, ...)` | Upload voice to library (Chatterbox) |

### Utilities

| Function | Purpose |
|----------|---------|
| `voices()` | List available voices |
| `languages()` | List supported languages |
| `tts_health()` | Check server health |

---

## Backend Architecture

```
speech(backend = ...)
    │
    ├── "auto" / "chatterbox" ──→ OpenAI-compatible API
    │                              POST /v1/audio/speech
    │                              Uses: set_tts_base(), set_tts_key()
    │
    ├── "openai" ───────────────→ OpenAI API (auto-sets base URL)
    │                              POST /v1/audio/speech
    │                              Uses: OPENAI_API_KEY env var
    │
    └── "elevenlabs" ───────────→ ElevenLabs API (NOT OpenAI-compatible)
                                   POST /v1/text-to-speech/{voice_id}
                                   Uses: set_elevenlabs_key() or
                                         ELEVENLABS_API_KEY env var
```

## Parameters by Backend

| Parameter | OpenAI | Chatterbox | ElevenLabs |
|-----------|--------|------------|------------|
| `input` | Yes | Yes | Yes |
| `voice` | Yes | Yes | voice_id |
| `model` | tts-1, tts-1-hd | ignored | eleven_* |
| `instructions` | Yes | No | No |
| `temperature` | No | Yes | No |
| `exaggeration` | No | Yes | No |
| `cfg_weight` | No | Yes | No |
| `stability` | No | No | Yes |
| `similarity_boost` | No | No | Yes |

---

## Package Options

```r
options(
  ttsapi.api_base = NULL,        # OpenAI-compatible base URL
  ttsapi.api_key = NULL,         # OpenAI-compatible API key
  ttsapi.elevenlabs_key = NULL,  # ElevenLabs API key
  ttsapi.timeout = 30
)
```

---

## Planned Backends

Reference: https://github.com/jhudsl/text2speech (abandoned, use as code reference)

| Backend | Priority | Auth | Notes |
|---------|----------|------|-------|
| **Azure TTS** | Medium | API key + region | REST-based, `set_azure_key(key, region)` |
| **Coqui TTS** | Medium | None (local) | Look for OpenAI-compatible wrappers |
| **Amazon Polly** | Low | AWS SigV4 | Complex auth |
| **Google Cloud** | Low | OAuth | Needs googleAuthR |

### Azure TTS

```
Endpoint: https://{region}.tts.speech.microsoft.com/cognitiveservices/v1
Headers:
  Ocp-Apim-Subscription-Key: {api_key}
  Content-Type: application/ssml+xml
  X-Microsoft-OutputFormat: audio-16khz-128kbitrate-mono-mp3
Body: SSML XML
```

### Coqui TTS

- Native Coqui requires Python
- Look for coqui-ai/TTS Docker images with REST API
- Or OpenAI-compatible wrappers (would just work with `set_tts_base()`)

---

## Notes

- GPU container management planned for separate `gpuctl` package
- ttsapi remains a pure HTTP client
