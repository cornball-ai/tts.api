% tinyrox says don't edit this manually, but it can't stop you!
\name{qwen3_available}
\alias{qwen3_available}
\title{Check if Qwen3-TTS Service is Available}
\usage{
qwen3_available(port = NULL, timeout = 2)
}
\arguments{
\item{port}{Port to check (default from QWEN3_TTS_PORT env var or 7811)}

\item{timeout}{Timeout in seconds (default 2)}
}
\value{
TRUE if Qwen3-TTS is available, FALSE otherwise
}
\description{
Quick check if Qwen3-TTS API is reachable. Distinguishes from Chatterbox
by checking for the qwen3-specific /v1/audio/speech/design endpoint.
}
\examples{
\dontrun{
  if (qwen3_available()) {
    tts("Hello", voice = "Vivian", backend = "qwen3")
  }
}
}
