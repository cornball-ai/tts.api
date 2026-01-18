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
  timeout <- getOption("tts.timeout", 30)
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


#' Get ElevenLabs API Key
#'
#' @return Character. The API key.
#' @keywords internal
.elevenlabs_api_key <- function() {
  api_key <- Sys.getenv("ELEVENLABS_API_KEY")
  if (api_key == "") {
    api_key <- getOption("tts.elevenlabs_key")
  }
  if (is.null(api_key) || api_key == "") {
    stop("ElevenLabs API key not set. Set ELEVENLABS_API_KEY env var or use set_elevenlabs_key()", call. = FALSE)
  }
  api_key
}


#' Make an HTTP Request to the ElevenLabs API
#'
#' @param endpoint Character. The API endpoint (e.g., "voices").
#' @param method Character. HTTP method ("GET", "POST", or "DELETE").
#' @param handle curl handle or NULL. Pre-configured handle for multipart forms.
#' @return curl response object.
#' @keywords internal
.elevenlabs_request <- function(endpoint, method = "GET", handle = NULL) {
  url <- paste0("https://api.elevenlabs.io/v1/", endpoint)

  if (is.null(handle)) {
    handle <- curl::new_handle()
  }

  curl::handle_setheaders(handle, "xi-api-key" = .elevenlabs_api_key())

  if (method == "DELETE") {
    curl::handle_setopt(handle, customrequest = "DELETE")
  }

  response <- tryCatch(
    curl::curl_fetch_memory(url, handle = handle),
    error = function(e) {
      stop("ElevenLabs connection failed: ", e$message, call. = FALSE)
    }
  )

  if (response$status_code >= 400) {
    err_msg <- tryCatch({
      err <- jsonlite::fromJSON(rawToChar(response$content))
      err$detail$message %||% err$detail %||% rawToChar(response$content)
    }, error = function(e) rawToChar(response$content))
    stop("ElevenLabs API error (", response$status_code, "): ", err_msg, call. = FALSE)
  }

  response
}
