#' Generate Speech from Text
#'
#' Calls the OpenAI-compatible /v1/audio/speech endpoint to generate audio
#' from text input.
#'
#' @param input Character. The text to convert to speech.
#' @param voice Character. The voice to use for synthesis.
#' @param file Character or NULL. Output file path. If NULL, returns raw bytes.
#' @param model Character or NULL. The model to use (optional, many local
#'   servers ignore this).
#' @param temperature Numeric or NULL. Sampling temperature for generation.
#' @param speed Numeric or NULL. Speed multiplier for the audio.
#' @param exaggeration Numeric or NULL. Exaggeration parameter (Chatterbox-specific).
#' @param cfg_weight Numeric or NULL. CFG weight parameter (Chatterbox-specific).
#' @param seed Integer or NULL. Random seed for reproducible output.
#' @param response_format Character or NULL. Audio format (e.g., "wav", "mp3").
#'   If NULL and file is provided, inferred from file extension.
#' @param instructions Character or NULL. Instructions for how the voice should
#'   speak (OpenAI-specific, e.g., "Speak in a cheerful and positive tone.").
#'
#' @return If \code{file} is provided, invisibly returns the file path.
#'   If \code{file} is NULL, returns raw audio bytes.
#'
#' @export
#' @examples
#' \dontrun{
#' # Setup for local Chatterbox server
#' tts_set_api_base("http://localhost:4123")
#'
#' # Generate speech to file
#' tts_speech("Hello, world!", voice = "FatherChristmas", file = "hello.wav")
#'
#' # Get raw bytes (useful for Shiny)
#' audio_bytes <- tts_speech("Hello!", voice = "default")
#'
#' # With additional parameters
#' tts_speech(
#'   input = "This is a test.",
#'   voice = "FatherChristmas",
#'   file = "test.wav",
#'   temperature = 0.9,
#'   exaggeration = 1.2,
#'   cfg_weight = 0.3
#' )
#' }
tts_speech <- function(input,
                       voice,
                       file = NULL,
                       model = NULL,
                       temperature = NULL,
                       speed = NULL,
                       exaggeration = NULL,
                       cfg_weight = NULL,
                       seed = NULL,
                       response_format = NULL,
                       instructions = NULL) {
  # Validate required parameters
 if (!is.character(input) || length(input) != 1 || nchar(input) == 0) {
    stop("'input' must be a non-empty character string", call. = FALSE)
  }
  if (!is.character(voice) || length(voice) != 1 || nchar(voice) == 0) {
    stop("'voice' must be a non-empty character string", call. = FALSE)
  }

  # Build request body
  body <- list(
    input = input,
    voice = voice
  )

  # Add optional parameters if provided
  if (!is.null(model)) body$model <- model
  if (!is.null(temperature)) body$temperature <- temperature
  if (!is.null(speed)) body$speed <- speed
  if (!is.null(exaggeration)) body$exaggeration <- exaggeration
  if (!is.null(cfg_weight)) body$cfg_weight <- cfg_weight
  if (!is.null(seed)) body$seed <- as.integer(seed)
  if (!is.null(instructions)) body$instructions <- instructions

  # Handle response format
  if (!is.null(response_format)) {
    body$response_format <- response_format
  } else if (!is.null(file)) {
    # Infer from file extension
    ext <- tolower(tools::file_ext(file))
    if (nchar(ext) > 0) {
      body$response_format <- ext
    }
  }

  # Make request
  audio_data <- .tts_post_json("/v1/audio/speech", body, expect_binary = TRUE)

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
