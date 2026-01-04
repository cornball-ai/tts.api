# **PACKAGE SPECIFICATION**

### **Package name:** `ttsapi`

### **Purpose:**

A minimal-dependency R client for **Text-to-Speech APIs**, supporting multiple backends:

* **OpenAI-compatible APIs**: OpenAI `/v1/audio/speech`, Chatterbox, LM Studio, OpenWebUI, AnythingLLM, etc.
* **ElevenLabs API**: Separate API with voice cloning and multilingual support

### **Dependencies:**

**Imports:**

* `curl`
* `jsonlite`

**Suggests:**

* `processx` (optional for long-running processes)

**Excluded:**

* No ffmpeg
* No tidyverse/httr2
* No audio concatenation logic

---

# **1. Exported Functions**

## **Configuration**

### `set_tts_base()`

Sets the base URL for OpenAI-compatible APIs.

```r
set_tts_base("http://localhost:4123")  # Chatterbox
set_tts_base("https://api.openai.com") # OpenAI
```

### `set_tts_key()`

Sets the API key for OpenAI-compatible APIs.

```r
set_tts_key(Sys.getenv("OPENAI_API_KEY"))
```

### `set_elevenlabs_key()`

Sets the API key for ElevenLabs (separate from OpenAI key).

```r
set_elevenlabs_key(Sys.getenv("ELEVENLABS_API_KEY"))
```

---

## **Speech Generation**

### `speech()`

Main speech synthesis function with backend switching:

```r
# OpenAI-compatible (uses set_tts_base())
speech(input, voice, file, backend = "auto")

# Explicit OpenAI (auto-configures base URL)
speech(input, voice, file, backend = "openai")

# ElevenLabs (uses own API, not OpenAI-compatible)
speech(input, voice, file, backend = "elevenlabs")
```

**Parameters by backend:**

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

### `speech_clone()`

Voice cloning with file upload (Chatterbox only).

### `voice_upload()`

Upload voice to server library (Chatterbox only).

---

## **Utilities**

### `voices()`

List available voices from OpenAI-compatible backend.

### `languages()`

List supported languages from backend.

### `tts_health()`

Check if OpenAI-compatible backend is reachable.

---

# **2. Internal Helpers (Unexported)**

### `.tts_get_api_base()` / `.tts_get_api_key()`

Fetch configured OpenAI-compatible settings.

### `.tts_request()` / `.tts_post_json()` / `.tts_get()`

HTTP helpers for OpenAI-compatible endpoints.

### `.tts_elevenlabs()`

Internal handler for ElevenLabs API (different auth, different endpoints).

---

# **3. Package Options**

```r
options(
  ttsapi.api_base = NULL,        # OpenAI-compatible base URL
  ttsapi.api_key = NULL,         # OpenAI-compatible API key
  ttsapi.elevenlabs_key = NULL,  # ElevenLabs API key (separate)
  ttsapi.timeout = 30
)
```

---

# **4. Backend Architecture**

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

---

# **5. Package Structure**

```
ttsapi/
  DESCRIPTION
  NAMESPACE
  R/
    speech.R               # Main function + .tts_elevenlabs()
    speech_clone.R         # Voice cloning (Chatterbox)
    voice_upload.R         # Voice upload (Chatterbox)
    voices.R
    languages.R
    tts_health.R
    set_tts_base.R
    set_tts_key.R
    set_elevenlabs_key.R
    internal_request.R
    zzz.R
  man/
  tests/
```

---

# **6. Error Handling**

* Never fail silently
* Backend-specific error parsing (OpenAI vs ElevenLabs formats differ)
* Clear instructions when configuration is missing

---

# **7. Future: gpuctl Integration**

GPU container management planned for separate `gpuctl` package.
ttsapi remains a pure HTTP client.

---

# **8. Planned Backends**

Reference: https://github.com/jhudsl/text2speech (abandoned, use as code reference only)

| Backend | Priority | Auth | Notes |
|---------|----------|------|-------|
| **Azure TTS** | Medium | API key + region | REST-based, similar pattern to ElevenLabs |
| **Coqui TTS** | Medium | None (local) | Look for OpenAI-compatible server wrappers |
| **Amazon Polly** | Low | AWS SigV4 | Complex auth, adds aws.signature dep |
| **Google Cloud** | Low | OAuth/service account | Needs googleAuthR ecosystem |

## Azure TTS Implementation Notes

```
Endpoint: https://{region}.tts.speech.microsoft.com/cognitiveservices/v1
Headers:
  Ocp-Apim-Subscription-Key: {api_key}
  Content-Type: application/ssml+xml
  X-Microsoft-OutputFormat: audio-16khz-128kbitrate-mono-mp3
Body: SSML XML
```

Configuration pattern:
```r
set_tts_azure_key(key, region)
# Stores: ttsapi.azure_key, ttsapi.azure_region
```

## Coqui TTS Notes

- Native Coqui requires Python
- Look for: coqui-ai/TTS Docker images with REST API
- Or: OpenAI-compatible wrappers (would just work with set_tts_base())
