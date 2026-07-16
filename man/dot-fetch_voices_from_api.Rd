% tinyrox says don't edit this manually, but it can't stop you!
\name{.fetch_voices_from_api}
\alias{.fetch_voices_from_api}
\title{Fetch voices from API}
\usage{
.fetch_voices_from_api(base_url, timeout = 2)
}
\arguments{
\item{base_url}{Character. API base URL.}

\item{timeout}{Numeric. Request timeout in seconds.}
}
\value{
Character vector of voice names, or NULL if unavailable.
}
\description{
Fetch voices from API
}
\keyword{internal}
