% tinyrox says don't edit this manually, but it can't stop you!
\name{voice_file}
\alias{voice_file}
\title{Resolve Voice Name to File Path}
\usage{
voice_file(voice_name, voices_dir = NULL)
}
\arguments{
\item{voice_name}{Character. Name of the voice to find.}

\item{voices_dir}{Path to voice library directory (see \code{\link{voice_library}}).}
}
\value{
Character string: full path to the voice file.
  Stops with an error if the voice is not found.
}
\description{
Looks up a voice by name in the voice library directory.
Case-insensitive matching is attempted if exact match fails.
}
\examples{
\dontrun{
voice_file("BigCasey")
voice_file("delicatecasey")
}
}
