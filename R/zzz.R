#' @keywords internal
.onLoad <- function(libname, pkgname) {
  op <- options()
  op_ttsapi <- list(
    tts.api_base = NULL,
    tts.api_key = NULL,
    tts.timeout = 30
  )
  toset <- !(names(op_ttsapi) %in% names(op))
  if (any(toset)) options(op_ttsapi[toset])
  invisible()
}
