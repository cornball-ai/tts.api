% tinyrox says don't edit this manually, but it can't stop you!
\name{voice_library}
\alias{voice_library}
\title{List Voice Files in Library}
\usage{
voice_library(voices_dir = NULL)
}
\arguments{
\item{voices_dir}{Path to voice library directory.
Defaults to \code{TTS_VOICES_DIR} env var, then \code{~/.cornball/voices}.}
}
\value{
Named character vector: names are voice names (filename without
  extension), values are full file paths. Returns empty named character
  vector if directory doesn't exist or contains no voice files.
}
\description{
Scans a directory for voice sample files and returns their paths.
}
\examples{
\dontrun{
voice_library()
voice_library("~/my-voices")
}
}
