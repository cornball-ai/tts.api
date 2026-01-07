#' TTS Provider Configurations
#'
#' A list of known TTS providers with their default voices and configuration.
#'
#' @format A named list where each element contains:
#' \describe{
#'   \item{voices}{Character vector of default/known voice names, or NULL if dynamic}
#'   \item{env_var}{Name of environment variable for API key, or NULL if not needed}
#'   \item{base_url}{Default API base URL, or NULL}
#' }
#'
#' @export
#' @examples
#' names(tts_providers)
#' tts_providers[["OpenAI"]]$voices
tts_providers <- list(
  "OpenAI" = list(
    voices = c("alloy", "ash", "coral", "echo", "fable", "onyx", "nova", "sage", "shimmer"),
    env_var = "OPENAI_API_KEY",
    base_url = "https://api.openai.com"
  ),

  "Chatterbox (Local)" = list(
    voices = NULL,  # Fetched dynamically from container
    env_var = NULL,
    base_url = "http://localhost:8100"
  ),
  "ElevenLabs" = list(
    voices = NULL,  # Fetched dynamically from API
    env_var = "ELEVENLABS_API_KEY",
    base_url = "https://api.elevenlabs.io"
  )
)

#' Get Voices for a TTS Provider
#'
#' Returns available voices for a given provider. Attempts to fetch dynamically
#' from the API first, falls back to static list if unavailable.
#'
#' @param provider Character string naming the provider (e.g., "OpenAI", "Chatterbox (Local)")
#' @param base_url Optional base URL override for the provider's API
#' @param timeout Timeout in seconds for API requests (default 2)
#'
#' @return Character vector of voice names
#' @export
#'
#' @examples
#' \dontrun{
#' tts_voices("OpenAI")
#' tts_voices("Chatterbox (Local)")
#' }
tts_voices <- function(provider, base_url = NULL, timeout = 2) {
  # Get provider config

config <- tts_providers[[provider]]

  # Determine base URL
  if (is.null(base_url)) {
    base_url <- if (!is.null(config$base_url)) config$base_url else getOption("ttsapi.base")
  }

  # Try to fetch voices dynamically
  if (!is.null(base_url)) {
    voices <- tryCatch({
      .fetch_voices_from_api(base_url, timeout)
    }, error = function(e) NULL)

    if (!is.null(voices) && length(voices) > 0) {
      return(voices)
    }
  }

  # Fall back to static list
  if (!is.null(config$voices)) {
    return(config$voices)
  }

  # Last resort default
  c("default")
}

#' Fetch voices from API
#' @keywords internal
.fetch_voices_from_api <- function(base_url, timeout = 2) {
  # Try /voices endpoint (Chatterbox style)
  url <- paste0(base_url, "/voices")
  res <- tryCatch({
    curl::curl_fetch_memory(url, handle = curl::new_handle(timeout = timeout))
  }, error = function(e) NULL)

  if (!is.null(res) && res$status_code == 200) {
    content <- jsonlite::fromJSON(rawToChar(res$content))
    if (is.character(content)) {
      return(content)
    }
    if (is.list(content) && !is.null(content$voices)) {
      return(unlist(content$voices))
    }
    if (is.data.frame(content) && "name" %in% names(content))
{
      return(content$name)
    }
  }

  # Try /v1/audio/voices endpoint (OpenAI style)
  url <- paste0(base_url, "/v1/audio/voices")
  res <- tryCatch({
    curl::curl_fetch_memory(url, handle = curl::new_handle(timeout = timeout))
  }, error = function(e) NULL)

  if (!is.null(res) && res$status_code == 200) {
    content <- jsonlite::fromJSON(rawToChar(res$content))
    if (is.list(content) && !is.null(content$voices)) {
      return(unlist(content$voices))
    }
    if (is.list(content) && !is.null(content$data)) {
      if (is.data.frame(content$data) && "voice_id" %in% names(content$data)) {
        return(content$data$voice_id)
      }
      return(unlist(content$data))
    }
  }

  NULL
}
