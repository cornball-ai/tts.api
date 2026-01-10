\name{chatterbox_voice_upload}
\alias{chatterbox_voice_upload}
\title{Upload Voice to Chatterbox}
\description{Uploads a voice sample directly to a local Chatterbox instance. Does not require setting the API base URL first.}
\usage{
chatterbox_voice_upload(voice_file, voice_name, port, timeout)
}
\arguments{
  \item{voice_file}{Character. Path to the voice sample file (mp3, wav).}
  \item{voice_name}{Character. Name to save the voice as.}
  \item{port}{Port for Chatterbox API (default from CHATTERBOX_PORT env var or 4123)}
  \item{timeout}{Timeout in seconds (default 30)}
}
\value{
TRUE if upload succeeded, FALSE otherwise. Does not throw errors.
}
\examples{
\dontrun{
  # Upload a voice sample
  success <- chatterbox_voice_upload("my_voice.wav", "my-voice")

  if (success) {
    speech("Hello!", voice = "my-voice", backend = "chatterbox")
  }
}
}
