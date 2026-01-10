\name{.tts_post_json}
\alias{.tts_post_json}
\title{POST JSON to the TTS API}
\description{POST JSON to the TTS API}
\usage{
.tts_post_json(endpoint, body, expect_binary)
}
\arguments{
  \item{endpoint}{Character. The API endpoint.}
  \item{body}{List. Request body.}
  \item{expect_binary}{Logical. If TRUE, expect binary response.}
}
\value{
Response content.
}
\keyword{internal}
