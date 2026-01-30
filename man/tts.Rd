% tinyrox says don't edit this manually, but it can't stop you!
\name{tts}
\alias{tts}
\title{Generate Speech from Text}
\usage{
tts(
  input,
  voice,
  file = NULL,
  backend = c("auto", "native", "chatterbox", "qwen3", "openai", "elevenlabs", "fal"),
  model = NULL,
  temperature = NULL,
  speed = NULL,
  exaggeration = NULL,
  cfg_weight = NULL,
  stability = NULL,
  similarity_boost = NULL,
  seed = NULL,
  response_format = NULL,
  instructions = NULL,
  device = "cuda"
)
}
\arguments{
\item{input}{Character. The text to convert to speech.}

\item{voice}{Character. The voice to use for synthesis.
For native: path to voice reference audio file.
For OpenAI: "alloy", "echo", "fable", "onyx", "nova", "shimmer".
For ElevenLabs: voice ID (e.g., "XpDLYThV0yUAFjVTok7m").
For Chatterbox container: custom voice names uploaded via voice_upload().}

\item{file}{Character or NULL. Output file path. If NULL, returns raw bytes.}

\item{backend}{Character. Backend to use: "native" for R chatterbox package,
"chatterbox" for local Chatterbox container, "qwen3" for Qwen3-TTS container,
"openai" for OpenAI TTS API, "elevenlabs" for ElevenLabs API,
"fal" for fal.ai TTS models, or "auto" to use native if available, else
configured API base.}

\item{model}{Character or NULL. The model to use.
For OpenAI: "tts-1" or "tts-1-hd".
For ElevenLabs: "eleven_multilingual_v2" (default), "eleven_turbo_v2_5", etc.
For Chatterbox: optional, often ignored.}

\item{temperature}{Numeric or NULL. Sampling temperature for generation.}

\item{speed}{Numeric or NULL. Speed multiplier for the audio.}

\item{exaggeration}{Numeric or NULL. Exaggeration parameter (Chatterbox-specific).}

\item{cfg_weight}{Numeric or NULL. CFG weight parameter (Chatterbox-specific).}

\item{stability}{Numeric or NULL. Voice stability 0-1 (ElevenLabs-specific). Default 0.5.}

\item{similarity_boost}{Numeric or NULL. Similarity boost 0-1 (ElevenLabs-specific). Default 0.75.}

\item{seed}{Integer or NULL. Random seed for reproducible output.}

\item{response_format}{Character or NULL. Audio format (e.g., "wav", "mp3").
If NULL and file is provided, inferred from file extension.}

\item{instructions}{Character or NULL. Instructions for how the voice should
speak (OpenAI-specific, e.g., "Speak in a cheerful and positive tone.").}

\item{device}{Character. Device for native backend: "cuda", "cpu", or "mps".
Default "cuda".}
}
\value{
If \code{file} is provided, invisibly returns the file path.
  If \code{file} is NULL, returns raw audio bytes (or list for native backend).
}
\description{
Generate audio from text using various TTS backends: native R chatterbox,
local Chatterbox container, OpenAI TTS API, or ElevenLabs API.
}
\examples{
\dontrun{
# Using native R chatterbox package (no container needed)
tts("Hello, world!", voice = "path/to/reference.wav",
       file = "hello.wav", backend = "native")

# Using local Chatterbox container
set_tts_base("http://localhost:7810")
tts("Hello, world!", voice = "FatherChristmas", file = "hello.wav")

# Using OpenAI TTS
tts("Hello, world!", voice = "nova", file = "hello.mp3", backend = "openai")

# Using ElevenLabs
tts("Hello, world!", voice = "XpDLYThV0yUAFjVTok7m",
       file = "hello.mp3", backend = "elevenlabs")
}
}
