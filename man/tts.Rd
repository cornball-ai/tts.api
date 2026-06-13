% tinyrox says don't edit this manually, but it can't stop you!
\name{tts}
\alias{tts}
\title{Generate Speech from Text}
\usage{
tts(input, voice, file = NULL,
    backend = c("auto", "chatterbox", "qwen3", "openai", "elevenlabs"),
    source = c("api", "auto", "package"), model = NULL, temperature = NULL,
    speed = NULL, exaggeration = NULL, cfg_weight = NULL, stability = NULL,
    similarity_boost = NULL, seed = NULL, response_format = NULL,
    instructions = NULL, language = NULL, device = "cuda")
}
\arguments{
\item{input}{Character. The text to convert to speech.}

\item{voice}{Character. The voice to use for synthesis.
For Chatterbox (package or container) and Qwen3: a voice-library name (e.g.
"FatherChristmas") or a path to a reference audio file. The package source
resolves names via \code{\link{voice_file}}; containers resolve them
server-side.
For OpenAI: "alloy", "echo", "fable", "onyx", "nova", "shimmer".
For ElevenLabs: voice ID (e.g., "XpDLYThV0yUAFjVTok7m").}

\item{file}{Character or NULL. Output file path. If NULL, returns raw bytes.}

\item{backend}{Character. The TTS engine: "chatterbox", "qwen3", "openai",
"elevenlabs", or "auto" (defaults to "chatterbox"). This selects *what*
synthesizes; see \code{source} for *where* it runs.}

\item{source}{Character. Where the engine runs: "api" (default) for an HTTP
service (container or hosted package server), "package" for the in-process
R chatterbox package, or "auto" which uses the package for chatterbox when
it is installed and the API otherwise. Only "chatterbox" has a package
source; the other engines are API-only.}

\item{model}{Character or NULL. The sub-model to use.
For Chatterbox package source: "turbo" loads Chatterbox Turbo.
For OpenAI: "tts-1" or "tts-1-hd".
For ElevenLabs: "eleven_multilingual_v2" (default), "eleven_turbo_v2_5", etc.}

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
speak (OpenAI/Qwen3, e.g., "Speak in a cheerful and positive tone.").}

\item{language}{Character or NULL. Language for synthesis (Qwen3-specific).
Options: "English", "Chinese", "Japanese", "Korean", "French", "German",
"Spanish", "Italian", "Portuguese", "Russian".}

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
# Native R chatterbox package, no container (source resolves to "package")
tts("Hello, world!", voice = "FatherChristmas", file = "hello.mp3")

# Chatterbox Turbo via the package
tts("Hello, world!", voice = "FatherChristmas", file = "hello.mp3",
    source = "package", model = "turbo")

# Chatterbox over an HTTP container
set_tts_base("http://troy-g5:7810")
tts("Hello, world!", voice = "FatherChristmas", file = "hello.wav",
    source = "api")

# Using OpenAI TTS
tts("Hello, world!", voice = "nova", file = "hello.mp3", backend = "openai")

# Using ElevenLabs
tts("Hello, world!", voice = "XpDLYThV0yUAFjVTok7m",
       file = "hello.mp3", backend = "elevenlabs")
}
}
