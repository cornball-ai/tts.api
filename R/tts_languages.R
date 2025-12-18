#' List Supported Languages
#'
#' Returns a list of languages supported by the TTS server.
#'
#' @return A character vector or list of supported language codes.
#'
#' @export
#' @examples
#' \dontrun{
#' tts_set_api_base("http://localhost:4123")
#' languages <- tts_languages()
#' print(languages)
#' }
tts_languages <- function() {
  result <- tryCatch(
    .tts_get("/languages"),
    error = function(e) {
      message("Language listing not available from this server.\n",
              "Error: ", e$message)
      return(NULL)
    }
  )

  result
}
