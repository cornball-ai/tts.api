#' Generate Speech with Designed Voice
#'
#' Create a voice from a natural language description and generate speech.
#' This endpoint requires the qwen3-tts-api backend with the voice design model.
#'
#' @param input Character. The text to convert to speech.
#' @param voice_description Character. Natural language description of the
#'   desired voice (e.g., "A warm, friendly female voice with a slight British accent").
#' @param file Character or NULL. Output file path. If NULL, returns raw bytes.
#' @param language Character. Language for synthesis. Supported: Chinese, English,
#'   Japanese, Korean, German, French, Russian, Portuguese, Spanish, Italian.
#'
#' @return If \code{file} is provided, invisibly returns the file path.
#'   If \code{file} is NULL, returns raw audio bytes.
#'
#' @details
#' This function uses the \code{/v1/audio/speech/design} endpoint which is
#' specific to qwen3-tts-api. It requires the VoiceDesign model to be loaded
#' (loaded on first use).
#'
#' @export
#' @examples
#' \dontrun{
#' set_tts_base("http://localhost:7811")
#'
#' # Generate speech with a custom designed voice
#' speech_design(
#'   input = "Hello, I am your AI assistant.",
#'   voice_description = "A professional male voice, clear and authoritative",
#'   file = "assistant.wav"
#' )
#'
#' # Playful voice
#' speech_design(
#'   input = "Let's have some fun!",
#'   voice_description = "An energetic young female voice, cheerful and playful",
#'   file = "playful.wav"
#' )
#' }
speech_design <- function(input, voice_description, file = NULL,
                          language = "English") {
    .sidecar_arm(environment(), "file")

    # Validate required parameters
    if (!is.character(input) || length(input) != 1 || nchar(input) == 0) {
        stop("'input' must be a non-empty character string", call. = FALSE)
    }
    if (!is.character(voice_description) || length(voice_description) != 1 ||
        nchar(voice_description) == 0) {
        stop("'voice_description' must be a non-empty character string",
             call. = FALSE)
    }

    # Build request body
    body <- list(
                 input = input,
                 voice_description = voice_description,
                 language = language
    )

    # Make request
    audio_data <- .tts_post_json("/v1/audio/speech/design", body, expect_binary = TRUE)

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
