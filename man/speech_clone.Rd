\name{speech_clone}
\alias{speech_clone}
\title{Generate Speech with Voice Cloning}
\description{Uploads a voice sample and generates speech in that voice using the /v1/audio/speech/upload endpoint.}
\usage{
speech_clone(input, voice_file, file, exaggeration, temperature, cfg_weight, speed, seed)
}
\arguments{
  \item{input}{Character. The text to convert to speech.}
  \item{voice_file}{Character. Path to the voice sample file (mp3, wav, etc.).}
  \item{file}{Character or NULL. Output file path. If NULL, returns raw bytes.}
  \item{exaggeration}{Numeric or NULL. Exaggeration parameter (Chatterbox-specific).}
  \item{temperature}{Numeric or NULL. Sampling temperature for generation.}
  \item{cfg_weight}{Numeric or NULL. CFG weight parameter (Chatterbox-specific).}
  \item{speed}{Numeric or NULL. Speed multiplier for the audio.}
  \item{seed}{Integer or NULL. Random seed for reproducible output.}
}
\value{
If \\code\{file\} is provided, invisibly returns the file path.
  If \\code\{file\} is NULL, returns raw audio bytes.
}
\examples{
\dontrun{
set_tts_base("http://localhost:4123")

# Clone voice and generate speech
speech_clone(
  input = "Hello with my custom voice!",
  voice_file = "my_voice.mp3",
  file = "output.wav",
  exaggeration = 0.8
)
}
}
