#' Make an HTTP Request to the TTS API
#'
#' Low-level HTTP wrapper around curl::curl_fetch_memory().
#'
#' @param endpoint Character. The API endpoint (e.g., "/v1/audio/speech").
#' @param method Character. HTTP method ("GET" or "POST").
#' @param body List or NULL. Request body for POST requests.
#' @param expect_binary Logical. If TRUE, expect binary response (audio data).
#' @return Response content (raw bytes if binary, parsed JSON otherwise).
#' @keywords internal
.tts_request <- function(endpoint, method = "GET", body = NULL,
                         expect_binary = FALSE) {
  base <- .tts_get_api_base()
  url <- paste0(base, endpoint)

  h <- curl::new_handle()
  timeout <- getOption("ttsapi.timeout", 30)
  curl::handle_setopt(h, timeout = timeout)

 # Build headers
  headers <- c("Content-Type" = "application/json")
  api_key <- .tts_get_api_key()
  if (!is.null(api_key) && nchar(api_key) > 0) {
    headers <- c(headers, "Authorization" = paste("Bearer", api_key))
  }
  curl::handle_setheaders(h, .list = headers)

  # Set method and body
  if (method == "POST" && !is.null(body)) {
    json_body <- jsonlite::toJSON(body, auto_unbox = TRUE)
    curl::handle_setopt(h, post = TRUE, postfields = json_body)
  }

  # Make request
  response <- tryCatch(
    curl::curl_fetch_memory(url, handle = h),
    error = function(e) {
      stop("Connection failed: ", e$message, call. = FALSE)
    }
  )

  # Check HTTP status
  status <- response$status_code
  if (status >= 400) {
    # Try to parse error message from JSON response
    err_msg <- tryCatch({
      err <- jsonlite::fromJSON(rawToChar(response$content))
      if (!is.null(err$error$message)) {
        err$error$message
      } else if (!is.null(err$error)) {
        as.character(err$error)
      } else if (!is.null(err$detail)) {
        as.character(err$detail)
      } else {
        rawToChar(response$content)
      }
    }, error = function(e) {
      rawToChar(response$content)
    })
    stop("API error (", status, "): ", err_msg, call. = FALSE)
  }

  # Return appropriate format
  if (expect_binary) {
    response$content
  } else {
    tryCatch(
      jsonlite::fromJSON(rawToChar(response$content)),
      error = function(e) rawToChar(response$content)
    )
  }
}

#' POST JSON to the TTS API
#'
#' @param endpoint Character. The API endpoint.
#' @param body List. Request body.
#' @param expect_binary Logical. If TRUE, expect binary response.
#' @return Response content.
#' @keywords internal
.tts_post_json <- function(endpoint, body, expect_binary = FALSE) {
  .tts_request(endpoint, method = "POST", body = body,
               expect_binary = expect_binary)
}

#' GET from the TTS API
#'
#' @param endpoint Character. The API endpoint.
#' @return Parsed JSON response.
#' @keywords internal
.tts_get <- function(endpoint) {
  .tts_request(endpoint, method = "GET", expect_binary = FALSE)
}
