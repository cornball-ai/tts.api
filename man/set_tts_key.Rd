% tinyrox says don't edit this manually, but it can't stop you!
\name{set_tts_key}
\alias{set_tts_key}
\title{Set the TTS API Key}
\usage{
set_tts_key(key)
}
\arguments{
\item{key}{Character string. The API key.}
}
\value{
Invisibly returns the previous value.
}
\description{
Sets the API key for authentication. Required for cloud services like OpenAI,
typically ignored by local servers.
}
\examples{
set_tts_key("sk-example-key")
getOption("tts.api_key")
}
