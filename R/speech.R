#' Generate Speech from Text
#'
#' Generate audio from text using various TTS backends: local Chatterbox server,
#' OpenAI TTS API, or ElevenLabs API.
#'
#' @param input Character. The text to convert to speech.
#' @param voice Character. The voice to use for synthesis.
#'   For OpenAI: "alloy", "echo", "fable", "onyx", "nova", "shimmer".
#'   For ElevenLabs: voice ID (e.g., "XpDLYThV0yUAFjVTok7m").
#'   For Chatterbox: custom voice names uploaded via voice_upload().
#' @param file Character or NULL. Output file path. If NULL, returns raw bytes.
#' @param backend Character. Backend to use: "chatterbox" for local server,
#'   "openai" for OpenAI TTS API, "elevenlabs" for ElevenLabs API,
#'   or "auto" to use configured API base.
#' @param model Character or NULL. The model to use.
#'   For OpenAI: "tts-1" or "tts-1-hd".
#'   For ElevenLabs: "eleven_monolingual_v1", "eleven_multilingual_v2", etc.
#'   For Chatterbox: optional, often ignored.
#' @param temperature Numeric or NULL. Sampling temperature for generation.
#' @param speed Numeric or NULL. Speed multiplier for the audio.
#' @param exaggeration Numeric or NULL. Exaggeration parameter (Chatterbox-specific).
#' @param cfg_weight Numeric or NULL. CFG weight parameter (Chatterbox-specific).
#' @param stability Numeric or NULL. Voice stability 0-1 (ElevenLabs-specific). Default 0.5.
#' @param similarity_boost Numeric or NULL. Similarity boost 0-1 (ElevenLabs-specific). Default 0.75.
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
#' set_tts_base("http://localhost:4123")
#' speech("Hello, world!", voice = "FatherChristmas", file = "hello.wav")
#'
#' # Using OpenAI TTS
#' speech("Hello, world!", voice = "nova", file = "hello.mp3", backend = "openai")
#'
#' # Using ElevenLabs
#' speech("Hello, world!", voice = "XpDLYThV0yUAFjVTok7m",
#'        file = "hello.mp3", backend = "elevenlabs")
#' }
speech <- function(input,
                       voice,
                       file = NULL,
                       backend = c("auto", "chatterbox", "openai", "elevenlabs"),
                       model = NULL,
                       temperature = NULL,
                       speed = NULL,
                       exaggeration = NULL,
                       cfg_weight = NULL,
                       stability = NULL,
                       similarity_boost = NULL,
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

  # Dispatch to ElevenLabs (different API structure)
  if (backend == "elevenlabs") {
    return(.tts_elevenlabs(
      input = input,
      voice_id = voice,
      file = file,
      model = model,
      stability = stability,
      similarity_boost = similarity_boost
    ))
  }

  # Handle OpenAI backend switching
  if (backend == "openai") {
    old_base <- getOption("ttsapi.api_base")
    old_key <- getOption("ttsapi.api_key")
    on.exit({
      options(ttsapi.api_base = old_base, ttsapi.api_key = old_key)
    }, add = TRUE)

    options(ttsapi.api_base = "https://api.openai.com")
    if (is.null(old_key) || !grepl("^sk-", old_key %||% "")) {
      api_key <- Sys.getenv("OPENAI_API_KEY")
      if (nchar(api_key) > 0) {
        options(ttsapi.api_key = api_key)
      }
    }

    if (is.null(model)) {
      model <- "tts-1"
    }
  }

  # Build request body (OpenAI-compatible: Chatterbox, OpenAI)
  body <- list(
    input = input,
    voice = voice
  )

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

  tryCatch({
    writeBin(audio_data, file)
  }, error = function(e) {
    stop("Failed to write audio to '", file, "': ", e$message, call. = FALSE)
  })

  invisible(file)
}


#' ElevenLabs TTS backend
#' @keywords internal
.tts_elevenlabs <- function(input, voice_id, file = NULL, model = NULL,
                            stability = NULL, similarity_boost = NULL) {

  api_key <- Sys.getenv("ELEVENLABS_API_KEY")
  if (api_key == "") {
    api_key <- getOption("ttsapi.elevenlabs_key")
  }
  if (is.null(api_key) || api_key == "") {
    stop("ElevenLabs API key not set. Set ELEVENLABS_API_KEY env var or use set_elevenlabs_key()", call. = FALSE)
  }

  url <- paste0("https://api.elevenlabs.io/v1/text-to-speech/", voice_id)

  body <- list(
    text = input,
    model_id = model %||% "eleven_monolingual_v1",
    voice_settings = list(
      stability = stability %||% 0.5,
      similarity_boost = similarity_boost %||% 0.75
    )
  )

  h <- curl::new_handle()
  curl::handle_setheaders(h,
    "xi-api-key" = api_key,
    "Content-Type" = "application/json",
    "Accept" = "audio/mpeg"
  )
  curl::handle_setopt(h,
    post = TRUE,
    postfields = jsonlite::toJSON(body, auto_unbox = TRUE),
    timeout = getOption("ttsapi.timeout", 120)
  )

  response <- tryCatch(
    curl::curl_fetch_memory(url, handle = h),
    error = function(e) {
      stop("ElevenLabs connection failed: ", e$message, call. = FALSE)
    }
  )

  if (response$status_code >= 400) {
    err_msg <- tryCatch({
      err <- jsonlite::fromJSON(rawToChar(response$content))
      err$detail$message %||% err$detail %||% rawToChar(response$content)
    }, error = function(e) rawToChar(response$content))
    stop("ElevenLabs API error (", response$status_code, "): ", err_msg, call. = FALSE)
  }

  audio_data <- response$content

  if (is.null(file)) {
    return(audio_data)
  }

  tryCatch({
    writeBin(audio_data, file)
  }, error = function(e) {
    stop("Failed to write audio to '", file, "': ", e$message, call. = FALSE)
  })

  invisible(file)
}
