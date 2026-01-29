% tinyrox says don't edit this manually, but it can't stop you!
\name{languages}
\alias{languages}
\title{List Supported Languages}
\usage{
languages()
}
\value{
A character vector or list of supported language codes.
}
\description{
Returns a list of languages supported by the TTS server.
}
\examples{
\dontrun{
set_tts_base("http://localhost:7810")
langs <- languages()
print(langs)
}
}
