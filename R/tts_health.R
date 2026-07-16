#' Check if Chatterbox Service is Available
#'
#' Quick check if the local Chatterbox TTS API is reachable.
#' Returns TRUE/FALSE without throwing errors.
#'
#' @param port Port to check (default from CHATTERBOX_PORT env var or 7810)
#' @param timeout Timeout in seconds (default 2)
#' @return TRUE if service is available, FALSE otherwise
#' @export
#' @examples
#' \dontrun{
#'   if (chatterbox_available()) {
#'     tts("Hello", voice = "default", backend = "chatterbox")
#'   }
#' }
chatterbox_available <- function (port = NULL, timeout = 2) {
    if (is.null(port)) {
        port <- Sys.getenv("CHATTERBOX_PORT", "7810")
    }
    url <- paste0("http://localhost:", port, "/health")

    tryCatch({
            h <- curl::new_handle()
            curl::handle_setopt(h, timeout = timeout)
            res <- curl::curl_fetch_memory(url, handle = h)
            res$status_code == 200
        }, error = function (e) FALSE)
}

#' Check if Qwen3-TTS Service is Available
#'
#' Quick check if Qwen3-TTS API is reachable. Distinguishes from Chatterbox
#' by checking for the qwen3-specific /v1/audio/speech/design endpoint.
#'
#' @param port Port to check (default from QWEN3_TTS_PORT env var or 7811)
#' @param timeout Timeout in seconds (default 2)
#' @return TRUE if Qwen3-TTS is available, FALSE otherwise
#' @export
#' @examples
#' \dontrun{
#'   if (qwen3_available()) {
#'     tts("Hello", voice = "Vivian", backend = "qwen3")
#'   }
#' }
qwen3_available <- function(port = NULL, timeout = 2)
{
    if (is.null(port)) {
        port <- Sys.getenv("QWEN3_TTS_PORT", "7811")
    }
    # Check for qwen3-specific endpoint (Chatterbox doesn't have /v1/audio/speech/design)
    url <- paste0("http://localhost:", port, "/v1/audio/speech/design")

    tryCatch({
            h <- curl::new_handle()
            curl::handle_setopt(h, timeout = timeout, customrequest = "OPTIONS")
            res <- curl::curl_fetch_memory(url, handle = h)
            # 200 or 405 (Method Not Allowed) means endpoint exists
            res$status_code < 500
        }, error = function(e) FALSE)
}

#' Check TTS API Health
#'
#' Checks whether the TTS backend is reachable by trying common health endpoints.
#'
#' @return A list with components:
#' \describe{
#'   \item{ok}{Logical. TRUE if the server is reachable.}
#'   \item{status}{Character. A human-readable status message.}
#'   \item{raw}{The raw response from the server (if any).}
#' }
#'
#' @export
#' @examples
#' \dontrun{
#' set_tts_base("http://localhost:4123")
#' h <- tts_health()
#' if (h$ok) {
#'   message("Server is ready!")
#' }
#' }
tts_health <- function() {
    base <- .tts_get_api_base()
    timeout <- getOption("tts.timeout", 30)

    # Endpoints to try in order
    endpoints <- c("/health", "/v1/status", "/")

    for (endpoint in endpoints) {
        result <- .try_health_endpoint(base, endpoint, timeout)
        if (result$ok) {
            return(result)
        }
    }

    # All endpoints failed
    list(
        ok = FALSE,
        status = "Server unreachable at all health endpoints",
        raw = NULL
    )
}

#' Try a single health endpoint
#' @return List with elements \code{ok}, \code{status}, and \code{raw}.
#' @keywords internal
.try_health_endpoint <- function(
    base,
    endpoint,
    timeout
) {
    url <- paste0(base, endpoint)
    h <- curl::new_handle()
    curl::handle_setopt(h, timeout = timeout)

    response <- tryCatch(
        curl::curl_fetch_memory(url, handle = h),
        error = function(e) {
            list(status_code = 0, content = raw(), error = e$message)
        }
    )

    if (!is.null(response$error)) {
        return(list(
                ok = FALSE,
                status = paste("Connection failed:", response$error),
                raw = NULL
            ))
    }

    status <- response$status_code
    if (status >= 200 && status < 400) {
        raw_content <- tryCatch(
            jsonlite::fromJSON(rawToChar(response$content)),
            error = function(e) rawToChar(response$content)
        )
        return(list(
                ok = TRUE,
                status = paste("OK (", endpoint, ")", sep = ""),
                raw = raw_content
            ))
    }

    list(
        ok = FALSE,
        status = paste("HTTP", status, "at", endpoint),
        raw = NULL
    )
}

