\name{tts_providers}
\alias{tts_providers}
\title{TTS Provider Configurations}
\description{A list of known TTS providers with their default voices and configuration.}
\details{
A named list where each element contains:
\\describe\{
  \\item\{voices\}\{Character vector of default/known voice names, or NULL if dynamic\}
  \\item\{env_var\}\{Name of environment variable for API key, or NULL if not needed\}
  \\item\{base_url\}\{Default API base URL, or NULL\}
\}
}
\examples{
names(tts_providers)
tts_providers[["OpenAI"]]$voices
}
