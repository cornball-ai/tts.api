% tinyrox says don't edit this manually, but it can't stop you!
\name{speech_design}
\alias{speech_design}
\title{Generate Speech with Designed Voice}
\usage{
speech_design(input, voice_description, file = NULL, language = "English")
}
\arguments{
\item{input}{Character. The text to convert to speech.}

\item{voice_description}{Character. Natural language description of the
desired voice (e.g., "A warm, friendly female voice with a slight British accent").}

\item{file}{Character or NULL. Output file path. If NULL, returns raw bytes.}

\item{language}{Character. Language for synthesis. Supported: Chinese, English,
Japanese, Korean, German, French, Russian, Portuguese, Spanish, Italian.}
}
\value{
If \code{file} is provided, invisibly returns the file path.
  If \code{file} is NULL, returns raw audio bytes.
}
\description{
Create a voice from a natural language description and generate speech.
This endpoint requires the qwen3-tts-api backend with the voice design model.
}
\details{
This function uses the \code{/v1/audio/speech/design} endpoint which is
specific to qwen3-tts-api. It requires the VoiceDesign model to be loaded
(loaded on first use).
}
\examples{
\dontrun{
set_tts_base("http://localhost:7811")

# Generate speech with a custom designed voice
speech_design(
  input = "Hello, I am your AI assistant.",
  voice_description = "A professional male voice, clear and authoritative",
  file = "assistant.wav"
)

# Playful voice
speech_design(
  input = "Let's have some fun!",
  voice_description = "An energetic young female voice, cheerful and playful",
  file = "playful.wav"
)
}
}
