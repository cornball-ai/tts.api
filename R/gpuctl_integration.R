# gpu.ctl integration for tts.api
#
# Optionally acquires GPU resources before API calls when gpu.ctl is available.
# Enable with: options(tts.gpuctl = TRUE)

# Service registry for TTS backends
.tts_gpu_services <- list(
    chatterbox = list(
        name = "chatterbox",
        port = 7810,
        vram = 6,
        container = "chatterbox",
        health = "/health"
    ),
    qwen3 = list(
        name = "qwen3-tts",
        port = 7811,
        vram = 8,
        container = "qwen3-tts-api",
        health = "/health"
    )
)

#' Check if gpu.ctl integration is enabled
#' @noRd
.gpuctl_enabled <- function () {
    isTRUE(getOption("tts.gpuctl", FALSE)) &&
    requireNamespace("gpu.ctl", quietly = TRUE)
}

#' Register tts.api service with gpu.ctl
#' @param backend Character. Backend name ("chatterbox" or "qwen3")
#' @noRd
.gpuctl_register_service <- function (backend = "chatterbox") {
    if (!.gpuctl_enabled()) return(invisible(FALSE))

    service <- .tts_gpu_services[[backend]]
    if (is.null(service)) {
        warning("Unknown backend for gpu.ctl: ", backend, call. = FALSE)
        return(invisible(FALSE))
    }

    tryCatch({
            # Only register if not already registered
            existing <- gpu.ctl::gpu_services()
            if (!service$name %in% existing$name) {
                gpu.ctl::gpu_register(
                    name = service$name,
                    port = service$port,
                    vram = service$vram,
                    container = service$container,
                    health_endpoint = service$health
                )
            }
        }, error = function (e) {
            # Silently ignore registration errors
        })
    invisible(TRUE)
}

#' Acquire GPU for TTS backend if gpu.ctl is enabled
#'
#' @param backend Character. Backend name ("chatterbox" or "qwen3")
#' @return Invisible TRUE if acquired, FALSE if not using gpu.ctl
#' @noRd
.gpuctl_acquire <- function (backend = "chatterbox") {
    if (!.gpuctl_enabled()) return(invisible(FALSE))

    service <- .tts_gpu_services[[backend]]
    if (is.null(service)) {
        warning("Unknown backend for gpu.ctl: ", backend, call. = FALSE)
        return(invisible(FALSE))
    }

    .gpuctl_register_service(backend)

    tryCatch({
            gpu.ctl::gpu_acquire(service$name)

            # Auto-set tts.api_base from gpu.ctl's service URL
            url <- gpu.ctl::gpu_service_url(service$name)
            if (!is.null(url)) {
                options(tts.api_base = url)
            }

            invisible(TRUE)
        }, error = function (e) {
            warning("gpu.ctl: ", e$message, call. = FALSE)
            invisible(FALSE)
        })
}

