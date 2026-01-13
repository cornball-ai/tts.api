\name{languages}
\alias{languages}
\title{List Supported Languages}
\description{Returns a list of languages supported by the TTS server.}
\usage{
languages()
}
\value{
A character vector or list of supported language codes.
}
\examples{
\dontrun{
set_tts_base("http://localhost:4123")
langs <- languages()
print(langs)
}
}
