% tinyrox says don't edit this manually, but it can't stop you!
\name{chatterbox_voice_upload}
\alias{chatterbox_voice_upload}
\title{Upload Voice to Chatterbox}
\usage{
chatterbox_voice_upload(voice_file, voice_name, port = NULL, timeout = 30)
}
\arguments{
\item{voice_file}{Character. Path to the voice sample file (mp3, wav).}

\item{voice_name}{Character. Name to save the voice as.}

\item{port}{Port for Chatterbox API (default from CHATTERBOX_PORT env var or 7810)}

\item{timeout}{Timeout in seconds (default 30)}
}
\value{
TRUE if upload succeeded, FALSE otherwise. Does not throw errors.
}
\description{
Uploads a voice sample directly to a local Chatterbox instance.
Does not require setting the API base URL first.
}
\examples{
\dontrun{
  # Upload a voice sample
  success <- chatterbox_voice_upload("my_voice.wav", "my-voice")

  if (success) {
    tts("Hello!", voice = "my-voice", backend = "chatterbox")
  }
}
}
