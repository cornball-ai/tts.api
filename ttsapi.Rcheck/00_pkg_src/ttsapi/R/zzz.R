#' @keywords internal
.onLoad <- function(libname, pkgname) {
  op <- options()
  op_ttsapi <- list(
    ttsapi.api_base = NULL,
    ttsapi.api_key = NULL,
    ttsapi.timeout = 30
  )
  toset <- !(names(op_ttsapi) %in% names(op))
  if (any(toset)) options(op_ttsapi[toset])
  invisible()
}
