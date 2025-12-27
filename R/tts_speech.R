#' Generate Speech from Text
#'
#' Calls the OpenAI-compatible /v1/audio/speech endpoint to generate audio
#' from text input. Supports both local Chatterbox server and OpenAI TTS API.
#'
#' @param input Character. The text to convert to speech.
#' @param voice Character. The voice to use for synthesis.
#'   For OpenAI: "alloy", "echo", "fable", "onyx", "nova", "shimmer".
#'   For Chatterbox: custom voice names uploaded via tts_voice_upload().
#' @param file Character or NULL. Output file path. If NULL, returns raw bytes.
#' @param backend Character. Backend to use: "chatterbox" for local server,
#'   "openai" for OpenAI TTS API, or "auto" to use configured API base.
#' @param model Character or NULL. The model to use. For OpenAI: "tts-1" or
#'   "tts-1-hd". For Chatterbox: optional, often ignored.
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
#' # Using local Chatterbox server
#' tts_set_api_base("http://localhost:4123")
#' tts_speech("Hello, world!", voice = "FatherChristmas", file = "hello.wav")
#'
#' # Using OpenAI TTS
#' tts_set_api_key(Sys.getenv("OPENAI_API_KEY"))
#' tts_speech("Hello, world!", voice = "nova", file = "hello.mp3", backend = "openai")
#'
#' # With additional parameters (Chatterbox)
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
                       backend = c("auto", "chatterbox", "openai"),
                       model = NULL,
                       temperature = NULL,
                       speed = NULL,
                       exaggeration = NULL,
                       cfg_weight = NULL,
                       seed = NULL,
                       response_format = NULL,
                       instructions = NULL) {

  backend <- match.arg(backend)

  # Validate required parameters
  if (!is.character(input) || length(input) != 1 || nchar(input) == 0) {
    stop("'input' must be a non-empty character string", call. = FALSE)
  }
  if (!is.character(voice) || length(voice) != 1 || nchar(voice) == 0) {
    stop("'voice' must be a non-empty character string", call. = FALSE)
  }

  # Handle backend switching
  if (backend == "openai") {
    # Save current settings
    old_base <- getOption("ttsapi.api_base")
    old_key <- getOption("ttsapi.api_key")
    on.exit({
      options(ttsapi.api_base = old_base, ttsapi.api_key = old_key)
    }, add = TRUE)

    # Set OpenAI settings
    options(ttsapi.api_base = "https://api.openai.com")
    # Use existing key if already set for OpenAI, or from env var
    if (is.null(old_key) || !grepl("^sk-", old_key %||% "")) {
      api_key <- Sys.getenv("OPENAI_API_KEY")
      if (nchar(api_key) > 0) {
        options(ttsapi.api_key = api_key)
      }
    }

    # Set default model for OpenAI if not specified
    if (is.null(model)) {
      model <- "tts-1"
    }
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
