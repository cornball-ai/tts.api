\name{voices}
\alias{voices}
\title{List Available Voices}
\description{Returns a list of available voices from the TTS server. Tries the /v1/audio/voices endpoint first, then falls back to /voices.}
\usage{
voices()
}
\value{
A character vector of voice names, or a list/data.frame depending
  on the server's response format.
}
\examples{
\dontrun{
set_tts_base("http://localhost:4123")
v <- voices()
print(v)
}
}
