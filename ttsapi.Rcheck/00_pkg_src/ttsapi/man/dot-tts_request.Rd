\name{.tts_request}
\alias{.tts_request}
\title{Make an HTTP Request to the TTS API}
\description{Low-level HTTP wrapper around curl::curl_fetch_memory().}
\usage{
.tts_request(endpoint, method, body, expect_binary)
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
\keyword{internal}
