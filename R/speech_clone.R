#' Generate Speech with Voice Cloning
#'
#' Uploads a voice sample and generates speech in that voice using the
#' /v1/audio/speech/upload endpoint.
#'
#' @param input Character. The text to convert to speech.
#' @param voice_file Character. Path to the voice sample file (mp3, wav, etc.).
#' @param file Character or NULL. Output file path. If NULL, returns raw bytes.
#' @param exaggeration Numeric or NULL. Exaggeration parameter (Chatterbox-specific).
#' @param temperature Numeric or NULL. Sampling temperature for generation.
#' @param cfg_weight Numeric or NULL. CFG weight parameter (Chatterbox-specific).
#' @param speed Numeric or NULL. Speed multiplier for the audio.
#' @param seed Integer or NULL. Random seed for reproducible output.
#'
#' @return If \code{file} is provided, invisibly returns the file path.
#'   If \code{file} is NULL, returns raw audio bytes.
#'
#' @export
#' @examples
#' \dontrun{
#' set_tts_base("http://localhost:4123")
#'
#' # Clone voice and generate speech
#' speech_clone(
#'   input = "Hello with my custom voice!",
#'   voice_file = "my_voice.mp3",
#'   file = "output.wav",
#'   exaggeration = 0.8
#' )
#' }
speech_clone <- function(input,
                             voice_file,
                             file = NULL,
                             exaggeration = NULL,
                             temperature = NULL,
                             cfg_weight = NULL,
                             speed = NULL,
                             seed = NULL) {
  # Validate required parameters
  if (!is.character(input) || length(input) != 1 || nchar(input) == 0) {
    stop("'input' must be a non-empty character string", call. = FALSE)
  }
  if (!is.character(voice_file) || length(voice_file) != 1) {
    stop("'voice_file' must be a character string", call. = FALSE)
  }
  if (!file.exists(voice_file)) {
    stop("Voice file not found: ", voice_file, call. = FALSE)
  }

  # Build URL
  base <- .tts_get_api_base()
  url <- paste0(base, "/v1/audio/speech/upload")

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
    input = input,
    voice_file = curl::form_file(voice_file)
  )

  if (!is.null(exaggeration)) form_data$exaggeration <- as.character(exaggeration)
  if (!is.null(temperature)) form_data$temperature <- as.character(temperature)
  if (!is.null(cfg_weight)) form_data$cfg_weight <- as.character(cfg_weight)
  if (!is.null(speed)) form_data$speed <- as.character(speed)
  if (!is.null(seed)) form_data$seed <- as.character(as.integer(seed))

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

  audio_data <- response$content

  # Return or write to file
  if (is.null(file)) {
    return(audio_data)
  }

  # Write to file
  tryCatch({
    writeBin(audio_data, file)
  }, error = function(e) {
    stop("Failed to write audio to '", file, "': ", e$message, call. = FALSE)
  })

  invisible(file)
}
