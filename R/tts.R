#' Generate Speech from Text
#'
#' Generate audio from text using various TTS backends: native R chatterbox,
#' local Chatterbox container, OpenAI TTS API, or ElevenLabs API.
#'
#' @param input Character. The text to convert to speech.
#' @param voice Character. The voice to use for synthesis.
#'   For Chatterbox (package or container) and Qwen3: a voice-library name (e.g.
#'   "FatherChristmas") or a path to a reference audio file. The package source
#'   resolves names via \code{\link{voice_file}}; containers resolve them
#'   server-side.
#'   For OpenAI: "alloy", "echo", "fable", "onyx", "nova", "shimmer".
#'   For ElevenLabs: voice ID (e.g., "XpDLYThV0yUAFjVTok7m").
#' @param file Character or NULL. Output file path. If NULL, returns raw bytes.
#' @param backend Character. The TTS engine: "chatterbox", "qwen3", "openai",
#'   "elevenlabs", or "auto" (defaults to "chatterbox"). This selects *what*
#'   synthesizes; see \code{source} for *where* it runs.
#' @param source Character. Where the engine runs: "api" (default) for an HTTP
#'   service (container or hosted package server), "package" for the in-process
#'   R chatterbox package, or "auto" which uses the package for chatterbox when
#'   it is installed and the API otherwise. Only "chatterbox" has a package
#'   source; the other engines are API-only.
#' @param model Character or NULL. The sub-model to use.
#'   For Chatterbox package source: "turbo" loads Chatterbox Turbo.
#'   For OpenAI: "tts-1" or "tts-1-hd".
#'   For ElevenLabs: "eleven_multilingual_v2" (default), "eleven_turbo_v2_5", etc.
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
#'   speak (OpenAI/Qwen3, e.g., "Speak in a cheerful and positive tone.").
#' @param language Character or NULL. Language for synthesis (Qwen3-specific).
#'   Options: "English", "Chinese", "Japanese", "Korean", "French", "German",
#'   "Spanish", "Italian", "Portuguese", "Russian".
#' @param device Character. Device for native backend: "cuda", "cpu", or "mps".
#'   Default "cuda".
#'
#' @return If \code{file} is provided, invisibly returns the file path.
#'   If \code{file} is NULL, returns raw audio bytes (or list for native backend).
#'
#' @export
#' @examples
#' \dontrun{
#' # Native R chatterbox package, no container (source resolves to "package")
#' tts("Hello, world!", voice = "FatherChristmas", file = "hello.mp3")
#'
#' # Chatterbox Turbo via the package
#' tts("Hello, world!", voice = "FatherChristmas", file = "hello.mp3",
#'     source = "package", model = "turbo")
#'
#' # Chatterbox over an HTTP container
#' set_tts_base("http://troy-g5:7810")
#' tts("Hello, world!", voice = "FatherChristmas", file = "hello.wav",
#'     source = "api")
#'
#' # Using OpenAI TTS
#' tts("Hello, world!", voice = "nova", file = "hello.mp3", backend = "openai")
#'
#' # Using ElevenLabs
#' tts("Hello, world!", voice = "XpDLYThV0yUAFjVTok7m",
#'        file = "hello.mp3", backend = "elevenlabs")
#' }
tts <- function (input, voice, file = NULL,
                    backend = c("auto", "chatterbox", "qwen3", "openai", "elevenlabs"),
                    source = c("api", "auto", "package"),
                    model = NULL, temperature = NULL, speed = NULL,
                    exaggeration = NULL, cfg_weight = NULL, stability = NULL,
                    similarity_boost = NULL, seed = NULL,
                    response_format = NULL, instructions = NULL,
                    language = NULL, device = "cuda") {
    .sidecar_arm(environment(), "file")

    # Deprecated: backend = "native" was the in-process chatterbox package,
    # now expressed as backend = "chatterbox", source = "package".
    if (identical(backend, "native")) {
        warning("backend = 'native' is deprecated; use ",
                "backend = 'chatterbox', source = 'package'.", call. = FALSE)
        backend <- "chatterbox"
        if (missing(source)) source <- "package"
    }
    backend <- match.arg(backend)
    source <- match.arg(source)

    # Validate required parameters early (before backend dispatch)
    if (!is.character(input) || length(input) != 1 || nchar(input) == 0) {
        stop("'input' must be a non-empty character string", call. = FALSE)
    }
    if (!is.character(voice) || length(voice) != 1 || nchar(voice) == 0) {
        stop("'voice' must be a non-empty character string", call. = FALSE)
    }

    # Resolve engine: "auto" defaults to chatterbox.
    if (backend == "auto") {
        backend <- "chatterbox"
    }

    # Resolve where it runs: "auto" prefers the in-process package for
    # chatterbox when installed, otherwise the API.
    if (source == "auto") {
        source <- if (backend == "chatterbox" && .has_chatterbox()) {
            "package"
        } else {
            "api"
        }
    }

    # Only chatterbox has a package implementation.
    if (source == "package" && backend != "chatterbox") {
        stop("source = 'package' is only available for backend = 'chatterbox'; ",
             backend, " runs via the API (source = 'api').", call. = FALSE)
    }

    # Dispatch to the in-process chatterbox package
    if (source == "package") {
        return(.via_chatterbox(
                input = input,
                voice = voice,
                file = file,
                exaggeration = exaggeration,
                cfg_weight = cfg_weight,
                temperature = temperature,
                device = device,
                turbo = identical(model, "turbo")
            ))
    }

    # Auto-acquire GPU for container backends via gpu.ctl
    if (backend %in% c("chatterbox", "qwen3")) {
        .gpuctl_acquire(backend)
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
    if (!is.null(instructions)) {
        # qwen3 uses 'instruct', OpenAI uses 'instructions'
        if (backend == "qwen3") {
            body$instruct <- instructions
        } else {
            body$instructions <- instructions
        }
    }
    if (!is.null(language)) body$language <- language

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


