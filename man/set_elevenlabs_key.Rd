% tinyrox says don't edit this manually, but it can't stop you!
\name{set_elevenlabs_key}
\alias{set_elevenlabs_key}
\title{Set ElevenLabs API Key}
\usage{
set_elevenlabs_key(api_key)
}
\arguments{
\item{api_key}{Character. Your ElevenLabs API key. Alternatively, set the
ELEVENLABS_API_KEY environment variable.}
}
\value{
Invisibly returns the API key.
}
\description{
Configure the API key for ElevenLabs TTS backend.
}
\examples{
set_elevenlabs_key("example-api-key")
getOption("tts.elevenlabs_key")
}
