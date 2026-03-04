% tinyrox says don't edit this manually, but it can't stop you!
\name{voice_ensure}
\alias{voice_ensure}
\title{Ensure Voice is Available on TTS Server}
\usage{
voice_ensure(voice_name, voices_dir = NULL)
}
\arguments{
\item{voice_name}{Character. Name of the voice.}

\item{voices_dir}{Path to voice library directory (see \code{\link{voice_library}}).}
}
\value{
Invisible \code{TRUE} if the voice is available (already present or
  successfully uploaded).
}
\description{
Checks if a voice exists on the current TTS server. If not, finds the
voice file in the library and uploads it.
}
\examples{
\dontrun{
set_tts_base("http://localhost:4123")
voice_ensure("BigCasey")
tts("Hello!", voice = "BigCasey", file = "out.mp3")
}
}
