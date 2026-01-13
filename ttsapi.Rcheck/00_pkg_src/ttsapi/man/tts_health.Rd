\name{tts_health}
\alias{tts_health}
\title{Check TTS API Health}
\description{Checks whether the TTS backend is reachable by trying common health endpoints.}
\usage{
tts_health()
}
\value{
A list with components:
\\describe\{
  \\item\{ok\}\{Logical. TRUE if the server is reachable.\}
  \\item\{status\}\{Character. A human-readable status message.\}
  \\item\{raw\}\{The raw response from the server (if any).\}
\}
}
\examples{
\dontrun{
set_tts_base("http://localhost:4123")
h <- tts_health()
if (h$ok) {
  message("Server is ready!")
}
}
}
