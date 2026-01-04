#' Set the TTS API Base URL
#'
#' Sets the base URL for the TTS API. This should be the root URL without
#' trailing slash (e.g., "http://localhost:4123" or "https://api.openai.com").
#'
#' @param url Character string. The base URL for the API.
#' @return Invisibly returns the previous value.
#' @export
#' @examples
#' \dontrun{
#' # For local Chatterbox server
#' set_tts_base("http://localhost:4123")
#'
#' # For OpenAI
#' set_tts_base("https://api.openai.com")
#' }
set_tts_base <- function(url) {
  if (!is.character(url) || length(url) != 1 || nchar(url) == 0) {
    stop("'url' must be a non-empty character string", call. = FALSE)
  }
  # Remove trailing slash if present

  url <- sub("/$", "", url)
  old <- getOption("ttsapi.api_base")
  options(ttsapi.api_base = url)
  invisible(old)
}

#' Get the TTS API Base URL
#'
#' @return Character string with the API base URL.
#' @keywords internal
.tts_get_api_base <- function() {
  base <- getOption("ttsapi.api_base")
  if (is.null(base) || nchar(base) == 0) {
    stop(
      "API base URL not set. Use set_tts_base() to configure it.\n",
      "Example: set_tts_base(\"http://localhost:4123\")",
      call. = FALSE
    )
  }
  base
}
