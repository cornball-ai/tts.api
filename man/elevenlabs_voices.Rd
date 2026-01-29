% tinyrox says don't edit this manually, but it can't stop you!
\name{elevenlabs_voices}
\alias{elevenlabs_voices}
\title{List ElevenLabs Voices}
\usage{
elevenlabs_voices()
}
\value{
Data frame with voice_id, name, and category columns.
}
\description{
Get all voices available in your ElevenLabs account.
}
\examples{
\dontrun{
voices <- elevenlabs_voices()
print(voices)
}
}
