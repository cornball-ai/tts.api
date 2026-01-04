# ttsapi

An R client for Text-to-Speech APIs.

Supports multiple backends:

- **OpenAI-compatible**: OpenAI, Chatterbox, LM Studio, OpenWebUI, AnythingLLM
- **ElevenLabs**: Separate API with voice cloning and multilingual models

## Installation

``` r
# install.packages("devtools")
devtools::install_github("cornball-ai/ttsapi")
```

## Backend Setup

### Chatterbox (Local, OpenAI-compatible)

Clone and run [chatterbox-tts-api](https://github.com/travisvn/chatterbox-tts-api):

```bash
git clone https://github.com/travisvn/chatterbox-tts-api.git
cd chatterbox-tts-api

# For newer Nvidia GPUs, for CPU see the above repo
docker build -f docker/Dockerfile.blackwell -t chatterbox-tts:blackwell .

docker run -d \
  --name chatterbox-blackwell \
  --gpus all \
  -p 4123:4123 \
  -v $(pwd)/cache:/cache \
  -v $(pwd)/voices:/voices \
  chatterbox-tts:blackwell
```

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
library(ttsapi)

# For local Chatterbox server (OpenAI-compatible)
set_tts_base("http://localhost:4123")

# For OpenAI
set_tts_base("https://api.openai.com")
set_tts_key(Sys.getenv("OPENAI_API_KEY"))

# For ElevenLabs (separate API key)
set_tts_elevenlabs_key(Sys.getenv("ELEVENLABS_API_KEY"))
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
tts_voices()
```

### Generate speech

``` r
# Basic usage (uses configured base URL)
tts_speech(
  input = "Hello, world!",
  voice = "alloy",
  file = "hello.mp3"
)

# OpenAI with voice instructions
tts_speech(
  input = "Today is a wonderful day to build something people love!",
  voice = "coral",
  file = "speech.mp3",
  backend = "openai",
  model = "gpt-4o-mini-tts",
  instructions = "Speak in a cheerful and positive tone."
)

# Chatterbox with custom parameters
tts_speech(
  input = "Hello with my custom voice!",
  voice = "FatherChristmas",
  file = "speech.wav",
  temperature = 0.9,
  exaggeration = 1.2,
  cfg_weight = 0.3
)

# ElevenLabs (different API, not OpenAI-compatible)
tts_speech(
  input = "Hello from ElevenLabs!",
  voice = "XpDLYThV0yUAFjVTok7m",  # voice ID
  file = "hello_eleven.mp3",
  backend = "elevenlabs",
  model = "eleven_multilingual_v2",
  stability = 0.5,
  similarity_boost = 0.75
)

# Return raw bytes (useful for Shiny)
audio_bytes <- tts_speech(
  input = "Hello!",
  voice = "alloy"
)
```

### Voice management (Chatterbox)

Upload a voice to the library for reuse:

``` r
# Upload once
tts_voice_upload(
  voice_file = "my_voice.wav",
  voice_name = "my-custom-voice"
)

# With language
tts_voice_upload(
  voice_file = "french_voice.wav",
  voice_name = "french-speaker",
  language = "fr"
)

# Use the saved voice by name
tts_speech(
  input = "Hello with my custom voice!",
  voice = "my-custom-voice",
  file = "output.wav"
)

# Or for one-off cloning (uploads and generates in one call)
tts_speech_clone(
  input = "Hello with my custom voice!",
  voice_file = "my_voice.mp3",
  file = "output.wav",
  exaggeration = 0.8
)
```

## Parameters

### `tts_speech()`

| Parameter | Backend | Description |
|-----------|---------|-------------|
| `input` | All | Text to convert to speech |
| `voice` | All | Voice name or ID |
| `file` | All | Output file path (NULL returns raw bytes) |
| `backend` | - | "auto", "chatterbox", "openai", or "elevenlabs" |
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

### `tts_voice_upload()` (Chatterbox)

| Parameter    | Description                     |
|--------------|---------------------------------|
| `voice_file` | Path to voice sample file       |
| `voice_name` | Name to save the voice as       |
| `language`   | Language code (e.g., "en", "fr")|

### `tts_speech_clone()` (Chatterbox)

| Parameter      | Description                             |
|----------------|-----------------------------------------|
| `input`        | Text to convert to speech               |
| `voice_file`   | Path to voice sample file               |
| `file`         | Output file path (NULL returns raw bytes)|
| `exaggeration` | Voice exaggeration                      |
| `temperature`  | Sampling temperature                    |
| `cfg_weight`   | CFG weight                              |
| `speed`        | Playback speed multiplier               |
| `seed`         | Random seed for reproducibility         |

### Configuration functions

| Function | Purpose |
|----------|---------|
| `set_tts_base()` | Set OpenAI-compatible API base URL |
| `set_tts_key()` | Set OpenAI-compatible API key |
| `set_tts_elevenlabs_key()` | Set ElevenLabs API key |

### Other functions

- `tts_voices()` - List available voices (OpenAI-compatible backends)
- `tts_languages()` - List supported languages
- `tts_health()` - Check server health (OpenAI-compatible backends)

## Dependencies

- `curl`
- `jsonlite`
