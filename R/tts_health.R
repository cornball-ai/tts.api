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
#' tts_set_api_base("http://localhost:4123")
#' health <- tts_health()
#' if (health$ok) {
#'   message("Server is ready!")
#' }
#' }
tts_health <- function() {
  base <- .tts_get_api_base()
  timeout <- getOption("ttsapi.timeout", 30)

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
#' @keywords internal
.try_health_endpoint <- function(base, endpoint, timeout) {
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
