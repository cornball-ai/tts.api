#' Set ElevenLabs API Key
#'
#' Configure the API key for ElevenLabs TTS backend.
#'
#' @param api_key Character. Your ElevenLabs API key.
#'
#' @export
#' @examples
#' \dontrun{
#' set_elevenlabs_key("your-api-key-here")
#' # Or use environment variable ELEVENLABS_API_KEY
#' }
set_elevenlabs_key <- function(api_key) {
  if (!is.character(api_key) || length(api_key) != 1) {
    stop("'api_key' must be a single character string", call. = FALSE)
  }
  options(tts.elevenlabs_key = api_key)
  invisible(api_key)
}
