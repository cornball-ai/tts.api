% tinyrox says don't edit this manually, but it can't stop you!
\name{.tts_request}
\alias{.tts_request}
\title{Make an HTTP Request to the TTS API}
\usage{
.tts_request(endpoint, method = "GET", body = NULL, expect_binary = FALSE)
}
\arguments{
\item{endpoint}{Character. The API endpoint (e.g., "/v1/audio/speech").}

\item{method}{Character. HTTP method ("GET" or "POST").}

\item{body}{List or NULL. Request body for POST requests.}

\item{expect_binary}{Logical. If TRUE, expect binary response (audio data).}
}
\value{
Response content (raw bytes if binary, parsed JSON otherwise).
}
\description{
Low-level HTTP wrapper around curl::curl_fetch_memory().
}
\keyword{internal}
