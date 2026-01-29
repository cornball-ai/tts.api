#' Generate Speech from Text
#'
#' Generate audio from text using various TTS backends: native R chatterbox,
#' local Chatterbox container, OpenAI TTS API, or ElevenLabs API.
#'
#' @param input Character. The text to convert to speech.
#' @param voice Character. The voice to use for synthesis.
#'   For native: path to voice reference audio file.
#'   For OpenAI: "alloy", "echo", "fable", "onyx", "nova", "shimmer".
#'   For ElevenLabs: voice ID (e.g., "XpDLYThV0yUAFjVTok7m").
#'   For Chatterbox container: custom voice names uploaded via voice_upload().
#' @param file Character or NULL. Output file path. If NULL, returns raw bytes.
#' @param backend Character. Backend to use: "native" for R chatterbox package,
#'   "chatterbox" for local Chatterbox container, "qwen3" for Qwen3-TTS container,
#'   "openai" for OpenAI TTS API, "elevenlabs" for ElevenLabs API,
#'   "fal" for fal.ai TTS models, or "auto" to use native if available, else
#'   configured API base.
#' @param model Character or NULL. The model to use.
#'   For OpenAI: "tts-1" or "tts-1-hd".
#'   For ElevenLabs: "eleven_multilingual_v2" (default), "eleven_turbo_v2_5", etc.
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
#' @param device Character. Device for native backend: "cuda", "cpu", or "mps".
#'   Default "cuda".
#'
#' @return If \code{file} is provided, invisibly returns the file path.
#'   If \code{file} is NULL, returns raw audio bytes (or list for native backend).
#'
#' @export
#' @examples
#' \dontrun{
#' # Using native R chatterbox package (no container needed)
#' speech("Hello, world!", voice = "path/to/reference.wav",
#'        file = "hello.wav", backend = "native")
#'
#' # Using local Chatterbox container
#' set_tts_base("http://localhost:7810")
#' speech("Hello, world!", voice = "FatherChristmas", file = "hello.wav")
#'
#' # Using OpenAI TTS
#' speech("Hello, world!", voice = "nova", file = "hello.mp3", backend = "openai")
#'
#' # Using ElevenLabs
#' speech("Hello, world!", voice = "XpDLYThV0yUAFjVTok7m",
#'        file = "hello.mp3", backend = "elevenlabs")
#' }
speech <- function (input, voice, file = NULL,
                    backend = c("auto", "native", "chatterbox", "qwen3", "openai", "elevenlabs", "fal"),
                    model = NULL, temperature = NULL, speed = NULL,
                    exaggeration = NULL, cfg_weight = NULL, stability = NULL,
                    similarity_boost = NULL, seed = NULL,
                    response_format = NULL, instructions = NULL,
                    device = "cuda") {
    backend <- match.arg(backend)

    # Validate required parameters early (before backend dispatch)
    if (!is.character(input) || length(input) != 1 || nchar(input) == 0) {
        stop("'input' must be a non-empty character string", call. = FALSE)
    }
    if (!is.character(voice) || length(voice) != 1 || nchar(voice) == 0) {
        stop("'voice' must be a non-empty character string", call. = FALSE)
    }

    # Auto mode: prefer native if available, else use API
    if (backend == "auto") {
        if (.has_chatterbox()) {
            backend <- "native"
        } else if (!is.null(getOption("tts.api_base"))) {
            backend <- "chatterbox"
        } else {
            stop(
                "No TTS backend available.\n",
                "Either install chatterbox: remotes::install_github('cornball-ai/chatterbox')\n",
                "Or set an API endpoint with set_tts_base()",
                call. = FALSE
            )
        }
    }

    # Dispatch to native chatterbox package
    if (backend == "native") {
        return(.via_chatterbox(
                input = input,
                voice = voice,
                file = file,
                exaggeration = exaggeration,
                cfg_weight = cfg_weight,
                temperature = temperature,
                device = device
            ))
    }

    # Acquire GPU for local container backends
    if (backend == "chatterbox") {
        .gpuctl_acquire("chatterbox")
    }
    if (backend == "qwen3") {
        .gpuctl_acquire("qwen3")
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

    # Dispatch to fal.ai
    if (backend == "fal") {
        return(.tts_fal(
                input = input,
                voice = voice,
                file = file,
                model = model
            ))
    }

    # Handle OpenAI backend switching
    if (backend == "openai") {
        old_base <- getOption("tts.api_base")
        old_key <- getOption("tts.api_key")
        on.exit({
                options(tts.api_base = old_base, tts.api_key = old_key)
            }, add = TRUE)

        options(tts.api_base = "https://api.openai.com")
        if (is.null(old_key) || !grepl("^sk-", old_key %||% "")) {
            api_key <- Sys.getenv("OPENAI_API_KEY")
            if (nchar(api_key) > 0) {
                options(tts.api_key = api_key)
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

    # For Chatterbox with speed adjustment, use ffmpeg post-processing
    needs_speed_adjust <- backend == "chatterbox" && !is.null(speed) && speed != 1.0

    if (needs_speed_adjust) {
        # Write to temp file first
        temp_file <- tempfile(fileext = paste0(".", body$response_format %||% "wav"))
        on.exit(unlink(temp_file), add = TRUE)
        tryCatch({
                writeBin(audio_data, temp_file)
            }, error = function (e) {
                stop("Failed to write temp audio: ", e$message, call. = FALSE)
            })

        # Apply speed adjustment with ffmpeg atempo filter
        # atempo only accepts 0.5-2.0, so chain filters for extreme values
        .apply_speed_ffmpeg(temp_file, file, speed)
    } else {
        tryCatch({
                writeBin(audio_data, file)
            }, error = function (e) {
                stop("Failed to write audio to '", file, "': ", e$message, call. = FALSE)
            })
    }

    invisible(file)
}

#' Apply speed adjustment using ffmpeg
#' @keywords internal
.apply_speed_ffmpeg <- function (input_file, output_file, speed) {
    # atempo filter only accepts 0.5-2.0, so we chain for extreme values
    if (speed < 0.5) {
        # Chain multiple atempo filters for very slow speeds
        atempo_chain <- c()
        remaining <- speed
        while (remaining < 0.5) {
            atempo_chain <- c(atempo_chain, "atempo=0.5")
            remaining <- remaining / 0.5
        }
        atempo_chain <- c(atempo_chain, sprintf("atempo=%.4f", remaining))
        filter <- paste(atempo_chain, collapse = ",")
    } else if (speed > 2.0) {
        # Chain multiple atempo filters for very fast speeds
        atempo_chain <- c()
        remaining <- speed
        while (remaining > 2.0) {
            atempo_chain <- c(atempo_chain, "atempo=2.0")
            remaining <- remaining / 2.0
        }
        atempo_chain <- c(atempo_chain, sprintf("atempo=%.4f", remaining))
        filter <- paste(atempo_chain, collapse = ",")
    } else {
        filter <- sprintf("atempo=%.4f", speed)
    }

    # Run ffmpeg
    result <- system2(
        "ffmpeg",
        c("-y", "-i", shQuote(input_file), "-filter:a", shQuote(filter), shQuote(output_file)),
        stdout = FALSE,
        stderr = FALSE
    )

    if (result != 0) {
        stop("ffmpeg speed adjustment failed with exit code ", result, call. = FALSE)
    }
}

#' ElevenLabs TTS backend
#' @keywords internal
.tts_elevenlabs <- function (input, voice_id, file = NULL, model = NULL,
                             stability = NULL, similarity_boost = NULL) {
    api_key <- Sys.getenv("ELEVENLABS_API_KEY")
    if (api_key == "") {
        api_key <- getOption("tts.elevenlabs_key")
    }
    if (is.null(api_key) || api_key == "") {
        stop("ElevenLabs API key not set. Set ELEVENLABS_API_KEY env var or use set_elevenlabs_key()", call. = FALSE)
    }

    url <- paste0("https://api.elevenlabs.io/v1/text-to-speech/", voice_id)

    body <- list(
        text = input,
        model_id = model %||% "eleven_multilingual_v2",
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
        timeout = getOption("tts.timeout", 120)
    )

    response <- tryCatch(
        curl::curl_fetch_memory(url, handle = h),
        error = function (e) {
            stop("ElevenLabs connection failed: ", e$message, call. = FALSE)
        }
    )

    if (response$status_code >= 400) {
        err_msg <- tryCatch({
                err <- jsonlite::fromJSON(rawToChar(response$content))
                err$detail$message %||% err$detail %||% rawToChar(response$content)
            }, error = function (e) rawToChar(response$content))
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

#' fal.ai TTS backend
#' @keywords internal
.tts_fal <- function(
    input,
    voice = NULL,
    file = NULL,
    model = NULL
) {
    if (!requireNamespace("fal.api", quietly = TRUE)) {
        stop("fal.api package is required for fal backend.\n",
            "Install with: remotes::install_github('cornball-ai/fal.api')",
            call. = FALSE)
    }

    # Default to F5-TTS (good quality, supports voice cloning)
    model <- model %||% "fal-ai/f5-tts"

    # Build request - voice can be a reference audio URL or path
    params <- list(gen_text = input)

    # If voice looks like a file path, upload it
    if (!is.null(voice)) {
        if (file.exists(voice)) {
            params$ref_audio_url <- fal.api::.fal_upload_file(voice)
        } else if (grepl("^https?://", voice)) {
            params$ref_audio_url <- voice
        } else {
            # Assume it's a voice name/ID for models that support named voices
            params$voice <- voice
        }
    }

    # Run TTS
    result <- fal.api::fal_generate(
        model = model,
        gen_text = input,
        ref_audio_url = params$ref_audio_url,
        .timeout = getOption("tts.timeout", 120)
    )

    # Get audio URL from result
    audio_url <- result$audio$url %||% result$audio_url %||% result$url

    if (is.null(audio_url)) {
        stop("fal.ai TTS did not return audio URL", call. = FALSE)
    }

    # Download audio
    h <- curl::new_handle()
    curl::handle_setopt(h, timeout = getOption("tts.timeout", 120))
    response <- curl::curl_fetch_memory(audio_url, handle = h)

    if (response$status_code >= 400) {
        stop("Failed to download audio from fal.ai: HTTP ", response$status_code, call. = FALSE)
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

