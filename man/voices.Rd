% tinyrox says don't edit this manually, but it can't stop you!
\name{voices}
\alias{voices}
\title{List Available Voices}
\usage{
voices()
}
\value{
A character vector of voice names, or a list/data.frame depending
  on the server's response format.
}
\description{
Returns a list of available voices from the TTS server.
Tries the /v1/audio/voices endpoint first, then falls back to /voices.
}
\examples{
\dontrun{
set_tts_base("http://localhost:7810")
v <- voices()
print(v)
}
}
