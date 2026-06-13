% tinyrox says don't edit this manually, but it can't stop you!
\name{.get_native_chatterbox_model}
\alias{.get_native_chatterbox_model}
\title{Get or create cached native chatterbox model}
\usage{
.get_native_chatterbox_model(device = "cuda", turbo = FALSE)
}
\arguments{
\item{device}{Device to use ("cuda", "cpu", "mps")}

\item{turbo}{Logical. Load the Chatterbox Turbo model instead of the base
model. Base and turbo are cached independently.}
}
\value{
Loaded chatterbox model object
}
\description{
Get or create cached native chatterbox model
}
\keyword{internal}
