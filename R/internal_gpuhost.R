# The fleet's GPU host as a place chatterbox runs: tts.api's third source.
#
# gpu.host is the client to a gpu.ctl host, or to the router in front of
# several: one base, one token, POST /infer with the text and the voice
# in the request. This file is the model-shaped half, which is the half
# the client refuses to know: which catalog entry, what goes in the
# input, and how the host's reply becomes the file the caller asked
# for. The reply is float32 PCM with the sample rate in a header;
# gpu.host turns it into a WAV, and ffmpeg (already used here for
# speed) makes any other container.

.has_gpu_host <- function() {
    requireNamespace("gpu.host", quietly = TRUE)
}

# Configured means a base resolves and the token file exists; whether
# the host answers is asked when a request is made.
.gpu_host_configured <- function() {
    .has_gpu_host() && gpu.host::gpu_host_configured()
}

# Which catalog entry synthesizes on this host. A property of the
# endpoint, not of tts.api; the fleet's hosts declare chatterbox-turbo
# today, and a name fixed here would make tts() usable against exactly
# one catalog. In order: the caller's model ("turbo" is the package
# source's sub-model switch and names the same thing here), then
# options(tts.gpuhost_entry), then the first chatterbox entry the host's
# /health lists.
.gpuhost_entry <- function(model = NULL) {
    if (!is.null(model)) {
        if (identical(model, "turbo")) {
            return("chatterbox-turbo")
        }
        return(model)
    }
    opt <- getOption("tts.gpuhost_entry")
    if (is.character(opt) && length(opt) == 1L && !is.na(opt) && nzchar(opt)) {
        return(opt)
    }
    entries <- as.character(gpu.host::gpu_host_health()$entries)
    hit <- entries[startsWith(entries, "chatterbox")]
    if (!length(hit)) {
        stop("the GPU host serves no chatterbox entry (it lists: ",
             paste(entries, collapse = ", "), "); name one with model = ",
             "or options(tts.gpuhost_entry = )", call. = FALSE)
    }
    hit[[1L]]
}

# The voice, as the entry takes it. A file travels as its bytes. A name
# is looked up in the host's own library first, since the recording the
# host holds is the one it fingerprints and caches by; then in the
# local library, sent as bytes like a file.
.gpuhost_voice <- function(voice) {
    if (file.exists(voice)) {
        bytes <- readBin(voice, "raw", n = file.size(voice))
        return(list(voice_b64 = jsonlite::base64_enc(bytes)))
    }
    lib <- tryCatch(gpu.host::gpu_host_voices()$voices, error = function(e) NULL)
    if (is.data.frame(lib) && nrow(lib) > 0 && all(c("id", "name") %in% names(lib))) {
        idx <- match(voice, lib$name)
        if (is.na(idx)) {
            idx <- match(tolower(voice), tolower(lib$name))
        }
        if (!is.na(idx)) {
            return(list(voice_id = as.character(lib$id[[idx]])))
        }
    }
    path <- tryCatch(voice_file(voice), error = function(e) NULL)
    if (!is.null(path)) {
        bytes <- readBin(path, "raw", n = file.size(path))
        return(list(voice_b64 = jsonlite::base64_enc(bytes)))
    }
    stop("Voice '", voice, "' is not a file, not in the GPU host's library (",
         if (is.data.frame(lib) && nrow(lib) > 0) {
             paste(lib$name, collapse = ", ")
         } else {
             "it lists none"
         },
         "), and not in the local library.", call. = FALSE)
}

#' Internal: Synthesize on the fleet's GPU host
#'
#' One \code{/infer} request through gpu.host. The entry takes the text,
#' the voice and a temperature; it has no CFG, so \code{exaggeration}
#' and \code{cfg_weight} are not sent, and that is said rather than
#' swallowed. The reply is PCM, written as WAV; any other extension on
#' \code{file}, or a speed other than 1, goes through ffmpeg.
#'
#' @param input The text.
#' @param voice A file, a name in the host's library, or a name in the
#'   local library.
#' @param file Output path, or NULL for the WAV bytes.
#' @param model The catalog entry, or NULL (see \code{.gpuhost_entry}).
#' @param temperature Sampling temperature, or NULL for the entry's own.
#' @param speed Speed multiplier applied with ffmpeg, or NULL.
#' @param exaggeration,cfg_weight Not taken by the entry; reported.
#' @param seed Not taken by the entry; reported.
#' @return \code{file} invisibly, or the WAV as raw bytes.
#' @keywords internal
.via_gpuhost <- function(input, voice, file = NULL, model = NULL,
                         temperature = NULL, speed = NULL,
                         exaggeration = NULL, cfg_weight = NULL,
                         seed = NULL) {
    if (!.has_gpu_host()) {
        stop("source = 'gpuhost' needs the gpu.host package.\n",
             "Install with: remotes::install_github('cornball-ai/gpu.host')",
             call. = FALSE)
    }
    entry <- .gpuhost_entry(model)
    req <- c(list(text = input), .gpuhost_voice(voice))
    if (!is.null(temperature)) {
        req$temperature <- as.numeric(temperature)
    }
    # Said, not swallowed: the host's schema is closed, so sending these
    # would be a 400, and dropping them without a word is how a caller
    # keeps passing something inert.
    dropped <- c(if (!is.null(exaggeration)) "exaggeration",
                 if (!is.null(cfg_weight)) "cfg_weight",
                 if (!is.null(seed)) "seed")
    if (length(dropped)) {
        message("gpuhost: entry ", entry, " takes no ",
                paste(dropped, collapse = ", "), "; not sent")
    }

    reply <- gpu.host::gpu_host_infer(entry, req,
                                      timeout = getOption("tts.timeout", 30))
    wav <- gpu.host::gpu_host_wav(gpu.host::gpu_host_pcm(reply))
    if (is.null(file)) {
        return(wav)
    }

    ext <- tolower(tools::file_ext(file))
    plain <- is.null(speed) || speed == 1
    if (ext %in% c("", "wav") && plain) {
        tryCatch(writeBin(wav, file), error = function(e) {
            stop("Failed to write audio to '", file, "': ", e$message,
                 call. = FALSE)
        })
        return(invisible(file))
    }
    tmp <- tempfile(fileext = ".wav")
    on.exit(unlink(tmp), add = TRUE)
    writeBin(wav, tmp)
    if (plain) {
        .ffmpeg_convert(tmp, file)
    } else {
        .apply_speed_ffmpeg(tmp, file, speed)
    }
    invisible(file)
}

# WAV to whatever the output's extension says, with ffmpeg; the speed
# path does the same with a filter in between.
.ffmpeg_convert <- function(input_file, output_file) {
    result <- system2("ffmpeg",
                      c("-y", "-loglevel", "error", "-i", shQuote(input_file),
                        shQuote(output_file)),
                      stdout = TRUE, stderr = TRUE)
    status <- attr(result, "status")
    if (!is.null(status) && status != 0) {
        stop("ffmpeg failed writing '", output_file, "': ",
             paste(result, collapse = "\n"), call. = FALSE)
    }
    invisible(output_file)
}
