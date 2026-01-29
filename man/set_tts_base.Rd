% tinyrox says don't edit this manually, but it can't stop you!
\name{set_tts_base}
\alias{set_tts_base}
\title{Set the TTS API Base URL}
\usage{
set_tts_base(url)
}
\arguments{
\item{url}{Character string. The base URL for the API.}
}
\value{
Invisibly returns the previous value.
}
\description{
Sets the base URL for the TTS API. This should be the root URL without
trailing slash (e.g., "http://localhost:7810" or "https://api.openai.com").
}
\examples{
\dontrun{
# For local Chatterbox server
set_tts_base("http://localhost:7810")

# For OpenAI
set_tts_base("https://api.openai.com")
}
}
