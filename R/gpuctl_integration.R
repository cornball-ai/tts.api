# gpu.ctl integration for tts.api
#
# Optionally acquires GPU resources before API calls when gpu.ctl is available.
# Enable with: options(tts.gpuctl = TRUE)

# Service configuration for Chatterbox TTS
.tts_gpu_service <- list(
  name = "chatterbox",
  port = 8100,
  vram = 6,
  container = "chatterbox",
  health = "/health"
)

#' Check if gpu.ctl integration is enabled
#' @noRd
.gpuctl_enabled <- function() {
  isTRUE(getOption("tts.gpuctl", FALSE)) &&
    requireNamespace("gpu.ctl", quietly = TRUE)
}

#' Register tts.api service with gpu.ctl
#' @noRd
.gpuctl_register_service <- function() {
  if (!.gpuctl_enabled()) return(invisible(FALSE))

  tryCatch({
    # Only register if not already registered
    existing <- gpu.ctl::gpu_services()
    if (!.tts_gpu_service$name %in% existing$name) {
      gpu.ctl::gpu_register(
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

#' Acquire GPU for chatterbox if gpu.ctl is enabled
#'
#' @return Invisible TRUE if acquired, FALSE if not using gpu.ctl
#' @noRd
.gpuctl_acquire <- function() {
  if (!.gpuctl_enabled()) return(invisible(FALSE))

  .gpuctl_register_service()

  tryCatch({
    gpu.ctl::gpu_acquire(.tts_gpu_service$name)
    invisible(TRUE)
  }, error = function(e) {
    warning("gpu.ctl: ", e$message, call. = FALSE)
    invisible(FALSE)
  })
}
