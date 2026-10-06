% tinyrox says don't edit this manually, but it can't stop you!
\name{.via_gpuhost}
\alias{.via_gpuhost}
\title{Internal: Synthesize on the fleet's GPU host}
\usage{
.via_gpuhost(
  input,
  voice,
  file = NULL,
  model = NULL,
  temperature = NULL,
  speed = NULL,
  exaggeration = NULL,
  cfg_weight = NULL,
  seed = NULL
)
}
\arguments{
\item{input}{The text.}

\item{voice}{A file, a name in the host's library, or a name in the
local library.}

\item{file}{Output path, or NULL for the WAV bytes.}

\item{model}{The catalog entry, or NULL (see \code{.gpuhost_entry}).}

\item{temperature}{Sampling temperature, or NULL for the entry's own.}

\item{speed}{Speed multiplier applied with ffmpeg, or NULL.}

\item{seed}{Not taken by the entry; reported.}

\item{exaggeration,cfg_weight}{Not taken by the entry; reported.}
}
\value{
\code{file} invisibly, or the WAV as raw bytes.
}
\description{
One \code{/infer} request through gpu.host. The entry takes the text,
the voice and a temperature; it has no CFG, so \code{exaggeration}
and \code{cfg_weight} are not sent, and that is said rather than
swallowed. The reply is PCM, written as WAV; any other extension on
\code{file}, or a speed other than 1, goes through ffmpeg.
}
\keyword{internal}
