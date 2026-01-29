# Native chatterbox package backend

# Module-level chatterbox model cache
.native_chatterbox_cache <- new.env(parent = emptyenv())

# Check if native chatterbox package is available
.has_chatterbox <- function () {
    requireNamespace("chatterbox", quietly = TRUE)
}

#' Get or create cached native chatterbox model
#' @param device Device to use ("cuda", "cpu", "mps")
#' @return Loaded chatterbox model object
#' @keywords internal
.get_native_chatterbox_model <- function (device = "cuda") {
    cache_key <- paste("chatterbox", device, sep = "_")
    if (is.null(.native_chatterbox_cache[[cache_key]])) {
        message("Loading native chatterbox model on ", device, "...")
        model <- chatterbox::chatterbox(device)
        .native_chatterbox_cache[[cache_key]] <- tryCatch(
            chatterbox::load_chatterbox(model),
            error = function (e) {
                stop(
                    "Failed to load chatterbox model: ", conditionMessage(e),
                    call. = FALSE
                )
            }
        )
        message("Native chatterbox model loaded and cached.")
    }
    .native_chatterbox_cache[[cache_key]]
}

#' Clear native chatterbox model cache
#'
#' Removes cached native chatterbox models from memory. Call this to free GPU/RAM
#' after batch processing is complete.
#'
#' @export
clear_native_chatterbox_cache <- function () {
    models <- ls(.native_chatterbox_cache)
    if (length(models) > 0) {
        rm(list = models, envir = .native_chatterbox_cache)
        gc()
        if (requireNamespace("torch", quietly = TRUE)) {
            torch::cuda_empty_cache()
        }
        message("Cleared ", length(models), " cached native chatterbox model(s).")
    } else {
        message("Native chatterbox cache is empty.")
    }
    invisible(NULL)
}

#' Internal: Generate speech via native chatterbox package
#'
#' Uses the cornball-ai/chatterbox native R torch implementation.
#'
#' @param input Character. Text to convert to speech.
#' @param voice Character. Path to voice reference audio file.
#' @param file Character or NULL. Output file path.
#' @param exaggeration Numeric or NULL. Exaggeration parameter.
#' @param cfg_weight Numeric or NULL. CFG weight parameter.
#' @param temperature Numeric or NULL. Sampling temperature.
#' @param device Character. Device to use ("cuda", "cpu").
#' @return If file is NULL, returns list with audio and sample_rate.
#'   If file is provided, writes to file and returns file path invisibly.
#' @keywords internal
.via_chatterbox <- function (input, voice, file = NULL, exaggeration = NULL,
                             cfg_weight = NULL, temperature = NULL,
                             device = "cuda") {
    if (!.has_chatterbox()) {
        stop(
            "chatterbox package is not installed.\n",
            "Install with: remotes::install_github('cornball-ai/chatterbox')",
            call. = FALSE
        )
    }

    # Validate voice file exists

    if (!file.exists(voice)) {
        stop("Voice reference file not found: ", voice, call. = FALSE)
    }

    # Get cached model
    model <- .get_native_chatterbox_model(device)

    # Set defaults
    exaggeration <- exaggeration %||% 0.5
    cfg_weight <- cfg_weight %||% 0.5
    temperature <- temperature %||% 0.8

    # Generate speech
    result <- tryCatch(
        chatterbox::tts(
            model = model,
            text = input,
            voice = voice,
            exaggeration = exaggeration,
            cfg_weight = cfg_weight,
            temperature = temperature
        ),
        error = function (e) {
            stop(
                "TTS generation failed: ", conditionMessage(e),
                call. = FALSE
            )
        }
    )

    # Return raw audio or write to file
    if (is.null(file)) {
        return(result)
    }

    # Write to file
    chatterbox::write_audio(result$audio, result$sample_rate, file)
    invisible(file)
}

# Null coalescing operator if not available
`%||%` <- function (x, y) if (is.null(x)) y else x

