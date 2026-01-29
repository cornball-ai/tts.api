% tinyrox says don't edit this manually, but it can't stop you!
\name{.elevenlabs_request}
\alias{.elevenlabs_request}
\title{Make an HTTP Request to the ElevenLabs API}
\usage{
.elevenlabs_request(endpoint, method = "GET", handle = NULL)
}
\arguments{
\item{endpoint}{Character. The API endpoint (e.g., "voices").}

\item{method}{Character. HTTP method ("GET", "POST", or "DELETE").}

\item{handle}{curl handle or NULL. Pre-configured handle for multipart forms.}
}
\value{
curl response object.
}
\description{
Make an HTTP Request to the ElevenLabs API
}
\keyword{internal}
