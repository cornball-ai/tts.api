% tinyrox says don't edit this manually, but it can't stop you!
\name{.via_chatterbox}
\alias{.via_chatterbox}
\title{Internal: Generate speech via native chatterbox package}
\usage{
.via_chatterbox(input, voice, file = NULL, exaggeration = NULL,
                cfg_weight = NULL, temperature = NULL, device = "cuda",
                turbo = FALSE)
}
\arguments{
\item{input}{Character. Text to convert to speech.}

\item{voice}{Character. Path to voice reference audio file.}

\item{file}{Character or NULL. Output file path.}

\item{exaggeration}{Numeric or NULL. Exaggeration parameter.}

\item{cfg_weight}{Numeric or NULL. CFG weight parameter.}

\item{temperature}{Numeric or NULL. Sampling temperature.}

\item{device}{Character. Device to use ("cuda", "cpu").}

\item{turbo}{Logical. Use the Chatterbox Turbo model.}
}
\value{
If file is NULL, returns list with audio and sample_rate.
  If file is provided, writes to file and returns file path invisibly.
}
\description{
Uses the cornball-ai/chatterbox native R torch implementation.
}
\keyword{internal}
