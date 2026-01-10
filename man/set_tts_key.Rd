\name{set_tts_key}
\alias{set_tts_key}
\title{Set the TTS API Key}
\description{Sets the API key for authentication. Required for cloud services like OpenAI, typically ignored by local servers.}
\usage{
set_tts_key(key)
}
\arguments{
  \item{key}{Character string. The API key.}
}
\value{
Invisibly returns the previous value.
}
\examples{
\dontrun{
set_tts_key(Sys.getenv("OPENAI_API_KEY"))
}
}
