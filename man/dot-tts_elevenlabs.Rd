% tinyrox says don't edit this manually, but it can't stop you!
\name{.tts_elevenlabs}
\alias{.tts_elevenlabs}
\title{ElevenLabs TTS backend}
\usage{
.tts_elevenlabs(input, voice_id, file = NULL, model = NULL, stability = NULL,
                similarity_boost = NULL)
}
\arguments{
\item{input}{Character. Text to convert to speech.}

\item{voice_id}{Character. ElevenLabs voice ID.}

\item{file}{Character or NULL. Output file path.}

\item{model}{Character or NULL. ElevenLabs model ID.}

\item{stability}{Numeric or NULL. Voice stability (0-1).}

\item{similarity_boost}{Numeric or NULL. Similarity boost (0-1).}
}
\value{
If \code{file} is provided, invisibly returns the file path;
  otherwise returns raw audio bytes.
}
\description{
ElevenLabs TTS backend
}
\keyword{internal}
