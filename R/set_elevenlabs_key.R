#' Set ElevenLabs API Key
#'
#' Configure the API key for ElevenLabs TTS backend.
#'
#' @param api_key Character. Your ElevenLabs API key. Alternatively, set the
#'   ELEVENLABS_API_KEY environment variable.
#'
#' @return Invisibly returns the API key.
#' @export
#' @examples
#' set_elevenlabs_key("example-api-key")
#' getOption("tts.elevenlabs_key")
set_elevenlabs_key <- function(api_key) {
    if (!is.character(api_key) || length(api_key) != 1) {
        stop("'api_key' must be a single character string", call. = FALSE)
    }
    options(tts.elevenlabs_key = api_key)
    invisible(api_key)
}
