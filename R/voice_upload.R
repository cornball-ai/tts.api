#' Upload Voice to Library
#'
#' Uploads a voice sample to the server's voice library for reuse.
#' Once uploaded, the voice can be used by name in speech().
#'
#' @param voice_file Character. Path to the voice sample file (mp3, wav, etc.).
#' @param voice_name Character. Name to save the voice as.
#' @param language Character or NULL. Language code (e.g., "en", "fr", "es").
#'
#' @return Invisibly returns the response from the server.
#'
#' @export
#' @examples
#' \dontrun{
#' set_tts_base("http://localhost:4123")
#'
#' # Upload a voice
#' voice_upload(
#'   voice_file = "my_voice.wav",
#'   voice_name = "my-custom-voice"
#' )
#'
#' # Upload with language
#' voice_upload(
#'   voice_file = "french_voice.wav",
#'   voice_name = "french-speaker",
#'   language = "fr"
#' )
#'
#' # Then use it by name
#' speech(
#'   input = "Hello with my custom voice!",
#'   voice = "my-custom-voice",
#'   file = "output.wav"
#' )
#' }
voice_upload <- function(voice_file, voice_name, language = NULL) {
  # Validate parameters
  if (!is.character(voice_file) || length(voice_file) != 1) {
    stop("'voice_file' must be a character string", call. = FALSE)
  }
  if (!file.exists(voice_file)) {
    stop("Voice file not found: ", voice_file, call. = FALSE)
  }
  if (!is.character(voice_name) || length(voice_name) != 1 || nchar(voice_name) == 0) {
    stop("'voice_name' must be a non-empty character string", call. = FALSE)
  }

  # Build URL
  base <- .tts_get_api_base()
  url <- paste0(base, "/voices")

  # Create form data
  h <- curl::new_handle()
  timeout <- getOption("ttsapi.timeout", 30)
  curl::handle_setopt(h, timeout = timeout)

  # Add authorization header if needed
  api_key <- .tts_get_api_key()
  if (!is.null(api_key) && nchar(api_key) > 0) {
    curl::handle_setheaders(h, "Authorization" = paste("Bearer", api_key))
  }

  # Build multipart form
  form_data <- list(
    voice_file = curl::form_file(voice_file),
    voice_name = voice_name
  )

  if (!is.null(language)) {
    form_data$language <- language
  }

  curl::handle_setform(h, .list = form_data)

  # Make request
  response <- tryCatch(
    curl::curl_fetch_memory(url, handle = h),
    error = function(e) {
      stop("Connection failed: ", e$message, call. = FALSE)
    }
  )

  # Check HTTP status
  status <- response$status_code
  if (status >= 400) {
    err_msg <- tryCatch({
      err <- jsonlite::fromJSON(rawToChar(response$content))
      if (!is.null(err$error$message)) {
        err$error$message
      } else if (!is.null(err$error)) {
        as.character(err$error)
      } else if (!is.null(err$detail)) {
        as.character(err$detail)
      } else {
        rawToChar(response$content)
      }
    }, error = function(e) {
      rawToChar(response$content)
    })
    stop("API error (", status, "): ", err_msg, call. = FALSE)
  }

  # Parse response
  result <- tryCatch(
    jsonlite::fromJSON(rawToChar(response$content)),
    error = function(e) rawToChar(response$content)
  )

  message("Voice '", voice_name, "' uploaded successfully")
  invisible(result)
}
