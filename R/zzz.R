#' @keywords internal
.onLoad <- function(
  libname,
  pkgname
) {
  op <- options()
  op_tts.api <- list(
    tts.api_base = NULL,
    tts.api_key = NULL,
    tts.timeout = 30
  )
  toset <- !(names(op_tts.api) %in% names(op))
  if (any(toset)) options(op_tts.api[toset])
  invisible()
}

