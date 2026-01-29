% tinyrox says don't edit this manually, but it can't stop you!
\name{tts_voices}
\alias{tts_voices}
\title{Get Voices for a TTS Provider}
\usage{
tts_voices(provider, base_url = NULL, timeout = 2)
}
\arguments{
\item{provider}{Character string naming the provider (e.g., "OpenAI", "Chatterbox (Local)")}

\item{base_url}{Optional base URL override for the provider's API}

\item{timeout}{Timeout in seconds for API requests (default 2)}
}
\value{
Character vector of voice names
}
\description{
Returns available voices for a given provider. Attempts to fetch dynamically
from the API first, falls back to static list if unavailable.
}
\examples{
\dontrun{
tts_voices("OpenAI")
tts_voices("Chatterbox (Local)")
}
}
