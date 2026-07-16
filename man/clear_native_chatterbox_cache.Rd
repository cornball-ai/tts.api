% tinyrox says don't edit this manually, but it can't stop you!
\name{clear_native_chatterbox_cache}
\alias{clear_native_chatterbox_cache}
\title{Clear native chatterbox model cache}
\usage{
clear_native_chatterbox_cache()
}
\value{
Invisibly returns NULL, called for its side effect.
}
\description{
Removes cached native chatterbox models from memory. Call this to free GPU/RAM
after batch processing is complete.
}
\examples{
\dontrun{
clear_native_chatterbox_cache()
}
}
