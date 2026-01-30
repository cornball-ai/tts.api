# tts.api

An R client for Text-to-Speech APIs.

Supports multiple backends:

- **OpenAI-compatible**: OpenAI, Chatterbox, Qwen3-TTS, LM Studio, OpenWebUI, AnythingLLM
- **ElevenLabs**: Separate API with voice cloning and multilingual models

## Installation

``` r
# From CRAN (once available)
install.packages("tts.api")

# Development version
remotes::install_github("cornball-ai/tts.api")
```

## Backend Setup

### Chatterbox (Local, OpenAI-compatible)

Use the [cornball-ai/chatterbox-tts-api](https://github.com/cornball-ai/chatterbox-tts-api) fork:

```bash
git clone https://github.com/cornball-ai/chatterbox-tts-api.git
cd chatterbox-tts-api

# For newer Nvidia GPUs (Blackwell/50xx series)
docker build -f docker/Dockerfile.blackwell -t chatterbox-tts:blackwell .

docker run -d \
  --name chatterbox-blackwell \
  --gpus all \
  -p 7810:4123 \
  -v $(pwd)/cache:/cache \
  -v $(pwd)/voices:/voices \
  chatterbox-tts:blackwell
```

See [upstream repo](https://github.com/travisvn/chatterbox-tts-api) for CPU and other GPU options.

### Qwen3-TTS (Local, OpenAI-compatible)

Qwen3-TTS supports voice cloning, voice design, and multilingual synthesis.

```bash
docker run -d --gpus all --network=host --name qwen3-tts-api \
  -v ~/.cache/huggingface:/cache \
  -e PORT=7811 \
  -e USE_FLASH_ATTENTION=false \
  qwen3-tts-api:blackwell
```

Built-in voices: Vivian, Serena, Uncle_Fu, Dylan, Eric, Ryan, Aiden, Ono_Anna, Sohee

### OpenAI

1. Create an account at https://platform.openai.com
2. Generate an API key at https://platform.openai.com/api-keys
3. Set the environment variable `OPENAI_API_KEY`

### ElevenLabs

1. Create an account at https://elevenlabs.io
2. Get your API key from https://elevenlabs.io/app/settings/api-keys
3. Set the environment variable `ELEVENLABS_API_KEY`

## Usage

### Setup

``` r
library(tts.api)

# For local Chatterbox server (OpenAI-compatible)
set_tts_base("http://localhost:7810")

# For local Qwen3-TTS server
set_tts_base("http://localhost:7811")

# For OpenAI
set_tts_base("https://api.openai.com")
set_tts_key(Sys.getenv("OPENAI_API_KEY"))

# For ElevenLabs (separate API key)
set_elevenlabs_key(Sys.getenv("ELEVENLABS_API_KEY"))
```

### Check server health

``` r
tts_health()
#> $ok
#> [1] TRUE
#>
#> $status
#> [1] "OK (/health)"
```

### List available voices

``` r
voices()
```

### Generate speech

``` r
# Basic usage (uses configured base URL)
tts(
  input = "Hello, world!",
  voice = "alloy",
  file = "hello.mp3"
)

# OpenAI with voice instructions
tts(
  input = "Today is a wonderful day to build something people love!",
  voice = "coral",
  file = "speech.mp3",
  backend = "openai",
  model = "gpt-4o-mini-tts",
  instructions = "Speak in a cheerful and positive tone."
)

# Chatterbox with custom parameters
tts(
  input = "Hello with my custom voice!",
  voice = "MyCustomVoice",
  file = "speech.wav",
  temperature = 0.9,
  exaggeration = 1.2,
  cfg_weight = 0.3
)

# ElevenLabs (different API, not OpenAI-compatible)
tts(
  input = "Hello from ElevenLabs!",
  voice = "21m00Tcm4TlvDq8ikWAM",  # Rachel voice ID
  file = "hello_eleven.mp3",
  backend = "elevenlabs",
  stability = 0.5,
  similarity_boost = 0.75
)

# Qwen3-TTS with built-in voice
tts(
  input = "Hello from Qwen3!",
  voice = "Vivian",
  file = "hello_qwen3.wav",
  backend = "qwen3"
)

# Return raw bytes (useful for Shiny)
audio_bytes <- tts(
  input = "Hello!",
  voice = "alloy"
)
```

### Voice cloning (Qwen3-TTS)

``` r
# Fast mode (x-vector only, no transcript needed)
speech_clone(
  input = "Hello in my cloned voice!",
  voice_file = "reference.wav",
  x_vector_only = TRUE,
  file = "cloned.wav",
  backend = "qwen3"
)

# High quality mode (with transcript)
speech_clone(
  input = "Hello in my cloned voice!",
  voice_file = "reference.wav",
  ref_text = "This is what I said in the recording.",
  file = "cloned.wav",
  backend = "qwen3"
)
```

### Voice design (Qwen3-TTS only)

Create a custom voice from a natural language description:

``` r
speech_design(
  input = "Hello, I am your AI assistant.",
  voice_description = "A warm, professional female voice with a slight British accent",
  file = "designed_voice.wav"
)
```

### Voice management (Chatterbox)

Upload a voice to the library for reuse:

``` r
# Upload once
voice_upload(
  voice_file = "my_voice.wav",
  voice_name = "my-custom-voice"
)

# With language
voice_upload(
  voice_file = "french_voice.wav",
  voice_name = "french-speaker",
  language = "fr"
)

# Use the saved voice by name
tts(
  input = "Hello with my custom voice!",
  voice = "my-custom-voice",
  file = "output.wav"
)

# Or for one-off cloning (uploads and generates in one call)
speech_clone(
  input = "Hello with my custom voice!",
  voice_file = "my_voice.mp3",
  file = "output.wav",
  exaggeration = 0.8
)
```

## Parameters

### `tts()`

| Parameter | Backend | Description |
|-----------|---------|-------------|
| `input` | All | Text to convert to speech |
| `voice` | All | Voice name or ID |
| `file` | All | Output file path (NULL returns raw bytes) |
| `backend` | - | "auto", "native", "chatterbox", "qwen3", "openai", "elevenlabs", or "fal" |
| `model` | OpenAI, ElevenLabs | Model name |
| `instructions` | OpenAI | Voice style instructions |
| `temperature` | Chatterbox | Sampling temperature |
| `speed` | OpenAI, Chatterbox | Playback speed multiplier |
| `exaggeration` | Chatterbox | Voice exaggeration |
| `cfg_weight` | Chatterbox | CFG weight |
| `stability` | ElevenLabs | Voice stability (0-1) |
| `similarity_boost` | ElevenLabs | Similarity boost (0-1) |
| `seed` | Chatterbox | Random seed for reproducibility |
| `response_format` | OpenAI, Chatterbox | Audio format |

### `voice_upload()` (Chatterbox)

| Parameter    | Description                     |
|--------------|---------------------------------|
| `voice_file` | Path to voice sample file       |
| `voice_name` | Name to save the voice as       |
| `language`   | Language code (e.g., "en", "fr")|

### `speech_clone()` (Chatterbox/Qwen3-TTS)

| Parameter      | Backend | Description                             |
|----------------|---------|----------------------------------------|
| `input`        | All | Text to convert to speech               |
| `voice_file`   | All | Path to voice sample file               |
| `file`         | All | Output file path (NULL returns raw bytes)|
| `backend`      | - | "auto", "chatterbox", or "qwen3" |
| `ref_text`     | Qwen3 | Transcript of reference audio (high quality) |
| `x_vector_only`| Qwen3 | Use only speaker embedding (faster) |
| `language`     | Qwen3 | Language for synthesis |
| `exaggeration` | Chatterbox | Voice exaggeration                      |
| `temperature`  | All | Sampling temperature                    |
| `cfg_weight`   | Chatterbox | CFG weight                              |
| `speed`        | All | Playback speed multiplier               |
| `seed`         | All | Random seed for reproducibility         |

### `speech_design()` (Qwen3-TTS only)

| Parameter      | Description                             |
|----------------|-----------------------------------------|
| `input`        | Text to convert to speech               |
| `voice_description` | Natural language description of desired voice |
| `file`         | Output file path (NULL returns raw bytes)|
| `language`     | Language for synthesis (default "English") |

### Configuration functions

| Function | Purpose |
|----------|---------|
| `set_tts_base()` | Set OpenAI-compatible API base URL |
| `set_tts_key()` | Set OpenAI-compatible API key |
| `set_elevenlabs_key()` | Set ElevenLabs API key |

### Health checks

| Function | Description |
|----------|-------------|
| `tts_health()` | Check server health (uses configured base URL) |
| `chatterbox_available()` | Check if Chatterbox is running on port 7810 |
| `qwen3_available()` | Check if Qwen3-TTS is running on port 7811 |

### Other functions

- `voices()` - List available voices (OpenAI-compatible backends)
- `languages()` - List supported languages

## Dependencies

- `curl`
- `jsonlite`
