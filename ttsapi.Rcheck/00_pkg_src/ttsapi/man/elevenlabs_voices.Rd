\name{elevenlabs_voices}
\alias{elevenlabs_voices}
\title{List ElevenLabs Voices}
\description{Get all voices available in your ElevenLabs account.}
\usage{
elevenlabs_voices()
}
\value{
Data frame with voice_id, name, and category columns.
}
\examples{
\dontrun{
voices <- elevenlabs_voices()
print(voices)
}
}
