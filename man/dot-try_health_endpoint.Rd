% tinyrox says don't edit this manually, but it can't stop you!
\name{.try_health_endpoint}
\alias{.try_health_endpoint}
\title{Try a single health endpoint}
\usage{
.try_health_endpoint(base, endpoint, timeout)
}
\arguments{
\item{base}{Character. API base URL.}

\item{endpoint}{Character. Health endpoint path to probe.}

\item{timeout}{Numeric. Request timeout in seconds.}
}
\value{
List with elements \code{ok}, \code{status}, and \code{raw}.
}
\description{
Try a single health endpoint
}
\keyword{internal}
