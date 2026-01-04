#' List Available Voices
#'
#' Returns a list of available voices from the TTS server.
#' Tries the /v1/audio/voices endpoint first, then falls back to /voices.
#'
#' @return A character vector of voice names, or a list/data.frame depending
#'   on the server's response format.
#'
#' @export
#' @examples
#' \dontrun{
#' set_tts_base("http://localhost:4123")
#' v <- voices()
#' print(v)
#' }
voices <- function() {
  # Try standard OpenAI-compatible endpoint first
  result <- tryCatch(
    .tts_get("/v1/audio/voices"),
    error = function(e) NULL
  )

  if (!is.null(result)) {
    # Handle different response formats
    if (is.data.frame(result)) {
      return(result)
    }
    if (is.list(result) && !is.null(result$voices)) {
      return(result$voices)
    }
    if (is.list(result) && !is.null(result$data)) {
      return(result$data)
    }
    return(result)
  }

  # Try alternative /voices endpoint
  result <- tryCatch(
    .tts_get("/voices"),
    error = function(e) NULL
  )

  if (!is.null(result)) {
    return(result)
  }

  # No voice listing available
  message("Voice listing not available from this server.\n",
          "The server may not support voice enumeration.\n",
          "Check your server's documentation for available voices.")
  invisible(NULL)
}
