\name{elevenlabs_voice_upload}
\alias{elevenlabs_voice_upload}
\title{Upload Voice to ElevenLabs (Instant Voice Clone)}
\description{Create an instant voice clone on ElevenLabs from audio samples.}
\usage{
elevenlabs_voice_upload(files, name, description, remove_background_noise, labels)
}
\arguments{
  \item{files}{Character vector. Paths to audio files (1-25 files, each up to 10MB).}
  \item{name}{Character. Name for the cloned voice.}
  \item{description}{Character or NULL. Optional description.}
  \item{remove_background_noise}{Logical. Remove background noise from samples. Default FALSE.}
  \item{labels}{Named list or NULL. Optional labels (e.g., list(accent = "british")).}
}
\value{
List with voice_id and name on success.
}
\examples{
\dontrun{
# Clone from a single file
voice <- elevenlabs_voice_upload(
  files = "my_voice.mp3",
  name = "My Clone"
)

# Use the cloned voice
speech("Hello!", voice = voice$voice_id, backend = "elevenlabs")

# Clone from multiple samples
voice <- elevenlabs_voice_upload(
  files = c("sample1.mp3", "sample2.mp3"),
  name = "Better Clone",
  remove_background_noise = TRUE
)
}
}
