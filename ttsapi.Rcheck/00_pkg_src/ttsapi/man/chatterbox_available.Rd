\name{chatterbox_available}
\alias{chatterbox_available}
\title{Check if Chatterbox Service is Available}
\description{Quick check if the local Chatterbox TTS API is reachable. Returns TRUE/FALSE without throwing errors.}
\usage{
chatterbox_available(port, timeout)
}
\arguments{
  \item{port}{Port to check (default from CHATTERBOX_PORT env var or 4123)}
  \item{timeout}{Timeout in seconds (default 2)}
}
\value{
TRUE if service is available, FALSE otherwise
}
\examples{
\dontrun{
  if (chatterbox_available()) {
    speech("Hello", voice = "default", backend = "chatterbox")
  }
}
}
