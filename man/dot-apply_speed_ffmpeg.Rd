% tinyrox says don't edit this manually, but it can't stop you!
\name{.apply_speed_ffmpeg}
\alias{.apply_speed_ffmpeg}
\title{Apply speed adjustment using ffmpeg}
\usage{
.apply_speed_ffmpeg(input_file, output_file, speed)
}
\arguments{
\item{input_file}{Character. Source audio file path.}

\item{output_file}{Character. Destination audio file path.}

\item{speed}{Numeric. Speed multiplier.}
}
\value{
Invisibly returns NULL; writes \code{output_file} as a side effect.
}
\description{
Apply speed adjustment using ffmpeg
}
\keyword{internal}
