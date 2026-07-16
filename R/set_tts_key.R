#' Set the TTS API Key
#'
#' Sets the API key for authentication. Required for cloud services like OpenAI,
#' typically ignored by local servers.
#'
#' @param key Character string. The API key.
#' @return Invisibly returns the previous value.
#' @export
#' @examples
#' set_tts_key("sk-example-key")
#' getOption("tts.api_key")
set_tts_key <- function(key) {
    if (!is.character(key) || length(key) != 1) {
        stop("'key' must be a character string", call. = FALSE)
    }
    old <- getOption("tts.api_key")
    options(tts.api_key = key)
    invisible(old)
}

#' Get the TTS API Key
#'
#' @return Character string with the API key, or NULL if not set.
#' @keywords internal
.tts_get_api_key <- function() {
    getOption("tts.api_key")
}
