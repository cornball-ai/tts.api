# gpuctl integration for ttsapi
#
# Optionally acquires GPU resources before API calls when gpuctl is available.
# Enable with: options(ttsapi.gpuctl = TRUE)

# Service configuration for Chatterbox TTS
.tts_gpu_service <- list(
  name = "chatterbox",
  port = 8100,
  vram = 6,
  container = "chatterbox",
  health = "/health"
)

#' Check if gpuctl integration is enabled
#' @noRd
.gpuctl_enabled <- function() {
  isTRUE(getOption("ttsapi.gpuctl", FALSE)) &&
    requireNamespace("gpuctl", quietly = TRUE)
}

#' Register ttsapi service with gpuctl
#' @noRd
.gpuctl_register_service <- function() {
  if (!.gpuctl_enabled()) return(invisible(FALSE))

  tryCatch({
    # Only register if not already registered
    existing <- gpuctl::gpu_services()
    if (!.tts_gpu_service$name %in% existing$name) {
      gpuctl::gpu_register(
        name = .tts_gpu_service$name,
        port = .tts_gpu_service$port,
        vram = .tts_gpu_service$vram,
        container = .tts_gpu_service$container,
        health_endpoint = .tts_gpu_service$health
      )
    }
  }, error = function(e) {
    # Silently ignore registration errors
  })
  invisible(TRUE)
}

#' Acquire GPU for chatterbox if gpuctl is enabled
#'
#' @return Invisible TRUE if acquired, FALSE if not using gpuctl
#' @noRd
.gpuctl_acquire <- function() {
  if (!.gpuctl_enabled()) return(invisible(FALSE))

  .gpuctl_register_service()

  tryCatch({
    gpuctl::gpu_acquire(.tts_gpu_service$name)
    invisible(TRUE)
  }, error = function(e) {
    warning("gpuctl: ", e$message, call. = FALSE)
    invisible(FALSE)
  })
}
