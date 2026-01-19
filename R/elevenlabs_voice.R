#' Upload Voice to ElevenLabs (Instant Voice Clone)
#'
#' Create an instant voice clone on ElevenLabs from audio samples.
#'
#' @param files Character vector. Paths to audio files (1-25 files, each up to 10MB).
#' @param name Character. Name for the cloned voice.
#' @param description Character or NULL. Optional description.
#' @param remove_background_noise Logical. Remove background noise from samples. Default FALSE.
#' @param labels Named list or NULL. Optional labels (e.g., list(accent = "british")).
#'
#' @return List with voice_id and name on success.
#' @export
#'
#' @examples
#' \dontrun{
#' # Clone from a single file
#' voice <- elevenlabs_voice_upload(
#'   files = "my_voice.mp3",
#'   name = "My Clone"
#' )
#'
#' # Use the cloned voice
#' speech("Hello!", voice = voice$voice_id, backend = "elevenlabs")
#'
#' # Clone from multiple samples
#' voice <- elevenlabs_voice_upload(
#'   files = c("sample1.mp3", "sample2.mp3"),
#'   name = "Better Clone",
#'   remove_background_noise = TRUE
#' )
#' }
elevenlabs_voice_upload <- function(
  files,
  name,
  description = NULL,
  remove_background_noise = FALSE,
  labels = NULL
) {

  # Validate inputs
  if (!is.character(files) || length(files) == 0) {
    stop("'files' must be a non-empty character vector of file paths", call. = FALSE)
  }
  if (length(files) > 25) {
    stop("Maximum 25 files allowed", call. = FALSE)
  }
  for (f in files) {
    if (!file.exists(f)) {
      stop("File not found: ", f, call. = FALSE)
    }
    if (file.info(f) $size > 10 * 1024 * 1024) {
      stop("File exceeds 10MB limit: ", f, call. = FALSE)
    }
  }

  if (!is.character(name) || length(name) != 1 || nchar(name) == 0) {
    stop("'name' must be a non-empty character string", call. = FALSE)
  }

  # Build multipart form
  h <- curl::new_handle()
  form_data <- list(name = name)

  if (!is.null(description)) {
    form_data$description <- description
  }

  form_data$remove_background_noise <- tolower(as.character(remove_background_noise))

  if (!is.null(labels)) {
    form_data$labels <- jsonlite::toJSON(labels, auto_unbox = TRUE)
  }

  # Add files
  for (f in files) {
    form_data <- c(form_data, list(files = curl::form_file(f)))
  }

  curl::handle_setform(h, .list = form_data)

  response <- .elevenlabs_request("voices/add", handle = h)
  result <- jsonlite::fromJSON(rawToChar(response$content))

  list(
    voice_id = result$voice_id,
    name = name
  )
}

#' List ElevenLabs Voices
#'
#' Get all voices available in your ElevenLabs account.
#'
#' @return Data frame with voice_id, name, and category columns.
#' @export
#'
#' @examples
#' \dontrun{
#' voices <- elevenlabs_voices()
#' print(voices)
#' }
elevenlabs_voices <- function() {
  response <- .elevenlabs_request("voices")
  result <- jsonlite::fromJSON(rawToChar(response$content))

  if (length(result$voices) == 0) {
    return(data.frame(
      voice_id = character(),
      name = character(),
      category = character(),
      stringsAsFactors = FALSE
      ))
  }

  data.frame(
    voice_id = result$voices$voice_id,
    name = result$voices$name,
    category = result$voices$category,
    stringsAsFactors = FALSE
  )
}

#' Delete ElevenLabs Voice
#'
#' Delete a voice from your ElevenLabs account.
#'
#' @param voice_id Character. The voice ID to delete.
#'
#' @return Invisible TRUE on success.
#' @export
#'
#' @examples
#' \dontrun{
#' elevenlabs_voice_delete("abc123")
#' }
elevenlabs_voice_delete <- function(voice_id) {
  if (!is.character(voice_id) || length(voice_id) != 1 || nchar(voice_id) == 0) {
    stop("'voice_id' must be a non-empty character string", call. = FALSE)
  }

  .elevenlabs_request(paste0("voices/", voice_id), method = "DELETE")
  invisible(TRUE)
}

