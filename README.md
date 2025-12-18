# ttsapi

An R client for OpenAI-compatible Text-to-Speech APIs.

Works with:

- OpenAI `/v1/audio/speech`
- Local servers: Chatterbox, LM Studio, OpenWebUI, AnythingLLM, etc.

## Installation

``` r
# install.packages("devtools")
devtools::install_github("cornball-ai/ttsapi")
```

## Backend Setup

You need either a local TTS server or OpenAI API credentials.

### Chatterbox (Local)

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

## Usage

### Setup

``` r
library(ttsapi)

# For local Chatterbox server
tts_set_api_base("http://localhost:4123")

# For OpenAI
tts_set_api_base("https://api.openai.com")
tts_set_api_key(Sys.getenv("OPENAI_API_KEY"))
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
# Basic usage
tts_speech(
 input = "Hello, world!",
 voice = "alloy",
 file = "hello.mp3"
)

# With Chatterbox-specific parameters
tts_speech(
  input = "Hello with my custom voice!",
  voice = "FatherChristmas",
  file = "speech.wav",
  temperature = 0.9,
  exaggeration = 1.2,
  cfg_weight = 0.3
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

| Parameter         | Description                                            |
|-------------------|--------------------------------------------------------|
| `input`           | Text to convert to speech                              |
| `voice`           | Voice name                                             |
| `file`            | Output file path (NULL returns raw bytes)              |
| `model`           | Model name (optional, often ignored by local servers)  |
| `temperature`     | Sampling temperature                                   |
| `speed`           | Playback speed multiplier                              |
| `exaggeration`    | Chatterbox: voice exaggeration                         |
| `cfg_weight`      | Chatterbox: CFG weight                                 |
| `seed`            | Random seed for reproducibility                        |
| `response_format` | Audio format (inferred from file extension if not set) |

### `tts_voice_upload()`

| Parameter    | Description                     |
|--------------|---------------------------------|
| `voice_file` | Path to voice sample file       |
| `voice_name` | Name to save the voice as       |
| `language`   | Language code (e.g., "en", "fr")|

### `tts_speech_clone()`

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

### Other functions

- `tts_voices()` - List available voices
- `tts_languages()` - List supported languages
- `tts_health()` - Check server health

## Dependencies

- `curl`
- `jsonlite`
