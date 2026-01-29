% tinyrox says don't edit this manually, but it can't stop you!
\name{speech_clone}
\alias{speech_clone}
\title{Generate Speech with Voice Cloning}
\usage{
speech_clone(
  input,
  voice_file,
  file = NULL,
  backend = c("auto", "chatterbox", "qwen3"),
  ref_text = NULL,
  x_vector_only = FALSE,
  language = NULL,
  exaggeration = NULL,
  temperature = NULL,
  cfg_weight = NULL,
  speed = NULL,
  seed = NULL
)
}
\arguments{
\item{input}{Character. The text to convert to speech.}

\item{voice_file}{Character. Path to the voice sample file (mp3, wav, etc.).}

\item{file}{Character or NULL. Output file path. If NULL, returns raw bytes.}

\item{backend}{Character. Backend to use: "auto" to detect qwen3 vs chatterbox,
"qwen3" for Qwen3-TTS, or "chatterbox" for Chatterbox.}

\item{ref_text}{Character or NULL. Transcript of the reference audio. Required
by qwen3-tts for high-quality cloning (ICL mode). If NULL and backend requires
it, use \code{x_vector_only = TRUE} for faster but lower-quality cloning.}

\item{x_vector_only}{Logical. If TRUE, use only speaker embedding for cloning
(faster but lower quality). Useful when ref_text is not available.}

\item{language}{Character or NULL. Language for synthesis (qwen3-tts specific).}

\item{exaggeration}{Numeric or NULL. Exaggeration parameter (Chatterbox-specific).}

\item{temperature}{Numeric or NULL. Sampling temperature for generation.}

\item{cfg_weight}{Numeric or NULL. CFG weight parameter (Chatterbox-specific).}

\item{speed}{Numeric or NULL. Speed multiplier for the audio.}

\item{seed}{Integer or NULL. Random seed for reproducible output.}
}
\value{
If \code{file} is provided, invisibly returns the file path.
  If \code{file} is NULL, returns raw audio bytes.
}
\description{
Uploads a voice sample and generates speech in that voice using the
/v1/audio/speech/upload endpoint.
}
\examples{
\dontrun{
set_tts_base("http://localhost:7811")

# Clone voice with transcript (high quality, qwen3-tts)
speech_clone(
  input = "Hello with my custom voice!",
  voice_file = "my_voice.wav",
  ref_text = "This is what I said in the recording.",
  file = "output.wav",
  backend = "qwen3"
)

# Clone voice without transcript (faster, lower quality)
speech_clone(
  input = "Hello with my custom voice!",
  voice_file = "my_voice.wav",
  x_vector_only = TRUE,
  file = "output.wav"
)

# Chatterbox-style cloning
speech_clone(
  input = "Hello with my custom voice!",
  voice_file = "my_voice.mp3",
  file = "output.wav",
  exaggeration = 0.8,
  backend = "chatterbox"
)
}
}
